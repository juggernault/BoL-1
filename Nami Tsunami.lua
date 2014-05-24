--[[

    Nami Tsunami by Lillgoalie
    Version: 1.0
    
    Features:
        - Combo Mode using VPrediction
        - Harass
        - Auto Harass
        - Auto Heal

    
    Instructions on saving the file:
    - Save the file in scripts folder
    
--]]

require 'VPrediction'
require 'SOW'

if myHero.charName ~= "Nami" then return end

local ts

local QRange, QSpeed, QDelay, QRadius = 865, 1750, 0.55, 200
local WRange = 725
local ERange = 800
local RSpeed, RDelay, RRadius = 1200, 0.5, 590

local VP = nil

local qOff, wOff, eOff, rOff = 0,0,0,0
local abilitySequence = {1, 2, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1}

-- Code -------------------------------------------

function OnLoad()
    local VP = VPrediction()
    Orbwalker = SOW(VP)
    ts = TargetSelector(TARGET_LESS_CAST, 2400)

    Menu = scriptConfig("Nami Tsunami", "NamiBL")

    Menu:addTS(ts)
    ts.name = "Target Selector"

    Menu:addSubMenu("["..myHero.charName.." - Orbwalker]", "SOWorb")
    Orbwalker:LoadToMenu(Menu.SOWorb)

    Menu:addSubMenu("["..myHero.charName.." - Combo]", "NamiCombo")
    Menu.NamiCombo:addParam("combo", "Combo key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.NamiCombo:addParam("useQ", "Use Q in combo", SCRIPT_PARAM_ONOFF, true)
    Menu.NamiCombo:addParam("useW", "Use W in combo", SCRIPT_PARAM_ONOFF, true)
    Menu.NamiCombo:addParam("useE", "Use E in combo", SCRIPT_PARAM_ONOFF, true)
    Menu.NamiCombo:addSubMenu("Ultimate settings", "Rset")
    Menu.NamiCombo.Rset:addParam("comboR", "Use Ultimate in combo", SCRIPT_PARAM_ONOFF, true)
    Menu.NamiCombo.Rset:addParam("RuseRange", "Range to use ultimate", SCRIPT_PARAM_SLICE, 1000, 0, 2200, 0)
    Menu.NamiCombo.Rset:addParam("MinimumR", "Minimum enemies to ultimate on", SCRIPT_PARAM_SLICE, 1, 1, 5, 0)

    Menu:addSubMenu("["..myHero.charName.." - Harass]", "NamiHarass")
    Menu.NamiHarass:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
    Menu.NamiHarass:addParam("AutoHarass", "Auto Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("A"))
    Menu.NamiHarass:addParam("QHarass", "Harass using Q", SCRIPT_PARAM_ONOFF, true)
    Menu.NamiHarass:addParam("WHarass", "Harass using W", SCRIPT_PARAM_ONOFF, true)

    Menu:addSubMenu("["..myHero.charName.." - Additionals]", "Ads")
    Menu.Ads:addParam("AutoLevelspells", "Auto-Level Spells", SCRIPT_PARAM_ONOFF, false)
    Menu.Ads:addSubMenu("Auto Heal Settings", "AutoHeal")
    Menu.Ads.AutoHeal:addParam("HealNami", "Auto Heal Yourself", SCRIPT_PARAM_ONOFF, true)
    Menu.Ads.AutoHeal:addParam("NamiPercent", "What % to heal yourself", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
    Menu.Ads.AutoHeal:addParam("HealAllies", "Auto Heal Allies", SCRIPT_PARAM_ONOFF, false)
    Menu.Ads.AutoHeal:addParam("AllyPercent", "What % to heal allies", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)

    Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
    Menu.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings:addParam("drawCircleR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)

    PrintChat("<font color = \"#33CCCC\">Nami Tsunami by</font> <font color = \"#fff8e7\">Lillgoalie</font>")
end

function OnTick()
    ts:update()

    if Menu.NamiCombo.combo then
        Combobombo()
    end

    if Menu.NamiHarass.Harass then
        harass()
    end

    if Menu.NamiHarass.AutoHarass then
        autoharass()
    end

    if Menu.Ads.AutoLevelspells then
        AutoLevel()
    end
end

function harass()
    if Menu.NamiHarass.QHarass then
        AddTickCallback(UseQ)
    end

    if Menu.NamiHarass.WHarass then
        AddTickCallback(UseW)
    end
end

function autoharass()
    if Menu.NamiHarass.QHarass then
        AddTickCallback(UseQ)
    end

    if Menu.NamiHarass.WHarass then
        AddTickCallback(UseW)
    end
end

function AutoLevel()
    local qL, wL, eL, rL = player:GetSpellData(_Q).level + qOff, player:GetSpellData(_W).level + wOff, player:GetSpellData(_E).level + eOff, player:GetSpellData(_R).level + rOff
    if qL + wL + eL + rL < player.level then
        local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
        local level = { 0, 0, 0, 0 }
        for i = 1, player.level, 1 do
            level[abilitySequence[i]] = level[abilitySequence[i]] + 1
        end
        for i, v in ipairs({ qL, wL, eL, rL }) do
        if v < level[i] then LevelSpell(spellSlot[i]) end
        end
    end
end

function Combobombo()
    AddTickCallback(UseR)
    AddTickCallback(UseQ)
    AddTickCallback(UseE)
    AddTickCallback(UseW)
end

function UseR()
    if ValidTarget(ts.target, Menu.NamiCombo.Rset.RuseRange) and myHero:CanUseSpell(_R) == READY and Menu.NamiCombo.Rset.comboR then
        for i, target in pairs(GetEnemyHeroes()) do
            local AOECastPosition, MainTargetHitChance, nTargets = VPrediction:GetLineAOECastPosition(ts.target, RDelay, RRadius, Menu.NamiCombo.Rset.RuseRange, RSpeed, myHero)
            if MainTargetHitChance >= 2 and GetDistance(AOECastPosition) < Menu.NamiCombo.Rset.RuseRange and nTargets >= Menu.NamiCombo.Rset.MinimumR then
                CastSpell(_R, AOECastPosition.x, AOECastPosition.z)
            end
        end
    end
end

function UseQ()
    if ValidTarget(ts.target, QRange) and myHero:CanUseSpell(_Q) == READY and Menu.NamiCombo.comboQ then
        for i, target in pairs(GetEnemyHeroes()) do
            local AOECastPosition, MainTargetHitChance, nTargets = VPrediction:GetLineAOECastPosition(ts.target, QDelay, QRadius, Q, QSpeed)
            if MainTargetHitChance >= 2 and GetDistance(AOECastPosition) < QRange then
                CastSpell(_Q, AOECastPosition.x, AOECastPosition.z)
            end
        end
    end
end

function UseW()
    if ValidTarget(ts.target, WRange) and myHero:CanUseSpell(_W) == READY then
        CastSpell(_W, ts.target)

    elseif ValidTarget(ts.target, ERange) and myHero:CanUseSpell(_W) == READY then
        for i = 1, heroManager.iCount do
            local hero = heroManager:GetHero(i)
            if hero.team ~= myHero.team then
                if GetDistance(hero, ts.target) < 400 then
                    CastSpell(_W, hero)
                end
            end
        end
    end
end

function UseE()
    if ValidTarget(ts.target, ERange) then
        for i = 1, heroManager.iCount do
        local hero = heroManager:GetHero(i)
            if hero.team == myHero.team and myHero:CanUseSpell(_E) == READY and Menu.NamiCombo.comboE then
                CastSpell(_E, hero)
            end
        end
    end
end

function OnDraw()
    if Menu.drawings.drawCircleR then
        DrawCircle(myHero.x, myHero.y, myHero.z, Menu.NamiCombo.Rset.RuseRange, 0x111111)
    end     
    
    if Menu.drawings.drawCircleQ then
        DrawCircle(myHero.x, myHero.y, myHero.z, QRange, 0x111111)
    end
    
    if Menu.drawings.drawCircleAA then
        DrawCircle(myHero.x, myHero.y, myHero.z, 550, ARGB(255, 0, 255, 0))
    end
end