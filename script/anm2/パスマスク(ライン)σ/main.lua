--information:パスマスク(ライン)σ@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
--label:Path_S\クリッピング
--filter
--require:${LEAST_AVIUTL_VERSION}
---$track:強さ, min = 0, max = 100, step = 0.01
local intensity = 100

---$checksection:反転
local invert = false

---$track:ライン幅, min = 0, max = 1000, step = 0.01, scale = 0.2
local line = 5

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

---$checksection:ループ
local loop = false

---$track:曲線精度, min = 1, max = 128, step = 1, scale = 0.25
local precision = 8

--group:ライン設定,false
---$track:開始位置, min = -400, max = 400, step = 0.001, scale = 0.25
local start_pos = 0

---$track:終了位置, min = -400, max = 400, step = 0.001, scale = 0.25
local end_pos = 100

---$select:端の形状
---円 = 0
---四角 = 1
---平坦 = 2
local end_shape = 0

---$select:接合点の形状
---ラウンド = 0
---ベベル = 1
local elbow_shape = 0

---$value:破線パターン
local dash_pat = {100,0}

---$checksection:破線周期補正
local dash_adj = true

---$track:破線位置, min = -4000, max = 4000, step = 0.01, scale = 0.25
local dash_pos = 0

---$select:dash::端の形状
---円 = 0
---四角 = 1
---平坦 = 2
local dash_end_shape = 0

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

--[[pixelshader@carve:
---$include "../../path_coord_header.hlsl"
---$include "line_dist_header.hlsl"
---$include "carve.hlsl"
]]
--[[pixelshader@carve_dash:
---$include "../../path_coord_header.hlsl"
---$include "line_dist_header.hlsl"
---$include "carve_dash.hlsl"
]]
local path_s = require("Path_S");
local obj, math, tonumber, type = obj, math, tonumber, type;

-- see if the points are already buffered.
local pt_buff, len_buff =
	type(PI.pt_buff) == "string" and PI.pt_buff or nil,
	tonumber(PI.len_buff);
if (pt_buff and pt_buff ~= "tempbuffer" and not pt_buff:match("^cache:.+$")) or not (len_buff and len_buff > 0) then pt_buff, len_buff = nil, -1 end

-- set anchors.
if obj.getoption("gui") and not pt_buff then
	if toggle_gui then obj.setanchor("X,Y", 0, "line") else
		num_points = math.max(math.floor(0.5 + (tonumber(num_points) or 4)), 2);
		path_type = math.min(math.max(math.floor(0.5 + path_type), 0), 3);
		local _, pts = path_s.anchor("points", path_type, points, num_points - (loop and 0 or 1), loop);
		points = pts;
	end
end

--#region PI / normalize parameters.

-- take parameters.
--[==[
	PI = {
		intensity:		number?,
		invert:			boolean|number|nil,
		line:			number?,
		num_points:		number?,
		path_type:		string?,
		points:			table?,
		loop:			boolean|number|nil,
		precision:		number?,
		start_pos:		number?,
		end_pos:		number?,
		end_shape:		string?,
		elbow_shape:	string?,
		dash_pat:		table?,
		dash_adj:		boolean|number|nil,
		dash_pos:		number?,
		dash_end_shape:	string?,
		X:				number?,
		Y:				number?,
		zoom:			number?,
		rotate:			number?,
		antialias:		number?,
		pt_buff:		string?,
		len_buff:		number?,
	}
]==]
intensity = tonumber(PI.intensity) or intensity;
invert = path_s.PI.as_bool(PI.invert, invert);
line = tonumber(PI.line) or line;
num_points = tonumber(PI.num_points) or num_points;
path_type = path_s.PI.path_type(PI.path_type, path_type);
if type(PI.points) == "table" then points = PI.points end
loop = path_s.PI.as_bool(PI.loop, loop);
precision = tonumber(PI.precision) or precision;
start_pos = tonumber(PI.start_pos) or start_pos;
end_pos = tonumber(PI.end_pos) or end_pos;
end_shape = path_s.PI.end_shape(PI.end_shape, end_shape);
elbow_shape = path_s.PI.elbow_shape(PI.elbow_shape, elbow_shape);
if type(PI.dash_pat) == "table" then dash_pat = PI.dash_pat end
dash_adj = path_s.PI.as_bool(PI.dash_adj, dash_adj);
dash_pos = tonumber(PI.dash_pos) or dash_pos;
dash_end_shape = path_s.PI.end_shape(PI.dash_end_shape, dash_end_shape);
X = tonumber(PI.X) or X;
Y = tonumber(PI.Y) or Y;
zoom = tonumber(PI.zoom) or zoom;
rotate = tonumber(PI.rotate) or rotate;
antialias = tonumber(PI.antialias) or antialias;

-- normalize parameters.
intensity = math.min(math.max(intensity / 100, 0), 1);
line = math.max(line, 0);
num_points = math.max(math.floor(0.5 + num_points), 2);
precision = math.max(precision, 1);
start_pos = start_pos / 100;
end_pos = end_pos / 100;
zoom = math.min(math.max(zoom / 100, 0), 50);
rotate = math.pi / 180 * (rotate % 360);
antialias = math.max(antialias, 1 / 1024);
if intensity <= 0 then return end

--#endregion PI / normalize parameters.

local alpha_outer, alpha_inner = 1 - intensity, 1;
if invert then alpha_outer, alpha_inner = alpha_inner, alpha_outer end
if pt_buff then
	path_s.path_mask_line_buffered(
		alpha_outer, alpha_inner, line, antialias,
		pt_buff, num_points, len_buff, loop,
		start_pos, end_pos, end_shape, elbow_shape,
		dash_pat, dash_pos, dash_adj, dash_end_shape);
else
	path_s.path_mask_line(
		alpha_outer, alpha_inner, line, antialias,
		path_type, points, num_points - (loop and 0 or 1), loop, precision,
		start_pos, end_pos, end_shape, elbow_shape,
		dash_pat, dash_pos, dash_adj, dash_end_shape,
		zoom, rotate, X, Y);
end
