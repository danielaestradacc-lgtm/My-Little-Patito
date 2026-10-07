extends Node2D

const walk_vel = 120

var speed = walk_vel
var direction = Vector2(1,1)
var screen_size = Vector2()
var window_size = Vector2(200,200)

var idle_timer = 0.0
var is_idling = false

var is_sleeping = false

var cam_direc = 0.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D

var is_dragging = false
var drag_offset = Vector2()

func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
			if is_sleeping:
				is_sleeping = false
				speed = walk_vel
				animated_sprite.play("caminar")
		else:
			is_dragging = false
		
		
func cambiar_random_direc():
	var dirs = [-1,1]
	direction = Vector2(dirs.pick_random(), dirs.pick_random())
	if direction.x != 0:
		animated_sprite.flip_h = direction.x < 0
		
	cam_direc = randf_range(4.0,7.0)

func maybe_idle():
	var num = randf()
	if num < 0.3:
		if num < 0.05:
			is_sleeping = true
			animated_sprite.play("domir")
		else:
			is_idling = true
			idle_timer = randf_range(3.0, 6.0)
			animated_sprite.play("quieto")
		speed = 0

func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size())
	DisplayServer.window_set_size(window_size)
	position = Vector2(window_size) / 2.0
	animated_sprite.play("caminar")
	area.input_event.connect(_on_area_input)
	cambiar_random_direc()

func _physics_process(delta: float) -> void:
	if is_dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		if is_sleeping:
			is_sleeping = false
			speed = walk_vel
			animated_sprite.play("caminar")
		return
	
	if is_sleeping:
		return
	
	if is_idling:
		idle_timer -= delta 
		if idle_timer <= 0:
			is_idling = false
			speed = walk_vel
			animated_sprite.play("caminar")
		return
		
	cam_direc -= delta
	if cam_direc <= 0:
		if randf() < 0.4:
			cambiar_random_direc()
		else:
			maybe_idle()
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction * speed * delta
	print(window_position)
	window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y - window_size.y)
	DisplayServer.window_set_position(Vector2i(window_position))
	
	if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x:
		direction.x *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
	if window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y:
		direction.y *= -1
