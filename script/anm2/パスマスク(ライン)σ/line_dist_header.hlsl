float sq_dist_func_end(float2 pt, float2 d, uint shape, float padding)
{
	static const float2 flip = { 1, -1 };
	const float l = -dot(d, pt);
	[branch] if (l < 0) return (1 << 30);
	else {
		const float L = abs(dot(flip * d.yx, pt));
		[branch] switch (shape) {
		case 0: default: return dot(pt, pt);
		case 1: {
			float D = max(l, L);
			return D * D;
		}
		case 2: {
			float D = l * l;
			if (L > padding) D += (L - padding) * (L - padding);
			D = sqrt(D) + padding;
			return D * D;
		}
		case 3: {
			float D = l + L;
			return D * D;
		}
		}
	}
}
float sq_dist_func_join(float2 pt, float2 d0, float2 d1, uint shape, float padding, float dot_lim)
{
	static const float2 flip = { 1, -1 };
	const float l0 = -dot(d0, pt), l1 = dot(d1, pt);
	[branch] if (l0 < 0 || l1 < 0) return (1 << 30);
	else {
		const float L0 = abs(dot(flip * d0.yx, pt)), L1 = abs(dot(flip * d1.yx, pt)),
			L = max(L0, L1);
		[branch] if (shape != 3 && dot_lim >= -dot(d0, d1)) {
			if (shape == 2) return L * L;
		}
		else if (shape >= 3) {
			float D = min(abs(l0), abs(l1)); D *= D;
			if (L > padding) D += (L - padding) * (L - padding);
			D = sqrt(D) + padding;
			return D * D;
		}

		[branch] switch (shape) {
		case 0: case 4: return dot(pt, pt);
		default:
			float2 dd = d0 - d1, nd = flip * (d0 + d1).yx;
			dd = normalize(dd + (dot(dd, nd) < 0 ? -nd : nd));
			float D = max(abs(dot(dd, pt)) + (1 - abs(dot(dd, flip * d0.yx))) * padding, L);
			return D * D;
		}
	}
}
