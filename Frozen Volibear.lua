--[[
 
        Frozen Volibear by Lillgoalie (+Ikita's W KS script)
        Version: 1.0
       
        Features:
			Combo Mode
			KS with W
       
        Instructions on saving the file:
        - Save the file in scripts folder
       
--]]

if myHero.charName ~= "Volibear" then return end

local ts

QRange, ERange, WRange, RRange = 600, 405, 400, 125
player = GetMyHero()

function OnLoad()
	-- Target Selector
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY,700)

	-- Create the menu
	Config = scriptConfig("Frozen Volibear by Lillgoalie", "FrozenVolibear")
	
	Config:addTS(ts)
	
	Config:addSubMenu("["..myHero.charName.." - Combo]", "Combo")
	Config.Combo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config.Combo:addParam("comboQ", "Use Q in Combo", SCRIPT_PARAM_ONOFF, true)
	Config.Combo:addParam("comboW", "Use W in Combo", SCRIPT_PARAM_ONOFF, true)
	Config.Combo:addParam("comboE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
	Config.Combo:addParam("comboR", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("["..myHero.charName.." - KS]", "KS")
	Config.KS:addParam("ks", "Enable Killsteal", SCRIPT_PARAM_ONOFF, true)

	Config:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
	Config.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	Config.drawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	Config.drawings:addParam("drawCircleW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	Config.drawings:addParam("drawCircleE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	
	-- Message
	PrintChat("Loaded Frozen Volibear By Lillgoalie")
end

function OnTick()
	if myHero.dead then return end
	-- Check for enemies repeatly
	ts:update()
	
	-- KS script from Ikita
	if player:GetSpellData(_W).level > 0 and Config.KS.ks and player:CanUseSpell(_W) == READY then

		for i=1, heroManager.iCount do
			local target = heroManager:GetHero(i)
			local baseHP = (472 + 92*player.level) * 1.03
			local biteDamage = player:CalcDamage(target, math.floor( (((player:GetSpellData(_W).level-1)*45) + 80 + (player.maxHealth - baseHP)*0.15) * (1 + (target.maxHealth - target.health)/(target.maxHealth))))

			if target ~= nil and target.visible == true and target.team ~= player.team and target.dead == false and player:GetDistance(target) < 400 and player:CanUseSpell(_W) == READY then
				if target.health < biteDamage then
					CastSpell(_W, target)
				end
			end
		end
	end
	
	-- Combo key pressed?
	if (Config.Combo.combo) then
		-- Activate function Combo
		Combo()
	end
end
			
function Combo()
	-- Can use spell, E in range and enabled?
	if ValidTarget(ts.target, ERange) and myHero:CanUseSpell(_E) == READY and Config.Combo.comboE then
		-- Cast E
		CastSpell(_E)
	end
	
	-- Can use spell and range and enabled?
	if ValidTarget(ts.target, QRange) and myHero:CanUseSpell(_Q) == READY and Config.Combo.comboQ then
		-- Cast Q
		CastSpell(_Q)
	end
	-- Can use spell and range and enabled?
	if ValidTarget(ts.target, RRange) and myHero:CanUseSpell(_R) == READY and Config.Combo.comboR then
		-- Cast R
		CastSpell(_R)
	end
	-- Can use spell and range and enabled?
	if ValidTarget(ts.target, WRange) and myHero:CanUseSpell(_W) == READY and Config.Combo.comboW then
		-- Cast W
		CastSpell(_W, ts.target)
	end
end

function OnDraw()
	if Config.drawings.drawCircleAA then
		DrawCircle(myHero.x, myHero.y, myHero.z, RRange, ARGB(255, 0, 255, 0))
	end
	
	if Config.drawings.drawCircleQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, QRange, 0x111111)
	end
			
	if Config.drawings.drawCircleW then
		DrawCircle(myHero.x, myHero.y, myHero.z, WRange, 0x111111)
	end		

	if Config.drawings.drawCircleE then
		DrawCircle(myHero.x, myHero.y, myHero.z, ERange, 0x111111)
	end		
end