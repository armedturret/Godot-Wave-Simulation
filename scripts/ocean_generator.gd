@tool
extends Node3D

class_name OceanGenerator

@export var side_square_count: int = 64
@export var tile_size: float = 10.0
@export var ocean_material: Material

@export_tool_button("Generate Ocean Mesh", "MeshInstance3D")
var generate_ocean_tool_button: Callable = regenerate_ocean

func _ready() -> void:
	regenerate_ocean()


func regenerate_ocean() -> void:
	# for now, only generate one mesh tile
	# the final play would be using a MultiMeshInstance
	var ocean_mesh := ArrayMesh.new()
	var surface_array := []
	surface_array.resize(Mesh.ARRAY_MAX)

	# only bother with vertices and indicies since normals will be generated
	# by the shader
	var verts := PackedVector3Array()
	var indices := PackedInt32Array()

	# generate mesh here
	var side_vert_count := side_square_count + 1
	verts.resize(side_vert_count * side_vert_count)
	for x : int in range(0, side_vert_count):
		for z : int in range(0, side_vert_count):
			var coord := Vector3(float(x), 0, float(z))
			coord *= tile_size / side_square_count
			verts[z * side_vert_count + x] = coord

	# each square has 2 tris for 6 verts per square
	indices.resize(side_square_count * side_square_count * 6)
	for x : int in range(0, side_square_count):
		for z : int in range(0, side_square_count):
			var base_idx := ((z * side_square_count) + x) * 6

			var bl_idx := z * side_vert_count + x
			var br_idx := bl_idx + 1
			var tl_idx := bl_idx + side_vert_count
			var tr_idx := tl_idx + 1

			indices[base_idx] = bl_idx
			indices[base_idx + 1] = tr_idx
			indices[base_idx + 2] = tl_idx

			indices[base_idx + 3] = bl_idx
			indices[base_idx + 4] = br_idx
			indices[base_idx + 5] = tr_idx

	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_INDEX] = indices

	ocean_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	ocean_mesh.surface_set_material(0, ocean_material)
	for child : Node in get_children():
		child.queue_free()

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = ocean_mesh
	add_child(mesh_instance)
