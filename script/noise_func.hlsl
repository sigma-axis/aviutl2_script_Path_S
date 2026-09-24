float checker(uint2 p)
{
	float b = 0;
	if ((dot(p, 1) & 1) != 0) { p += uint2(127, 128); b = 1; }
	p = firstbitlow(256 | p);
	uint v = 2 * (8 - min(p.x, p.y));
	if (p.x == p.y && v > 0) v -= 1;
	static const float V = 0.4 / (1 << 15);
	return abs(V * (1 << v) - b);
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
	default: return 0;
	case 1:
		// checker
		return checker(uint2(pos));
	case 2:
		// bayer 2x2
		return ((bayer_88(uint2(pos)) & 0xc000) + 0x2000) / float(1 << 16);
	case 3:
		// bayer 4x4
		return ((bayer_88(uint2(pos)) & 0xf000) + 0x0800) / float(1 << 16);
	case 4:
		// bayer 256x256
		return (bayer_88(uint2(pos)) + 0.5) / float(1 << 16);
	case 5: {
		uint2 s = uint2(106033, 92681) * seed;
		s ^= s >> 14; s &= 0x3fff;
		// Interleaved Gradient Noise
		return ign(floor(pos) + s);
	}
	case 6:
		// white noise
		return ibuki(float4(pos, seed));
	}
}
