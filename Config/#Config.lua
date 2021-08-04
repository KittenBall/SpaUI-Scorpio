Scorpio "SpaUI.Config" ""

namespace "SpaUI.Widget.Config"

__Sealed__()
interface "OptionItem" (function(_ENV)

    __Abstract__()
    property "ConfigBehavior"

    function SetConfigBehavior(self, behavior)
        self.ConfigBehavior = behavior
    end

    function GetConfigBehavior(self)
        return self.ConfigBehavior
    end

    -- 值变化回调
    function OnValueChange(self,...)
        if self.ConfigBehavior and self.ConfigBehavior.OnValueChange then
            return self.ConfigBehavior:OnValueChange(...)
        end
    end

    -- 是否需要重载
    function NeedReload(self)
        return self.ConfigBehavior and self.ConfigBehavior.NeedReload and self.ConfigBehavior:NeedReload()
    end

    -- 保存配置
    function SaveConfig(self)
        if self.ConfigBehavior and self.ConfigBehavior.SaveConfig then
            return self.ConfigBehavior:SaveConfig()
        end
    end

    -- 重置，对于需要重载的配置项，在重载前的数值变更并不会真的应用
    -- 如果没有重载，则此函数会将其值还原为原来的值
    function Restore(self)
        if self.ConfigBehavior then
            if self.ConfigBehavior.GetValue then
                self:OnRestore(self.ConfigBehavior:GetValue())
            end
            if self.ConfigBehavior.Restore then
                return self.ConfigBehavior:Restore()
            end
        end
    end

    -- 重置回调，由实现ConfigItem的子类实现
    __Abstract__()
    function OnRestore(self, ...) end
end)

-------------------------
-------- Widget ---------
-------------------------

-- Config Conatiner
__Sealed__()
class "OptionsContainer" (function(_ENV)
    inherit "Frame"

    local function IsOptionItem(item)
        return Interface.ValidateValue(OptionItem, item)
    end

    -- 保存配置
    function SaveConfig(self)
        for _, child in self:GetChilds() do
            if IsOptionItem(child) then
                child:SaveConfig()
            end
            SaveConfig(child)
        end
    end

    -- 是否需要重载
    function NeedReload(self)
        for _, child in self:GetChilds() do
            if (IsOptionItem(child) and child:NeedReload()) or NeedReload(child) then
                return true
            end
        end
    end

    -- 重置
    function Restore(self)
        for _, child in self:GetChilds() do
            if IsOptionItem(child) then
                child:Restore()
            end
            Restore(child)
        end
    end
end)

-- ConfigPanel CheckButton
__Sealed__()
class "OptionsCheckButton" (function(_ENV)
    inherit "CheckButton"
    extend "OptionItem"
    
    property "TooltipText" { type = NEString }
    
    property "ConfigBehavior" {
        type                    = RawTable,
        handler                 = function(self, behavior)
            if behavior then
                if behavior.GetValue then
                    self:SetChecked(behavior:GetValue())
                end
                local Label = self:GetChild("Label")
                local CharIndicator = self:GetChild("CharIndicator")
                Label:ClearAllPoints()
                if behavior.IsCharOption then
                    CharIndicator:Show()
                    Label:SetPoint("LEFT", CharIndicator, "RIGHT", 0, 0)
                else
                    CharIndicator:Hide()
                    Label:SetPoint("LEFT", self, "RIGHT", 2, 0)
                end
            end
        end
    }

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

    local function ChangeChildrenEnabled(self)
        local checked = self:GetChecked()
        local enabled = self:IsEnabled()
        for _, child in self:GetChilds() do
            if child.SetEnabled then
                child:InstantApplyStyle()
                child:SetEnabled(enabled and checked)
            end
        end
    end

    local function OnClick(self)
        local checked = self:GetChecked()
        if checked then
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
        else
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
        end
        self:OnValueChange(checked)
        ChangeChildrenEnabled(self)
    end

    function SetChecked(self, checked)
        super.SetChecked(self, checked)
        ChangeChildrenEnabled(self)
    end

    function OnRestore(self, value)
        self:SetChecked(value)
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
        ChangeChildrenEnabled(self)
    end

    __Template__{
        Label         = UICheckButtonLabel,
        CharIndicator = Texture
    }
    function __ctor(self)
        self.OnEnter = self.OnEnter + OnEnter
        self.OnLeave = self.OnLeave + OnLeave
        self.OnClick = self.OnClick + OnClick
        local Label = self:GetChild("Label")
        local CharIndicator = self:GetChild("CharIndicator")
        CharIndicator:SetPoint("LEFT", self, "RIGHT", 2, 0)
        CharIndicator:Hide()
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

        CharIndicator           = {
            file                = [[Interface\Addons\SpaUI\Media\char_indicator]],
            size                = Size(22, 22)
        },

        Label                   = {
            fontObject          = GameFontHighlightLeft
        }
    }
})

