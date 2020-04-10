extends KinematicBody2D

# A remote transform2d 
var positioning_node

var speed = 150
var target_offset = Vector2(0, -50)

func _physics_process(delta):

		
	if get_parent().is_class("PathFollow2D"):
		get_parent().offset += speed * delta
		
		
		

	if positioning_node:
		positioning_node.offset += speed * delta
		
		
		
		
		
