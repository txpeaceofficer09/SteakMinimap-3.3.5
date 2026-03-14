local f = CreateFrame("ScrollFrame", "MapFrame", UIParent)

local mm = CreateFrame("Minimap", "SteakMinimap", MapFrameSC)


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

function SteakMap_UpdateMinimap()
	local mapFileName = GetMapInfo()

	if not InCombatLockdown() then
		if mapFileName and zoneOverride[mapFileName] then
			local override = zoneOverride[mapFileName]
			local zoom = override.Minimap.Zoom or 1
			local size = override.Minimap.Size or {width = 100, height = 100}

			mm:SetZoom(zoom)
			mm:SetSize(size.width, size.height)
		elseif IsInInstance() then
			mm:Hide()
		elseif IsInCity() then
			mm:SetZoom(3)
			mm:SetSize(150, 150)
			mm:Show()
		else
			mm:Show()
			mm:SetSize(70, 70)
			mm:SetZoom(1)
		end
	end
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		mm:SetFrameLevel(MapFrameSC:GetFrameLevel()+2)
		TimeManagerClockButton:Hide()
		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetPoint("TOPLEFT", UIParent, "TOPRIGHT", 0, 0)
		MinimapCluster:Hide()
		Minimap:Hide()
		mm:SetAlpha(0)
		--Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
		--self:Show()
		
	elseif event == "PLAYER_LOGIN" then
		mm:SetMovable(true)
		mm:SetUserPlaced(true)
		mm:SetParent(MapFrameSC)
	elseif event == "WORLD_MAP_UPDATE" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "WORLD_MAP_NAME_UPDATE" or event == "ZONE_CHANGED_NEW_AREA" then
		MapFrame_UpdateTextures()
	end
end

f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

f:RegisterEvent("WORLD_MAP_UPDATE")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_INDOORS")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("CLOSE_WORLD_MAP")
f:RegisterEvent("WORLD_MAP_NAME_UPDATE")

--f:RegisterEvent("MINIMAP_UPDATE_TRACKING")

f:SetScript("OnEvent", OnEvent)

mm:SetScript("OnUpdate", function(self, elapsed)
	local unitX, unitY = GetPlayerMapPosition("player")

	if unitX == 0 and unitY == 0 then return end
	if InCombatLockdown() then return end

	SteakMap_UpdateMinimap()

	local mapWidth = MapFrameSC:GetWidth()
	local mapHeight = MapFrameSC:GetHeight()

	local offsetX = 0
	local offsetY = 0

	local mmX = (unitX * mapWidth) + offsetX
	local mmY = (-unitY * mapHeight) - offsetY

	self:ClearAllPoints()
	self:SetPoint("CENTER", MapFrameSC, "TOPLEFT", mmX, mmY)
end)
