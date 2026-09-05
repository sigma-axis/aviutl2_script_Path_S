--information:パスに沿って配置σ@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
---$script_tips:パスに沿ってオブジェクトを配置するフィルタ効果です．個別オブジェクトでも間隔を空けて配置できます．\n各オブジェクト間の相対座標はパスに沿わずにそのまま反映されます．直前に「座標の拡大縮小(個別オブジェクト)」で 0 倍をしておくなどするとパスに沿った配置になります．
--label:Path_S\配置
--require:${LEAST_AVIUTL_VERSION}
---$track:位置, min = -400, max = 400, step = 0.001, scale = 0.25
local position = 0

---$track:回転, min = -3600, max = 3600, step = 0.01, scale = 0.1
local rotate = 0

---$checksection:パスに沿って回転
local rot_tangent = true

---$tips:個別オブジェクト間の位置ズレ長さ，パス全体長からの % 単位
---$track:個別位置ズレ, min = -200, max = 200, step = 0.001, scale = 0.5
local ofs_indiv = -5

---$tips:パスの始点と終点の間に収まらないオブジェクトを表示するかどうかを指定．
---$select:範囲外
---非表示 = 0
---始点のみ表示 = 1
---終点のみ表示 = 2
---表示 = 3
local out_of_range = 0

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

--hide@out_of_range:loop==1
---$tips:折れ線近似の最大サンプル間隔，ピクセル単位
---$track:曲線精度, min = 1, max = 128, step = 1, scale = 0.25
local precision = 8

---$tips:パスの形状を編集画面に表示．動画出力時には自動的に無効化されます．
---$check:パスの表示
local toggle_gui = false

--group:その他,false
---$nolang: name
---$tips:PI = {
---     :  position: number?,
---     :  rotate: number?,
---     :  rot_tangent: boolean|number|nil,
---     :  ofs_indiv: number?,
---     :  out_of_range: string?,
---     :  num_points: number?,
---     :  path_type: string?,
---     :  points: table?,
---     :  loop: boolean|number|nil,
---     :  mode_anchor_base: string?,
---     :  precision: number?,
---     :}
---$value:PI
local PI = {}

local path_s = require("Path_S");
local obj, math, tonumber, type = obj, math, tonumber, type;
local cx0, cy0, cz0 = obj.getvalue("center");

-- set anchors.
if obj.getoption("gui") then
	num_points = math.max(math.floor(0.5 + (tonumber(num_points) or 4)), 2);
	path_type = math.min(math.max(math.floor(0.5 + path_type), 0), 3);
	local _, pts = path_s.anchor("points", path_type, points,
		num_points - (loop and 0 or 1), loop, nil, mode_anchor_base);
	points = pts;
end

--#region PI / normalize parameters.

-- take parameters.
position = tonumber(PI.position) or position;
rotate = tonumber(PI.rotate) or rotate;
rot_tangent = path_s.PI.as_bool(PI.rot_tangent, rot_tangent);
ofs_indiv = tonumber(PI.ofs_indiv) or ofs_indiv;
if type(PI.out_of_range) == "string" then
	local name2num = {
		["非表示"] = 0, ["始点のみ表示"] = 1, ["終点のみ表示"] = 2, ["表示"] = 3,
	};
	out_of_range = name2num[PI.out_of_range] or out_of_range;
end
num_points = tonumber(PI.num_points) or num_points;
path_type = path_s.PI.path_type(PI.path_type, path_type);
if type(PI.points) == "table" then points = PI.points end
loop = path_s.PI.as_bool(PI.loop, loop);
mode_anchor_base = path_s.PI.mode_anchor_base(PI.mode_anchor_base, mode_anchor_base);
precision = tonumber(PI.precision) or precision;

-- normalize parameters.
position = position / 100;
rotate = rotate % 360;
ofs_indiv = ofs_indiv / 100;
out_of_range = math.min(math.max(math.floor(0.5 + out_of_range), 0), 3);
num_points = math.max(math.floor(0.5 + num_points), 2);
precision = math.max(precision, 1);
local is_mult_obj = obj.getoption("multi_object");
toggle_gui = toggle_gui and
	obj.getoption("gui") and (not is_mult_obj or obj.index == 0);

--#endregion PI / normalize parameters.

