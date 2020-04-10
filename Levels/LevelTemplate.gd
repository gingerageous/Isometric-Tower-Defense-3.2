extends Node2D

# Game State variables
var build_mode = false

# Build Mode Variables
var yellow = Color(0.87451, 0.8, 0.094118, 0.576471)
var red = Color(0.87594, 0.092384, 0.092384, 0.576471)
var current_color 
var can_build = false
var in_menu = false
var current_tile = Vector2()

# Build Mode Texures
var UI_red_tower = preload("res://Towers/Assets/towerRound_sampleC_W.png")
var UI_purple_tower = preload("res://Towers/Assets/towerSquare_sampleE_E.png")
var UI_tower_list = {	"Red_Tower" : UI_red_tower,
						"Purple_Tower" : UI_purple_tower}
						
var attack_ranges = {	"Red_Tower" : 5,
						"Purple_Tower" : 4}

# Tower Scenes
var red_tower = preload("res://Towers/Red_Tower.tscn")
var purple_tower = preload("res://Towers/Purple_Tower.tscn")
var tower_list = {	"Red_Tower" : red_tower,
					"Purple_Tower" : purple_tower}
var current_tower


# Tile Map variables
var map_size = 32  #Hypotenuse from top left to bottom right
onready var Map = $MapTemplate
var num_of_crystals = 5
var crystal_tiles_array = range(26,30,1)
var num_of_rocks = 15
var rock_tiles_array = range(18,26, 1)
var num_of_trees = 10
var tree_tiles_array = range(30, 35, 1)


# Tile map custom autotiles variables
const N = 1
const E = 2
const S = 4
const W = 8

var road_connections = {Vector2(0,-1): N, Vector2(1,0): E,
						Vector2(0,1): S, Vector2(-1,0): W}

# Astar variables
var astar = AStar.new()
const top_margin = 4
const bottom_margin = 5
var starting_point
var ending_point
var final_path
var num_of_astar_obstacles = 5
var size_of_astar_obstacles = 5

# Path Variables
var enemy_curve

# Enemy scenes
var basic_enemy = preload("res://Enemies/Type/EnemyTemplate.tscn")


func _ready():
	Globals.main_game_node = self
	randomize()
	create_map(map_size)

func _physics_process(delta):
	#Debug
	if Input.is_action_just_pressed("ui_accept"):
		var mouse_pos = Map.world_to_map(get_global_mouse_position())
		print(astar.get_point_connections(astar.get_closest_point(Vector3(mouse_pos.x, mouse_pos.y, 0))))
		print(astar.get_closest_point(Vector3(mouse_pos.x, mouse_pos.y, 0)))
	
	if Input.is_action_just_pressed("ui_down"):
		get_tree().reload_current_scene()
		
	$UI/FPS.text = str(Performance.get_monitor(Performance.TIME_FPS))
		
	if Input.is_action_just_pressed("frenzy"):
		for node in get_tree().get_nodes_in_group("frenzy"):
			node.frenzy_mode()
	###############
	if build_mode:
		_update_build_tool()
		if Input.is_action_just_pressed("action"):
			build_tower()
			
		if Input.is_action_just_pressed("ui_cancel"):
			build_mode = false
			$Build_Tool.hide()
			
	


# Create map builds the map by making a rectangle
# Starting with the hypotenuse of a right triangle
# Then adding line by line to the right triangle from the hypotenuse to the right angle
# Then it mirrors the action to make a rectangle (except at the hypotenuse (as to not repeat actions))
# Astar is added along the way

