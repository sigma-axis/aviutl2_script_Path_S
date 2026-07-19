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
local path_s = require("Path_S");
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

--#region PI / normalize parameters.

-- take parameters.
--[==[
	PI = {
		invert:			boolean|number|nil,
		num_points:		number?,
		path_type:		string?,
		points:			table?,
		precision:		number?,
		inflation:		number?,
		mode_fill:		string?,
		X:				number?,
		Y:				number?,
		zoom:			number?,
		rotate:			number?,
		extra_filter:	string?,
		antialias:		number?,
	}
]==]
invert = path_s.PI.as_bool(PI.invert, invert);
num_points = tonumber(PI.num_points) or num_points;
path_type = path_s.PI.path_type(PI.path_type, path_type);
if type(PI.points) == "table" then points = PI.points end
precision = tonumber(PI.precision) or precision;
inflation = tonumber(PI.inflation) or inflation;
mode_fill = path_s.PI.mode_fill(PI.mode_fill, mode_fill);
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
antialias = tonumber(PI.antialias) or antialias;

-- normalize parameters.
num_points = math.max(math.floor(0.5 + num_points), 3);
precision = math.max(precision, 1);
inflation = math.max(inflation, 0);
zoom = math.min(math.max(zoom / 100, 0), 50);
rotate = math.pi / 180 * (rotate % 360);
extra_filter = math.min(math.max(math.floor(0.5 + extra_filter), 0), 1);
antialias = math.max(antialias, 1 / 1024);
if extra_filter == 1 and extra_script:match("^%s*(.-)%s*$") == "" then return end

--#endregion PI / normalize parameters.

-- save the current context.
---@type partial_filter_context?
local cxt = path_s.partial_filter.make_cxt(
	num_points, path_type, points, precision,
	mode_fill, inflation, antialias, invert,
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
