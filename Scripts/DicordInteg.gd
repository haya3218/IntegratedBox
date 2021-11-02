extends VBoxContainer

var discord: Discord.Core
var activities: Discord.ActivityManager


func _ready() -> void:
	if globals.game_started:
		if discord == null:
			discord = Discord.Core.new()

		var result: int = discord.create(
			904639293765586955,
			Discord.CreateFlags.NO_REQUIRE_DISCORD
		)

		if result != Discord.Result.OK:
			print("Failed to initialise SDK: ", result)
			discord = null
			return

		activities = discord.get_activity_manager()


		var activity := Discord.Activity.new()
		activity.details = "Playing Box"
		activity.state = "Trolling"
		activity.assets.large_image = "box"
		activity.assets.large_text = "True!"
		activities.update_activity(activity, self, "_update_activity_callback")


func _update_activity_callback(result: int) -> void:
	if globals.game_started:
		if result != Discord.Result.OK:
			print("Failed to update activity: ", result)
			return

		print("Updated activity!")


func _process(_delta: float) -> void:
	if discord and globals.game_started:
		var result: int = discord.run_callbacks()
		if result != Discord.Result.OK:
			print("Failed to run callbacks: ", result)
			discord = null
			activities = null