-- CategoryList Button
__Sealed__()
class "CategoryListButton"(function(_ENV)
    inherit "CheckButton"

    event "OnCollpasedChanged"

    local function ToggleChild(self, collapsed)
        local toggle = self:GetChild("Toggle")
        if collapsed then
			toggle:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP");
			toggle:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-DOWN");
        else
			toggle:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP");
			toggle:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-DOWN");
        end
        OnCollpasedChanged(self, collapsed)
    end

    property "Collapsed" {
        type        = Boolean,
        default     = true,
        handler     = ToggleChild
    }

    function SetCategory(self,category)
        self.category = category
        local name = category.name
        if category.isCharOption then
            name = L["config_char_indicator"]..name
        end
        self:SetText(name)
        local toggle = self:GetChild("Toggle")
        if category.parent then
            self:SetNormalFontObject(GameFontHighlightSmall);
            self:SetHighlightFontObject(GameFontHighlightSmall);
            self:GetFontString():SetPoint("LEFT", 16, 2)
            toggle:Hide()
            self:Hide()
        else
            self:SetNormalFontObject(GameFontNormal);
            self:SetHighlightFontObject(GameFontHighlight);
            self:GetFontString():SetPoint("LEFT", 8, 2)
            self:Show()
            if category.children then
                toggle:Show()
            end
        end
    end

    local function OnClick(self)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end

    local function OnDoubleClick(self)
        if self.Collapsed then
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
            self.Collapsed = not self.Collapsed
        end
    end

    local function OnToggleClick(self)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
        local parent = self:GetParent()
        parent.Collapsed = not parent.Collapsed
    end

    __Template__{
        Toggle          = Button
    }
    function __ctor(self)
        self.OnClick = self.OnClick + OnClick
        self.OnDoubleClick = self.OnDoubleClick + OnDoubleClick
        local toggle = self:GetChild("Toggle")
        toggle.OnClick = toggle.OnClick + OnToggleClick
        self:InstantApplyStyle()
    end
end)

Style.UpdateSkin("Default", {
    [CategoryListButton] = {
        size                    = Size(175, 18),
        highlightTexture        = {
            file                = [[Interface\QuestFrame\UI-QuestLogTitleHighlight]],
            alphaMode           = "ADD",
            vertexColor         = ColorType(.196, .388, .8),
            location            = {
                Anchor("TOPLEFT", 0, 1),
                Anchor("BOTTOMRIGHT", 0, 1)
            }
        },
        buttonText              = {
            justifyH            = "LEFT",
            wordwrap            = false
        },

        Toggle                  = {
            size                = Size(14, 14),
            location            = {
                Anchor("TOPRIGHT", -6, -1)
            },
            visible             = false,
            normalTexture       = {
                setAllPoints    = true,
                file            = [[Interface\Buttons\UI-PlusButton-UP]]
            },
            pushedTexture       = {
                setAllPoints    = true,
                file            = [[Interface\Buttons\UI-PlusButton-DOWN]]
            },
            highlightTexture    = {
                setAllPoints    = true,
                file            = [[Interface\Buttons\UI-PlusButton-Hilight]],
                alphaMode       = "ADD"
            }
        }
    }
})

-- Line
__Sealed__() __Template__(Texture)
class "OptionsLine" {}

Style.UpdateSkin("Default", {
    [OptionsLine] = {
        height                  = 1,
        color                   = ColorType(1, 1, 1, 0.2)
    }
})

