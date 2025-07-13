extends Area2D

signal hit

@export var speed: float = 300
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity: Vector2 = Vector2.ZERO
	
	# Handle movement
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		
	# If the velocity's magnitude is greater than 0...
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
	# Update the player's position and prevent it from leaving the screen
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
func _on_body_entered(_body: Node2D) -> void:
	hide() # Player  disappears after
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionPolygon2D.set_deferred("disabled", true)
	
func start(pos: Vector2) -> void:
	position = pos
	show()
	$CollisionPolygon2D.disabled = false
