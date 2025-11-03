local DRData = LibStub("DRList-1.0")

local function defaultCategories()
    local categories = {}
    local indexList = {}
    
    
    if not sArenaMixin.drList then
        print("ERROR: sArenaMixin.drList no existe")
        return {}
    end
    
    
    for spellName, data in pairs(sArenaMixin.drList) do
        local category = type(data) == "table" and data.category or data
        local found = false
        for _, v in ipairs(indexList) do
            if v.category == category then
                found = true
                break
            end
        end
        if not found then
            tinsert(indexList, { 
                spellName = spellName, 
                category = category,
                iconId = type(data) == "table" and data.iconId or nil
            })
        end
    end
    
    
    table.sort(indexList, function(a, b)
        return a.category < b.category
    end)
    
    
    for _, v in pairs(indexList) do
        if not categories[v.category] then
            local spellTexture
            
            
            if DRData and DRData.GetCategoryIcon then
                spellTexture = DRData:GetCategoryIcon(v.category)
            end
            
            
            if not spellTexture and v.iconId then
                spellTexture = select(3, GetSpellInfo(v.iconId))
            end
            
            
            if not spellTexture then
                spellTexture = select(3, GetSpellInfo(v.spellName))
            end
            
            
            if not spellTexture then
                for altSpellName, altData in pairs(sArenaMixin.drList) do
                    local altCategory = type(altData) == "table" and altData.category or altData
                    if altCategory == v.category then
					
                        if type(altData) == "table" and altData.iconId then
                            spellTexture = select(3, GetSpellInfo(altData.iconId))
                        end
                        
                        if not spellTexture then
                            spellTexture = select(3, GetSpellInfo(altSpellName))
                        end
                        if spellTexture then
                            break
                        end
                    end
                end
            end
            
            categories[v.category] = {
                enabled = true,
                forceIcon = false,
                icon = spellTexture or "Interface\\Icons\\INV_Misc_QuestionMark"
            }
        end
    end
    
    
    local categoriesL = {}
    local l = 1
    for categoryName, _ in pairs(categories) do
        categoriesL[l] = categoryName
        l = l + 1
    end
    
    return categoriesL, categories
end

sArenaMixin.drCategories = {}
sArenaMixin.defaultSettings.profile.drCategories = {}

local categories, categoryData = defaultCategories()

for _, category in ipairs(categories) do
    table.insert(sArenaMixin.drCategories, tostring(category))
    
    sArenaMixin.defaultSettings.profile.drCategories[category] = categoryData[category]
end

local drCategories = sArenaMixin.drCategories
local drTime = 18
local severityColor = {
    [1] = { 0, 1, 0, 1 },
    [2] = { 1, 1, 0, 1 },
    [3] = { 1, 0, 0, 1 },
}

local function getDiminishText(dr)
    if dr == 1 then
        return "Â½"
    elseif dr == 2 then
        return "Â¼"
    else
        return "Ã¸"
    end
end

local GetTime = GetTime


local function getSpellTexture(spellName, category)
    local texture
    
    
    if DRData and DRData.GetCategoryIcon then
        texture = DRData:GetCategoryIcon(category)
        if texture then return texture end
    end
    
    
    local spellData = sArenaMixin.drList[spellName]
    if type(spellData) == "table" and spellData.iconId then
        texture = select(3, GetSpellInfo(spellData.iconId))
        if texture then return texture end
    end
    
    
    texture = select(3, GetSpellInfo(spellName))
    if texture then return texture end
    
    return nil
end

function sArenaFrameMixin:FindDR(combatEvent, spellParam)
    
    local spellName = spellParam
    if type(spellParam) == "number" then
        spellName = GetSpellInfo(spellParam)
    end
    
    if not spellName then
        return
    end
    
    
    local spellData = sArenaMixin.drList[spellName]
    if not spellData then
        return
    end
    
    
    local category = type(spellData) == "table" and spellData.category or spellData
    
    
    local categorySettings = self.parent.db.profile.drCategories[category]
    if not categorySettings then
        return
    end
    
    
    if type(categorySettings) == "table" and not categorySettings.enabled then
        return
    end

    local frame = self[category]
    local currTime = GetTime()

    if not frame then
        return
    end

    frame.cooldownData = frame.cooldownData or {}

    if (combatEvent == "SPELL_AURA_REMOVED" or combatEvent == "SPELL_AURA_BROKEN") then
        
        frame:Show()
        frame.Cooldown:SetCooldown(currTime, drTime)

        frame.cooldownData.startTime = currTime
        frame.cooldownData.duration = drTime
        return
    elseif (combatEvent == "SPELL_AURA_APPLIED" or combatEvent == "SPELL_AURA_REFRESH") then
        
        frame:Show()
        frame.Cooldown:Clear()
        
        frame.cooldownData.startTime = 0
        frame.cooldownData.duration = 0
    elseif (combatEvent == "SPELL_AURA_APPLIED_DUMMY") then
        frame:Show()
        frame.Cooldown:SetCooldown(currTime, drTime)

        frame.cooldownData.startTime = currTime
        frame.cooldownData.duration = drTime
    end

    
    local spellTexture = getSpellTexture(spellName, category)
    
    
    if spellTexture then
        frame.Icon:SetTexture(spellTexture)
    else
        if type(categorySettings) == "table" and categorySettings.icon then
            frame.Icon:SetTexture(categorySettings.icon)
        else
            frame.Icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
    end
    
    frame.Border:SetVertexColor(unpack(severityColor[frame.severity]))
    
    if self.parent.db.profile.drText then
        if not frame.Text then
            frame.Text = frame.Cooldown:CreateFontString(nil, "OVERLAY")
            frame.Text:SetFont("Interface\\AddOns\\sArena\\ARIALN.ttf", 8, "OUTLINE")
            frame.Text:SetJustifyH("CENTER")
            frame.Text:SetPoint("CENTER", frame, "CENTER", 0, -8)
        end
        frame.Text:SetText(getDiminishText(frame.severity))
        frame.Text:SetTextColor(unpack(severityColor[frame.severity]))
    end

    frame.severity = frame.severity + 1
    if frame.severity > 3 then
        frame.severity = 3
    end
end

function sArenaFrameMixin:UpdateDRPositions()
    local layoutdb = self.parent.layoutdb
    local numActive = 0
    local frame, prevFrame
    local spacing = layoutdb.dr.spacing
    local growthDirection = layoutdb.dr.growthDirection

    for i = 1, #drCategories do
        frame = self[drCategories[i]]

        if frame and frame:IsShown() then
            frame:ClearAllPoints()
            if numActive == 0 then
                frame:SetPoint("CENTER", self, "CENTER", layoutdb.dr.posX, layoutdb.dr.posY)
            else
                if growthDirection == 4 then
                    frame:SetPoint("RIGHT", prevFrame, "LEFT", -spacing, 0)
                elseif growthDirection == 3 then
                    frame:SetPoint("LEFT", prevFrame, "RIGHT", spacing, 0)
                elseif growthDirection == 1 then
                    frame:SetPoint("TOP", prevFrame, "BOTTOM", 0, -spacing)
                elseif growthDirection == 2 then
                    frame:SetPoint("BOTTOM", prevFrame, "TOP", 0, spacing)
                end
            end
            numActive = numActive + 1
            prevFrame = frame
        end
    end
end

function sArenaFrameMixin:ResetDR()
    for i = 1, #drCategories do
        local category = drCategories[i]
        if self[category] and self[category].Cooldown then
            self[category].Cooldown:Clear()
            self[category]:Hide()
        end
    end
end