--information:追加フィルタここまで@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
---$script_tips:「後続フィルタ」の範囲を指定します．
--label:Path_S
--require:${LEAST_AVIUTL_VERSION}
local path_s = require("Path_S");
local cxt = path_s.context_manager.pop();
---@diagnostic disable-next-line: param-type-mismatch
if path_s.partial_filter.check_cxt(cxt) then path_s.partial_filter.combine(cxt);
---@diagnostic disable-next-line: param-type-mismatch
elseif path_s.post_effect.check_cxt(cxt) then path_s.post_effect.combine(cxt) end
