--[[
local function GetQuestiePositions(questID)
    local q = QuestieDB.questData[questID]
    if not q then return {} end

    local results = {}

    -- 1. Quest starters (NPCs)
    if q[2] then
        for _, group in ipairs(q[2]) do
            for _, npcID in ipairs(group) do
                local npc = QuestieDB.npcData[npcID]
                if npc and npc.spawns then
                    for mapID, coords in pairs(npc.spawns) do
                        for _, loc in ipairs(coords) do
                            table.insert(results, {
                                mapID = mapID,
                                x = loc[1] / 100,
                                y = loc[2] / 100,
                                type = "starter",
                                name = npc.name,
                            })
                        end
                    end
                end
            end
        end
    end

    -- 2. Quest finishers
    if q[3] then
        for _, group in ipairs(q[3]) do
            for _, npcID in ipairs(group) do
                local npc = QuestieDB.npcData[npcID]
                if npc and npc.spawns then
                    for mapID, coords in pairs(npc.spawns) do
                        for _, loc in ipairs(coords) do
                            table.insert(results, {
                                mapID = mapID,
                                x = loc[1] / 100,
                                y = loc[2] / 100,
                                type = "finisher",
                                name = npc.name,
                            })
                        end
                    end
                end
            end
        end
    end

    -- 3. Objective NPCs/objects
    local objectives = q[10]
    if objectives then
        for _, objGroup in ipairs(objectives) do
            if objGroup then
                for _, obj in ipairs(objGroup) do
                    for _, id in ipairs(obj) do
                        -- NPC objective
                        local npc = QuestieDB.npcData[id]
                        if npc and npc.spawns then
                            for mapID, coords in pairs(npc.spawns) do
                                for _, loc in ipairs(coords) do
                                    table.insert(results, {
                                        mapID = mapID,
                                        x = loc[1] / 100,
                                        y = loc[2] / 100,
                                        type = "objective",
                                        name = npc.name,
                                    })
                                end
                            end
                        end

                        -- Object objective
                        local obj = QuestieDB.objectData[id]
                        if obj and obj.spawns then
                            for mapID, coords in pairs(obj.spawns) do
                                for _, loc in ipairs(coords) do
                                    table.insert(results, {
                                        mapID = mapID,
                                        x = loc[1] / 100,
                                        y = loc[2] / 100,
                                        type = "objective",
                                        name = obj.name,
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return results
end

local function GetQuestiePOIsForMap(mapID)
    local pois = {}

    for questID, q in pairs(QuestieDB.questData) do
        -- skip completed quests
        if not IsQuestFlaggedCompleted(questID) then

            -- skip wrong faction
            local factionMask = q[6]
            if factionMask == nil or Questie:IsCorrectFaction(factionMask) then

                -- get all positions
                local positions = GetQuestiePositions(questID)

                for _, pos in ipairs(positions) do
                    if pos.mapID == mapID then
                        table.insert(pois, pos)
                    end
                end
            end
        end
    end

    return pois
end

local function MapFrame_UpdateQuestiePOIs()
	local mapID = GetCurrentMapAreaID()
	local pois = GetQuestiePOIsForMap(mapID)

	for i, poi in ipairs(pois) do
		local icon = questieIcons[i]
		if not icon then
			icon = CreateFrame("Frame", nil, MapFrameSC)
			icon:SetSize(20, 20)

			local tex = icon:CreateTexture(nil, "OVERLAY")
			tex:SetAllPoints()
			tex:SetTexture("Interface\\WorldMap\\UI-QuestPoi-NumberIcons")
			tex:SetTexCoord(0.625, 0.75, 0.875, 1) -- yellow !
			icon.tex = tex

			icon:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:AddLine(poi.name)
				GameTooltip:AddLine("Quest ID: " .. poi.questID)
				GameTooltip:Show()
			end)

			icon:SetScript("OnLeave", function() GameTooltip:Hide() end)

			questieIcons[i] = icon
		end

        icon:ClearAllPoints()
        icon:SetPoint("CENTER", MapFrameSC, "TOPLEFT",
            poi.x * MapFrameSC:GetWidth(),
            -poi.y * MapFrameSC:GetHeight()
        )

        icon:Show()
    end
end
]]

--[[
local MFSC_QuestieIcons = {}

local function MFSC_HideAllQuestieIcons()
    for _, icon in ipairs(MFSC_QuestieIcons) do
        icon:Hide()
    end
end

local function MFSC_GetCurrentMapID()
    SetMapToCurrentZone()
    return GetCurrentMapAreaID()
end

local function MFSC_GetQuestiePOIsForMap(mapID)
    local pois = {}

    for questID, q in pairs(QuestieDB.questData) do
        local isCompleted = IsQuestFlaggedCompleted(questID)
        local inLog = C_QuestLog.IsOnQuest(questID)

        -- skip completed quests entirely
        if not isCompleted then

            -- faction filter
            local factionMask = q[6]
            if Questie:IsCorrectFaction(factionMask) then

                -- 1. Quest starters (always shown)
                local starters = q[2]
                if starters then
                    for _, group in ipairs(starters) do
                        for _, npcID in ipairs(group) do
                            local npc = QuestieDB.npcData[npcID]
                            if npc and npc.spawns and npc.spawns[mapID] then
                                for _, loc in ipairs(npc.spawns[mapID]) do
                                    table.insert(pois, {
                                        questID = questID,
                                        name = npc.name,
                                        x = loc[1] / 100,
                                        y = loc[2] / 100,
                                        type = "starter",
                                    })
                                end
                            end
                        end
                    end
                end

                -- 2. Finishers + objectives ONLY if quest is in log
                if inLog then
                    -- finishers
                    local finishers = q[3]
                    if finishers then
                        for _, group in ipairs(finishers) do
                            for _, npcID in ipairs(group) do
                                local npc = QuestieDB.npcData[npcID]
                                if npc and npc.spawns and npc.spawns[mapID] then
                                    for _, loc in ipairs(npc.spawns[mapID]) do
                                        table.insert(pois, {
                                            questID = questID,
                                            name = npc.name,
                                            x = loc[1] / 100,
                                            y = loc[2] / 100,
                                            type = "finisher",
                                        })
                                    end
                                end
                            end
                        end
                    end

                    -- objectives (NPCs/objects)
                    local objectives = q[10]
                    if objectives then
                        for _, objGroup in ipairs(objectives) do
                            if objGroup then
                                for _, obj in ipairs(objGroup) do
                                    for _, id in ipairs(obj) do
                                        -- NPC objective
                                        local npc = QuestieDB.npcData[id]
                                        if npc and npc.spawns and npc.spawns[mapID] then
                                            for _, loc in ipairs(npc.spawns[mapID]) do
                                                table.insert(pois, {
                                                    questID = questID,
                                                    name = npc.name,
                                                    x = loc[1] / 100,
                                                    y = loc[2] / 100,
                                                    type = "objective",
                                                })
                                            end
                                        end

                                        -- Object objective
                                        local objData = QuestieDB.objectData[id]
                                        if objData and objData.spawns and objData.spawns[mapID] then
                                            for _, loc in ipairs(objData.spawns[mapID]) do
                                                table.insert(pois, {
                                                    questID = questID,
                                                    name = objData.name,
                                                    x = loc[1] / 100,
                                                    y = loc[2] / 100,
                                                    type = "objective",
                                                })
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end -- inLog
            end -- faction
        end -- not completed
    end -- for questID

    return pois
end

function MapFrameSC_UpdateQuestiePOIs()
    MFSC_HideAllQuestieIcons()

    local mapID = MFSC_GetCurrentMapID()
    if not mapID then return end

    local pois = MFSC_GetQuestiePOIsForMap(mapID)
    local mapW = MapFrameSC:GetWidth()
    local mapH = MapFrameSC:GetHeight()

    for i, poi in ipairs(pois) do
        local icon = MFSC_QuestieIcons[i]
        if not icon then
            icon = CreateFrame("Frame", nil, MapFrameSC)
            icon:SetSize(20, 20)

            local tex = icon:CreateTexture(nil, "OVERLAY")
            tex:SetAllPoints()
            icon.tex = tex

            icon:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(poi.name)
                GameTooltip:AddLine("Quest ID: " .. poi.questID)
                GameTooltip:Show()
            end)

            icon:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            MFSC_QuestieIcons[i] = icon
        end

        -- choose icon texture based on type
        if poi.type == "starter" then
            icon.tex:SetTexture("Interface\\WorldMap\\UI-QuestPoi-NumberIcons")
            icon.tex:SetTexCoord(0.625, 0.75, 0.875, 1)
        elseif poi.type == "finisher" then
            icon.tex:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon")
        else
            icon.tex:SetTexture("Interface\\WorldMap\\UI-WorldMap-QuestIcon")
        end

        icon:ClearAllPoints()
        icon:SetPoint("CENTER", MapFrameSC, "TOPLEFT",
            poi.x * mapW,
            -poi.y * mapH
        )

        icon:Show()
    end
end

local MFSC_QuestieEvents = CreateFrame("Frame")

MFSC_QuestieEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
MFSC_QuestieEvents:RegisterEvent("ZONE_CHANGED_NEW_AREA")
MFSC_QuestieEvents:RegisterEvent("ZONE_CHANGED")
MFSC_QuestieEvents:RegisterEvent("QUEST_LOG_UPDATE")

MFSC_QuestieEvents:SetScript("OnEvent", function(self, event)
    MapFrameSC_UpdateQuestiePOIs()
end)
]]

