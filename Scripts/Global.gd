extends Node

var player_died = false
var game_started = false
var game_finished = false
var velocity = Vector2()
var cur_level = 1
var death_reason = 0

static func modulo(v, m):
	return int(v) % m
