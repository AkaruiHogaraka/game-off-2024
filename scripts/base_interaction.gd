class_name BaseInteraction extends Node

var in_area: bool
var can_interact: bool

func _ready() -> void:
	GlobalReference.Player.Input_Handler.Interaction.connect(_on_interaction)
	can_interact = true
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
	if body.is_in_group("Player") and can_interact: 
		in_area = true
		GlobalReference.Player.set_is_in_interaction_area(false, self, true)
		GlobalReference.Player.set_interaction_display(true)
		GlobalReference.Player.set_is_in_interaction_area(true, self, true)
		_on_entered_extension()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		in_area = false
		GlobalReference.Player.set_is_in_interaction_area(false, self, false)
		GlobalReference.Player.set_interaction_display(false)
		_on_exited_extension()
