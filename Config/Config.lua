Scorpio "SpaUI.Config" ""

function OnLoad()
    _Enabled = false
    hooksecurefunc("GameMenuFrame_UpdateVisibleButtons", InjectConfigButtonToGameMenu)
end

-- 游戏菜单注入Config按钮
function InjectConfigButtonToGameMenu()
    if not SpaUIConfigButton then
        SpaUIConfigButton = Button("SpaUIConfigButton", GameMenuFrame, "GameMenuButtonTemplate")
        local _, relativeTo, _, _, offY = GameMenuButtonStore:GetPoint()
        SpaUIConfigButton:SetText(L["addon_name"])
        SpaUIConfigButton:SetPoint("TOP", relativeTo, "BOTTOM", 0, offY)
        SpaUIConfigButton.OnClick = OnGameMenuConfigButtonClick
        GameMenuButtonStore:ClearAllPoints()
        GameMenuButtonStore:SetPoint("TOP", SpaUIConfigButton, "BOTTOM", 0, offY)
    end
    GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + SpaUIConfigButton:GetHeight() + 1)
end

function OnGameMenuConfigButtonClick(self)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    -- ToggleConfigPanel()
    -- todo
    -- if InCombatLockdown() then ShowUIError(L["combat_error"]) end
end