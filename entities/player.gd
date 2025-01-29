extends Area2D


signal hit
signal graze
@export var is_host: bool = false
@export var run_speed = 400 # How fast the player will move (pixels/sec).
@export var walk_speed = 200
@export var bullet : PackedScene
var screen_size # Size of the game window.
var graze_points = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	name = str(get_multiplayer_authority())
	screen_size = get_viewport_rect().size
	var label = $Label
	label.text = "Host" if is_host else "Cliente"

func shoot():
	var b = bullet.instantiate()
	get_tree().root.add_child(b)
	b.transform = global_transform

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("shoot"):
		shoot()

	if velocity.length() > 0:
		if (Input.is_action_pressed("walk")):
			velocity = velocity.normalized() * walk_speed
		else:
			velocity = velocity.normalized() * run_speed
		
	if (Input.is_action_pressed("walk")):
		$"Hit Sprite".show()
	else:
		$"Hit Sprite".hide()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	$"Sprite".play()
	$"Sprite".flip_h = velocity.x > 0
	
	rpc("remote_set_position", global_position) # atualiza sua posição para os outros jogadores

	if velocity.x != 0:
		$"Sprite".animation = "walk"
	else:
		$"Sprite".animation = "idle"




@rpc("unreliable")
func remote_set_position(authority_position):
	global_position = authority_position