-- ############################################################
-- MapFrameSC + Questie quest POIs
-- Starters for all uncompleted quests
-- Finishers/Objectives only if quest is in log
-- WotLK API only
-- ############################################################

local MFSC_QuestieIcons = {}

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local function MFSC_HideAllQuestieIcons()
    for _, icon in ipairs(MFSC_QuestieIcons) do
        icon:Hide()
    end
end

local function MFSC_GetCurrentMapID()
    SetMapToCurrentZone()
    return GetCurrentMapAreaID()
end

local function MFSC_IsQuestInLog(questID)
    for i = 1, GetNumQuestLogEntries() do
        local _, _, _, _, _, _, _, id = GetQuestLogTitle(i)
        if id == questID then
            return true
        end
    end
    return false
end

---------------------------------------------------------------
-- Core: Build POIs for a given mapID from Questie
---------------------------------------------------------------
local function MFSC_GetQuestiePOIsForMap(mapID)
    local pois = {}

    if not QuestieDB or not QuestieDB.questData or not QuestieDB.npcData then
        return pois
    end

    for questID, q in pairs(QuestieDB.questData) do
        local isCompleted = IsQuestFlaggedCompleted(questID)
        local inLog = MFSC_IsQuestInLog(questID)

        if not isCompleted then
            local factionMask = q[6]
            if not Questie or not Questie.IsCorrectFaction or Questie:IsCorrectFaction(factionMask) then

                ---------------------------------------------------
                -- 1. Quest starters (always shown if uncompleted)
                ---------------------------------------------------
                local starters = q[2]
                if starters then
                    for _, group in ipairs(starters) do
                        for _, npcID in ipairs(group) do
                            local npc = QuestieDB.npcData[npcID]
                            if npc and npc.spawns and npc.spawns[mapID] then
                                for _, loc in ipairs(npc.spawns[mapID]) do
                                    table.insert(pois, {
                                        questID = questID,
                                        name    = npc.name,
                                        x       = loc[1] / 100,
                                        y       = loc[2] / 100,
                                        type    = "starter",
                                    })
                                end
                            end
                        end
                    end
                end

                ---------------------------------------------------
                -- 2. Finishers + objectives (only if in quest log)
                ---------------------------------------------------
                if inLog then
                    -- Finishers
                    local finishers = q[3]
                    if finishers then
                        for _, group in ipairs(finishers) do
                            for _, npcID in ipairs(group) do
                                local npc = QuestieDB.npcData[npcID]
                                if npc and npc.spawns and npc.spawns[mapID] then
                                    for _, loc in ipairs(npc.spawns[mapID]) do
                                        table.insert(pois, {
                                            questID = questID,
                                            name    = npc.name,
                                            x       = loc[1] / 100,
                                            y       = loc[2] / 100,
                                            type    = "finisher",
                                        })
                                    end
                                end
                            end
                        end
                    end

                    -- Objectives (NPCs/objects)
                    local objectives = q[10]
                    if objectives then
                        for _, objGroup in ipairs(objectives) do
                            if objGroup then
                                for _, obj in ipairs(objGroup) do
                                    for _, id in ipairs(obj) do
                                        -- NPC objective
                                        local npc = QuestieDB.npcData[id]
                                        if npc and npc.spawns and npc.spawns[mapID] then
                                            for _, loc in ipairs(npc.spawns[mapID]) do
                                                table.insert(pois, {
                                                    questID = questID,
                                                    name    = npc.name,
                                                    x       = loc[1] / 100,
                                                    y       = loc[2] / 100,
                                                    type    = "objective",
                                                })
                                            end
                                        end

                                        -- Object objective
                                        if QuestieDB.objectData then
                                            local objData = QuestieDB.objectData[id]
                                            if objData and objData.spawns and objData.spawns[mapID] then
                                                for _, loc in ipairs(objData.spawns[mapID]) do
                                                    table.insert(pois, {
                                                        questID = questID,
                                                        name    = objData.name,
                                                        x       = loc[1] / 100,
                                                        y       = loc[2] / 100,
                                                        type    = "objective",
                                                    })
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end -- inLog
            end -- faction ok
        end -- not completed
    end -- for questID

    return pois
