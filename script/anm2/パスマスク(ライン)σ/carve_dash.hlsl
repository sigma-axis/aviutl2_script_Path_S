cbuffer constant0 : register(b0) {
	float2 alpha_map;
	float N_f, padding, aa_thick,
		M_f, len_period0, idx_period0;
	float end_shape_f, join_shape_f, dash_shape_f, loop_f, dot_lim;
	float4 phase_whole;
	float4 phase_period[64];
};
static const uint
	end_shape = uint(end_shape_f),
	join_shape = uint(join_shape_f),
	dash_shape = uint(dash_shape_f);
static const bool loop = loop_f > 0;
static const uint N = uint(N_f), M = uint(M_f);

float4 carve_dash(float4 pos : SV_Position) : SV_Target
{
	float sq_dist = (aa_thick + padding + 1) * (aa_thick + padding + 1),
		len_whole = phase_whole[0], len_period = len_period0;
	uint idx_whole = 0, idx_period = idx_period0;
	if (loop) {
		if (len_whole <= 0) len_whole += phase_whole[(++idx_whole) & 3];
		if (len_period <= 0) {
			++idx_period;
			idx_period %= M;
			len_period += phase_period[idx_period >> 2][idx_period & 3];
		}
	}

	float2 pt0 = get_point(0) - pos.xy, d0 = get_point(1) - pos.xy - pt0;
	d0 = length(d0) == 0 ? float2(1, 0) : normalize(d0);
	bool was_stroke_whole = (idx_whole & 1) != 0, was_stroke_period = (idx_period & 1) != 0;

	for (uint i = 1; i < N; i++) {
		float2 pt1 = get_point(i) - pos.xy, d1 = pt1 - pt0;
		const float l = length(d1);
		d1 = l == 0 ? d0 : d1 / l;
		const float side = dot(float2(-d1.y, d1.x), pt1);

		if (was_stroke_whole && was_stroke_period)
			sq_dist = min(sq_dist, sq_dist_func_join(pt0, d0, d1, join_shape, padding, dot_lim));
		for (float rest = l; rest > 0 && idx_whole < 4; ) {
			if (len_whole <= 0) len_whole += phase_whole[(++idx_whole) & 3];
			if (len_period <= 0) {
				++idx_period;
				idx_period %= M;
				len_period += phase_period[idx_period >> 2][idx_period & 3];
			}
			const float consume = min(rest, min(len_whole, len_period));
			rest -= consume; len_whole -= consume; len_period -= consume;

			const float2 ptm = pt1 - rest * d1;
			const bool is_stroke_whole = (idx_whole & 1) != 0,
				is_stroke_period = (idx_period & 1) != 0;
			if (is_stroke_whole && is_stroke_period &&
				dot(d1, pt0) < 0 && dot(d1, ptm) >= 0)
				sq_dist = min(sq_dist, side * side);
			if ((was_stroke_whole && was_stroke_period) != (is_stroke_whole && is_stroke_period)) {
				sq_dist = min(sq_dist, sq_dist_func_end(pt0,
					(was_stroke_whole && was_stroke_period) ? d1 : -d1,
					(was_stroke_whole != is_stroke_whole) ? end_shape : dash_shape, padding));
			}

			pt0 = ptm;
			was_stroke_whole = is_stroke_whole;
			was_stroke_period = is_stroke_period;
		}
		d0 = d1;
	}

	if (loop) {
		float2 d1 = get_point(1) - pos.xy - pt0;
		d1 = length(d1) == 0 ? float2(1, 0) : normalize(d1);
		const bool is_stroke_whole = phase_whole[0] <= 0,
			is_stroke_period = ((uint(idx_period0) & 1) != 0) ^ (len_period0 <= 0);
		if (was_stroke_whole && was_stroke_period)
			sq_dist = min(sq_dist, sq_dist_func_join(pt0, d0, d1, join_shape, padding, dot_lim));
		if ((was_stroke_whole && was_stroke_period) != (is_stroke_whole && is_stroke_period)) {
			sq_dist = min(sq_dist, sq_dist_func_end(pt0,
				(was_stroke_whole && was_stroke_period) ? d0 : -d1,
				(was_stroke_whole != is_stroke_whole) ? end_shape : dash_shape, padding));
		}
	}
	else if (was_stroke_whole && was_stroke_period)
		sq_dist = min(sq_dist, sq_dist_func_end(pt0, d0, end_shape, padding));

	const float a = 1 - saturate((sqrt(sq_dist) - padding) / aa_thick);
	return float4(0, 0, 0, dot(alpha_map, float2(a, 1)));
}
