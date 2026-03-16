local f = CreateFrame("Frame", nil, UIParent)

local fpIcons = {}

function SteakMap_UpdateFlightPaths()
	for _, poi in ipairs(fpIcons) do poi:Hide() end

	if not SteakMapConfigDB.showFlight then return end
	
	local mapID = GetCurrentMapAreaID()
	if not mapID or mapID == 0 or not SteakFlightPathDB or not SteakFlightPathDB[mapID] then return end

	local mapW, mapH = MapFrameSC:GetSize()
	
	local index = 1
	for _, data in pairs(SteakFlightPathDB[mapID]) do
		local icon = fpIcons[index]
		
		if not icon then
			icon = CreateFrame("Button", nil, MapFrameSC)
			icon:SetSize(16, 16)
			icon:SetFrameStrata(MapFrameSC:GetFrameStrata())
			icon:SetFrameLevel(MapFrameSC:GetFrameLevel()+1)

			local tex = icon:CreateTexture(nil, "BACKGROUND")
			tex:SetAllPoints(icon)
			tex:SetTexture("Interface\\MINIMAP\\TRACKING\\FlightMaster.blp")
			icon.tex = tex

			icon.text = icon:CreateFontString(nil, "OVERLAY")
			icon.text:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 7, "OUTLINE")
			icon.text:SetPoint("TOP", icon, "BOTTOM", 0, -2)
			icon.text:Hide()

			icon:SetScript("OnEnter", function(self) self.text:Show() end)
			icon:SetScript("OnLeave", function(self) self.text:Hide() end)

			fpIcons[index] = icon
		end
		
		icon:ClearAllPoints()
		icon:SetPoint("CENTER", MapFrameSC, "TOPLEFT", data.x * mapW, -data.y * mapH)
		icon:Show()
		index = index + 1
	end
end

local function OnEvent(self, event, ...)
	if event == "VARIABLES_LOADED" then
		SteakFlightPathDB = SteakFlightPathDB or {}
	elseif event == "TAXIMAP_OPENED" then
		local x, y = GetPlayerMapPosition("player")
		local mapID = GetCurrentMapAreaID()

		if not mapID or mapID == 0 then return end
		if ( not x or x == 0 ) or ( not y or y == 0 ) then return end

		SteakFlightPathDB[mapID] = SteakFlightPathDB[mapID] or {}
		
		for _, v in ipairs(SteakFlightPathDB[mapID]) do
			if math.abs(v.x - x) < 0.01 and math.abs(v.y - y) < 0.01 then return end
		end

		
		local name = UnitName("target") or "Flight Path"
		SteakFlightPathDB[mapID] = SteakFlightPathDB[mapID] or {}
			
		table.insert(SteakFlightPathDB[mapID], { x = x, y = y, name = name })
			
		SteakMap_UpdateFlightPaths()
	else
		SteakMap_UpdateFlightPaths()
	end
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("VARIABLES_LOADED")

f:RegisterEvent("WORLD_MAP_UPDATE")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_INDOORS")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("WORLD_MAP_NAME_UPDATE")
f:RegisterEvent("TAXIMAP_OPENED")

f:SetScript("OnEvent", OnEvent)
