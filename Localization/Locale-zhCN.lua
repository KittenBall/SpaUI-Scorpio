Scorpio "SpaUI.Localization.zhCN" ""

local L = _Locale("zhCN",true)

if not L then return end

---------- Do not Translate --------------
L["addon_name"] = "|cFF00FFFFS|r|cFFFFC0CBp|r|cFFFF6347a|r|cffffd200UI|r"
L["message_format"] = L["addon_name"]..":%s"
L["version"] = "Scorpio:|cFF00BFFF%s|r "..L["addon_name"]..":|cFF00BFFF%s|r"


---------- Universal String --------------
L["error_in_combat"] = "你正在战斗中"
L["debug_mode"] = "调试模式"
L["debug_enable"] = "调试模式已启用，你可以输入命令\"/spa debug 0\"关闭"
L["debug_disable"] = "调试模式已关闭，你可以输入命令\"/spa debug 1\"启用"

----------      Command    ---------------
L["cmd_error"] = "请输入正确的命令"
L["cmd_debug"] = "打开/关闭调试模式 0：关闭 1：打开"
L["cmd_config"] = "打开/关闭配置面板"


----------      Config     ---------------
L["config_panel_title"] = L["addon_name"].."配置面板"
L["config_panel_show_after_combat"] = "配置面板将在战斗结束后显示"