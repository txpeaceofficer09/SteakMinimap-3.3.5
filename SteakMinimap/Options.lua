SteakMapConfigDB = SteakMapConfigDB or {
	showRepair = true,
	showReagent = true,
	showFlight = true,
	showQuestPOI = true,
	showPOI = true
}

function SteakMap_UpdateAll()
	if SteakMap_UpdateFlightPaths then SteakMap_UpdateFlightPaths() end
	if SteakMap_UpdateRepairVendors then SteakMap_UpdateRepairVendors() end
	if SteakMap_UpdateReagentVendors then SteakMap_UpdateReagentVendors() end
	if SteakMap_UpdateQuestIcons then SteakMap_UpdateQuestIcons() end
	if SteakMap_UpdateHerbNodes then SteakMap_UpdateHerbNodes() end
	if SteakMap_UpdatePOI then SteakMap_UpdatePOI() end

	--[[
	if SteakMapConfigDB.showRepair then
		if DrawRepairVendors then DrawRepairVendors() end
	else
		if HideRepairVendors then HideRepairVendors() end
	end

	if SteakMapConfigDB.showReagent then
		if DrawReagentVendors then DrawReagentVendors() end
	else
		if HideReagentVendors then HideReagentVendors() end
	end

	if SteakMapConfigDB.showFlight then
		if DrawFlightPaths then DrawFlightPaths() end
	else
		if HideFlightPaths then HideFlightPaths() end
	end

	if SteakMapConfigDB.showQuestPOI then
		--SetCVar("questPOI", "1")
		if MapFrame_UpdateQuestIcons then MapFrame_UpdateQuestIcons() end
	else
		--SetCVar("questPOI", "0")
		if HideQuestPOIIcons then HideQuestPOIIcons() end
	end
	]]
end

local panel = CreateFrame("Frame", "SteakMapConfigPanel", UIParent)
panel.name = "Steak Minimap"
InterfaceOptions_AddCategory(panel)

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Steak Minimap Options")

local function CreateCheckbox(parent, label, dbKey, yOffset)
	local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
	cb:SetPoint("TOPLEFT", 16, yOffset)

	local text = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
	text:SetText(label)
	cb.label = text

	cb:SetChecked(SteakMapConfigDB[dbKey])

	cb:SetScript("OnClick", function(self)
		SteakMapConfigDB[dbKey] = self:GetChecked()
		SteakMap_UpdateAll()
	end)

	return cb
end

local y = -60

CreateCheckbox(panel, "Show Repair Vendors", "showRepair",  y)
y = y - 30

CreateCheckbox(panel, "Show Reagent Vendors", "showReagent", y)
y = y - 30

CreateCheckbox(panel, "Show Flight Paths", "showFlight",  y)
y = y - 30

CreateCheckbox(panel, "Show Quest POIs", "showQuestPOI", y)
y = y - 30

CreateCheckbox(panel, "Show Herb Nodes", "showHerbs", y)
y = y - 30

CreateCheckbox(panel, "Show Map POI", "showPOI", y)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
	--[[
	if SteakMapConfigDB.showQuestPOI then
		SetCVar("questPOI", "1")
	end
	]]
	SteakMap_UpdateAll()
end)

