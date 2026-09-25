--information:パス図形σ@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
---$script_tips:パスに沿ったラインと，パス内を塗りつぶした図形を描画するオブジェクトです．
--label:Path_S\図形
--require:${LEAST_AVIUTL_VERSION}
---$track:ライン幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local line = 5

---$color:ライン色
local color_line = 0x808080

---$color:塗り色
local color_fill = 0xffffff

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

---$checksection:ループ
local loop = true

---$tips:折れ線近似の最大サンプル間隔，ピクセル単位
---$track:曲線精度, min = 1, max = 128, step = 1, scale = 0.25
local precision = 8

--group:ライン設定,false
---$track:ライン透明度, min = 0, max = 100, step = 0.01
local alpha_line = 0

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
--group:塗り設定,false
---$track:塗り追加幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local inflation = 0

---$track:塗り透明度, min = 0, max = 100, step = 0.01
local alpha_fill = 0

---$select:塗り範囲
---内側 = 0
---奇偶 = 1
local mode_fill = 0

--group:塗り境界設定,false
---$track:fill::ぼかし幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local fill_antialias = 1

---$nolang: option:Checker, option:Bayer 2x2, option:Bayer 4x4, option:Bayer 256x256, option:IGN, option:White Noise
---$select:fill::ディザリング
---なし = 0
---Checker = 1
---Bayer 2x2 = 2
---Bayer 4x4 = 3
---Bayer 256x256 = 4
---IGN = 5
---White Noise = 6
local fill_dither_pattern = 0

---$tips:0 以上だと同じシードでも別オブジェクトだと別の乱数．
---     :負だと同じシードなら別オブジェクトでも同じ乱数．
---$track:fill::dither::ノイズシード, min = -65536, max = 65535, step = 1
local fill_dither_seed = 20000

--hide@fill_dither_seed:fill_dither_pattern==0
--hide@fill_dither_seed:fill_dither_pattern==1
--hide@fill_dither_seed:fill_dither_pattern==2
--hide@fill_dither_seed:fill_dither_pattern==3
--hide@fill_dither_seed:fill_dither_pattern==4
---$track:fill::ディザ強さ, min = 0, max = 100, step = 0.01
local fill_dither_rate = 100

--hide@fill_dither_rate:fill_dither_pattern==0
---$track:fill::dither::ドットサイズ, min = 100, max = 6400, step = 0.01, scale = 0.0625
local fill_dither_size = 100

--hide@fill_dither_size:fill_dither_pattern==0
--group:ランダム変化,false
---$tips:パスの描画方向に沿ったランダム変動の周期，ピクセル単位
---$track:ランダム周期, min = 4, max = 1024, step = 0.001, scale = 0.25
local rand_period = 32

---$tips:ランダム変動の大きさ，ピクセル単位
---$track:ランダム振幅, min = 0, max = 1024, step = 0.01, scale = 0.125
local rand_amplify = 0

---$tips:パスの始点終点をランダム変動の影響から除外します．
---$checksection:ランダム固定端
local rand_fix_end = true

--hide@rand_fix_end:loop==1
---$tips:0 以上だと同じシードでも別オブジェクトだと別の乱数．
---     :負だと同じシードなら別オブジェクトでも同じ乱数．
---$track:ランダムシード, min = -65536, max = 65535, step = 1
local rand_seed = 10000

--group:その他,false
---$nolang: name
---$tips:PI = {
---     :  line: number?,
---     :  color_line: number?,
---     :  color_fill: number?,
---     :  num_points: number?,
---     :  path_type: string?,
---     :  points: table?,
---     :  loop: boolean|number|nil,
---     :  precision: number?,
---     :  alpha_line: number?,
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
---     :  inflation: number?,
---     :  alpha_fill: number?,
---     :  mode_fill: string?,
---     :  fill_antialias: number?,
---     :  fill_dither_pattern: string?,
---     :  fill_dither_seed: number?,
---     :  fill_dither_rate: number?,
---     :  fill_dither_size: number?,
---     :  rand_period: number?,
---     :  rand_amplify: number?,
---     :  rand_fix_end: boolean|number|nil,
---     :  rand_seed: number?,
---     :}
---$value:PI
local PI = {}

local path_s = require("Path_S");
local obj, math, tonumber, type = obj, math, tonumber, type;

-- set anchors.
if obj.getoption("gui") then
	num_points = math.max(math.floor(0.5 + (tonumber(num_points) or 4)), 2);
	path_type = math.min(math.max(math.floor(0.5 + path_type), 0), 3);
	local _, pts = path_s.anchor("points", path_type, points, num_points - (loop and 0 or 1), loop);
	points = pts;
end

--#region PI / normalize parameters.

