-- 非推奨化に伴い，このスクリプトは更新凍結 / information も固定．
--hidemenu
--information:パス部分フィルタσここまで@Path_S v2.40 by σ軸
---$script_tips:「パス部分フィルタσ」での「後続フィルタ」の範囲を指定します．
--label:Path_S\加工
--require:${LEAST_AVIUTL_VERSION}
local path_s = require("Path_S");
local cxt = path_s.partial_filter.check_cxt(path_s.context_manager.pop());
if cxt then path_s.partial_filter.combine(cxt) end
