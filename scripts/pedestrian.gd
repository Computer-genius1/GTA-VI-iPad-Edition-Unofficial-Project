extends Node3D
# Simple original pedestrian placeholder with slow strolling behavior.
@export var patrol_points: Array[Vector3] = []
@export var stroll_speed := 1.1
var current_point := 0
var mesh_node: MeshInstance3D

func _ready() -> void:
	var capsule:=CapsuleMesh.new()
	capsule.radius=0.28
	capsule.height=1.65
	mesh_node=MeshInstance3D.new()
	mesh_node.mesh=capsule
	mesh_node.position.y=0.85
	var material:=StandardMaterial3D.new()
	material.albedo_color=Color(0.78,0.52,0.28)
	mesh_node.material_override=material
	add_child(mesh_node)
	if patrol_points.size()>0:
		global_position=patrol_points[0]

func _process(delta: float) -> void:
	if patrol_points.size()<2:
		return
	var target:=patrol_points[current_point]
	var dir:=target-global_position
	if dir.length()<0.5:
		current_point=(current_point+1)%patrol_points.size()
		return
	global_position+=dir.normalized()*stroll_speed*delta
	look_at(global_position+dir,Vector3.UP)
