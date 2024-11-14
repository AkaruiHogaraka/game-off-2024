class_name BaseDialogueReader extends Node

@export var lines: Array[String]
@export var line_speed: Array[float]
@export var custom_writer_target: DialogueWriter

@onready var current_line_index: int = 0

var is_writing_line: bool
var is_force_skipping: bool

var writer: DialogueWriter

func _ready() -> void:
	if custom_writer_target != null: writer = custom_writer_target
	else: writer = GlobalReference.Writer
	
	writer.StartWritingCurrentLine.connect(_on_start_writing_current_line)
	writer.EndWritingCurrentLine.connect(_on_end_writing_current_line)
	
	initialise()

func initialise() -> void:
	pass

func on_read_line() -> void:
	if is_force_skipping: return
	
	if current_line_index >= lines.size(): 
		_on_end_writing()
		is_force_skipping = true
		return
	
	var line_chrs: PackedStringArray = lines[current_line_index].split()
	
	if current_line_index == 0: _on_start_writing()
	
	if is_writing_line:
		is_force_skipping = true
		
		await writer.force_write_end_line(line_chrs)
		
		is_writing_line = false
		is_force_skipping = false
		return
	
	writer.write_line(line_chrs, line_speed[current_line_index])
	
	is_writing_line = true

func _on_start_writing() -> void:
	pass

func _on_start_writing_current_line() -> void:
	pass

func _on_end_writing() -> void:
	pass

func _on_end_writing_current_line() -> void:
	pass
