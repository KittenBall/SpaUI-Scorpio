Scorpio "SpaUI" ""

-- Logger
Log = Logger("SpaUI")
Log:AddHandler(function(...) print("|cffffffff", ..., "|r") end, Logger.LogLevel.Info)
Log:AddHandler(function(...) print("|cff33ccff", ..., "|r") end, Logger.LogLevel.Warn)
Log:AddHandler(function(...) print("|cffff3300", ..., "|r") end, Logger.LogLevel.Error)
Log:SetPrefix(Logger.LogLevel.Info, " Info:")
Log:SetPrefix(Logger.LogLevel.Warn, " Warn:")
Log:SetPrefix(Logger.LogLevel.Error, " Error:")
Log.TimeFormat = L["addon_name"] .." %Y%m%d %X"

function Log.Info(...)
    Log(Logger.LogLevel.Info, ...)
end

function Log.Warn(...)
    Log(Logger.LogLevel.Warn, ...)
end

function Log.Error(...)
    Log(Logger.LogLevel.Error, ...)
end

-- 调试模式打开/关闭
__SystemEvent__()
function SPAUI_DEBUGGABLE_CHANGED()
    Log.LogLevel = _Config.Debuggable and Logger.LogLevel.Info or Logger.LogLevel.Error
end

function Dump(value, type)
    print(Toolset.tostring(value, type, false))
end

-- 显示红字错误
__Arguments__{NEString}
function ShowUIError(text)
    UIErrorsFrame:AddMessage(text, 1.0, 0.0, 0.0, 1, 3)
end

-- 显示消息
__Arguments__{NEString}
function ShowMessage(text)
    print(L["message_format"]:format(text))
end