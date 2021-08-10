Scorpio "SpaUI.Widget.Options" ""

__Sealed__()
class "OptionsFrame"(function(_ENV)
    inherit "Dialog"

    local function OnKeyDown(self, key)
        if key == "ESCAPE" then
            self:Hide()
        end
        self:SetPropagateKeyboardInput(key ~= "ESCAPE")
    end

    local function OnHide(self)
	    PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT);
    end

    local function OnShow(self)
        self:SetDebuggable(_Config.Debuggable or false)
    end

    function SetDebuggable(self, debuggable)
        local debugButton = self:GetChild("DebugButton")
        debugButton:SetChecked(debuggable)
        debugButton:SetShown(debuggable)
    end

    __Template__{
        Version         = FontString,
        CategoryList    = OptionsCategoryList,
        PanelContainer  = Frame,
        DefaultButton   = UIPanelButton,
        OkayButton      = UIPanelButton,
        CancelButton    = UIPanelButton,
        DebugButton     = OptionsCheckButton
    }
    function __ctor(self)
        super(self)
        self.OnKeyDown = self.OnKeyDown + OnKeyDown
        self.OnHide = self.OnHide + OnHide
        self.OnShow = self.OnShow + OnShow
        self:SetDebuggable(_Config.Debuggable or false)

        local version = self:GetChild("Version")
        version:SetText(L["version"]:format(ScorpioVersion,AddonVersion))
    end
end)

Style.UpdateSkin("Default", {
    [OptionsFrame]                      = {
        size                            = Size(858, 660),

        Header                          = {
            text                        = L["config_panel_title"]
        },

        Resizer                         = {
            visible                     = false
        },

        CloseButton                     = {
            visible                     = false
        },

        Version                         = {
            location                    = { 
                Anchor("BOTTOMRIGHT", -10, 0, "PanelContainer", "TOPRIGHT")
            }
        },

        CategoryList                    = {
            location                    = {Anchor("TOPLEFT",22,-40)}
        },

        PanelContainer                  = {
            backdrop                    = {
                edgeFile                = [[Interface\Tooltips\UI-Tooltip-Border]],
                edgeSize                = 16,
                tileEdge                = true
            },  
            backdropBorderColor         = ColorType(0.6, 0.6, 0.6),
            location                    = {
                Anchor("TOPLEFT", 16, 0, "CategoryList", "TOPRIGHT"),
                Anchor("BOTTOMLEFT", 16, 1, "CategoryList", "BOTTOMRIGHT"),
                Anchor("RIGHT", -22, 0)
            }
        },

        DefaultButton                   = {
            size                        = Size(96,22),
            text                        = DEFAULTS,
            location                    = {Anchor("BOTTOMLEFT", 22, 16)}
        },          

        CancelButton                    = {
            size                        = Size(96,22),
            text                        = CANCEL,
            location                    = {Anchor("BOTTOMRIGHT", -22, 16)}
        },          

        OkayButton                      = {
            size                        = Size(96,22),
            text                        = OKAY,
            location                    = {Anchor("BOTTOMRIGHT", 0, 0, "CancelButton", "BOTTOMLEFT")}
        },

        DebugButton                     = {
            enabled                     = false,
            location                    = {Anchor("LEFT", 0, 0, "DefaultButton", "RIGHT")},
            Label                       = {
                text                    = L['debug_mode']
            }
        },
    }
})