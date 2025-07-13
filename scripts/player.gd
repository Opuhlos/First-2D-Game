extends Area2D

signal hit
signal graze

@export var speed: float = 300
@export var debug_mode: bool = true
var screen_size
var was_grazed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide the Graze
	$Graze.hide()
		
	screen_size = get_viewport_rect().size
	
	if (debug_mode):
		pass
	else:
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
	
	# Deltarune bullet grazing
	handle_bullet_grazing()
	
func _on_body_entered(_body: Node2D) -> void:
	if (debug_mode):
		return
	hide() # Player  disappears after
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$HeartCollisionPolygon2D.set_deferred("disabled", true)

func start(pos: Vector2) -> void:
	position = pos
	show()
	$HeartCollisionPolygon2D.disabled = false

func handle_bullet_grazing() -> void:
	# Get the number of bodies currently overlapping with the bullet graze area
	var over_lapping_bodies = $Graze.get_overlapping_bodies()
	# Trigger the graze effects if there is a body in the graze area
	# and if the player was not just grazed
	if over_lapping_bodies.size() > 0 && !was_grazed:
		# Set grazed to true
		was_grazed = true
		
		# Show the graze area and play the sound
		$Graze.show()
		$Graze/AudioStreamPlayer2D.play()
		
		# Add to score
		graze.emit()
		
		# Short delay before hiding the graze area and set the
		# recently grazed variable to false
		await get_tree().create_timer(0.5 / over_lapping_bodies.size()).timeout # shorten the graze delay if there are multiple bodies in the graze area
		was_grazed = false
		$Graze.hide()
