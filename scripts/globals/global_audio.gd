extends Node

var CurrentSFX: Array[AudioStreamPlayer]

func play_sfx(sfx: AudioStreamPlayer) -> void:
	var new_sfx: AudioStreamPlayer = sfx.duplicate()
	CurrentSFX.append(new_sfx)
	add_child(new_sfx)
	
	new_sfx.play()
	
	await new_sfx.finished
	
	stop_sfx(new_sfx)

func stop_sfx(sfx: AudioStreamPlayer) -> void:
	if CurrentSFX.has(sfx):
		var index: int = CurrentSFX.find(sfx)
		CurrentSFX[index].queue_free()
		CurrentSFX.remove_at(index)
