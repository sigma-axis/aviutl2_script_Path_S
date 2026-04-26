-- under development for v1.20 (for beta42) r8
--[[
MIT License
Copyright (c) 2025-2026 sigma-axis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

https://mit-license.org/
]]

--
-- v1.12 (for beta25)
--

local obj, print, math, tonumber, ipairs, unpack, bit, ffi, buffer = obj, print, math, tonumber, ipairs, unpack, bit, require("ffi"), require("string.buffer");

if obj.getinfo("version") < 2004001 then
	error([[AviUtl ExEdit beta40a 以降が必要です！]], 2);
end

---@alias path_type # パスの種類．
---| 0 # 折れ線
---| 1 # 補間移動
---| 2 # 2次 Bezier
---| 3 # 3次 Bezier

---@alias mode_fill # 塗りつぶし範囲の指定．
---| 0 # 通常
---| 1 # 奇偶
---| 2 # 反転
---| 3 # 奇偶反転

---@class end_points 曲線の両端の情報を記述．2点の座標と正方向への方向ベクトル．
---@field [1] number? X1
---@field [2] number? Y1
---@field [3] number? dx1
---@field [4] number? dy1
---@field [5] number? X2
---@field [6] number? Y2
---@field [7] number? dx2
---@field [8] number? dy2

