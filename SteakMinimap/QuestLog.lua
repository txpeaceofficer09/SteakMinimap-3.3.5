local QUEST_LIST_WIDTH = (MapFrame and MapFrame:GetWidth() > 0) and MapFrame:GetWidth() or 312
local QUEST_SPACING = 10
local ITEM_BUTTON_SIZE = 22

local _, class = UnitClass("player")
local borderColor = RAID_CLASS_COLORS[class]

local QuestListParent = CreateFrame("ScrollFrame", "SteakQuestListParent", UIParent)
QuestListParent:SetSize(QUEST_LIST_WIDTH, GetScreenHeight() / 3)
QuestListParent:SetPoint("BOTTOMLEFT", MapFrame, "TOPLEFT", 0, 10)
--[[
QuestListParent.bg = QuestListParent:CreateTexture(nil, "BACKGROUND")
QuestListParent.bg:SetAllPoints()
QuestListParent.bg:SetTexture(0, 0, 0, 0.5)
]]

local QuestList = CreateFrame("Frame", "SteakQuestList", QuestListParent)

QuestList:SetSize(QUEST_LIST_WIDTH, 1)
--QuestList:SetPoint("BOTTOMLEFT", MapFrame, "TOPLEFT", 0, 10)
QuestListParent:SetScrollChild(QuestList)
QuestList.rows = {}

local header = CreateFrame("Frame", "SteakQuestHeader", QuestListParent)

header:SetPoint("BOTTOMLEFT", QuestListParent, "TOPLEFT", 0, 4)
header:SetPoint("BOTTOMRIGHT", QuestListParent, "TOPRIGHT", 0, 4)
header:SetHeight(20)
header:SetBackdrop( { bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Buttons\\WHITE8x8", tile = true, tileSize = 32, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 } } )
header:SetBackdropColor(0.2, 0.2, 0.2, 1)
header:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, 1)

local label = header:CreateFontString(nil, "OVERLAY")
label:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 10, "OUTLINE")
label:SetPoint("LEFT", header, "LEFT", 2, 0)
header.label = label

local QuestToggle = CreateFrame("Button", "SteakQuestToggle", UIParent)
QuestToggle:SetSize(20, 20)
QuestToggle:SetPoint("RIGHT", header, "RIGHT", -5, 0)

QuestToggle.text = QuestToggle:CreateFontString(nil, "OVERLAY")
QuestToggle.text:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 10, "OUTLINE")
QuestToggle.text:SetPoint("CENTER")
QuestToggle.text:SetText("-")

QuestToggle:SetScript("OnClick", function(self, button)
	self.expanded = self.expanded or true
	
	if self.expanded == true then
		self.text:SetText("+")
		self.expanded = nil
		QuestList:SetHeight(GetScreenHeight() / 3)
	else
		self.text:SetText("-")
		self.expanded = true
		QuestList:SetHeight(0)
	end
end)

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

	local numQuests = 0
	local numMaxQuests = MAX_QUESTLOG_QUESTS or 25

	for i = 1, GetNumQuestLogEntries() do
		local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(i)
		if title and not isHeader then numQuests = numQuests + 1 end
	end

	header.label:SetText(("%d / %d"):format(numQuests, numMaxQuests))

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
                
				row.title = row:CreateFontString(nil, "OVERLAY")
				row.title:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 10, "OUTLINE")
				--row.title:SetPoint("TOPLEFT", row, "TOPLEFT", 5, -2)
				row.title:SetPoint("TOPLEFT", row, "TOPLEFT", 25, -2)
				row.title:SetJustifyH("LEFT")
                
				row.obj = row:CreateFontString(nil, "OVERLAY")
				row.obj:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 8, "OUTLINE")
				row.obj:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 10, -4)
				--row.obj:SetWidth(QUEST_LIST_WIDTH - 30)
				row.obj:SetWidth(QUEST_LIST_WIDTH - 50)
				row.obj:SetJustifyH("LEFT")

				row.icon = row:CreateTexture(nil, "ARTWORK")
				row.icon:SetSize(24, 24)
				row.icon:SetTexture("Interface\\WorldMap\\UI-QuestPoi-NumberIcons.tga")
				row.icon:SetTexCoord(0.875, 1, 0.875, 1)
				row.icon:SetPoint("RIGHT", row.title, "LEFT", -5, 0)

				row.status = row:CreateFontString(nil, "OVERLAY")
				row.status:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 8, "OUTLINE")
				row.status:SetPoint("CENTER", row.icon, "CENTER", 0, 0)
				row.status:SetTextColor(1, 1, 0)
                
				row.item = CreateItemButton(row)
				QuestList.rows[rowIndex] = row
			end

			row.status:SetText(isComplete and "?" or rowIndex)

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
				row:SetPoint("TOPLEFT", QuestList, "TOPLEFT", 0, 0)
			else
				row:SetPoint("TOPLEFT", QuestList.rows[rowIndex-1], "BOTTOMLEFT", 0, -QUEST_SPACING)
			end

			row:Show()
			rowIndex = rowIndex + 1
		end

		local height = 0
		for _, row in ipairs(QuestList.rows) do
			if row:IsShown() then height = height + row:GetHeight() end
		end

		QuestList:SetHeight(height)
		local maxHeight = GetScreenHeight() / 3

		QuestListParent:SetHeight(math.min(height+QUEST_SPACING+5, maxHeight))
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

QuestListParent:EnableMouseWheel(true)
QuestListParent:SetScript("OnMouseWheel", function(self, delta)
	local current = self:GetVerticalScroll()
	local step = 30
	local max = self:GetVerticalScrollRange()
	local newScroll = current - (delta * step)

	newScroll = math.max(0, math.min(newScroll, max))

	self:SetVerticalScroll(newScroll)
end)
