sArenaMixin = {}
sArenaFrameMixin = {}

sArenaMixin.layouts = {}
sArenaMixin.portraitClassIcon = true;
sArenaMixin.portraitSpecIcon = true;

sArenaMixin.defaultSettings = {
    profile = {
        currentLayout = "BlizzArena",
        classColors = true,
        showNames = true,
        statusText = {
            usePercentage = false,
            alwaysShow = true,
        },
        petScale = {
            posX = 31,
            posY = -24,
            scale = 1
        },
        layoutSettings = {},
        CombatIndicator = {
            posX = 68,
            posY = -5,
            scale = 1.0,
        },
        cbicon = true,
        petFrames = false,
        drText = false,
        arenaNames = true,
    },
}

local iconPath = "Interface\\Addons\\sArena\\Textures\\SQUARE.BLP";

local classIcons = {

    -- UpperLeftx, UpperLefty, LowerLeftx, LowerLefty, UpperRightx, UpperRighty, LowerRightx, LowerRighty

    ["WARRIOR"] = { 0, 0, 0, 0.25, 0.25, 0, 0.25, 0.25 },
    ["ROGUE"] = { 0.5, 0, 0.5, 0.25, 0.75, 0, 0.75, 0.25 },
    ["DRUID"] = { 0.75, 0, 0.75, 0.25, 1, 0, 1, 0.25 },
    ["WARLOCK"] = { 0.75, 0.25, 0.75, 0.5, 1, 0.25, 1, 0.5 },
    ["HUNTER"] = { 0, 0.25, 0, 0.5, 0.25, 0.25, 0.25, 0.5 },
    ["PRIEST"] = { 0.5, 0.25, 0.5, 0.5, 0.75, 0.25, 0.75, 0.5 },
    ["PALADIN"] = { 0, 0.5, 0, 0.75, 0.25, 0.5, 0.25, 0.75 },
    ["SHAMAN"] = { 0.25, 0.25, 0.25, 0.5, 0.5, 0.25, 0.5, 0.5 },
    ["MAGE"] = { 0.25, 0, 0.25, 0.25, 0.5, 0, 0.5, 0.25 },
    ["DEATHKNIGHT"] = { 0.25, 0.5, 0.25, 0.75, 0.5, 0.5, 0.50, 0.75 }

};

local db
local auraList
local interruptList

local emptyLayoutOptionsTable = {
    notice = {
        name = "The selected layout doesn't appear to have any settings.",
        type = "description",
    },
}
local blizzFrame
local FEIGN_DEATH = GetSpellInfo(5384) -- Localized name for Feign Death

-- make local vars of globals that are used with high frequency
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local UnitGUID = UnitGUID
local UnitChannelInfo = UnitChannelInfo
local GetTime = GetTime
local After = C_Timer.After
local UnitAura = UnitAura
local UnitHealthMax = UnitHealthMax
local UnitHealth = UnitHealth
local SetPortraitToTexture = SetPortraitToTexture
local UnitPowerMax = UnitPowerMax
local UnitPower = UnitPower
local UnitPowerType = UnitPowerType
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local FindAuraByName = AuraUtil.FindAuraByName
local ceil = ceil
local EnableAddOn = EnableAddOn or C_AddOns.EnableAddOn
local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded
--local UnitFrameHealPredictionBars_Update = UnitFrameHealPredictionBars_Update

local function UpdateBlizzVisibility(instanceType)
    -- hide blizz arena frames while in arena
    if (InCombatLockdown()) then
        return
    end
    if (not IsAddOnLoaded("Blizzard_ArenaUI")) then
        LoadAddOn("Blizzard_ArenaUI")
        SetCVar("showArenaEnemyFrames", 1)
        return
    end

    if (not blizzFrame) then
        blizzFrame = CreateFrame("Frame", nil, UIParent)
        blizzFrame:SetSize(1, 1)
        blizzFrame:SetPoint("RIGHT", UIParent, "RIGHT", 500, 0)
        blizzFrame:Hide()
    end

    for i = 1, 5 do
        local arenaFrame = _G["ArenaEnemyFrame" .. i]
        local sArenaFrame = _G["sArenaEnemyFrame" .. i]
        local petframe = _G["ArenaEnemyFrame" .. i .. "PetFrame"]

        arenaFrame:ClearAllPoints()

        if (instanceType == "arena") then
            arenaFrame:SetParent(blizzFrame)
            arenaFrame:SetPoint("CENTER", blizzFrame, "CENTER")
            if petframe and db.profile.petFrames then
                petframe:ClearAllPoints()
                petframe:SetParent(sArenaFrame)
                petframe:SetPoint("BOTTOMRIGHT", sArenaFrame, db.profile.petScale.posX, db.profile.petScale.posY)
            end
        else
            arenaFrame:SetParent(ArenaEnemyFrames)

            if (i == 1) then
                arenaFrame:SetPoint("TOP", arenaFrame:GetParent(), "TOP")
            else
                arenaFrame:SetPoint("TOP", "ArenaEnemyFrame" .. i - 1, "BOTTOM", 0, -20)
            end
        end
    end
end

function sArenaMixin:OnLoad(self)
    auraList = self.auraList
    interruptList = self.interruptList

    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

local eventRegistered = {
    ["SPELL_CAST_START"] = true,
    ["SPELL_CAST_SUCCESS"] = true,
    ["SPELL_CAST_FAILED"] = true,
    ["SPELL_AURA_APPLIED"] = true,
    ["SPELL_AURA_REFRESH"] = true,
    ["SPELL_AURA_REMOVED"] = true,
    ["SPELL_HEAL"] = true,
    ["SPELL_DAMAGE"] = true,
}

function sArenaMixin:OnEvent(event, ...)
    if (event == "PLAYER_LOGIN") then
        self:Initialize()
        self:UnregisterEvent("PLAYER_LOGIN")
    elseif (event == "PLAYER_ENTERING_WORLD") then
        local _, instanceType = IsInInstance()
        UpdateBlizzVisibility(instanceType)
        self:SetMouseState(true)

        if (instanceType == "arena") then
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            if (InCombatLockdown()) then
                return
            end
            self:Show()
        else
            self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            if (InCombatLockdown()) then
                return
            end
            self:Hide()
        end
    elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        local _, combatEvent, _, sourceGUID, _, srcFlags, _, destGUID, _, _, _, spellID, _, _, auraType = CombatLogGetCurrentEventInfo(...)

        if not eventRegistered[combatEvent] then
            return
        end

        local isSourceEnemy = CombatLog_Object_IsA(srcFlags, COMBATLOG_FILTER_HOSTILE_PLAYERS)

        for i = 1, 5 do
            local ArenaFrame = self["arena" .. i]

            if (sourceGUID == UnitGUID("arena" .. i)) then
                ArenaFrame:FindRacial(combatEvent, spellID)
                ArenaFrame:FindTrinket(combatEvent, spellID)
                if not ArenaFrame.specTexture and isSourceEnemy and spellID then
                    ArenaFrame:DetectSpec("arena" .. i, spellID)
                end
            end

            if (destGUID == UnitGUID("arena" .. i)) then
			   local spellName = spellID and GetSpellInfo(spellID) or nil
			   
               ArenaFrame:FindInterrupt(combatEvent, spellName or spellID)

                if (auraType == "DEBUFF") then
                    ArenaFrame:FindDR(combatEvent, spellName or spellID)
                end

                return
            end
        end
    end
