if GetObjectName(GetMyHero()) ~= "Katarina" then return end

require("DamageLib")

local mainMenu = Menu("Katarina [Jace]", "Katarina [Jace]")

mainMenu:SubMenu('CK', 'Combo [Katarina]')
mainMenu.CK:Boolean('CQ', 'Use [Q]', true)
mainMenu.CK:Boolean('CW', 'Use [W]', true)
mainMenu.CK:Boolean('CE', 'Use [E]', true)
mainMenu.CK:Boolean('CR', 'Use [R]', true)
mainMenu.CK:Boolean('CRC', 'Cancel [R]', true)
mainMenu.CK:Boolean('CanItems', 'Use [Gun]', true)
if Ignite ~= nil then mainMenu.CK:Boolean("AutoIgnite", "Auto Ignite", true) end
mainMenu.CK:Slider("CountR","Count Enemies", 2, 1, 5, 1)

mainMenu:SubMenu('Keys', 'Keys [Katarina]')
mainMenu.Keys:Key("ComboKat", "Combo [Key]", string.byte(" "))
mainMenu.Keys:Key("ManualR", "R [Manual] [Key]", string.byte("R"))
mainMenu.Keys:Key("LaneClear", "Lane [Key]", string.byte("V"))

mainMenu:SubMenu('AL', 'Auto level')
mainMenu.AL:Boolean('ALV', 'Auto level spells', true)
mainMenu.AL:Boolean('EQE', 'Q->E->W Order', true)

mainMenu:SubMenu('DR', 'Drawnings')
mainMenu.DR:Boolean("Q", "Draw Q range", true)
mainMenu.DR:Boolean("W", "Draw W range", true)
mainMenu.DR:Boolean("E", "Draw E range", true)
mainMenu.DR:Boolean("R", "Draw R range", true)
mainMenu.DR:Boolean("Dagas", "Draw Circle Dagger", true)


local DaggerPos = {}
local DaggerIsCast = {}
local kataCounter = 0
local kataR = false

PrintChat("<font color=\"#adff2f\">[Katarina Jace]:</font> <font color=\"#00FFFF\">Katarina</font> <font color=\"#adff2f\">Injected successfully!</font>")
PrintChat("font color=\"#00FFFF\">Update: 0.1</font> ")

OnProcessSpell(function(unit,spell)
	if unit == myHero and spell.name == "KatarinaR" then
		kataR = true
	end
end)

OnUpdateBuff(function(unit,buff)
	if unit == myHero and buff.Name == "katarinarsound" then
		kataR = true
	end
end)

OnRemoveBuff(function(unit,buff)
	if unit == myHero and buff.Name == "katarinarsound" then
		kataR = false
	end
end)

OnIssueOrder(function(orderProc)
	if (orderProc.flag == 2 or orderProc.flag == 3) and kataR == true and ValidTarget(GetCurrentTarget(),550) and mainMenu.Keys.ComboKat:Value() then
		BlockOrder()
	end
end)

OnSpellCast(function(castProc)
	if kataR == true and castProc.spellID == 1 then
		BlockCast()
	end
end)

OnCreateObj(function(Obj)
	if GetDistance(Obj) < 2500 then
		if Obj.name == "Katarina_Base_W_Indicator_Ally" then
			table.insert(DaggerPos, Obj)
			local delay = 0.2
			if GetDistance(Obj) < 50 then
				delay = 0
			end
			DelayAction(function() table.insert(DaggerIsCast, Obj) end, 1.0 - delay)
		end
	end
end)

OnDeleteObj(function(Obj)
	if Obj.name == "Katarina_Base_W_Indicator_Ally" then
		for i,v in pairs(DaggerIsCast) do
			if GetNetworkID(v) == GetNetworkID(Obj) then
				table.remove(DaggerIsCast, i)
			end
		end
		for i,v in pairs(DaggerPos) do
			if GetNetworkID(v) == GetNetworkID(Obj) then
				table.remove(DaggerPos,i)
			end
		end
	end
end)

OnDraw(function()
	local posMy = GetOrigin(myHero)
	if mainMenu.DR.Q:Value() and IsReady(_Q) then 
		DrawCircle(posMy,725,1,25,GoS.Pink) 
	end
	if mainMenu.DR.W:Value() and IsReady(_W) then 
		DrawCircle(posMy,350,1,25,GoS.Yellow) 
	end
	if mainMenu.DR.E:Value() and IsReady(_E) then 
		DrawCircle(posMy,800,1,25,GoS.Blue) 
	end
	if mainMenu.DR.R:Value() and IsReady(_R) then 
		DrawCircle(posMy,600,1,25,GoS.Green) 
	end
	for i,v in pairs(DaggerIsCast) do
		DrawCircle(v.x, v.y, v.z, 350,1,25,GoS.Pink)
	end
end)

