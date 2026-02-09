shader_type spatial;
render_mode world_vertex_coords;

const int WAVE_COUNT = 12;
const float G = 9.8f;

uniform float steepness : hint_range(0.001, 1.0, 0.001);

uniform float amp[WAVE_COUNT];
uniform vec2 wave_dirs[WAVE_COUNT];
uniform float wave_lens[WAVE_COUNT];
uniform float phases[WAVE_COUNT];

void vertex() {
	// This notation is confusing, but used in the tessendorf paper
	// TLDR; x is a horizontal vector, y is the height offset
	vec2 x = VERTEX.xz;
	float y = 0.0f;

	// Calculate Qi
	float total_ka = 0.0f;
	for (int i = 0; i < WAVE_COUNT; i++)
	{
		float k = 2.0f * PI / wave_lens[i];
		total_ka += k * amp[i];
	}
	float steepness_coeff = steepness / total_ka;

		// Calculate the vertex position
	for (int i = 0; i < WAVE_COUNT; i++)
	{
		if (amp[i] <= 0.0f)
			continue;

		vec2 wave_dir_norm = normalize(wave_dirs[i]);
		float k = 2.0f * PI / wave_lens[i];
		float ang_freq = sqrt(k * G);
		vec2 wave_vec = wave_dir_norm * k;

		float theta = dot(wave_vec, VERTEX.xz) + ang_freq * TIME + phases[i];
		x += wave_dir_norm * steepness_coeff * amp[i] * cos(theta);
		y += amp[i] * sin(theta);
	}

	// Need to calculate norm AFTER finding location
	vec3 norm_sum = vec3(0.0f, 1.0f, 0.0f);
	for (int i = 0; i < WAVE_COUNT; i ++)
	{
		vec2 wave_dir_norm = normalize(wave_dirs[i]);
		float k = 2.0f * PI / wave_lens[i];
		float ang_freq = sqrt(k * G);

		// Calculate the normal components
		float norm_theta = dot(k * wave_dir_norm, x) + ang_freq * TIME + phases[i];
		norm_sum.xz -= wave_dir_norm * amp[i] * k * cos(norm_theta);
		norm_sum.y -= steepness_coeff * amp[i] * k * sin(norm_theta);
	}

	VERTEX = vec3(x.x, y, x.y);
	NORMAL = normalize(norm_sum);
}

void fragment() {
	ALBEDO = vec3(0.0f, 0.0f, 1.0f);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
