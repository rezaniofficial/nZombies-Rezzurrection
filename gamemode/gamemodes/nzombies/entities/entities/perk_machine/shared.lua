AddCSLuaFile()

ENT.Type			= "anim"

ENT.PrintName		= "perk_machine"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.DynLightColors = {
	["jugg"] = Color(255, 100, 100),
	["speed"] = Color(100, 255, 100),
	["dtap"] = Color(255, 255, 100),
	["revive"] = Color(100, 100, 255),
	["dtap2"] = Color(255, 255, 100),
	["staminup"] = Color(200, 255, 100),
	["phd"] = Color(255, 50, 255),
	["deadshot"] = Color(150, 200, 150),
	["mulekick"] = Color(100, 200, 100),
	["cherry"] = Color(50, 50, 200),
	["tombstone"] = Color(100, 100, 100),
	["whoswho"] = Color(100, 100, 255),
	["vulture"] = Color(255, 100, 100),
	["pap"] = Color(200, 220, 220),
}

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "PerkID")
	self:NetworkVar("Bool", 0, "Active")
	self:NetworkVar("Bool", 1, "BeingUsed")
	self:NetworkVar("Int", 0, "Price")
end

function ENT:Initialize()
	if SERVER then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:DrawShadow( false )
		self:SetUseType( SIMPLE_USE )
		self:SetBeingUsed(false)
		local PerkData = nzPerks:Get(self:GetPerkID())
		if nzPerks:GetMachineType(nzMapping.Settings.perkmachinetype) == "IW" then
						self:SetPrice(PerkData.price_skin)
						else
						self:SetPrice(PerkData.price)
						end
		if offmodel then
		self:SetModel(offmodel)
		end
		if self:GetPerkID() == "gum" then
		self:SetModelScale( self:GetModelScale() * 0.5, 0 )
		end
	end
end

function ENT:TurnOn()
	self:SetActive(true)
	self:Update()
end

function ENT:TurnOff()
	self:SetActive(false)
	self:Update()
end

function ENT:Update()
	local PerkData = nzPerks:Get(self:GetPerkID())
	local skinmodel = PerkData.model
	local iwskin = PerkData.skin
	if nzPerks:GetMachineType(nzMapping.Settings.perkmachinetype) == "IW" then
	
	else
		local offmodel = PerkData.model_off
		end
	if skinmodel then
	if offmodel then
	if self:IsOn() then
			self:SetModel(skinmodel)
		else
			self:SetModel(offmodel)
		end
		else
	if nzPerks:GetMachineType(nzMapping.Settings.perkmachinetype) == "IW" and iwskin then
	self:SetModel(iwskin)
	else
		self:SetModel(skinmodel)
		end
		if self:IsOn() then
			self:SetSkin(PerkData.on_skin or 0)
		else
			self:SetSkin(PerkData.off_skin or 1)
		end
		end
		else
		self:SetModel(PerkData and (self:IsOn() and PerkData.on_model or PerkData.off_model) or "")
	end
	--if self:GetPerkID() == "gum" then
		--self:SetModelScale( self:GetModelScale() * 0.5, 0 )
		--end
end

function ENT:IsOn()
	return self:GetActive()
end

local MachinesNoDrink = {
	["pap"] = true,
}

function ENT:Use(activator, caller)
	local PerkData = nzPerks:Get(self:GetPerkID())
	
	if self:IsOn() then
		local price = self:GetPrice()
		-- As long as they have less than the max perks, unless it's pap
			-- If they have enough money
			print("it isnt pap")
			local func = function()
				local id = self:GetPerkID()
				if !activator:HasPerk(id) then
					local given = true
					
					if PerkData.condition then
						given = PerkData.condition(id, activator, self)
					end
					
					-- Call a hook for it
					local hookblock = hook.Call("OnPlayerBuyPerkMachine", nil, activator, self)
					if hookblock != nil then -- Only if the hook returned true/false
						given = hookblock
					end
					
					if given then
						if !PerkData.specialmachine then
							local wep = activator:Give("nz_perk_bottle")
							if IsValid(wep) then wep:SetPerk(id) end
							timer.Simple(3, function()
								if IsValid(activator) and activator:GetNotDowned() then
									activator:GivePerk(id, self)
								end
							end)
						else
							activator:GivePerk(id, self)
						end
						
						if nzPerks:GetMachineType(nzMapping.Settings.perkmachinetype) == "IW" then
						self:EmitSound("nz/machines/jingle/IW/"..id.."_get.wav", 75)
						else
						self:EmitSound("nz/machines/jingle/"..id.."_get.wav", 75)
						end
						return true
					end
				else
					print("Already have perk")
					return false
				end
			end
			
			local upgradefunc = function()
				local id = self:GetPerkID()
				if not activator:HasUpgrade(id) then
					local given = true
					
					
					-- Call a hook for it
					local hookblock = hook.Call("OnPlayerBuyPerkMachine", nil, activator, self)
					if hookblock != nil then -- Only if the hook returned true/false
						given = hookblock
					end
					
					if given then
						if !PerkData.specialmachine then
							local wep = activator:Give("nz_perk_bottle")
							if IsValid(wep) then wep:SetPerk(id) end
							timer.Simple(3, function()
								if IsValid(activator) and activator:GetNotDowned() then
								print("giving upgrade")
									activator:GiveUpgrade(id, self)
								end
							end)
						else
							activator:GiveUpgrade(id, self)
						end
						
						if nzPerks:GetMachineType(nzMapping.Settings.perkmachinetype) == "IW" then
						self:EmitSound("nz/machines/jingle/IW/"..id.."_get.wav", 75)
						else
						self:EmitSound("nz/machines/jingle/"..id.."_get.wav", 75)
						end
						return true
					end
				else
					print("Already have upgrade")
					return false
				end
			end
			
			-- If a perk has NoBuy true, then it won't run a Buy on it but just run the func directly
			-- (Allows stuff like dynamic pricing and conditional checks, similar to PaP)
			local id = self:GetPerkID()
			if not PerkData.nobuy then
			
			if not activator:HasPerk(id) then
			if #activator:GetPerks() < GetConVar("nz_difficulty_perks_max"):GetInt() or self:GetPerkID() == "pap" then
				activator:Buy(price, self, func)
			else
			print(activator:Nick().." already has max perks")
			end
			else
					if tobool(nzMapping.Settings.perkupgrades) then
				activator:Buy((price*2), self, upgradefunc)
				end
			end
			else
			func()
			end
else
print("that shit off")
end
end


if CLIENT then
	local usedcolor = Color(255,255,255)
	
	function ENT:Draw()
		self:DrawModel()
		if self:GetActive() then
			if !self.NextLight or CurTime() > self.NextLight then
				local dlight = DynamicLight( self:EntIndex() )
				if ( dlight ) then
					local col = nzPerks:Get(self:GetPerkID()).color or usedcolor
					dlight.pos = self:GetPos() + self:OBBCenter()
					dlight.r = col.r
					dlight.g = col.g
					dlight.b = col.b
					dlight.brightness = 2
					dlight.Decay = 1000
					dlight.Size = 256
					dlight.DieTime = CurTime() + 1
				end
				if math.random(300) == 1 then self.NextLight = CurTime() + 0.05 end
			end
		end
	end
end