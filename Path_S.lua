--[[
MIT License
Copyright (c) 2025 sigma-axis

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
-- v1.11 (for beta22a)
--

local obj, math, tonumber, bit, ffi, buffer = obj, math, tonumber, bit, require("ffi"), require("string.buffer");

if obj.getinfo("version") < 2002000 then
	error([[AviUtl ExEdit beta20 以降が必要です！]], 2);
end

local function pt(pts, i) return tonumber(pts[i]) or 0 end

---places anchors for the path.
---@param var_name string the name of the variable of the path points.
---@param path_type 0|1|2|3 specifies a type of a path.
---@param pts { [integer]: number? } the array of the points in the form `{ x1, y1, x2, y2, x3, y3, ... }`.
---@param n_segs integer the number of segments of the path.
---@param loop boolean whether the path is closed.
---@return integer n_anchors the number of anchor points for the path.
local function anchor(var_name, path_type, pts, n_segs, loop)
	local n_anchors = (loop and 0 or 1) + n_segs * (
		path_type == 0 and 1 or
		path_type == 1 and 1 or
		path_type == 2 and 2 or 3);
	if path_type == 3 then
		obj.setanchor(var_name, n_anchors);
		for i = 1, n_segs do
			local I, J = 6 * i, 6 * (loop and (i % n_segs) or i);
			obj.setanchor({
				pt(pts, I - 3), pt(pts, I - 2),
				pt(pts, I - 5), pt(pts, I - 4),
				pt(pts, J + 1), pt(pts, J + 2),
				pt(pts, I - 1), pt(pts, I - 0),
			}, 4, "line");
		end
	else obj.setanchor(var_name, n_anchors, loop and "loop" or "line") end
	return n_anchors;
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

---converts path into a sequence of secants.
---@param path_type 0|1|2|3 specifies a type of a path.
---@param pts { [integer]: number? } the array of the points in the form `{ x1, y1, x2, y2, x3, y3, ... }`.
---@param n_segs integer the number of segments of the path.
---@param looping boolean whether the path is closed.
---@param prec number the maximum length allowed for a secant.
---@return { [integer]: number } pts2 the array of numbers representing the sequence of end points of the secants.
---@return integer n_pts2 the number of points contained in `pts2`.
local function poll(path_type, pts, n_segs, looping, prec)
	local ret, n_ret;
	if path_type == 0 then
		ret, n_ret = {}, n_segs + 1;
		-- essentially a shallow copy of `pts`.
		for i = 1, 2 * n_ret do ret[i] = pt(pts, i) end
		if looping then
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
				if looping then
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
				local j = (i >= n_segs and looping) and 0 or i;
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
				local j = (i >= n_segs and looping) and 0 or i;
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

---measure the bounding box and the length of the path.
---@param pts { [integer]: number } the array to numbers representing the sequence of points.
---@param n_pts integer the number of points contained in `pts`.
---@return number L, number R, number T, number B represent the bounding box.
---@return number length the length of the whole path.
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

---find the index position where the length measured from the starting point is `pos`, using binary search.
---@param pos number if non-negative, the length measured from the starting point to find the position. if negative, it must be `>= -1.0` and its absolute value specifies the ratio relative to the length of the whole path.
---@param tbl { [integer]: number } either an array of points of the form `{ x1, y1, x2, y2, ... }`, in which case `n_pts` must be set, or an array of lengths `{ 0, l1, l2, ... }`, in which case `n_pts` must be `nil`.
---@param n_pts integer? the number of points contained in `tbl` when `tbl` specifies an array of points; otherwise must be `nil`.
---@return integer int_part the index of the section where `pos` is lying on.
---@return number frac_part the relative position of `pos` in the `int_part`-th section, from `0.0` to `1.0`.
---@return { [integer]: number } lengths an array of accumulated lengths measured from the starting point, which can be reused later.
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

---transforms a sequence of points by the specified scaling / rotation and translation.
---@param pts { [integer]: number } the array to numbers representing the sequence of points. its contents will be modified.
---@param n_pts integer the number of points contained in `pts`.
---@param scale number the scaling rate of the transform.
---@param rotate number the rotation angle of the transform, in radians.
---@param dx number? the translation along x-axis. it's applied after the scaling and rotation, defaults to 0.
---@param dy number? the translation along y-axis. it's applied after the scaling and rotation, defaults to 0.
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
---applies random moves to the path. this function uses `obj.rand1()` for PRNG.
---@param pts { [integer]: number } the array of points of the path. path is assumed to be an array of straight secants.
---@param n_pts integer the number of points contained in `pts`.
---@param period number the period in the length of the path per PRNG invocation. must be positive.
---@param rand_range number the radius of the random range in pixels.
---@param end_mode 0|1|2 0: no special behavior, 1: the ends do not move, 2: the two ends move the same.
---@param seed number the random seed for `obj.rand1()` function.
---@return { [integer]: number } pts2 the new array of points representing the randomized path.
---@return integer n_pts2 the number points contained in `pts2`.
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

local function encode_float(x)
	local d, m, M = 2 ^ 8, -2 ^ 23, 2 ^ 23 - 1;
	return bit.bor(0xff000000, math.min(math.max(math.floor(x * d + 0.5), m), M));
end
local function decode_float(c)
	local d = 2 ^ 16;
	return bit.lshift(c, 8) / d;
end
local uint32_t_array, uint32_t_ptr, intptr_t = ffi.typeof("uint32_t[?]"), ffi.typeof("uint32_t*"), ffi.typeof("intptr_t");
-- converts a pointer to a light userdata.
local function to_userdata(ptr)
	-- 0x05: lightud64. (https://luajit.org/ext_buffer.html)
	return buffer.decode("\x05"..buffer.encode(ffi.cast(intptr_t, ptr)):sub(2));
end
---sends the coordinates of the points in `pts` to the buffer specified by `target`.
---@param pts { [integer]: number } the array to numbers representing the sequence of points.
---@param n_pts integer the number of points contained in `pts`.
---@param dx number? offset x-coordinate applied to each point, defaults to 0.
---@param dy number? offset y-coordinate applied to each point, defaults to 0.
---@param target string? either `"tempbuffer"` or of the form `"cache:..."` that specifies the destination buffer. defaults to `"tempbuffer"`.
local function send(pts, n_pts, dx, dy, target)
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

---retrieves the coordinates of the points from the buffer specified by `target`.
---@param n_pts integer the number of points expected to be retrieved from the buffer.
---@param target string? either `"tempbuffer"` or of the form `"cache:..."` that specifies the source buffer. defaults to `"tempbuffer"`.
---@return { [integer]: number }? pts the desired array of numbers representing the sequence of points, or nil if the buffer did not fit `n_pts`.
local function retrieve(n_pts, target)
	local max_width = 2 ^ 12;
	local w, h =
		math.min(2 * n_pts, max_width),
		math.ceil(2 * n_pts / max_width);
	local data, W, H = obj.getpixeldata(target or "tempbuffer");
	if H < h or (h > 1 and W ~= w) or W < w then return nil end
	local ret, ptr = {}, ffi.cast(uint32_t_ptr, data);
	for i = 1, 2 * n_pts do ret[i] = decode_float(ptr[i - 1]) end
	return ret;
end

-- return the table containing the exported functions.
return {
	anchor = anchor,
	poll = poll,
	measure = measure,
	find_index = find_index,
	transform = transform,
	randomize = randomize,
	send = send,
	retrieve = retrieve,
};
