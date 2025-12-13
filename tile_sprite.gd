extends Sprite2D

var LETTER: String = ""
var VALUE: int = 0

var MAX_SPEED: float = 40.0
var TILE_SIZE: float = 0.0

var LetterPicker = preload("res://letter_picker.tscn")

var is_moving: bool = false
var velocity: Vector2 = Vector2(0, 0)
var placed: bool = false
var scored: bool = false
var square

signal started_moving(tile: Sprite2D)
signal finished_moving(tile: Sprite2D, placed: bool)

func _ready() -> void:
	update_display()
	TILE_SIZE = %CollisionShape2D.shape.size.x

func _process(delta: float) -> void:
	set_is_moving()
	update_position(delta)

func set_tile_letter(letter: String) -> void:
	LETTER = letter

func set_value(value: int) -> void:
	VALUE = value
	if value == 0:
		%Value.visible = false

func update_display() -> void:
	%Letter.text = LETTER
	%Value.text = str(VALUE)

func get_tile_letter() -> String:
	return LETTER

func get_value() -> int:
	return VALUE

func get_bounds() -> Dictionary:
	var global_pos = %CollisionShape2D.global_position
	var size = %CollisionShape2D.shape.size
	var pos = Vector2(global_pos.x - size.x / 2, global_pos.y - size.y / 2)
	return {
		"top": pos.y,
		"right": pos.x,
		"bottom": pos.y + size.y,
		"left": pos.x + size.x,
	}

func set_is_moving() -> void:
	if scored:
		return

	if is_moving and Input.is_action_just_released("left_click"):
		end_move()
	elif !is_moving and Input.is_action_just_pressed("left_click"):
		start_move()

func start_move() -> void:
	if !_is_mouse_over():
		return

	placed = false
	Globals.selected_tile = self
	z_index = 2
	is_moving = true
	emit_signal("started_moving", self)

func end_move() -> void:
	emit_signal("finished_moving", self, placed)
	Globals.selected_tile = null
	z_index = 1
	is_moving = false
	_show_letter_selection()

func update_position(delta: float) -> void:
	if !is_moving || scored:
		return
	
	var global_mouse_pos = get_global_mouse_position()
	var direction: Vector2 = global_mouse_pos - position
	
	var mouse_x = snapped(global_mouse_pos.x, 0.01)
	var mouse_y = snapped(global_mouse_pos.y, 0.01)
	var tile_x = snapped(position.x, 0.01)
	var tile_y = snapped(position.y, 0.01)
	
	# Tile is already centered, skip position update
	if mouse_x == tile_x && mouse_y == tile_y:
		return
	
	var speed = MAX_SPEED
	var x_distance = abs(mouse_x - tile_x)
	var y_distance = abs(mouse_y - tile_y)
	
	if x_distance < TILE_SIZE && y_distance < TILE_SIZE:
		speed *= max(x_distance, y_distance) / TILE_SIZE
		speed = max(speed, 10.0)
	
	velocity = direction * speed
	position += velocity * delta

func _show_letter_selection() -> void:
	if VALUE != 0 or !placed:
		return
	
	is_moving = false
	var letter_picker = LetterPicker.instantiate()
	letter_picker.initialize(self)
	add_sibling(letter_picker)

func _is_mouse_over() -> bool:
	var mouse = get_global_mouse_position()
	var bounds = get_bounds()
	return mouse.x > bounds.right and mouse.y > bounds.top and mouse.x < bounds.left and mouse.y < bounds.bottom