end

---------------------------------------------------------------
-- Public: Update POIs on MapFrameSC
---------------------------------------------------------------
function MapFrameSC_UpdateQuestiePOIs()
    if not MapFrameSC then return end

    MFSC_HideAllQuestieIcons()

    local mapID = MFSC_GetCurrentMapID()
    if not mapID or mapID == 0 then return end

    local pois = MFSC_GetQuestiePOIsForMap(mapID)
    local mapW = MapFrameSC:GetWidth()
    local mapH = MapFrameSC:GetHeight()

    for i, poi in ipairs(pois) do
        local icon = MFSC_QuestieIcons[i]
        if not icon then
            icon = CreateFrame("Frame", nil, MapFrameSC)
            icon:SetSize(18, 18)

            local tex = icon:CreateTexture(nil, "OVERLAY")
            tex:SetAllPoints()
            icon.tex = tex

            icon:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(poi.name or "Unknown")
                if poi.questID then
                    GameTooltip:AddLine("Quest ID: " .. poi.questID, 0.8, 0.8, 0.8)
                end
                if poi.type == "starter" then
                    GameTooltip:AddLine("Quest Start", 0, 1, 0)
                elseif poi.type == "finisher" then
                    GameTooltip:AddLine("Quest Turn-in", 0, 0.75, 1)
                else
                    GameTooltip:AddLine("Quest Objective", 1, 0.82, 0)
                end
                GameTooltip:Show()
            end)

            icon:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            MFSC_QuestieIcons[i] = icon
        end

        -- Choose texture by type
        if poi.type == "starter" then
            icon.tex:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon")
        elseif poi.type == "finisher" then
            icon.tex:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon")
        else
            icon.tex:SetTexture("Interface\\WorldMap\\UI-WorldMap-QuestIcon")
        end

        icon:ClearAllPoints()
        icon:SetPoint("CENTER", MapFrameSC, "TOPLEFT",
            poi.x * mapW,
            -poi.y * mapH
        )

        icon:Show()
    end

    -- hide any leftover icons from previous updates
    for i = #pois + 1, #MFSC_QuestieIcons do
        MFSC_QuestieIcons[i]:Hide()
    end
end

---------------------------------------------------------------
-- Events: keep POIs in sync with world/zone/quest changes
---------------------------------------------------------------
local MFSC_QuestieEvents = CreateFrame("Frame")
MFSC_QuestieEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
MFSC_QuestieEvents:RegisterEvent("ZONE_CHANGED_NEW_AREA")
MFSC_QuestieEvents:RegisterEvent("ZONE_CHANGED")
MFSC_QuestieEvents:RegisterEvent("ZONE_CHANGED_INDOORS")
MFSC_QuestieEvents:RegisterEvent("QUEST_LOG_UPDATE")

MFSC_QuestieEvents:SetScript("OnEvent", function()
    MapFrameSC_UpdateQuestiePOIs()
end)
