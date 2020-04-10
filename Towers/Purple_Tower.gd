extends "res://Towers/TowerTemplate.gd"

export var num_of_frenzy_shots = 250
onready var frenzy_target = $FrenzyPivot/FrenzyModeTarget
onready var frenzy_pivot = $FrenzyPivot
var frenzy_mode = false


func frenzy_mode():
	$ReloadTimer.stop()
	can_shoot = false
	frenzy_mode = true
	
	for shot in num_of_frenzy_shots:
		var pos = $Node2D/ProjectileSpawn.global_position
		emit_signal("shoot", projectile, pos, frenzy_target)
		frenzy_pivot.rotation += 2*PI / 180
		yield(get_tree().create_timer(.002), "timeout")
		
	frenzy_mode = false
	$ReloadTimer.start()
		

func _on_TextureButton_button_down():
	if not frenzy_mode:
		frenzy_mode()
	
