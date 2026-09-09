class_name AudioController
extends Node

var sounds: Dictionary = {}
var voices: Array[AudioStreamPlayer] = []
var cursor: int = 0
var volume: float = 0.4

func _ready() -> void:
	for i in 6:
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		voices.append(voice)
	for pair in [["bolt",660,0.14],["nova",280,0.36],["hit",140,0.08],["dash",420,0.13],["light",880,0.65],["hurt",95,0.18]]:
		sounds[pair[0]] = synthesize(float(pair[1]),float(pair[2]))

func synthesize(frequency: float, duration: float) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var count := int(22050*duration)
	var bytes := PackedByteArray()
	bytes.resize(count*2)
	for i in count:
		var time := float(i)/22050
		var envelope := minf(time*100,1)*pow(1-time/duration,2)
		var sample := (sin(TAU*frequency*time)+sin(TAU*frequency*1.5*time)*0.22)*envelope*0.22
		bytes.encode_s16(i*2,int(sample*32767))
	stream.data = bytes
	return stream

func play(id: String) -> void:
	if volume<=0 or not sounds.has(id):
		return
	var voice := voices[cursor%voices.size()]
	cursor += 1
	voice.stream = sounds[id]
	voice.volume_db = linear_to_db(volume)
	voice.play()

func _exit_tree() -> void:
	for voice in voices:
		voice.stop()
		voice.stream=null
	sounds.clear()
