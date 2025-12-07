extends VehicleBody3D

@export var engine_force_value := 40.0

const STEER_SPEED = 20
const STEER_LIMIT = 0.2
const BRAKE_STRENGTH = 2.0
const UPSIDE_DOWN_THRESHOLD = 2.0

var _steer_target := 0.0
var _upside_down_time := 0.0
var _spawn_position: Vector3
var _spawn_rotation: Basis

func _ready() -> void:
	_spawn_position = global_position
	_spawn_rotation = global_transform.basis

func _physics_process(delta: float) -> void:
	if global_transform.basis.y.y < 0.0:
		_upside_down_time += delta
		if _upside_down_time >= UPSIDE_DOWN_THRESHOLD:
			_reset_to_spawn()
	else:
		_upside_down_time = 0.0
	
	_steer_target = Input.get_axis(&"right", &"left")
	_steer_target *= STEER_LIMIT
	
	if Input.is_action_pressed(&"up"):
		# Increase engine force at low speeds to make the initial acceleration faster.
		var speed := linear_velocity.length()
		if speed < 5.0 and not is_zero_approx(speed):
			engine_force = clampf(engine_force_value * 5.0 / speed, 0.0, 100.0)
		else:
			engine_force = engine_force_value
	else:
		engine_force = 0.0
		
	if Input.is_action_pressed(&"down"):
		var speed := linear_velocity.length()
		if speed < 5.0 and not is_zero_approx(speed):
			engine_force = -clampf(engine_force_value * BRAKE_STRENGTH * 5.0 / speed, 0.0, 100.0)
		else:
			engine_force = -engine_force_value * BRAKE_STRENGTH

		engine_force *= Input.get_action_strength(&"down")

	steering = move_toward(steering, _steer_target, STEER_SPEED * delta)

func _reset_to_spawn() -> void:
	global_position = _spawn_position
	global_transform.basis = _spawn_rotation
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	_upside_down_time = 0.0
