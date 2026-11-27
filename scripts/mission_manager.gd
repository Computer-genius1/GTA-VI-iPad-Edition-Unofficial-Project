extends Node3D
# Build 0.1 mission manager: checkpoint persistence, rewards, five original objectives.
const SAVE_PATH := "user://leonida_build01.save"
var player: CharacterBody3D
var vehicle: Node3D
var objective_label: Label
var marker: MeshInstance3D
var story_active := false
var mission_index := 0
var cash := 0
var missions := [
 {"title":"Coastal Welcome","description":"Head to the beachfront promenade.","target":Vector3(0,0,-96),"radius":12.0,"reward":100},
 {"title":"Warehouse Run","description":"Visit the warehouse district.","target":Vector3(-120,0,150),"radius":14.0,"reward":150},
 {"title":"Park Recon","description":"Visit the neighborhood park.","target":Vector3(-150,0,80),"radius":12.0,"reward":175},
 {"title":"Downtown Check-in","description":"Reach the downtown plaza.","target":Vector3(60,0,0),"radius":14.0,"reward":200},
 {"title":"Marina View","description":"Drive or walk to the marina lookout.","target":Vector3(145,0,142),"radius":15.0,"reward":250}
]
func setup(player_node: CharacterBody3D, vehicle_node: Node3D, label: Label) -> void:
 player=player_node
 vehicle=vehicle_node
 objective_label=label
 load_save()
 build_marker()
func load_save() -> void:
 if not FileAccess.file_exists(SAVE_PATH): return
 var file:=FileAccess.open(SAVE_PATH,FileAccess.READ)
 if file:
  var data: Variant=JSON.parse_string(file.get_as_text())
  if data is Dictionary:
   mission_index=clamp(int(data.get("mission_index",0)),0,missions.size())
   cash=max(0,int(data.get("cash",0)))
   if player and data.has("player_position"): player.global_position=Vector3(data.player_position[0],data.player_position[1],data.player_position[2])
func save_progress() -> void:
 var data={"mission_index":mission_index,"cash":cash,"player_position":[player.global_position.x,player.global_position.y,player.global_position.z]}
 var file:=FileAccess.open(SAVE_PATH,FileAccess.WRITE)
 if file: file.store_string(JSON.stringify(data))
func build_marker() -> void:
 var mesh:=CylinderMesh.new()
 mesh.top_radius=1.8
 mesh.bottom_radius=1.8
 mesh.height=0.16
 marker=MeshInstance3D.new()
 marker.mesh=mesh
 var mat:=StandardMaterial3D.new()
 mat.albedo_color=Color(1.0,0.78,0.16,0.85)
 mat.emission_enabled=true
 mat.emission=Color(0.65,0.42,0.04)
 mat.emission_energy_multiplier=0.9
 marker.material_override=mat
 marker.visible=false
 add_child(marker)
func start_story() -> void:
 story_active=true
 mission_index=clamp(mission_index,0,missions.size())
 set_objective()
func set_objective() -> void:
 if mission_index>=missions.size():
  story_active=false
  marker.visible=false
  objective_label.text="BUILD 0.1 STORY COMPLETE • $%d earned • Free roam unlocked"%cash
  save_progress()
  return
 var mission: Dictionary=missions[mission_index]
 marker.visible=true
 marker.position=mission.target+Vector3(0,0.15,0)
 objective_label.text="MISSION %d/%d: %s\n%s\nReward: $%d  •  Wallet: $%d"%(mission_index+1,missions.size(),mission.title,mission.description,mission.reward,cash)
func _process(_delta: float) -> void:
 if not story_active or player==null or mission_index>=missions.size(): return
 var current_position:=player.global_position
 if vehicle and vehicle.get("occupied"): current_position=vehicle.global_position
 var mission: Dictionary=missions[mission_index]
 if current_position.distance_to(mission.target)<=mission.radius:
  cash+=int(mission.reward)
  mission_index+=1
  save_progress()
  set_objective()
