--information:ラインσ@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
--label:Path_S\図形
--require:${LEAST_AVIUTL_VERSION}
---$track:始点X, min = -4000, max = 4000, step = 0.01, scale = 0.25
local start_X = 0

---$track:始点Y, min = -4000, max = 4000, step = 0.01, scale = 0.25
local start_Y = 0

--trackgroup@start_X,start_Y:start_point
---$track:終点X, min = -4000, max = 4000, step = 0.01, scale = 0.25
local end_X = 256

---$track:終点Y, min = -4000, max = 4000, step = 0.01, scale = 0.25
local end_Y = 0

--trackgroup@X,Y:end_point
---$track:ライン幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local line = 5

---$color:色
local color = 0xffffff

--group:曲線設定,true
---$select:形状
---直線 = 0
---正弦波 = 1
---三角波 = 2
---矩形波 = 3
---のこぎり波 = 4
local line_shape = 1

---$track:周期, min = 4, max = 1024, step = 0.001, scale = 0.25
local line_period = 64

---$track:周期位置, min = -4000, max = 4000, step = 0.01, scale = 0.25
local line_phase = 0

---$track:振幅, min = 0, max = 1024, step = 0.01, scale = 0.125
local line_amplify = 32

--group:ライン設定,false
---$track:開始位置, min = 0, max = 100, step = 0.001
local start_pos = 0

---$track:終了位置, min = 0, max = 100, step = 0.001
local end_pos = 100

---$select:端の形状
---円 = 0
---四角 = 1
---平坦 = 2
---三角 = 3
local end_shape = 0

---$select:線結合の形状
---ラウンド = 0
---ベベル = 1
---マイター = 2
---ブランク = 3
local join_shape = 0

---$track:マイター限界, min = 100, max = 3200, step = 0.01, scale = 0.25
local miter_limit = 400

---$value:破線パターン
local dash_pat = {100,0}

---$track:破線位置, min = -4000, max = 4000, step = 0.01, scale = 0.25
local dash_pos = 0

---$select:dash::端の形状
---円 = 0
---四角 = 1
---平坦 = 2
---三角 = 3
local dash_end_shape = 0

--group:ランダム変化,false
---$track:ランダム周期, min = 4, max = 1024, step = 0.01, scale = 0.25
local rand_period = 32

---$track:ランダム振幅, min = 0, max = 1024, step = 0.001, scale = 0.125
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
	obj.setanchor("start_X,start_Y", 0, "line", "color", 0xa0ffa0);
	obj.setanchor("end_X,end_Y", 0, "line", "color", 0xffa0a0);
	obj.setanchor({ start_X, start_Y, end_X, end_Y }, 2, "line");
end

--#region PI / normalize parameters.

-- take parameters.
--[==[
	PI = {
		start_X, start_Y:	number?,
		end_X, end_Y:		number?,
		line:				number?,
		color:				number?,
		line_shape:			string?,
		line_period:		number?,
		line_phase:			number?,
		line_amplify:		number?,
		start_pos:			number?,
		end_pos:			number?,
		end_shape:			string?,
		join_shape:			string?,
		miter_limit:		number?,
		dash_pat:			table?,
		dash_pos:			number?,
		dash_end_shape:		string?,
		rand_period:		number?,
		rand_amplify:		number?,
		rand_fix_end:		boolean|number|nil,
		rand_seed:			number?,
		antialias:			number?,
	}
]==]
start_X = tonumber(PI.start_X) or start_X;
start_Y = tonumber(PI.start_Y) or start_Y;
end_X = tonumber(PI.end_X) or end_X;
end_Y = tonumber(PI.end_Y) or end_Y;
line = tonumber(PI.line) or line;
color = tonumber(PI.color) or color;
if type(PI.line_shape) == "string" then
	local name2num = {
		["直線"] = 0,["正弦波"] = 1,["三角波"] = 2,["矩形波"] = 3, ["のこぎり波"] = 4,
	};
	line_shape = name2num[PI.line_shape] or line_shape;
end
line_period = tonumber(PI.line_period) or line_period;
line_phase = tonumber(PI.line_phase) or line_phase;
line_amplify = tonumber(PI.line_amplify) or line_amplify;
start_pos = tonumber(PI.start_pos) or start_pos;
end_pos = tonumber(PI.end_pos) or end_pos;
end_shape = path_s.PI.end_shape(PI.end_shape, end_shape);
join_shape = path_s.PI.join_shape(PI.join_shape, join_shape);
miter_limit = tonumber(PI.miter_limit) or miter_limit;
dash_pat = type(PI.dash_pat) == "table" and PI.dash_pat or dash_pat;
dash_pos = tonumber(PI.dash_pos) or dash_pos;
dash_end_shape = path_s.PI.end_shape(PI.dash_end_shape, dash_end_shape);
rand_period = tonumber(PI.rand_period) or rand_period;
rand_amplify = tonumber(PI.rand_amplify) or rand_amplify;
rand_fix_end = path_s.PI.as_bool(PI.rand_fix_end, rand_fix_end);
rand_seed = tonumber(PI.rand_seed) or rand_seed;
antialias = tonumber(PI.antialias) or antialias;

-- normalize parameters.
line = math.max(line, 0);
color = math.floor(0.5 + color) % 2 ^ 24;
line_shape = math.min(math.max(math.floor(0.5 + line_shape), 0), 4);
line_period = math.max(line_period, 4);
line_amplify = math.max(line_amplify, 0);
start_pos = math.min(math.max(start_pos / 100, 0), 1);
end_pos = math.min(math.max(end_pos / 100, 0), 1);
miter_limit = math.max(miter_limit / 100, 1);
rand_period = math.max(rand_period, 4);
rand_amplify = math.max(rand_amplify, 0);
rand_seed = math.min(math.max(math.floor(0.5 + rand_seed), -2 ^ 16), 2 ^ 16 - 1);
antialias = math.max(antialias, 0);

