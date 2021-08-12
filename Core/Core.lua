local addonName, _ = ...

Scorpio "SpaUI" ""

namespace "SpaUI"

-- Locale
L = _Locale

__SlashCmd__ "rl"
function Reload()
    ReloadUI()
end

function OnLoad()
    ScorpioVersion = GetAddOnMetadata("Scorpio", "version")
    AddonVersion = GetAddOnMetadata(addonName, "version")
    ShowMessage(L["addon_loaded_tip"]:format(AddonVersion))

    _Config = SVManager("SpaUIConfigDB", "SpaUIConfigDBChar")
    
    FireSystemEvent("SPAUI_DEBUGGABLE_CHANGED")
end
