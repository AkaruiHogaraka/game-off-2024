extends Node2D

@export var speed: float = 32

@onready var point_a: Vector2 = $Position1.global_position
@onready var point_b: Vector2 = $Position2.global_position

var progress: float = 0.0
var direction: int = 1
var in_area: bool
var reparent_once: bool

@onready var distance_between: float = $Position1.global_position.distance_to($Position2.global_position)

func _ready() -> void:
	$Platform/Area2D.body_entered.connect(_on_body_entered)
	$Platform/Area2D.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	progress += speed * delta * direction

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

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not in_area:
		in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and in_area and reparent_once:
		in_area = false
		reparent_once = false
		body.reparent(GlobalReference.PlayerParent)
