extends Node2D

var dead = false
var state = "big"
var moving = false
var direction = 180
var newdirection = 180
var directionbuffer = 0 # How long Tux should attempt to turn an intersection

const MOVE_SPEED = 8
const BUFFER = 3

func _ready():
	position = Vector2(0,0)
	for child in get_tree().current_scene.get_node("Level").get_children():
		if child.is_in_group("spawnpoint"):
			position = child.position

func _process(delta):
	if UIHelpers._get_scene().editmode:
		return
	
	# Setting the direction to move
	if !moving: newdirection = null
	if Input.is_action_pressed("up"):
		newdirection = 0
	
	if Input.is_action_pressed("duck"):
		newdirection = 180
	
	if Input.is_action_pressed("move_left"):
		newdirection = -90
	
	if Input.is_action_pressed("move_right"):
		newdirection = 90
	
	var rndx = (floor(position.x / 32) * 32) + 16
	var rndy = (floor(position.y / 32) * 32) + 16
	
	# Change direction from the grid
	if position.x == rndx and position.y == rndy:
		for child in UIHelpers.get_level().get_children():
			if child.is_in_group("tilemap"):
				var playerpos = child.world_to_map(UIHelpers.get_player().position)
				var tile_id = child.get_cellv(playerpos)
				if tile_id != null and tile_id != -1:
					var tile_name = child.get_tileset().tile_get_name(tile_id)
					
					if tile_name == "Pathing":
						var tile_pos = child.get_cell_autotile_coord(playerpos.x, playerpos.y)
						var bitmask = child.get_tileset().autotile_get_bitmask(tile_id, tile_pos)
						var up_tiles = [186, 146, 18, 58, 178, 154, 50, 26]
						var down_tiles = [186, 146, 176, 152, 184, 178, 154, 144]
						var left_tiles = [186, 56, 152, 26, 154, 58, 184, 24]
						var right_tiles = [186, 56, 178, 58, 184, 48, 50, 176]
						
						# Move regularly
						if newdirection == 0 and bitmask in up_tiles:
							moving = true
							direction = newdirection
							directionbuffer = BUFFER
						elif newdirection == 180 and bitmask in down_tiles:
							moving = true
							direction = newdirection
							directionbuffer = BUFFER
						elif newdirection == 90 and bitmask in right_tiles:
							moving = true
							direction = newdirection
							directionbuffer = BUFFER
						elif newdirection == -90 and bitmask in left_tiles:
							moving = true
							direction = newdirection
							directionbuffer = BUFFER
						else:
							directionbuffer -= 1
							if directionbuffer <= 0:
								newdirection = null
								directionbuffer = 0
						
						# Turn on corner tiles
						if bitmask == 176: # Bottom Right
							if direction == 0:
								direction = 90
								newdirection = direction
							if direction == -90:
								direction = 180
								newdirection = direction
						elif bitmask == 152: # Bottom Left
							if direction == 0:
								direction = -90
								newdirection = direction
							if direction == 90:
								direction = 180
								newdirection = direction
						elif bitmask == 50: # Top Right
							if direction == -90:
								direction = 0
								newdirection = direction
							if direction == 180:
								direction = 90
								newdirection = direction
						elif bitmask == 26: # Top Left
							if direction == 90:
								direction = 0
								newdirection = direction
							if direction == 180:
								direction = -90
								newdirection = direction
						
						# Stop at edges
						if direction == 0 and not bitmask in up_tiles:
							moving = false
						if direction == 180 and not bitmask in down_tiles:
							moving = false
						if direction == 90 and not bitmask in right_tiles:
							moving = false
						if direction == -90 and not bitmask in left_tiles:
							moving = false
	
	if moving:
		position += Vector2(MOVE_SPEED, 0).rotated(deg2rad(direction - 90))