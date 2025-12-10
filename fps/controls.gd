extends CanvasLayer

@onready var player: CharacterBody3D = $"../Player"

@onready var controls_panel: Control = $ControlsPanel

@onready var speed_slider: HSlider = $ControlsPanel/VBoxContainer/SpeedContainer/SpeedSlider
@onready var jump_slider: HSlider = $ControlsPanel/VBoxContainer/JumpContainer/JumpSlider
@onready var sensitivity_slider: HSlider = $ControlsPanel/VBoxContainer/SensitivityContainer/SensitivitySlider

@onready var speed_label: Label = $ControlsPanel/VBoxContainer/SpeedContainer/SpeedLabel
@onready var jump_label: Label = $ControlsPanel/VBoxContainer/JumpContainer/JumpLabel
@onready var sensitivity_label: Label = $ControlsPanel/VBoxContainer/SensitivityContainer/SensitivityLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	controls_panel.visible = false
	
	speed_label.text = "Speed: %.1f" % player.speed
	jump_label.text = "Jump: %.1f" % player.jump_velocity
	sensitivity_label.text = "Sensitivity: %.4f" % player.mouse_sensitivity
	

func _toggle_visibility() -> void:
	controls_panel.visible = !controls_panel.visible

func _on_speed_slider_value_changed(value: float) -> void:
	player.speed = value
	speed_label.text = "Speed: %.1f" % value

func _on_jump_slider_value_changed(value: float) -> void:
	player.jump_velocity = value
	jump_label.text = "Jump: %.1f" % value

func _on_sensitivity_slider_value_changed(value: float) -> void:
	player.mouse_sensitivity = value
	sensitivity_label.text = "Sensitivity: %.4f" % value
