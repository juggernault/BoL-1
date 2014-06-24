--[[

	[Master Yi] Stannis Baratheon by Lillgoalie
       
    Instructions on saving the file:
    - Save the file in scripts folder

]]

if myHero.charName ~= "MasterYi" then return end

require 'VPrediction'
require 'SOW'

local ts
local VP = nil
local qOff, wOff, eOff, rOff = 0,0,0,0
local abilitySequence = {1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2}

function OnLoad()
	VP = VPrediction()
    ts = TargetSelector(TARGET_LESS_CAST, 600)

    Menu = scriptConfig("[Master Yi] Stannis Baratheon by Lillgoalie", "MasterYiBL")
    Orbwalker = SOW(VP)
           
    Menu:addSubMenu("["..myHero.charName.." - Orbwalker]", "SOWorb")
    Orbwalker:LoadToMenu(Menu.SOWorb)
     
    Menu:addSubMenu("["..myHero.charName.." - Combo]", "YiCombo")
    Menu.YiCombo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
    Menu.YiCombo:addParam("comboQ", "Use Q in combo", SCRIPT_PARAM_ONOFF, true)
    Menu.YiCombo:addParam("comboW", "Use W as AA reset", SCRIPT_PARAM_ONOFF, true)
    Menu.YiCombo:addParam("comboE", "Use E in combo", SCRIPT_PARAM_ONOFF, true)
    Menu.YiCombo:addParam("comboR", "Use R in combo", SCRIPT_PARAM_ONOFF, false)
           
    Menu:addSubMenu("["..myHero.charName.." - Harass]", "Harass")
    Menu.Harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
    Menu.Harass:addParam("autominionharass", "Auto Minion-Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("A"))
    Menu.Harass:addParam("autoharassMana", "Use Auto Minion-Harass if Mana %", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)

    Menu:addSubMenu("["..myHero.charName.." - Laneclear]", "Laneclear")
    Menu.Laneclear:addParam("lclr", "Laneclear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
    Menu.Laneclear:addParam("UseQclear", "Use Q in Jungleclear", SCRIPT_PARAM_ONOFF, true)
    Menu.Laneclear:addParam("lclrMana", "Use Spells if mana is over %", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)

    Menu:addSubMenu("["..myHero.charName.." - Jungleclear]", "Jungleclear")
    Menu.Jungleclear:addParam("jclr", "Jungleclear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
    Menu.Jungleclear:addParam("UseQclear", "Use Q in Jungleclear", SCRIPT_PARAM_ONOFF, true)
    Menu.Jungleclear:addParam("UseEclear", "Use E in Jungleclear", SCRIPT_PARAM_ONOFF, true)
     
    Menu:addSubMenu("["..myHero.charName.." - Additionals]", "Ads")
    Menu.Ads:addParam("ksQ", "Killsteal with Q", SCRIPT_PARAM_ONOFF, true)
    Menu.Ads:addParam("autoLevel", "Auto-Level Spells", SCRIPT_PARAM_ONOFF, false)

    Menu:addSubMenu("["..myHero.charName.." - Target Selector]", "targetSelector")
    Menu.targetSelector:addTS(ts)
    ts.name = "Focus"
           
    Menu:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
    Menu.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
    Menu.drawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)

    Menu.YiCombo:permaShow("combo")
    Menu.Harass:permaShow("harass")
    Menu.Harass:permaShow("autominionharass")

    enemyMinions = minionManager(MINION_ENEMY, 600, myHero, MINION_SORT_MAXHEALTH_DEC)
    jungleMinions = minionManager(MINION_JUNGLE, 600, myHero, MINION_SORT_MAXHEALTH_DEC)
           
	PrintChat("<font color = \"#33CCCC\">Stannis Baratheon by</font> <font color = \"#fff8e7\">Lillgoalie</font>")
end

function OnTick()
	if myHero.dead then return end
	ts:update()
	jungleMinions:update()
	enemyMinions:update()

	if Menu.YiCombo.combo then
		ComboMode()
	end

	if Menu.Harass.harass then
		Harass()
	end

	if Menu.Harass.autominionharass then
		MinionHarass()
	end

	if Menu.Laneclear.lclr then
		LaneClear()
	end

	if Menu.Jungleclear.jclr then
		JungleClear()
	end

	if Menu.Ads.ksQ then
		qKS()
	end

	if Menu.Ads.autoLevel then
		AutoLevel()
	end
end

function ComboMode()
	if ts.target ~= nil and ValidTarget(ts.target, 600) then
		if Menu.YiCombo.comboQ then
			Qcast()
		end

		if Menu.YiCombo.comboE then
			Ecast()
		end

		if Menu.YiCombo.comboR then
			Rcast()
		end
	end
end

function Qcast()
	if myHero:CanUseSpell(_Q) == READY then
		CastSpell(_Q, ts.target)
	end
end

function Ecast()
	if myHero:CanUseSpell(_E) == READY and ValidTarget(ts.target, 250) then
		CastSpell(_E)
	end
end

function Rcast()
	if myHero:CanUseSpell(_R) == READY and ValidTarget(ts.target, 250) then
		CastSpell(_R)
	end
end

function Harass()
	if ts.target ~= nil and ValidTarget(ts.target, 600) and myHero:CanUseSpell(_Q) == READY then
		CastSpell(_Q, ts.target)
	end
end

function MinionHarass()
	local spellRange = 400	 
	local MinionCount = 0
    local Minions = {}
    local NearestMinion
	
	for i, minion in pairs(enemyMinions.objects) do
        if ValidTarget(minion, 600) then
            for _, enemy in pairs(GetEnemyHeroes()) do
                if GetDistance(minion, enemy) <= spellRange then
                    table.insert(Minions, minion)
                    MinionCount = MinionCount + 1
                end
            end
        end
    end
 
    if MinionCount == 0 then return end
    for _, jumpTarget in pairs(Minions) do
        if NearestMinion and NearestMinion.valid and jumpTarget and jumpTarget.valid then
            if GetDistance(jumpTarget) < GetDistance(NearestMinion) then
                NearestMinion = jumpTarget
            end
        end
    end
 
    if ValidTarget(NearestMinion) and MinionCount <= 3 and myHero:CanUseSpell(_Q) == READY and ManaCheck(myHero, Menu.Harass.autoharassMana) then
    	CastSpell(_Q, NearestMinion) 
		MinionCount = 0
	end
end

function LaneClear()
	for i, minion in pairs(enemyMinions.objects) do
		if minion ~= nil and ValidTarget(minion, 600) and myHero:CanUseSpell(_Q) == READY and ManaCheck(myHero, Menu.Laneclear.lclrMana) then
			CastSpell(_Q, minion)
		end
	end
end

function JungleClear()
	local jMinions = jungleMinions.objects[1]
	if jMinions ~= nil and ValidTarget(jMinions, 600) then
		if myHero:CanUseSpell(_Q) == READY and Menu.Jungleclear.UseQclear then
			CastSpell(_Q, jMinions)
		end
		if myHero:CanUseSpell(_E) == READY and Menu.Jungleclear.UseEclear then			
			CastSpell(_E)
		end
	end
end

function qKS()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		qDmg = getDmg("Q", enemy, myHero)
				
		if enemy ~= nil and ValidTarget(enemy, 600) and enemy.health < qDmg then
			CastSpell(_Q, enemy)
		end
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

function OnProcessSpell(unit, spell)
	if unit.isMe and spell.name:lower():find("attack") and Menu.YiCombo.combo and Menu.YiCombo.comboW then
        SpellTarget = spell.target
        if SpellTarget.type == myHero.type then
            DelayAction(function() CastSpell(_W) end, spell.windUpTime - GetLatency() / 2000)
        end
    end
end

function ManaCheck(unit, ManaValue)
	if unit.mana < (unit.maxMana * (ManaValue/100))
		then return true
	else
		return false
	end
end

function OnDraw()
	if Menu.drawings.drawCircleAA then
		DrawCircle(myHero.x, myHero.y, myHero.z, 250, ARGB(255, 0, 255, 0))
	end

	if Menu.drawings.drawCircleQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, 600, 0x111111)
	end
end