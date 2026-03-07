local QUEST_LIST_WIDTH = (MapFrame and MapFrame:GetWidth() > 0) and MapFrame:GetWidth() or 312
local QUEST_SPACING = 10
local ITEM_BUTTON_SIZE = 22

local QuestList = CreateFrame("Frame", "SteakQuestList", UIParent)
QuestList:SetSize(QUEST_LIST_WIDTH, 1)
QuestList:SetPoint("BOTTOMLEFT", MapFrame, "TOPLEFT", 0, 10)
QuestList.rows = {}

local function CreateItemButton(parent)
    local btn = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate")
    btn:SetSize(ITEM_BUTTON_SIZE, ITEM_BUTTON_SIZE)
    btn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -2)
    
    btn.icon = btn:CreateTexture(nil, "BACKGROUND")
    btn.icon:SetAllPoints()
    
    btn:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    
    btn:Hide()
    return btn
end

local function OnEvent(self, event, ...)
	if WatchFrame:IsShown() then WatchFrame:Hide() end
	
	if GetNumRaidMembers() > 0 then
		self:Hide()
	else
		self:Show()
	end

	local currentZone = GetZoneText()
	local lastHeader = ""
    
	for _, row in ipairs(QuestList.rows) do row:Hide() end
	
	local rowIndex = 1
	for i = 1, GetNumQuestLogEntries() do
		local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(i)

		if isHeader then
			lastHeader = title
		elseif lastHeader == currentZone then
			local row = QuestList.rows[rowIndex]

			if not row then
				row = CreateFrame("Frame", nil, QuestList)
				row:SetWidth(QUEST_LIST_WIDTH)
                
				row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				row.title:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 10, "OUTLINED")
				row.title:SetPoint("TOPLEFT", row, "TOPLEFT", 5, -2)
				row.title:SetJustifyH("LEFT")
                
				row.obj = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				row.obj:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 8, "OUTLINED")
				row.obj:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 10, -4)
				row.obj:SetWidth(QUEST_LIST_WIDTH - 30)
				row.obj:SetJustifyH("LEFT")

				row.icon = row:CreateTexture(nil, "ARTWORK")
				row.icon:SetSize(24, 24)
				row.icon:SetTexture("Interface\\WorldMap\\UI-QuestPoi-NumberIcons.tga")
				row.icon:SetTexCoord(0.875, 1, 0.875, 1)
				row.icon:SetPoint("RIGHT", row.title, "LEFT", -10, 0)

				row.status = row:CreateFontString(nil, "OVERLAY")
				row.status:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 8, "OUTLINE")
				row.status:SetPoint("CENTER", row.icon, "CENTER", 0, 0)
				row.status:SetTextColor(1, 1, 0)
                
				row.item = CreateItemButton(row)
				QuestList.rows[rowIndex] = row
			end

			if isComplete then
				row.status:SetText("?")
			else
				row.status:SetText(rowIndex)
			end

			if suggestedGroup > 0 then
				row.title:SetText(format("|cffffd100[%d]|r %s (Group %d)", level, title, suggestedGroup))
			else
				row.title:SetText(format("|cffffd100[%d]|r %s", level, title))
			end
            
			local objText = ""
			for j = 1, GetNumQuestLeaderBoards(i) do
				local t, _, finished = GetQuestLogLeaderBoard(j, i)
				if t then
					local color = finished and "|cff00ff00" or "|cffffffff"
					objText = objText .. color .. "- " .. t .. "|r\n"
				end
			end
			row.obj:SetText(objText)

			local itemLink, itemIcon = GetQuestLogSpecialItemInfo(i)
			if itemLink and not InCombatLockdown() then
				row.item.icon:SetTexture(itemIcon)
				row.item:SetAttribute("type", "item")
				row.item:SetAttribute("item", GetItemInfo(itemLink))
				row.item:Show()
			else
				row.item:Hide()
			end

			local height = row.title:GetHeight() + row.obj:GetHeight() + 10
			row:SetHeight(height)
			row:ClearAllPoints()
            
			if rowIndex == 1 then
				row:SetPoint("BOTTOMLEFT", QuestList, "BOTTOMLEFT", 0, 0)
			else
				row:SetPoint("BOTTOMLEFT", QuestList.rows[rowIndex-1], "TOPLEFT", 0, QUEST_SPACING)
			end

			row:Show()
			rowIndex = rowIndex + 1
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("QUEST_LOG_UPDATE")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UNIT_QUEST_LOG_CHANGED")

f:SetScript("OnEvent", OnEvent)

WatchFrame:HookScript("OnShow", function(self) self:Hide() end)
