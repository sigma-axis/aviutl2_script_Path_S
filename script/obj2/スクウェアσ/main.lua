--information:スクウェアσ@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
--label:Path_S\図形
--require:${LEAST_AVIUTL_VERSION}
---$track:幅, min = 0, max = 4000, step = 0.01, scale = 0.25
local width = 100

---$track:高さ, min = 0, max = 4000, step = 0.01, scale = 0.25
local height = 100

---$track:ライン幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local line = 5

---$color:ライン色
local color_line = 0x808080

---$color:塗り色
local color_fill = 0xffffff

---$track:角半径, min = 0, max = 2000, step = 0.01, scale = 0.25
local radius = 40

--group:整列,false
---$track:水平揃え, min = -100, max = 100, step = 0.001
local align_x = 0

---$track:垂直揃え, min = -100, max = 100, step = 0.001
local align_y = 0

--group:丸角設定,false
---$check:半径均一
local uniform = true

---$track:右上半径, min = 0, max = 2000, step = 0.01, scale = 0.25
local r_RT = 40

---$track:右下半径, min = 0, max = 2000, step = 0.01, scale = 0.25
local r_RB = 40

---$track:左下半径, min = 0, max = 2000, step = 0.01, scale = 0.25
local r_LB = 40

---$track:丸角縦横比, min = -100, max = 100, step = 0.001
local aspect = 0

---$check:丸角縦横比固定
local fixed_aspect = true

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

---$track:破線位置, min = -4000, max = 4000, step = 0.01, scale = 0.25
local dash_pos = 0

--group:塗り設定,false
---$track:塗り追加幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local inflation = 0

---$track:塗り透明度, min = 0, max = 100, step = 0.01
local alpha_fill = 0

--group:ランダム変化,false
---$track:ランダム周期, min = 4, max = 1024, step = 0.001, scale = 0.25
local rand_period = 32

---$track:ランダム振幅, min = 0, max = 1024, step = 0.01, scale = 0.125
local rand_amplify = 0

---$track:ランダムシード, min = -65536, max = 65535, step = 1
local rand_seed = 10000

--group:その他,false
---$track:ぼかし幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local antialias = 1

---$value:PI
local PI = {}

local path_s = require("Path_S");
local obj, math, tonumber, type = obj, math, tonumber, type;

-- take parameters.
local function apply_aspect(r, a)
	return math.min(1 - a, 1) * r, math.min(1 + a, 1) * r;
end
radius = math.max(radius, 0);
aspect = math.min(math.max(aspect / 100, -1), 1);
local radii = {
	{ apply_aspect(radius, aspect) },
	{ apply_aspect(uniform and radius or math.max(r_RT, 0), aspect) },
	{ apply_aspect(uniform and radius or math.max(r_RB, 0), aspect) },
	{ apply_aspect(uniform and radius or math.max(r_LB, 0), aspect) },
};

--[==[
	PI = {
		width:			number?,
		height:			number?,
		align_x:		number?,
		align_y:		number?,
		radii:			table|number|nil,
		fixed_aspect:	boolean|number|nil,
		antialias:		number?,
		color_line:		number?,
		alpha_line:		number?,
		line:			number?,
		start_pos:		number?,
		end_pos:		number?,
		end_shape:		string?,
		dash_pat:		table?,
		dash_pos:		number?,
		color_fill:		number?,
		alpha_fill:		number?,
		inflation:		number?,
		rand_period:	number?,
		rand_amplify:	number?,
		rand_seed:		number?,
	}
]==]
local function as_bool(t, v)
	if type(t) == "boolean" then return t;
	elseif type(t) == "number" then return t ~= 0;
	else return v end
end
local function as_pair(c)
	if type(c) == "number" then return c, c;
	elseif type(c) == "table" then
		local x, y = tonumber(c[1]), tonumber(c[2]);
		if x and y then return x, y end
	end
	return nil;
end
width = tonumber(PI.width) or width;
height = tonumber(PI.height) or height;
align_x = tonumber(PI.align_x) or align_x;
align_y = tonumber(PI.align_y) or align_y;
if type(PI.radii) == "number" then
	local r = PI.radii;
	radii = { { r, r }, { r, r }, { r, r }, { r, r } };
elseif type(PI.radii) == "table" then
	if PI.radii.uniform then
		local x, y = as_pair(PI.radii.uniform);
		if x then radii = { { x, y }, { x, y }, { x, y }, { x, y } } end
	end
	for i = 1, 4 do
		local x, y = as_pair(PI.radii[i]);
		if x then radii[i] = { x, y } end
	end
end
fixed_aspect = as_bool(PI.fixed_aspect, fixed_aspect);
antialias = tonumber(PI.antialias) or antialias;
color_line = tonumber(PI.color_line) or color_line;
alpha_line = tonumber(PI.alpha_line) or alpha_line;
line = tonumber(PI.line) or line;
start_pos = tonumber(PI.start_pos) or start_pos;
end_pos = tonumber(PI.end_pos) or end_pos;

if type(PI.end_shape) == "string" then
	local name2num = {
		["円"] = 0, ["四角"] = 1,
	};
	end_shape = name2num[PI.end_shape] or end_shape;
