class_name PixelArt
extends RefCounted
## Original pixel assets, rasterized once and cached. Feet are the sorting origin.

static var textures: Dictionary = {}
static var images: Dictionary = {}

static func rect(img: Image, x: int, y: int, w: int, h: int, color: String) -> void:
	img.fill_rect(Rect2i(x,y,w,h), Color(color))

static func disk(img: Image, x: int, y: int, rx: int, ry: int, color: String) -> void:
	for py in range(maxi(0,y-ry), mini(img.get_height(),y+ry+1)):
		for px in range(maxi(0,x-rx), mini(img.get_width(),x+rx+1)):
			if pow(float(px-x)/maxi(1,rx),2)+pow(float(py-y)/maxi(1,ry),2) <= 1:
				img.set_pixel(px,py,Color(color))

static func line(img: Image, a: Vector2i, b: Vector2i, color: String, width: int = 1) -> void:
	var steps := maxi(absi(a.x-b.x),absi(a.y-b.y))
	for i in range(steps+1):
		var p := Vector2(a).lerp(Vector2(b),float(i)/maxi(1,steps))
		rect(img,roundi(p.x),roundi(p.y),width,width,color)

static func poly(img: Image, coords: Array, color: String) -> void:
	var points := PackedVector2Array()
	for pair in coords:
		points.append(Vector2(pair[0],pair[1]))
	var bounds := Rect2(points[0],Vector2.ZERO)
	for point in points:
		bounds = bounds.expand(point)
	for y in range(maxi(0,int(bounds.position.y)),mini(img.get_height(),int(bounds.end.y)+1)):
		for x in range(maxi(0,int(bounds.position.x)),mini(img.get_width(),int(bounds.end.x)+1)):
			if Geometry2D.is_point_in_polygon(Vector2(x,y),points):
				img.set_pixel(x,y,Color(color))

static func foliage(img: Image, c: Vector2i, w: int, h: int, palette: Array, rng: RandomNumberGenerator) -> void:
	# Angular overlapping masses and broken leaf edges, lit from the upper left.
	var points: Array = []
	for i in 16:
		var angle := i*TAU/16
		var scale_leaf := rng.randf_range(0.80,1.10)
		points.append([c.x+int(cos(angle)*w*scale_leaf),c.y+int(sin(angle)*h*scale_leaf)])
	poly(img,points,palette[0])
	for shift in [[-1,-3,0.91,1],[-3,-6,0.70,2],[-5,-8,0.43,3]]:
		var inset: Array = []
		for point in points:
			inset.append([c.x+int((point[0]-c.x)*shift[2])+shift[0],c.y+int((point[1]-c.y)*shift[2])+shift[1]])
		poly(img,inset,palette[shift[3]])
	for i in 26:
		var px := c.x+rng.randi_range(-w+3,w-3)
		var py := c.y+rng.randi_range(-h+1,h-2)
		if px<1 or py<1 or px>=img.get_width()-4 or py>=img.get_height()-2:
			continue
		if img.get_pixel(px,py).a>0.9 and Vector2(float(px-c.x)/w,float(py-c.y)/h).length()<0.94:
			var shade: String = palette[4] if py<c.y-3 else palette[2]
			rect(img,px,py,3,1,shade)
			rect(img,px+1,py-1,2,1,shade)

