extends Node2D

@export_range(0, 9) var index: int
@export var walk_to: Marker2D
@export var sprite: AnimatedSprite2D

var was_seen: bool
var direction: float

func _ready() -> void:
	walk()

func _physics_process(delta: float) -> void:
	animate_sprite()

func animate_sprite() -> void:
	if direction != 0.0:
		sprite.play("walk")
	else:
		sprite.play("idle")

func walk() -> void:
	set_visible(not was_seen)
	if was_seen: return
	
	was_seen = true
	
	var size: int = GlobalReference.friend_seen.size() - 1
	
	for i in range(index, size):
		if index + 1 > size:
			break
		
		if GlobalReference.friend_seen[i]:
			GlobalReference.friend_seen[index] = true
			set_visible(false)
			return
	
	GlobalReference.friend_seen[index] = true
	
	var distance: float = absf(global_position.x - walk_to.global_position.x)
	var direction: float = -1 if global_position.x - walk_to.global_position.x > 0 else 1
	var speed: float = GlobalReference.Player.move_speed
	
	set_sprite_direction(direction)
	self.direction = direction
	
	await create_tween().tween_property(sprite, "global_position:x", walk_to.global_position.x, distance / speed).finished
	
	direction = 0.0
	
	await get_tree().create_timer(1.0).timeout
	set_visible(false)

func set_sprite_direction(direction: float) -> void:
	if direction != 0: sprite.scale.x = sprite.scale.y * direction

func save_data() -> Dictionary:
	var data: Dictionary = {
		"path": get_path(),
		"was_seen": was_seen
	}
	
	return data

func load_data(data: Dictionary) -> void:
	was_seen = data["was_seen"]
	
	if not GlobalScene.CurrentScene.is_alternate_scene_dream:
		walk()
