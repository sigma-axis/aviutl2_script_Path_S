cbuffer constant0 : register(b0) {
	float2 alpha_map;
	float N_f, mode_fill_f,
		padding, aa_thick;
	float2 noise_offset;
	float inv_noise_size, noise_buff, noise_seed;
};

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

	float a = 1 - (is_inner(cycles) ? 0 : sqrt(sq_dist) - padding) / aa_thick,
		noise = ibuki(float4(inv_noise_size * (pos.xy - noise_offset) + (1 << 16), noise_seed, 101));
	a = (a - (1 - noise_buff) * noise) / noise_buff;
	return float4(0, 0, 0, dot(alpha_map, float2(saturate(a), 1)));
}
