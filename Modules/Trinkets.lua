local GetTime = GetTime

-- tabla compartida
sArenaSharedTrinketRacial = sArenaSharedTrinketRacial or {
    trinketEnd = 0,
    racialEnd  = 0,
}

local trinketSpells = {
    ["PvP Trinket"] = 120,
}

local sharedSpells = {
    ["Will of the Forsaken"] = 45
}

local trinketData = {
    ["Alliance"] = { texture = "Interface\\Icons\\Inv_jewelry_necklace_37"},
    ["Horde"]    = { texture = "Interface\\Icons\\Inv_jewelry_necklace_38"},
    ["Human"]    = { texture = "Interface\\Icons\\Spell_shadow_charm"},
}

local spellStartTimes = {}

local function GetRemainingCD(spellName)
    local currTime = GetTime()
    local duration = trinketSpells[spellName]
    if not duration then return 0 end
    local startTime = spellStartTimes[spellName] or 0
    return math.max(0, (startTime + duration) - currTime)
end

function sArenaFrameMixin:FindTrinket(event, spellParam, duration)
    if event ~= "SPELL_CAST_SUCCESS" then return end

    local spellName = spellParam
    if type(spellParam) == "number" then
        spellName = GetSpellInfo(spellParam)
    end
    if not spellName then return end

    -- NO procesar la racial aquí (la pinta el otro archivo)
    if spellName == "Every Man for Himself" then
        return
    end

    local now = GetTime()

    -- PvP Trinket
    if spellName == "PvP Trinket" then
        -- registrar en este
        spellStartTimes[spellName] = now

        -- actualizar compartida
        sArenaSharedTrinketRacial.trinketEnd = now + 120
        -- si la racial estaba libre, la dejamos a 45 y la pintamos
        if sArenaSharedTrinketRacial.racialEnd <= now then
            sArenaSharedTrinketRacial.racialEnd = now + 45

            -- pintar racial si existe el frame
            if self.Racial and self.Racial.Texture:GetTexture() then
                self.Racial.Cooldown:SetCooldown(now, 45)
            end
        end

        -- pintar trinket
        self.Trinket.spellName = spellName
        self.Trinket.Cooldown:SetCooldown(now, 120)
        return
    end

    -- resto de spells
    local currentCD = GetRemainingCD(spellName)
    if sharedSpells[spellName] and currentCD < sharedSpells[spellName] then
        duration = sharedSpells[spellName]
    end

    duration = duration or trinketSpells[spellName]

    if duration then
        local currTime = GetTime()
        spellStartTimes[spellName] = currTime
        self.Trinket.spellName = spellName
        self.Trinket.Cooldown:SetCooldown(currTime, duration)
    end
end

function sArenaFrameMixin:UpdateTrinket()
    local _, _, raceId = UnitRace(self.unit)
    local faction = UnitFactionGroup(self.unit)
    if raceId == 1 then  -- Humano
        self.Trinket.Texture:SetTexture(trinketData["Human"].texture)
    else 
        if faction then
            self.Trinket.Texture:SetTexture(trinketData[faction].texture)
        end
    end
end

function sArenaFrameMixin:ResetTrinket()
    self.Trinket.spellName = nil
    self.Trinket.Texture:SetTexture(nil)
    self.Trinket.Cooldown:Clear()
    self:UpdateTrinket()
end
