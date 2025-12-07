extends Camera3D

var follow_car: bool = true
var look_at_car: bool = true
var follow_smoothness: float = 5.0
var height_offset: float = 2.0
var distance_behind: float = 3.0

@onready var carBody: VehicleBody3D = $"../Body"

func _process(delta: float) -> void:
	if follow_car:
		# Get horizontal direction behind car (ignore pitch/roll)
		var car_forward = carBody.global_transform.basis.z
		car_forward.y = 0
		car_forward = car_forward.normalized()
		
		var behind_offset = -car_forward * distance_behind
		var target_position = carBody.global_position + behind_offset
		target_position.y = carBody.global_position.y + height_offset
		
		# Smooth horizontal movement
		var new_pos = global_position.lerp(target_position, follow_smoothness * delta)
		# Keep camera height completely stable (only changes with terrain, not suspension)
		new_pos.y = lerpf(global_position.y, target_position.y, 0.5 * delta)
		global_position = new_pos

	if look_at_car:
		var look_target = carBody.global_position
		look_target.y = global_position.y - height_offset * 0.5
		look_at(look_target)
