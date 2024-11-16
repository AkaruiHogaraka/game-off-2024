extends Node

var CurrentPrioritySFX: Array[AudioStreamPlayer]
var CurrentSFX: Array[AudioStreamPlayer]

func play_sfx(sfx: AudioStreamPlayer, priority: bool = false) -> void:
	var new_sfx: AudioStreamPlayer = sfx.duplicate()
	
	if priority:
		CurrentPrioritySFX.append(new_sfx)
		for mod_sfx in CurrentSFX:
			mod_sfx.set_volume_db(mod_sfx.get_volume_db() - 10.0)
	else:
		CurrentSFX.append(new_sfx)
		if not CurrentPrioritySFX.is_empty():
			new_sfx.set_volume_db(new_sfx.get_volume_db() - 10.0)
	
	add_child(new_sfx)
	new_sfx.play()
	
	await new_sfx.finished
	
	stop_sfx(new_sfx, priority)

func stop_sfx(sfx: AudioStreamPlayer, priority: bool = false) -> void:
	for child in get_children():
		if child == sfx:
			child.queue_free()
			if priority: 
				CurrentPrioritySFX.erase(child)
			else:
				CurrentSFX.erase(child)
