extends BaseInventoryItem

@export var max_spawn_count: int = 3
@export var block_prefab: Resource

@export var spawn_sfx: AudioStreamPlayer
@export var invalid_spawn_sfx: AudioStreamPlayer

@onready var spawn_area: Area2D = $SpawnArea

var spawned_objects: Array[Node2D]
var is_despawning: bool

func _ready() -> void:
	call_deferred("initialise")

func initialise() -> void:
	GlobalReference.Player.Input_Handler.DirectionInput.connect(_on_move)
	set_scale(GlobalReference.Player.sprite_parent.get_scale())

func _physics_process(delta: float) -> void:
	if spawned_objects.size() > 3:
		if spawned_objects[0] == null: 
			spawned_objects.remove_at(0)
			is_despawning = false
			return
		
		if is_despawning: return
		
		is_despawning = true
		
		await spawned_objects[0].on_despawn()
		
		spawned_objects[0].queue_free()
		spawned_objects.remove_at(0)
		is_despawning = false

func on_item_use(_arg = null) -> void:
	if GlobalReference.Player._is_currently_interacting: return
	
	if spawn_area.has_overlapping_bodies(): 
		GlobalAudio.play_sfx(invalid_spawn_sfx, true)
		return
	
	var block = block_prefab.duplicate().instantiate()
	GlobalReference.PlayerParent.add_child(block)
	block.set_global_position($SpawnArea/Spawn.global_position)
	spawned_objects.append(block)
	
	GlobalAudio.play_sfx(spawn_sfx)

func _on_move(direction: float) -> void:
	if direction != 0: scale.x = scale.y * direction
