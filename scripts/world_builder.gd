extends Node3D

# Original procedural coastal-city prototype. Layout is inspired by South Florida,
# but all geometry and map layout are generated for this project.
const CITY_EXTENT := 240.0
const BLOCK := 28.0
const ROAD := 8.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 6112026
	build_environment()
	build_coast()
	build_roads()
	build_blocks()
	build_landmarks()
	setup_input()

func setup_input() -> void:
	var map := {"move_forward": KEY_W, "move_back": KEY_S, "move_left": KEY_A, "move_right": KEY_D}
	for action in map:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var ev := InputEventKey.new()
			ev.keycode = map[action]
			InputMap.action_add_event(action, ev)

func build_environment() -> void:
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.sky.sky_material = ProceduralSkyMaterial.new()
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.8
	environment.tonemap_mode = Environment.TONE_MAP_FILMIC
	environment.ssr_enabled = true
	env.environment = environment
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -28, 0)
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	add_child(sun)

func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, roughness := 0.82) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mi.material_override = mat
	parent.add_child(mi)
	return mi

func build_coast() -> void:
	# Ocean and sandy edge along the southern side of the prototype.
	box(self, Vector3(0, -0.22, -148), Vector3(500, 0.2, 100), Color(0.04, 0.38, 0.58), 0.18)
	box(self, Vector3(0, -0.1, -99), Vector3(500, 0.25, 14), Color(0.86, 0.72, 0.48))
	box(self, Vector3(0, 0, -88), Vector3(500, 0.25, 10), Color(0.38, 0.38, 0.34))

func build_roads() -> void:
	# Grid streets, arterial boulevard, sidewalks and painted lane dividers.
	for x in range(-120, 121, int(BLOCK)):
		box(self, Vector3(x, -0.02, 0), Vector3(ROAD, 0.16, 245), Color(0.12, 0.13, 0.14))
		box(self, Vector3(x - ROAD/2 - 1.4, 0.02, 0), Vector3(2.8, 0.22, 245), Color(0.53, 0.51, 0.47))
		box(self, Vector3(x + ROAD/2 + 1.4, 0.02, 0), Vector3(2.8, 0.22, 245), Color(0.53, 0.51, 0.47))
	for z in range(-120, 121, int(BLOCK)):
		box(self, Vector3(0, -0.02, z), Vector3(245, 0.16, ROAD), Color(0.12, 0.13, 0.14))
		box(self, Vector3(0, 0.02, z - ROAD/2 - 1.4), Vector3(245, 0.22, 2.8), Color(0.53, 0.51, 0.47))
		box(self, Vector3(0, 0.02, z + ROAD/2 + 1.4), Vector3(245, 0.22, 2.8), Color(0.53, 0.51, 0.47))
	# Wide downtown avenue with median.
	box(self, Vector3(0, 0.01, 0), Vector3(24, 0.2, 250), Color(0.10, 0.11, 0.12))
	box(self, Vector3(0, 0.15, 0), Vector3(2.2, 0.3, 245), Color(0.36, 0.42, 0.30))
	for z in range(-112, 113, 12):
		box(self, Vector3(-5.5, 0.1, z), Vector3(0.18, 0.03, 4.0), Color(0.92, 0.86, 0.58))
		box(self, Vector3(5.5, 0.1, z), Vector3(0.18, 0.03, 4.0), Color(0.92, 0.86, 0.58))

func build_blocks() -> void:
	var palette := [Color(0.79,0.73,0.65), Color(0.82,0.80,0.72), Color(0.62,0.66,0.67), Color(0.88,0.79,0.68), Color(0.69,0.74,0.72), Color(0.75,0.68,0.61)]
	for x in range(-108, 109, int(BLOCK)):
		for z in range(-108, 85, int(BLOCK)):
			if abs(x) < 18: continue
			var h := rng.randf_range(8, 26)
			if abs(x) < 60 and abs(z) < 60: h = rng.randf_range(28, 70)
			var w := rng.randf_range(13, 19)
			var d := rng.randf_range(13, 19)
			var p := Vector3(x + rng.randf_range(-3,3), h/2, z + rng.randf_range(-3,3))
			var building := box(self, p, Vector3(w,h,d), palette[rng.randi_range(0,palette.size()-1)])
			# Simple roof details and rooftop equipment.
			box(self, Vector3(p.x, h + 0.5, p.z), Vector3(w*0.55, 1.0, d*0.55), Color(0.38,0.4,0.4))
			if rng.randf() > 0.5:
				box(self, Vector3(p.x + 2, h + 1.5, p.z), Vector3(2,2,2), Color(0.45,0.47,0.46))
			# A few low-rise buildings have colorful awnings.
			if h < 18:
				box(self, Vector3(p.x, 2.7, p.z + d/2 + 0.4), Vector3(w*0.65, 0.5, 0.8), Color(0.86,0.35,0.26))

func palm(at: Vector3) -> void:
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.18
	trunk.bottom_radius = 0.35
	trunk.height = 6.0
	var t := MeshInstance3D.new()
	t.mesh = trunk
	t.position = at + Vector3(0,3,0)
	var tm := StandardMaterial3D.new()
	tm.albedo_color = Color(0.44,0.29,0.16)
	t.material_override = tm
	add_child(t)
	for i in range(7):
		var angle := i * TAU / 7
		var leaf := box(self, at + Vector3(cos(angle)*2.2, 5.8, sin(angle)*2.2), Vector3(4.5,0.18,0.65), Color(0.13,0.36,0.17))
		leaf.rotation.y = angle
		leaf.rotation.z = -0.18

func build_landmarks() -> void:
	# Palm-lined beach boulevard, pier stub, and a distinctive hotel tower.
	for x in range(-110, 111, 14):
		palm(Vector3(x, 0, -91))
		palm(Vector3(x, 0, -103))
	# Downtown signature tower silhouette.
	box(self, Vector3(-32, 52, 8), Vector3(22, 104, 20), Color(0.47,0.57,0.62))
	box(self, Vector3(-32, 106, 8), Vector3(12, 4, 12), Color(0.26,0.35,0.42))
	# Waterfront pier reaching into the sea.
	box(self, Vector3(30, 0.4, -115), Vector3(12, 1, 38), Color(0.48,0.39,0.28))
	for x in [-34, -20, 20, 34, 48, 62]:
		palm(Vector3(x, 0, -80))
