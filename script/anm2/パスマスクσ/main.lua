--information:パスマスクσ@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
---$script_tips:パスで囲った範囲で画像を切り抜くフィルタ効果です．
--label:Path_S\クリッピング
--filter
--require:${LEAST_AVIUTL_VERSION}
---$track:強さ, min = 0, max = 100, step = 0.01
local intensity = 100

---$checksection:反転
local invert = false

--group:パス設定,true
---$value:頂点数
local num_points = 4

---$select:線タイプ
---折れ線 = 0
---補間移動 = 1
---2次ベジェ曲線 = 2
---3次ベジェ曲線 = 3
local path_type = 3

---$value:点リスト
local points = {0,-100,55.23,-100,100,-55.23,100,0,100,55.23,55.23,100,0,100,-55.23,100,-100,55.23,-100,0,-100,-55.23,-55.23,-100}

---$select:アンカー基準
---回転中心 = 0
---左上 = 1
---上 = 2
---右上 = 3
---左 = 4
---中央 = 5
---右 = 6
---左下 = 7
---下 = 8
---右下 = 9
local mode_anchor_base = 5

---$tips:折れ線近似の最大サンプル間隔，ピクセル単位
---$track:曲線精度, min = 1, max = 128, step = 1, scale = 0.25
local precision = 8

--group:塗り設定,false
---$track:追加幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local inflation = 0

---$select:範囲
---内側 = 0
---奇偶 = 1
---内側反転 = 2
---奇偶反転 = 3
local mode_fill = 0

--group:塗り境界設定,false
---$track:ぼかし幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local antialias = 1

---$track:ノイズ強さ, min = 0, max = 100, step = 0.01
local noise_intensity = 0

---$tips:0 以上だと同じシードでも別オブジェクトだと別の乱数．
---     :負だと同じシードなら別オブジェクトでも同じ乱数．
---$track:noise::シード, min = -65536, max = 65535, step = 1
local noise_seed = 10000

---$track:noise::ドットサイズ, min = 100, max = 6400, step = 0.01, scale = 0.0625
local noise_size = 100

--group:配置,false
---$track:移動X, min = -4000, max = 4000, step = 0.01, scale = 0.25
local X = 0

---$track:移動Y, min = -4000, max = 4000, step = 0.01, scale = 0.25
local Y = 0

--trackgroup@X,Y:Position
---$track:拡大率, min = 0, max = 5000, step = 0.001, scale = 0.16
local zoom = 100

---$track:回転, min = -3600, max = 3600, step = 0.01, scale = 0.1
local rotate = 0

---$tips:パス編集用のアンカーと移動用のアンカーを切り替え．
---$check:アンカー切り替え
local toggle_gui = false

--group:その他,false
---$nolang: name
---$tips:PI = {
---     :  intensity: number?,
---     :  invert: boolean|number|nil,
---     :  num_points: number?,
---     :  path_type: string?,
---     :  points: table?,
---     :  mode_anchor_base: string?,
---     :  precision: number?,
---     :  inflation: number?,
---     :  mode_fill: string?,
---     :  antialias: number?,
---     :  noise_intensity: number?,
---     :  noise_seed: number?,
---     :  noise_size: number?,
---     :  X, Y: number?,
---     :  zoom: number?,
---     :  rotate: number?,
---     :}
---$value:PI
local PI = {}

--[[pixelshader@const_alpha:
---$include "const_alpha.hlsl"
]]
--[[pixelshader@carve:
---$include "../../path_coord_header.hlsl"
---$include "../../ibukihash.hlsl"
---$include "carve.hlsl"
]]
local path_s = require("Path_S");
local obj, math, tonumber, type = obj, math, tonumber, type;

-- see if the points are already buffered.
local pt_buff = type(PI.pt_buff) == "string" and PI.pt_buff or nil;
if pt_buff and pt_buff ~= "tempbuffer" and not pt_buff:match("^cache:.+$") then pt_buff = nil end

-- set anchors.
if obj.getoption("gui") and not pt_buff then
	if toggle_gui then
		obj.setanchor("X,Y", 0, "line", "offset", path_s.anchor_offset(mode_anchor_base));
	else
		num_points = math.max(math.floor(0.5 + (tonumber(num_points) or 4)), 3);
		path_type = math.min(math.max(math.floor(0.5 + path_type), 0), 3);
		local _, pts = path_s.anchor("points", path_type, points, num_points,
			true, nil, mode_anchor_base);
		points = pts;
	end
end

--#region PI / normalize parameters.

-- take parameters.
intensity = tonumber(PI.intensity) or intensity;
invert = path_s.PI.as_bool(PI.invert, invert);
num_points = tonumber(PI.num_points) or num_points;
path_type = path_s.PI.path_type(PI.path_type, path_type);
if type(PI.points) == "table" then points = PI.points end
mode_anchor_base = path_s.PI.mode_anchor_base(PI.mode_anchor_base, mode_anchor_base);
precision = tonumber(PI.precision) or precision;
inflation = tonumber(PI.inflation) or inflation;
mode_fill = path_s.PI.mode_fill(PI.mode_fill, mode_fill);
antialias = tonumber(PI.antialias) or antialias;
noise_intensity = tonumber(PI.noise_intensity) or noise_intensity;
noise_seed = tonumber(PI.noise_seed) or noise_seed;
noise_size = tonumber(PI.noise_size) or noise_size;
X = tonumber(PI.X) or X;
Y = tonumber(PI.Y) or Y;
zoom = tonumber(PI.zoom) or zoom;
rotate = tonumber(PI.rotate) or rotate;

-- normalize parameters.
intensity = math.min(math.max(intensity / 100, 0), 1);
num_points = math.max(math.floor(0.5 + num_points), 3);
precision = math.max(precision, 1);
inflation = math.max(inflation, 0);
antialias = math.max(antialias, 1 / 1024);
noise_intensity = math.min(math.max(noise_intensity / 100, 0), 1);
noise_seed = math.floor(0.5 + noise_seed);
if noise_seed >= 0 then
	noise_seed = noise_seed
		+  2525 * (obj.id % 2 ^ 20)
		+ 13579 * (obj.effect_id % 2 ^ 20)
		+ 54321 * (obj.index % 2 ^ 20);
end
noise_seed = noise_seed % 2 ^ 20;
noise_size = math.max(noise_size / 100, 1);
do
	local cx, cy = path_s.anchor_offset(mode_anchor_base);
	X, Y = X + cx, Y + cy;
end
zoom = math.min(math.max(zoom / 100, 0), 50);
rotate = math.pi / 180 * (rotate % 360);
if intensity <= 0 then return end

--#endregion PI / normalize parameters.

-- further calculations.
local alpha_outer, alpha_inner = 1 - intensity, 1;
if invert then alpha_outer, alpha_inner = alpha_inner, alpha_outer end
if pt_buff then
	path_s.path_mask_area_buffered(
		alpha_outer, alpha_inner, mode_fill,
		inflation, antialias,
		pt_buff, num_points);
else
	path_s.path_mask_area(
		alpha_outer, alpha_inner, mode_fill,
		inflation, {
			width = antialias, intensity = noise_intensity,
			seed = noise_seed,
			cx = X + obj.w / 2, cy = Y + obj.h / 2, size = noise_size
		},
		path_type, points, num_points, precision,
		zoom, rotate, X, Y);
end
