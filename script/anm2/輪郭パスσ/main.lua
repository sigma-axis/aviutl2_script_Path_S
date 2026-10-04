--information:輪郭パスσ@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
---$script_tips:アンカーで選んだ部分の輪郭にラインを引きます．
--label:Path_S\装飾
--require:${LEAST_AVIUTL_VERSION}
---$select:対象
---1個 = 0
---複数 = 1
---全て = 2
local mode_targets = 0

---$nolang: name
---$track:X, min = -4000, max = 4000, step = 0.01, scale = 0.25
local X = 0

--hide@X:mode_targets~=0
---$nolang: name
---$track:Y, min = -4000, max = 4000, step = 0.01, scale = 0.25
local Y = 0

---$value:対象個数
local num_points = 2

--hide@num_points:mode_targets~=1
---$value:点リスト
local points = {-100,0,100,0}

--hide@points:mode_targets~=1
--hide@Y:mode_targets~=0
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

--hide@mode_anchor_base:mode_targets==2
---$track:ライン幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local line = 5

---$color:色
local color= 0xffffff

-- ---$track:曲線精度, min = 1, max = 128, step = 1, scale = 0.25
-- _local precision = 8

--group:境界設定,false
---$track:αしきい値, min = 0, max = 100, step = 0.01
local thresh = 50

---$checksection:角で隣接扱い
local conn_corner = false

---$track:境界精度, min = 10, max = 200, step = 0.01, scale = 0.5
local prec_track = 50

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

---$tips:実線部分の長さと空白部分の長さを交互に記述，ピクセル単位
---$value:破線パターン
local dash_pat = {100,0}

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
--group:ランダム変化,false
---$tips:パスの描画方向に沿ったランダム変動の周期，ピクセル単位
---$track:ランダム周期, min = 4, max = 1024, step = 0.01, scale = 0.25
local rand_period = 32

---$tips:ランダム変動の大きさ，ピクセル単位
---$track:ランダム振幅, min = 0, max = 1024, step = 0.001, scale = 0.125
local rand_amplify = 0

---$tips:0 以上だと同じシードでも別オブジェクトだと別の乱数．
---     :負だと同じシードなら別オブジェクトでも同じ乱数．
---$track:ランダムシード, min = -65536, max = 65535, step = 1
local rand_seed = 10000

--group:合成,false
---$select:モード
---前方から合成 = 0
---後方から合成 = 1
local mode_draw = 0

---$track:ライン透明度, min = 0, max = 100, step = 0.01
local line_alpha = 0

---$track:元画像透明度, min = 0, max = 100, step = 0.01
local orig_alpha = 0

--group:フィルタ設定,false
-- ---$tips:「後続フィルタ」の範囲は「後続フィルタここまで」で区切ることができます．
---$select:追加のフィルタ効果
---なし = 0
---後続フィルタ = 1
---スクリプト実行 = 2
local extra_filter = 0

---$text:追加スクリプト
local extra_script = 'obj.effect("グラデーション",\n  "形状","凸形",\n  "角度",30,\n  "開始色",0x00ff00) -- グラデーション適用\nobj.cx=obj.cx+100 -- 位置もずらせる\n'

--hide@extra_script:extra_filter~=2
--group:その他,false
---$nolang: name
---$value:PI
local PI = {}

--[[pixelshader@invert_alpha:
---$include "invert_alpha.hlsl"
]]
local path_s = require("Path_S");
local obj, math, tonumber, type = obj, math, tonumber, type;

if obj.getoption("gui") and mode_targets ~= 2 then
	local cx, cy = path_s.anchor_offset(mode_anchor_base);
	num_points = math.floor(0.5 + num_points);
	if mode_targets == 0 then
		obj.setanchor("X,Y", 0, "line", "offset", cx, cy);
	elseif num_points > 0 then
		for i = #points + 1, 2 * num_points do points[i] = 0 end
		obj.setanchor("points", num_points, points, "offset", cx, cy);
	end
end

--#region PI / normalize parameters.

-- take parameters.
-- TODO: PI
--[[

]]

