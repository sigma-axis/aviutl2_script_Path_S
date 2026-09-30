Texture2D src : register(t0);
cbuffer constant0 : register(b0) {
	float4 color;
};
float4 invert_alpha(float4 pos : SV_Position) : SV_Target
{
	const float a = saturate(src[pos.xy].a);
	return (1 - a) * color;
}
