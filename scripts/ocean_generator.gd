@tool
extends MeshInstance3D

class_name OceanGenerator

@export var wave_count: int = 12
@export var min_wavelen: float = 1.0
@export var max_wavelen: float = 50.0

@export_tool_button("Generate Ocean Params", "Path3D")
var generate_ocean_tool_button: Callable = regenerate_ocean_params


func regenerate_ocean_params() -> void:
	var ocean_material := get_surface_override_material(0) as ShaderMaterial

	if ocean_material == null:
		return

	var amplitudes : Array[float] = []
	var wave_dirs : Array[Vector2] = []
	var wave_lens : Array[float] = []
	var phases : Array[float] = []
	for i in range(wave_count):
		# If kA > 1 causes looping waves
		# Cap for now
		var wave_len := randf_range(min_wavelen, max_wavelen)
		var wave_dir := randf_range(0, 2.0 * PI)
		var k := 2 * PI / wave_len
		var max_amp := 1.0 / k
		var amp := randf_range(0.001 * max_amp, max_amp * 0.5)
		amplitudes.append(amp)
		wave_dirs.append(Vector2(cos(wave_dir), sin(wave_dir)))
		wave_lens.append(wave_len)
		phases.append(randf_range(0, 2.0 * PI))

	ocean_material.set_shader_parameter("amp", amplitudes)
	ocean_material.set_shader_parameter("wave_dirs", wave_dirs)
	ocean_material.set_shader_parameter("wave_lens", wave_lens)
	ocean_material.set_shader_parameter("phases", phases)
