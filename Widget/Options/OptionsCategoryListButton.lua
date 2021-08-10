Scorpio "SpaUI.Widget.Options" ""

__Sealed__()
class "OptionsCategory"(function(_ENV)

    __Arguments__ {PositiveNumber, NEString, Boolean/true}
    function __new(_, level, name, enabled)
        return {
            Level       = level,
            Name        = name,
            Enabled     = enabled
        }
    end

    __Arguments__ {OptionsCategory, NaturalNumber / nil}
    function AddSubCategory(self, subCategory, index)
        if subCategory.Level <= self.Level then
            Log.Error("SubCategory' level should be greater than parent's level")
            return
        end
        self.SubCategories = self.SubCategories or {}
        if index then
            tinsert(self.SubCategories, index, subCategory)
        else
            tinsert(self.SubCategories, subCategory)
        end
    end

    --是否可以展开
    function CanExpand(self)
        if not self.Enabled then return end

        if self.SubCategories and #self.SubCategories > 0 then
            for index, subCategory in ipairs(self.SubCategories) do
                if subCategory.Enabled then
                    return true
                end                
            end
        end
    end
    
    property "Collapsed" {
        type        = Boolean,
        default     = true
    }
end)

-- CategoryList Button
__Sealed__()
class "OptionsCategoryListButton"(function(_ENV)
    inherit "CheckButton"

    __Arguments__(OptionsCategory/nil)
    function SetCategory(self, category)
        self.category = category
        if category then
            self:SetText(category.Name)
            
            local toggle = self:GetChild("Toggle")
            if category:CanExpand() then
                toggle:Show()
            else
                toggle:Hide()
            end
            self:SetEnabled(category.Enabled)
            if category.Level > 1 then
                self:SetNormalFontObject(GameFontHighlightSmall);
                self:SetHighlightFontObject(GameFontHighlightSmall);
            else
                self:SetNormalFontObject(GameFontNormal);
                self:SetHighlightFontObject(GameFontHighlight);
            end
            self:GetFontString():SetPoint("LEFT", category.Level*8, 2)
        else
            self:Hide()
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
        if parent.category then
            parent.category.Collapsed = not parent.category.Collapsed

            if parent.category.Collapsed then
			    self:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP");
			    self:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-DOWN");
            else
			    self:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP");
			    self:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-DOWN");
            end

            OnCollapsedChanged(parent) 
        end
    end

    event "OnCollapsedChanged"

    __Template__{
        Toggle          = Button
    }
    __InstantApplyStyle__()
    function __ctor(self)
        self.OnClick = self.OnClick + OnClick
        self.OnDoubleClick = self.OnDoubleClick + OnDoubleClick
        local toggle = self:GetChild("Toggle")
        toggle.OnClick = toggle.OnClick + OnToggleClick
    end
end)

Style.UpdateSkin("Default", {
    [OptionsCategoryListButton] = {
        size                    = Size(165, 18),
        highlightTexture        = {
            file                = [[Interface\QuestFrame\UI-QuestLogTitleHighlight]],
            alphaMode           = "ADD",
            vertexColor         = ColorType(.196, .388, .8),
            location            = {
                Anchor("TOPLEFT", 0, 1),
                Anchor("BOTTOMRIGHT", 0, 1)
            }
        },
        disabledFont            = GameFontNormalGraySmall,
        buttonText              = {
            justifyH            = "LEFT",
            wordwrap            = false,
            location            = {
                Anchor("RIGHT", 0, 0, "Toggle", "LEFT")
            }
        },

        Toggle                  = {
            size                = Size(14, 14),
            location            = {
                Anchor("TOPRIGHT", 0, -1)
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