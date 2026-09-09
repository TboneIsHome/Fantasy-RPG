class_name PixelArt
extends RefCounted

static var textures: Dictionary = {}

static func rect(img: Image, x: int, y: int, w: int, h: int, color: String) -> void:
	img.fill_rect(Rect2i(x,y,w,h), Color(color))

static func disk(img: Image, x: int, y: int, rx: int, ry: int, color: String) -> void:
	for py in range(maxi(0,y-ry), mini(img.get_height(),y+ry+1)):
		for px in range(maxi(0,x-rx), mini(img.get_width(),x+rx+1)):
			if pow(float(px-x)/rx,2)+pow(float(py-y)/ry,2) <= 1:
				img.set_pixel(px,py,Color(color))

static func texture(kind: String, variant: int = 0) -> Texture2D:
	var key := kind + str(variant)
	if textures.has(key):
		return textures[key]
	var img := Image.create(64,72,false,Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	match kind:
		"tree":
			var palette := ["183c3c","235344","367053","54946a","8cba7e"]
			if variant % 4 == 1:
				palette = ["583c39","81503f","ad724b","d49b59","ebc47b"]
			elif variant % 4 == 2:
				palette = ["193d48","28545e","367779","58a19a","97c7b4"]
			disk(img,32,64,21,6,"152e324f")
			rect(img,28,30,9,34,"303333")
			rect(img,30,33,4,30,"6e5544")
			rect(img,26,61,15,3,"594737")
			rect(img,34,29,4,18,"92714e")
			var clusters := [[21,36,18,13],[43,34,16,14],[31,20,21,16],[20,25,14,13],[44,24,13,12],[31,10,11,7]]
			for c in clusters:
				disk(img,c[0],c[1],c[2],c[3],palette[0])
				disk(img,c[0]-1,c[1]-3,c[2]-1,c[3]-2,palette[1])
				disk(img,c[0]-3,c[1]-5,c[2]-4,maxi(2,c[3]-5),palette[2])
				disk(img,c[0]-6,c[1]-7,maxi(2,c[2]-9),maxi(2,c[3]-8),palette[3])
			for p in [[12,22],[24,12],[35,15],[44,24],[20,29],[29,33],[43,36]]:
				rect(img,p[0],p[1],4,2,palette[4])
		"mage":
			disk(img,32,65,10,3,"102c355f")
			rect(img,25,61,5,5,"223747")
			rect(img,34,61,5,5,"223747")
			rect(img,24,47,15,16,"343b5f")
			rect(img,22,51,19,10,"55538b")
			rect(img,25,48,12,14,"8580b1")
			rect(img,26,54,3,9,"b9b4cf")
			rect(img,24,61,15,2,"d6b677")
			rect(img,29,41,9,8,"e5b686")
			rect(img,33,43,2,2,"253844")
			rect(img,25,39,12,3,"30374c")
			rect(img,19,39,25,3,"3b4064")
			rect(img,24,33,15,6,"6d679c")
			rect(img,27,28,10,7,"9086b5")
			rect(img,30,25,7,5,"c6b9d6")
			rect(img,25,37,15,2,"d6b677")
			rect(img,43,43,2,20,"a57a55")
			rect(img,41,41,6,5,"ded795")
			rect(img,42,38,4,6,"9ff3df")
		"wolf":
			disk(img,32,65,13,4,"102c355f")
			rect(img,20,51,20,10,"283d4a")
			rect(img,23,49,15,9,"536c76")
			rect(img,26,48,9,4,"8b9690")
			rect(img,36,45,10,13,"5c7380")
			rect(img,37,42,3,5,"3e5368")
			rect(img,43,42,3,5,"344f60")
			rect(img,42,51,8,5,"99a79c")
			rect(img,47,51,3,3,"223744")
			rect(img,41,48,2,2,"bcf6e2")
			rect(img,23,59,4,7,"354f5e")
			rect(img,36,58,4,8,"354f5e")
			rect(img,16,47,7,7,"536c76")
		"wisp":
			disk(img,32,65,9,3,"102c353f")
			disk(img,32,50,10,13,"354e71")
			disk(img,32,47,8,9,"688bad")
			disk(img,31,46,6,7,"a6d6db")
			disk(img,30,44,3,4,"e5ffe5")
			rect(img,26,60,3,5,"6685a2")
			rect(img,34,60,3,4,"6685a2")
			rect(img,27,48,2,3,"36516b")
			rect(img,34,48,2,3,"36516b")
		"shrine":
			disk(img,32,64,23,7,"15373a88")
			disk(img,32,61,22,7,"547777")
			disk(img,32,58,19,6,"8b9d89")
			disk(img,32,57,15,4,"435f65")
			rect(img,27,32,10,23,"3e626b")
			rect(img,28,31,4,23,"7c9390")
			rect(img,32,28,5,24,"597780")
			rect(img,29,37,5,3,"c6c397")
			rect(img,30,42,2,7,"8de2ca" if variant else "626b73")
			disk(img,32,27,7,7,"3d7378" if variant else "374e61")
			disk(img,31,26,4,5,"a4f3d6" if variant else "82969c")
			rect(img,16,51,4,7,"a9b9a1")
			rect(img,44,52,4,7,"a9b9a1")
		"camp":
			disk(img,32,65,22,5,"16363b66")
			disk(img,32,59,17,6,"5c7472")
			disk(img,32,57,13,4,"263b43")
			rect(img,22,54,20,3,"977250")
			rect(img,30,42,6,13,"de8553")
			rect(img,26,47,13,8,"e8ab65")
			rect(img,29,48,7,8,"f9e9a2")
		"npc":
			disk(img,32,65,9,3,"102c355f")
			rect(img,25,60,5,6,"403d42")
			rect(img,34,60,5,6,"403d42")
			rect(img,23,48,17,14,"875c50")
			rect(img,26,48,12,12,"b88261")
			rect(img,25,48,4,10,"cfb27c")
			rect(img,26,37,12,13,"39464e")
			rect(img,29,40,9,8,"e1b58b")
			rect(img,26,36,12,5,"dad8b1")
			rect(img,26,39,4,9,"b4bba1")
			rect(img,34,42,2,2,"39464e")
		"tent":
			disk(img,32,64,28,7,"15323766")
			for y in range(28,64):
				var half := int((y-26)*0.7)
				rect(img,32-half,y,half*2,1,"8b6658")
				rect(img,32,y,half,1,"b38c69")
			for y in range(42,64):
				var half := int((y-42)*0.32)
				rect(img,32-half,y,maxi(1,half*2),1,"283b43")
			rect(img,31,23,2,42,"d1ad76")
		"rock":
			disk(img,32,63,11,4,"23454777")
			disk(img,32,59,10,7,"3e595c")
			disk(img,30,57,8,5,"799187")
			rect(img,26,54,7,2,"a9b69a")
	var result := ImageTexture.create_from_image(img)
	textures[key] = result
	return result

static func sprite(kind: String, variant: int = 0) -> Sprite2D:
	var node := Sprite2D.new()
	node.texture = texture(kind,variant)
	node.offset = Vector2(0,-29)
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return node