end

function sArena_OnLoad(self)
    Mixin(self, sArenaMixin)
    sArenaMixin:OnLoad(self)
end

function sArena_OnEvent(self, event, ...)
    self:OnEvent(event, ...)
end

local function ChatCommand(input)
    if not input or input:trim() == "" then
        LibStub("AceConfigDialog-3.0"):Open("sArena")
    else
        LibStub("AceConfigCmd-3.0").HandleCommand("sArena", "sarena", "sArena", input)
    end
end

function sArenaMixin:Initialize()
    if (db) then
        return
    end

    self.db = LibStub("AceDB-3.0"):New("sArena3DB", self.defaultSettings, true)
    db = self.db

    db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    self.optionsTable.handler = self
    self.optionsTable.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("sArena", self.optionsTable)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("sArena")
    LibStub("AceConfigDialog-3.0"):SetDefaultSize("sArena", 700, 620)
    LibStub("AceConsole-3.0"):RegisterChatCommand("sarena", ChatCommand)

    self:SetLayout(nil, db.profile.currentLayout)
end

function sArenaMixin:RefreshConfig()
    self:SetLayout(nil, db.profile.currentLayout)
end

function sArenaMixin:SetLayout(_, layout)
    if (InCombatLockdown()) then
        return
    end

    layout = sArenaMixin.layouts[layout] and layout or "BlizzArena"

    db.profile.currentLayout = layout
    self.layoutdb = self.db.profile.layoutSettings[layout]

    for i = 1, 5 do
        local frame = self["arena" .. i]
        frame:ResetLayout()
        self.layouts[layout]:Initialize(frame)
        frame:UpdatePlayer()
    end

    self.optionsTable.args.layoutSettingsGroup.args = self.layouts[layout].optionsTable and
            self.layouts[layout].optionsTable or emptyLayoutOptionsTable
    LibStub("AceConfigRegistry-3.0"):NotifyChange("sArena")

    local _, instanceType = IsInInstance()
    if (instanceType ~= "arena" and self.arena1:IsShown()) then
        self:Test()
    end
end

function sArenaMixin:SetupDrag(frameToClick, frameToMove, settingsTable, updateMethod)
    frameToClick:HookScript("OnMouseDown", function()
        if (InCombatLockdown()) then
            return
        end

        if (IsShiftKeyDown() and IsControlKeyDown() and not frameToMove.isMoving) then
            frameToMove:StartMoving()
            frameToMove.isMoving = true
        end
    end)

    frameToClick:HookScript("OnMouseUp", function()
        if (InCombatLockdown()) then
            return
        end

        if (frameToMove.isMoving) then
            frameToMove:StopMovingOrSizing()
            frameToMove.isMoving = false

            local settings = db.profile.layoutSettings[db.profile.currentLayout]

            if (settingsTable) then
                settings = settings[settingsTable]
            end

            local parentX, parentY = frameToMove:GetParent():GetCenter()
            local frameX, frameY = frameToMove:GetCenter()
            local scale = frameToMove:GetScale()

            frameX = ((frameX * scale) - parentX) / scale
            frameY = ((frameY * scale) - parentY) / scale

            -- round to 1 decimal place
            frameX = floor(frameX * 10 + 0.5) / 10
            frameY = floor(frameY * 10 + 0.5) / 10

            settings.posX, settings.posY = frameX, frameY
            self[updateMethod](self, settings)
            LibStub("AceConfigRegistry-3.0"):NotifyChange("sArena")
        end
    end)
end

function sArenaMixin:SetMouseState(state)
    for i = 1, 5 do
        local frame = self["arena" .. i]
        frame.CastBar:EnableMouse(state)
        frame.incapacitate:EnableMouse(state)
        frame.SpecIcon:EnableMouse(state)
        frame.Trinket:EnableMouse(state)
        frame.Racial:EnableMouse(state)
    end
end

-- Arena Frames

local function ResetTexture(texturePool, t)
    if (texturePool) then
        t:SetParent(texturePool.parent)
    end

    t:SetTexture("")
    t:SetColorTexture(0, 0, 0, 0)
    t:SetVertexColor(1, 1, 1, 1)
    t:SetDesaturated()
    t:SetTexCoord(0, 1, 0, 1)
    t:ClearAllPoints()
    t:SetSize(0, 0)
    t:Hide()
end

function sArena_CastBar(self, unit, showTradeSkills, showShield)
    if self.unit ~= unit then
        self.unit = unit;
        self.showTradeSkills = showTradeSkills;
        self.showShield = showShield;

        self.casting = nil;
        self.channeling = nil;
        self.holdTime = 0;
        self.fadeOut = nil;

        if unit then
            self.showCastbar = true
            self.notInterruptible = false

            self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
            self:RegisterEvent("UNIT_SPELLCAST_DELAYED");
            self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
            self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
            self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
            self:RegisterEvent("PLAYER_ENTERING_WORLD");
            self:RegisterEvent("UNIT_SPELLCAST_START");
            self:RegisterEvent("UNIT_SPELLCAST_STOP");
            self:RegisterEvent("UNIT_SPELLCAST_FAILED");
            self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE");
            self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE");

            CastingBarFrame_OnEvent(self, "PLAYER_ENTERING_WORLD")
        else
            self.showCastbar = false;

            self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
            self:UnregisterEvent("UNIT_SPELLCAST_DELAYED");
            self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
            self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
            self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
            self:UnregisterEvent("PLAYER_ENTERING_WORLD");
            self:UnregisterEvent("UNIT_SPELLCAST_START");
            self:UnregisterEvent("UNIT_SPELLCAST_STOP");
            self:UnregisterEvent("UNIT_SPELLCAST_FAILED");
            self:Hide();
        end
    end
end

