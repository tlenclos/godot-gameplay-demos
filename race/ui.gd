extends VBoxContainer

@onready var camera_x: SpinBox = $cameraX
@onready var camera_y: SpinBox = $cameraY
@onready var camera_z: SpinBox = $cameraZ
@onready var follow_car_checkbox: CheckBox = $followCar
@onready var look_at_car_checkbox: CheckBox = $lookAtCar
@onready var camera_3d: Camera3D = %Car/CarCamera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_x.value = camera_3d.position.x
	camera_y.value = camera_3d.position.y
	camera_z.value = camera_3d.position.z
	follow_car_checkbox.button_pressed = camera_3d.follow_car
	look_at_car_checkbox.button_pressed = camera_3d.look_at_car
	
	if follow_car_checkbox.button_pressed:
		_show_camera_control(false)

func _on_camera_x_value_changed(value: float) -> void:
	camera_3d.position.x = value

func _on_camera_y_value_changed(value: float) -> void:
	camera_3d.position.y = value

func _on_camera_z_value_changed(value: float) -> void:
	camera_3d.position.z = value

func _on_follow_car_toggled(toggled_on: bool) -> void:
	camera_3d.follow_car = toggled_on
	_show_camera_control(not toggled_on)

func _on_look_at_car_toggled(toggled_on: bool) -> void:
	camera_3d.look_at_car = toggled_on

func _show_camera_control(show: bool):
	if show:
		camera_x.show()
		camera_y.show()
		camera_z.show()
	else:
		camera_x.hide()
		camera_y.hide()
		camera_z.hide()
