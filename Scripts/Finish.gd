extends Area2D

export var next_level = 2
	
func _physics_process(delta):
	rotation += 5 * delta
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.get_name() == 'Player':
			body.get_node(@"Sprite").scale.x = lerp(body.get_node(@"Sprite").scale.x, 1.5, body.get_node(@"Sprite").scale.x/2)
			body.get_node(@"Sprite").scale.y = lerp(body.get_node(@"Sprite").scale.y, 0, .8)
			if not globals.game_finished:
				$Sound.play()
				var left = Vector2(-2, 0)
				Transitions.slide_rect2(self, 'res://Levels/Level'+ str(next_level) + '.tscn', 2, Color.black, left)
				globals.cur_level = next_level
			globals.game_finished = true
	pass
