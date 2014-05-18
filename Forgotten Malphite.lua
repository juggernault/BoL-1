if myHero.charName ~= "Malphite" then return end

require 'VPrediction'

local ts
local VP = nil

QRange, WRange, ERange, RRange = 625, 125, 390, 1000

function OnLoad()
	VP = VPrediction()
	-- Target Selector
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY,1000)
		
	Config = scriptConfig("Forgotten Malphite by Lillgoalie", "Malphite")
	
	Config:addTS(ts)
	
	Config:addSubMenu("["..myHero.charName.." - Combo]", "Combo")
	Config.Combo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config.Combo:addParam("comboR", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
	
	Config:addSubMenu("["..myHero.charName.." - Harass]", "Harass")
	Config.Harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
	
	Config:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
	Config.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	Config.drawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	Config.drawings:addParam("drawCircleR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	
	PrintChat("Loaded Forgotten Malphite by Lillgoalie")
end

function OnTick()
	-- Check for enemies repeatly
	ts:update()

	if Config.Combo.combo then
		Combo()
	end
	
	if Config.Harass.harass then
		Harass()
	end
end

function Combo()
	if ValidTarget(ts.target, RRange) and myHero:CanUseSpell(_R) == READY and Config.Combo.comboR then
			for i, target in pairs(GetEnemyHeroes()) do
				local CastPosition,  HitChance,  Position = VP:GetCircularAOECastPosition(ts.target, 0, 270, 1000, 700, myHero)
					if HitChance >= 2 and GetDistance(CastPosition) < 1000 then
						CastSpell(_R, CastPosition.x, CastPosition.z)
			end
		end
	end
			
	if ValidTarget(ts.target, ERange) and myHero:CanUseSpell(_E) == READY then
		CastSpell(_E)
	end
	
	if ValidTarget(ts.target, QRange) and myHero:CanUseSpell(_Q) == READY then
		CastSpell(_Q, ts.target)
	end
	
	if ValidTarget(ts.target, WRange) and myHero:CanUseSpell(_W) == READY then
		CastSpell(_W)
	end
end

function Harass()
	if ValidTarget(ts.target, ERange) and myHero:CanUseSpell(_E) == READY then
		CastSpell(_E)
	end
	
	if ValidTarget(ts.target, QRange) and myHero:CanUseSpell(_Q) == READY then
		CastSpell(_Q, ts.target)
	end
end

function OnDraw()
	if Config.drawings.drawCircleR then
		DrawCircle(myHero.x, myHero.y, myHero.z, RRange, 0x111111)
	end		
	
	if Config.drawings.drawCircleQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, QRange, 0x111111)
	end
	
	if Config.drawings.drawCircleAA then
		DrawCircle(myHero.x, myHero.y, myHero.z, 125, ARGB(255, 0, 255, 0))
	end
end