-- further calculations.
local cx, cy = path_s.anchor_offset(mode_anchor_base);
points, num_points = path_s.poll(path_type, points, num_points - (loop and 0 or 1), loop, precision);
if toggle_gui then
	-- backup the original object.
	local cache_name = "cache:path_s/place/obj";
	obj.copybuffer(cache_name, "object");

	-- find the bounding box.
	local L, R, T, B, len = path_s.measure(points, num_points);
	local pts, rate = points, 1;
	if (R - L) + (B - T) > obj.screen_w + obj.screen_w then
		-- shrink the points so the canvas will not be too large.
		pts, rate = {}, (obj.screen_w + obj.screen_w) / ((R - L) + (B - T));
		for i = 1, 2 * num_points do
			pts[i] = rate * points[i];
		end
		L, R, T, B, len = rate * L, rate * R, rate * T, rate * B, rate * len;
	end
	L, R = math.floor(L) - 1, math.ceil(R) + 1;
	T, B = math.floor(T) - 1, math.ceil(B) + 1;

	-- prepare the canvas.
	obj.clearbuffer("object", R - L, B - T, 0xffffff);

	-- carve by the path.
	path_s.path_mask_line(
		0, 1, 2, 1,
		0, pts, num_points - (loop and 0 or 1), loop, 1,
		0, 1, 0, 0, 1, { 6, 10 }, 0, true, 0,
		1, 0, -(L + R) / 2, -(T + B) / 2);

	-- adjust the position.
	local cx1, cy1 = obj.cx, obj.cy;
	obj.cx, obj.cy =
		(cx0 + cx1 - cx) * rate - (R + L) / 2 - cx0,
		(cy0 + cy1 - cy) * rate - (B + T) / 2 - cy0;

	-- then draw to the framebuffer.
	local prev_blend = obj.getoption("blend");
	obj.setoption("blend", "diff");
	obj.draw(0, 0, 0, 1 / rate);
	obj.setoption("blend", prev_blend);
	obj.setoption("draw_state", false);

	-- rewind the states.
	obj.copybuffer("object", cache_name);
	obj.cx, obj.cy = cx1, cy1;
end
local ofs = position + ofs_indiv * (is_mult_obj and obj.index or 0);
if loop then ofs = ofs % 1;
elseif (ofs < 0 and out_of_range % 2 == 0) or (ofs > 1 and out_of_range < 2) then
	-- hide the object.
	obj.setoption("draw_state", true);
	return;
else ofs = math.min(math.max(ofs, 0), 1) end

-- find the position and the angle.
local X, Y, A do
	local i, j = path_s.find_index(-ofs, points, num_points);

	-- calculate the position and the angle.
	X, Y =
		(1 - j) * points[2 * i - 1] + j * points[2 * i + 1],
		(1 - j) * points[2 * i - 0] + j * points[2 * i + 2];

	if rot_tangent then
		A = math.atan2(
			points[2 * i + 2] - points[2 * i - 0],
			points[2 * i + 1] - points[2 * i - 1]);

		-- as to the angle, interpolate with the neighbor secant.
		if j < 0.5 then i = i - 1;
		else i, j = i + 1, 1 - j end
		if loop then
			if i < 1 then i = i + (num_points - 1);
			elseif i >= num_points then i = i - (num_points - 1) end
		end
		local dA = 0;
		if 0 < i and i < num_points then
			dA = math.atan2(
				points[2 * i + 2] - points[2 * i - 0],
				points[2 * i + 1] - points[2 * i - 1]);
			dA = (dA - A) / (2 * math.pi);
			dA = ((dA + 0.5) % 1) - 0.5;
			dA = 360 * (0.5 - j) * dA;
		end
		A = 180 / math.pi * A + dA;
	else A = 0 end
end

-- convert anchor coordinates to screen coordinates.
local Z = 0 do
	X, Y, Z = X + cx - cx0 - obj.cx, Y + cy - cy0 - obj.cy, Z - cz0 - obj.cz;

	local x, y, z = obj.getvalue("scale");
	X, Y, Z = obj.sx * x * X, obj.sy * y * Y, obj.sz * z * Z;

	x, y, z = obj.getvalue("angle");
	x, y, z =
		math.pi / 180 * (obj.rx + x),
		math.pi / 180 * (obj.ry + y),
		math.pi / 180 * (obj.rz + z);
	local c, s = math.cos(x), math.sin(x);
	X, Y = c * X - s * Y, s * X + c * Y;
	c, s = math.cos(y), math.sin(y);
	Z, X = c * Z - s * X, s * Z + c * X;
	c, s = math.cos(z), math.sin(z);
	Y, Z = c * Y - s * Z, s * Y + c * Z;
end

-- apply the position and the angle.
obj.ox, obj.oy, obj.oz = obj.ox + X, obj.oy + Y, obj.oz + Z;
obj.rz = obj.rz + rotate + A;
