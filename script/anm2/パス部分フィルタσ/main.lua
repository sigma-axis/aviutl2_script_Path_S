--information:パス部分フィルタσ@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
---$script_tips:パスで囲った範囲のみに，後続のフィルタ効果，または直接スクリプトを記述して適用するフィルタ効果です．
--label:Path_S\加工
--require:${LEAST_AVIUTL_VERSION}
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

--group:フィルタ設定,false
---$tips:「後続フィルタ」の範囲は「パス部分フィルタσここまで」で区切ることができます．
---$select:追加のフィルタ効果
---後続フィルタ = 0
---スクリプト実行 = 1
local extra_filter = 0

---$text:追加スクリプト
local extra_script = 'obj.effect("グラデーション",\n  "形状","凸形",\n  "角度",30,\n  "開始色",0x00ff00) -- グラデーション適用\nobj.cx=obj.cx+100 -- 位置もずらせる\n'

--hide@extra_script:extra_filter~=1
--group:その他,false
---$nolang: name
---$tips:PI = {
---     :  invert: boolean|number|nil,
---     :  num_points: number?,
---     :  path_type: string?,
---     :  points: table?,
---     :  mode_anchor_base: string?,
---     :  precision: number?,
---     :  inflation: number?,
---     :  mode_fill: string?,
---     :  antialias: number?,
---     :  dither_pattern: string?,
---     :  dither_seed: number?,
---     :  dither_rate: number?,
---     :  dither_size: number?,
---     :  X, Y: number?,
---     :  zoom: number?,
---     :  rotate: number?,
---     :  extra_filter: string?,
---     :}
---$value:PI
local PI = {}

--[[pixelshader@interpolate:
---$include "interpolate.hlsl"
]]
local path_s = require("Path_S");
local obj, math, tonumber, type, tostring = obj, math, tonumber, type, tostring;

-- set anchors.
if obj.getoption("gui") then
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
invert = path_s.PI.as_bool(PI.invert, invert);
num_points = tonumber(PI.num_points) or num_points;
path_type = path_s.PI.path_type(PI.path_type, path_type);
if type(PI.points) == "table" then points = PI.points end
mode_anchor_base = path_s.PI.mode_anchor_base(PI.mode_anchor_base, mode_anchor_base);
precision = tonumber(PI.precision) or precision;
inflation = tonumber(PI.inflation) or inflation;
mode_fill = path_s.PI.mode_fill(PI.mode_fill, mode_fill);
antialias = tonumber(PI.antialias) or antialias;
dither_pattern = path_s.PI.dither_pattern(PI.dither_pattern, dither_pattern);
dither_seed = tonumber(PI.dither_seed) or dither_seed;
dither_rate = tonumber(PI.dither_rate) or dither_rate;
dither_size = tonumber(PI.dither_size) or dither_size;
X = tonumber(PI.X) or X;
Y = tonumber(PI.Y) or Y;
zoom = tonumber(PI.zoom) or zoom;
rotate = tonumber(PI.rotate) or rotate;
if type(PI.extra_filter) == "string" then
	local name2num = {
		["後続フィルタ"] = 0, ["スクリプト実行"] = 1,
	};
	extra_filter = name2num[PI.extra_filter] or extra_filter;
end

-- normalize parameters.
num_points = math.max(math.floor(0.5 + num_points), 3);
precision = math.max(precision, 1);
inflation = math.max(inflation, 0);
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
extra_filter = math.min(math.max(math.floor(0.5 + extra_filter), 0), 1);
if extra_filter == 1 and extra_script:match("^%s*(.-)%s*$") == "" then return end

--#endregion PI / normalize parameters.

-- save the current context.
local cxt; cxt = path_s.partial_filter.make_cxt(
	num_points, path_type, points, precision,
	mode_fill, inflation, {
			width = antialias,
			pattern = dither_pattern, seed = dither_seed,
			rate = dither_rate,
		cx = X + obj.w / 2, cy = Y + obj.h / 2, size = dither_size,
	}, invert,
	X, Y, zoom, rotate);

-- apply following filters.
if extra_filter == 0 then
	-- push the context so subsequent filter can combine.
	path_s.partial_filter.push_cxt(cxt);
	obj.effect();
	-- then pop it off after.
	cxt = path_s.partial_filter.pop_cxt(obj.effect_id);
else
	local f, c, e;
	f, e = loadstring(extra_script);
	if f then c, e = pcall(f) end
	if not (f and c) then
		path_s.print_script_error(tostring(e), extra_script);
		obj.load("text", "");
		return;
	end
end
if obj.w <= 0 or obj.h <= 0 then return end -- subsequent filter already drew.

-- if the context is still alive, combine with the original.
if cxt then path_s.partial_filter.combine(cxt) end

if extra_filter == 0 then
	-- draw to the framebuffer.
	obj.setoption("drawtarget", "framebuffer");
	obj.draw();
end
