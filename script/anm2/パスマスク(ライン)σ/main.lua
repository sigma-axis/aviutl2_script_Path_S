--information:パスマスク(ライン)σ@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
---$script_tips:パスの通ったライン上の画像を切り抜くフィルタ効果です．
--label:Path_S\クリッピング
--filter
--require:${LEAST_AVIUTL_VERSION}
---$track:強さ, min = 0, max = 100, step = 0.01
local intensity = 100

---$checksection:反転
local invert = false

---$track:ライン幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local line = 5

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
local points = {-100.00,50.00,-75.00,0.00,-50.00,-50.00,-25.00,-50.00,0.00,-50.00,0.00,50.00,25.00,50.00,50.00,50.00,75.00,0.00,100.00,-50.00}

---$checksection:ループ
local loop = false

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

--group:ライン設定,false
---$tips:ライン描画範囲の始点，パス全体長からの % 単位
---$track:開始位置, min = -400, max = 400, step = 0.001, scale = 0.25
local start_pos = 0

---$tips:ライン描画範囲の終点，パス全体長からの % 単位
---$track:終了位置, min = -400, max = 400, step = 0.001, scale = 0.25
local end_pos = 100

---$select:端の形状
---円 = 0
---四角 = 1
---平坦 = 2
---三角 = 3
---リボン = 4
local end_shape = 0

---$select:線結合の形状
---ラウンド = 0
---ベベル = 1
---マイター = 2
---ブランク = 3
---ブランク+ラウンド = 4
---ブランク+ベベル = 5
local join_shape = 0

---$track:マイター限界, min = 100, max = 3200, step = 0.001, scale = 0.25
local miter_limit = 400

--hide@miter_limit:join_shape<2
--hide@miter_limit:join_shape==3
---$tips:実線部分の長さと空白部分の長さを交互に記述，ピクセル単位
---$value:破線パターン
local dash_pat = {100,0}

---$tips:ループが ON の場合のみ有効，ループ 1 周での破線パターンが整数回になるよう補正
---$checksection:破線周期補正
local dash_adj = true

---$track:破線位置, min = -4000, max = 4000, step = 0.01, scale = 0.25
local dash_pos = 0

---$select:dash::端の形状
---円 = 0
---四角 = 1
---平坦 = 2
---三角 = 3
---リボン = 4
local dash_end_shape = 0

--group:ライン境界設定,false
---$track:ぼかし幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local antialias = 1

---$nolang: option:Checker, option:Bayer 2x2, option:Bayer 4x4, option:Bayer 256x256, option:IGN, option:White Noise
---$select:ディザリング
---なし = 0
---Checker = 1
---Bayer 2x2 = 2
---Bayer 4x4 = 3
---Bayer 256x256 = 4
---IGN = 5
---White Noise = 6
local dither_pattern = 0

---$tips:0 以上だと同じシードでも別オブジェクトだと別の乱数．
---     :負だと同じシードなら別オブジェクトでも同じ乱数．
---$track:dither::ノイズシード, min = -65536, max = 65535, step = 1
local dither_seed = 10000

--hide@dither_seed:dither_pattern==0
--hide@dither_seed:dither_pattern==1
--hide@dither_seed:dither_pattern==2
--hide@dither_seed:dither_pattern==3
--hide@dither_seed:dither_pattern==4
---$track:ディザ強さ, min = 0, max = 100, step = 0.01
local dither_rate = 100

--hide@dither_rate:dither_pattern==0
---$track:dither::ドットサイズ, min = 100, max = 6400, step = 0.01, scale = 0.0625
local dither_size = 100

--hide@dither_size:dither_pattern==0
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
---     :  line: number?,
---     :  num_points: number?,
---     :  path_type: string?,
---     :  points: table?,
---     :  loop: boolean|number|nil,
---     :  mode_anchor_base: string?,
---     :  precision: number?,
---     :  start_pos: number?,
---     :  end_pos: number?,
---     :  end_shape: string?,
---     :  join_shape: string?,
---     :  miter_limit: number?,
---     :  dash_pat: table?,
---     :  dash_adj: boolean|number|nil,
---     :  dash_pos: number?,
---     :  dash_end_shape: string?,
---     :  antialias: number?,
---     :  dither_pattern: string?,
---     :  dither_seed: number?,
---     :  dither_rate: number?,
---     :  dither_size: number?,
---     :  X, Y: number?,
---     :  zoom: number?,
---     :  rotate: number?,
---     :}
---$value:PI
local PI = {}

--[[pixelshader@carve:
---$include "../../path_coord_header.hlsl"
---$include "../../ibukihash.hlsl"
---$include "../../noise_func.hlsl"
---$include "line_dist_header.hlsl"
---$include "carve.hlsl"
]]
--[[pixelshader@carve_dash:
---$include "../../path_coord_header.hlsl"
---$include "../../ibukihash.hlsl"
---$include "../../noise_func.hlsl"
---$include "line_dist_header.hlsl"
---$include "carve_dash.hlsl"
]]
local path_s = require("Path_S");
local obj, math, tonumber, type = obj, math, tonumber, type;