-- ConfigPanel DropDownMenu
__Sealed__()
class "OptionsDropDownMenu" (function(_ENV)
    inherit "Frame"
    extend "OptionItem"

    -- DropDownMenu GetValue至少需要返回两个参数
    -- 不要在ConfigBehavior内保存值
    -- return arg1:value
    -- return arg2:text
    property "ConfigBehavior" {
        type                    = RawTable,
        handler                 = function(self, behavior)
            CloseDropDownMenus()
            if behavior then
                if behavior.GetValue then
                    local _, text = behavior:GetValue()
                    self:SetText(text)
                end
                local CharIndicator = self:GetChild("CharIndicator")
                if behavior.IsCharOption then
                    CharIndicator:Show()
                else
                    CharIndicator:Hide()
                end
            end
        end
    }

    property "DropDownInfos" {
        type                    = RawTable,
        handler                 = function(self, infos)
            self:SetEnabled(infos and #infos > 0)
        end
    }

    property "DisplayTextJustifyH" {
        type                    = JustifyHType,
        handler                 = function(self, justifyH)
            UIDropDownMenu_JustifyText(self, justifyH)
        end
    }

    property "TooltipText" { type = NEString }

    local function OnEnter(self)
        if self.TooltipText then
            GameTooltip:SetOwner(self,"ANCHOR_TOP")
            GameTooltip:SetText(self.TooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end
    end

    local function OnLeave(self)
        GameTooltip:Hide()
    end

    local function OnItemSelect(button, arg1, arg2, checked)
        if button and button:GetParent() and button:GetParent().dropdown then
            local self = button:GetParent().dropdown
            -- 如果返回true，则改变当前文本
            local result = self:OnValueChange(arg1, arg2, checked)
            if result == true then
                SetText(self,arg2)
            end
        end
        CloseDropDownMenus()
    end

    local function SetupInfo(info, value)
        info.value = info.value or info.text
        info.arg1 = info.arg1 or info.value or info.text
        info.arg2 = info.arg2 or info.text
        info.func = OnItemSelect
        info.tooltipTitle = (not info.tooltipTitle and info.tooltipText) and info.text or nil
        info.tooltipOnButton = (info.tooltipText or info.tooltipTitle) and true or false
        info.hasArrow = info.menuList and #info.menuList > 0
        info.checked = IsInfoChecked(info, value)
    end

    function IsInfoChecked(info, value)
        if value == nil then return false end
        if info.arg1 == value then return true end
        if info.menuList and #info.menuList > 0 then
            for _, childInfo in ipairs(info.menuList) do
                SetupInfo(childInfo)
                if childInfo.hasArrow then
                    return IsInfoChecked(childInfo, value)
                else
                    return childInfo.arg1 == value
                end
            end
        end
        return false
    end

    -- 判断是否选中的条件为arg1是否与ConfigBehavior返回的第一个参数相等
    -- 如果arg1为nil，则会取value，继而取text
    local function DropDownInitialize(self, level, menuList)
        local infos = (( level or 1 ) == 1 ) and self.DropDownInfos or menuList
        if not infos or #infos <= 0 then return end
        local value = self.ConfigBehavior and self.ConfigBehavior.TempValue or (self.ConfigBehavior.GetValue and self.ConfigBehavior:GetValue())
        for _, info in ipairs(infos) do
            SetupInfo(info, value)
            UIDropDownMenu_AddButton(info, level)
        end
    end

    function SetText(self, text)
        UIDropDownMenu_SetText(self, text)
    end

    function OnRestore(self, _, text)
        self:SetText(text)
    end

    property "DropDownMenuWidth" {
        type                = Number,
        handler             = function(self, width)
            UIDropDownMenu_SetWidth(self, width)
        end
    }

    function SetEnabled(self, enable)
        if enable then
            UIDropDownMenu_EnableDropDown(self)
        else
            UIDropDownMenu_DisableDropDown(self)
        end
    end

    __Template__{
        Label           = FontString,
        CharIndicator   = Texture
    }
    function __ctor(self)
        self.OnEnter = self.OnEnter + OnEnter
        self.OnLeave = self.OnLeave + OnLeave
        self:SetEnabled(false)
        -- 锚点对齐框体.
        UIDropDownMenu_SetAnchor(self, 14, 22)
        UIDropDownMenu_Initialize(self, DropDownInitialize)
        UIDropDownMenu_JustifyText(self,"LEFT")

        local CharIndicator = self:GetChild("CharIndicator")
        local Label = self:GetChild("Label")
        CharIndicator:SetTexture[[Interface\Addons\SpaUI\Media\char_indicator]]
        CharIndicator:SetSize(22, 22)
        CharIndicator:SetPoint("RIGHT", Label, "LEFT", 0, 0)
        CharIndicator:Hide()
    end

    function __new(_,_,parent,...)
        return CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    end
end)

-- ConfigPanel OptionsSlider
class "OptionsSlider" (function(_ENV)
    inherit "Slider"
    extend "OptionItem"

    property "ConfigBehavior" {
        type                    = RawTable,
        handler                 = function(self, behavior)
            if behavior then
                if behavior.GetValue then
                    local value, minRange, maxRange, valueStep = behavior:GetValue()
                    self:SetValueStep(valueStep)
                    self:SetMinMaxValues(minRange, maxRange)
                    self:SetValue(value)
                end
                local Label = self:GetChild("Label")
                local CharIndicator = self:GetChild("CharIndicator")
                Label:ClearAllPoints()
                if behavior.IsCharOption then
                    CharIndicator:Show()
                    Label:SetPoint("BOTTOM", self, "TOP", 7, -3)
                else
                    CharIndicator:Hide()
                    Label:SetPoint("BOTTOM", self, "TOP", 0, -3)
                end
            end
        end
    }

    function SetValueStep(self, valueStep)
        super.SetValueStep(self, valueStep)
        self._ValueStep = valueStep
    end

    function GetValueStep(self)
        return self._ValueStep or super.GetValueStep(self)
    end

    function SetMinMaxValues(self, minValue, maxValue)
        super.SetMinMaxValues(self, minValue, maxValue)
        -- Slider GetValue GetValueStep GetMinMaxValues取出来的浮点数精度太高了
        self._MinValue = minValue
        self._MaxValue = maxValue
        local MinText = self:GetChild("MinText")
        MinText:SetText(tostring(minValue))
        local MaxText = self:GetChild("MaxText")
        MaxText:SetText(tostring(maxValue))
    end

    function GetMinMaxValues(self)
        local minValue, maxValue = super.GetMinMaxValues(self)
        return self._MinValue or minValue, self._MaxValue or maxValue
    end

    function GetValue(self)
        local value             = super.GetValue(self)
        local step              = self:GetValueStep()

        if value and step then
            local count         = tostring(step):match("%.%d+")
            count               = count and 10 ^ (#count - 1) or 1
            return floor(count * value) / count
        end

        return value
    end

    local function OnValueChanged(self, value)
        value = value or 0
        local valueStep = self:GetValueStep()
        local factor = 1 / valueStep
		value = floor(value * factor + 0.5) / factor
        local Text = self:GetChild("Text")
        Text:SetText(tostring(value))
        Text:SetCursorPosition(0)
        Text:ClearFocus()
        self:OnValueChange(value)
    end

    local function OnEnterPressed(self)
        local Slider = self:GetParent()
        local minValue, maxValue = self._MinValue, self._MaxValue
        if not minValue or not maxValue then
            minValue, maxValue = Slider:GetMinMaxValues()
        end
        local value = tonumber(self:GetText()) or Slider:GetValue() or minValue
        local valueStep = self._ValueStep or Slider:GetValueStep()
        local factor = 1 / valueStep
		value = floor(value * factor + 0.5) / factor
		value = max(minValue, min(maxValue, value))
		Slider:SetValue(value)
    end

    local function OnChar(self)
        self:SetText(self:GetText():gsub('[^%.0-9]+', ''):gsub('(%..*)%.', '%1'))
    end

    function OnRestore(self, value)
        self:SetValue(value)
    end

    function SetEnabled(self, enable)
        super.SetEnabled(self, enable)
        local Text = self:GetChild("Text")
        local MinText = self:GetChild("MinText")
        local MaxText = self:GetChild("MaxText")
        local Label = self:GetChild("Label")

        if enable then
            Label:SetTextColor(NORMAL_FONT_COLOR.r , NORMAL_FONT_COLOR.g , NORMAL_FONT_COLOR.b)
            Text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            MinText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            MaxText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        else
            local r, g, b = Color.DISABLED.r, Color.DISABLED.g, Color.DISABLED.b
            Label:SetTextColor(r, g, b)
            Text:SetTextColor(r, g, b)
            MinText:SetTextColor(r, g, b)
            MaxText:SetTextColor(r, g, b)
        end
    end

    local function SetMaxLetters(inputBox, maxLetters)
        EditBox.SetMaxLetters(inputBox, maxLetters)
        local text = inputBox:GetText()
        if text then
            inputBox:SetText(text:sub(1, maxLetters))
            inputBox:SetCursorPosition(0)
        end
    end

    __Template__{
        MinText             = FontString,
        MaxText             = FontString,
        Text                = InputBox,
        Label               = FontString,
        CharIndicator       = Texture
    }
    function __ctor(self)
        self:InstantApplyStyle()
        self.OnValueChanged = self.OnValueChanged + OnValueChanged
        local Text = self:GetChild("Text")
        Text.SetMaxLetters = SetMaxLetters
        Text.OnEnterPressed = Text.OnEnterPressed + OnEnterPressed
        Text.OnChar = Text.OnChar + OnChar
    end
end)

Style.UpdateSkin("Default", {
    [OptionsSlider] = {
        hitRectInsets               = Inset(0, 0, -10, -10),
        orientation                 = "HORIZONTAL",
        enableMouse                 = true,
        size                        = Size(144, 17),
        backdrop                    = {
            bgFile                  = "Interface\\Buttons\\UI-SliderBar-Background",
	        edgeFile                = "Interface\\Buttons\\UI-SliderBar-Border",
	        tile                    = true,
	        tileEdge                = true,
	        tileSize                = 8,
	        edgeSize                = 8,
	        insets                  = { left = 3, right = 3, top = 6, bottom = 6 },
        },

        ThumbTexture                = {
            file                    = [[Interface\Buttons\UI-SliderBar-Button-Horizontal]],
            size                    = Size(32, 32),
        },

        MinText                     = {
            fontObject              = OptionsFontHighlight,
            location                = {
                Anchor("TOPLEFT", -4, 0, nil, "BOTTOMLEFT")
            }
        },

        MaxText                     = {
            fontObject              = OptionsFontHighlight,
            location                = {
                Anchor("TOPRIGHT", 4, 0, nil, "BOTTOMRIGHT")
            }
        },

        Text                        = {
            fontObject              = OptionsFontHighlight,
            location                = {
                Anchor("TOP", 0, 0, nil, "BOTTOM")
            },
            justifyH                = "CENTER"
        },

        CharIndicator               = {
            file                    = [[Interface\Addons\SpaUI\Media\char_indicator]],
            size                    = Size(22, 22),
            location                = {
                Anchor("RIGHT", 0, 0, "Label", "LEFT")
            },
            visible                 = false
        },

        Label                       = {
            fontObject              = GameFontNormalSmall,
            justifyH                = "CENTER",
            location                = {
                Anchor("BOTTOM", 0, -3, nil, "TOP")
            }
        }
    }
})

class "OptionsModifierKey"(function(_ENV)

    __Static__()
    property "SHIFT" { set = false, type = NEString, default = "SHIFT" }

    __Static__()
    property "ALT" { set = false, type = NEString, default = "ALT" }

    __Static__()
    property "CTRL" { set = false, type = NEString, default = "CTRL" }

    __Static__()
    property "NONE" { set = false, type = NEString, default = "NONE" }

    __Static__()
    __Arguments__(NEString)
    function IsKeyDown(key)
        if key == "SHIFT" then
            return IsShiftKeyDown()
        elseif key == "ALT" then
            return IsAltKeyDown()
        elseif key == "CTRL" then
            return IsControlKeyDown()
        end
    end

    __Static__()
    __Arguments__(NEString)
    function GetKeyText(key)
        if key == "SHIFT" then
            return SHIFT_KEY
        elseif key == "ALT" then
            return ALT_KEY
        elseif key == "CTRL" then
            return CTRL_KEY
        else
            return NONE_KEY
        end
    end
end)