function ComboKat()
	if mainMenu.Keys.ComboKat:Value() and not kataR == true then
		local target = GetCurrentTarget()
		if ValidTarget(target, 1500) then
			if GetDistance(target) < 650 and IsReady(_Q) then
				CastTargetSpell(target, _Q)
			end
			if GetDistance(target) < 200 and IsReady(_W) then
				CastSpell(_W)
			end
			if IsReady(_E) then
				for i,v in pairs(DaggerIsCast) do
					local posDaga = Vector(v) + (Vector(target) - Vector(v)):normalized()* 50
					if GetDistance(target, posDaga) < 350 and GetDistance(v) < 1200 then
						CastSkillShot(2, posDaga.x, posDaga.y, posDaga.z)
					elseif GetDistance(target, posDaga) < 350 and GetDistance(target) < 800 then
						CastSkillShot(2, posDaga.x, posDaga.y, posDaga.z)
					end
				end
			end 
		end 
	end			
end

function AutoLevel()

	QEWt = {_Q,_E,_W,_Q,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W}

	if mainMenu.AL.EQE:Value() then
		mainMenu.AL.EQE:Value(true)
	end

	if mainMenu.AL.ALV:Value() and GetLevelPoints(myHero) > 0 then

		if mainMenu.AL.EQE:Value() then
			LevelSpell(QEWt[GetLevel(myHero)-GetLevelPoints(myHero)+1])
		end
	end
end

function Lane()
	if mainMenu.Keys.LaneClear:Value() then
		for _, minion in pairs(minionManager.objects) do
			if GetTeam(minion) ~= MINION_ALLY then
				if IsReady(_Q) and ValidTarget(minion, 715) then
					CastTargetSpell(minion, _Q)
				end 
				for i,v in pairs(DaggerIsCast) do
				    if IsReady(_E) and ValidTarget(minion, 800) then
					local posDaga = Vector(v) + (Vector(minion) - Vector(v)):normalized()* 50
					    if GetDistance(minion, posDaga) < 350 and GetDistance(v) < 1200 then
						CastSkillShot(_E, posDaga.x, posDaga.y, posDaga.z)
						end 
					end 
				end
			end 
		end 
	end 
end 

function CastGun()
	if mainMenu.Keys.ComboKat:Value() then
		local target = GetCurrentTarget()
		if ValidTarget(target,1500) and not kataR == true then
			local tiro = GetItemSlot(myHero, 3146)
			if tiro >= 1 and ValidTarget(target, 550) then
				if CanUseSpell(myHero, tiro) == READY then
					CastTargetSpell(target, tiro)
				end
			end
		end 
	end 
end 

function IgL()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if Ignite and mainMenu.CK.AutoIgnite:Value() then
			if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetHP(enemy)+GetHPRegen(enemy)*3 and ValidTarget(enemy, 600) then
				CastTargetSpell(enemy, Ignite)
			end 
		end 
	end 
end 

function CancelR()
	if GotBuff(myHero, "katarinarsound") == 1 and EnemiesAround(GetOrigin(myHero), 550 + 10) == 0 then
		MoveToXYZ(GetMousePos())
	end 
end 

function DamageRKat(target)
	local target = GetCurrentTarget()
	if target ~= 0 and CastSpell(_R) then
		local Damage = 0
		local DamageAP = {375, 562.5, 750}
		local DamageAD = {1.325302, 1.325302, 1.325302}
		if IsReady(_R) then
			Damage = (0.80 * GetBonusDmg(myHero) + DamageAP[GetCastLevel(myHero, _R)] + 0.2 * GetBonusAP(myHero)) + DamageAD[GetCastLevel(myHero, _R)]
		end
		return myHero.CalcDamage(target.Addr, Damage)
	end
	return 0
end 

function selfcAR()
	local rdmg = 0
	local target = GetCurrentTarget()
	if IsReady(_R) then
		rdmg = CalcDamage(187.5*GetCastLevel(myHero,_R)+187.5)+(3.3*GetBonusDmg(myHero))+(2.85*GetBonusAP(myHero))
		if GetCurrentHP(target) < rdmg then
			CastSpell(_R)
		end 
	end
	if IsReady(_R) then
		if EnemiesAround(GetOrigin(myHero),500) >= mainMenu.CK.CountR:Value() then
			CastSpell(_R)
		end 
	end
	if CanUseSpell(myHero,_R) == READY then
		if 100*GetCurrentHP(target)/GetMaxHP(target) < 35 then 
			CastSpell(_R)
		end 
	end 
end 


OnTick(function(myHero)
	--Combo Kat

	ComboKat()
	 
	
	--AutoLevel
	AutoLevel()
	--LaneClear
	Lane()
	--CanR
	CancelR()
	--Ig
	IgL()

	if mainMenu.CK.CanItems:Value() then
		CastGun()
	end 

	for _, enemy in pairs(GetEnemyHeroes()) do
		if IsReady(_Q) and ValidTarget(enemy, 725) and GetCurrentHP(enemy) < getdmg("Q", enemy) then
			CastTargetSpell(enemy, _Q)
		end 
		if IsReady(_R) and ValidTarget(enemy, 500) and EnemiesAround(GetOrigin(myHero), 500) >= mainMenu.CK.CountR:Value() and GetCurrentHP(enemy) < DamageRKat(enemy) then
			CastSpell(_R)
		end 
		if IsReady(_E) and ValidTarget(enemy, 800) and GetCurrentHP(enemy) < getdmg("E", enemy) then
			CastSkillShot(_E, GetOrigin(enemy))
		end 
	end		
end)
