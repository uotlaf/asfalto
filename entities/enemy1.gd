extends RigidBody2D

var speed = 100
@export var bullet : PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var colors = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(colors[randi() % colors.size()])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += speed * delta

func dead():
	queue_free()
