extends Area2D

signal hit
signal graze

@export var run_speed = 400 # How fast the player will move (pixels/sec).
@export var walk_speed = 200
var screen_size # Size of the game window.
var graze_points = 0
#var is_host: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = str(get_multiplayer_authority())
	screen_size = get_viewport_rect().size
	var label = $Label
	
	#label.text = "Host" if is_host else "Cliente"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
		
	var velocity = Vector2.ZERO 
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
	remote_set_position.rpc(global_position)
	if velocity.x != 0:
		$"Sprite".animation = "walk"
		$"Sprite".flip_v = false
		$"Sprite".flip_h = velocity.x < 0
	elif velocity.y != 0:
		$"Sprite".animation = "up"
		$"Sprite".flip_v = velocity.y > 0

@rpc("unreliable")
func remote_set_position(authority_position):
	global_position = authority_position

@rpc("any_peer", "call_local", "reliable")
func display_message(msg):
	$message.text = msg;

func set_Label(name):
	$Label.text = name
