extends Node3D

# Procedural original coastal-city blockout for the unofficial iPad prototype.
# All map geometry is generated here; no commercial game files/assets are used.
const GRID := 30
const ROAD_WIDTH := 9.0
var rng := RandomNumberGenerator.new()
var player: CharacterBody3D
var vehicle
var status_label: Label

func _ready() -> void:
	rng.seed = 612026
	configure_inputs()
	create_environment()
	create_base()
	create_coast()
	create_roads()
	create_city_blocks()
	create_landmarks()
	spawn_player()
	spawn_vehicle()
	create_hud()

func configure_inputs() -> void:
	var actions := {"move_forward": KEY_W, "move_back": KEY_S, "move_left": KEY_A, "move_right": KEY_D, "sprint": KEY_SHIFT, "jump": KEY_SPACE, "interact": KEY_E}
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event := InputEventKey.new()
		event.keycode = actions[action]
		InputMap.action_add_event(action, event)

func create_environment() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.18,0.42,0.76)
	sky_mat.sky_horizon_color = Color(0.78,0.84,0.94)
	sky_mat.ground_bottom_color = Color(0.25,0.28,0.30)
	sky_mat.ground_horizon_color = Color(0.66,0.72,0.77)
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.7
	env.tonemap_mode = Environment.TONE_MAP_FILMIC
	env.ssr_enabled = true
	env.ssao_enabled = true
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42,-24,0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	sun.shadow_bias = 0.04
	add_child(sun)

func material(color: Color, rough := 0.8, metallic := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	m.metallic = metallic
	return m

func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, rough := 0.8) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	node.material_override = material(color, rough)
	parent.add_child(node)
	return node

func create_base() -> void:
	box(self, Vector3(0,-0.45,0), Vector3(480,0.9,480), Color(0.34,0.43,0.29))
	var ground_collision := StaticBody3D.new()
	var ground_shape := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(480,1,480)
	ground_shape.shape = shape
	ground_shape.position.y = -0.5
	ground_collision.add_child(ground_shape)
	add_child(ground_collision)

func create_coast() -> void:
	box(self, Vector3(0,-0.22,-164), Vector3(520,0.3,108), Color(0.04,0.32,0.52), 0.2)
	box(self, Vector3(0,-0.05,-111), Vector3(520,0.25,12), Color(0.88,0.75,0.52))
	box(self, Vector3(0,0.05,-100), Vector3(520,0.2,9), Color(0.49,0.48,0.43))
	# Sea-facing promenade with tiled segments and lamp posts.
	for x in range(-230,231,16):
		box(self, Vector3(x,0.12,-96), Vector3(14,0.22,5), Color(0.72,0.67,0.59))
		create_lamp(Vector3(x,0,-93), false)

func create_roads() -> void:
	for x in range(-210,211,GRID):
		box(self,Vector3(x,0,4),Vector3(ROAD_WIDTH,0.16,410),Color(0.12,0.13,0.14))
		box(self,Vector3(x-ROAD_WIDTH/2-1.2,0.04,4),Vector3(2.4,0.22,410),Color(0.62,0.59,0.53))
		box(self,Vector3(x+ROAD_WIDTH/2+1.2,0.04,4),Vector3(2.4,0.22,410),Color(0.62,0.59,0.53))
	for z in range(-210,211,GRID):
		box(self,Vector3(0,0,z),Vector3(410,0.16,ROAD_WIDTH),Color(0.12,0.13,0.14))
		box(self,Vector3(0,0.04,z-ROAD_WIDTH/2-1.2),Vector3(410,0.22,2.4),Color(0.62,0.59,0.53))
		box(self,Vector3(0,0.04,z+ROAD_WIDTH/2+1.2),Vector3(410,0.22,2.4),Color(0.62,0.59,0.53))
	# Main avenue: wider asphalt with green median and lane markers.
	box(self,Vector3(0,0.02,12),Vector3(25,0.2,420),Color(0.10,0.11,0.12))
	box(self,Vector3(0,0.18,12),Vector3(2.2,0.35,420),Color(0.32,0.40,0.28))
	for z in range(-190,211,14):
		for x in [-7.2,7.2]:
			box(self,Vector3(x,0.14,z),Vector3(0.18,0.035,5.2),Color(0.91,0.86,0.65))

