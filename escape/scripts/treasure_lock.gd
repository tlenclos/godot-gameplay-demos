extends Control

signal unlocked
signal closed

const VALID_CODE: Array[int] = [1, 9, 9, 1]

var current_code: Array[int] = [0, 0, 0, 0]

@onready var digit_containers: Array[VBoxContainer] = [
	$Panel/MarginContainer/VBox/DigitsContainer/Digit1,
	$Panel/MarginContainer/VBox/DigitsContainer/Digit2,
	$Panel/MarginContainer/VBox/DigitsContainer/Digit3,
	$Panel/MarginContainer/VBox/DigitsContainer/Digit4,
]
@onready var unlock_btn: Button = $Panel/MarginContainer/VBox/UnlockBtn
@onready var panel: PanelContainer = $Panel

func _ready() -> void:
	# Connect buttons for each digit
	for i in range(4):
		var container = digit_containers[i]
		var up_btn = container.get_node("Up") as Button
		var down_btn = container.get_node("Down") as Button
		
		up_btn.pressed.connect(_on_digit_up.bind(i))
		down_btn.pressed.connect(_on_digit_down.bind(i))
	
	unlock_btn.pressed.connect(_on_unlock_pressed)
	_update_display()


func _on_digit_up(index: int) -> void:
	current_code[index] = (current_code[index] + 1) % 10
	_update_display()


func _on_digit_down(index: int) -> void:
	current_code[index] = (current_code[index] - 1 + 10) % 10
	_update_display()


func _update_display() -> void:
	for i in range(4):
		var label = digit_containers[i].get_node("Display/Value") as Label
		label.text = str(current_code[i])


func _on_unlock_pressed() -> void:
	if current_code == VALID_CODE:
		_show_success()
		unlocked.emit()
	else:
		_show_error()


func _show_success() -> void:
	# Flash green on digits
	for container in digit_containers:
		var label = container.get_node("Display/Value") as Label
		label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1))
	
	# Disable buttons after unlock
	unlock_btn.disabled = true
	for container in digit_containers:
		container.get_node("Up").disabled = true
		container.get_node("Down").disabled = true


func _show_error() -> void:
	# Flash red on digits briefly
	for container in digit_containers:
		var label = container.get_node("Display/Value") as Label
		label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3, 1))
	
	# Reset color after delay
	await get_tree().create_timer(0.5).timeout
	for container in digit_containers:
		var label = container.get_node("Display/Value") as Label
		label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.75, 1))
