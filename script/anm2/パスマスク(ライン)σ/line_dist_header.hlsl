float sq_dist_func_end(float2 pt, float2 d, uint shape, float padding)
{
	static const float2 flip = { 1, -1 };
	const float l = -dot(d, pt);
	if (l < 0) return (1 << 30);

	const float L = abs(dot(flip * d.yx, pt));
	float D = l;
	switch (shape) {
	case 0: default: return dot(pt, pt);
	case 1: break;
	case 2: D = l + padding; break;
	case 3: D = L + l; break;
	}
	D = max(D, L);
	return D * D;
}
float sq_dist_func_join(float2 pt, float2 d0, float2 d1, uint shape, float padding, float dot_lim)
{
	static const float2 flip = { 1, -1 };
	const float l0 = -dot(d0, pt), l1 = dot(d1, pt);
	if (l0 < 0 || l1 < 0) return (1 << 30);

	const float L0 = abs(dot(flip * d0.yx, pt)), L1 = abs(dot(flip * d1.yx, pt)),
		L = max(L0, L1);
	float D = max(min(abs(l0), abs(l1)) + padding, L);
	if (shape == 3) return D * D;
	if (dot_lim >= -dot(d0, d1)) {
		if (shape == 2) return L * L;
	}
	else if (shape > 3) return D * D;

	switch (shape) {
	case 0: case 4: return dot(pt, pt);
	default:
		float2 dd = d0 - d1, nd = flip * (d0 + d1).yx;
		dd = normalize(dd + (dot(dd, nd) < 0 ? -nd : nd));
		D = max(abs(dot(dd, pt)) + (1 - abs(dot(dd, flip * d0.yx))) * padding, L);
		return D * D;
	}
}
