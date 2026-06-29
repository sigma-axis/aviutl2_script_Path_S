Texture2D ori : register(t0);
Texture2D eff : register(t1);
Texture2D rate : register(t2);
cbuffer constant0 : register(b0) {
	float2 ofs_ori, ofs_eff;
};
float4 interpolate(float4 pos : SV_Position) : SV_Target
{
	return lerp(
		ori.Load(int3(pos.xy + ofs_ori, 0)),
		eff.Load(int3(pos.xy + ofs_eff, 0)),
		rate.Load(int3(pos.xy, 0)).a);
}
