shader_type spatial;
render_mode world_vertex_coords;
uniform float amplitude = 1.0;
uniform float angular_frequency = 1.0;
uniform vec2 wave_vector = vec2(1.0, 0.0);

void vertex() {
	// Called for every vertex the material is visible on.
	float wp_dot = dot(wave_vector, VERTEX.xz);
	vec2 xz = VERTEX.xz - normalize(wave_vector) *
		amplitude *
		sin(wp_dot - angular_frequency * TIME);
	float y = amplitude * cos(wp_dot - angular_frequency * TIME);
	VERTEX = vec3(xz.x, y, xz.y);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