func create_map(hypotenuse):
	# Set all background to Green
	# Iteration through left leg of bottom triangle
	# I want x.5 to round up
	var height = hypotenuse / 2
	for y in height:
		# Distance to other leg (in tiles), I want to take 2 off each time through the loop
		var length = hypotenuse - (2 * y)
		# fill triangle line by line from the hypotenuse then mirror if not 0 as to not do the same thing twice
		for x in length:
			Map.set_cell(x + y, y, 15)
			if y != 0:
				Map.set_cell(x + y, -y, 15)
				
			# Add and connect points to astar excluding a border/margin
			if x >= top_margin and x <= (length - bottom_margin):
				var current_id = astar.get_available_point_id()
				astar.add_point(current_id, Vector3(x + y, y, 0))
				# exclude the first in the row so it doesn't connect to the far side of the map
				# connect to previous point as we move across the hypotonuse
				if x > top_margin:
					astar.connect_points(current_id, astar.get_closest_point(Vector3(x + y - 1, y, 0)))

				if y !=0:
					# connect lines toward the hypotenuse
					astar.connect_points(current_id, astar.get_closest_point(Vector3(x + y, y - 1, 0)))
					# build and connect the mirror side of the map
					current_id = astar.get_available_point_id()
					astar.add_point(current_id, Vector3(x + y, -y, 0))
					# connect toward hypotenuse
					astar.connect_points(current_id, astar.get_closest_point(Vector3(x + y, -y + 1, 0)))
					# connect parallel to hypotenuse
					if x > top_margin:
						astar.connect_points(current_id, astar.get_closest_point(Vector3(x + y - 1, -y, 0)))

	# Pick Starting point and ending point
	# Picks random number then finds how that correlates to starting left side and ending right side
	var starting_point_offset = (randi() % (height - (top_margin + bottom_margin))) + top_margin
	var ending_point_offset = (randi() % (height - (top_margin + bottom_margin))) + top_margin

	# for testing
#	starting_point_offset = 5
#	ending_point_offset = 5

	starting_point = Vector2(starting_point_offset, starting_point_offset)
	# Minus one to compensate for the losing 1 to the for loop earlier
	ending_point = Vector2((hypotenuse-1) - ending_point_offset, -ending_point_offset)
	##########
	Map.set_cellv(starting_point, 17)
	Map.set_cellv(ending_point, 17)

	# Make Path from starting point to ending point
	var starting_id = astar.get_closest_point(Vector3(starting_point.x, starting_point.y, 0))
	var ending_id = astar.get_closest_point(Vector3(ending_point.x, ending_point.y, 0))
#	var current_path = astar.get_point_path(starting_id, ending_id)
	
	# Add Weight/obstacles to Astar to make the path more interesting
	for num in range(num_of_astar_obstacles):
		var current_path = astar.get_point_path(starting_id, ending_id)
		# partition path so all the obstacles don't clump in the same area of the path
		var current_path_section_length = int(round(current_path.size()/(num_of_astar_obstacles)))
		# attempt to space out the obstacles more
		var point_in_section = (randi() % (current_path_section_length - (current_path_section_length/2))) + (current_path_section_length / 4)
		var current_obstacle_point = ((num) * current_path_section_length) + point_in_section
		
		# add a buffer so the obstacle isn't the first or last point of the path
		if num == 0 and current_obstacle_point < 3:
			current_obstacle_point = 3
		if num == num_of_astar_obstacles and current_obstacle_point > (current_path.size() - 3):
			current_obstacle_point = current_path.size() - 3
	
	
		var point_to_change_weight = current_path[current_obstacle_point]
		
		
		# Make a vertical Line barrier for astar to path around
		for size in range(size_of_astar_obstacles):
			for tile in [-size, size]:
				var current_tile_id = astar.get_closest_point(point_to_change_weight + Vector3(tile, tile, 0))
				astar.set_point_weight_scale(current_tile_id, 500)
