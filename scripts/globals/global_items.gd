extends Node

var has_lantern: bool = false
var require_lantern: bool = false
var dream_gems: int = 0
var gems: int = 0

func reset_items() -> void:
	dream_gems = 0
	gems = 0
	require_lantern = false
	has_lantern = false
	GlobalScene.is_holding_lantern = false
