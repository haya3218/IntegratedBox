extends Area2D

export var next_level = 2

func _physics_process(delta):
	rotation += 5 * delta
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.get_name() == 'Player':
			var left = Vector2(-2, 0)
			Transitions.slide_rect2(self, 'res://Levels/Level'+ str(next_level) + '.tscn', 2, Color.black, left, true)
	pass
