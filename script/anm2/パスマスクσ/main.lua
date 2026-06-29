--information:パスマスクσ@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
--label:Path_S\クリッピング
--filter
--require:${LEAST_AVIUTL_VERSION}
---$track:強さ, min = 0, max = 100, step = 0.01
local intensity = 100

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

--group:その他,false
---$track:ぼかし幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local antialias = 1

---$value:PI
local PI = {}

--[[pixelshader@const_alpha:
---$include "const_alpha.hlsl"
]]
--[[pixelshader@carve:
---$include "carve.hlsl"
]]
local path_s = require "Path_S";
local obj, math, tonumber, type = obj, math, tonumber, type;

-- see if the points are already buffered.
local pt_buff = type(PI.pt_buff) == "string" and PI.pt_buff or nil;
if pt_buff and pt_buff ~= "tempbuffer" and not pt_buff:match("^cache:.+$") then pt_buff = nil end

-- set anchors.
if obj.getoption("gui") and not pt_buff then
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
		intensity:	number?,
		num_points:	number?,
		path_type:	string?,
		points:		table?,
		precision:	number?,
		antialias:	number?,
		inflation:	number?,
		mode_fill:	string?,
		invert:		boolean|number|nil,
		X:			number?,
		Y:			number?,
		zoom:		number?,
		rotate:		number?,
		pt_buff:	string?,
	}
]==]
local function as_bool(t, v)
	if type(t) == "boolean" then return t;
	elseif type(t) == "number" then return t ~= 0;
	else return v end
end
intensity = tonumber(PI.intensity) or intensity;
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

-- normalize parameters.
intensity = math.min(math.max(intensity / 100, 0), 1);
num_points = math.max(math.floor(0.5 + num_points), 3);
path_type = math.min(math.max(math.floor(0.5 + path_type), 0), 3);
precision = math.max(precision, 1);
antialias = math.max(antialias, 1 / 1024);
inflation = math.max(inflation, 0);
mode_fill = math.min(math.max(math.floor(0.5 + mode_fill), 0), 3);
zoom = math.min(math.max(zoom / 100, 0), 50);
rotate = math.pi / 180 * (rotate % 360);
if intensity <= 0 then return end

-- further calculations.
local alpha_outer, alpha_inner = 1 - intensity, 1;
if invert then alpha_outer, alpha_inner = alpha_inner, alpha_outer end
if pt_buff then
	path_s.path_mask_area_buffered(
		alpha_outer, alpha_inner, mode_fill,
		inflation, antialias,
		pt_buff, num_points);
else
	path_s.path_mask_area(
		alpha_outer, alpha_inner, mode_fill,
		inflation, antialias,
		path_type, points, num_points, precision,
		zoom, rotate, X, Y);
end
