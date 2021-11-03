extends Area2D

var CorrectSound = preload("res://Sounds/death.wav")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == 'Player':
			if not globals.player_died:
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
				rigid_body.blocks_impulse = 10
				rigid_body.explosion_delay = true
				
				print(rigid_body)

				node.add_child(rigid_body, true)
			globals.player_died = true
			var left = Vector2(-2, 0)
			Transitions.slide_rect2(self, '', 2.5, Color.black, left)
	pass
