--information:スパイラルσ@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
--label:Path_S\図形
--require:${LEAST_AVIUTL_VERSION}
---$track:始点X, min = -4000, max = 4000, step = 0.01, scale = 0.25
local start_X = 0

---$track:始点Y, min = -4000, max = 4000, step = 0.01, scale = 0.25
local start_Y = 0

--trackgroup@start_X,start_Y:start_point
---$track:終点X, min = -4000, max = 4000, step = 0.01, scale = 0.25
local end_X = 0

---$track:終点Y, min = -4000, max = 4000, step = 0.01, scale = 0.25
local end_Y = 0

--trackgroup@end_X,end_Y:end_point
---$track:開始半径, min = 0, max = 2000, step = 0.01, scale = 0.25
local start_radius = 0

---$track:終了半径, min = 0, max = 2000, step = 0.01, scale = 0.25
local end_radius = 256

---$track:ライン幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local line = 5

---$color:色
local color = 0xffffff

--group:螺旋設定,true
---$select:形状
---アルキメデス螺旋 = 0
---対数螺旋 = 1
local line_shape = 1

---$track:傾き, min = -400, max = 400, step = 0.001, scale = 0.25
local slope = 10

---$track:回転, min = -3600, max = 3600, step = 0.01, scale = 0.1
local rotate = 0

--group:ライン設定,false
---$track:開始位置, min = 0, max = 100, step = 0.001
local start_pos = 0

---$track:終了位置, min = 0, max = 100, step = 0.001
local end_pos = 100

---$select:端の形状
---円 = 0
---四角 = 1
---平坦 = 2
local end_shape = 0

---$track:曲線精度, min = 1, max = 128, step = 1, scale = 0.25
local precision = 8

---$value:破線パターン
local dash_pat = {100,0}

---$track:破線位置, min = -4000, max = 4000, step = 0.01, scale = 0.25
local dash_pos = 0

---$select:dash::端の形状
---円 = 0
---四角 = 1
---平坦 = 2
local dash_end_shape = 0

--group:ランダム変化,false
---$track:ランダム周期, min = 4, max = 1024, step = 0.01, scale = 0.25
local rand_period = 32

---$track:ランダム振幅, min = 0, max = 1024, step = 0.001, scale = 0.125
local rand_amplify = 0

---$check:ランダム固定端
local rand_fix_end = false

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
		start_radius:		number?,
		end_radius:			number?,
		line:				number?,
		color:				number?,
		line_shape:			string?,
		slope:				number?,
		rotate:				number?,
		start_pos:			number?,
		end_pos:			number?,
		end_shape:			string?,
		precision:			number?,
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
start_radius = tonumber(PI.start_radius) or start_radius;
end_radius = tonumber(PI.end_radius) or end_radius;
line = tonumber(PI.line) or line;
color = tonumber(PI.color) or color;
if type(PI.line_shape) == "string" then
	local name2num = {
		["アルキメデス螺旋"] = 0, ["対数螺旋"] = 1,
	};
	line_shape = name2num[PI.line_shape] or line_shape;
end
slope = tonumber(PI.slope) or slope;
rotate = tonumber(PI.rotate) or rotate;
start_pos = tonumber(PI.start_pos) or start_pos;
end_pos = tonumber(PI.end_pos) or end_pos;
end_shape = path_s.PI.end_shape(PI.end_shape, end_shape);
precision = tonumber(PI.precision) or precision;
dash_pat = type(PI.dash_pat) == "table" and PI.dash_pat or dash_pat;
dash_pos = tonumber(PI.dash_pos) or dash_pos;
dash_end_shape = path_s.PI.end_shape(PI.dash_end_shape, dash_end_shape);
rand_period = tonumber(PI.rand_period) or rand_period;
rand_amplify = tonumber(PI.rand_amplify) or rand_amplify;
rand_fix_end = path_s.PI.as_bool(PI.rand_fix_end, rand_fix_end);
rand_seed = tonumber(PI.rand_seed) or rand_seed;
antialias = tonumber(PI.antialias) or antialias;

