cbuffer constant0 : register(b0) {
	float2 alpha_map;
	float N_f, padding, aa_thick;
	float4 end_points[2];
};

float4 carve(float4 pos : SV_Position) : SV_Target
{
	float sq_dist = (aa_thick + padding + 1) * (aa_thick + padding + 1);

	static const uint N = uint(N_f);
	float2 pt0 = get_point(0) - pos.xy;
	for (uint i = 1; i < N; i++) {
		const float2 pt1 = get_point(i) - pos.xy,
			d = pt1 - pt0;
		const float L = dot(d, d), l = sqrt(L),
			side = d.y * pt1.x - d.x * pt1.y;

		sq_dist = min(sq_dist,
			dot(d, pt0) >= 0 ? dot(pt0, pt0) :
			dot(d, pt1) <= 0 ? dot(pt1, pt1) :
			side * side / L);

		pt0 = pt1;
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
