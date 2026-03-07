local f = CreateFrame("Frame", nil, UIParent)

local fpDots = {}

local function IsInCity()
    local channels = {GetChannelList()}
    
    for i = 1, #channels, 2 do
        local id, name = channels[i], channels[i+1]

        if string.find(name, "Trade") then
            return true
        end
    end

    return false 
end

function MapFrame_UpdateFlightPaths()
	for _, poi in ipairs(fpDots) do poi:Hide() end
	
	local mapFilename = GetMapInfo()
	
	if not mapFilename or not SteakFlightPaths[mapFilename] then return end

	local mapW, mapH = MapFrameSC:GetSize()
	
	local index = 1
	for _, data in pairs(SteakFlightPaths[mapFilename]) do
		local dot = fpDots[index]
		
		if not dot then
			dot = CreateFrame("Frame", nil, MapFrameSC)
			dot:SetSize(16, 16)
			local tex = dot:CreateTexture(nil, "BACKGROUND")
			tex:SetAllPoints(dot)
			tex:SetTexture("Interface\\TaxiFrame\\UI-Taxi-Icon-White")
			dot.tex = tex
			fpDots[index] = dot
		end
		
		dot:ClearAllPoints()
		dot:SetPoint("CENTER", MapFrameSC, "TOPLEFT", data.x * mapW, -data.y * mapH)
		dot:Show()
		index = index + 1
	end
end

local function OnEvent(self, event, ...)
	if event == "VARIABLES_LOADED" then
		SteakFlightPaths = SteakFlightPaths or {}
	elseif event == "TAXIMAP_OPENED" then
		local x, y = GetPlayerMapPosition("player")
		local mapFilename = GetMapInfo()
		
		if x > 0 and y > 0 and mapFilename then
			SteakFlightPaths[mapFilename] = SteakFlightPaths[mapFilename] or {}
			
			SteakFlightPaths[mapFilename][("%.0f,%.0f"):format(x * 100, y * 100)] = { x = x, y = y }
			
			MapFrame_UpdateFlightPaths()
		end
	else
		MapFrame_UpdateFlightPaths()
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