func create_city_blocks() -> void:
	var palette := [Color(0.82,0.76,0.68),Color(0.82,0.84,0.83),Color(0.64,0.70,0.72),Color(0.90,0.79,0.68),Color(0.70,0.74,0.70),Color(0.74,0.68,0.60),Color(0.78,0.79,0.76)]
	for x in range(-195,196,GRID):
		for z in range(-195,100,GRID):
			if abs(x)<17 or z < -90: continue
			var height := rng.randf_range(9,23)
			if abs(x)<90 and abs(z)<90: height = rng.randf_range(24,58)
			var width := rng.randf_range(13,18)
			var depth := rng.randf_range(13,18)
			var pos := Vector3(x+rng.randf_range(-2,2),height/2,z+rng.randf_range(-2,2))
			var facade: Color = palette[rng.randi_range(0,palette.size()-1)]
			box(self,pos,Vector3(width,height,depth),facade)
			add_building_collision(pos,Vector3(width,height,depth))
			# Limited stylized window panels to keep the scene lighter on mobile GPUs.
			for floor_i in range(min(4,int(height/4))):
				for side_i in range(2):
					var window_x := pos.x-width*0.26+side_i*width*0.52
					var window_y := 2.2+floor_i*(height/5.0)
					box(self,Vector3(window_x,window_y,pos.z+depth/2+0.08),Vector3(1.8,1.35,0.12),Color(0.14,0.26,0.34),0.35)
					box(self,Vector3(window_x,window_y,pos.z-depth/2-0.08),Vector3(1.8,1.35,0.12),Color(0.14,0.26,0.34),0.35)
			box(self,Vector3(pos.x,height+0.35,pos.z),Vector3(width*0.58,0.7,depth*0.58),Color(0.38,0.40,0.40))
			if height < 18:
				box(self,Vector3(pos.x,2.6,pos.z+depth/2+0.6),Vector3(width*0.7,0.55,1.0),Color(0.9,0.33,0.23))

func add_building_collision(pos: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	var shape_node := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	shape_node.shape = shape
	shape_node.position = pos
	body.add_child(shape_node)
	add_child(body)

func create_lamp(at: Vector3, road_lamp := true) -> void:
	var height := 5.5 if road_lamp else 3.2
	var pole := CylinderMesh.new()
	pole.top_radius = 0.06
	pole.bottom_radius = 0.1
	pole.height = height
	var m := MeshInstance3D.new()
	m.mesh = pole
	m.position = at+Vector3(0,height/2,0)
	m.material_override = material(Color(0.24,0.26,0.27),0.5,0.55)
	add_child(m)
	box(self,at+Vector3(0,height,0),Vector3(0.55,0.18,0.55),Color(0.92,0.82,0.56),0.3)

func create_palm(at: Vector3) -> void:
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius=0.16
	trunk_mesh.bottom_radius=0.34
	trunk_mesh.height=6.2
	var trunk := MeshInstance3D.new()
	trunk.mesh=trunk_mesh
	trunk.position=at+Vector3(0,3.1,0)
	trunk.material_override=material(Color(0.43,0.28,0.16))
	add_child(trunk)
	for i in range(7):
		var a:=TAU*i/7.0
		var frond:=box(self,at+Vector3(cos(a)*2.4,5.9,sin(a)*2.4),Vector3(4.8,0.18,0.65),Color(0.13,0.35,0.17))
		frond.rotation.y=a
		frond.rotation.z=-0.22

func create_landmarks() -> void:
	# Beach palm row and a simple landmark tower; all are original blockout shapes.
	for x in range(-220,221,14):
		create_palm(Vector3(x,0,-106))
		create_palm(Vector3(x,0,-92))
	box(self,Vector3(-38,48,20),Vector3(24,96,22),Color(0.45,0.56,0.62),0.3)
	box(self,Vector3(-38,98,20),Vector3(14,4,14),Color(0.27,0.36,0.42),0.3)
	box(self,Vector3(38,0.4,-121),Vector3(14,1,42),Color(0.48,0.38,0.28))
	for x in [-38,-24,24,38,52,66]:
		create_palm(Vector3(x,0,-82))
	# District signage blocks, to aid orientation in test build.
	box(self,Vector3(84,2.3,-66),Vector3(7,4.6,0.7),Color(0.08,0.35,0.38))
	box(self,Vector3(-84,2.3,72),Vector3(7,4.6,0.7),Color(0.38,0.16,0.28))

func spawn_player() -> void:
	var script_player := load("res://scripts/player.gd")
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0,1.15,22)
	player.set_script(script_player)
	var shape := CapsuleShape3D.new()
	shape.radius=0.38
	shape.height=1.8
	var collision := CollisionShape3D.new()
	collision.shape=shape
	player.add_child(collision)
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius=0.38
	body_mesh.height=1.8
	var visual := MeshInstance3D.new()
	visual.mesh=body_mesh
	visual.material_override=material(Color(0.12,0.30,0.72))
	visual.name="PlayerVisual"
	player.add_child(visual)
	add_child(player)

func spawn_vehicle() -> void:
	var car_script=load("res://scripts/vehicle.gd")
	vehicle=Node3D.new()
	vehicle.name="PrototypeCar"
	vehicle.position=Vector3(3,0.45,24)
	vehicle.set_script(car_script)
	add_child(vehicle)

