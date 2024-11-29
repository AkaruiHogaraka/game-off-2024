class_name BaseDialogueReader extends Node

signal StartDialogue()
signal EndDialogue()

@export var lines: Array[String]
@export var line_speed: Array[float]
@export var custom_writer_target: DialogueWriter
@export var skip_cooldown: float = 0.2

@onready var current_line_index: int = 0

var is_writing_line: bool
var is_force_skipping: bool

var writer: DialogueWriter

var can_input: bool

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and can_input:
		on_read_line()

func _ready() -> void:
	if custom_writer_target != null: writer = custom_writer_target
	else: writer = GlobalReference.Writer
	
	writer.StartWritingCurrentLine.connect(_on_start_writing_current_line)
	writer.EndWritingCurrentLine.connect(_on_end_writing_current_line)
	can_input = false
	
	initialise()

func initialise() -> void:
	pass

func on_read_line() -> void:
	if is_force_skipping or GlobalScene.internal_scene_change_cooldown or writer == null: return
	
	if current_line_index >= lines.size(): 
		EndDialogue.emit()
		_on_end_writing()
		return
	
	var line_chrs: PackedStringArray = lines[current_line_index].split()
	
	if current_line_index == 0: 
		StartDialogue.emit()
		_on_start_writing()
	
	if is_writing_line:
		is_force_skipping = true
		
		await writer.force_write_end_line(line_chrs)
		await get_tree().create_timer(skip_cooldown).timeout
		
		is_writing_line = false
		is_force_skipping = false
		return
	
	writer.write_line(line_chrs, line_speed[current_line_index])
	
	is_writing_line = true

func reset_dialogue() -> void:
	current_line_index = 0
	is_force_skipping = false
	is_writing_line = false
	can_input = false

func _on_start_writing() -> void:
	pass

func _on_start_writing_current_line() -> void:
	pass

func _on_end_writing() -> void:
	writer.hide_dialogue_box()

func _on_end_writing_current_line() -> void:
	is_writing_line = false
	current_line_index += 1
