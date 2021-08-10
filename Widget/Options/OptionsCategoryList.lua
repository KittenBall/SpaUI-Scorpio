Scorpio "SpaUI.Widget.Options" ""

__Sealed__()
class "OptionsCategoryList"(function(_ENV)
    inherit "FauxScrollFrame"

    local function OnCategoryListButtonCollapsedChanged(button)
        button:GetParent():GetParent():Refresh()
    end

    local function SetCategoryToButton(self, category, index)
        local button = self.Buttons[index]
        if not button then
            button = OptionsCategoryListButton("OptionsCategoryListButton"..index, self.ScrollChild)
            button.OnCollapsedChanged = OnCategoryListButtonCollapsedChanged
            self.Buttons[index] = button

            local relativeTo, yOffset
            if index == 1 then
                button:SetPoint("TOPLEFT", self.ScrollChild, "TOPLEFT", 0, -8)
            else
                button:SetPoint("TOPLEFT", self.Buttons[index-1], "BOTTOMLEFT", 0, -5)
            end
        end
        button:SetCategory(category)
        button:Show()
        index = index + 1

        if not category.Collapsed and category.SubCategories then
            for _, subCategory in ipairs(category.SubCategories) do
                index = SetCategoryToButton(self, subCategory, index)
            end
        end

        return index
    end

    function Refresh(self)
        local index = 1

        if self.ConfigCategories then
            for _, optionsCategory in ipairs(self.ConfigCategories) do
                index = SetCategoryToButton(self, optionsCategory, index)
            end
        end

        for i = index, #self.Buttons do
            self.Buttons[i]:Hide()
        end
    end

    __Arguments__(OptionsCategory)
    function AddCategory(self, optionsCategory)
        if optionsCategory.Level > 1 then
            Log.Error("OptionsCategoryList can only add categories with level 1")
            return
        end
        self.ConfigCategories = self.ConfigCategories or {}
        tinsert(self.ConfigCategories, optionsCategory)
        self:Refresh()
    end

    __Arguments__{List[OptionsCategory]}
    function SetCategories(self, configCategories)
        if not configCategories then
            self.ConfigCategories = nil
            self:Refresh()
            return
        end

        for index, optionsCategory in ipairs(configCategories) do
            if optionsCategory.Level > 1 then
                Log.Error("OptionsCategoryList can only add categories with level 1")
                return
            end
        end
        self.ConfigCategories = configCategories
        self:Refresh()
    end

    function __ctor(self)
        super(self)
        self.Buttons = self.Buttons or {}
    end
end)

Style.UpdateSkin("Default", {
    [OptionsCategoryList]           = {
        size                        = Size(175, 569),
        location                    = {Anchor("CENTER")},
        backdrop                    = {
            edgeFile                = [[Interface\Tooltips\UI-Tooltip-Border]],
            edgeSize                = 16,
            tileEdge                = true
        },
        backdropBorderColor         = ColorType(0.6, 0.6, 0.6, 0.6),
        scrollbarHideable           = true,

        ScrollBar                   = {
            location                = {
                Anchor("TOPRIGHT", -6, -26),
                Anchor("BOTTOMRIGHT", -6, 24)
            },
        }
    },
})
