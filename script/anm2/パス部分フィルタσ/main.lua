--information:パス部分フィルタσ@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
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

---$check:アンカー切り替え
local toggle_gui = false

--group:フィルタ設定,false
---$select:追加のフィルタ効果
---後続フィルタ = 0
---スクリプト実行 = 1
local extra_filter = 0

---$text:追加スクリプト
local extra_script = 'obj.effect("グラデーション",\n  "形状","凸形",\n  "角度",30,\n  "開始色",0x00ff00) -- グラデーション適用\nobj.cx=obj.cx+100 -- 位置もずらせる\n'

--group:その他,false
---$track:ぼかし幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local antialias = 1

---$value:PI
local PI = {}

--[[pixelshader@interpolate:
---$include "interpolate.hlsl"
]]
local path_s = require "Path_S";
local obj, math, tonumber, type, tostring = obj, math, tonumber, type, tostring;

-- set anchors.
if obj.getoption("gui") then
	if toggle_gui then obj.setanchor("X,Y", 0, "line") else
		num_points = math.max(math.floor(0.5 + (tonumber(num_points) or 4)), 3);
		path_type = math.min(math.max(math.floor(0.5 + path_type), 0), 3);
		local _, pts = path_s.anchor("points", path_type, points, num_points, true);
		points = pts;
	end
end

-- take parameters.
--[==[
	PI = {
		num_points:		number?,
		path_type:		string?,
		points:			table?,
		precision:		number?,
		antialias:		number?,
		inflation:		number?,
		mode_fill:		string?,
		invert:			boolean|number|nil,
		X:				number?,
		Y:				number?,
		zoom:			number?,
		rotate:			number?,
		extra_filter:	string?,
	}
]==]
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
inflation = tonumber(PI.inflation) or inflation;
if type(PI.mode_fill) == "string" then
	local name2num = {
		["内側"] = 0, ["奇偶"] = 1, ["内側反転"] = 2, ["奇偶反転"] = 3,
	};
	mode_fill = name2num[PI.mode_fill] or mode_fill;
end
invert = as_bool(PI.invert, invert);
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
path_type = math.min(math.max(math.floor(0.5 + path_type), 0), 3);
precision = math.max(precision, 1);
antialias = math.max(antialias, 1 / 1024);
inflation = math.max(inflation, 0);
mode_fill = math.min(math.max(math.floor(0.5 + mode_fill), 0), 3);
zoom = math.min(math.max(zoom / 100, 0), 50);
rotate = math.pi / 180 * (rotate % 360);
extra_filter = math.min(math.max(math.floor(0.5 + extra_filter), 0), 1);
if extra_filter == 1 and extra_script:match("^%s*(.-)%s*$") == "" then return end

-- backup the current image.
local cache_name_ori, cache_name_eff = "cache:path_s/part/ori#"..obj.effect_id, "cache:path_s/part/eff";
obj.copybuffer(cache_name_ori, "object");

-- apply following filters.
local w0, h0, cx0, cy0 = obj.w, obj.h, obj.cx, obj.cy;
if extra_filter == 0 then obj.effect();
else
	local f, c, e;
	f, e = loadstring(extra_script);
	if f then c, e = pcall(f) end
	if not (f and c) then
		path_s.print_script_error(tostring(e), extra_script);
		obj.setoption("draw_state", true);
		return;
	end
end
if obj.w <= 0 or obj.h <= 0 then return end -- subsequent filter already drew.
obj.copybuffer(cache_name_eff, "object");

-- adjust the size and center.
local w1, h1, cx1, cy1 = obj.w, obj.h, obj.cx, obj.cy;
local w, h, cx, cy do
	local L, R, T, B =
		math.min(-w0 / 2 - cx0, -w1 / 2 - cx1),
		math.max(w0 / 2 - cx0, w1 / 2 - cx1),
		math.min(-h0 / 2 - cy0, -h1 / 2 - cy1),
		math.max(h0 / 2 - cy0, h1 / 2 - cy1);
	w, h = math.ceil(R - L), math.ceil(B - T);
	cx, cy = -(2 * L + w) / 2, -(2 * T + h) / 2;
end

-- create the shape of the path.
obj.clearbuffer("tempbuffer", w, h, 0x000000);
obj.cx, obj.cy  = cx, cy;
path_s.path_mask_area(
	invert and 1 or 0, invert and 0 or 1, mode_fill, inflation, antialias,
	path_type, points, num_points, precision,
	zoom, rotate, X + (cx - cx0), Y + (cy - cy0),
	{ name = "tempbuffer", w = w, h = h }, "object");

-- interpolate the original and effected buffers by that shape.
obj.clearbuffer("object", w, h);
obj.pixelshader("interpolate", "object", { cache_name_ori, cache_name_eff, "tempbuffer" }, {
	-(w - w0) / 2 - (cx - cx0), -(h - h0) / 2 - (cy - cy0);
	-(w - w1) / 2 - (cx - cx1), -(h - h1) / 2 - (cy - cy1);
});

if extra_filter == 0 then
	-- draw to the framebuffer.
	obj.setoption("drawtarget", "framebuffer");
	obj.draw();
end
