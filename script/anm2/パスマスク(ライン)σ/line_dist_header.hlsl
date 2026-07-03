float sq_dist_func_end(float2 pt, float2 d, uint shape, float padding)
{
	static const float2 flip = { 1, -1 }, c = { sqrt(0.5), 1 - sqrt(0.5) };
	const float l = -dot(d, pt), L = abs(dot(flip * d.yx, pt));
	float D = max(abs(l) + padding, L);
	if (l < 0) return D * D;

	switch (shape) {
	case 0: default: return dot(pt, pt);
	case 1: D = max(abs(l), L); break;
	case 2: break;
	case 3:
		D = max(dot(c, float2(L + abs(l), padding)), L);
		break;
	}
	return D * D;
}
float sq_dist_func_join(float2 pt, float2 d0, float2 d1, uint shape, float padding, float dot_lim)
{
	static const float2 flip = { 1, -1 };
	const float l0 = -dot(d0, pt), l1 = dot(d1, pt),
		L0 = abs(dot(flip * d0.yx, pt)), L1 = abs(dot(flip * d1.yx, pt)),
		L = max(L0, L1);
	float D = max(min(abs(l0), abs(l1)) + padding, L);
	if (l0 < 0 || l1 < 0 || shape == 3) return D * D;
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