-- take parameters. (they don't affect to anchors.)
line = tonumber(PI.line) or line;
color_line = tonumber(PI.color_line) or color_line;
color_fill = tonumber(PI.color_fill) or color_fill;
num_points = tonumber(PI.num_points) or num_points;
if type(PI.path_type) == "string" then
	local name2num = {
		["折れ線"] = 0, ["補間移動"] = 1, ["2次ベジェ曲線"] = 2, ["3次ベジェ曲線"] = 3,
	};
	path_type = name2num[PI.path_type] or path_type;
end
if type(PI.points) == "table" then points = PI.points end
loop = path_s.PI.as_bool(PI.loop, loop);
precision = tonumber(PI.precision) or precision;
alpha_line = tonumber(PI.alpha_line) or alpha_line;
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
inflation = tonumber(PI.inflation) or inflation;
alpha_fill = tonumber(PI.alpha_fill) or alpha_fill;
if type(PI.mode_fill) == "string" then
	local name2num = {
		["内側"] = 0, ["奇偶"] = 1,
	};
	mode_fill = name2num[PI.mode_fill] or mode_fill;
end
fill_antialias = tonumber(PI.fill_antialias) or fill_antialias;
fill_dither_pattern = path_s.PI.dither_pattern(PI.fill_dither_pattern, fill_dither_pattern);
fill_dither_seed = tonumber(PI.fill_dither_seed) or fill_dither_seed;
fill_dither_rate = tonumber(PI.fill_dither_rate) or fill_dither_rate;
fill_dither_size = tonumber(PI.fill_dither_size) or fill_dither_size;
rand_period = tonumber(PI.rand_period) or rand_period;
rand_amplify = tonumber(PI.rand_amplify) or rand_amplify;
rand_fix_end = path_s.PI.as_bool(PI.rand_fix_end, rand_fix_end);
rand_seed = tonumber(PI.rand_seed) or rand_seed;

-- normalize parameters.
line = math.max(line, 0);
color_line = color_line % 2 ^ 24;
color_fill = color_fill % 2 ^ 24;
num_points = math.max(math.floor(0.5 + num_points), 2);
path_type = math.min(math.max(math.floor(0.5 + path_type), 0), 3);
precision = math.max(precision, 1);
alpha_line = math.min(math.max(1 - alpha_line / 100, 0), 1);
start_pos = start_pos / 100;
end_pos = end_pos / 100;
miter_limit = math.max(miter_limit / 100, 1);
antialias = math.max(antialias, 0);
dither_seed = math.floor(0.5 + dither_seed);
if dither_seed >= 0 then
	dither_seed = dither_seed +  2525 * (obj.id % 2 ^ 20);
end
dither_seed = dither_seed % 2 ^ 20;
dither_rate = math.min(math.max(dither_rate / 100, 0), 1);
dither_size = math.max(dither_size / 100, 1);
inflation = math.max(inflation, 0);
alpha_fill = math.min(math.max(1 - alpha_fill / 100, 0), 1);
mode_fill = math.min(math.max(math.floor(0.5 + mode_fill), 0), 1);
fill_antialias = math.max(fill_antialias, 0);
fill_dither_seed = math.floor(0.5 + fill_dither_seed);
if fill_dither_seed >= 0 then
	fill_dither_seed = fill_dither_seed +  2525 * (obj.id % 2 ^ 20);
end
fill_dither_seed = fill_dither_seed % 2 ^ 20;
fill_dither_rate = math.min(math.max(fill_dither_rate / 100, 0), 1);
fill_dither_size = math.max(fill_dither_size / 100, 1);
rand_period = math.max(rand_period, 4);
rand_amplify = math.max(rand_amplify, 0);
rand_seed = math.min(math.max(math.floor(0.5 + rand_seed), -2 ^ 16), 2 ^ 16 - 1);

--#endregion PI / normalize parameters.

-- further calculations.
local has_fill, has_chrome = alpha_fill > 0,
	line > 0 and alpha_line > 0 and start_pos <= end_pos;

-- parse/measure the path.
points, num_points = path_s.poll(path_type, points, num_points - (loop and 0 or 1), loop, precision);
if rand_amplify > 0 then
	-- randomize the path.
	points, num_points = path_s.randomize(points, num_points, rand_period, rand_amplify,
		loop and 2 or rand_fix_end and 1 or 0, rand_seed);
end
local L, R, T, B, len = path_s.measure(points, num_points);
local th = math.max(path_s.line_inflation(end_shape, dash_end_shape, join_shape,
	line, antialias, miter_limit, dash_pat), fill_antialias);
L, T = math.floor(L - th), math.floor(T - th);
R, B = math.max(math.ceil(R + th), L + 1), math.max(math.ceil(B + th), T + 1);

-- prepare the canvas.
obj.clearbuffer("object", R - L, B - T);
obj.cx, obj.cy = -(L + R) / 2, -(T + B) / 2;

-- draw the figures.
if has_fill or has_chrome then
	local cache_name, num_segments = "tempbuffer", num_points;
	if has_fill and has_chrome then
		cache_name = "cache:path_s/coords";
		obj.setoption("drawtarget", "tempbuffer", obj.w, obj.h);
	end

	if not loop and has_fill then
		-- close the loop for drawing the filling part.
		num_points = num_points + 1;
		points[2 * num_points - 1], points[2 * num_points] = points[1], points[2];
	end
	path_s.send(points, num_points, -L, -T, cache_name);

	-- draw the shape of the filling part.
	if has_fill then
		obj.clearbuffer(has_chrome and "tempbuffer" or "object", color_fill);
		path_s.path_mask_area_buffered(
			0, alpha_fill, mode_fill, inflation, {
				width = fill_antialias,
				pattern = fill_dither_pattern, seed = fill_dither_seed,
				rate = fill_dither_rate,
				cx = obj.cx + obj.w / 2, cy = obj.cy + obj.h / 2, size = fill_dither_size,
			},
			cache_name, num_points,
			has_chrome and { name = "tempbuffer", w = obj.w, h = obj.h } or nil);
	end

	-- then the outline part.
	if has_chrome then
		obj.clearbuffer("object", color_line);
		path_s.path_mask_line_buffered(
			0, alpha_line, line, {
				width = antialias,
				pattern = dither_pattern, seed = dither_seed,
				rate = dither_rate,
				cx = obj.cx + obj.w / 2, cy = obj.cy + obj.h / 2, size = dither_size,
			},
			cache_name, num_segments, len, loop,
			start_pos, end_pos, end_shape, join_shape, miter_limit,
			dash_pat, dash_pos, dash_adj, dash_end_shape);
		if has_fill then
			obj.draw();
			assert(obj.copybuffer("object", "tempbuffer"));
		end
	end
end
