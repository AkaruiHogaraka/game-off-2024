class_name HeartUI extends HBoxContainer

@export var texture_one: TextureRect
@export var texture_two: TextureRect

@export var heart_full_texture: Texture
@export var heart_empty_texture: Texture
@export var heart_extra_texture: Texture

var last_texture_index: int = 0

func _ready() -> void:
	call_deferred("update_heart_display")

func reset_hearts() -> void:
	var texture: TextureRect
	
	last_texture_index = 1
	
	for i in GlobalReference.Player.starting_health:
		match last_texture_index:
			0: texture = texture_two.duplicate()
			1: texture = texture_one.duplicate()
		
		texture.set_texture(heart_full_texture)
		remove_child(get_child(get_child_count() - 1 - i))
		add_child(texture)
		
		last_texture_index += 1
		if last_texture_index > 1: last_texture_index = 0

func add_heart() -> void:
	var texture: TextureRect
	var count: int = GlobalReference.Player.current_health
	var max_default: int = GlobalReference.Player.starting_health
	var current_count: int = get_child_count() - 1
	
	if count <= max_default:
		var child = get_child(current_count - (max_default - count))
		
		if (max_default - count) % 2 == 0:
			last_texture_index += 1
			if last_texture_index > 1: last_texture_index = 0
		
		match last_texture_index:
			0: texture = texture_two.duplicate()
			1: texture = texture_one.duplicate()
		
		remove_child(child)
		child.queue_free()
		
		texture.set_texture(heart_full_texture)
		add_child(texture)
		move_child(texture, get_child_count() - 1 - (max_default - count))
		
		if (max_default - count) % 2 == 0:
			last_texture_index += 1
			if last_texture_index > 1: last_texture_index = 0
	
	if count > max_default:
		match last_texture_index:
			0: texture = texture_two.duplicate()
			1: texture = texture_one.duplicate()
		
		texture.set_texture(heart_extra_texture)
		add_child(texture)
		
		last_texture_index += 1
		if last_texture_index > 1: last_texture_index = 0

func update_heart_display() -> void:
	var count: int = GlobalReference.Player.current_health
	var max_default: int = GlobalReference.Player.starting_health
	var current_count: int = get_child_count() - 1
	
	if current_count > count:
		for i in current_count - count:
			var child = get_child(get_child_count() - 1)
			remove_child(child)
			child.queue_free()
			
			last_texture_index += 1
			if last_texture_index > 1: last_texture_index = 0
	
	var texture: TextureRect
	
	if count < max_default:
		for i in max_default - count:
			match last_texture_index:
				0: texture = texture_two.duplicate()
				1: texture = texture_one.duplicate()
			
			texture.set_texture(heart_empty_texture)
			add_child(texture)
			
			last_texture_index += 1
			if last_texture_index > 1: last_texture_index = 0
