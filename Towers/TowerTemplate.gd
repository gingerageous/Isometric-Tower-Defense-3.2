tool
extends Node2D

signal shoot

export (int) var attack_range = 3 setget set_attack_range
export (PackedScene) var projectile

var target_list = []
var can_shoot = true

func _ready():
	connect("shoot", Globals.main_game_node, "spawn_projectile")
	
func _physics_process(delta):
	if target_list and can_shoot:
		shoot()


func set_attack_range(num):
	attack_range = num
	var new_shape = ConvexPolygonShape2D.new()
	new_shape.points = get_attack_range_shape(num)
	if $AttackRange/CollisionShape2D:
		$AttackRange/CollisionShape2D.shape = new_shape
		

func get_attack_range_shape(attack_range):
	var points = []
	points.append(Vector2(0, -32 - (attack_range * 64)))
	points.append(Vector2(64 + (attack_range * 128), 0))
	points.append(Vector2(0, 32 + (attack_range * 64)))
	points.append(Vector2(-64 - (attack_range * 128), 0))
	return points

func shoot():
	can_shoot = false
	$ReloadTimer.start()
	var pos = $Node2D/ProjectileSpawn.global_position
	var target = target_list[0]
	emit_signal("shoot", projectile, pos, target)
	
	
	

func _on_ReloadTimer_timeout():
	can_shoot = true


func _on_AttackRange_body_entered(body):
	target_list.append(body)

func _on_AttackRange_body_exited(body):
	if target_list.has(body):
		target_list.erase(body)
	
