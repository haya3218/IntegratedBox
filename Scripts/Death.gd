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
				var deathsound = AudioStreamPlayer2D.new()
				add_child(deathsound)
				deathsound.max_distance = 99999
				deathsound.stream = CorrectSound
				deathsound.play()
			globals.player_died = true
			var left = Vector2(-2, 0)
			Transitions.slide_rect2(self, '', 2, Color.black, left)
	pass
