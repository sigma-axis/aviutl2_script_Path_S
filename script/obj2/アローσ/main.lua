--information:アローσ@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
--label:Path_S\図形
--require:${LEAST_AVIUTL_VERSION}
---$track:ライン幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local line = 5

---$track:矢じりサイズ, min = 0, max = 2048, step = 0.01, scale = 0.125
local head_size = 32

---$color:色
local color= 0xffffff

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

---$track:曲線精度, min = 1, max = 128, step = 1, scale = 0.25
local precision = 8

--group:ライン設定,false
---$track:開始位置, min = 0, max = 100, step = 0.001
local start_pos = 0

---$track:終了位置, min = 0, max = 100, step = 0.001
local end_pos = 100

---$select:端の形状
---円 = 0
---四角 = 1
local end_shape = 0

---$value:破線パターン
local dash_pat = {100,0}

---$track:破線位置, min = -4000, max = 4000, step = 0.01, scale = 0.25
local dash_pos = 0

--group:矢じり設定,false
---$select:矢じり配置
---なし = 0
---終点 = 1
---両方 = 2
---双方向 = 3
local head_type = 1

---$figure:矢じり図形
local head_fig = "三角形"

---$track:矢じり幅, min = 0, max = 800, step = 0.001, scale = 0.25
local head_width = 100

---$track:矢じり中心, min = -100, max = 100, step = 0.001
local head_center = -50

---$track:矢じり角度, min = -3600, max = 3600, step = 0.01, scale = 0.1
local head_rot = 0

---$track:矢じり位置, min = -100, max = 100, step = 0.001
local head_pos = 0

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
	local _, pts = path_s.anchor("points", path_type, points, num_points - 1, false);
	points = pts;
end

