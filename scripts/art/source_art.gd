class_name SourceArt
extends RefCounted
static var cache: Dictionary = {}

static func texture(kind: String, pose: int = 0) -> Texture2D:
	var key := kind+str(pose)
	if cache.has(key): return cache[key]
	var img := Image.create(96,112,false,Image.FORMAT_RGBA8)
	# Broad, angular clusters stay readable at the game's native pixel resolution.
	if kind=="guardian":
		PixelArt.disk(img,48,101,28,6,"172e39aa")
		for side in [-1,1]:
			var x: int=48+side*16
			PixelArt.rect(img,x-7,81,13,18,"334d50")
			PixelArt.rect(img,x-7,78,10,16,"6c8775")
			PixelArt.rect(img,x-6,79,7,3,"b1b69a")
			PixelArt.line(img,Vector2i(x,84),Vector2i(x+side*6,100),"9a925e",3)
			var hand_y: int=58-(12 if pose==1 else 3 if pose==2 else 0)
			PixelArt.disk(img,48+side*29,hand_y,10,13,"345459")
			PixelArt.disk(img,46+side*29,hand_y-2,8,10,"77947f")
			PixelArt.rect(img,43+side*29,hand_y-8,9,2,"b8c1a0")
			PixelArt.line(img,Vector2i(48+side*19,38),Vector2i(48+side*29,hand_y-10),"c5ad6e",3)
			PixelArt.line(img,Vector2i(48+side*9,30),Vector2i(48+side*20,15),"8b9d77",4)
			PixelArt.line(img,Vector2i(48+side*20,15),Vector2i(48+side*17,6),"b4bd8a",2)
			PixelArt.line(img,Vector2i(48+side*19,18),Vector2i(48+side*28,13),"a8b386",2)
		PixelArt.disk(img,48,64,20,23,"2f5056")
		PixelArt.disk(img,46,58,18,20,"688b79")
		PixelArt.line(img,Vector2i(33,45),Vector2i(39,75),"c0ad71",3)
		PixelArt.line(img,Vector2i(63,44),Vector2i(57,77),"a59861",3)
		PixelArt.disk(img,48,32,12,14,"3a5b59")
		PixelArt.rect(img,38,20,19,17,"86a085")
		PixelArt.rect(img,40,21,13,3,"c7c5a4")
		PixelArt.rect(img,39,32,7,3,"c8f3d8")
		PixelArt.rect(img,50,32,6,3,"c8f3d8")
		PixelArt.line(img,Vector2i(49,24),Vector2i(47,40),"476961",2)
		PixelArt.disk(img,48,60,9,11,"305760")
		PixelArt.poly(img,[Vector2i(48,46),Vector2i(55,59),Vector2i(48,72),Vector2i(41,59)],"a5e3cc")
		PixelArt.line(img,Vector2i(48,49),Vector2i(48,68),"f5ecc1",2)
	elif kind=="heart":
		PixelArt.disk(img,48,99,15,3,"17333caa")
		PixelArt.poly(img,[Vector2i(48,62),Vector2i(60,78),Vector2i(48,96),Vector2i(36,78)],"998957")
		PixelArt.poly(img,[Vector2i(48,66),Vector2i(56,78),Vector2i(48,90),Vector2i(40,78)],"8dd2bc")
		PixelArt.line(img,Vector2i(48,69),Vector2i(46,83),"e6f0cf",2)
		PixelArt.line(img,Vector2i(37,74),Vector2i(31,67),"c5b775",2)
		PixelArt.line(img,Vector2i(59,74),Vector2i(65,67),"c5b775",2)
	else:
		PixelArt.disk(img,48,99,27,6,"1c353daa")
		PixelArt.disk(img,48,94,26,9,"405d60")
		PixelArt.disk(img,48,90,23,8,"82947e")
		PixelArt.disk(img,48,87,19,7,"d1c394")
		PixelArt.disk(img,48,87,16,5,"527b72" if kind=="restored" else "293e4c")
		if kind=="broken":
			for i in 5:
				var x := 30+i*9
				PixelArt.poly(img,[Vector2i(x,92),Vector2i(x+3,66-i%2*9),Vector2i(x+9,89)],"8e7253" if pose>0 else "cc9e65")
				PixelArt.line(img,Vector2i(x+3,70),Vector2i(x+4,83),"f1d39a" if pose==0 else "ab936a",1)
		elif kind=="restored":
			PixelArt.disk(img,48,84,15,5,"87c6b1")
			PixelArt.line(img,Vector2i(39,83),Vector2i(55,83),"e1e9bd",1)
			for side in [-1,1]:
				PixelArt.line(img,Vector2i(48+side*18,93),Vector2i(48+side*24,63),"759d6b",2)
				PixelArt.disk(img,48+side*25,69,6,3,"a8bb74")
				PixelArt.disk(img,48+side*20,78,6,3,"bad792")
		else:
			for side in [-1,1]:
				PixelArt.rect(img,45+side*21,65,7,29,"4c6870")
				PixelArt.rect(img,45+side*21,63,7,3,"c6b67f")
			PixelArt.poly(img,[Vector2i(48,52),Vector2i(54,66),Vector2i(47,75),Vector2i(43,64)],"a8cbbb")
			PixelArt.line(img,Vector2i(30,74),Vector2i(65,85),"e1b47c",2)
			PixelArt.line(img,Vector2i(65,74),Vector2i(30,85),"e1b47c",2)
	cache[key]=ImageTexture.create_from_image(img)
	return cache[key]

static func sprite(kind: String, pose: int = 0) -> Sprite2D:
	var result := Sprite2D.new()
	result.texture=texture(kind,pose)
	result.offset=Vector2(0,-44)
	return result
