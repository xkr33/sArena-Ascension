local GetTime = GetTime

sArenaMixin.defaultSettings.profile.racialCategories = {
	["Human"] = true,
	["Scourge"] = true,
	["Gnome"] = true,
	["Dwarf"] = true,
	["Orc"] = true,
	["Tauren"] = true,
	["BloodElf"] = true,
	["Troll"] = true,
	["Draenei"] = false,
	["NightElf"] = false,
}


local racialSpells = {
	["War Stomp"] = 120,
	["Will of the Forsaken"] = 120,
	["Blood Fury"] = 120,
	["Shadowmeld"] = 10,
	["Escape Artist"] = 105,
	["Stoneform"] = 180,
	["Every Man for Himself"] = 120,  -- Will to survive
	["Berserking"] = 180,
	["Gift of the Naaru"] = 180,
	["Arcane Torrent"] = 120,
}


local racialData = {
	["Human"] = { spellName = "Every Man for Himself" },
	["Scourge"] = { spellName = "Will of the Forsaken" },
	["Gnome"] = { spellName = "Escape Artist" },
	["Dwarf"] = { spellName = "Stoneform" },
	["Orc"] = { spellName = "Blood Fury" },
	["Tauren"] = { spellName = "War Stomp" },
	["BloodElf"] = { spellName = "Arcane Torrent" },
	["Troll"] = { spellName = "Berserking" },
	["Draenei"] = { spellName = "Gift of the Naaru" },
	["NightElf"] = { spellName = "Shadowmeld" },
}


local sharedSpells = {
	["PvP Trinket"] = {  
		races = {
			["Scourge"] = 45,  
			["Human"] = 120    
		}
	}
}

local spellStartTimes = {}

local function GetRemainingCD(spellName)
	if not spellStartTimes then
		spellStartTimes = {}
	end

	local currTime = GetTime()
	local duration = racialSpells[spellName]

	if not duration then
		return 0
	end

	local startTime = spellStartTimes[spellName] or 0
	local remainingCD = math.max(0, (startTime + duration) - currTime)

	return remainingCD
end

function sArenaFrameMixin:FindRacial(event, spellParam, duration)
	if event ~= "SPELL_CAST_SUCCESS" then return end

	
	local spellName = spellParam
	if type(spellParam) == "number" then
		spellName = GetSpellInfo(spellParam)
	end

	if not spellName then return end

	local _, race = UnitRace(self.unit)
	local currentCD = GetRemainingCD(spellName)
	
	if sharedSpells[spellName] 
		and sharedSpells[spellName].races[race]
		and currentCD < sharedSpells[spellName].races[race]
	then
		duration = sharedSpells[spellName].races[race]
	end

	duration = duration or racialSpells[spellName]

	if duration then
		local currTime = GetTime()
		spellStartTimes[spellName] = currTime  -- ← FIX: Registrar el tiempo de inicio

		if self.Racial.Texture:GetTexture() then
			self.Racial.Cooldown:SetCooldown(currTime, duration)
		end
	end
end

function sArenaFrameMixin:UpdateRacial()
	if not self.race then
		local _, race = UnitRace(self.unit)
		self.race = race

		if self.parent.db.profile.racialCategories[self.race] and racialData[self.race] then
			local spellName = racialData[self.race].spellName
			local texture = select(3, GetSpellInfo(spellName))
			
			if texture then
				self.Racial.Texture:SetTexture(texture)
			end
		end
	end
end

function sArenaFrameMixin:ResetRacial()
	self.race = nil
	self.Racial.Texture:SetTexture(nil)
	self.Racial.Cooldown:Clear()
	self:UpdateRacial()
	spellStartTimes = {}
end