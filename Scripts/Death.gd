extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == 'Player':
			if not globals.player_died:
				$DeathSound.play()
			globals.player_died = true
			var left = Vector2(-2, 0)
			Transitions.slide_rect2(self, '', 2, Color.black, left)
	pass