#	For Debugging to see where the astar obstacles are
#				Map.set_cellv(Vector2(point_to_change_weight.x + tile, point_to_change_weight.y + tile), 16)
			
	final_path = astar.get_point_path(starting_id, ending_id)
	
	
	# For Testing
	for tile in final_path:
		Map.set_cell(tile.x, tile.y, 17)
		yield(get_tree(),"idle_frame")
		

	for tile in final_path:
		var current_tile = N|E|S|W
		for dir in road_connections:
			if Map.get_cellv(Vector2(tile.x, tile.y) + dir) != N|E|S|W:
				# Check needed since I changed tiles for seeing astar obstacles
				if Map.get_cellv(Vector2(tile.x, tile.y) + dir) != 16:
					current_tile -= road_connections[dir]
				
		Map.set_cellv(Vector2(tile.x, tile.y), current_tile)
		
		
	# Add random pretty tiles of rocks
	var open_spaces = Map.get_used_cells_by_id(15)
	for num in num_of_rocks:
		var new_tile = rock_tiles_array[randi() % rock_tiles_array.size()]
		var pos = open_spaces[randi() % open_spaces.size()]
		Map.set_cellv(pos, new_tile)
		
	# Add random tree tiles
	for num in num_of_trees:
		var new_tile = tree_tiles_array[randi() % tree_tiles_array.size()]
		var pos = open_spaces[randi() % open_spaces.size()]
		Map.set_cellv(pos, new_tile)
		
	# Add random pretty tiles of crystals
	for num in num_of_crystals:
		var new_tile = crystal_tiles_array[randi() % crystal_tiles_array.size()]
		var pos = open_spaces[randi() % open_spaces.size()]
		Map.set_cellv(pos, new_tile)
		
##################
	spawn_enemies()
	


func spawn_enemies():
	# Make Path for the enemies to spawn on
	enemy_curve = Curve2D.new()
	for point in final_path:
		# need to convert from cartesian to isometric then scale to the size of tile map
		enemy_curve.add_point(Vector2((point.x - point.y) * 64, ((point.x + point.y) / 2) * 64))
		
		
	$Routes/First_Path.curve = enemy_curve
		
	var num_of_enemies = 3
	for num in num_of_enemies:
		# add enemy scene into a y sort container
		var enemy = basic_enemy.instance()
		$EnemyContainer.add_child(enemy)
		var enemy_node_path = enemy.get_path()
		# add path_follow with remote transform
		var new_path_follow = PathFollow2D.new()
		new_path_follow.rotate = false
		var remote_transform = RemoteTransform2D.new()
		remote_transform.remote_path = enemy_node_path
		new_path_follow.add_child(remote_transform)
		$Routes/First_Path.add_child(new_path_follow)

		var positioning_node_path = get_node(new_path_follow.get_path())

		# Give enemy scene the info for how to adjust the remote transform
		enemy.positioning_node = positioning_node_path

		yield(get_tree().create_timer(0.5),"timeout")
		
		
func _update_build_tool():
	var mouse_pos = get_global_mouse_position()
	current_tile = Map.world_to_map(mouse_pos)
	$Build_Tool.position = Map.map_to_world(current_tile)
	
	if Map.get_cellv(current_tile) == 15 and current_color != yellow:
		current_color = yellow
		can_build = true
		$Build_Tool/BuildInterface.material.set_shader_param("current_color", current_color)
		$Build_Tool/AttackRange.color = current_color
		
	if Map.get_cellv(current_tile) != 15 and current_color != red:
		current_color = red
		can_build = false
		$Build_Tool/BuildInterface.material.set_shader_param("current_color", current_color)
		$Build_Tool/AttackRange.color = current_color
		
func build_tower():
	if can_build and not in_menu:
		Map.set_cellv(current_tile, 16)
		var new_tower = current_tower.instance()
		new_tower.global_position = Map.map_to_world(current_tile)
		$TowerContainer.add_child(new_tower)
		
func _on_Select_Tower_button_down(tower):
	current_tower = tower_list[tower]
	$Build_Tool/BuildInterface.texture = UI_tower_list[tower]
	$Build_Tool/AttackRange.polygon = get_attack_range_shape(attack_ranges[tower])
	build_mode = true
	$Build_Tool.show()
	
# returns array of points for a polygon
func get_attack_range_shape(attack_range):
	var points = []
	points.append(Vector2(0, -32 - (attack_range * 64)))
	points.append(Vector2(64 + (attack_range * 128), 0))
	points.append(Vector2(0, 32 + (attack_range * 64)))
	points.append(Vector2(-64 - (attack_range * 128), 0))
	return points

func spawn_projectile(_projectile, _pos, _target):
	var projectile = _projectile.instance()
	$ProjectileContainer.add_child(projectile)
	projectile.start(_pos, _target)

func _on_Tower_Button_mouse_entered():
	in_menu = true

func _on_Tower_Button_mouse_exited():
	in_menu = false
