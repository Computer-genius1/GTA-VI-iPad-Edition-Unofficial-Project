extends Node3D
# Original lightweight traffic prop that follows a simple looping route.
@export var route: Array[Vector3] = []
@export var cruise_speed := 7.0
var target_index := 0
var body_mesh: MeshInstance3D

func _ready() -> void:
	build_vehicle()
	if route.size()<2:
		queue_free()
		return
	global_position=route[0]

func build_vehicle() -> void:
	var mesh:=BoxMesh.new()
	mesh.size=Vector3(1.7,0.55,3.6)
	body_mesh=MeshInstance3D.new()
	body_mesh.mesh=mesh
	body_mesh.position.y=0.45
	var paint:=StandardMaterial3D.new()
	paint.albedo_color=Color(0.18,0.48,0.72)
	paint.roughness=0.35
	body_mesh.material_override=paint
	add_child(body_mesh)
	var cabin:=BoxMesh.new()
	cabin.size=Vector3(1.35,0.65,1.6)
	var cabin_node:=MeshInstance3D.new()
	cabin_node.mesh=cabin
	cabin_node.position=Vector3(0,0.95,0.05)
	var glass:=StandardMaterial3D.new()
	glass.albedo_color=Color(0.12,0.18,0.22)
	cabin_node.material_override=glass
	add_child(cabin_node)

func _process(delta: float) -> void:
	if route.size()<2:
		return
	var target:=route[target_index]
	var direction:=target-global_position
	if direction.length()<2:
		target_index=(target_index+1)%route.size()
		return
	var velocity:=direction.normalized()*cruise_speed
	global_position+=velocity*delta
	if velocity.length()>0.01:
		look_at(global_position+velocity,Vector3.UP)
