extends BaseInventoryItem

@export var max_spawn_count: int = 3
@export var block_prefab: Resource

@onready var spawn_area: Area2D = $SpawnArea

var spawned_objects: Array[Node2D]

func _ready() -> void:
	call_deferred("initialise")

func initialise() -> void:
	GlobalReference.Player.Input_Handler.DirectionInput.connect(_on_move)

func _physics_process(delta: float) -> void:
	if spawned_objects.size() > 3:
		if spawned_objects[0] == null: 
			spawned_objects.remove_at(0)
			return
		
		spawned_objects[0].queue_free()
		spawned_objects.remove_at(0)

func on_item_use() -> void:
	if GlobalReference.Player._is_currently_interacting: return
	
	if spawn_area.has_overlapping_bodies(): return
	
	var block = block_prefab.duplicate().instantiate()
	GlobalReference.PlayerParent.add_child(block)
	block.set_global_position($Spawn.global_position)
	spawned_objects.append(block)

func _on_move(direction: float) -> void:
	if direction != 0: scale.x = scale.y * direction