--#endregion PI / normalize parameters.

-- further calculations.
local length = ((end_X - start_X) ^ 2 + (end_Y - start_Y) ^ 2) ^ 0.5;
if length <= 0 then
	-- no image.
	obj.setoption("draw_state", true);
	return;
end

-- make the table of the points for the curve.
local n_pts, pts
if line_shape == 0 or line_amplify <= 0 then
	-- straight line.
	n_pts, pts = 2, { 0, 0, length, 0 };
elseif line_shape == 1 then
	-- sine wave.
	local dp, p = math.min(2 ^ -math.ceil(math.log((line_period + line_amplify) / 8, 2)), 1 / 16),
		((-line_phase) / line_period) % 1;
	n_pts, pts = 1, { 0, line_amplify * math.sin(2 * math.pi * p) };
	local x do
		local p1 = (math.floor(p / dp) + 1) * dp;
		x = (p1 - p) * line_period;
		p = p1 % 1;
	end
	while x < length do
		n_pts = n_pts + 1;
		pts[2 * n_pts - 1], pts[2 * n_pts] =
			x, line_amplify * math.sin(2 * math.pi * p);
		x, p = x + dp * line_period, (p + dp) % 1;
	end
	p = (p - (x - length) / line_period) % 1;
	n_pts = n_pts + 1;
	pts[2 * n_pts - 1], pts[2 * n_pts] =
		length, line_amplify * math.sin(2 * math.pi * p);
elseif line_shape == 2 then
	-- triangular wave.
	local p = (((-line_phase) / line_period) - 0.25) % 1;
	n_pts, pts = 1, { 0, line_amplify * (4 * math.abs(p - 0.5) - 1) };
	local x do
		local p1 = (math.floor(2 * p) + 1) / 2;
		x = (p1 - p) * line_period;
		p = p1 % 1;
	end
	while x < length do
		n_pts = n_pts + 1;
		pts[2 * n_pts - 1], pts[2 * n_pts] =
			x, line_amplify * (p > 0 and -1 or 1);
		x, p = x + 0.5 * line_period, (p + 0.5) % 1;
	end
	p = (p - (x - length) / line_period) % 1;
	n_pts = n_pts + 1;
	pts[2 * n_pts - 1], pts[2 * n_pts] =
		length, line_amplify * (4 * math.abs(p - 0.5) - 1);
elseif line_shape == 3 then
	-- square wave.
	local p = ((-line_phase) / line_period) % 1;
	n_pts, pts = 1, { 0, line_amplify * (p < 0.5 and -1 or 1) };
	local x do
		local p1 = (math.floor(2 * p) + 1) / 2;
		x = (p1 - p) * line_period;
		p = p1 % 1;
	end
	while x < length do
		n_pts = n_pts + 2;
		pts[2 * n_pts - 3], pts[2 * n_pts - 2] =
			x, line_amplify * (p > 0 and -1 or 1);
		pts[2 * n_pts - 1], pts[2 * n_pts] = pts[2 * n_pts - 3], -pts[2 * n_pts - 2];
		x, p = x + 0.5 * line_period, (p + 0.5) % 1;
	end
	p = ((x - length) / line_period - p) % 1;
	n_pts = n_pts + 1;
	pts[2 * n_pts - 1], pts[2 * n_pts] =
		length, line_amplify * (p < 0.5 and 1 or -1);
else -- line_shape == 4
	-- saw wave.
	local p = ((-line_phase) / line_period) % 1;
	n_pts, pts = 1, { 0, line_amplify * (2 * p - 1) };
	local x do
		local p1 = (math.floor(p) + 1);
		x = (p1 - p) * line_period;
		p = 0;
	end
	while x < length do
		n_pts = n_pts + 2;
		pts[2 * n_pts - 3], pts[2 * n_pts - 2] =
			x, line_amplify;
		pts[2 * n_pts - 1], pts[2 * n_pts] = pts[2 * n_pts - 3], -pts[2 * n_pts - 2];
		x = x + line_period;
	end
	p = 1 - (((x - length) / line_period) % 1);
	n_pts = n_pts + 1;
	pts[2 * n_pts - 1], pts[2 * n_pts] =
		length, line_amplify * (2 * p - 1);
end

-- randomize the line.
if rand_amplify > 0 then
	pts, n_pts = path_s.randomize(pts, n_pts, rand_period, rand_amplify,
		rand_fix_end and 1 or 0, rand_seed);
end

-- measure and move the path.
path_s.transform(pts, n_pts, 1, math.atan2(end_Y - start_Y, end_X - start_X), start_X, start_Y);
local L, R, T, B = path_s.measure(pts, n_pts);
local th = math.ceil(line * math.max(
	end_shape == 1 and 2 ^ 0.5 or 1,
	join_shape == 2 and miter_limit or 1) / 2
	+ antialias);
L, T = math.floor(L - th), math.floor(T - th);
R, B = math.max(math.ceil(R + th), L + 1), math.max(math.ceil(B + th), T + 1);

-- prepare the canvas.
obj.cx, obj.cy = -(L + R) / 2, -(T + B) / 2;
obj.clearbuffer("object", R - L, B - T, color);

-- draw the line.
path_s.path_mask_line(
	0, 1, line, antialias,
	nil, pts, n_pts - 1, false, 1,
	start_pos, end_pos, end_shape, join_shape, miter_limit,
	dash_pat, dash_pos, false, dash_end_shape,
	1, 0, obj.cx, obj.cy);
