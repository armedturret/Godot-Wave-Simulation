shader_type spatial;
render_mode world_vertex_coords;

const int WAVE_COUNT = 12;
const float G = 9.8f;

group_uniforms WaveParams;
uniform float steepness : hint_range(0.001, 1.0, 0.001);
uniform sampler2D noise : hint_default_black;
uniform float noise_scale : hint_range(0.0, 10.0, 0.01) = 0.0f;
uniform float uv_to_world_ratio = 100.0f;
uniform sampler2D foam : hint_default_white;
uniform float foam_start = 0.2f;
uniform float foam_full = 0.0f;

group_uniforms WaveArrays;
uniform float amp[WAVE_COUNT];
uniform vec2 wave_dirs[WAVE_COUNT];
uniform float wave_lens[WAVE_COUNT];
uniform float phases[WAVE_COUNT];

group_uniforms VisualSettings;
uniform vec3 max_albedo : source_color = vec3(1.0f);
uniform vec3 min_albedo : source_color = vec3(1.0f);
uniform float roughness : hint_range(0, 1) = 0.0f;
uniform float metallic : hint_range(0, 1) = 0.0f;

varying float height_percent;
varying float norm_vert_unsteep;
varying vec2 uv_calculated;

void vertex() {
	// This notation is confusing, but used in the tessendorf paper
	// TLDR; x is a horizontal vector, y is the height offset
	vec2 x = VERTEX.xz;
	float y = 0.0f;
	uv_calculated = VERTEX.xz / uv_to_world_ratio;
    // noise works by giving each vertex a "time" offset
    float t_off = texture(noise, uv_calculated).r;
    float t = TIME + noise_scale * t_off;

	// Calculate Qi
	float total_ka = 0.0f;
	for (int i = 0; i < WAVE_COUNT; i++)
	{
		float k = 2.0f * PI / wave_lens[i];
		total_ka += k * amp[i];
	}
	float steepness_coeff = steepness / total_ka;
	float max_amp = 0.0f;
	float min_amp = 0.0f;

	// Calculate the vertex position
	for (int i = 0; i < WAVE_COUNT; i++)
	{
		if (amp[i] <= 0.0f)
			continue;

		vec2 wave_dir_norm = normalize(wave_dirs[i]);
		float k = 2.0f * PI / wave_lens[i];
		float ang_freq = sqrt(k * G);
		vec2 wave_vec = wave_dir_norm * k;

		float theta = dot(wave_vec, VERTEX.xz) + ang_freq * t + phases[i];
		x += wave_dir_norm * steepness_coeff * amp[i] * cos(theta);
		y += amp[i] * sin(theta);
		min_amp -= amp[i];
		max_amp += amp[i];
	}

	// Need to calculate norm AFTER finding location
	vec3 norm_sum = vec3(0.0f, 1.0f, 0.0f);
	norm_vert_unsteep = 1.0f;
	for (int i = 0; i < WAVE_COUNT; i ++)
	{
		vec2 wave_dir_norm = normalize(wave_dirs[i]);
		float k = 2.0f * PI / wave_lens[i];
		float ang_freq = sqrt(k * G);

		// Calculate the normal components
		float norm_theta = dot(k * wave_dir_norm, x) + ang_freq * t + phases[i];
		norm_sum.xz -= wave_dir_norm * amp[i] * k * cos(norm_theta);
		norm_sum.y -= steepness_coeff * amp[i] * k * sin(norm_theta);
		norm_vert_unsteep -= amp[i] * k * sin(norm_theta);
	}

	VERTEX = vec3(x.x, y, x.y);
	NORMAL = normalize(norm_sum);

	height_percent = (y - min_amp) / (max_amp - min_amp);



}

void fragment() {
	ALBEDO = height_percent * max_albedo + (1.0f - height_percent) * min_albedo;

	// foam calculations
	float foam_percent = 0.0f;
	if (norm_vert_unsteep < foam_full)
		foam_percent = 1.0f;
	else if (norm_vert_unsteep < foam_start)
		foam_percent = 1.0f - smoothstep(foam_full, foam_start, norm_vert_unsteep);

	if (foam_percent > 0.0f)
		foam_percent = texture(foam, uv_calculated).r * foam_percent;
		ALBEDO = mix(ALBEDO, vec3(1.0f), foam_percent);

	ROUGHNESS = (1.0f - foam_percent) * roughness + foam_percent;
	METALLIC = (1.0f - foam_percent) * metallic;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