-- see if the points are already buffered.
local pt_buff, len_buff =
	type(PI.pt_buff) == "string" and PI.pt_buff or nil,
	tonumber(PI.len_buff);
if (pt_buff and pt_buff ~= "tempbuffer" and not pt_buff:match("^cache:.+$")) or not (len_buff and len_buff > 0) then pt_buff, len_buff = nil, -1 end

-- set anchors.
if obj.getoption("gui") and not pt_buff then
	if toggle_gui then
		obj.setanchor("X,Y", 0, "line", "offset", path_s.anchor_offset(mode_anchor_base));
	else
		num_points = math.max(math.floor(0.5 + (tonumber(num_points) or 4)), 2);
		path_type = math.min(math.max(math.floor(0.5 + path_type), 0), 3);
		local _, pts = path_s.anchor("points", path_type,
			points, num_points - (loop and 0 or 1), loop, nil, mode_anchor_base);
		points = pts;
	end
end

--#region PI / normalize parameters.

-- take parameters.
intensity = tonumber(PI.intensity) or intensity;
invert = path_s.PI.as_bool(PI.invert, invert);
line = tonumber(PI.line) or line;
num_points = tonumber(PI.num_points) or num_points;
path_type = path_s.PI.path_type(PI.path_type, path_type);
if type(PI.points) == "table" then points = PI.points end
loop = path_s.PI.as_bool(PI.loop, loop);
mode_anchor_base = path_s.PI.mode_anchor_base(PI.mode_anchor_base, mode_anchor_base);
precision = tonumber(PI.precision) or precision;
start_pos = tonumber(PI.start_pos) or start_pos;
end_pos = tonumber(PI.end_pos) or end_pos;
end_shape = path_s.PI.end_shape(PI.end_shape, end_shape);
join_shape = path_s.PI.join_shape(PI.join_shape, join_shape);
miter_limit = tonumber(PI.miter_limit) or miter_limit;
if type(PI.dash_pat) == "table" then dash_pat = PI.dash_pat end
dash_adj = path_s.PI.as_bool(PI.dash_adj, dash_adj);
dash_pos = tonumber(PI.dash_pos) or dash_pos;
dash_end_shape = path_s.PI.end_shape(PI.dash_end_shape, dash_end_shape);
antialias = tonumber(PI.antialias) or antialias;
dither_pattern = path_s.PI.dither_pattern(PI.dither_pattern, dither_pattern);
dither_seed = tonumber(PI.dither_seed) or dither_seed;
dither_rate = tonumber(PI.dither_rate) or dither_rate;
dither_size = tonumber(PI.dither_size) or dither_size;
X = tonumber(PI.X) or X;
Y = tonumber(PI.Y) or Y;
zoom = tonumber(PI.zoom) or zoom;
rotate = tonumber(PI.rotate) or rotate;

-- normalize parameters.
intensity = math.min(math.max(intensity / 100, 0), 1);
line = math.max(line, 0);
num_points = math.max(math.floor(0.5 + num_points), 2);
precision = math.max(precision, 1);
start_pos = start_pos / 100;
end_pos = end_pos / 100;
miter_limit = math.max(miter_limit / 100, 1);
antialias = math.max(antialias, 0);
dither_seed = math.floor(0.5 + dither_seed);
if dither_seed >= 0 then
	dither_seed = dither_seed
		+  2525 * (obj.id % 2 ^ 20)
		+ 13579 * (obj.effect_id % 2 ^ 20)
		+ 54321 * (obj.index % 2 ^ 20);
end
dither_seed = dither_seed % 2 ^ 20;
dither_rate = math.min(math.max(dither_rate / 100, 0), 1);
dither_size = math.max(dither_size / 100, 1);
do
	local cx, cy = path_s.anchor_offset(mode_anchor_base);
	X, Y = X + cx, Y + cy;
end
zoom = math.min(math.max(zoom / 100, 0), 50);
rotate = math.pi / 180 * (rotate % 360);
if intensity <= 0 then return end

--#endregion PI / normalize parameters.

local alpha_outer, alpha_inner = 1 - intensity, 1;
if invert then alpha_outer, alpha_inner = alpha_inner, alpha_outer end
if pt_buff then
	path_s.path_mask_line_buffered(
		alpha_outer, alpha_inner, line, antialias,
		pt_buff, num_points, len_buff, loop,
		start_pos, end_pos, end_shape, join_shape, miter_limit,
		dash_pat, dash_pos, dash_adj, dash_end_shape);
else
	path_s.path_mask_line(
		alpha_outer, alpha_inner, line, {
			width = antialias,
			pattern = dither_pattern, seed = dither_seed,
			rate = dither_rate,
			cx = X + obj.w / 2, cy = Y + obj.h / 2, size = dither_size,
		},
		path_type, points, num_points - (loop and 0 or 1), loop, precision,
		start_pos, end_pos, end_shape, join_shape, miter_limit,
		dash_pat, dash_pos, dash_adj, dash_end_shape,
		zoom, rotate, X, Y);
end
