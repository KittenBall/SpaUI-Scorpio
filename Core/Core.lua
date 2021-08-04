local addonName,_ = ...

Scorpio "SpaUI" ""

namespace "SpaUI"

-- DB
_Config = SVManager("SpaUIConfigDB","SpaUIConfigDBChar")

-- Locale
L = _Locale

__SlashCmd__ "rl"
function Reload()
    ReloadUI()
end