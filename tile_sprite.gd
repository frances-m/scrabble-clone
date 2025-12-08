extends Sprite2D

var LETTER: String = ""
var VALUE: int = 0

var MAX_SPEED: float = 40.0
var TILE_SIZE: float = 0.0

var is_moving: bool = false
var mouse_over: bool = false
var velocity: Vector2 = Vector2(0, 0)

func _ready() -> void:
	%Letter.text = LETTER
	%Value.text = str(VALUE)
	TILE_SIZE = %CollisionShape2D.shape.size.x

func _process(delta: float) -> void:
	set_is_moving()
	update_position(delta)

func set_tile_letter(letter: String) -> void:
	LETTER = letter

func set_value(value: int) -> void:
	VALUE = value

func set_is_moving() -> void:
	if is_moving && Input.is_action_just_released("left_click"):
		is_moving = false
		emit_signal("finished_moving", self, false)
	
	if !is_moving && Input.is_action_just_pressed("left_click") && mouse_over:
		is_moving = true

func update_position(delta: float) -> void:
	if !is_moving:
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

func _on_area_2d_mouse_entered() -> void:
	mouse_over = true

func _on_area_2d_mouse_exited() -> void:
	mouse_over = false

signal finished_moving(tile: Sprite2D, placed: bool)
