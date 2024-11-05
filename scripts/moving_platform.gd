extends Node2D

@export var speed: float = 32

@onready var point_a: Vector2 = $Position1.global_position
@onready var point_b: Vector2 = $Position2.global_position

var progress: float = 0.0
var direction: int = 1
var in_area: bool
var reparent_once: bool

@onready var distance: float = point_a.distance_to(point_b)

func _ready() -> void:
	$Platform/Area2D.body_entered.connect(_on_body_entered)
	$Platform/Area2D.body_exited.connect(_on_body_exited)
	$TextureRect.size.x = $Position1.global_position.distance_to($Position2.global_position)
	$TextureRect.global_position = $Position1.global_position + Vector2.UP
	$TextureRect.rotation = ($Position2.global_position - $Position1.global_position).angle()

func _physics_process(delta: float) -> void:
	progress += (speed / distance) * delta * direction

	if progress >= 1.0:
		progress = 1.0
		direction = -1
	elif progress <= 0.0:
		progress = 0.0
		direction = 1

	$Platform.global_position = point_a.lerp(point_b, progress)
	
	if not reparent_once and in_area:
		reparent_once = true
		GlobalReference.Player.reparent($Platform)
		GlobalReference.Player.set_can_dream(false)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not in_area and body.is_on_floor():
		in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		in_area = false
		reparent_once = false
		body.reparent(GlobalReference.PlayerParent)
		body.set_can_dream(true)
		
func save_data() -> Dictionary:
	var data: Dictionary = {
		"path": get_path(),
		"progress": progress
	}
	
	return data

func load_data(data: Dictionary) -> void:
	progress = data["progress"]
