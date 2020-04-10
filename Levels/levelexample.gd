extends Node2D

const top_margin = 2
const bottom_margin = 3
var starting_point
var ending_point
var current_path
onready var Map = $MapTemplate
var astar = AStar.new()


func _ready():
	create_map(26)

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		var mouse_pos = Map.world_to_map(get_global_mouse_position())
		print(astar.get_point_connections(astar.get_closest_point(Vector3(mouse_pos.x, mouse_pos.y, 0))))
		print(astar.get_closest_point(Vector3(mouse_pos.x, mouse_pos.y, 0)))

# Create map builds the map by making a rectangle
# Starting with the hypotenuse of a right triangle
# Then adding line by line to the right triangle from the hypotenuse to the right angle
# Then it mirrors the action to make a rectangle (except at the hypotenuse (as to not repeat actions))
# Astar is added along the way

func create_map(hypotenuse):
	# Set all background to Green
	# Iteration through left leg of bottom triangle
	# I want x.5 to round up
	var height = int(round(float(hypotenuse)/2.0))
	for y in height:
		# Distance to other leg (in tiles), I want to take 2 off each time through the loop
		var length = hypotenuse - (2 * y)
		# fill triangle line by line from the hypotenuse then mirror if not 0 as to not do the same thing twice
		for x in length:
			Map.set_cell(x, y, 15)
#			if y != 0:
#				Map.set_cell(x + y, -y, 15)
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
					astar.connect_points(current_id, astar.get_closest_point(Vector3(x + y, -y + 1, 0)))
					if x < (length - bottom_margin):
						astar.connect_points(current_id, astar.get_closest_point(Vector3(x + y - 1, -y, 0)))

	# Pick Starting point and ending point
	# Picks random number then finds how that correlates to starting left side and ending right side
	var starting_point_offset = (randi() % (height - (top_margin + bottom_margin))) + top_margin
	var ending_point_offset = (randi() % (height - (top_margin + bottom_margin))) + top_margin

	starting_point_offset = 5
	ending_point_offset = 5

	var starting_point = Vector2(starting_point_offset, starting_point_offset)
	# Minus one to compensate for the losing 1 to the for loop earlier
	var ending_point = Vector2((hypotenuse-1) - ending_point_offset, -ending_point_offset)

	Map.set_cellv(starting_point, 5)
	Map.set_cellv(ending_point, 6)


	# Make Path from starting point to ending point
	var starting_id = astar.get_closest_point(Vector3(starting_point.x, starting_point.y, 0))
	var ending_id = astar.get_closest_point(Vector3(ending_point.x, ending_point.y, 0))

	current_path = astar.get_point_path(starting_id, ending_id)
	print(current_path)
	for tile in current_path:
		Map.set_cell(tile.x, tile.y, 5)
		yield(get_tree(),"idle_frame")

