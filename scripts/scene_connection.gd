class_name SceneConnection extends Node

@export var scene_path: String
@export var node_path: String

var scene: Scene
var node: Node2D

func preload_connected_scene() -> bool:
	if scene_path.is_empty():
		push_warning("%s does not inculude a connection scene" % [self])
		return false
	
	var scene_resource: Resource = load(scene_path)
	scene = scene_resource.instantiate()
	scene.current_scene_path = scene_path
	node = GlobalReference.Player if node_path.is_empty() else scene.get_node(NodePath(node_path))
	return true
