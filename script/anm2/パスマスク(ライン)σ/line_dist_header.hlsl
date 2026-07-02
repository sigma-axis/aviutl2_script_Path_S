float sq_dist_func_end(float2 pt, float2 d, uint shape, float padding)
{
	static const float2 flip = { 1, -1 };
	const float l = -dot(pt, d), L = abs(dot(pt, flip * d.yx));
	float D = max(abs(l) + padding, L);
	if (l < 0) return D * D;

	switch (shape) {
	case 0: default: return min(D * D, dot(pt, pt));
	case 1:
		D = min(D, max(abs(dot(d, pt)), abs(dot(flip * d.yx, pt))));
		return D * D;
	case 2:
		D = min(D, max(abs(dot(d, pt)) + padding, abs(dot(flip * d.yx, pt))));
		return D * D;
	}
}
float sq_dist_func_elbow(float2 pt, float2 d0, float2 d1, uint shape, float padding)
{
	static const float2 flip = { 1, -1 };
	const float l0 = -dot(pt, d0), l1 = dot(pt, d1),
		L = max(abs(dot(pt, flip * d0.yx)), abs(dot(pt, flip * d1.yx)));
	float D = max(max(abs(l0), abs(l1)) + padding, L);
	if (l0 < 0 || l1 < 0) return D * D;

	switch (shape) {
	case 0: default: return min(D * D, dot(pt, pt));
	case 1: {
		float2 dd = d0 - d1, nd = flip * (d0 + d1).yx;
		if (dot(dd, nd) < 0) nd = -nd;
		dd += nd; dd = normalize(dd);
		nd = flip * dd.yx;

		D = min(D, abs(dot(dd, pt)) + (1 - abs(dot(nd, d0))) * padding);
		return D * D;
	}
	}
}
