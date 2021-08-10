Scorpio "SpaUI.Config" ""

import "SpaUI.Widget.Options"

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
    ToggleConfigPanel()
    if InCombatLockdown() then ShowUIError(L["error_in_combat"]) end
end

-- 开启/关闭面板
__SlashCmd__("spa", "config", L["cmd_config"])
__AsyncSingle__()
function ToggleConfigPanel()
    if InCombatLockdown() then
       ShowMessage(L['config_panel_show_after_combat'])
    end
    NoCombat()
    HideUIPanel(GameMenuFrame)

    if SpaUIConfigFrame then
        if SpaUIConfigFrame:IsShown() then
            SpaUIConfigFrame:Hide()
        else
            SpaUIConfigFrame:Show()
        end
    end

    _Enabled = true
end
 
-- 切换调试模式
__SlashCmd__("spa", "debug", L["cmd_debug"])
__AsyncSingle__()
function ToggleDebugMode(info)
    if not _Config then return end
    if info then
        info = strlower(info)
        if info == "0" or info == "off" or info == "disable" then
            _Config.Debuggable = false
            ShowMessage(L['debug_disable'])
        elseif info == "1" or info == "on" or info == "enable" then
            _Config.Debuggable = true
            ShowMessage(L['debug_enable'])
        else
            ShowMessage(L['cmd_error'])
        end
    else
        _Config.Debuggable = false
    end
    if SpaUIConfigFrame then
        SpaUIConfigFrame:SetDebuggable(_Config.Debuggable)
    end
    FireSystemEvent("SPAUI_DEBUGGABLE_CHANGED")
end

function OnEnable()
    if not SpaUIConfigFrame then
        CreateConfigPanel()
    end
end

-- 创建配置面板
__NoCombat__()
function CreateConfigPanel()
    if SpaUIConfigFrame then return end

    SpaUIConfigFrame = OptionsFrame("SpaUIConfigFrame")
end