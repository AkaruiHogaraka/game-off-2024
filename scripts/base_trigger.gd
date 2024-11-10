class_name BaseTrigger extends Node

@export var areas: Array[Area2D]

func is_all_areas_triggered() -> bool:
	for area in areas: 
		if not area.has_overlapping_bodies(): 
			return false
	return true