function sArena_CastBar_OnEvent(self, event, ...)
    local arg1 = ...;

    local unit = self.unit;
    if ( event == "PLAYER_ENTERING_WORLD" ) then
        local nameChannel = UnitChannelInfo(unit);
        local nameSpell = UnitCastingInfo(unit);
        if ( nameChannel ) then
            event = "UNIT_SPELLCAST_CHANNEL_START";
            arg1 = unit;
        elseif ( nameSpell ) then
            event = "UNIT_SPELLCAST_START";
            arg1 = unit;
        else
            CastingBarFrame_FinishSpell(self);
        end
    end

    if ( arg1 ~= unit ) then
        return;
    end

    if ( event == "UNIT_SPELLCAST_START" ) then
        local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)
        self.notInterruptible = notInterruptible;

        if ( not name or (not self.showTradeSkills and isTradeSkill)) then
            self:Hide();
            return;
        end

        self:SetStatusBarColor(1.0, 0.7, 0.0);
        self.Flash:SetVertexColor(1, 1, 1);

        if ( self.Spark ) then
            self.Spark:Show();
        end
        self.value = (GetTime() - (startTime / 1000));
        self.maxValue = (endTime - startTime) / 1000;
        self:SetMinMaxValues(0, self.maxValue);
        self:SetValue(self.value);
        if ( self.Text ) then
            self.Text:SetText(text);
        end
        if ( self.Icon ) then
            self.Icon:SetTexture(texture);
            if ( self.iconWhenNoninterruptible ) then
                self.Icon:SetShown(not notInterruptible);
            end
        end
        self:SetAlpha(1)
        self.holdTime = 0;
        self.casting = 1;
        self.castID = castID;
        self.channeling = nil;
        self.fadeOut = nil;

        if ( self.BorderShield ) then
            if ( self.showShield and notInterruptible ) then
                self.BorderShield:Show();
                if ( self.BarBorder ) then
                    self.BarBorder:Hide();
                end
            else
                self.BorderShield:Hide();
                if ( self.BarBorder ) then
                    self.BarBorder:Show();
                end
            end
        end
        if ( self.showCastbar ) then
            self:Show();
        end

    elseif ( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") then
        if ( not self:IsVisible() ) then
            self:Hide();
        end
        if ( (self.casting and event == "UNIT_SPELLCAST_STOP" and select(4, ...) == self.castID) or
                (self.channeling and event == "UNIT_SPELLCAST_CHANNEL_STOP") ) then
            if ( self.Spark ) then
                self.Spark:Hide();
            end
            if ( self.Flash ) then
                self.Flash:SetAlpha(0.0);
                self.Flash:Show();
            end
            self:SetValue(self.maxValue);
            if ( event == "UNIT_SPELLCAST_STOP" ) then
                self.casting = nil;
                self:SetStatusBarColor(0.0, 1.0, 0.0);
            else
                self.channeling = nil;
            end
            self.flash = 1;
            self.fadeOut = 1;
            self.holdTime = 0;
        end
    elseif ( event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" ) then
        if ( self:IsShown() and
                (self.casting and select(4, ...) == self.castID) and not self.fadeOut ) then
            self:SetValue(self.maxValue);
            self:SetStatusBarColor(1.0, 0.0, 0.0);
            if ( self.Spark ) then
                self.Spark:Hide();
            end
            if ( self.Text ) then
                if ( event == "UNIT_SPELLCAST_FAILED" ) then
                    self.Text:SetText(FAILED);
                else
                    self.Text:SetText(INTERRUPTED);
                end
            end
            self.casting = nil;
            self.channeling = nil;
            self.fadeOut = 1;
            self.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
        end
    elseif ( event == "UNIT_SPELLCAST_DELAYED" ) then
        if ( self:IsShown() ) then
            local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit)
            self.notInterruptible = notInterruptible;

            if ( not name or (not self.showTradeSkills and isTradeSkill)) then
                -- if there is no name, there is no bar
                self:Hide();
                return;
            end
            self.value = (GetTime() - (startTime / 1000));
            self.maxValue = (endTime - startTime) / 1000;
            self:SetMinMaxValues(0, self.maxValue);
            if ( not self.casting ) then
                self:SetStatusBarColor(1.0, 0.7, 0.0);
                if ( self.Spark ) then
                    self.Spark:Show();
                end
                if ( self.Flash ) then
                    self.Flash:SetAlpha(0.0);
                    self.Flash:Hide();
                end
                self.casting = 1;
                self.channeling = nil;
                self.flash = 0;
                self.fadeOut = 0;
            end
        end
    elseif ( event == "UNIT_SPELLCAST_CHANNEL_START" ) then
        local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(unit);
        self.notInterruptible = notInterruptible;

        if ( not name or (not self.showTradeSkills and isTradeSkill)) then
            -- if there is no name, there is no bar
            self:Hide();
            return;
        end

        self.Flash:SetVertexColor(1, 1, 1);
        self:SetStatusBarColor(0.0, 1.0, 0.0);
        self.value = (endTime / 1000) - GetTime();
        self.maxValue = (endTime - startTime) / 1000;
        self:SetMinMaxValues(0, self.maxValue);
        self:SetValue(self.value);
        if ( self.Text ) then
            self.Text:SetText(text);
        end
        if ( self.Icon ) then
            self.Icon:SetTexture(texture)
        end
        if ( self.Spark ) then
            self.Spark:Hide();
        end
        self:SetAlpha(1)
        self.holdTime = 0;
        self.casting = nil;
        self.channeling = 1;
        self.fadeOut = nil;
        if ( self.BorderShield ) then
            if ( self.showShield and notInterruptible ) then
                self.BorderShield:Show();
                if ( self.BarBorder ) then
                    self.BarBorder:Hide();
                end
            else
                self.BorderShield:Hide();
                if ( self.BarBorder ) then
                    self.BarBorder:Show();
                end
            end
        end
        if ( self.showCastbar ) then
            self:Show();
        end
    elseif ( event == "UNIT_SPELLCAST_CHANNEL_UPDATE" ) then
        if ( self:IsShown() ) then
            local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit);
            if ( not name or (not self.showTradeSkills and isTradeSkill)) then
                -- if there is no name, there is no bar
                self:Hide();
                return;
            end
            self.value = ((endTime / 1000) - GetTime());
            self.maxValue = (endTime - startTime) / 1000;
            self:SetMinMaxValues(0, self.maxValue);
            self:SetValue(self.value);
        end
    elseif ( self.showShield and event == "UNIT_SPELLCAST_INTERRUPTIBLE" ) then
        if self.BorderShield then
            self.BorderShield:Hide();
            if self.BarBorder then
                self.BarBorder:Show();
            end
        end
    elseif ( self.showShield and event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" ) then
        if self.BorderShield then
            self.BorderShield:Show();
            if self.BarBorder then
                self.BarBorder:Hide();
            end
        end
    end
end

function sArena_CastBar_OnUpdate(self, elapsed)
    if ( self.casting ) then
        self.value = self.value + elapsed;
        if ( self.value >= self.maxValue ) then
            self:SetValue(self.maxValue);
            CastingBarFrame_FinishSpell(self, self.Spark, self.Flash);
            return;
        end
        self:SetValue(self.value);
        if ( self.Flash ) then
            self.Flash:Hide();
        end
        if ( self.Spark ) then
            local sparkPosition = (self.value / self.maxValue) * self:GetWidth();
            self.Spark:SetPoint("CENTER", self, "LEFT", sparkPosition, self.Spark.offsetY or 2);
        end
    elseif ( self.channeling ) then
        self.value = self.value - elapsed;
        if ( self.value <= 0 ) then
            CastingBarFrame_FinishSpell(self, self.Spark, self.Flash);
            return;
        end
        self:SetValue(self.value);
        if ( self.Flash ) then
            self.Flash:Hide();
        end
    elseif ( GetTime() < self.holdTime ) then
        return;
    elseif ( self.flash ) then
        local alpha = 0;
        if ( self.Flash ) then
            alpha = self.Flash:GetAlpha() + CASTING_BAR_FLASH_STEP;
        end
        if ( alpha < 1 ) then
            if ( self.Flash ) then
                self.Flash:SetAlpha(alpha);
            end
        else
            if ( self.Flash ) then
                self.Flash:SetAlpha(1.0);
            end
            self.flash = nil;
        end
    elseif ( self.fadeOut ) then
        local alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP;
        if ( alpha > 0 ) then
            self:SetAlpha(0)
        else
            self.fadeOut = nil;
            self:Hide();
        end
    end
end

function sArenaFrameMixin:OnLoad()
    local unit = "arena" .. self:GetID()
    self.parent = self:GetParent()

    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_NAME_UPDATE")
    self:RegisterEvent("ARENA_OPPONENT_UPDATE")
    self:RegisterEvent("ARENA_COOLDOWNS_UPDATE")
   -- self:RegisterEvent("ARENA_CROWD_CONTROL_SPELL_UPDATE")
    self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
    self:RegisterUnitEvent("UNIT_HEALTH", unit)
    self:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    self:RegisterUnitEvent("UNIT_POWER_UPDATE", unit)
    self:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    self:RegisterUnitEvent("UNIT_DISPLAYPOWER", unit)
    self:RegisterUnitEvent("UNIT_AURA", unit)

    self:RegisterForClicks("AnyUp")
    self:SetAttribute("*type1", "target")
    self:SetAttribute("*type2", "focus")
    self:SetAttribute("unit", unit)
    self.unit = unit
	self.isInStealth = false

    sArena_CastBar(self.CastBar, unit, false, true)

    self.healthbar = self.HealthBar

    self.TexturePool = CreateTexturePool(self, "ARTWORK", nil, nil, ResetTexture)
end

function sArenaFrameMixin:OnEvent(event, eventUnit, ...)
    local unit = self.unit

    if (eventUnit and eventUnit == unit) then
        if (event == "UNIT_NAME_UPDATE") then
            if db.profile.arenaNames then
                self.Name:SetText(unit)
            else
                self.Name:SetText(GetUnitName(unit))
            end
        elseif (event == "ARENA_OPPONENT_UPDATE") then
            local updateReason = ...
            self:UpdatePlayer(updateReason, eventUnit)
        elseif (event == "ARENA_COOLDOWNS_UPDATE") then
            self:UpdateTrinket()
            -- sets trinket texture & changes human to always show a trinket
        elseif (event == "ARENA_CROWD_CONTROL_SPELL_UPDATE") then
            local spellID, itemID = ...
            if (spellID ~= self.Trinket.spellID) then
                self.Trinket.spellID = spellID;

                if (itemID and itemID ~= 0) then
                    local itemTexture = GetItemIcon(itemID);
                    self.Trinket.Texture:SetTexture(itemTexture);
                else
                    local spellTexture, spellTextureNoOverride = select(3, GetSpellInfo(spellID))
                    self.Trinket.Texture:SetTexture(spellTextureNoOverride);
                end
            end

        elseif (event == "UNIT_AURA") then
            self:FindAura()
        elseif (event == "UNIT_HEALTH") then
            self:SetLifeState()
            self:SetStatusText()
            local currHp = UnitHealth(unit)
            if (currHp ~= self.currHp) then
                self.HealthBar:SetValue(currHp)
                -- UnitFrameHealPredictionBars_Update(self)
                self.currHp = currHp
            end
        elseif (event == "UNIT_MAXHEALTH") then
            self.HealthBar:SetMinMaxValues(0, UnitHealthMax(unit))
            self.HealthBar:SetValue(UnitHealth(unit))
            -- UnitFrameHealPredictionBars_Update(self)
        elseif (event == "UNIT_POWER_UPDATE") then
            self:SetStatusText()
            self.PowerBar:SetValue(UnitPower(unit))
        elseif (event == "UNIT_MAXPOWER") then
            self.PowerBar:SetMinMaxValues(0, UnitPowerMax(unit))
            self.PowerBar:SetValue(UnitPower(unit))
        elseif (event == "UNIT_DISPLAYPOWER") then
            local _, powerType = UnitPowerType(unit)
            self:SetPowerType(powerType)
            self.PowerBar:SetMinMaxValues(0, UnitPowerMax(unit))
            self.PowerBar:SetValue(UnitPower(unit))
        end
    elseif (event == "PLAYER_LOGIN") then
        self:UnregisterEvent("PLAYER_LOGIN")

        if (not db) then
            self.parent:Initialize()
        end

        self:Initialize()
        if db.profile.cbicon then
            self:CreateCombatIndicatorForUnit()
        end
    elseif (event == "PLAYER_ENTERING_WORLD") then
        self.Name:SetText("")
        self.CastBar:Hide()
        self.specTexture = nil
        self.class = nil
        self.currentClassIconTexture = nil
        self.currentClassIconStartTime = 0
        self:UpdatePlayer()
        self:ResetTrinket()
        self:ResetRacial()
        self:ResetDR()
        if self.CombatIcon then
            self.CombatIcon:Hide()
        end
        -- UnitFrameHealPredictionBars_Update(self)
    elseif (event == "PLAYER_REGEN_ENABLED") then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    elseif event == "UPDATE_BATTLEFIELD_STATUS" then
        local status, _, _, _, _, teamSize = GetBattlefieldStatus(eventUnit)
        local _, instanceType = IsInInstance()
        if ((instanceType == "arena" or GetNumArenaOpponents() > 0) and status == "active" and teamSize > 0) then
            for i = 1, teamSize do
                local frame = _G["sArenaEnemyFrame" .. i]
                if frame and not frame:IsShown() and not InCombatLockdown() then
                    frame:Show()
                    if not UnitExists("arena" .. i) then
                        frame:SetMysteryPlayer()
                        frame.ClassIcon:SetTexture("Interface\\Icons\\Inv_misc_questionmark")
                    end
                end
            end
        end
    end
end

function sArenaFrameMixin:Initialize()
    self:SetMysteryPlayer()
    self.parent:SetupDrag(self, self.parent, nil, "UpdateFrameSettings")
    self.parent:SetupDrag(self.CastBar, self.CastBar, "castBar", "UpdateCastBarSettings")
    self.parent:SetupDrag(self.incapacitate, self.incapacitate, "dr", "UpdateDRSettings")
    self.parent:SetupDrag(self.SpecIcon, self.SpecIcon, "specIcon", "UpdateSpecIconSettings")
    self.parent:SetupDrag(self.Trinket, self.Trinket, "trinket", "UpdateTrinketSettings")
    self.parent:SetupDrag(self.Racial, self.Racial, "racial", "UpdateRacialSettings")
end

function sArenaFrameMixin:OnEnter()
    UnitFrame_OnEnter(self)

    self.HealthText:Show()
    self.PowerText:Show()
end

function sArenaFrameMixin:OnLeave()
    UnitFrame_OnLeave(self)

    self:UpdateStatusTextVisible()
end

function sArenaFrameMixin_OnLoad(self)
    Mixin(self, sArenaFrameMixin)
    self:OnLoad()
end

function sArenaFrameMixin_OnEvent(self, event, ...)
    self:OnEvent(event, ...)
end

function sArenaFrameMixin_OnEnter(self)
    self:OnEnter()
end

function sArenaFrameMixin_OnLeave(self)
    self:OnLeave()
end

function sArenaFrameMixin:UpdatePlayer(unitEvent, unitTarget)
    local unit = unitTarget or self.unit

    
    if unitEvent == "destroyed" then
        self.isInStealth = true
        
        if not self.savedClassIconTexture then
            self.savedClassIconTexture = self.currentClassIconTexture
            self.savedSpecTexture = self.specTexture
            self.savedClass = self.class
        end
        
        self.ClassIcon:SetTexture("Interface\\Icons\\Inv_misc_questionmark")
        self.ClassIcon:SetTexCoord(0, 1, 0, 1)
        self.currentClassIconTexture = "Interface\\Icons\\Inv_misc_questionmark"
        
        
        self.HealthBar:SetStatusBarColor(0.5, 0.5, 0.5)
        self.PowerBar:SetStatusBarColor(0.5, 0.5, 0.5)
        
        return
    end

    
    if unitEvent == "seen" and self.isInStealth then
        self.isInStealth = false
        
        if self.savedClassIconTexture then
            self.currentClassIconTexture = nil 
            self.specTexture = self.savedSpecTexture
            self.class = self.savedClass
            self.savedClassIconTexture = nil
            self.savedSpecTexture = nil
            self.savedClass = nil
        end
        
        
        self:GetClassAndSpec()
        self:UpdateClassIcon()
    end

    self:GetClassAndSpec()
    self:FindAura()

    if unit and not self.specTexture then
        After(0, function()
            self:DetectSpec(unit, nil)
        end)
    end

    if not InCombatLockdown() and unitEvent and unitEvent == "cleared" then
        self:Hide()
        return
    end

    if ((unitEvent and unitEvent ~= "seen") or not UnitExists(unit)) then
        
        if not self.isInStealth then
            self:SetMysteryPlayer()
        end
        return
    end

    self:UpdateTrinket(unit)
    self:UpdateRacial()

    -- prevent castbar and other frames from intercepting mouse clicks during a match
    if (unitEvent == "seen") then
        self.parent:SetMouseState(false)
    end

    self.hideStatusText = false

    if db.profile.arenaNames then
        self.Name:SetText(unit)
    else
        self.Name:SetText(GetUnitName(unit))
    end
    self.Name:SetShown(db.profile.showNames)

    self:UpdateStatusTextVisible()
    self:SetStatusText()

    self:OnEvent("UNIT_MAXHEALTH", unit)
    self:OnEvent("UNIT_HEALTH", unit)
    self:OnEvent("UNIT_MAXPOWER", unit)
    self:OnEvent("UNIT_POWER_UPDATE", unit)
    self:OnEvent("UNIT_DISPLAYPOWER", unit)

    local _, class = UnitClass(unit)
    local color = RAID_CLASS_COLORS[class]

    if (color and db.profile.classColors) then
        self.HealthBar:SetStatusBarColor(color.r, color.g, color.b, 1.0)
    else
        self.HealthBar:SetStatusBarColor(0, 1.0, 0, 1.0)
    end
end

function sArenaFrameMixin:SetMysteryPlayer()
    local f = self.HealthBar
    f:SetMinMaxValues(0, 100)
    f:SetValue(100)
    f:SetStatusBarColor(0.5, 0.5, 0.5)

    f = self.PowerBar
    f:SetMinMaxValues(0, 100)
    f:SetValue(100)
    f:SetStatusBarColor(0.5, 0.5, 0.5)

    self.hideStatusText = true
    self:SetStatusText()

    self.DeathIcon:Hide()
end

function sArenaFrameMixin:GetClassAndSpec()
    local _, instanceType = IsInInstance()

    if (instanceType ~= "arena") then
        self.specTexture = nil
        self.class = nil
        self.SpecBorderOverlay:Hide()
        self.ClassIcon:SetTexture("Interface\\Icons\\Inv_misc_questionmark")
    elseif (not self.specTexture or not self.class) then
        local id = self:GetID()
        if (GetNumArenaOpponents() >= id) then
            self:DetectSpec(self.unit)
            _, self.class = UnitClass(self.unit)
            self:UpdateClassIcon()
        end
    end

    if not self.specTexture or db.profile.specIcons then
        self.SpecBorderOverlay:Hide()
    end
end

function sArenaFrameMixin:UpdateClassIcon()
    if not self then return end

    
    if (self.currentAuraSpellName and self.currentAuraDuration > 0 and self.currentClassIconStartTime ~= self.currentAuraStartTime) then
        self.ClassIconCooldown:SetCooldown(self.currentAuraStartTime, self.currentAuraDuration)
        self.currentClassIconStartTime = self.currentAuraStartTime
    elseif (self.currentAuraDuration and self.currentAuraDuration == 0) then
        self.ClassIconCooldown:Clear()
        self.currentClassIconStartTime = 0
    end

    local unknown = "Interface\\Icons\\Inv_misc_questionmark"
    local texture = self.class and "class" or unknown

   
    if self.currentAuraSpellName then
        texture = self.currentAuraTexture
    elseif self.specTexture and db.profile.specIcons then
        texture = "Interface\\Icons\\" .. self.specTexture
    end

    if (self.currentClassIconTexture == texture) then
        return
    end

    self.currentClassIconTexture = texture

    if (texture == "class") then
        self.ClassIcon:SetTexture(iconPath, true)
        self.ClassIcon:SetTexCoord(unpack(classIcons[self.class]))
        return
    end
    
    self.ClassIcon:SetTexCoord(0, 1, 0, 1)
    self.ClassIcon:SetTexture(texture)
end

local function ResetStatusBar(f)
    f:SetStatusBarTexture("")
    f:ClearAllPoints()
    f:SetSize(0, 0)
    f:SetScale(1)
end

local function ResetFontString(f)
    f:SetDrawLayer("OVERLAY", 1)
    f:SetJustifyH("CENTER")
    f:SetJustifyV("MIDDLE")
    f:SetTextColor(1, 0.82, 0, 1)
    f:SetShadowColor(0, 0, 0, 1)
    f:SetShadowOffset(1, -1)
    f:ClearAllPoints()
    f:Hide()
end

function sArenaFrameMixin:ResetLayout()
    self.currentClassIconTexture = nil
    self.currentClassIconStartTime = 0

    ResetTexture(nil, self.ClassIcon)
    ResetStatusBar(self.HealthBar)
    ResetStatusBar(self.PowerBar)
    ResetStatusBar(self.CastBar)
    self.CastBar:SetHeight(16)
    --self.ClassIcon:RemoveMaskTexture(self.ClassIconMask)

    --self.ClassIconCooldown:SetSwipeTexture(1)
    --self.ClassIconCooldown:SetUseCircularEdge(false)

    local f = self.Trinket
    f:ClearAllPoints()
    f:SetSize(0, 0)
    f.Texture:SetTexCoord(0, 1, 0, 1)

    f = self.Racial
    f:ClearAllPoints()
    f:SetSize(0, 0)
    f.Texture:SetTexCoord(0, 1, 0, 1)

    f = self.SpecIcon
    f:ClearAllPoints()
    f:SetSize(0, 0)
    f:SetScale(1)
   -- f.Texture:RemoveMaskTexture(f.Mask)
    f.Texture:SetTexCoord(0, 1, 0, 1)

    f = self.Name
    ResetFontString(f)
    f:SetDrawLayer("OVERLAY")
    f:SetFontObject("GameFontNormalSmall")
    --f:SetScale(1.4)

    f = self.HealthText
    ResetFontString(f)
    f:SetDrawLayer("OVERLAY")
    f:SetFontObject("TextStatusBarText")
    f:SetTextColor(1, 1, 1, 1)

    f = self.PowerText
    ResetFontString(f)
    f:SetDrawLayer("OVERLAY")
    f:SetFontObject("TextStatusBarText")
    f:SetTextColor(1, 1, 1, 1)

    f = self.CastBar
    f.Icon:SetTexCoord(0, 1, 0, 1)

    --if self.TexturePool then
        self.TexturePool:ReleaseAll()
   -- end
end

function sArenaFrameMixin:SetPowerType(powerType)
    local color = PowerBarColor[powerType]
    if color then
        self.PowerBar:SetStatusBarColor(color.r, color.g, color.b)
    end
end

function sArenaFrameMixin:FindAura()
    local unit = self.unit
    local currentSpellName, currentDuration, currentExpirationTime, currentTexture = nil, 0, 0, nil

   
    if (self.currentInterruptSpellName) then
        currentSpellName = self.currentInterruptSpellName
        currentDuration = self.currentInterruptDuration
        currentExpirationTime = self.currentInterruptExpirationTime
        currentTexture = self.currentInterruptTexture
    end

    
    for i = 1, 2 do
        local filter = (i == 1 and "HELPFUL" or "HARMFUL")

        for n = 1, 30 do
            local name, _, texture, _, _, duration, expirationTime = UnitAura(unit, n, filter)

            if (not name) then
                break
            end

            
            if (auraList[name]) then
                if (not currentSpellName or auraList[name] < auraList[currentSpellName]) then
                    currentSpellName = name
                    currentDuration = duration
                    currentExpirationTime = expirationTime
                    currentTexture = texture
                end
            end
        end
    end

    
    if (currentSpellName) then
        self.currentAuraSpellName = currentSpellName
        self.currentAuraStartTime = currentExpirationTime - currentDuration
        self.currentAuraDuration = currentDuration
        self.currentAuraTexture = currentTexture
    else
        self.currentAuraSpellName = nil
        self.currentAuraStartTime = 0
        self.currentAuraDuration = 0
        self.currentAuraTexture = nil
    end

    self:UpdateClassIcon()
end

function sArenaFrameMixin:FindInterrupt(event, spellParam)
    
    local spellName = spellParam
    if type(spellParam) == "number" then
        spellName = GetSpellInfo(spellParam)
    end

    if not spellName then
        return
    end

    local interruptDuration = interruptList[spellName]

    if (not interruptDuration) then
        return
    end
    
    if (event ~= "SPELL_INTERRUPT" and event ~= "SPELL_CAST_SUCCESS") then
        return
    end

    local unit = self.unit
    local _, _, _, _, _, _, _, notInterruptable = UnitChannelInfo(unit)

    if (event == "SPELL_INTERRUPT" or notInterruptable == false) then
        self.currentInterruptSpellName = spellName
        self.currentInterruptDuration = interruptDuration
        self.currentInterruptExpirationTime = GetTime() + interruptDuration
        self.currentInterruptTexture = select(3, GetSpellInfo(spellName))
        
        self:FindAura()
        
        
        C_Timer.After(interruptDuration, function()
            if self.currentInterruptSpellName == spellName then
                self.currentInterruptSpellName = nil
                self.currentInterruptDuration = 0
                self.currentInterruptExpirationTime = 0
                self.currentInterruptTexture = nil
                self:FindAura()
            end
        end)
    end
end

function sArenaFrameMixin:SetLifeState()
    local unit = self.unit
    local isDead = UnitIsDeadOrGhost(unit) and not FindAuraByName(FEIGN_DEATH, unit, "HELPFUL")

    self.DeathIcon:SetShown(isDead)
    self.hideStatusText = isDead
    if (isDead) then
        self:ResetDR()
    end
end

local function k(val)
    if (val >= 1e3) then
        if db.profile.currentLayout == "Asuri" then
            return ("%.1f"):format(val / 1e3)
        else
            return ("%.1fk"):format(val / 1e3)
        end
    else
        return val
    end
end

function sArenaFrameMixin:SetStatusText(unit)

    if (self.hideStatusText) then
        --[[
		f = self.HealthText
		ResetFontString(f)
		f:SetDrawLayer("ARTWORK", 4)
		f:SetFontObject("Game10Font_o1")
		f:SetTextColor(1, 1, 1, 1)

		f = self.PowerText
		ResetFontString(f)
		f:SetDrawLayer("ARTWORK", 3)
		f:SetFontObject("Game10Font_o1")
		f:SetTextColor(1, 1, 1, 1)
		--]]
        self.HealthText:SetFontObject("TextStatusBarText")
        self.HealthText:SetText("")
        self.PowerText:SetFontObject("TextStatusBarText")
        self.PowerText:SetText("")

        return
    end

    if (not unit) then
        unit = self.unit
    end

    local hp = UnitHealth(unit)
    local hpMax = UnitHealthMax(unit)
    local pp = UnitPower(unit)
    local ppMax = UnitPowerMax(unit)

    if (db.profile.statusText.usePercentage) then
        self.HealthText:SetText(ceil((hp / hpMax) * 100) .. "%")
        self.PowerText:SetText(ceil((pp / ppMax) * 100) .. "%")
    elseif db.profile.statusText.Abbreviate then
        self.HealthText:SetText(k(hp))
        self.PowerText:SetText(k(pp))
    else
        self.HealthText:SetText(TextStatusBar_CapDisplayOfNumericValue(hp))
        self.PowerText:SetText(TextStatusBar_CapDisplayOfNumericValue(pp))
    end
end

function sArenaFrameMixin:UpdateStatusTextVisible()
    self.HealthText:SetShown(db.profile.statusText.alwaysShow)
    self.PowerText:SetShown(db.profile.statusText.alwaysShow)
end

function sArenaMixin:Test()
    local _, instanceType = IsInInstance()
    if (InCombatLockdown() or instanceType == "arena") then
        return
    end

    self:Show();
    local currTime = GetTime()

    for i = 1, 5 do

        if (i == 1) then

            local frame = self["arena" .. i]
            frame:Show()
            frame:SetAlpha(1)

            frame.HealthBar:SetMinMaxValues(0, 100)
            frame.HealthBar:SetValue(100)

            frame.PowerBar:SetMinMaxValues(0, 100)
            frame.PowerBar:SetValue(100)

            local petFrame = _G["ArenaEnemyFrame" .. i .. "PetFrame"]
            if petFrame and db.profile.petFrames then
                petFrame:ClearAllPoints()
                petFrame:SetParent(frame)
                petFrame:SetPoint("BOTTOMRIGHT", frame, db.profile.petScale.posX, db.profile.petScale.posY)
                petFrame:Show()
                petFrame.healthbar:SetStatusBarColor(0,1,0)
                petFrame.portrait:SetTexture("Interface\\Icons\\ability_hunter_pet_cat")
            end

            if frame.CombatIcon then
                frame.CombatIcon:ClearAllPoints()
                frame.CombatIcon:SetPoint("CENTER", frame, "CENTER", db.profile.CombatIndicator.posX, db.profile.CombatIndicator.posY)
                frame.CombatIcon:Show()
            end


            if db.profile.specIcons then
                if ( frame.parent.portraitClassIcon ) then
                    SetPortraitToTexture(frame.ClassIcon, "Interface\\Icons\\ability_marksmanship");
                else
                    frame.ClassIcon:SetTexture("Interface\\Icons\\ability_marksmanship");
                end
            else
                frame.ClassIcon:SetTexture(iconPath, true);
                frame.ClassIcon:SetTexCoord(unpack(classIcons["HUNTER"]));

                if ( frame.parent.portraitSpecIcon ) then
                    SetPortraitToTexture(frame.SpecIcon.Texture, "Interface\\Icons\\ability_marksmanship");
                else
                    frame.SpecIcon.Texture:SetTexture("Interface\\Icons\\ability_marksmanship");
                end
                frame.SpecIcon:Show()
            end

            frame.ClassIconCooldown:SetCooldown(GetTime(), math.random(20, 60))
            if db.profile.arenaNames then
                frame.Name:SetText("arena" .. i)
            else
                frame.Name:SetText("Tosan")
            end
            frame.Name:SetShown(db.profile.showNames)

            frame.Trinket.Texture:SetTexture("Interface\\Icons\\inv_jewelry_trinketpvp_02")
            frame.Trinket.Cooldown:SetCooldown(currTime, math.random(20, 60))

            frame.Racial.Texture:SetTexture("Interface\\Icons\\spell_shadow_unholystrength")
            frame.Racial.Cooldown:SetCooldown(currTime, math.random(20, 60))

            local color = RAID_CLASS_COLORS["HUNTER"]
            if (db.profile.classColors) then
                frame.HealthBar:SetStatusBarColor(color.r, color.g, color.b, 1)
            else
                frame.HealthBar:SetStatusBarColor(0, 1, 0, 1)
            end
            frame.PowerBar:SetStatusBarColor(0, 0, 1, 1)

            frame:FindDR("SPELL_AURA_APPLIED_DUMMY", "Hammer of Justice")
            frame:FindDR("SPELL_AURA_APPLIED_DUMMY", "Polymorph")
            frame:FindDR("SPELL_AURA_APPLIED_DUMMY", "Fear")

            frame.CastBar.fadeOut = nil
            frame.CastBar:Show()
            frame.CastBar:SetAlpha(1)
            frame.CastBar.Icon:SetTexture("Interface\\Icons\\inv_spear_07")
            frame.CastBar.Text:SetText("Aimed Shot")
            frame.CastBar:SetStatusBarColor(1, 0.7, 0, 1)

            frame.hideStatusText = false
            frame:SetStatusText("player")
            frame:UpdateStatusTextVisible()

        elseif (i == 2) then

            local frame = self["arena" .. i]
            frame:Show()
            frame:SetAlpha(1)

            frame.HealthBar:SetMinMaxValues(0, 100)
            frame.HealthBar:SetValue(100)

            frame.PowerBar:SetMinMaxValues(0, 100)
            frame.PowerBar:SetValue(100)

            if db.profile.specIcons then
                if ( frame.parent.portraitClassIcon ) then
                    SetPortraitToTexture(frame.ClassIcon, "Interface\\Icons\\spell_nature_lightning");
                else
                    frame.ClassIcon:SetTexture("Interface\\Icons\\spell_nature_lightning");
                end
            else
                frame.ClassIcon:SetTexture(iconPath, true);
                frame.ClassIcon:SetTexCoord(unpack(classIcons["SHAMAN"]));

                if ( frame.parent.portraitSpecIcon ) then
                    SetPortraitToTexture(frame.SpecIcon.Texture, "Interface\\Icons\\spell_nature_lightning");
                else
                    frame.SpecIcon.Texture:SetTexture("Interface\\Icons\\spell_nature_lightning");
                end
                frame.SpecIcon:Show()
            end

            if frame.CombatIcon then
                frame.CombatIcon:ClearAllPoints()
                frame.CombatIcon:SetPoint("CENTER", frame, "CENTER", db.profile.CombatIndicator.posX, db.profile.CombatIndicator.posY)
                frame.CombatIcon:Show()
            end

            frame.ClassIconCooldown:SetCooldown(GetTime(), math.random(20, 60))
            if db.profile.arenaNames then
                frame.Name:SetText("arena" .. i)
            else
                frame.Name:SetText("Unbreakable")
            end
            frame.Name:SetShown(db.profile.showNames)

            frame.Trinket.Texture:SetTexture("Interface\\Icons\\inv_jewelry_trinketpvp_02")
            frame.Trinket.Cooldown:SetCooldown(currTime, math.random(20, 60))

            frame.Racial.Texture:SetTexture("Interface\\Icons\\spell_holy_holyprotection")
            frame.Racial.Cooldown:SetCooldown(currTime, math.random(20, 60))

            local color = RAID_CLASS_COLORS["SHAMAN"]
            if (db.profile.classColors) then
                frame.HealthBar:SetStatusBarColor(color.r, color.g, color.b, 1)
            else
                frame.HealthBar:SetStatusBarColor(0, 1, 0, 1)
            end
            frame.PowerBar:SetStatusBarColor(0, 0, 1, 1)

            frame:FindDR("SPELL_AURA_APPLIED_DUMMY", 10890)
            frame:FindDR("SPELL_AURA_APPLIED_DUMMY", 28271) -- poly icon
            frame:FindDR("SPELL_AURA_APPLIED_DUMMY", 8643)

            frame.CastBar.fadeOut = nil
            frame.CastBar:Show()
            frame.CastBar:SetAlpha(1)
            frame.CastBar.Icon:SetTexture("Interface\\Icons\\Spell_nature_chainlightning")
            frame.CastBar.Text:SetText("Chain Lightning")
            frame.CastBar:SetStatusBarColor(1, 0.7, 0, 1)

            frame.hideStatusText = false
            frame:SetStatusText("player")
            frame:UpdateStatusTextVisible()

        elseif (i == 3) then

            local frame = self["arena" .. i]
            frame:Show()
            frame:SetAlpha(1)

            frame.HealthBar:SetMinMaxValues(0, 100)
            frame.HealthBar:SetValue(100)

            frame.PowerBar:SetMinMaxValues(0, 100)
            frame.PowerBar:SetValue(100)

            if db.profile.specIcons then
                if ( frame.parent.portraitClassIcon ) then
                    SetPortraitToTexture(frame.ClassIcon, "Interface\\Icons\\Spell_nature_healingtouch");
                else
                    frame.ClassIcon:SetTexture("Interface\\Icons\\Spell_nature_healingtouch");
                end
            else
                frame.ClassIcon:SetTexture(iconPath, true);
                frame.ClassIcon:SetTexCoord(unpack(classIcons["DRUID"]));

                if ( frame.parent.portraitSpecIcon ) then
                    SetPortraitToTexture(frame.SpecIcon.Texture, "Interface\\Icons\\Spell_nature_healingtouch");
                else
                    frame.SpecIcon.Texture:SetTexture("Interface\\Icons\\Spell_nature_healingtouch");
                end
                frame.SpecIcon:Show()
            end

            if frame.CombatIcon then
                frame.CombatIcon:ClearAllPoints()
                frame.CombatIcon:SetPoint("CENTER", frame, "CENTER", db.profile.CombatIndicator.posX, db.profile.CombatIndicator.posY)
                frame.CombatIcon:Show()
            end

            frame.ClassIconCooldown:SetCooldown(GetTime(), math.random(20, 60))
            if db.profile.arenaNames then
                frame.Name:SetText("arena" .. i)
            else
                frame.Name:SetText("Hafu")
            end
            frame.Name:SetShown(db.profile.showNames)

            frame.Trinket.Texture:SetTexture("Interface\\Icons\\inv_jewelry_trinketpvp_02")
            frame.Trinket.Cooldown:SetCooldown(currTime, math.random(20, 60))

            frame.Racial.Texture:SetTexture("Interface\\Icons\\ability_ambush")
            frame.Racial.Cooldown:SetCooldown(currTime, math.random(20, 60))

            local color = RAID_CLASS_COLORS["DRUID"]
            if (db.profile.classColors) then
                frame.HealthBar:SetStatusBarColor(color.r, color.g, color.b, 1)
            else
                frame.HealthBar:SetStatusBarColor(0, 1, 0, 1)
            end
            frame.PowerBar:SetStatusBarColor(0, 0, 1, 1)

            frame:FindDR("SPELL_AURA_APPLIED_DUMMY", 10890)
            frame:FindDR("SPELL_AURA_APPLIED_DUMMY", 28271) -- poly icon
            frame:FindDR("SPELL_AURA_APPLIED_DUMMY", 8643)

            frame.CastBar.fadeOut = nil
            frame.CastBar:Show()
            frame.CastBar:SetAlpha(1)
            frame.CastBar.Icon:SetTexture("Interface\\Icons\\Spell_nature_resistnature")
            frame.CastBar.Text:SetText("Regrowth")
            frame.CastBar:SetStatusBarColor(1, 0.7, 0, 1)

            frame.hideStatusText = false
            frame:SetStatusText("player")
            frame:UpdateStatusTextVisible()

        elseif (i == 4) then

            local frame = self["arena" .. i]
            frame:Show()
            frame:SetAlpha(1)

            frame.HealthBar:SetMinMaxValues(0, 100)
            frame.HealthBar:SetValue(100)

            frame.PowerBar:SetMinMaxValues(0, 100)
            frame.PowerBar:SetValue(100)

            local petFrame = _G["ArenaEnemyFrame" .. i .. "PetFrame"]
            if petFrame and db.profile.petFrames then
                petFrame:ClearAllPoints()
                petFrame:SetParent(frame)
                petFrame:SetPoint("BOTTOMRIGHT", frame, db.profile.petScale.posX, db.profile.petScale.posY)
                petFrame:Show()
                petFrame.healthbar:SetStatusBarColor(0,1,0)
                petFrame.portrait:SetTexture("Interface\\Icons\\spell_shadow_summonfelhunter")
            end

            if db.profile.specIcons then
                if ( frame.parent.portraitClassIcon ) then
                    SetPortraitToTexture(frame.ClassIcon, "Interface\\Icons\\spell_shadow_deathcoil");
                else
                    frame.ClassIcon:SetTexture("Interface\\Icons\\spell_shadow_deathcoil");
                end
            else
                frame.ClassIcon:SetTexture(iconPath, true);
                frame.ClassIcon:SetTexCoord(unpack(classIcons["WARLOCK"]));

                if ( frame.parent.portraitSpecIcon ) then
                    SetPortraitToTexture(frame.SpecIcon.Texture, "Interface\\Icons\\spell_shadow_deathcoil");
                else
                    frame.SpecIcon.Texture:SetTexture("Interface\\Icons\\spell_shadow_deathcoil");
                end
                frame.SpecIcon:Show()
            end

            frame.ClassIconCooldown:SetCooldown(GetTime(), math.random(20, 60))
            if db.profile.arenaNames then
                frame.Name:SetText("arena" .. i)
            else
                frame.Name:SetText("Drakedog")
            end
            frame.Name:SetShown(db.profile.showNames)

            frame.Trinket.Texture:SetTexture("Interface\\Icons\\inv_jewelry_trinketpvp_02")
            frame.Trinket.Cooldown:SetCooldown(currTime, math.random(20, 60))

            frame.Racial.Texture:SetTexture("Interface\\Icons\\spell_nature_sleep")
            frame.Racial.Cooldown:SetCooldown(currTime, math.random(20, 60))

            local color = RAID_CLASS_COLORS["WARLOCK"]
            if (db.profile.classColors) then
                frame.HealthBar:SetStatusBarColor(color.r, color.g, color.b, 1)
            else
                frame.HealthBar:SetStatusBarColor(0, 1, 0, 1)
            end
            frame.PowerBar:SetStatusBarColor(0, 0, 1, 1)

            frame:FindDR("SPELL_AURA_APPLIED_DUMMY", 10890)
            frame:FindDR("SPELL_AURA_APPLIED_DUMMY", 28271) -- poly icon
            frame:FindDR("SPELL_AURA_APPLIED_DUMMY", 8643)

            frame.CastBar.fadeOut = nil
            frame.CastBar:Show()
            frame.CastBar:SetAlpha(1)
            frame.CastBar.Icon:SetTexture("Interface\\Icons\\spell_shadow_deathscream")
            frame.CastBar.Text:SetText("Howl of Terror")
            frame.CastBar:SetStatusBarColor(1, 0.7, 0, 1)

            frame.hideStatusText = false
            frame:SetStatusText("player")
            frame:UpdateStatusTextVisible()

        else

            local frame = self["arena" .. i]
            frame:Show()
            frame:SetAlpha(1)

            frame.HealthBar:SetMinMaxValues(0, 100)
            frame.HealthBar:SetValue(100)

            frame.PowerBar:SetMinMaxValues(0, 100)
            frame.PowerBar:SetValue(100)

            if db.profile.specIcons then
                if ( frame.parent.portraitClassIcon ) then
                    SetPortraitToTexture(frame.ClassIcon, "Interface\\Icons\\ability_warrior_savageblow");
                else
                    frame.ClassIcon:SetTexture("Interface\\Icons\\ability_warrior_savageblow");
                end
            else
                frame.ClassIcon:SetTexture(iconPath, true);
                frame.ClassIcon:SetTexCoord(unpack(classIcons["WARRIOR"]));

                if ( frame.parent.portraitSpecIcon ) then
                    SetPortraitToTexture(frame.SpecIcon.Texture, "Interface\\Icons\\ability_warrior_savageblow");
                else
                    frame.SpecIcon.Texture:SetTexture("Interface\\Icons\\ability_warrior_savageblow");
                end
                frame.SpecIcon:Show()
            end

            frame.ClassIconCooldown:SetCooldown(GetTime(), math.random(20, 60))
            if db.profile.arenaNames then
                frame.Name:SetText("arena" .. i)
            else
                frame.Name:SetText("Gforce")
            end
            frame.Name:SetShown(db.profile.showNames)

            frame.Trinket.Texture:SetTexture("Interface\\Icons\\inv_jewelry_trinketpvp_02")
            frame.Trinket.Cooldown:SetCooldown(currTime, math.random(20, 60))

            frame.Racial.Texture:SetTexture("Interface\\Icons\\ability_rogue_trip")
            frame.Racial.Cooldown:SetCooldown(currTime, math.random(20, 60))

            local color = RAID_CLASS_COLORS["WARRIOR"]
            if (db.profile.classColors) then
                frame.HealthBar:SetStatusBarColor(color.r, color.g, color.b, 1)
            else
                frame.HealthBar:SetStatusBarColor(0, 1, 0, 1)
            end
            frame.PowerBar:SetStatusBarColor(170 / 255, 10 / 255, 10 / 255)

            frame:FindDR("SPELL_AURA_APPLIED_DUMMY", 10890)
            frame:FindDR("SPELL_AURA_APPLIED_DUMMY", 28271) -- poly icon
            frame:FindDR("SPELL_AURA_APPLIED_DUMMY", 8643)

            frame.CastBar.fadeOut = nil
            frame.CastBar:Show()
            frame.CastBar:SetAlpha(1)
            frame.CastBar.Icon:SetTexture("Interface\\Icons\\ability_warrior_decisivestrike")
            frame.CastBar.Text:SetText("Slam")
            frame.CastBar:SetStatusBarColor(1, 0.7, 0, 1)

            frame.hideStatusText = false
            frame:SetStatusText("player")
            frame:UpdateStatusTextVisible()
        end
    end
end
