extends Node2D

## TODO Shader on faces card

# Credits to https://www.youtube.com/@BarrysDevHell for the video tutorials

const CARD_SCALE = 4;
const SNAP_TWEEN_DURATION: float = 0.1 # Duration for card snap animation
var screen_size: Vector2;

# State
var card_dragged: Node2D = null;
var card_hovering: Node2D = null

# Hand management variables
var hand_cards: Array = []
var hand_position: Vector2 = Vector2.ZERO
var hand_spread: int = 100 # Horizontal spacing between cards
var hand_arc_height: int = 40 # Vertical offset for fan effect
var max_hand_size: int = -1 # -1 means unlimited
var bottom_of_hand_position: int = 150
var card_slots: Array[Control] = []

func _ready() -> void:
	screen_size = get_viewport_rect().size
	# Initialize hand position at bottom center of screen
	hand_position = Vector2(screen_size.x / 2, screen_size.y - bottom_of_hand_position)
	
	# Find and setup card slot
	for card_slot in get_tree().get_nodes_in_group("cardSlots"):
		card_slots.append(card_slot)
		card_slot.connect("card_dropped", on_card_dropped_in_slot)
	
	# Add existing cards from scene to hand
	for child in get_children():
		if child.is_in_group("cards"):
			add_card_to_hand(child)
	arrange_hand()

func _process(delta: float) -> void:
	if card_dragged:
		card_dragged.position = Vector2(clamp(get_global_mouse_position().x, 0, screen_size.x), clamp(get_global_mouse_position().y, 0, screen_size.y))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = card_on_mouse()
			if card:
				start_drag(card)
		else:
			finish_drag()

func card_on_mouse():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var results = space_state.intersect_point(parameters)
	
	if results.size() > 0:
		return get_card_on_top(results)
	
func get_card_on_top(cards):
	var highest_z_card = cards[0].collider.get_parent()
	
	for card in cards:
		var current_card = card.collider.get_parent()
		
		if current_card.is_in_group("cards") and current_card.z_index > highest_z_card.z_index:
			highest_z_card = current_card
	
	return highest_z_card
	
func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(CARD_SCALE + 0.2, CARD_SCALE + 0.2)
		card.z_index = 10
		card_hovering = card;
	else:
		card.scale = Vector2(CARD_SCALE, CARD_SCALE)
		card.z_index = get_z_index_for_card(card)
		card_hovering = null
	
func connect_card_signals(card):
	if not card.is_connected("hovered", on_hovered_card):
		card.connect("hovered", on_hovered_card)
	if not card.is_connected("hovered_off", on_hovered_card_off):
		card.connect("hovered_off", on_hovered_card_off)

func on_hovered_card(card):
	if !card_hovering:
		highlight_card(card, true)
	
func on_hovered_card_off(card):
	if !card_dragged and card_hovering:
		highlight_card(card, false)

		var new_card_hovered = card_on_mouse()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			card_hovering = null
	
func start_drag(card):
	card_dragged = card
	card.scale = Vector2(CARD_SCALE, CARD_SCALE)
	card.z_index = 10
	card.rotation = 0
	
func finish_drag():
	if card_dragged:
		var card = card_dragged
		var mouse_pos = get_global_mouse_position()
		
		# Check if card was dropped in the slot
		var hasFoundSlot = false
		for card_slot in card_slots:
			if card_slot.is_point_inside(mouse_pos):
				# Card dropped in slot
				handle_card_drop_in_slot(card, card_slot)
				hasFoundSlot = true
				break
				
		# Return to normal state
		card.scale = Vector2(CARD_SCALE + 0.1, CARD_SCALE + 0.1)
		card_dragged = null
			
		# Return to hand if no slot detected
		if !hasFoundSlot:
			# Card not in slot, snap back to hand
			snap_card_to_hand(card)

# Hand management methods
func add_card_to_hand(card: Node2D) -> void:
	if max_hand_size > 0 and hand_cards.size() >= max_hand_size:
		return # Hand is full
	
	if card not in hand_cards:
		hand_cards.append(card)
		connect_card_signals(card)

func remove_card_from_hand(card: Node2D) -> void:
	print("Remove card from hand: ", card.name)
	var index = hand_cards.find(card)
	if index != -1:
		hand_cards.remove_at(index)
		arrange_hand()

func arrange_hand() -> void:
	var total_cards = hand_cards.size()
	if total_cards == 0:
		return
	
	for i in range(total_cards):
		var card = hand_cards[i]
		var target_position = get_card_hand_position(i, total_cards)
		card.position = target_position
		
		# Rotation effect
		var center_offset = (i - (total_cards - 1) / 2.0)
		var rotation_angle = center_offset * 0.1 # Adjust rotation intensity
		card.rotation = rotation_angle
		card.z_index = i;

func get_card_hand_position(index: int, total: int) -> Vector2:
	if total == 0:
		return hand_position
	
	# Calculate horizontal offset from center
	var center_offset = index - (total - 1) / 2.0
	var x_offset = center_offset * hand_spread
	
	# Calculate vertical offset for arc effect (cards further from center are higher)
	var arc_factor = abs(center_offset) / (total / 2.0) if total > 1 else 0.0
	var y_offset = arc_factor * hand_arc_height
	
	return hand_position + Vector2(x_offset, y_offset)

func snap_card_to_hand(card: Node2D) -> void:
	if card not in hand_cards:
		add_card_to_hand(card)

	var index = hand_cards.find(card)
	var target_position = get_card_hand_position(index, hand_cards.size())
	# Calculate target rotation
	var center_offset = (index - (hand_cards.size() - 1) / 2.0)
	var target_rotation = center_offset * 0.1
	
	# Create tween for smooth animation
	var tween = create_tween()
	tween.set_parallel(true) # Allow multiple properties to tween simultaneously
	tween.tween_property(card, "position", target_position, SNAP_TWEEN_DURATION)
	tween.tween_property(card, "rotation", target_rotation, SNAP_TWEEN_DURATION)
	tween.finished.connect(arrange_hand)
	
func handle_card_drop_in_slot(card: Node2D, card_slot: Control) -> void:
	# Remove card from hand
	remove_card_from_hand(card)
	
	# Card is already at mouse position, just reset rotation and z_index
	card.rotation = 0
	card.z_index = 5 # Keep it above hand cards but below dragged cards
	
	# Optionally, animate to slot center
	if card_slot:
		# Get slot center in screen coordinates
		var slot_center_screen = card_slot.global_position + card_slot.slot_size / 2
		# For now, keep card at current position (mouse position)
		# The card is already where the user dropped it
	
	# Emit signal
	if card_slot:
		card_slot.emit_signal("card_dropped", card)

func on_card_dropped_in_slot(card: Node2D) -> void:
	# Handle card drop event
	print("Card dropped in slot: ", card.name)

func get_z_index_for_card(card: Node2D) -> int:
	if card in hand_cards:
		return hand_cards.find(card)
	return 1
