extends Node3D

# Procedural original coastal-city blockout for the unofficial iPad prototype.
# All map geometry is generated here; no commercial game files/assets are used.
const GRID := 30
const ROAD_WIDTH := 9.0
var rng := RandomNumberGenerator.new()
var player: CharacterBody3D
var vehicle
var status_label: Label
var environment_ref: Environment
var sun_ref: DirectionalLight3D
var night_mode := false
var rain_mode := false

func _ready() -> void:
	rng.seed = 612026
	configure_inputs()
	create_environment()
	create_base()
	create_coast()
	create_roads()
	create_city_blocks()
	create_landmarks()
	create_road_details()
	create_district_props()
	spawn_ambient_traffic()
	spawn_pedestrians()
	spawn_player()
	spawn_vehicle()
	create_hud()

func configure_inputs() -> void:
	var actions := {"move_forward": KEY_W, "move_back": KEY_S, "move_left": KEY_A, "move_right": KEY_D, "sprint": KEY_SHIFT, "jump": KEY_SPACE, "interact": KEY_E, "toggle_night": KEY_N, "toggle_weather": KEY_V}
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
	environment_ref = env
	env.ssr_enabled = true
	env.ssao_enabled = true
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42,-24,0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	sun.shadow_bias = 0.04
	sun_ref = sun
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
	left_pad.texture_normal=make_touch_texture(Color(0.18,0.22,0.28,0.65))
	left_pad.action="move_forward"
	layer.add_child(left_pad)
	add_touch_label(layer,Vector2(90,570),"↑")
	var right_pad:=TouchScreenButton.new()
	right_pad.name="TouchMoveBack"
	right_pad.position=Vector2(90,650)
	right_pad.texture_normal=make_touch_texture(Color(0.18,0.22,0.28,0.65))
	right_pad.action="move_back"
	layer.add_child(right_pad)
	add_touch_label(layer,Vector2(90,650),"↓")
	var side_pad:=TouchScreenButton.new()
	side_pad.position=Vector2(18,610)
	side_pad.texture_normal=make_touch_texture(Color(0.18,0.22,0.28,0.65))
	side_pad.action="move_left"
	layer.add_child(side_pad)
	add_touch_label(layer,Vector2(18,610),"←")
	var side_pad2:=TouchScreenButton.new()
	side_pad2.position=Vector2(162,610)
	side_pad2.texture_normal=make_touch_texture(Color(0.18,0.22,0.28,0.65))
	side_pad2.action="move_right"
	layer.add_child(side_pad2)
	add_touch_label(layer,Vector2(162,610),"→")
	var sprint_button:=TouchScreenButton.new()
	sprint_button.position=Vector2(1040,570)
	sprint_button.texture_normal=make_touch_texture(Color(0.12,0.34,0.22,0.65))
	sprint_button.action="sprint"
	layer.add_child(sprint_button)
	add_touch_label(layer,Vector2(1040,570),"RUN")
	var jump_button:=TouchScreenButton.new()
	jump_button.position=Vector2(1150,620)
	jump_button.texture_normal=make_touch_texture(Color(0.3,0.25,0.13,0.65))
	jump_button.action="jump"
	layer.add_child(jump_button)
	add_touch_label(layer,Vector2(1150,620),"JUMP")
	var interact_button:=TouchScreenButton.new()
	interact_button.position=Vector2(1150,520)
	interact_button.texture_normal=make_touch_texture(Color(0.28,0.18,0.34,0.65))
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
	if Input.is_action_just_pressed("toggle_night"):
		toggle_night()
	if Input.is_action_just_pressed("toggle_weather"):
		toggle_weather()
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

func create_road_details() -> void:
	# Crosswalks and small street props at selected intersections.
	for z in [-120,-60,0,60,120]:
		for stripe in range(7):
			box(self,Vector3(-15+stripe*4.5,0.15,z),Vector3(2.5,0.04,0.7),Color(0.88,0.87,0.82))
	for x in [-90,-60,60,90]:
		for z in [-45,45,105]:
			create_lamp(Vector3(x,0,z),true)
	# Small landscaped planters along the waterfront.
	for x in range(-200,201,32):
		box(self,Vector3(x,0.35,-88),Vector3(4,0.7,2.5),Color(0.45,0.33,0.23))
		box(self,Vector3(x,1.15,-88),Vector3(2.6,1.4,1.5),Color(0.12,0.38,0.19))

