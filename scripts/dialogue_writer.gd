class_name DialogueWriter extends Control

signal StartWritingCurrentLine()
signal EndWritingCurrentLine()

@export var base_write_time: float
@export var dialogue_label: Label
@export var continue_texture: TextureRect
@export var speak_sfx: AudioStreamPlayer

var force_skipping: bool

func _ready() -> void:
	GlobalReference.Writer = self
	hide_dialogue_box()

func force_write_end_line(chrs: PackedStringArray) -> void:
	dialogue_label.text = ""
	force_skipping = true
	
	for chr in chrs:
		dialogue_label.text += chr
	
	continue_texture.set_visible(true)
	EndWritingCurrentLine.emit()
	await get_tree().create_timer(0.2).timeout

func write_line(chrs: PackedStringArray, speed: float) -> void:
	continue_texture.set_visible(false)
	dialogue_label.set_visible(true)
	dialogue_label.text = ""
	force_skipping = false
	
	StartWritingCurrentLine.emit()
	
	for chr in chrs:
		if force_skipping: return
		dialogue_label.text += chr
		GlobalAudio.play_sfx(speak_sfx)
		await get_tree().create_timer(base_write_time * speed).timeout
	
	force_write_end_line(chrs)

func hide_dialogue_box() -> void:
	dialogue_label.set_visible(false)
	continue_texture.set_visible(false)
