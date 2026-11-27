extends CharacterBody3D

@export var walk_speed: float = 7.0
@export var acceleration: float = 18.0
@export var gravity: float = 22.0
var yaw := 0.0
var pitch := -0.12

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * 0.003
		pitch = clamp(pitch - event.relative.y * 0.003, -0.65, 0.45)
		rotation.y = yaw
		$CameraPivot.rotation.x = pitch
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	var input_vec := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	)
	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()
	var direction := (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
	velocity.x = move_toward(velocity.x, direction.x * walk_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * walk_speed, acceleration * delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	move_and_slide()
