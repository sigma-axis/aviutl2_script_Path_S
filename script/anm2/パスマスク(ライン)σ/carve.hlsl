cbuffer constant0 : register(b0) {
	float2 alpha_map;
	float N_f, padding, aa_thick;
	float end_shape_f, elbow_shape_f, loop_f, dot_lim;
};
static const uint
	end_shape = uint(end_shape_f),
	elbow_shape = uint(elbow_shape_f);
static const bool loop = loop_f > 0;
static const uint N = uint(N_f);

float4 carve(float4 pos : SV_Position) : SV_Target
{
	float sq_dist = (aa_thick + padding + 1) * (aa_thick + padding + 1);

	float2 pt0 = get_point(0) - pos.xy, d0 = get_point(1) - pos.xy - pt0;
	d0 = length(d0) == 0 ? float2(1, 0) : normalize(d0);

	if (!loop) sq_dist = sq_dist_func_end(pt0, -d0, end_shape, padding);

	for (uint i = 1; i < N; i++) {
		float2 pt1 = get_point(i) - pos.xy, d1 = pt1 - pt0;
		float l = length(d1);
		d1 = l == 0 ? d0 : d1 / l;

		sq_dist = min(sq_dist,
			sq_dist_func_elbow(pt0, d0, d1, elbow_shape, padding, dot_lim));
		if (dot(d1, pt0) < 0 && dot(d1, pt1) >= 0) {
			const float side = dot(float2(-d1.y, d1.x), pt1);
			sq_dist = min(sq_dist, side * side);
		}

		pt0 = pt1; d0 = d1;
	}

	if (loop) {
		float2 pt1 = get_point(1) - pos.xy, d1 = pt1 - pt0;
		float l = length(d1);
		d1 = l == 0 ? d0 : d1 / l;
		sq_dist = min(sq_dist,
			sq_dist_func_elbow(pt0, d0, d1, elbow_shape, padding, dot_lim));
	}
	else sq_dist = min(sq_dist,
		sq_dist_func_end(pt0, d0, end_shape, padding));

	const float a = 1 - saturate((sqrt(sq_dist) - padding) / aa_thick);
	return float4(0, 0, 0, dot(alpha_map, float2(a, 1)));
}
