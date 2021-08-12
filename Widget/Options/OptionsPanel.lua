Scorpio "SpaUI.Widget.Options" ""

namespace "SpaUI.Widget.Options"

__Sealed__()
class "OptionsPanel"(function(_ENV)
    inherit "Frame"

    
end)

Style.UpdateSkin("Default", {
    [OptionsPanel]              = {
        location                = {
            Anchor("TOPLEFT", 15, -15),
            Anchor("BOTTOMLEFT", -15, 15)
        }
    }
})