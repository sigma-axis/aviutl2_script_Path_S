Texture2D<half4> coords : register(t0);
float decode_float(half3 c)
{
	const uint3 c_i = floor(255 * c + 0.5);
	const int i = (c_i.r << 8) | (c_i.g << 16) | (c_i.b << 24);
	return i / float(1 << 16);
}
float2 get_point(uint i)
{
	static const uint log2_span_x = 12, span_x = 1 << log2_span_x;
	const uint x = (i << 1) & (span_x - 1), y = i >> (log2_span_x - 1);
	return float2(
		decode_float(coords[uint2(x | 0, y)].rgb),
		decode_float(coords[uint2(x | 1, y)].rgb));
}
