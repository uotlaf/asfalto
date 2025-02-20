extends AnimatedSprite2D
var initial_y
var speed = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_y = position.y
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += speed * delta
	if position.y == 0:
		position.y = initial_y
