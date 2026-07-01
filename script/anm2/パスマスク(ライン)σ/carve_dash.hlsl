cbuffer constant0 : register(b0) {
	float2 alpha_map;
	float N_f, padding, aa_thick,
		M_f, len_period0, idx_period0;
	float4 end_points[2];
	float4 phase_whole;
	float4 phase_period[64];
};

float4 carve_dash(float4 pos : SV_Position) : SV_Target
{
	float sq_dist = (aa_thick + padding + 1) * (aa_thick + padding + 1),
		len_whole = phase_whole[0], len_period = len_period0;
	uint idx_whole = 0, idx_period = idx_period0;

	static const uint N = uint(N_f), M = uint(M_f);
	float2 pt0 = get_point(0) - pos.xy;
	for (uint i = 1; i < N; i++) {
		const float2 pt1 = get_point(i) - pos.xy,
			d = pt1 - pt0;
		const float L = dot(d, d), l = sqrt(L),
			side = d.y * pt1.x - d.x * pt1.y,
			L_side = side * side / L;

		for (float rest = l; rest > 0 && idx_whole < 4; ) {
			if (len_whole <= 0) len_whole += phase_whole[(++idx_whole) & 3];
			if (len_period <= 0) {
				++idx_period;
				idx_period %= M;
				len_period += phase_period[idx_period >> 2][idx_period & 3];
			}
			const float consume = min(rest, min(len_whole, len_period));
			rest -= consume; len_whole -= consume; len_period -= consume;

			const float2 ptm = pt1 - (rest / l) * d;
			if ((idx_whole & idx_period & 1) != 0) {
				sq_dist = min(sq_dist,
					dot(d, pt0) >= 0 ? dot(pt0, pt0) :
					dot(d, ptm) <= 0 ? dot(ptm, ptm) :
					L_side);
			}
			pt0 = ptm;
		}
	}

	float end_dist = sqrt(sq_dist);
	for (i = 0; i < 2; i++) {
		const float2 pt = end_points[i].xy - pos.xy,
			d = end_points[i].zw, nd = float2(-d.y, d.x);
		end_dist = min(end_dist, max(abs(dot(d, pt) - padding / 2) + padding / 2, abs(dot(nd, pt))));
	}

	const float a = 1 - saturate((end_dist - padding) / aa_thick);
	return float4(0, 0, 0, dot(alpha_map, float2(a, 1)));
}
