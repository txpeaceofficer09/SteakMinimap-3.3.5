local f = CreateFrame("Frame", nil, UIParent)

local questDots = {}

local function MapFrame_UpdateQuestIcons()
	--if not WorldMapFrame:IsShown() then SetMapToCurrentZone() end

	local mapW = MapFrameSC:GetWidth()
	local mapH = MapFrameSC:GetHeight()

	for _, poi in ipairs(questDots) do poi:Hide() end
	
	local index = 1
	
	--for i=1, GetNumQuestLogEntries() do
	for i=GetNumQuestLogEntries(),1,-1 do
		local poi = questDots[i]
		
		if not poi then
			poi = CreateFrame("Frame", nil, MapFrameSC)

			poi:SetSize(24, 24)
			poi:SetFrameLevel(Minimap:GetFrameLevel() + 1)

			local tex = poi:CreateTexture(nil, "BACKGROUND")
			tex:SetAllPoints(poi)
			tex:SetTexture("Interface\\WorldMap\\UI-QuestPoi-NumberIcons.tga")
			tex:SetTexCoord(0.875, 1, 0.875, 1)
			poi.tex = tex
			
			local num = poi:CreateFontString(nil, "OVERLAY")
			num:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 8, "OUTLINE")
			num:SetPoint("CENTER", poi, "CENTER", 0, 0)
			num:SetTextColor(1, 1, 0)
			poi.num = num

			poi:EnableMouse(true)

			poi:SetScript("OnEnter", function(self)
				if self.questID then
					for i=1, GetNumQuestLogEntries() do
						local name, _, _, _, _, _, _, _, questID = GetQuestLogTitle(i)
						
						if questID == self.questID then
							GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
							GameTooltip:SetText(name)
							for j=1,GetNumQuestLeaderBoards(i) do
								local t, _, finished = GetQuestLogLeaderBoard(j, i)
								if finished then
									GameTooltip:AddLine(("|cff00ff00%s|r"):format(t))
								else
									GameTooltip:AddLine(("|cffffffff%s|r"):format(t))
								end
							end
							GameTooltip:Show()
						end
					end
				end
			end)
   
   			poi:SetScript("OnLeave", function(self)
   				GameTooltip:Hide()
   			end)
			
			questDots[i] = poi
		end
		
		local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(i)

		if not isHeader then
			local _, posX, posY, objective = QuestPOIGetIconInfo(questID)

			poi.num:SetText(isComplete and "?" or index)

			if posX and posX > 0 then
				--[[
				if isComplete then
					poi.num:SetText("?")
				else
					poi.num:SetText(index)
				end
				]]

				local finalX = posX * mapW
				local finalY = -posY * mapH

				questDots[i].x = finalX
				questDots[i].y = finalY

				poi:ClearAllPoints()
				poi:SetPoint("CENTER", MapFrameSC, "TOPLEFT", finalX, finalY)

				poi.questID = questID
				poi.num:SetText(index)
				
				poi:Show()
				index = index + 1
			end
		end
	end
end

local function OnEvent(self, event, ...)
	if event == "QUEST_LOG_UPDATE" or event == "QUEST_POI_UPDATE" or event == "UNIT_QUEST_LOG_CHANGED" then
		if not InCombatLockdown() and not WorldMapFrame:IsShown() and not QuestLogFrame:IsShown() then
			local mapSize = WORLDMAP_SETTINGS.size
			WORLDMAP_SETTINGS.size = WORLDMAP_WINDOWED_SIZE
			ShowUIPanel(WorldMapFrame)
			WorldMapFrame:ClearAllPoints()
			WorldMapFrame:SetClampedToScreen(false)
			WorldMapFrame:SetPoint("RIGHT", UIParent, "LEFT", -1000, 0)
			HideUIPanel(WorldMapFrame)
		end
	end		

	MapFrame_UpdateQuestIcons()
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("WORLD_MAP_UPDATE")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_INDOORS")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("CLOSE_WORLD_MAP")
f:RegisterEvent("WORLD_MAP_NAME_UPDATE")
f:RegisterEvent("QUEST_LOG_UPDATE")
f:RegisterEvent("QUEST_POI_UPDATE")
f:RegisterEvent("UNIT_QUEST_LOG_CHANGED")

f:SetScript("OnEvent", OnEvent)