func spawn_ambient_traffic() -> void:
	var script_car=load("res://scripts/traffic_car.gd")
	for lane_x in [-5.5,5.5]:
		for start_z in [-120,-40,55,145]:
			var car:=Node3D.new()
			car.set_script(script_car)
			car.route=[Vector3(lane_x,0,start_z),Vector3(lane_x,0,start_z+45),Vector3(lane_x,0,start_z+90),Vector3(lane_x,0,start_z+135)]
			car.cruise_speed=rng.randf_range(4.0,7.0)
			add_child(car)

func spawn_pedestrians() -> void:
	var script_npc=load("res://scripts/pedestrian.gd")
	for x in [-72,-36,36,72,108]:
		var npc:=Node3D.new()
		npc.set_script(script_npc)
		npc.patrol_points=[Vector3(x,0,-91),Vector3(x+10,0,-91),Vector3(x+10,0,-86),Vector3(x,0,-86)]
		npc.stroll_speed=rng.randf_range(0.7,1.25)
		add_child(npc)

func toggle_night() -> void:
	night_mode=not night_mode
	if sun_ref:
		sun_ref.light_energy=0.18 if night_mode else 1.15
		sun_ref.rotation_degrees=Vector3(-8,-24,0) if night_mode else Vector3(-42,-24,0)
	if environment_ref:
		environment_ref.ambient_light_energy=0.28 if night_mode else 0.7
		environment_ref.background_color=Color(0.025,0.035,0.09) if night_mode else Color(0.45,0.7,0.9)
		if environment_ref.sky and environment_ref.sky.sky_material is ProceduralSkyMaterial:
			var sky_mat=environment_ref.sky.sky_material
			sky_mat.sky_top_color=Color(0.025,0.04,0.12) if night_mode else Color(0.18,0.42,0.76)
			sky_mat.sky_horizon_color=Color(0.08,0.11,0.2) if night_mode else Color(0.78,0.84,0.94)
	if status_label:
		status_label.text="Night mode on  •  press N for day" if night_mode else "Day mode  •  press N for night"

func toggle_weather() -> void:
	rain_mode=not rain_mode
	if environment_ref:
		environment_ref.ambient_light_energy=0.42 if rain_mode else (0.28 if night_mode else 0.7)
		if environment_ref.sky and environment_ref.sky.sky_material is ProceduralSkyMaterial:
			var sky_mat=environment_ref.sky.sky_material
			sky_mat.sky_horizon_color=Color(0.42,0.48,0.55) if rain_mode else (Color(0.08,0.11,0.2) if night_mode else Color(0.78,0.84,0.94))
	if status_label:
		status_label.text="Cloudy/rain ambience  •  press V" if rain_mode else "Weather cleared  •  press V"

func create_district_props() -> void:
	# Original gas-station set piece for a future interaction area.
	box(self,Vector3(145,0.2,142),Vector3(32,0.4,22),Color(0.35,0.37,0.36))
	box(self,Vector3(145,5.2,142),Vector3(26,0.9,14),Color(0.9,0.83,0.62))
	for x in [136,154]:
		for z in [137,147]:
			box(self,Vector3(x,2.6,z),Vector3(0.7,5.2,0.7),Color(0.72,0.72,0.68))
	for x in [137,145,153]:
		box(self,Vector3(x,1.1,151),Vector3(0.8,2.2,1.1),Color(0.88,0.2,0.12))
	# Industrial warehouse forms with colored loading doors.
	for x in [-160,-120]:
		box(self,Vector3(x,5,160),Vector3(30,10,26),Color(0.56,0.58,0.56))
		box(self,Vector3(x,2.3,146.8),Vector3(5,4.6,0.35),Color(0.22,0.30,0.36))
		box(self,Vector3(x+8,2.3,146.8),Vector3(5,4.6,0.35),Color(0.22,0.30,0.36))
	# Neighborhood park block: green lawn, pathway, benches and trees.
	box(self,Vector3(-150,0.05,80),Vector3(42,0.18,38),Color(0.22,0.42,0.25))
	box(self,Vector3(-150,0.12,80),Vector3(5,0.24,34),Color(0.72,0.68,0.60))
	for x in [-166,-154,-142,-130]:
		create_palm(Vector3(x,0,68))
		box(self,Vector3(x,0.8,91),Vector3(3.8,0.5,1.0),Color(0.38,0.25,0.16))
	# Original location markers help orient testers; simple readable signage.
	add_location_sign(Vector3(80,3,-68),"BEACHFRONT")
	add_location_sign(Vector3(-95,3,115),"WAREHOUSE DISTRICT")
	add_location_sign(Vector3(-150,3,55),"CITY PARK")

func add_location_sign(at: Vector3, words: String) -> void:
	var label:=Label3D.new()
	label.text=words
	label.position=at
	label.font_size=64
	label.pixel_size=0.01
	label.modulate=Color(0.96,0.89,0.66)
	label.outline_size=8
	label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
