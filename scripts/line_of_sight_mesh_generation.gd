extends Node2D

@export var radius := 100.0         # Max radius of the circle
@export var vertex_count := 20      # Number of rays/segments (finer mesh with more rays)
@export var collision_layer := 1    # Collision layer to check against
@export var mesh_color := Color(1, 1, 1)  # Color of the mesh

var circle_points = []

func _ready():
	update_circle_mesh()

func _process(delta: float) -> void:
	update_circle_mesh()
	
func update_circle_mesh():
	# Clear previous points
	circle_points.clear()
	
	# Calculate points around the circle using raycasts
	for i in vertex_count:
		var angle = i * TAU / vertex_count
		var point = cast_ray(angle)
		circle_points.push_back(point)

	# Create the mesh from the points
	create_fan_mesh(circle_points)

func cast_ray(angle: float) -> Vector2:
	# Calculate direction vector based on angle
	var direction = Vector2(cos(angle), sin(angle))
	var ray_origin = global_position
	var ray_end = ray_origin + direction * radius

	# Use intersect_ray to detect collisions
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(ray_origin, ray_end, 1 << 1))

	# If collision, adjust point to the collision position
	if result:
		return result.position + (direction.normalized() * (1.1 / sin(deg_to_rad((int(angle) + 90) % 360))))
	else:
		# No collision, return the endpoint at max radius
		return ray_end

func create_fan_mesh(points: Array):
	# Initialize the ArrayMesh
	var mesh = ArrayMesh.new()
	var vertices = PackedVector2Array()
	var indices = PackedInt32Array()
	var colors = PackedColorArray()

	# Center point (index 0 in vertices)
	vertices.append(Vector2(0, 0))  # Local center position for the MeshInstance2D
	colors.append(mesh_color)
	
	# Add each outer point to the vertices
	for point in points:
		vertices.append(point - global_position)
		colors.append(mesh_color)

	# Create triangles from center point to each pair of outer points
	for i in vertex_count:
		indices.append(0)  # Center point
		indices.append(i + 1)
		indices.append((i + 1) % vertex_count + 1)

	# Set up the mesh arrays (index 0 for vertices, 1 for colors, 2 for indices)
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices

	# Add the surface from the arrays
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	# Create a MeshInstance2D to display the mesh
	var mesh_instance = $MeshInstance2D
	mesh_instance.mesh = mesh
