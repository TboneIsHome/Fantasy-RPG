class_name DungeonArt
extends RefCounted
## Original, code-defined art for the buried observatory.
static var cache: Dictionary = {}

static func texture(kind: String, active: bool = false) -> Texture2D:
	var key := kind+str(active)
	if cache.has(key):
		return cache[key]
	var img := Image.create(64,72,false,Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	match kind:
		"entrance","exit":
			PixelArt.disk(img,32,64,29,7,"142e3990")
			PixelArt.poly(img,[[5,64],[6,30],[12,15],[23,8],[41,8],[53,16],[58,31],[60,64]],"354d5c")
			PixelArt.poly(img,[[13,63],[14,29],[22,19],[40,18],[48,29],[49,63]],"102733")
			for y in [28,37,46,55]:
				PixelArt.rect(img,6,y,8,7,"7b8c89")
				PixelArt.rect(img,49,y,8,7,"526f76")
				PixelArt.rect(img,7,y,6,1,"b1b7a1")
			for i in 5:
				PixelArt.rect(img,17-i,42+i*4,28+i*2,3,"4c6b70" if kind=="entrance" else "729d96")
				PixelArt.rect(img,17-i,42+i*4,28+i*2,1,"96b4a2")
			PixelArt.poly(img,[[11,26],[15,16],[25,11],[32,9],[39,11],[50,18],[53,26],[46,24],[41,18],[26,18],[18,25]],"93a191")
			PixelArt.poly(img,[[32,10],[36,15],[32,22],[28,16]],"b7e2c4")
			PixelArt.line(img,Vector2i(10,8),Vector2i(17,36),"64583f",3)
			PixelArt.line(img,Vector2i(53,7),Vector2i(47,32),"74754b",3)
			PixelArt.line(img,Vector2i(47,32),Vector2i(55,58),"727d4b",2)
			for p in [[12,25],[49,35],[55,56],[7,60]]:
				PixelArt.disk(img,p[0],p[1],5,2,"849c62")
		"chest":
			PixelArt.disk(img,32,65,19,4,"10293677")
			PixelArt.poly(img,[[16,50],[32,45],[49,50],[48,64],[32,68],[16,63]],"394e58")
			PixelArt.poly(img,[[17,50],[32,46],[47,50],[32,56]],"b9985e")
			PixelArt.poly(img,[[18,53],[31,57],[31,65],[18,61]],"927953")
			PixelArt.poly(img,[[33,57],[47,53],[46,63],[33,66]],"665e50")
			PixelArt.line(img,Vector2i(20,51),Vector2i(20,62),"ddc282",2)
			PixelArt.line(img,Vector2i(43,52),Vector2i(43,63),"bda573",2)
			PixelArt.rect(img,30,57,5,5,"e4cd90")
			if active:
				PixelArt.poly(img,[[16,49],[18,37],[33,32],[48,37],[49,49],[33,53]],"746944")
				PixelArt.poly(img,[[20,46],[21,39],[33,36],[44,40],[46,47],[32,50]],"283c48")
				PixelArt.line(img,Vector2i(17,49),Vector2i(31,54),"ebcc8a")
		"memory":
			PixelArt.disk(img,32,65,18,4,"152f3770")
			PixelArt.poly(img,[[19,61],[21,32],[27,24],[41,25],[46,34],[44,62],[32,67]],"344e60")
			PixelArt.poly(img,[[22,60],[24,34],[28,28],[37,28],[40,37],[39,61],[30,64]],"799494")
			PixelArt.line(img,Vector2i(25,33),Vector2i(27,28),"c2c9a6",2)
			var ink := "caf5ce" if active else "98c5be"
			for y in [39,46,53]:
				PixelArt.line(img,Vector2i(28,y),Vector2i(33,y-3),ink)
				PixelArt.line(img,Vector2i(33,y-3),Vector2i(36,y+1),ink)
			PixelArt.rect(img,21,59,7,3,"637d50")
		"font":
			PixelArt.disk(img,32,64,23,6,"1b344380")
			PixelArt.disk(img,32,60,22,8,"4c6874")
			PixelArt.disk(img,32,57,20,6,"9ba997")
			PixelArt.disk(img,32,56,16,4,"407b8c")
			PixelArt.disk(img,30,56,11,2,"83bbbd")
			PixelArt.rect(img,23,56,9,1,"cff3d7")
			PixelArt.poly(img,[[28,49],[29,31],[34,28],[39,33],[37,49]],"617e87")
			PixelArt.rect(img,30,35,2,14,"acd9c5")
		"lever":
			PixelArt.disk(img,32,65,16,4,"19313c80")
			PixelArt.poly(img,[[20,61],[23,52],[39,51],[46,61],[34,66]],"6a8382")
			PixelArt.line(img,Vector2i(30,58),Vector2i(42 if active else 22,40),"b39466",4)
			PixelArt.disk(img,42 if active else 22,40,5,4,"84bca9" if active else "e0bc73")
		"gate":
			for x in [8,54]:
				PixelArt.rect(img,x,23,5,43,"587780")
				PixelArt.rect(img,x,23,2,40,"a5b7a6")
			if not active:
				for x in range(15,53,7):
					PixelArt.rect(img,x,30,2,34,"9b9471")
				for y in [33,50]:
					PixelArt.rect(img,12,y,43,3,"726a50")
				PixelArt.line(img,Vector2i(12,60),Vector2i(46,35),"7e874d",3)
			PixelArt.rect(img,7,24,52,5,"80938a")
		"roots":
			for x in [17,30,43]:
				PixelArt.line(img,Vector2i(x,0),Vector2i(x-5,26),"3e5040",5)
				PixelArt.line(img,Vector2i(x-5,26),Vector2i(x+4,48),"786d48",4)
				PixelArt.line(img,Vector2i(x+4,48),Vector2i(x-8,66),"6d7147",3)
				PixelArt.line(img,Vector2i(x,2),Vector2i(x-4,25),"a49761")
			for p in [[16,23],[38,36],[28,50],[18,60],[48,20]]:
				PixelArt.disk(img,p[0],p[1],6,3,"5f8c68")
				PixelArt.rect(img,p[0]-3,p[1]-2,4,1,"acc189")
		"banner":
			PixelArt.line(img,Vector2i(15,17),Vector2i(49,17),"c0a772",2)
			PixelArt.poly(img,[[19,19],[46,19],[45,57],[32,66],[20,58]],"304b65")
			PixelArt.line(img,Vector2i(21,20),Vector2i(22,56),"ceaf72")
			PixelArt.line(img,Vector2i(43,20),Vector2i(42,56),"bda671")
			PixelArt.poly(img,[[32,29],[35,36],[42,39],[35,42],[32,51],[29,42],[23,39],[29,36]],"d6c18a")
			PixelArt.poly(img,[[32,35],[35,39],[32,45],[29,39]],"638f95")
		"pillar":
			PixelArt.disk(img,32,65,14,4,"10263666")
			PixelArt.poly(img,[[22,62],[24,26],[22,21],[24,16],[41,16],[43,22],[39,27],[41,63],[32,66]],"3c5968")
			PixelArt.rect(img,26,23,5,37,"8ca39e")
			PixelArt.rect(img,33,25,4,36,"62848b")
			PixelArt.rect(img,23,19,19,3,"aec0a6")
			PixelArt.rect(img,22,60,20,3,"869e93")
		"shelf":
			PixelArt.poly(img,[[12,62],[12,27],[45,23],[51,28],[51,62],[21,68]],"3b4547")
			for y in [29,42,55]:
				PixelArt.rect(img,16,y,31,3,"ad926a")
				for i in 7:
					PixelArt.rect(img,17+i*4,y+3,3,8,"799587" if i%3==0 else "bba87b" if i%3==1 else "7d737a")
			PixelArt.rect(img,13,28,3,36,"c0a277")
		"crystal":
			PixelArt.disk(img,32,65,13,3,"19374466")
			for p in [[23,49,60],[33,34,66],[41,53,63]]:
				PixelArt.poly(img,[[p[0],p[1]],[p[0]+5,p[1]+7],[p[0]+3,p[2]],[p[0]-3,p[2]-2],[p[0]-4,p[1]+9]],"387c8b")
				PixelArt.poly(img,[[p[0],p[1]+2],[p[0]+1,p[2]-1],[p[0]-3,p[2]-3],[p[0]-3,p[1]+9]],"9bdac7")
		"kobold":
			PixelArt.disk(img,32,65,12,3,"112b3555")
			PixelArt.rect(img,23,58,4,8,"655440")
			PixelArt.rect(img,35,58,4,8,"655440")
			PixelArt.poly(img,[[22,47],[36,44],[42,59],[31,64],[20,59]],"35584c")
			PixelArt.poly(img,[[24,47],[33,47],[37,59],[28,60]],"7c9156")
			PixelArt.poly(img,[[22,37],[14,34],[20,43],[23,45],[37,45],[43,38],[49,33],[39,35],[34,30],[25,31]],"6f9a74")
			PixelArt.poly(img,[[23,36],[28,32],[35,33],[38,41],[34,46],[25,44]],"a8b884")
			PixelArt.rect(img,27,38,2,2,"f4d09a")
			PixelArt.rect(img,35,38,2,2,"f4d09a")
			PixelArt.poly(img,[[22,34],[26,23],[29,29],[35,22],[38,33]],"666e46")
			PixelArt.line(img,Vector2i(44,64),Vector2i(46,38),"ac8559",2)
			PixelArt.line(img,Vector2i(45,41),Vector2i(39,33),"7a8a53",2)
			PixelArt.line(img,Vector2i(46,43),Vector2i(52,35),"8c9c5b",2)
			PixelArt.disk(img,46,37,3,4,"b8d28e")
	cache[key]=ImageTexture.create_from_image(img)
	return cache[key]

static func sprite(kind: String, active: bool = false) -> Sprite2D:
	var node := Sprite2D.new()
	node.texture=texture(kind,active)
	node.offset=Vector2(0,-29)
	node.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	return node
