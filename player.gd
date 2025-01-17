extends Area2D

signal hit
signal graze

@export var run_speed = 400 # How fast the player will move (pixels/sec).
@export var walk_speed = 200
var screen_size # Size of the game window.
var graze_points = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		if (Input.is_action_pressed("walk")):
			$"Hit Sprite".show()
			velocity = velocity.normalized() * walk_speed
		else:
			$"Hit Sprite".hide()
			velocity = velocity.normalized() * run_speed
		$"Sprite".play()
	else:
		$"Sprite".stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$"Sprite".animation = "walk"
		$"Sprite".flip_v = false
		# See the note below about the following boolean assignment.
		$"Sprite".flip_h = velocity.x < 0
	elif velocity.y != 0:
		$"Sprite".animation = "up"
		$"Sprite".flip_v = velocity.y > 0
