extends Camera2D

@export var move_speed: float = 400.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.3
@export var max_zoom: float = 3.0

var _dragging: bool = false
var _drag_start: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	_handle_movement(delta)

func _handle_movement(delta: float) -> void:
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1

	position += direction * move_speed * delta

func _unhandled_input(event: InputEvent) -> void:
	_handle_zoom(event)
	_handle_drag(event)

func _handle_zoom(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom = clamp(zoom + Vector2(zoom_speed, zoom_speed), Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom = clamp(zoom - Vector2(zoom_speed, zoom_speed), Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func _handle_drag(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				_dragging = true
				_drag_start = event.position  # store where the mouse started
			else:
				_dragging = false

	if event is InputEventMouseMotion and _dragging:
		# move camera opposite to mouse direction, divided by zoom so speed feels consistent
		position -= event.relative / zoom