local anchor, poll do
	local function pt(pts, i) return tonumber(pts[i]) or 0 end
	local function unpack1(x) if x ~= nil then return x end end

	---places anchors for the path.
	---@param var_name string 点列を受け取る変数の名前．
	---@param path_type path_type パスの種類．
	---@param pts { [integer]: number? } 点列の配列， `{ x1, y1, x2, y2, x3, y3, ... }` の形式．
	---@param n_segs integer パスの分割区間の個数．
	---@param loop boolean 閉じたパスかどうか．
	---@return integer n_anchors 設定したアンカーの個数．
	---@return table pts_corrected 足りない点や余剰な点を補正した点列．補正の必要がない場合は `pts` そのもの．
	function anchor(var_name, path_type, pts, n_segs, loop)
		local pts_per_seg =
			path_type == 0 and 1 or
			path_type == 1 and 1 or
			path_type == 2 and 2 or 3;
		local n_anchors = (loop and 0 or 1) + pts_per_seg * n_segs;
		local alt_pts = nil;
		if 2 * n_anchors ~= #pts then
			alt_pts = {};
			local n = math.min(n_anchors, math.floor(#pts / 2));
			for i = 1, 2 * n do alt_pts[i] = pt(pts, i) end

			if n < n_anchors then
				-- find a suitable placeholder point.
				local k = 1 + math.floor((n - 1) / pts_per_seg) * pts_per_seg;
				local X, Y = pt(pts, 2 * k - 1), pt(pts, 2 * k); -- last point.
				local dx, dy;
				if loop then
					dx, dy = (pt(pts, 1) - X) / 2, (pt(pts, 2) - Y) / 2;
				else
					k = math.max(1, k - pts_per_seg);
					dx, dy = (X - pt(pts, 2 * k - 1)) / 2, (Y - pt(pts, 2 * k)) / 2;
				end
				local l = dx ^ 2 + dy ^ 2;
				if l > 100 ^ 2 then
					l = 100 / l ^ 0.5; -- at most 100 pixel far.
					dx, dy = l * dx, l * dy;
				end
				X, Y = X + dx, Y + dy;

				-- fill the rest with that placeholder.
				for i = n + 1, n_anchors do
					alt_pts[2 * i - 1], alt_pts[2 * i] = X, Y;
				end
			end
		end
		if path_type == 3 then
			obj.setanchor(var_name, n_anchors, unpack1(alt_pts));

			-- draw handles.
			local pts2, pts3 = alt_pts or pts, {};
			for i = 1, n_segs do
				local I, J = 6 * i, 6 * (loop and (i % n_segs) or i);
				obj.setanchor({
					pt(pts2, I - 5), pt(pts2, I - 4),
					pt(pts2, I - 3), pt(pts2, I - 2),
					pt(pts2, I - 1), pt(pts2, I - 0),
					pt(pts2, J + 1), pt(pts2, J + 2),
				}, 4, "line", "inout");
				pts3[2 * i - 1], pts3[2 * i] = pt(pts2, I - 5), pt(pts2, I - 4);
			end
			if not loop then
				pts3[2 * n_segs + 1], pts3[2 * n_segs + 2] =
					pt(pts2, 6 * n_segs + 1), pt(pts2, 6 * n_segs + 2);
			end
			obj.setanchor(pts3, n_segs + (loop and 0 or 1), loop and "loop" or "line");
		else obj.setanchor(var_name, n_anchors, loop and "loop" or "line", unpack1(alt_pts)) end
		return n_anchors, alt_pts or pts;
	end

	local interpolation = obj.interpolation;
	local function bezier2_1d(t, a0, a1, a2)
		return (1 - t) ^ 2 * a0 + 2 * t * (1 - t) * a1 + t ^ 2 * a2;
	end
	local function bezier2(t, x0, y0, x1, y1, x2, y2)
		return bezier2_1d(t, x0, x1, x2), bezier2_1d(t, y0, y1, y2);
	end
	local function bezier3_1d(t, a0, a1, a2, a3)
		return (1 - t) ^ 3 * a0 + 3 * t * (1 - t) ^ 2 * a1 + 3 * t ^ 2 * (1 - t) * a2 + t ^ 3 * a3;
	end
	local function bezier3(t, x0, y0, x1, y1, x2, y2, x3, y3)
		return bezier3_1d(t, x0, x1, x2, x3), bezier3_1d(t, y0, y1, y2, y3);
	end

	local pts2, n_pts2, stack, r2 = {}, 0, {}, 0;
	local function poll_section(curve, apriori, ...)
		local rem = 0;
		-- firstly, collect certain number of mid-points.
		for i = 1, apriori do
			local t = 1 - (i - 1) / apriori;
			rem = rem + 1;
			stack[3 * rem - 2], stack[3 * rem - 1], stack[3 * rem] = t, curve(t, ...);
		end

		-- iterate until the stack clears up.
		local s = 0;
		while rem > 0 do
			local x, y, t, X, Y =
				pts2[2 * n_pts2 - 1], pts2[2 * n_pts2],
				stack[3 * rem - 2], stack[3 * rem - 1], stack[3 * rem];
			if (X - x) ^ 2 + (Y - y) ^ 2 < r2 then
				-- point near enough.
				rem = rem - 1;
				n_pts2 = n_pts2 + 1;
				s, pts2[2 * n_pts2 - 1], pts2[2 * n_pts2] = t, X, Y;
			else
				-- too far, calculate the intermediate.
				local u = (s + t) / 2;
				rem = rem + 1;
				stack[3 * rem - 2], stack[3 * rem - 1], stack[3 * rem] = u, curve(u, ...);
			end
		end
	end

	---曲線を表すパスを折れ線の列に変換する．
	---@param path_type path_type パスの種類．折れ線の場合は実質 shallow copy が取られる．
	---@param pts { [integer]: number? } 点列の配列， `{ x1, y1, x2, y2, x3, y3, ... }` の形式．
	---@param n_segs integer パスの分割区間の個数．
	---@param loop boolean 閉じたパスかどうか．
	---@param prec number 折れ線の許容最長距離．
	---@return { [integer]: number } pts2 結果の折れ線の頂点を表す点列．`loop` が true の場合は末尾には最初と同じ点が格納される．
	---@return integer n_pts2 `pts2` に含まれる点の個数．
	function poll(path_type, pts, n_segs, loop, prec)
		local ret, n_ret;
		if path_type == 0 then
			ret, n_ret = {}, n_segs + 1;
			-- essentially a shallow copy of `pts`.
			for i = 1, 2 * n_ret do ret[i] = pt(pts, i) end
			if loop then
				-- place a copy of the first point at the end.
				ret[2 * n_ret - 1], ret[2 * n_ret] = ret[1], ret[2];
			end
		else
			-- replace the curve into a sequence of secants.
			-- prepare poll_section() function.
			pts2, n_pts2, stack, r2 = { pt(pts, 1), pt(pts, 2) }, 1, {}, prec ^ 2;

			if path_type == 1 then
				-- built-in interpolation function.
				for i = 1, n_segs do
					local x0, y0, x2, y2, x3, y3 =
						pt(pts, 2 * i - 3), pt(pts, 2 * i - 2),
						pt(pts, 2 * i + 1), pt(pts, 2 * i + 2),
						pt(pts, 2 * i + 3), pt(pts, 2 * i + 4);
					if loop then
						if i == 1 then x0, y0 = pt(pts, 2 * n_segs - 1), pt(pts, 2 * n_segs) end
						if i >= n_segs - 1 then
							local j = i - n_segs;
							x3, y3 = pt(pts, 2 * j + 3), pt(pts, 2 * j + 4);
							if j >= 0 then x2, y2 = pt(pts, 2 * j + 1), pt(pts, 2 * j + 2) end
						end
					else
						if i == 1 then x0, y0 = pts2[1], pts2[2] end
						if i >= n_segs then x3, y3 = x2, y2 end
					end
					local x1, y1 = pts2[2 * n_pts2 - 1], pts2[2 * n_pts2];
					if x0 ~= x1 or x0 ~= x2 or x0 ~= x3 or y0 ~= y1 or y0 ~= y2 or y0 ~= y3 then
						poll_section(interpolation, 4,
							x0, y0, x1, y1, x2, y2, x3, y3);
					end
				end
			elseif path_type == 2 then
				-- quadratic Bezier curve.
				for i = 1, n_segs do
					local j = (i >= n_segs and loop) and 0 or i;
					local x1, y1, x2, y2 =
						pt(pts, 4 * i - 1), pt(pts, 4 * i - 0),
						pt(pts, 4 * j + 1), pt(pts, 4 * j + 2);
					local x0, y0 = pts2[2 * n_pts2 - 1], pts2[2 * n_pts2];
					if x0 ~= x1 or x0 ~= x2 or y0 ~= y1 or y0 ~= y2 then
						poll_section(bezier2, 2,
							x0, y0, x1, y1, x2, y2);
					end
				end
			else
				-- cubic Bezier curve.
				for i = 1, n_segs do
					local j = (i >= n_segs and loop) and 0 or i;
					local x1, y1, x2, y2, x3, y3 =
						pt(pts, 6 * i - 3), pt(pts, 6 * i - 2),
						pt(pts, 6 * i - 1), pt(pts, 6 * i - 0),
						pt(pts, 6 * j + 1), pt(pts, 6 * j + 2);
					local x0, y0 = pts2[2 * n_pts2 - 1], pts2[2 * n_pts2];
					if x0 == x1 and y0 == y1 and x2 == x3 and y2 == y3 then
						if x1 ~= x2 or y1 ~= y2 then
							n_pts2 = n_pts2 + 1;
							pts2[2 * n_pts2 - 1], pts2[2 * n_pts2] = x3, y3;
						end
					else
						poll_section(bezier3, 4,
							x0, y0, x1, y1, x2, y2, x3, y3);
					end
				end
			end

			if n_pts2 < 2 then
				-- ensure to have at least two points.
				n_pts2 = n_pts2 + 1;
				pts2[2 * n_pts2 - 1], pts2[2 * n_pts2] = pts2[1], pts2[2];
			end

			-- store the result.
			ret, n_ret, pts2, n_pts2, stack, r2 = pts2, n_pts2, {}, 0, {}, 0;
		end

		return ret, n_ret;
	end
end

---折れ線の bounding box と長さを計算．
---@param pts { [integer]: number } 折れ線の頂点を表す点列．
---@param n_pts integer `pts` に含まれる点の個数．
---@return number L, number R, number T, number B bounding box の座標．
---@return number length 折れ線の長さ．
local function measure(pts, n_pts)
	local x0, y0 = pts[1], pts[2];
	local L, R, T, B, length = x0, x0, y0, y0, 0;
	for i = 3, 2 * n_pts - 1, 2 do
		local x, y = pts[i], pts[i + 1];
		L = math.min(L, x); R = math.max(R, x);
		T = math.min(T, y); B = math.max(B, y);
		length = length + ((x - x0) ^ 2 + (y - y0) ^ 2) ^ 0.5;
		x0, y0 = x, y;
	end
	return L, R, T, B, length;
end

---折れ線を表す配列で，始点から距離 `pos` だけ離れた位置にある点の前後にある頂点のインデックスを二分法で検索．
---@param pos number 始点からの距離．0 以上の場合はピクセル数で指定，負の場合は `pos >= -1.0` の必要があり，パスの総長との比を絶対値で指定．
---@param tbl { [integer]: number } `n_pts` を指定した場合，点列を `{ x1, y1, x2, y2, ... }` の形式で指定．`n_pts` が `nil` の場合，各頂点の始点からの累計距離の配列を `{ 0, l1, l2, ... }` の形式で指定．
---@param n_pts integer? `tbl` に点列を指定した場合， `tbl` に含まれる点の個数． 累計距離の配列の場合は `nil`.
---@return integer int_part `pos` の前後位置にある頂点のインデックスのうち小さいほう．
---@return number frac_part `int_part` から次の頂点までの相対位置を表す，0.0 から 1.0 までの数値．
---@return { [integer]: number } lengths 各頂点の始点からの累計距離の配列．2回目以降の呼び出しで使うと一部計算を省略できる．
local function find_index(pos, tbl, n_pts)
	if n_pts then
		-- construct an array of accumulated lengths.
		local lengths = { 0.0 };
		local x0, y0 = tbl[1], tbl[2];
		for i = 2, n_pts do
			local x, y = tbl[2 * i - 1], tbl[2 * i];
			lengths[i] = lengths[i - 1] + ((x - x0) ^ 2 + (y - y0) ^ 2) ^ 0.5;
			x0, y0 = x, y;
		end
		tbl = lengths;
	else n_pts = #tbl end
	if pos < 0 then pos = tbl[n_pts] * (-pos) end

	-- find the secant where the `pos` is placed on.
	local i, j = 1, n_pts;
	while i + 1 < j do
		local k = math.floor((i + j) / 2);
		if tbl[k] <= pos then i = k else j = k end
	end

	-- calculate the relative position between indices.
	j = tbl[i + 1] - tbl[i];
	j = j > 0 and (pos - tbl[i]) / j or 0.5;

	-- return an integer-fraction pair.
	return i, j, tbl;
end

---曲線の両端の情報 (2点の座標と正方向への方向ベクトル) を計算・取得する．
---@param pts { [integer]: number } 折れ線の頂点を表す点列．
---@param n_pts integer `pts` に含まれる点の個数．
---@param loop boolean 閉じたパスかどうか．
---@param start_pos number パスの始点の位置をパス全体の長さからの比で 0.0 から 1.0 に正規化した数値．ただしループの場合はこの範囲を超えることもある．
---@param end_pos number パスの終点の位置をパス全体の長さからの比で 0.0 から 1.0 に正規化した数値．ただしループの場合はこの範囲を超えることもある．
---@param offset_x number 両端位置の X 方向の移動量．
---@param offset_y number 両端位置の Y 方向の移動量．
---@return end_points # 曲線の両端の情報を記述．2点の座標と正方向への方向ベクトル．
local function find_end_points(pts, n_pts, loop, start_pos, end_pos, offset_x, offset_y)
	-- calculate the end points from the calculated length.
	if loop then start_pos, end_pos = start_pos % 1, end_pos % 1
	else start_pos, end_pos = math.min(math.max(start_pos, 0), 1), math.min(math.max(end_pos, 0), 1) end

	local ret = { 0.0, 0.0, 0.0, 0.0; 0.0, 0.0, 0.0, 0.0 };
	local i, j, l = find_index(-start_pos, pts, n_pts);
	ret[1], ret[2], ret[3], ret[4] =
		(1 - j) * pts[2 * i - 1] + j * pts[2 * i + 1] + offset_x,
		(1 - j) * pts[2 * i - 0] + j * pts[2 * i + 2] + offset_y,
		pts[2 * i + 1] - pts[2 * i - 1],
		pts[2 * i + 2] - pts[2 * i - 0];

	i, j = find_index(-end_pos, l);
	ret[5], ret[6], ret[7], ret[8] =
		(1 - j) * pts[2 * i - 1] + j * pts[2 * i + 1] + offset_x,
		(1 - j) * pts[2 * i - 0] + j * pts[2 * i + 2] + offset_y,
		pts[2 * i + 1] - pts[2 * i - 1],
		pts[2 * i + 2] - pts[2 * i - 0];

	return ret;
end

---点列に対して拡縮回転平行移動を適用する．
---@param pts { [integer]: number } 適用先の点列．このテーブルの内容を書き換える．
---@param n_pts integer `pts` に含まれる点の個数．
---@param scale number 拡縮の比率．
---@param rotate number ラジアン単位の回転角．
---@param dx number? X方向の平行移動量．省略時は 0. 拡縮回転の後に適用される．
---@param dy number? Y方向の平行移動量．省略時は 0. 拡縮回転の後に適用される．
local function transform(pts, n_pts, scale, rotate, dx, dy)
	dx, dy = dx or 0, dy or 0;
	local c, s = scale * math.cos(rotate), scale * math.sin(rotate);
	for i = 1, 2 * n_pts - 1, 2 do
		local x, y = pts[i], pts[i + 1];
		pts[i], pts[i + 1] =
			(c * x - s * y) + dx,
			(s * x + c * y) + dy;
	end
end

local disk_rand do
	local setmetatable, tau, cos, sin, rand1 =
		setmetatable, 2 * math.pi, math.cos, math.sin, obj.rand1;
	local mt_disk_rand = {
		__call = function (self)
			self[1] = self[1] + 2;
			local a, r =
				tau * rand1(self[2], self[1] - 1),
				self[3] * rand1(self[2], self[1]) ^ 0.5;
			return r * cos(a), r * sin(a);
		end
	};
	-- PRNG uniform on a disk with the specified radius.
	function disk_rand(seed, radius)
		return setmetatable({ 1, seed, radius }, mt_disk_rand);
	end
end
---パスに対してランダム移動を適用する．乱数器は `obj.rand1()`．
---@param pts { [integer]: number } 適用先の点列．このテーブルの内容は書き換わらない．
---@param n_pts integer `pts` に含まれる点の個数．
---@param period number ランダムを適用する距離周期，ピクセル単位．
---@param rand_range number 各点がランダム移動する最大距離，ピクセル単位．
---@param end_mode 0|1|2 両端での特別扱いを指定．0: 特になし, 1: 両端は固定, 2: 両端のランダム移動量を揃える (ループ用).
---@param seed number `obj.rand1()` へ渡す乱数シード値．
---@return { [integer]: number } pts2 ランダム移動で得られた新しい点列．
---@return integer n_pts2 `pts2` に含まれる点の個数．
local function randomize(pts, n_pts, period, rand_range, end_mode, seed)
	local rng = disk_rand(seed, rand_range);
	local x_r0, y_r0 = rng();
	local x_r1, y_r1 = rng();
	local p = 0;

	-- for fixed ends or a loop, adjust the period and the first random value.
	local rand_rest, x_r2, y_r2 = -1, 0, 0;
	if end_mode == 1 or end_mode == 2 then
		local _, _, _, _, len = measure(pts, n_pts);
		rand_rest = math.max(math.floor(0.5 + len / period), 2);
		period = len / rand_rest;
		rand_rest = rand_rest - 2;

		if end_mode == 1 then x_r0, y_r0 = 0, 0 end
		x_r2, y_r2 = x_r0, y_r0;
	end

	local n_ret, x0, y0 = 1, pts[1], pts[2];
	local ret = { x0 + x_r0, y0 + y_r0 };
	for i = 3, 2 * n_pts - 1, 2 do
		local x1, y1 = pts[i], pts[i + 1];
		local q = p + ((x1 - x0) ^ 2 + (y1 - y0) ^ 2) ^ 0.5 / period;
		while q >= 1 do
			local t = (1 - p) / (q - p);
			n_ret, x0, y0 = n_ret + 1, (1 - t) * x0 + t * x1, (1 - t) * y0 + t * y1;
			x_r0, y_r0, x_r1, y_r1 = x_r1, y_r1, rng();
			p, q = 0, q - 1;
			ret[2 * n_ret - 1], ret[2 * n_ret] = x0 + x_r0, y0 + y_r0;

			-- manipulate the random values for fixed ends or a loop.
			if rand_rest == 0 then x_r1, y_r1 = x_r2, y_r2 end
			rand_rest = rand_rest - 1;
		end
		p = q;

		if p > 0 then
			n_ret, x0, y0 = n_ret + 1, x1, y1;
			ret[2 * n_ret - 1], ret[2 * n_ret] =
				x0 + (1 - p) * x_r0 + p * x_r1, y0 + (1 - p) * y_r0 + p * y_r1;
		end
	end

	return ret, n_ret;
end

local send, retrieve do
	local function encode_float(x)
		local d, m, M = 2 ^ 8, -2 ^ 23, 2 ^ 23 - 1;
		return bit.bor(0xff000000, math.min(math.max(math.floor(x * d + 0.5), m), M));
	end
	local function decode_float(c)
		local d = 2 ^ 16;
		return bit.lshift(c, 8) / d;
	end
	local buf, intptr_t, uint32_t_array, uint32_t_ptr =
		buffer.new(9), ffi.typeof("intptr_t"), ffi.typeof("uint32_t[?]"), ffi.typeof("uint32_t*");
	-- converts a pointer to a light userdata.
	local function to_userdata(ptr)
		-- 0x05: lightud64. (https://luajit.org/ext_buffer.html)
		buf:reset():encode(ffi.cast(intptr_t, ptr)):ref()[0] = 0x05;
		return buf:decode();
	end

	---点列 `pts` の情報を `target` で指定したバッファに転送する．転送したデータはシェーダーで点列として読み取れるようになる．
	---@param pts { [integer]: number } 折れ線の頂点を表す点列．
	---@param n_pts integer `pts` に含まれる点の個数．
	---@param dx number? X方向の平行移動量．省略時は 0.
	---@param dy number? Y方向の平行移動量．省略時は 0.
	---@param target string? `"tempbuffer"` あるいは `"cache:..."` の形式でバッファを指定．省略時は `"tempbuffer"`.
	function send(pts, n_pts, dx, dy, target)
		dx, dy = dx or 0, dy or 0;
		local max_width = 2 ^ 12;
		local w, h =
			math.min(2 * n_pts, max_width),
			math.ceil(2 * n_pts / max_width)
		local data = uint32_t_array(w * h);
		for i = 1, 2 * n_pts, 2 do
			data[i - 1] = encode_float(pts[i] + dx);
			data[i] = encode_float(pts[i + 1] + dy);
		end
		obj.putpixeldata(target or "tempbuffer", to_userdata(data), w, h);
	end

	---`target` で指定したバッファから点列情報を復元する．
	---@param n_pts integer バッファに含まれている点の個数．
	---@param target string? `"tempbuffer"` あるいは `"cache:..."` の形式でバッファを指定．省略時は `"tempbuffer"`.
	---@return { [integer]: number }? pts 求める点列を表す配列．もしバッファのサイズが `n_pts` と想定されない場合は `nil`.
	function retrieve(n_pts, target)
		local max_width = 2 ^ 12;
		local w, h =
			math.min(2 * n_pts, max_width),
			math.ceil(2 * n_pts / max_width);
		local data, W, H = obj.getpixeldata(target or "tempbuffer");
		if H < h or (h > 1 and W ~= w) or W < w then return nil end
		local ret, ptr = {}, uint32_t_ptr(data);
		for i = 1, 2 * n_pts do ret[i] = decode_float(ptr[i - 1]) end
		return ret;
	end
end

local function mask_uniform(alpha, target)
	if alpha <= 0 then obj.clearbuffer(target);
	elseif alpha < 1 then
		obj.pixelshader("const_alpha@パスマスクσ@Path_S", target, nil, { alpha }, "mask");
	end
end

---パスマスクσ をバッファに送った点列データを元に適用する．
---@param alpha_outer number パス外側のマスクのアルファ値を 0.0 から 1.0 で指定．
---@param alpha_inner number パス内側のマスクのアルファ値を 0.0 から 1.0 で指定．
---@param mode_fill mode_fill 塗りつぶし範囲の指定．
---@param inflation number 「追加幅」をピクセル単位で指定．
---@param antialias number 「ぼかし幅」をピクセル単位で指定．
---@param buffer_name string 折れ線の頂点データのあるバッファ名．
---@param num_points integer バッファに含まれる頂点数．
---@param target_buffer { name: string, w: integer, h: integer }? マスク適用先のバッファ名 (e.g. "object", "cache:foo") とその幅と高さを指定．省略時は `{ name = "object", w = obj.w, h = obj.h }`.
local function path_mask_area_buffered(
	alpha_outer, alpha_inner, mode_fill,
	inflation, antialias,
	buffer_name, num_points,
	target_buffer)
	-- unwrap target_buffer.
	local tgt_name = target_buffer and target_buffer.name or "object";

	-- handle the trivial case.
	if alpha_outer == alpha_inner then mask_uniform(alpha_outer, tgt_name); return end

	-- mask with the path.
	obj.pixelshader("carve@パスマスクσ@Path_S", tgt_name, buffer_name,
	{
		alpha_inner - alpha_outer, alpha_outer;
		num_points, mode_fill,
		inflation, antialias,
	}, "mask");
end

---パスマスクσ を点列を元に適用する．
---@param alpha_outer number パス外側のマスクのアルファ値を 0.0 から 1.0 で指定．
---@param alpha_inner number パス内側のマスクのアルファ値を 0.0 から 1.0 で指定．
---@param mode_fill mode_fill 塗りつぶし範囲の指定．
---@param inflation number 「追加幅」をピクセル単位で指定．
---@param antialias number 「ぼかし幅」をピクセル単位で指定．
---@param path_type path_type|nil 「線タイプ」(パスの種類) を指定．`nil` を指定した場合，折れ線への変換や点列のコピーを省略する．このとき `pts` は既に折れ線の前提で，テーブルの内容も書き換わる．
---@param pts { [integer]: number? } 点列の配列， `{ x1, y1, x2, y2, x3, y3, ... }` の形式．
---@param n_segs integer パスの分割区間の個数．
---@param prec number 「曲線精度」(折れ線の許容最長距離) を指定．
---@param scale number 「拡大率」を指定．
---@param rotate number 「回転」を指定．
---@param dx number 「移動X」を指定．拡縮回転の後に適用．省略時は 0.
---@param dy number 「移動Y」を指定．拡縮回転の後に適用．省略時は 0.
---@param target_buffer { name: string, w: integer, h: integer }? マスク適用先のバッファ名 (e.g. "object", "cache:foo") とその幅と高さを指定．省略時は `{ name = "object", w = obj.w, h = obj.h }`.
---@param temp_buffer_name string? 頂点データを転送する先のバッファ名 (e.g. "tempbuffer", "cache:foo"). 省略時は "tempbuffer".
local function path_mask_area(
	alpha_outer, alpha_inner, mode_fill,
	inflation, antialias,
	path_type, pts, n_segs, prec,
	scale, rotate, dx, dy,
	target_buffer, temp_buffer_name)
	-- unwrap target_buffer.
	local tgt_name, tgt_w, tgt_h = "object", obj.w, obj.h;
	if target_buffer then
		tgt_name, tgt_w, tgt_h = target_buffer.name, target_buffer.w, target_buffer.h;
	end

	-- handle the trivial case.
	if alpha_outer == alpha_inner then mask_uniform(alpha_outer, tgt_name); return end

	-- make the curve into the sequence of secants.
	local points, num_points = pts, n_segs + 1;
	if path_type then
		points, num_points = poll(path_type, pts, n_segs, true,
			prec / math.min(math.max(scale, 1 / 64), 1));
	end

	-- apply translation / scaling / rotation.
	transform(points, num_points, scale, rotate, dx, dy);
	local L, R, T, B = measure(points, num_points);
	local th = inflation + antialias;
	L, R, T, B = L - th, R + th, T - th, B + th;

	-- check if the path overlaps this object.
	if L >= tgt_w / 2 or R <= -tgt_w / 2 or T >= tgt_h / 2 or B <= -tgt_h / 2 then
		mask_uniform(mode_fill >= 2 and alpha_inner or alpha_outer, tgt_name);
		return;
	end

	-- send the coordinates to tempbuffer.
	temp_buffer_name = temp_buffer_name or "tempbuffer";
	send(points, num_points, tgt_w / 2, tgt_h / 2, temp_buffer_name);

	path_mask_area_buffered(
		alpha_outer, alpha_inner, mode_fill,
		inflation, antialias, temp_buffer_name, num_points,
		target_buffer);
end

---パスマスク(ライン)σ をバッファに送った点列データを元に適用する．
---@param alpha_outer number パス外側のマスクのアルファ値を 0.0 から 1.0 で指定．
---@param alpha_inner number パス内側のマスクのアルファ値を 0.0 から 1.0 で指定．
---@param line_width number 「ライン幅」をピクセル単位で指定．
---@param antialias number 「ぼかし幅」をピクセル単位で指定．
---@param buffer_name string 折れ線の頂点データのあるバッファ名．
---@param num_points integer バッファに含まれる頂点数．
---@param len_path number バッファに含まれる折れ線の累計長さ．
---@param loop boolean 閉じたパスかどうか．
---@param start_pos number 「開始位置」を 0.0 から 1.0 に正規化した数値で指定．ただしループの場合はこの範囲を超えることもある．
---@param end_pos number 「終了位置」を 0.0 から 1.0 に正規化した数値で指定．ただしループの場合はこの範囲を超えることもある．
---@param end_shape 0|1 「端の形状」を指定．`1` (四角) を指定した場合，`end_points` を省略せず指定すること．
---@param end_points end_points|nil `end_shape` が `1` のときのみ有効．曲線の両端の情報を記述．2点の座標と正方向への方向ベクトル．
---@param dash_pat { [integer]: number } 「破線パターン」を `{ opaque_len1, blank_len1, opaque_len2, blank_len2, ... }` の形式で指定．
---@param dash_pos number 「破線位置」をピクセル単位で指定．
---@param dash_adj boolean 「破線周期補正」を指定．
---@param target_buffer { name: string, w: integer, h: integer }? マスク適用先のバッファ名 (e.g. "object", "cache:foo") とその幅と高さを指定．省略時は `{ name = "object", w = obj.w, h = obj.h }`.
local function path_mask_line_buffered(
	alpha_outer, alpha_inner, line_width, antialias,
	buffer_name, num_points, len_path, loop,
	start_pos, end_pos, end_shape, end_points,
	dash_pat, dash_pos, dash_adj,
	target_buffer)
	-- unwrap target_buffer.
	local tgt_name = target_buffer and target_buffer.name or "object";

	-- handle the trivial case.
	if alpha_outer == alpha_inner then mask_uniform(alpha_outer, tgt_name); return end

	if line_width < 1 then
		-- fade out the line as the width approaches zero.
		alpha_inner = line_width * alpha_inner + (1 - line_width) * alpha_outer;
	end

	local phase_whole0, phase_whole1, phase_whole2;
	if end_pos < start_pos then
		phase_whole0, phase_whole1, phase_whole2 = 2, 0, 0;
	elseif loop then
		start_pos, end_pos = start_pos % 1, end_pos - math.floor(start_pos);
		if end_pos - start_pos >= 1 then
			phase_whole0, phase_whole1, phase_whole2 = 0, 2, 0;
		elseif end_pos <= 1 then
			phase_whole0, phase_whole1, phase_whole2 = start_pos, end_pos - start_pos, 2;
		else
			phase_whole0, phase_whole1, phase_whole2 = 0, end_pos - 1, 1 + start_pos - end_pos;
		end
	else
		start_pos = math.min(math.max(start_pos, 0), 1);
		end_pos = math.min(math.max(end_pos, 0), 1);
		phase_whole0 = math.max(start_pos, 0);
		phase_whole1 = math.max(end_pos - phase_whole0, 0);
		phase_whole2 = 2;
	end

	-- dash pattern.
	local dash_len0, dash_idx0, sum_dash_len = 0, 0, 0;
	if #dash_pat <= 256 then
		for i,v in ipairs(dash_pat) do
			v = math.max(tonumber(v) or 0, 0);
			sum_dash_len = sum_dash_len + v;
			dash_pat[i] = v;
		end
	end
	if sum_dash_len > 0 then
		-- normalize so zero does not occur other than the head.
		local j, pat, len_rest = 1, { 0 }, (-dash_pos) % sum_dash_len;
		for i, v in ipairs(dash_pat) do
			if v ~= 0 then
				if (i - j) % 2 ~= 0 then
					pat[j] = pat[j] + v;
				else
					j = j + 1;
					pat[j] = v;
				end

				if len_rest >= 0 then
					len_rest = len_rest - v;
					if len_rest < 0 then
						dash_len0 = -len_rest;
						dash_idx0 = j;
					end
				end
			end
		end
		if j % 2 == 1 then
			pat[1] = pat[j];
			pat[j] = nil;
			j = j - 1;
		end

		dash_pat = pat; -- replace with the normalized one.
		if j <= 2 then
			if j < 2 or pat[1] == 0 then
				sum_dash_len = 0; -- all opaque.
			end
		end
	end
	if sum_dash_len <= 0 then
		dash_len0, dash_idx0 = len_path * 2, 2;
		dash_pat = { 0, len_path * 2 };
	elseif loop and dash_adj then
		local adj = len_path / sum_dash_len;
		adj = adj / math.max(math.floor(0.5 + adj), 1);
		sum_dash_len = adj * sum_dash_len;
		dash_len0 = adj * dash_len0;
		for i, v in ipairs(dash_pat) do dash_pat[i] = adj * v end
	end

	-- handle the shape of the end points.
	local endpt = {
		-- dummy, out-of-bound data.
		-2, -2, 4 * math.max(line_width + antialias, 4), 0,
		-2, -2, 4 * math.max(line_width + antialias, 4), 0,
	};
	if end_shape == 1 and end_points and start_pos <= end_pos and (not loop or start_pos + 1 > end_pos) then
		for i = 1, 5, 4 do
			if sum_dash_len > 0 then
				-- identify the position in the dash pattern.
				local pos = i > 1 and end_pos or start_pos;
				if loop then pos = pos % 1 end
				pos = (-dash_pos + dash_pat[1] + len_path * pos) % sum_dash_len;
				for k, v in ipairs(dash_pat) do
					pos = pos - v;
					if pos < 0 then
						-- invalidate when on a non-stroke part.
						if k % 2 == 1 then end_points[i] = nil end
						break;
					end
				end
			end

			local x, y, z, w = end_points[i], end_points[i + 1], end_points[i + 2], end_points[i + 3];
			if x and y and z and w then
				local l = (z ^ 2 + w ^ 2) ^ 0.5;
				if l > 0 then z, w = z / l, w / l else z, w = 1, 0 end
				if i > 1 then z, w = -z, -w end
				endpt[i], endpt[i + 1], endpt[i + 2], endpt[i + 3] = x, y, z, w;
			end
		end
	end

	-- mask with the path.
	if end_pos - start_pos >= 1 and sum_dash_len <= 0 then
		obj.pixelshader("carve@パスマスク(ライン)σ@Path_S", tgt_name, buffer_name,
		{
			alpha_inner - alpha_outer, alpha_outer;
			num_points, math.max(line_width - 1, 0) / 2, antialias; 0, 0, 0;

			endpt[1], endpt[2], endpt[3], endpt[4];
			endpt[5], endpt[6], endpt[7], endpt[8];
		}, "mask");
	else
		obj.pixelshader("carve_dash@パスマスク(ライン)σ@Path_S", tgt_name, buffer_name,
		{
			alpha_inner - alpha_outer, alpha_outer;
			num_points, math.max(line_width - 1, 0) / 2, antialias;
			#dash_pat, dash_len0, dash_idx0 - 1;

			endpt[1], endpt[2], endpt[3], endpt[4];
			endpt[5], endpt[6], endpt[7], endpt[8];

			len_path * phase_whole0, len_path * phase_whole1, len_path * phase_whole2, len_path * 2;
			unpack(dash_pat)
		}, "mask");
	end
end

---パスマスク(ライン)σ を点列を元に適用する．
---@param alpha_outer number パス外側のマスクのアルファ値を 0.0 から 1.0 で指定．
---@param alpha_inner number パス内側のマスクのアルファ値を 0.0 から 1.0 で指定．
---@param line_width number 「ライン幅」をピクセル単位で指定．
---@param antialias number 「ぼかし幅」をピクセル単位で指定．
---@param path_type path_type|nil 「線タイプ」(パスの種類) を指定．`nil` を指定した場合，折れ線への変換や点列のコピーを省略する．このとき `pts` は既に折れ線の前提で，テーブルの内容も書き換わる．
---@param pts { [integer]: number? } 点列の配列， `{ x1, y1, x2, y2, x3, y3, ... }` の形式．
---@param n_segs integer パスの分割区間の個数．
---@param loop boolean 閉じたパスかどうか．
---@param prec number 「曲線精度」(折れ線の許容最長距離) を指定．
---@param start_pos number 「開始位置」を 0.0 から 1.0 に正規化した数値で指定．ただしループの場合はこの範囲を超えることもある．
---@param end_pos number 「終了位置」を 0.0 から 1.0 に正規化した数値で指定．ただしループの場合はこの範囲を超えることもある．
---@param end_shape 0|1 「端の形状」を指定．
---@param dash_pat { [integer]: number } 「破線パターン」を `{ opaque_len1, blank_len1, opaque_len2, blank_len2, ... }` の形式で指定．
---@param dash_pos number 「破線位置」をピクセル単位で指定．
---@param dash_adj boolean 「破線周期補正」を指定．
---@param scale number 「拡大率」を指定．
---@param rotate number 「回転」を指定．
---@param dx number? 「移動X」を指定．拡縮回転の後に適用．省略時は 0.
---@param dy number? 「移動Y」を指定．拡縮回転の後に適用．省略時は 0.
---@param target_buffer { name: string, w: integer, h: integer }? マスク適用先のバッファ名 (e.g. "object", "cache:foo") とその幅と高さを指定．省略時は `{ name = "object", w = obj.w, h = obj.h }`.
---@param temp_buffer_name string? 頂点データを転送する先のバッファ名 (e.g. "tempbuffer", "cache:foo"). 省略時は "tempbuffer".
local function path_mask_line(
	alpha_outer, alpha_inner, line_width, antialias,
	path_type, pts, n_segs, loop, prec,
	start_pos, end_pos, end_shape, dash_pat, dash_pos, dash_adj,
	scale, rotate, dx, dy,
	target_buffer, temp_buffer_name)
	-- unwrap target_buffer.
	local tgt_name, tgt_w, tgt_h = "object", obj.w, obj.h;
	if target_buffer then
		tgt_name, tgt_w, tgt_h = target_buffer.name, target_buffer.w, target_buffer.h;
	end

	-- handle the trivial case.
	if alpha_outer == alpha_inner then mask_uniform(alpha_outer, tgt_name); return end

	-- make the curve into the sequence of secants.
	local points, num_points = pts, n_segs + 1;
	if path_type then
		points, num_points = poll(path_type, pts, n_segs, loop,
			prec / math.min(math.max(scale, 1.0 / 64), 1));
	end

	-- apply translation / scaling / rotation.
	transform(points, num_points, scale, rotate, dx, dy);
	local L, R, T, B, len = measure(points, num_points);
	local th = line_width / 2 + antialias;
	L, R, T, B = L - th, R + th, T - th, B + th;

	-- check if the path overlaps this object.
	if L >= tgt_w / 2 or R <= -tgt_w / 2 or T >= tgt_h / 2 or B <= -tgt_h / 2 then
		mask_uniform(alpha_outer, tgt_name);
		return;
	end

	-- send the coordinates to tempbuffer.
	temp_buffer_name = temp_buffer_name or "tempbuffer";
	send(points, num_points, tgt_w / 2, tgt_h / 2, temp_buffer_name);

	-- calculate the end points from the calculated length.
	local end_points = end_shape == 1 and
		find_end_points(points, num_points, loop, start_pos, end_pos, tgt_w / 2, tgt_h / 2) or nil;

	path_mask_line_buffered(
		alpha_outer, alpha_inner, line_width, antialias,
		temp_buffer_name, num_points, len, loop,
		start_pos, end_pos, end_shape, end_points,
		dash_pat, dash_pos, dash_adj,
		target_buffer);
end

---Lua のエラーメッセージを，AviUtl2 が標準で出力する形式を真似て出力する．
---@param err_mes string Lua からのエラーメッセージ．
---@param source string エラー元となった Lua スクリプトのソースコード．
local function print_script_error(err_mes, source)
	local n, err_desc = err_mes:match("%]:(%d+):%s(.-)$");
	n = tonumber(n);
	if n and err_desc then
		-- collect three lines containing the one that caused the error.
		n = math.max(n - 1, 1);
		local k = 0;
		for l in (source.."\n"):gmatch("(.-)\n") do
			k = k + 1;
			if k >= n then
				err_desc = err_desc.."\n> "..l;
				if k >= n + 2 then break end
			end
		end
	else err_desc = err_mes end
	print(err_desc); -- easy-to-read message.
	print("@warn", err_mes); -- raw message.
end

-- return the table containing the exported functions.
return {
	anchor = anchor,
	poll = poll,
	measure = measure,
	find_index = find_index,
	find_end_points = find_end_points,
	transform = transform,
	randomize = randomize,
	send = send,
	retrieve = retrieve,

	path_mask_area_buffered = path_mask_area_buffered,
	path_mask_area = path_mask_area,
	path_mask_line_buffered = path_mask_line_buffered,
	path_mask_line = path_mask_line,

	print_script_error = print_script_error,
};