static func tree(img: Image, variant: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 98713+variant*913
	var palette := ["193b38","285541","427855","689766","9eb779"]
	if variant%9 == 1:
		palette = ["583d3c","835442","b87848","dca55f","f2d48a"]
	elif variant%9 == 2:
		palette = ["183e43","235b58","3c7c70","6ba38b","aecdb1"]
	elif variant%9 == 3:
		palette = ["29463a","44644b","6b8754","99a963","c8ce8a"]
	var lean := rng.randi_range(-4,4)
	poly(img,[[43,103],[45,65],[51+lean,55],[53,100],[62,105],[48,103],[38,106]],"383c31")
	poly(img,[[45,101],[48,61],[51+lean,58],[50,98],[55,103]],"786048")
	line(img,Vector2i(47,90),Vector2i(49+lean,60),"ae8860",2)
	line(img,Vector2i(47,78),Vector2i(32,63),"655140",3)
	line(img,Vector2i(49,75),Vector2i(64,54),"574b3c",3)
	if variant%8 == 7:
		# Broken elder trunk and new growth open the forest silhouette.
		poly(img,[[40,103],[40,76],[46,73],[54,75],[58,102]],"574d3c")
		poly(img,[[41,77],[45,74],[51,75],[54,80],[45,81]],"ba9a6d")
		rect(img,44,83,2,17,"a18151")
		foliage(img,Vector2i(34,86),13,9,palette,rng)
		foliage(img,Vector2i(59,82),12,10,palette,rng)
	elif variant%4 == 0:
		# Slender fir: irregular shelves, visible trunk between the lower boughs.
		for j in 5:
			var y := 74-j*13
			var w := 26-j*4
			poly(img,[[48,y-28],[48-w,y+2],[42,y-1],[39,y+6],[52,y+3],[58,y+7],[48+w,y]],palette[0])
			poly(img,[[47,y-26],[50-w,y-1],[42,y-3],[42,y+1],[57,y-3],[60,y+1],[64,y-2]],palette[2])
			line(img,Vector2i(46,y-20),Vector2i(48-w+6,y-3),palette[3],2)
			for k in 5:
				var x := 48+rng.randi_range(-w+5,w-5)
				rect(img,x,y+rng.randi_range(-5,1),3,1,palette[1])
	else:
		var clusters := [[32,64,21,15],[64,60,20,17],[47,48,26,20],[29,44,17,17],[65,40,19,17],[46,28,22,17],[48,15,12,10]]
		if variant%8 == 6:
			clusters = [[38,72,13,10],[56,65,14,12],[43,50,15,14],[51,36,11,11]]
		elif variant%4 == 2:
			clusters = [[38,65,17,13],[59,56,15,18],[35,42,18,21],[55,32,19,19],[43,18,14,13]]
			line(img,Vector2i(47,99),Vector2i(49,57),"b9b69a",3)
			for y in [76,87,94]:
				rect(img,48,y,3,2,"4d5549")
		for c in clusters:
			foliage(img,Vector2i(c[0]+rng.randi_range(-3,3),c[1]+rng.randi_range(-2,2)),c[2],c[3],palette,rng)
	# Moss and a pair of roots tie the trunk to the ground.
	line(img,Vector2i(44,99),Vector2i(36,105),"526744",2)
	rect(img,51,101,8,2,"7d8b50")
	rect(img,42,98,2,5,"8b985f")

static func texture(kind: String, variant: int = 0) -> Texture2D:
	var key := kind+str(variant)
	if textures.has(key):
		return textures[key]
	var img := Image.create(96 if kind=="tree" else 64,112 if kind=="tree" else 72,false,Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	match kind:
		"tree": tree(img,variant)
		"mage":
			var step: int = [0,2,0,-2][variant%4]
			var back := variant>=4
			disk(img,32,65,10,3,"102a355a")
			poly(img,[[24,45],[36,45],[42,61],[38,64],[27,62],[20,64],[22,54]],"283552")
			poly(img,[[24,46],[33,47],[38,61],[27,60],[22,62]],"625781")
			poly(img,[[25,47],[29,48],[29,60],[23,61]],"9e82aa")
			rect(img,25,61-step,4,5,"253643")
			rect(img,34,61+step,4,5,"253643")
			rect(img,25,64-step,5,2,"907961")
			rect(img,34,64+step,5,2,"907961")
			poly(img,[[28,48],[36,47],[37,59],[27,59]],"8981a5")
			rect(img,28,58,9,2,"d8b979")
			rect(img,33,57,2,3,"fbdfa0")
			rect(img,35,52,5,4,"b497b7")
			rect(img,39,53,3,3,"e4b98f")
			rect(img,28,39,9,10,"c49077" if not back else "59547c")
			rect(img,29,40,9,6,"ecc49e" if not back else "7a6a91")
			if not back:
				rect(img,35,42,2,2,"293c4c")
				rect(img,30,47,6,2,"dfcaaa")
			poly(img,[[18,38],[24,35],[28,24],[32,21],[37,25],[37,33],[43,38],[40,41],[23,41]],"2c3555")
			poly(img,[[21,37],[27,35],[30,24],[33,24],[35,34],[40,37],[37,39],[24,39]],"766794")
			poly(img,[[27,34],[30,26],[33,24],[33,32],[35,35]],"ac91b8")
			rect(img,26,35,12,2,"dec28a")
			rect(img,32,34,3,3,"fff0be")
			line(img,Vector2i(42,62),Vector2i(44,40),"514d43",3)
			line(img,Vector2i(43,61),Vector2i(45,40),"b49668")
			poly(img,[[43,43],[40,38],[43,32],[47,33],[49,38],[46,44]],"526a75")
			poly(img,[[42,38],[45,33],[47,37],[45,42]],"8cdecf")
			line(img,Vector2i(44,36),Vector2i(44,40),"e1ffe1")
		"wolf":
			var step: int = [0,2,0,-2][variant%4]
			disk(img,32,65,15,4,"102c3555")
			poly(img,[[22,54],[15,52],[10,44],[16,45],[22,49],[33,47],[40,43],[44,49],[44,59],[36,61],[23,61]],"2b3c48")
			poly(img,[[20,52],[26,48],[36,48],[42,52],[38,58],[24,58]],"536c78")
			poly(img,[[24,50],[30,46],[34,49],[39,48],[37,52],[28,53]],"8295a0")
			poly(img,[[34,49],[35,38],[40,42],[44,39],[47,48],[51,51],[51,55],[42,57],[38,53]],"566b81")
			poly(img,[[38,44],[41,45],[43,42],[46,50],[49,52],[43,54],[40,50]],"9baeb4")
			rect(img,47,51,5,3,"203745")
			rect(img,43,46,2,2,"d2f7de")
			rect(img,37,40,1,4,"c39aa3")
			for leg in [[23,step],[29,-step],[36,-step],[41,step]]:
				rect(img,leg[0],57,3,8+leg[1],"3b5365")
				rect(img,leg[0],63+leg[1],5,2,"91a3a7")
		"wisp":
			disk(img,32,64,8,2,"163c4535")
			poly(img,[[32,27],[38,40],[42,45],[39,54],[36,57],[38,63],[31,59],[27,61],[26,55],[23,50],[26,41]],"354e76")
			poly(img,[[32,32],[34,42],[39,46],[37,53],[32,57],[28,54],[26,48],[30,41]],"618dba")
			poly(img,[[32,38],[35,44],[37,48],[34,54],[29,51],[29,45]],"a6dce2")
			poly(img,[[32,41],[34,46],[33,51],[30,48]],"e6ffe6")
			rect(img,28,48,2,2,"3d5c80")
			rect(img,35,48,2,2,"3d5c80")
		"shrine":
			disk(img,32,65,24,6,"173d3c55")
			poly(img,[[10,58],[18,52],[43,52],[54,58],[53,64],[40,69],[22,67],[10,63]],"3e5b5e")
			poly(img,[[11,57],[23,50],[42,51],[52,57],[43,63],[22,63]],"8b9b89")
			poly(img,[[17,56],[25,52],[39,53],[47,57],[39,60],[24,60]],"5d7875")
			poly(img,[[23,54],[25,35],[22,29],[25,21],[36,19],[41,29],[38,36],[40,56],[31,59]],"324e5b")
			poly(img,[[25,54],[28,34],[25,28],[27,23],[32,21],[32,57]],"8a9f9b")
			poly(img,[[33,21],[38,26],[37,34],[35,36],[38,54],[33,55]],"506b75")
			line(img,Vector2i(29,39),Vector2i(27,51),"c7c5a1")
			var rune := "b6ffe0" if variant else "769eaa"
			poly(img,[[31,37],[34,41],[31,47],[28,43]],rune)
			poly(img,[[32,9],[38,17],[34,26],[28,24],[26,18]],"3a637c")
			poly(img,[[31,11],[34,17],[31,24],[28,18]],"ceffe1" if variant else "7bb4bc")
			poly(img,[[34,16],[37,17],[34,24],[32,25]],"69cfbc" if variant else "567988")
			for pair in [[16,56],[43,58],[21,64]]:
				rect(img,pair[0],pair[1],5,2,"7a9d66")
		"camp":
			disk(img,32,65,23,5,"16363b55")
			disk(img,32,60,18,6,"455552")
			disk(img,32,58,15,4,"232f35")
			for pair in [[18,58],[23,54],[33,53],[43,57],[41,63],[29,64],[21,62]]:
				disk(img,pair[0],pair[1],4,2,"879089")
				rect(img,pair[0]-2,pair[1]-1,3,1,"b3b5a0")
			line(img,Vector2i(23,61),Vector2i(39,56),"966048",3)
			line(img,Vector2i(26,56),Vector2i(40,61),"bc8352",2)
			var flicker := variant%3*2
			poly(img,[[23,55],[25,45],[28,48],[33,32+flicker],[36,44],[40,42+flicker],[42,52],[38,58],[28,59]],"c96045")
			poly(img,[[26,54],[29,45],[31,49],[34,39+flicker],[35,47],[38,49],[38,56],[32,59]],"efa756")
			poly(img,[[30,55],[32,48],[34,52],[36,50],[36,57],[32,58]],"fff0b1")
		"npc":
			disk(img,32,65,10,3,"102c3555")
			rect(img,26,59,4,7,"3a4141")
			rect(img,34,59,4,7,"3a4141")
			poly(img,[[25,45],[36,45],[42,61],[23,62],[22,54]],"645247")
			poly(img,[[25,47],[35,47],[38,59],[25,59]],"ae7956")
			poly(img,[[24,45],[27,44],[30,55],[25,58],[22,54]],"c7b37a")
			rect(img,26,57,12,2,"e1c78c")
			rect(img,28,37,9,10,"d8a583")
			rect(img,30,38,8,7,"efc7a1")
			poly(img,[[24,40],[25,32],[31,29],[37,33],[38,38],[29,36],[27,45]],"889788")
			poly(img,[[25,36],[29,31],[33,31],[36,35],[28,35],[27,41]],"e6dfbd")
			rect(img,24,41,4,9,"b8c2a5")
			rect(img,24,49,3,4,"d0be8a")
			rect(img,35,40,2,2,"34444a")
			rect(img,39,49,3,11,"665341")
			rect(img,38,48,6,4,"dbc294")
		"tent":
			disk(img,32,65,29,6,"19363350")
			poly(img,[[4,61],[28,26],[41,31],[61,61],[44,66],[20,64]],"554a43")
			poly(img,[[7,60],[29,28],[37,34],[44,63],[19,61]],"608777" if variant else "99734e")
			poly(img,[[30,28],[40,32],[58,60],[44,63]],"97b499" if variant else "dbba80")
			line(img,Vector2i(29,31),Vector2i(43,62),"d1c997",2)
			poly(img,[[28,43],[21,62],[38,63],[33,45]],"2a3d43")
			poly(img,[[29,44],[25,59],[28,59],[31,46]],"b39466")
			line(img,Vector2i(29,22),Vector2i(29,40),"e4c992",2)
			line(img,Vector2i(28,27),Vector2i(3,63),"e0c99c")
			line(img,Vector2i(40,32),Vector2i(62,63),"c3b282")
			rect(img,1,61,2,6,"6d5842")
			rect(img,61,61,2,6,"6d5842")
			poly(img,[[31,23],[31,30],[40,25]],"86b5a4" if variant else "d0a56a")
		"rock":
			disk(img,32,65,12,3,"203b3d50")
			poly(img,[[20,62],[22,55],[28,49],[38,51],[44,59],[42,65],[29,67]],"3f565e")
			poly(img,[[21,59],[26,52],[29,50],[37,52],[39,58],[30,61]],"83958c")
			poly(img,[[22,56],[28,51],[34,52],[30,56]],"b8bca0")
			poly(img,[[29,61],[37,57],[42,61],[40,64],[31,64]],"596e6b")
			rect(img,23,63,8,2,"779163")
		"fern":
			for j in 7:
				var end := Vector2i(18+j*5,52+absi(j-3)*2)
				line(img,Vector2i(32,65),end,"5c975f")
				for k in range(1,5):
					var tip := Vector2i(Vector2(32,65).lerp(Vector2(end),k/5.0))
					line(img,tip,tip+Vector2i(-3,-1),"93b776" if j<4 else "488561")
					line(img,tip,tip+Vector2i(3,-3),"79ad70")
		"flowers":
			for i in 5:
				var x := 22+i*5
				var y := 56+(i*7+variant)%6
				line(img,Vector2i(x+1,66),Vector2i(x,y),"679768")
				rect(img,x-2,y,5,2,"b3a4d7" if variant%3==0 else "e4c181" if variant%3==1 else "d9e3b5")
				rect(img,x,y-2,2,5,"ddc6ec" if variant%3==0 else "f5db96" if variant%3==1 else "f3f3d5")
				rect(img,x,y,1,1,"fff5c4")
		"mushrooms":
			for c in [[25,60,4],[35,56,5],[40,64,3]]:
				rect(img,c[0],c[1],2,6,"bfba90")
				disk(img,c[0],c[1],c[2],3,"ac685b" if variant%2 else "539c9b")
				rect(img,c[0]-2,c[1]-2,3,1,"f0bb9b" if variant%2 else "b1e6ce")
		"lantern":
			disk(img,32,65,9,2,"213d4055")
			rect(img,28,30,3,35,"635240")
			rect(img,29,30,1,33,"ae8b5e")
			rect(img,28,28,15,3,"b08b5e")
			rect(img,39,30,1,7,"3b4b48")
			poly(img,[[35,39],[38,35],[42,35],[45,39],[44,50],[36,50]],"455456")
			rect(img,37,40,6,8,"d7934b")
			rect(img,38,40,3,7,"ffdf95")
			rect(img,36,49,8,2,"a58354")
		"supplies":
			disk(img,32,65,20,4,"173b3c55")
			poly(img,[[17,50],[29,46],[41,50],[41,64],[28,67],[17,62]],"645442")
			poly(img,[[18,50],[29,47],[40,50],[29,54]],"bc9e6c")
			poly(img,[[18,52],[28,56],[28,65],[18,61]],"9f7e54")
			for y in [54,59,63]:
				line(img,Vector2i(30,y),Vector2i(40,y-3),"b39764")
			line(img,Vector2i(19,53),Vector2i(27,62),"d1b07a",2)
			disk(img,43,57,7,7,"717968")
			disk(img,42,55,5,6,"acb392")
			rect(img,41,48,3,3,"d4cd9c")
		"rug":
			poly(img,[[9,54],[40,49],[55,61],[23,68]],"4c5555")
			poly(img,[[12,54],[39,51],[51,61],[24,65]],"8b6468")
			poly(img,[[19,55],[37,53],[44,60],[25,63]],"d7b087")
			poly(img,[[25,56],[35,55],[39,59],[28,61]],"596e71")
	var result := ImageTexture.create_from_image(img)
	textures[key] = result
	images[key] = img
	return result

static func sprite(kind: String, variant: int = 0) -> Sprite2D:
	var node := Sprite2D.new()
	node.texture = texture(kind,variant)
	node.offset = Vector2(0,-49 if kind=="tree" else -29)
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return node

static func glow() -> Texture2D:
	if textures.has("glow"):
		return textures.glow
	var img := Image.create(128,128,false,Image.FORMAT_RGBA8)
	for y in 128:
		for x in 128:
			var d := Vector2(x-64,y-64).length()/64.0
			var value := pow(maxf(0,1-d),2.4)
			img.set_pixel(x,y,Color(value,value,value,1))
	textures.glow = ImageTexture.create_from_image(img)
	return textures.glow
