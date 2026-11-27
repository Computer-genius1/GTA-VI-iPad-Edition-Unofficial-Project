extends CharacterBody3D

@export var walk_speed := 5.8
@export var sprint_speed := 9.2
@export var acceleration := 15.0
@export var braking := 19.0
@export var jump_velocity := 5.2
@export var gravity := 20.0
@export var mouse_sensitivity := 0.0025
var camera_yaw := 0.0
var camera_pitch := -0.12
var camera: Camera3D
var camera_pivot: Node3D
var driving := false

func _ready() -> void:
	camera_pivot=Node3D.new()
	camera_pivot.name="CameraPivot"
	camera_pivot.position=Vector3(0,1.3,0)
	add_child(camera_pivot)
	camera=Camera3D.new()
	camera.name="PlayerCamera"
	camera.position=Vector3(0,2.3,6.5)
	camera_pivot.add_child(camera)
	camera.current=true
	camera.fov=72
	camera_pivot.rotation.x=camera_pitch
	if not OS.has_feature("mobile"):
		Input.mouse_mode=Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
		camera_yaw-=event.relative.x*mouse_sensitivity
		camera_pitch=clamp(camera_pitch-event.relative.y*mouse_sensitivity,-0.7,0.45)
		rotation.y=camera_yaw
		camera_pivot.rotation.x=camera_pitch
	if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT and not OS.has_feature("mobile"):
		Input.mouse_mode=Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if driving:
		velocity=Vector3.ZERO
		return
	var input_vector:=Vector2(Input.get_action_strength("move_right")-Input.get_action_strength("move_left"),Input.get_action_strength("move_back")-Input.get_action_strength("move_forward"))
	if input_vector.length()>1.0:
		input_vector=input_vector.normalized()
	var move_direction:=Vector3(input_vector.x,0,input_vector.y).rotated(Vector3.UP,camera_yaw)
	var speed:=sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	var target_velocity:=move_direction*speed
	var rate:=acceleration if input_vector.length()>0.05 else braking
	velocity.x=move_toward(velocity.x,target_velocity.x,rate*delta)
	velocity.z=move_toward(velocity.z,target_velocity.z,rate*delta)
	if not is_on_floor():
		velocity.y-=gravity*delta
	else:
		velocity.y=0.0
		if Input.is_action_just_pressed("jump"):
			velocity.y=jump_velocity
	if input_vector.length()>0.1:
		rotation.y=lerp_angle(rotation.y,atan2(-move_direction.x,-move_direction.z),delta*8.0)
	move_and_slide()

func set_driving(active: bool) -> void:
	driving=active
	camera.current=not active
