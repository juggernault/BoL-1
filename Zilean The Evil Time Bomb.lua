--[[

	Zilean The Evil Time Bomb by Lillgoalie [REWORKED]
	Version: 1.3
	
	Features:
	
		- Combo Mode:
			- Uses Q, W, Q , E (if E enabled in menu)
			- Checks if Q is not available before using W
		- Harass Mode:
			- Uses QWQ combo if harass key pressed or autoharass is toggled.

	
	Instructions on saving the file:
	- Save the file in scripts folder
	
--]]
if myHero.charName ~= "Zilean" then return end

local ts

function OnLoad()
	-- Create the menu
	Config = scriptConfig("Zilean by Lillgoalie", "ZileanBL")
	
	Config:addSubMenu("["..myHero.charName.." - Combo]", "Combo")
	Config.Combo:addParam("comboE", "Use E in combo", SCRIPT_PARAM_ONOFF, true)
	Config.Combo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	
	Config:addSubMenu("["..myHero.charName.." - Harass]", "Harass")
	Config.Harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
	Config.Harass:addParam("autoharass", "Auto Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("A"))
	
	Config:addSubMenu("["..myHero.charName.." - Additionals]", "Ads")
	Config.Ads:addParam("FarmR", "Farm R with W", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("U"))
	Config.Ads:addParam("TravelMode", "Travel Mode", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"))

	Config:addSubMenu("["..myHero.charName.." - Drawings]", "drawings")
	Config.drawings:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	Config.drawings:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	Config.drawings:addParam("drawCircleR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	
	-- Target Selector
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY,700)
	
	-- Message
	PrintChat("Loaded Zilean By Lillgoalie")
end

function OnTick()
	-- Check for enemies repeatly
	ts:update()
	
	-- Enemy in range?
	if (ts.target ~= nil) then
		-- Combo key pressed?
		if (Config.Combo.combo) then
			-- Able to cast Q?
			if (myHero:CanUseSpell(_Q) == READY) then
				-- Cast spell on target
				CastSpell(_Q, ts.target)
			end
				-- Able to cast W?
			if (myHero:CanUseSpell(_W) == READY) then
				-- Not able to cast Q?
				if (myHero:CanUseSpell(_Q) ~= READY) then
					-- Cast spell on enemy
					CastSpell(_W)
				end
			end
			
			-- E in combo enabled?
			if (Config.Combo.comboE) then
				-- Able to cast E?
				if (myHero:CanUseSpell(_E) == READY) then
					-- Cast spell on target
					CastSpell(_E, ts.target)
				end
			end
		end
	end
	
	if (ts.target ~= nil) then
		if (Config.Combo.combo == false) then
			if (Config.Harass.harass) then
				if (myHero:CanUseSpell(_Q) == READY) then
					CastSpell(_Q, ts.target)
					else
					
					if (myHero:CanUseSpell(_W) == READY) then
						CastSpell(_W)
					end
				end
			end
		end
	end
	
	if (ts.target ~= nil) then
		if (Config.Combo.combo == false) then
			if (Config.Harass.autoharass) then
				if (myHero:CanUseSpell(_Q) == READY) then
					CastSpell(_Q, ts.target)
					if (myHero:CanUseSpell(_Q) ~= READY) then
						CastSpell(_W)
					end
				end
			end
		end
	end
		
	-- Combo key not pressed?
	if (Config.Combo.combo == false) then
		-- Travel mode enabled in menu?
		if (Config.Ads.TravelMode) then
			-- E Ready?
			if (myHero:CanUseSpell(_E) == READY) then
				CastSpell(_E, myHero)
			else
			
			if (myHero:CanUseSpell(_W) == READY) then
				CastSpell(_W)
			end
			end
		end
	end
	
	-- Is farming R enabled in menu?
	if (Config.Ads.FarmR) then
		-- Is champion higher than level 6?
		if (myHero.level >= 6) then
			-- Can't use R?
			if (myHero:CanUseSpell(_R) ~= READY) then
				-- Can we use W?
				if (myHero:CanUseSpell(_W) == READY) then
					-- Cast W
					CastSpell(_W)
				end
			end
		end
	end
			
end

function OnDraw()
	--Draw Range if activated in menu
		if (Config.drawings.drawCircleAA) then
			DrawCircle(myHero.x, myHero.y, myHero.z, 600, ARGB(255, 0, 255, 0))
		end
		if (Config.drawings.drawCircleQ) then
			DrawCircle(myHero.x, myHero.y, myHero.z, 700, 0x111111)
		end
		if (Config.drawings.drawCircleR) then
			DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0x111111)
		end
end