end
if type(PI.dash_pat) == "table" then dash_pat = PI.dash_pat end
dash_pos = tonumber(PI.dash_pos) or dash_pos;
color_fill = tonumber(PI.color_fill) or color_fill;
alpha_fill = tonumber(PI.alpha_fill) or alpha_fill;
inflation = tonumber(PI.inflation) or inflation;
rand_period = tonumber(PI.rand_period) or rand_period;
rand_amplify = tonumber(PI.rand_amplify) or rand_amplify;
rand_seed = tonumber(PI.rand_seed) or rand_seed;

-- normalize parameters.
if width <= 0 or height <= 0 then return end -- early return if empty.
align_x = math.min(math.max(align_x / 100, -1), 1);
align_y = math.min(math.max(align_y / 100, -1), 1);
for i = 1, 4 do
	radii[i][1], radii[i][2] = math.max(radii[i][1], 0), math.max(radii[i][2], 0);
end
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
rand_period = math.max(rand_period, 4);
rand_amplify = math.max(rand_amplify, 0);
rand_seed = math.min(math.max(math.floor(0.5 + rand_seed), -2 ^ 16), 2 ^ 16 - 1);

-- avoid corner sizes from being too large.
do local prev = {
		{ radii[1][1], radii[1][2] },
		{ radii[2][1], radii[2][2] },
		{ radii[3][1], radii[3][2] },
		{ radii[4][1], radii[4][2] },
	};
	for i = 1, 4 do
		local j, r1, r2, m = 2 - (i % 2),
			radii[i], radii[(i % 4) + 1],
			(i % 2) > 0 and width or height;
		if r1[j] + r2[j] >= m then
			local c1, c2 = r1[j], r2[j];
			if c1 <= m / 2 then c2 = m - c1;
			elseif c2 <= m / 2 then c1 = m - c2;
			else c1, c2 = m / 2, m / 2 end
			r1[j], r2[j] = c1, c2;
		end
	end
	-- adjust aspect ratios if specified to be fixed.
	if fixed_aspect then
		for i = 1, 4 do
			local r, r0 = radii[i], prev[i];
			local u, v = r[1] * r0[2], r[2] * r0[1];
			if u > v then r[1] = v / r0[2];
			elseif u < v then r[2] = u / r0[1] end
		end
	end
end

-- further calculations.
local has_fill, has_chrome = alpha_fill > 0,
	line > 0 and alpha_line > 0 and start_pos <= end_pos;

-- generate a path.
local pts, n_pts = { (radii[1][1] - radii[2][1]) / 2, -height / 2 }, 1;
for i = 1, 4 do
	local r, precision = radii[(i % 4) + 1], 0.25; -- difference at most 0.25 pixels is allowed.
	local rx, ry, a0 = r[1], r[2], (i / 2 - 1) * math.pi;
	local N = math.ceil(2 ^ -2.5 * math.pi * (math.max(rx, ry) / precision) ^ 0.5);

	local cx, cy = width / 2 - rx, height / 2 - ry;
	if i > 2 then cx = -cx end
	if (i % 4) < 2 then cy = -cy end
	for j = 0, N do
		local a = a0 + (j / math.max(N, 1)) * math.pi / 2;
		n_pts = n_pts + 1;
		pts[2 * n_pts - 1], pts[2 * n_pts] =
			cx + rx * math.cos(a), cy + ry * math.sin(a);
	end
end
n_pts = n_pts + 1;
pts[2 * n_pts - 1], pts[2 * n_pts] = pts[1], pts[2];

if rand_amplify > 0 then
	-- randomize the path.
	pts, n_pts = path_s.randomize(pts, n_pts, rand_period, rand_amplify,
		2, rand_seed);
end

-- measure the path.
local L, R, T, B, len = path_s.measure(pts, n_pts);
local th = math.max(line * (end_shape == 1 and 0.5 ^ 0.5 or 0.5), inflation) + antialias;
L, T = math.floor(L - th), math.floor(T - th);
R, B = math.max(math.ceil(R + th), L + 1), math.max(math.ceil(B + th), T + 1);

-- prepare the canvas.
obj.clearbuffer("object", R - L, B - T);
obj.cx, obj.cy = -(L + R + align_x * width) / 2, -(T + B + align_y * height) / 2;

-- draw the figures.
if has_fill or has_chrome then
	local cache_name = "tempbuffer";
	if has_fill and has_chrome then
		cache_name = "cache:path_s/coords";
		obj.setoption("drawtarget", "tempbuffer", obj.w, obj.h);
	end
	path_s.send(pts, n_pts, -L, -T, cache_name);

	-- draw the shape of the filling part.
	if has_fill then
		obj.clearbuffer(has_chrome and "tempbuffer" or "object", color_fill);
		path_s.path_mask_area_buffered(
			0, alpha_fill, 0, inflation, antialias,
			cache_name, n_pts,
			has_chrome and { name = "tempbuffer", w = obj.w, h = obj.h } or nil);
	end

	-- then the outline part.
	if has_chrome then
		obj.clearbuffer("object", color_line);
		path_s.path_mask_line_buffered(
			0, alpha_line, line, antialias,
			cache_name, n_pts, len, true,
			start_pos, end_pos, end_shape, 0,
			dash_pat, dash_pos, true, 0); -- TODO: new parameters.
		if has_fill then
			obj.draw();
			obj.copybuffer("object", "tempbuffer");
		end
	end
end
