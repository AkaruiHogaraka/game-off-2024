class_name SceneConnection extends Node

@export var scene_path: String
@export var node_path: String

var scene: Scene
var node: Node2D

func preload_connected_scene() -> void:
	if scene_path.is_empty() or node_path.is_empty():
		push_warning("%s does not inculude a connection scene or node" % [self])
		return
	
	var scene_resource: Resource = load(scene_path)
	scene = scene_resource.instantiate()
	node = scene.get_node(NodePath(node_path))
