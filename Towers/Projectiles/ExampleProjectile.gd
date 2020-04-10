extends Area2D

var speed = 250

func _physics_process(delta):
	var velocity = Vector2(speed * delta,0)
	position += velocity.rotated(rotation)
	
func start(_pos, _target):
	position = _pos
	rotation = Vector2(1,0).angle_to((_target.position - _pos).normalized())