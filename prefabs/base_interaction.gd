class_name BaseInteraction extends Node

var in_area: bool

func _ready() -> void:
	GlobalReference.Player.Input_Handler.Interaction.connect(_on_interaction)
	_initialise()

func _initialise() -> void:
	pass

func _on_interaction() -> void:
	pass
	
func _on_entered_extension() -> void:
	pass
	
func _on_exited_extension() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		in_area = true
		GlobalReference.Player.set_interaction_display(true)
		_on_entered_extension()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		in_area = false
		GlobalReference.Player.on_interaction_let_go()
		GlobalReference.Player.set_interaction_display(false)
		_on_exited_extension()
