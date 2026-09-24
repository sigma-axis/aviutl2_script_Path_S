uint checker(uint2 p)
{
	uint f = 0;
	if ((dot(p, 1) & 1) != 0) { p += uint2(7, 8); f = 0x0f; }
	p = firstbitlow(16 | p);
	uint v = 2 * (4 - min(p.x, p.y));
	if (p.x == p.y && v > 0) v -= 1;
	return f ^ v;
}
float checker_normal(uint2 p)
{
	float2 m = float2(1, 0);
	uint v = checker(p);
	if (v >= 8) { v ^= 0x0f; m = float2(-1, 1); }
	static const float v0 = pow(0.5, 1.0 / 3) / 256;
	return dot(float2(v0 * (1 << v), 1), m);
}
uint bayer_88(uint2 p)
{
	p.y ^= p.x;
	uint v = dot(p & 0xff, uint2(1 << 8, 1));
	v = (v & 0x0ff0) | ((v & 0xf000) >>12) | ((v & 0x000f) <<12);
	v = (v & 0x3c3c) | ((v & 0xc0c0) >> 6) | ((v & 0x0303) << 6);
	v = (v & 0x6666) | ((v & 0x8888) >> 3) | ((v & 0x1111) << 3);
	return v;
}
// Interleaved Gradient Noise by Jorge Jimenez
// https://www.iryoku.com/next-generation-post-processing-in-call-of-duty-advanced-warfare
float ign(float2 v)
{
    float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
    return frac(magic.z * frac(dot(v, magic.xy)));
}
float noise_func(float2 pos, uint2 seed, uint noise_type)
{
	[branch] switch (noise_type) {
	case 0:
		// white noise
		return ibuki(float4(pos, seed));
	case 1:
		// bayer 2x2
		return ((bayer_88(uint2(pos)) & 0xc000) + 0x2000) / float(1 << 16);
	case 2:
		// bayer 4x4
		return ((bayer_88(uint2(pos)) & 0xf000) + 0x0800) / float(1 << 16);
	case 3:
		// bayer 256x256
		return (bayer_88(uint2(pos)) + 0.5) / float(1 << 16);
	case 4:
		// checker
		return (checker(uint2(pos)) + 0.5) / 16.0;
	case 5:
		// uniform checker
		return checker_normal(uint2(pos));
	default: {
		uint2 s = uint2(106033, 92681) * seed;
		s ^= s >> 14; s &= 0x3fff;
		// Interleaved Gradient Noise
		return ign(floor(pos) + s);
	}
	}
}
