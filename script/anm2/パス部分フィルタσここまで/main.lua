--information:パス部分フィルタσここまで@Path_S ${PACKAGE_VERSION} by ${AUTHOR}
--label:Path_S\加工
--require:${LEAST_AVIUTL_VERSION}
local path_s = require("Path_S");
local cxt = path_s.partial_filter.pop_cxt();
if cxt then path_s.partial_filter.combine(cxt) end
