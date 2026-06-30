--information:パス図形σ@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
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

---$track:曲線精度, min = 1, max = 128, step = 1, scale = 0.25
local precision = 8

--group:ライン設定,false
---$track:ライン透明度, min = 0, max = 100, step = 0.01
local alpha_line = 0

---$track:開始位置, min = -400, max = 400, step = 0.001, scale = 0.25
local start_pos = 0

---$track:終了位置, min = -400, max = 400, step = 0.001, scale = 0.25
local end_pos = 100

---$select:端の形状
---円 = 0
---四角 = 1
local end_shape = 0

---$value:破線パターン
local dash_pat = {100,0}

---$checksection:破線周期補正
local dash_adj = true

---$track:破線位置, min = -4000, max = 4000, step = 0.01, scale = 0.25
local dash_pos = 0

--group:塗り設定,false
---$track:塗り追加幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local inflation = 0

---$track:塗り透明度, min = 0, max = 100, step = 0.01
local alpha_fill = 0

---$select:塗り範囲
---内側 = 0
---奇偶 = 1
local mode_fill = 0

--group:ランダム変化,false
---$track:ランダム周期, min = 4, max = 1024, step = 0.001, scale = 0.25
local rand_period = 32

---$track:ランダム振幅, min = 0, max = 1024, step = 0.01, scale = 0.125
local rand_amplify = 0

---$checksection:ランダム固定端
local rand_fix_end = true

---$track:ランダムシード, min = -65536, max = 65535, step = 1
local rand_seed = 10000

--group:その他,false
---$track:ぼかし幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local antialias = 1

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

-- take parameters. (they don't affect to anchors.)
--[[
	PI = {
		num_points:		number?,
		path_type:		string?,
		points:			table?,
		precision:		number?,
		antialias:		number?,
		color_line:		number?,
		alpha_line:		number?,
		line:			number?,
		loop:			boolean|number|nil,
		start_pos:		number?,
		end_pos:		number?,
		end_shape:		string?,
		dash_pat:		table?,
		dash_adj:		boolean|number|nil,
		dash_pos:		number?,
		color_fill:		number?,
		alpha_fill:		number?,
		inflation:		number?,
		mode_fill:		string?,
		rand_period:	number?,
		rand_amplify:	number?,
		rand_fix_end:	boolean|number|nil,
		rand_seed:		number?,
	}
]]
local function as_bool(t, v)
	if type(t) == "boolean" then return t;
	elseif type(t) == "number" then return t ~= 0;
	else return v end
end
num_points = tonumber(PI.num_points) or num_points;
if type(PI.path_type) == "string" then
	local name2num = {
		["折れ線"] = 0, ["補間移動"] = 1, ["2次ベジェ曲線"] = 2, ["3次ベジェ曲線"] = 3,
	};
	path_type = name2num[PI.path_type] or path_type;
end
if type(PI.points) == "table" then points = PI.points end
precision = tonumber(PI.precision) or precision;
antialias = tonumber(PI.antialias) or antialias;
color_line = tonumber(PI.color_line) or color_line;
alpha_line = tonumber(PI.alpha_line) or alpha_line;
line = tonumber(PI.line) or line;
loop = as_bool(PI.loop, loop);
start_pos = tonumber(PI.start_pos) or start_pos;
end_pos = tonumber(PI.end_pos) or end_pos;
if type(PI.end_shape) == "string" then
	local name2num = {
		["円"] = 0, ["四角"] = 1,
	};
	end_shape = name2num[PI.end_shape] or end_shape;
end
if type(PI.dash_pat) == "table" then dash_pat = PI.dash_pat end
dash_adj = as_bool(PI.dash_adj, dash_adj);
dash_pos = tonumber(PI.dash_pos) or dash_pos;
color_fill = tonumber(PI.color_fill) or color_fill;
alpha_fill = tonumber(PI.alpha_fill) or alpha_fill;
inflation = tonumber(PI.inflation) or inflation;
if type(PI.mode_fill) == "string" then
	local name2num = {
		["内側"] = 0, ["奇偶"] = 1,
	};
	mode_fill = name2num[PI.mode_fill] or mode_fill;
end
rand_period = tonumber(PI.rand_period) or rand_period;
rand_amplify = tonumber(PI.rand_amplify) or rand_amplify;
rand_fix_end = as_bool(PI.rand_fix_end, rand_fix_end);
rand_seed = tonumber(PI.rand_seed) or rand_seed;

-- normalize parameters.
num_points = math.max(math.floor(0.5 + num_points), 2);
path_type = math.min(math.max(math.floor(0.5 + path_type), 0), 3);
precision = math.max(precision, 1);
antialias = math.max(antialias, 0);
color_line = color_line % 2 ^ 24;
alpha_line = math.min(math.max(1 - alpha_line / 100, 0), 1);
line = math.max(line, 0);
start_pos = start_pos / 100;
end_pos = end_pos / 100;
end_shape = math.min(math.max(math.floor(0.5 + end_shape), 0), 1);
color_fill = color_fill % 2 ^ 24;
alpha_fill = math.min(math.max(1 - alpha_fill / 100, 0), 1);
inflation = math.max(inflation, 0);
mode_fill = math.min(math.max(math.floor(0.5 + mode_fill), 0), 1);
rand_period = math.max(rand_period, 4);
rand_amplify = math.max(rand_amplify, 0);
rand_seed = math.min(math.max(math.floor(0.5 + rand_seed), -2 ^ 16), 2 ^ 16 - 1);

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
local th = math.max(line * (end_shape == 1 and 0.5 ^ 0.5 or 0.5), inflation) + antialias;
L, T = math.floor(L - th), math.floor(T - th);
R, B = math.max(math.ceil(R + th), L + 1), math.max(math.ceil(B + th), T + 1);

-- calculate the end points from the calculated length.
local end_points = nil;
if end_shape == 1 and has_chrome then
	end_points = path_s.find_end_points(points, num_points, loop, start_pos, end_pos, -L, -T);
end

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
			0, alpha_fill, mode_fill, inflation, antialias,
			cache_name, num_points,
			has_chrome and { name = "tempbuffer", w = obj.w, h = obj.h } or nil);
	end

	-- then the outline part.
	if has_chrome then
		obj.clearbuffer("object", color_line);
		path_s.path_mask_line_buffered(
			0, alpha_line, line, antialias,
			cache_name, num_segments, len, loop,
			start_pos, end_pos, end_shape, end_points,
			dash_pat, dash_pos, dash_adj);
		if has_fill then
			obj.draw();
			obj.copybuffer("object", "tempbuffer");
		end
	end
end
