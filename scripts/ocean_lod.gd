extends Node3D

@export var camera : Camera3D
@export var lods : Array[OceanLodLevel]
@export var template: PackedScene
@export var max_chunk_dist: int = 12
@export var chunk_size: float = 100.0
@export var recalc_distance: float = 100.0

var last_camera_pos: Vector3

var mesh_dict: Dictionary[Vector2i, MeshInstance3D]

func _ready() -> void:
	recalculate_lod()


func _process(delta: float) -> void:
	position.x = camera.position.x
	position.z = camera.position.z
	if abs(camera.position.y - last_camera_pos.y) > recalc_distance:
		recalculate_lod()


func recalculate_lod() -> void:
	last_camera_pos = camera.position

	for x : int in range(-max_chunk_dist, max_chunk_dist + 1):
		for y : int in range(-max_chunk_dist, max_chunk_dist + 1):
			var coord := Vector2i(x, y)
			if not mesh_dict.has(coord):
				var inst := template.instantiate() as MeshInstance3D
				mesh_dict[coord] = inst
				add_child(inst)
				inst.position = Vector3(x * chunk_size, 0, y * chunk_size)

			var inst := mesh_dict[coord] as MeshInstance3D
			var sq_dist := Vector3(inst.position.x,
				camera.position.y,
				inst.position.z).length_squared()
			inst.mesh = get_lod_mesh(sq_dist)


func get_lod_mesh(sq_dist: float) -> Mesh:
	# assume lods are in order of increasing simplicity, start with the last one
	for i: int in range(lods.size() - 1, -1, -1):
		if sq_dist >= lods[i].min_distance ** 2:
			return lods[i].mesh

	return lods[-1].mesh
