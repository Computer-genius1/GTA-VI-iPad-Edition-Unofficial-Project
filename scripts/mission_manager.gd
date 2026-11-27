extends Node3D
# Small original mission framework for the prototype. Objectives are location-based.
var player: CharacterBody3D
var vehicle: Node3D
var objective_label: Label
var marker: MeshInstance3D
var story_active := false
var mission_index := 0
var missions := [
	{"title":"Coastal Welcome","description":"Head to the beachfront promenade.","target":Vector3(0,0,-96),"radius":12.0},
	{"title":"Warehouse Run","description":"Drive or walk to the warehouse district.","target":Vector3(-120,0,150),"radius":14.0},
	{"title":"Park Recon","description":"Visit the neighborhood park to finish the intro.","target":Vector3(-150,0,80),"radius":12.0}
]

func setup(player_node: CharacterBody3D, vehicle_node: Node3D, label: Label) -> void:
	player=player_node
	vehicle=vehicle_node
	objective_label=label
	build_marker()

func build_marker() -> void:
	var mesh:=CylinderMesh.new()
	mesh.top_radius=1.8
	mesh.bottom_radius=1.8
	mesh.height=0.16
	marker=MeshInstance3D.new()
	marker.mesh=mesh
	var mat:=StandardMaterial3D.new()
	mat.albedo_color=Color(0.15,0.85,0.95,0.8)
	mat.emission_enabled=true
	mat.emission=Color(0.08,0.55,0.8)
	mat.emission_energy_multiplier=0.7
	marker.material_override=mat
	marker.visible=false
	add_child(marker)

func start_story() -> void:
	story_active=true
	mission_index=0
	set_objective()

func set_objective() -> void:
	if mission_index>=missions.size():
		story_active=false
		marker.visible=false
		objective_label.text="STORY INTRO COMPLETE  •  Sandbox remains available"
		return
	var mission: Dictionary=missions[mission_index]
	marker.visible=true
	marker.position=mission.target+Vector3(0,0.15,0)
	objective_label.text="MISSION %d/%d: %s\n%s"%(mission_index+1,missions.size(),mission.title,mission.description)

func _process(_delta: float) -> void:
	if not story_active or player==null:
		return
	var current_position:=player.global_position
	if vehicle and vehicle.get("occupied"):
		current_position=vehicle.global_position
	var mission: Dictionary=missions[mission_index]
	if current_position.distance_to(mission.target)<=mission.radius:
		mission_index+=1
		set_objective()
