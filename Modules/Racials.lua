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

-- tabla compartida
sArenaSharedTrinketRacial = sArenaSharedTrinketRacial or {
    trinketEnd = 0,
    racialEnd  = 0,
}

local racialSpells = {
    ["War Stomp"] = 120,
    ["Will of the Forsaken"] = 120,
    ["Blood Fury"] = 120,
    ["Shadowmeld"] = 10,
    ["Escape Artist"] = 105,
    ["Stoneform"] = 180,
    ["Every Man for Himself"] = 120,
    ["Berserking"] = 180,
    ["Gift of the Naaru"] = 180,
    ["Arcane Torrent"] = 120,
}

local racialData = {
    ["Human"]    = { spellName = "Every Man for Himself" },
    ["Scourge"]  = { spellName = "Will of the Forsaken" },
    ["Gnome"]    = { spellName = "Escape Artist" },
    ["Dwarf"]    = { spellName = "Stoneform" },
    ["Orc"]      = { spellName = "Blood Fury" },
    ["Tauren"]   = { spellName = "War Stomp" },
    ["BloodElf"] = { spellName = "Arcane Torrent" },
    ["Troll"]    = { spellName = "Berserking" },
    ["Draenei"]  = { spellName = "Gift of the Naaru" },
    ["NightElf"] = { spellName = "Shadowmeld" },
}

local spellStartTimes = {}

local function GetRemainingCD(spellName)
    local currTime = GetTime()
    local duration = racialSpells[spellName]
    if not duration then return 0 end
    local startTime = spellStartTimes[spellName] or 0
    return math.max(0, (startTime + duration) - currTime)
end

function sArenaFrameMixin:FindRacial(event, spellParam, duration)
    if event ~= "SPELL_CAST_SUCCESS" then return end

    local spellName = spellParam
    if type(spellParam) == "number" then
        spellName = GetSpellInfo(spellParam)
    end
    if not spellName then return end

    local now = GetTime()

    -- humana
    if spellName == "Every Man for Himself" then
        -- racial a 120
        spellStartTimes[spellName] = now
        sArenaSharedTrinketRacial.racialEnd = now + 120

        -- si el trinket estaba libre, lo ponemos a 45 SOLO en la compartida (no lo pintamos)
        if sArenaSharedTrinketRacial.trinketEnd <= now then
            sArenaSharedTrinketRacial.trinketEnd = now + 45
        end

        if self.Racial.Texture:GetTexture() then
            self.Racial.Cooldown:SetCooldown(now, 120)
        end

        return
    end

    -- resto de raciales como tenías
    local _, race = UnitRace(self.unit)
    local currentCD = GetRemainingCD(spellName)

    duration = duration or racialSpells[spellName]

    if duration then
        spellStartTimes[spellName] = now
        if self.Racial.Texture:GetTexture() then
            self.Racial.Cooldown:SetCooldown(now, duration)
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
