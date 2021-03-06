extends KinematicBody2D

# Basic Rigidbody-like Box Movement

# Main Variables
var velocity = Vector2()
var dir = 0

# Constants
const UP = Vector2(0, -1)
export var MAX_SPEED = 200
export var ACCELERATION = 10
export var JUMP_HEIGHT = 400
export var DUCK_HEIGHT = 16
export var DASH_LENGTH = 750
export var DASH_SPEED = 0.2
export var GRAVITY = 20
export var FRICTION = 99

var can_dash = true
var is_dashing = false
var dash_direction = Vector2()

export(PackedScene) var dash_object

var is_crouching = false

var discord: Discord.Core
var activities: Discord.ActivityManager

var finish = preload("res://Objects/Finish.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_auto_accept_quit(false)
	# reset player died bool
	$dash_timer.connect("timeout",self,"dash_timer_timeout")
	globals.game_started = true
	globals.player_died = false
	globals.game_finished = false
	globals.death_reason = 0
	$DicordTimer.connect("timeout",self,"discord_integ")
	$DicordTimer.start(0.5)
	pass # Replace with function body.
	
func dash_timer_timeout():
	is_dashing = false
	
func _exit_tree():
	discord = null
	
func discord_integ():
	if discord == null:
		discord = Discord.Core.new()

		var result: int = discord.create(
			904639293765586955,
			Discord.CreateFlags.NO_REQUIRE_DISCORD
		)

		if result != Discord.Result.OK:
			print("Failed to initialise SDK: ", result)
			get_tree().quit()
			discord = null
			return

		activities = discord.get_activity_manager()

		var activity := Discord.Activity.new()
		activity.details = "Playing Box"
		activity.state = "Level " + str(globals.cur_level)
		activity.assets.large_image = "box"
		activity.assets.large_text = "True!"
		activities.update_activity(activity, self, "_update_activity_callback")
	pass
	
func _update_activity_callback(result: int) -> void:
	if globals.game_started and discord != null:
		if result != Discord.Result.OK:
			print("Failed to update activity: ", result)
			return

		print("Updated activity!")
	
func _process(delta):
	if Input.is_action_just_pressed("debug"):
		var f = finish.instance()
		f.position = position + 100 * Vector2.UP
		get_parent().add_child(f)
		f.next_level = globals.cur_level + 1
	print(Engine.get_frames_per_second())
	if discord != null and not globals.player_died:
		var result: int = discord.run_callbacks()
		if result != Discord.Result.OK:
			print("Failed to run callbacks: ", result)
			get_tree().quit()
			discord = null
			activities = null
			
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		globals.player_died = true
		get_tree().quit()
	pass

func _physics_process(delta):
	
	if not globals.player_died or globals.death_reason == 1:
		globals.velocity = velocity
		
		# Have gravity.
		if not globals.game_finished:
			velocity.y += GRAVITY
		else:
			velocity.y = 0
			velocity.x = 0
		var is_friction = false
		
		# Movement.
		if Input.is_action_pressed('ui_right'):
			if not globals.player_died:
				dir = 1
				velocity.x = max(velocity.x+ACCELERATION, MAX_SPEED)
			else:
				velocity.x = 0
		elif Input.is_action_pressed('ui_left'):
			if not globals.player_died:
				dir = -1
				velocity.x = min(velocity.x-ACCELERATION, -MAX_SPEED)
			else:
				velocity.x = 0
		else:
			dir = 0
			is_friction = true
			
		if Input.is_action_just_pressed("reset"):
			globals.player_died = true
			var left = Vector2(-2, 0)
			Transitions.slide_rect2(self, '', 2, Color.black, left)
			
		if Input.is_action_pressed("ui_down"):
			is_friction = true
			is_crouching = true
			scale.x = lerp(scale.x, 1.5, .3)
			scale.y = lerp(scale.y, 0.5, .3)
		elif Input.is_action_just_released("ui_down"):
			if dir != 0:
				is_friction = true
			is_crouching = false
			
		var collision = test_move(transform, velocity * delta)
		if floor_check(delta) and not globals.player_died:
			can_dash = true
			
		if floor_check(delta) and not globals.player_died:
			var current_rotate = modulo(rad2deg($Sprite/SpriteChild.rotation), 360)
			var current_right_rotate = modulo(current_rotate, 90)

			var diff = current_rotate - current_right_rotate
			var new_rotation = diff + 90

			if not round(current_rotate) == diff:
				$Sprite/SpriteChild.rotation = deg2rad(new_rotation)
				
			if Input.is_action_pressed('ui_up'):
				$JumpSound.play()
				if  not wall_check():
					$Sprite.scale = Vector2(0.5,1.5)
				velocity.y = -JUMP_HEIGHT
			if is_friction:
				velocity.x = lerp(velocity.x, 0, .1)
		else:
			if (not wall_check() or velocity.y < 50) and not is_crouching:
				$Sprite/SpriteChild.rotation_degrees += 5
			else:
				var current_rotate = modulo(rad2deg($Sprite/SpriteChild.rotation), 360)
				var current_right_rotate = modulo(current_rotate, 90)

				var diff = current_rotate - current_right_rotate
				var new_rotation = diff + 90

				if not round(current_rotate) == diff:
					$Sprite/SpriteChild.rotation = deg2rad(new_rotation)
			if is_friction:
				velocity.x = lerp(velocity.x, 0, .1)
				
		if wall_check() and velocity.y > 50 and not globals.player_died:
			velocity.y = 50
				
		# print(is_dashing)
		
		handle_dash(delta)
			
		# Final movement.
		if (!is_dashing):
			velocity = move_and_slide(velocity, UP)
		else:
			velocity = move_and_slide(dash_direction,UP)
		# test_move(transform, velocity)
		pass
		
		apply_squash_squeeze()
	else:
		velocity = Vector2()
		move_and_slide(Vector2())

func wall_check():
	# print($WallCheck1.is_colliding())
	return $WallCheck1.is_colliding() or $WallCheck2.is_colliding()
	pass

func modulo(v, m):
	return int(v) % m
	
func get_direction_from_input():
	var move_dir = Vector2()
	move_dir.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
	move_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		
	move_dir = move_dir.clamped(1)
	
	#check if no movement is pressed further enough... then dash towards ur facing position
	if (move_dir == Vector2(0,0)):
		move_dir.x = dir
			
	return move_dir * DASH_LENGTH
	
func floor_check(delta):
	var collision = test_move(transform, velocity * delta)
	return velocity.y >= UP.y and collision
	pass
	
func handle_dash(var delta):
	if(Input.is_action_pressed("dash") and can_dash and !floor_check(delta)):
		if not is_dashing:
			$DashSound.play()
		is_dashing = true
		can_dash = false
		dash_direction = get_direction_from_input()
		$dash_timer.start(DASH_SPEED)
	
	if(is_dashing):
		var dash_node = dash_object.instance()
		dash_node.texture = $Sprite/SpriteChild.texture
		dash_node.global_position = global_position
		dash_node.rotation = $Sprite/SpriteChild.rotation
		get_parent().add_child(dash_node)
		
		var collision = move_and_collide(velocity * delta * 2)
		
		if(collision):
			is_dashing = false
		if(is_on_wall()):
			is_dashing = false
		if(is_on_floor()):
			is_dashing = false
		if(is_on_ceiling()):
			is_dashing = false
		pass

func _on_ground_land(body):
	var rot = 0
	if body.name != 'Player':
		if not is_crouching and scale.x < 1.5:
			$Sprite.scale = Vector2(1.5, 0.5)
	pass # Replace with function body.

func apply_squash_squeeze():
	if not globals.game_finished:
		$Sprite.scale.x = lerp($Sprite.scale.x,1,0.2)
		$Sprite.scale.y = lerp($Sprite.scale.y,1,0.2)
	if not is_crouching:
		scale.x = lerp(scale.x,1,0.2)
		scale.y = lerp(scale.y,1,0.2)