func create_hud() -> void:
	var layer:=CanvasLayer.new()
	layer.name="HUD"
	add_child(layer)
	var panel:=PanelContainer.new()
	panel.position=Vector2(24,22)
	panel.size=Vector2(310,94)
	layer.add_child(panel)
	var vbox:=VBoxContainer.new()
	panel.add_child(vbox)
	var title:=Label.new()
	title.text="LEONIDA  •  TEST BUILD 0.1.0"
	title.add_theme_font_size_override("font_size",18)
	vbox.add_child(title)
	status_label=Label.new()
	status_label.text="Explore  •  WASD move  •  Shift sprint"
	status_label.add_theme_font_size_override("font_size",14)
	vbox.add_child(status_label)
	var hint:=Label.new()
	hint.text="E: enter / exit vehicle   Space: jump"
	layer.add_child(hint)
	hint.position=Vector2(24,124)
	# Mobile controls are visible on touch devices and support simple virtual movement.
	if OS.has_feature("mobile"):
		create_touch_controls(layer)

func create_touch_controls(layer: CanvasLayer) -> void:
	var left_pad:=TouchScreenButton.new()
	left_pad.name="TouchMoveForward"
	left_pad.position=Vector2(90,570)
	left_pad.texture=make_touch_texture(Color(0.18,0.22,0.28,0.65))
	left_pad.action="move_forward"
	layer.add_child(left_pad)
	add_touch_label(layer,Vector2(90,570),"↑")
	var right_pad:=TouchScreenButton.new()
	right_pad.name="TouchMoveBack"
	right_pad.position=Vector2(90,650)
	right_pad.texture=make_touch_texture(Color(0.18,0.22,0.28,0.65))
	right_pad.action="move_back"
	layer.add_child(right_pad)
	add_touch_label(layer,Vector2(90,650),"↓")
	var side_pad:=TouchScreenButton.new()
	side_pad.position=Vector2(18,610)
	side_pad.texture=make_touch_texture(Color(0.18,0.22,0.28,0.65))
	side_pad.action="move_left"
	layer.add_child(side_pad)
	add_touch_label(layer,Vector2(18,610),"←")
	var side_pad2:=TouchScreenButton.new()
	side_pad2.position=Vector2(162,610)
	side_pad2.texture=make_touch_texture(Color(0.18,0.22,0.28,0.65))
	side_pad2.action="move_right"
	layer.add_child(side_pad2)
	add_touch_label(layer,Vector2(162,610),"→")
	var sprint_button:=TouchScreenButton.new()
	sprint_button.position=Vector2(1040,570)
	sprint_button.texture=make_touch_texture(Color(0.12,0.34,0.22,0.65))
	sprint_button.action="sprint"
	layer.add_child(sprint_button)
	add_touch_label(layer,Vector2(1040,570),"RUN")
	var jump_button:=TouchScreenButton.new()
	jump_button.position=Vector2(1150,620)
	jump_button.texture=make_touch_texture(Color(0.3,0.25,0.13,0.65))
	jump_button.action="jump"
	layer.add_child(jump_button)
	add_touch_label(layer,Vector2(1150,620),"JUMP")
	var interact_button:=TouchScreenButton.new()
	interact_button.position=Vector2(1150,520)
	interact_button.texture=make_touch_texture(Color(0.28,0.18,0.34,0.65))
	interact_button.action="interact"
	layer.add_child(interact_button)
	add_touch_label(layer,Vector2(1150,520),"E")

func add_touch_label(layer: CanvasLayer, at: Vector2, label_text: String) -> void:
	var label:=Label.new()
	label.text=label_text
	label.position=at+Vector2(0,34)
	label.size=Vector2(96,28)
	label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",18)
	label.add_theme_color_override("font_color",Color(1,1,1,0.9))
	layer.add_child(label)

func make_touch_texture(color: Color) -> Texture2D:
	var image:=Image.create(96,96,false,Image.FORMAT_RGBA8)
	image.fill(Color(0,0,0,0))
	for y in range(96):
		for x in range(96):
			if Vector2(x-48,y-48).length()<46:
				image.set_pixel(x,y,color)
	return ImageTexture.create_from_image(image)

func _process(_delta: float) -> void:
	if player and vehicle:
		var near_car:=player.global_position.distance_to(vehicle.global_position)<5.0
		if near_car and status_label:
			status_label.text="E: enter vehicle  •  WASD drive"
		elif status_label and not vehicle.get("occupied"):
			status_label.text="Explore  •  WASD move  •  Shift sprint"
		if Input.is_action_just_pressed("interact"):
			if vehicle.has_method("toggle_occupancy") and near_car:
				vehicle.toggle_occupancy(player)
				if vehicle.occupied:
					status_label.text="Driving  •  E exit  •  WASD steer"
				else:
					status_label.text="Explore  •  WASD move  •  Shift sprint"
