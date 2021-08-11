Scorpio "SpaUI.Widget.Options" ""

__Sealed__()
class "OptionsCheckButton" (function(_ENV)
    inherit "CheckButton"
    
    property "TooltipText" { type = NEString }

    function SetTooltipText(self, tooltipText)
        self.TooltipText = tooltipText
    end

    local function OnEnter(self)
        if self.TooltipText then
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
            GameTooltip:SetText(self.TooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end
    end

    local function OnLeave(self)
        GameTooltip:Hide()
    end

    local function OnClick(self)
        local checked = self:GetChecked()
        if checked then
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        else
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        end
    end

    function SetEnabled(self, enabled)
        super.SetEnabled(self, enabled)
        local Label = self:GetChild("Label")
        if enabled then
            local r, g, b = Label:GetFontObject():GetTextColor()
            Label:SetTextColor(r, g, b)
        else
            Label:SetTextColor(Color.DISABLED.r, Color.DISABLED.g, Color.DISABLED.b)
        end
    end

    __Template__{
        Label         = UICheckButtonLabel
    }
    function __ctor(self)
        self.OnEnter = self.OnEnter + OnEnter
        self.OnLeave = self.OnLeave + OnLeave
        self.OnClick = self.OnClick + OnClick
        local Label = self:GetChild("Label")
        Label:SetPoint("LEFT", self, "RIGHT", 2, 0)
    end
end)

Style.UpdateSkin("Default", {
    [OptionsCheckButton] = {
        size                    = Size(26, 26),

        normalTexture           = {
            file                = [[Interface\Buttons\UI-CheckBox-Up]],
            setAllPoints        = true,
        },
        pushedTexture           = {
            file                = [[Interface\Buttons\UI-CheckBox-Down]],
            setAllPoints        = true,
        },
        highlightTexture        = {
            file                = [[Interface\Buttons\UI-CheckBox-Highlight]],
            setAllPoints        = true,
            alphamode           = "ADD",
        },
        checkedTexture          = {
            file                = [[Interface\Buttons\UI-CheckBox-Check]],
            setAllPoints        = true,
        },
        disabledCheckedTexture  = {
            file                = [[Interface\Buttons\UI-CheckBox-Check-Disabled]],
            setAllPoints        = true,
        },

        Label                   = {
            fontObject          = GameFontHighlightLeft
        }
    }
})