-- normalize parameters.
start_radius = math.max(start_radius, 0);
end_radius = math.max(end_radius, 0);
line = math.max(line, 0);
color = math.floor(0.5 + color) % 2 ^ 24;
line_shape = math.min(math.max(math.floor(0.5 + line_shape), 0), 1);
rotate = math.pi / 180 * (rotate % 360);
start_pos = math.min(math.max(start_pos / 100, 0), 1);
end_pos = math.min(math.max(end_pos / 100, 0), 1);
precision = math.max(precision, 1);
rand_period = math.max(rand_period, 4);
rand_amplify = math.max(rand_amplify, 0);
rand_seed = math.min(math.max(math.floor(0.5 + rand_seed), -2 ^ 16), 2 ^ 16 - 1);
antialias = math.max(antialias, 0);

--#endregion PI / normalize parameters.

-- prepare the function for the curve, which maps from a radius to a pair (angle, diff_radius).
local curve_func if line_shape == 0 then
	-- archimedean spiral.
	local s, d = (2 * math.pi / 1024) * slope, precision;
	local a0 = 128 * s;
	function curve_func(r)
		local a = s * r;
		return a - a0, (1 + a ^ 2) ^ -0.5 * d;
	end
else -- line_shape == 1.
	-- logarithmic spiral.
	local s, d, log = slope, (1 + slope ^ 2) ^ -0.5 * precision, math.log;
	function curve_func(r)
		return r > 0 and s * log(r / 128) or 0, d;
	end
end

-- make the array of the points for the curve.
local pts, n_pts = {}, 0 do
	-- poll points from inner to outer.
	local r, R, x, y, dx, dy =
		start_radius, end_radius, start_X, start_Y,
		(end_X - start_X) / (end_radius - start_radius),
		(end_Y - start_Y) / (end_radius - start_radius);
	if r > R then r, R, x, y = R, r, end_X, end_Y end
	while true do
		local a, dr = curve_func(r);
		n_pts = n_pts + 1;
		pts[2 * n_pts - 1], pts[2 * n_pts] =
			r * math.sin(a + rotate) + x,
			r * math.cos(a + rotate) + y;
		if r >= R then break end
		r, dr = math.min(r + dr, R), math.min(dr, R - r);
		x, y = x + dr * dx, y + dr * dy;
	end

	-- reverse the array if necessary.
	if start_radius > end_radius then
		for i = 1, math.floor(n_pts / 2) do
			local j = n_pts + 1 - i;
			pts[2 * i - 1], pts[2 * j - 1] = pts[2 * j - 1], pts[2 * i - 1];
			pts[2 * i], pts[2 * j] = pts[2 * j], pts[2 * i];
		end
	end
end

-- randomize the path.
if rand_amplify > 0 then
	pts, n_pts = path_s.randomize(pts, n_pts, rand_period, rand_amplify,
		rand_fix_end and 1 or 0, rand_seed);
end

-- measure and move the path.
local L, R, T, B, len = path_s.measure(pts, n_pts);
local th = math.ceil(line * (end_shape == 1 and 0.5 ^ 0.5 or 0.5) + antialias);
L, T = math.floor(L - th), math.floor(T - th);
R, B = math.max(math.ceil(R + th), L + 1), math.max(math.ceil(B + th), T + 1);

-- prepare the canvas.
obj.cx, obj.cy = -(L + R) / 2, -(T + B) / 2;
obj.clearbuffer("object", R - L, B - T, color);

-- draw the path.
path_s.path_mask_line(
	0, 1, line, antialias,
	nil, pts, n_pts - 1, false, 1,
	start_pos, end_pos, end_shape, 0,
	dash_pat, dash_pos, false, dash_end_shape,
	1, 0, obj.cx, obj.cy);
