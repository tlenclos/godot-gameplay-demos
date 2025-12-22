extends Node2D

## TODO Effects on drag/drop/hover
## TODO Shader on hero card

var screen_size: Vector2;
var card_dragged: Node2D = null;

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	if card_dragged:
		card_dragged.position = Vector2(clamp(get_global_mouse_position().x, 0, screen_size.x), clamp(get_global_mouse_position().y, 0, screen_size.y))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = card_on_mouse()
			if card:
				card_dragged = card
				card.position = get_global_mouse_position()
		else:
			card_dragged = null

func card_on_mouse():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var results = space_state.intersect_point(parameters)
	
	for result in results:
		var card = result.collider.get_parent()
		if card and card.is_in_group("cards"):
			return card
	
	return null
