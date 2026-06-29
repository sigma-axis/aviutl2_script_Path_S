Texture2D<half4> coords : register(t0);
cbuffer constant0 : register(b0) {
	float2 alpha_map;
	float N_f, mode_fill_f,
		padding, aa_thick;
};

float decode_float(half3 c)
{
	const uint3 c_i = floor(255 * c + 0.5);
	const int i = (c_i.r << 8) | (c_i.g << 16) | (c_i.b << 24);
	return i / float(1 << 16);
}

float2 get_point(uint i)
{
	static const uint log2_span_x = 12, span_x = 1 << log2_span_x;
	const uint x = (i << 1) & (span_x - 1), y = i >> (log2_span_x - 1);
	return float2(
		decode_float(coords.Load(int3(x | 0, y, 0)).rgb),
		decode_float(coords.Load(int3(x | 1, y, 0)).rgb));
}

uint quadrant(float2 v)
{
	return (v.x >= 0 ? 0 : 1) ^ (v.y >= 0 ? 0 : 3);
}
bool is_inner(int cycles)
{
	static const uint mode_fill = uint(mode_fill_f);
	switch(mode_fill) {
	case 0: default: return cycles != 0;
	case 1: return (cycles & 1) != 0;
	case 2: return cycles == 0;
	case 3: return (cycles & 1) == 0;
	}
}

float4 carve(float4 pos : SV_Position) : SV_Target
{
	int cycles = 0;
	float sq_dist = (aa_thick + padding + 1) * (aa_thick + padding + 1);

	static const uint N = uint(N_f);
	float2 pt0 = get_point(0) - pos.xy;
	uint q0 = quadrant(pt0);
	for (uint i = 1; i < N; i++) {
		const float2 pt1 = get_point(i) - pos.xy,
			d = pt1 - pt0;
		const float side = d.y * pt1.x - d.x * pt1.y;
		const uint q1 = quadrant(pt1);

		if (side < 0) { if (q1 > q0) cycles--; }
		else { if (q1 < q0) cycles++; }
		sq_dist = min(sq_dist,
			dot(d, pt0) >= 0 || dot(d, pt1) <= 0 ?
			dot(pt0, pt0) : side * side / dot(d, d));

		pt0 = pt1; q0 = q1;
	}

	const float a = 1 - smoothstep(0, aa_thick, is_inner(cycles) ? 0 : sqrt(sq_dist) - padding);
	return float4(0, 0, 0, dot(alpha_map, float2(a, 1)));
}