-- normalize parameters.
mode_targets = math.min(math.max(math.floor(0.5 + mode_targets), 0), 2);
if mode_targets == 0 then num_points, points = 1, { X, Y };
elseif mode_targets == 1 then
	num_points = math.min(math.max(math.floor(0.5 + num_points), 1), math.floor(#points / 2));
end
line = math.max(line, 0);
color = math.floor(0.5 + color) % 2 ^ 24;
thresh = math.min(math.max(thresh / 100, 0), 1);
prec_track = math.max(prec_track / 100, 1 / 16);
start_pos = start_pos / 100;
end_pos = end_pos / 100;
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
rand_period = math.max(rand_period, 4);
rand_amplify = math.max(rand_amplify, 0);
rand_seed = math.min(math.max(math.floor(0.5 + rand_seed), -2 ^ 16), 2 ^ 16 - 1);
mode_draw = math.min(math.max(math.floor(0.5 + mode_draw), 0), 1);
line_alpha = math.min(math.max(1 - line_alpha / 100, 0), 1);
orig_alpha = math.min(math.max(1 - orig_alpha / 100, 0), 1);

--#endregion PI / normalize parameters.

-- collect paths.
local paths, cx, cy = {}, nil, nil;
if mode_targets < 2 then
	cx, cy = path_s.anchor_offset(mode_anchor_base);
	for i = 1, num_points do
		points[2 * i - 1] = math.floor(0.5 + points[2 * i - 1] + cx + obj.w / 2);
		points[2 * i] = math.floor(0.5 + points[2 * i] + cy + obj.h / 2);
	end
	paths = path_s.boundary.find("object", points, num_points,
		thresh, conn_corner, prec_track);
else
	cx, cy = path_s.anchor_offset(0); -- rotation center.
	paths = path_s.boundary.find_all("object", thresh, conn_corner, prec_track);
end
if #paths == 0 then return end

if rand_amplify > 0 then
	-- randomize the path.
	for i = 1, #paths do
		local p = paths[i];
		local pts, n_pts = path_s.randomize(p.points, p.num_segments + 1,
			rand_period, rand_amplify, 2, rand_seed);
		p.points, p.num_segments = pts, n_pts - 1;
	end
end

-- measure paths.
local w, h, L, R, T, B = obj.w, obj.h, 0, obj.w, 0, obj.h;
for i = 1, #paths do
	local p = paths[i];
	local l, r, t, b = path_s.measure(p.points, p.num_segments);
	L, R = math.min(L, l), math.max(R, r);
	T, B = math.min(T, t), math.max(B, b);
end
local th = path_s.line_inflation(end_shape, dash_end_shape, 0, line, antialias, 1, dash_pat);
L, R = math.floor(L - th), math.ceil(R + th);
T, B = math.floor(T - th), math.ceil(B + th);
local W, H, dcx, dcy = R - L, B - T, (w - L - R) / 2, (h - T - B) / 2;

-- backup the original image.
local cache_name = "cache:path_s/track/obj#"..obj.effect_id;
assert(obj.copybuffer(cache_name, "object"));
local cx0, cy0 = obj.cx, obj.cy;

-- carve the shape.
obj.cx, obj.cy = obj.cx + dcx, obj.cy + dcy;
obj.clearbuffer("object", W, H, color);
for i = 1, #paths do
	local p = paths[i];
	path_s.path_mask_line(#paths > 1 and 1 or 0, #paths > 1 and 0 or 1,
		line, {
			width = antialias,
			pattern = dither_pattern,
			rate = dither_rate,
			seed = dither_seed,
			size = dither_size,
			cx = cx + dcx - w / 2,
			cy = cy + dcy - h / 2,
		}, nil,
		p.points, p.num_segments, true, 8,
		start_pos, end_pos, end_shape, 0, 1,
		dash_pat, dash_pos, true, dash_end_shape,
		1, 0, dcx - w / 2, dcy - h / 2);
end
if #paths > 1 then
	obj.pixelshader("invert_alpha", "object", "object", {
		bit.band(color, 0xff0000) / 0xff0000,
		bit.band(color, 0x00ff00) / 0x00ff00,
		bit.band(color, 0x0000ff) / 0x0000ff, 1;
	});
end

-- save the current context.
local cxt; cxt = path_s.post_effect.make_cxt(
	mode_draw, orig_alpha, line_alpha,
	w, h, cx0, cy0, cache_name);

-- apply following filters.
if extra_filter == 1 then
	-- push the context so subsequent filter can combine.
	path_s.post_effect.push_cxt(cxt);
	obj.effect();
	-- then pop it off after.
	cxt = path_s.post_effect.check_cxt(path_s.context_manager.pop(obj.effect_id));
elseif extra_filter == 2 then
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
if cxt then path_s.post_effect.combine(cxt) end

if extra_filter == 1 then
	-- draw to the framebuffer.
	obj.setoption("drawtarget", "framebuffer");
	obj.draw();
end