-- take parameters. (they don't affect to anchors.)
--[==[
	PI = {
		color:			number?,
		line:			number?,
		head_type:		string?,
		head_fig:		string?,
		head_size:		number?,
		head_width:		number?,
		head_center:	number?,
		head_rot:		number?,
		head_pos:		number?,
		num_points:		number?,
		path_type:		string?,
		points:			table?,
		precision:		number?,
		antialias:		number?,
		start_pos:		number?,
		end_pos:		number?,
		end_shape:		string?,
		dash_pat:		table?,
		dash_pos:		number?,
		rand_period:	number?,
		rand_amplify:	number?,
		rand_fix_end:	boolean|number|nil,
		rand_seed:		number?,
	}
]==]
local function as_bool(t, v)
	if type(t) == "boolean" then return t;
	elseif type(t) == "number" then return t ~= 0;
	else return v end
end
color = tonumber(PI.color) or color;
line = tonumber(PI.line) or line;
if type(PI.head_type) == "string" then
	local name2num = {
		["なし"] = 0, ["終点"] = 1, ["両方"] = 2, ["双方向"] = 3,
	};
	head_type = name2num[PI.head_type] or head_type;
end
head_fig = type(PI.head_fig) == "string" and PI.head_fig or head_fig;
head_size = tonumber(PI.head_size) or head_size;
head_width = tonumber(PI.head_width) or head_width;
head_center = tonumber(PI.head_center) or head_center;
head_rot = tonumber(PI.head_rot) or head_rot;
head_pos = tonumber(PI.head_pos) or head_pos;
num_points = tonumber(PI.num_points) or num_points;
if type(PI.path_type) == "string" then
	local name2num = {
		["折れ線"] = 0, ["補間移動"] = 1, ["2次ベジェ曲線"] = 2, ["3次ベジェ曲線"] = 3,
	};
	path_type = name2num[PI.path_type] or path_type;
end
points = type(PI.points) == "table" and PI.points or points;
precision = tonumber(PI.precision) or precision;
antialias = tonumber(PI.antialias) or antialias;
start_pos = tonumber(PI.start_pos) or start_pos;
end_pos = tonumber(PI.end_pos) or end_pos;
if type(PI.end_shape) == "string" then
	local name2num = {
		["円"] = 0, ["四角"] = 1,
	};
	end_shape = name2num[PI.end_shape] or end_shape;
end
dash_pat = type(PI.dash_pat) == "table" and PI.dash_pat or dash_pat;
dash_pos = tonumber(PI.dash_pos) or dash_pos;
rand_period = tonumber(PI.rand_period) or rand_period;
rand_amplify = tonumber(PI.rand_amplify) or rand_amplify;
rand_fix_end = as_bool(PI.rand_fix_end, rand_fix_end);
rand_seed = tonumber(PI.rand_seed) or rand_seed;

-- normalize parameters.
color = math.floor(0.5 + color) % 2 ^ 24;
line = math.max(line, 0);
head_type = math.min(math.max(math.floor(0.5 + head_type), 0), 3);
head_size = math.max(math.floor(0.5 + head_size), 0);
head_width = math.max(head_width / 100, 0);
head_center = head_center / 100;
head_rot = math.pi / 180 * (head_rot % 360);
head_pos = math.min(math.max(head_pos / 100, -1), 1);
num_points = math.max(math.floor(0.5 + num_points), 2);
path_type = math.min(math.max(math.floor(0.5 + path_type), 0), 3);
precision = math.max(precision, 1);
antialias = math.max(antialias, 0);
start_pos = math.min(math.max(start_pos / 100, 0), 1);
end_pos = math.min(math.max(end_pos / 100, 0), 1);
end_shape = math.min(math.max(math.floor(0.5 + end_shape), 0), 1);
rand_period = math.max(rand_period, 4);
rand_amplify = math.max(rand_amplify, 0);
rand_seed = math.min(math.max(math.floor(0.5 + rand_seed), -2 ^ 16), 2 ^ 16 - 1);
if start_pos > end_pos then return end

-- parse/measure the path.
points, num_points = path_s.poll(path_type, points, num_points - 1, false, precision);
if rand_amplify > 0 then
	-- randomize the path.
	if rand_fix_end then
		-- append two extra points near the both ends, so the arrow heads don't shake (if at the ends).
		local x1, y1, x2, y2, x3, y3, x4, y4 = points[1], points[2], points[3], points[4],
			points[2 * num_points - 3], points[2 * num_points - 2],
			points[2 * num_points - 1], points[2 * num_points];
		local dx, dy = x2 - x1, y2 - y1; local l = (dx ^ 2 + dy ^ 2) ^ 0.5;
		x2, y2 = x1 + dx / l, y1 + dy / l;
		dx, dy = x3 - x4, y3 - y4; l = (dx ^ 2 + dy ^ 2) ^ 0.5;
		x3, y3 = x4 + dx / l, y4 + dy / l;

		points, num_points = path_s.randomize(points, num_points,
			rand_period, rand_amplify, 1, rand_seed);

		num_points = num_points + 2;
		table.insert(points, 3, x2);
		table.insert(points, 4, y2);
		table.insert(points, 2 * num_points - 3, x3);
		table.insert(points, 2 * num_points - 2, y3);
	else
		points, num_points = path_s.randomize(points, num_points,
			rand_period, rand_amplify, 0, rand_seed);
	end
end
local L, R, T, B = path_s.measure(points, num_points);
local th = line * (end_shape == 1 and 0.5 ^ 0.5 or 0.5) + antialias;
if head_type ~= 0 then
	-- take the arrow heads into account.
	th = math.max(th, head_size / 2 * ((math.abs(head_center) + 1) ^ 2 + head_width ^ 2) ^ 0.5);
end
L, T = math.floor(L - th), math.floor(T - th);
R, B = math.max(math.ceil(R + th), L + 1), math.max(math.ceil(B + th), T + 1);
local W, H, cx, cy = R - L, B - T, -(L + R) / 2, -(T + B) / 2;

-- calculate the head position.
local head_vertices = nil;
if head_type ~= 0 and head_size > 0 and head_width > 0 then
	local function polygon(i, j, rot)
		local X, Y =
			(1 - j) * points[2 * i - 1] + j * points[2 * i + 1],
			(1 - j) * points[2 * i - 0] + j * points[2 * i + 2];
		local A = math.atan2(
			points[2 * i + 2] - points[2 * i - 0],
			points[2 * i + 1] - points[2 * i - 1]);

		-- as to the angle, interpolate with the neighbor secant.
		if j < 0.5 then i = i - 1;
		else i, j = i + 1, 1 - j end
		local dA = 0;
		if 0 < i and i < num_points then
			dA = math.atan2(
				points[2 * i + 2] - points[2 * i - 0],
				points[2 * i + 1] - points[2 * i - 1]);
			dA = (dA - A) / (2 * math.pi);
			dA = ((dA + 0.5) % 1) - 0.5;
			dA = 2 * math.pi * (0.5 - j) * dA;
		end
		A = A + dA + rot;

		local c, s = math.cos(A), math.sin(A);
		X, Y =
			X - head_center * head_size / 2 * s + cx,
			Y + head_center * head_size / 2 * c + cy;
		local w2x, w2y, h2x, h2y = head_size * head_width / 2, 0, 0, head_size / 2;
		w2x, w2y = w2x * c, w2x * s;
		h2x, h2y = h2y *-s, h2y * c;
		return
			{ X - w2x - h2x, Y - w2y - h2y, 0; 0, 0 },
			{ X + w2x - h2x, Y + w2y - h2y, 0; 1, 0 },
			{ X + w2x + h2x, Y + w2y + h2y, 0; 1, 1 },
			{ X - w2x + h2x, Y - w2y + h2y, 0; 0, 1 };
	end

	-- first tip.
	local pos = math.min(math.max(1 + head_pos, 0), 1);
	pos = (1 - pos) * start_pos + pos * end_pos;
	local i, j, l = path_s.find_index(-pos, points, num_points);
	local vts = { polygon(i, j, head_rot + math.pi / 2) };

	if head_type > 1 then
		-- second tip.
		local pos2 = math.min(math.max(head_pos, 0), 1);
		pos2 = (1 - pos2) * start_pos + pos2 * end_pos;
		if pos ~= pos2 then
			i, j = path_s.find_index(-pos2, l);
			vts[5], vts[6], vts[7], vts[8] = polygon(i, j, head_rot
				+ math.pi / 2 * (head_type == 2 and 1 or -1));
		end
	end

	head_vertices = vts;
end

-- draw the path.
obj.clearbuffer(head_vertices and "tempbuffer" or "object", W, H, color);
path_s.path_mask_line(
	0, 1, line, antialias,
	nil, points, num_points - 1, false, 1,
	start_pos, end_pos, end_shape, dash_pat, dash_pos, false,
	1, 0, cx, cy,
	head_vertices and { name = "tempbuffer", w = W, h = H } or nil,
	head_vertices and "object" or nil);

-- draw the arrow heads.
if head_vertices then
	obj.setoption("drawtarget", "tempbuffer");
	if obj.load("figure", head_fig, color, math.ceil(head_size * math.max(head_width, 1))) then
		-- "alpha_max" does not seem to work well with obj.drawpoly().
		-- obj.setoption("blend", "alpha_max");
		obj.drawpoly(head_vertices);
		-- obj.setoption("blend");
	end
	obj.copybuffer("object", "tempbuffer");
end

-- adjust the center.
obj.cx, obj.cy = cx, cy;
