extends Node3D

var occupied := false
var driver: CharacterBody3D
var speed := 0.0
var steering := 0.0
var max_speed := 24.0
var acceleration := 12.0
var brake_force := 20.0
var vehicle_camera: Camera3D
const PAINT := Color(0.72,0.12,0.08)

func _ready() -> void:
	build_car()
	build_camera()

func build_car() -> void:
	add_box(Vector3(2.0,0.65,4.1),Vector3(0,0.35,0),PAINT)
	add_box(Vector3(1.55,0.8,2.1),Vector3(0,1.0,-0.15),Color(0.12,0.19,0.24))
	add_box(Vector3(1.7,0.22,1.0),Vector3(0,0.75,-1.45),PAINT)
	for x in [-1.05,1.05]:
		for z in [-1.35,1.35]:
			var tire:=CylinderMesh.new()
			tire.top_radius=0.38
			tire.bottom_radius=0.38
			tire.height=0.24
			var wheel:=MeshInstance3D.new()
			wheel.mesh=tire
			wheel.rotation.z=PI/2
			wheel.position=Vector3(x,0.35,z)
			wheel.material_override=mat(Color(0.04,0.04,0.045))
			add_child(wheel)
			var rim:=CylinderMesh.new()
			rim.top_radius=0.2
			rim.bottom_radius=0.2
			rim.height=0.26
			var rim_node:=MeshInstance3D.new()
			rim_node.mesh=rim
			rim_node.rotation.z=PI/2
			rim_node.position=Vector3(x,0.35,z)
			rim_node.material_override=mat(Color(0.4,0.42,0.44),0.35,0.4)
			add_child(rim_node)
		for side in [-0.72,0.72]:
			add_box(Vector3(0.35,0.18,0.08),Vector3(side,0.45,-2.08),Color(0.98,0.83,0.52))
			add_box(Vector3(0.35,0.18,0.08),Vector3(side,0.45,2.08),Color(0.78,0.04,0.03))

func add_box(size: Vector3,pos: Vector3,color: Color) -> void:
	var mesh:=BoxMesh.new()
	mesh.size=size
	var n:=MeshInstance3D.new()
	n.mesh=mesh
	n.position=pos
	n.material_override=mat(color)
	add_child(n)

func mat(color: Color,rough:=0.65,metallic:=0.0) -> StandardMaterial3D:
	var m:=StandardMaterial3D.new()
	m.albedo_color=color
	m.roughness=rough
	m.metallic=metallic
	return m

func build_camera() -> void:
	vehicle_camera=Camera3D.new()
	vehicle_camera.position=Vector3(0,3.2,7.6)
	vehicle_camera.rotation.x=-0.18
	vehicle_camera.fov=75
	add_child(vehicle_camera)
	vehicle_camera.current=false

func toggle_occupancy(character: CharacterBody3D) -> void:
	occupied=not occupied
	if occupied:
		driver=character
		driver.set_driving(true)
		vehicle_camera.current=true
	else:
		vehicle_camera.current=false
		if driver:
			driver.set_driving(false)
			driver.global_position=global_position+global_transform.basis.x*2.4+Vector3(0,0.4,0)
			driver=null
		speed=0.0

func _physics_process(delta: float) -> void:
	if not occupied:
		speed=move_toward(speed,0,delta*5)
		return
	var throttle:=Input.get_action_strength("move_forward")-Input.get_action_strength("move_back")
	var steer_input:=Input.get_action_strength("move_left")-Input.get_action_strength("move_right")
	if throttle>0:
		speed=move_toward(speed,max_speed,acceleration*throttle*delta)
	elif throttle<0:
		speed=move_toward(speed,-max_speed*0.35,acceleration*0.65*delta)
	else:
		speed=move_toward(speed,0,brake_force*delta)
	steering=move_toward(steering,steer_input,delta*3.2)
	rotation.y+=steering*speed*0.022*delta
	global_position+=-global_transform.basis.z*speed*delta
	vehicle_camera.global_position=vehicle_camera.global_position.lerp(global_position+global_transform.basis*Vector3(0,3.2,7.6),delta*4)
	vehicle_camera.look_at(global_position+Vector3(0,1,0),Vector3.UP)
