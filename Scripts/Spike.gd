extends Area2D

var CorrectSound = preload("res://Sounds/death.wav")
var explod = preload("res://Sounds/explod.wav")
onready var explos = preload("res://Objects/Explosion.tscn")

var honor = false
var last_position = Vector2()

func _ready():
	last_position = Vector2()
	honor = false
	$Timer.connect("timeout",self,"shit")
	$Timer2.connect("timeout",self,"shit2")
	pass
	
func shit():
	honor = false
	
func shit2():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == 'Player':
			body.get_node(@"CollisionShape2D").queue_free()
	
func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == 'Player':
			if not globals.player_died:
				$Timer2.start(0.15)
				body.modulate.a = 0
				var deathsound = AudioStreamPlayer2D.new()
				add_child(deathsound)
				deathsound.max_distance = 99999
				deathsound.stream = CorrectSound
				deathsound.play()
				var node = Node2D.new()
				node.name = "destructible_container"
				get_parent().add_child(node, true)

				var rigid_body = RigidBody2D.new()
				rigid_body.name = "destructible_object"
				rigid_body.global_position = body.global_position

				var sprite = Sprite.new()
				# Set the sprite's texture, size, etc.
				sprite.texture = preload("res://Sprites/player.png")
				sprite.rotation = body.rotation

				var collision = CollisionShape2D.new()
				collision.shape = RectangleShape2D.new()
				collision.shape.extents = body.get_node(@"CollisionShape2D").shape.extents

				rigid_body.add_child(sprite, true)
				rigid_body.add_child(collision, true)

				var script = preload("res://Scripts/destroy.gd")
				rigid_body.set_script(script)

				# Here you can set the 'rigid_body' variables from the script.
				rigid_body.blocks_per_side = 2
				rigid_body.blocks_impulse = 0
				# rigid_body.explosion_delay = true
				
				var random_dir = pow(-1, randi() % 10)
				
				if random_dir == 1:
					var e = explos.instance()
					e.global_position = body.global_position
					e.get_node(@"AnimationPlayer").play('Explode')
					node.add_child(e, true)
					rigid_body.apply_impulse(Vector2(), Vector2(randf(), randf()))
					deathsound.stream = explod
					deathsound.play()
					honor = true
					$Timer.start(0.5)
				
				print(rigid_body)
				
				last_position = body.global_position
				
				globals.death_reason = 0

				node.add_child(rigid_body, true)
				var left = Vector2(-2, 0)
				Transitions.slide_rect2(self, '', 2.5, Color.black, left)
			globals.player_died = true
			# body.global_position = last_position
			
	if honor:
		for body in bodies:
			if body.name == 'Player':
				body.get_node(@"Camera2D").set_offset(Vector2( \
					rand_range(-1.0, 1.0) * 3, \
					rand_range(-1.0, 1.0) * 3 \
				))
	pass
