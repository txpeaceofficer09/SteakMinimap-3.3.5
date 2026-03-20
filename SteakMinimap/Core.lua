local mapBorder = CreateFrame("Frame", nil, UIParent)
local f = CreateFrame("ScrollFrame", "MapFrame", UIParent)

local SteakTracking = false

local MAPW = 1002
local MAPH = 662

local TXTW = 256
local TXTH = 256

local MMAPW = 312
local MMAPH = 220

local PlayerArrow = nil
local borderColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

f:EnableKeyboard(false)
f:EnableMouse(true)
f:EnableMouseWheel(true)

mapBorder:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -1, 20)
mapBorder:SetSize(MMAPW, MMAPH)
mapBorder:SetBackdrop( { bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = { left = -1, right = -1, top = -1, bottom = -1 } } )
mapBorder:SetBackdropColor(0, 0, 0, 0.8)
mapBorder:SetBackdropBorderColor(borderColor.r or 1, borderColor.g or 0.5, borderColor.b or 0, 1)
mapBorder:SetFrameStrata("LOW")

f:SetPoint("TOPLEFT", mapBorder, "TOPLEFT", 1, -1)
f:SetPoint("BOTTOMRIGHT", mapBorder, "BOTTOMRIGHT", -1, 1)

f:SetFrameStrata("LOW")
f:SetFrameLevel(mapBorder:GetFrameLevel()+1)

local sc = CreateFrame("Frame", "MapFrameSC", MapFrame)
sc:SetFrameStrata("LOW")

for i = 1, 12, 1 do
	local t = sc:CreateTexture("MapFrameTexture"..i, "ARTWORK")

	t:SetSize(TXTW, TXTH)

	if i == 1 then
		t:SetPoint("TOPLEFT", MapFrameSC, "TOPLEFT", 0, 0)
	elseif i == 5 then
		t:SetPoint("TOPLEFT", MapFrameTexture1, "BOTTOMLEFT", 0, 0)
	elseif i == 9 then
		t:SetPoint("TOPLEFT", MapFrameTexture5, "BOTTOMLEFT", 0, 0)
	else
		t:SetPoint("LEFT", _G["MapFrameTexture"..(i-1)], "RIGHT", 0, 0)
	end

	t:Show()
end

sc:SetBackdrop( { bgFile = "Interface\\DialogFrame\\UI-DialogBox-BackGround-Dark", edgeFile = nil, tile = true, tileSize = 32, edgeSize = 0, insets = { left = 0, right = 0, top = 0, bottom = 0 } } )

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

MapFrame:SetScript("OnMouseDown", function(self, button)
	if button ~= "LeftButton" then return end

	local width  = MapFrameSC:GetWidth()
	local height = MapFrameSC:GetHeight()

	local x, y = GetCursorPosition()
	local sx, sy = MapFrameSC:GetCenter()
	local scale = MapFrameSC:GetEffectiveScale()

	x = (x / scale - (sx - width/2)) / width
	y = 1 - ((y / scale - (sy - height/2)) / height)

	if x >= 0 and x <= 1 and y >= 0 and y <= 1 then
		Minimap:PingLocation(x, y)
	end
end)

local function Steak_UpdateMinimapTracking()
	SteakTracking = false
	for i = 1, GetNumTrackingTypes() do
		local _, _, active = GetTrackingInfo(i)

		if active then
			SteakTracking = true
		end
	end
	--[[
	if SteakTracking then
		Minimap:Show()
	else
		Minimap:Hide()
	end
	]]
end

function MapFrame_UpdateTextures()
	local mapFileName, textureHeight, textureWidth = GetMapInfo()
	local dungeonLevel = GetCurrentMapDungeonLevel()

	if mapFileName then
		SteakMinimapZones[mapFileName] = {
			width = textureWidth,
			height = textureHeight,
			textureWidth = textureWidth / 4,
			textureHeight = textureHeight / 3
		}

		local RealZoneText = SteakMinimapZones[mapFileName].RealZoneText or {}

		if not tcontains(RealZoneText, GetRealZoneText()) then table.insert(RealZoneText, GetRealZoneText()) end
		SteakMinimapZones[mapFileName].RealZoneText = RealZoneText
	end

	if DungeonUsesTerrainMap() then dungeonLevel = dungeonLevel - 1 end

	if not mapFileName then
		if GetCurrentMapContinent() == WORLDMAP_COSMIC_ID then
			mapFileName = "Cosmic"
		else
			mapFileName = "World"
		end
	end

	local prefix = "Interface\\AddOns\\SteakMinimap\\WorldMap\\"
	if IsInInstance() then prefix = "Interface\\WorldMap\\" end

	for i=1, NUM_WORLDMAP_DETAIL_TILES, 1 do
		if dungeonLevel > 0 then
			_G["MapFrameTexture"..i]:SetTexture(prefix..mapFileName.."\\"..mapFileName..dungeonLevel.."_"..i)
		else
			_G["MapFrameTexture"..i]:SetTexture(prefix..mapFileName.."\\"..mapFileName..i)
		end
	end
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		TimeManagerClockButton:Hide()
		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetPoint("TOPLEFT", UIParent, "TOPRIGHT", 0, 0)
		MinimapCluster:Hide()
		Minimap:Hide()
		MapFrameSC:SetSize(MAPW, MAPH)
		self:SetScrollChild(MapFrameSC)
		--Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
		self:Show()

		DurabilityFrame:ClearAllPoints()
		DurabilityFrame:SetPoint("TOPRIGHT", MapFrame, "TOPLEFT", -5, 0)
		
		--Steak_UpdateMinimapTracking()
		
		if not PlayerArrow then
			PlayerArrow = CreateFrame("Frame", "SteakMinimapPlayerArrowFrame", MapFrameSC)
			PlayerArrow:SetSize(64, 64)
			--PlayerArrow:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
			--PlayerArrow:SetFrameStrata("HIGH")
			PlayerArrow:SetFrameStrata("TOOLTIP")
			--PlayerArrow:SetFrameLevel(MapFrameSC:GetFrameLevel()+10)
			PlayerArrow:SetFrameLevel(9999)
			PlayerArrow.texture = PlayerArrow:CreateTexture(nil, "OVERLAY")
			PlayerArrow.texture:SetAllPoints(PlayerArrow)
			PlayerArrow.texture:SetTexture("Interface\\AddOns\\SteakMiniMap\\Default.tga")
		end
	elseif event == "UPDATE_INVENTORY_DURABILITY" then
		if not InCombatLockdown() then
			DurabilityFrame:ClearAllPoints()
			DurabilityFrame:SetPoint("TOPRIGHT", MapFrame, "TOPLEFT", -5, 0)
		end
	elseif event == "VARIABLES_LOADED" then
		SteakMinimapZones = SteakMinimapZones or {}
	elseif event == "WORLD_MAP_UPDATE" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "WORLD_MAP_NAME_UPDATE" or event == "ZONE_CHANGED_NEW_AREA" then
		MapFrame_UpdateTextures()
	elseif event == "MINIMAP_PING" then
		--[[
		if not Ping then
			local Ping = MapFrameSC:CreateTexture(nil, "OVERLAY")
			Ping:SetSize(32, 32)
			Ping:SetTexture("Interface\\Minimap\\MinimapPing") -- or your own
			--Ping:Hide()
		end

		local unit, x, y = ...

		Ping:ClearAllPoints()
		Ping:SetPoint("CENTER", MapFrameSC, "TOPLEFT", x*MapFrameSC:GetWidth(), -y*MapFrameSC:GetHeight())
		Ping.timer = 0
		Ping:Show()
		
		Ping:SetScript("OnUpdate", function(self, elapsed)
			self.timer = (self.timer or 0) + elapsed
			if self.timer < 1.5 then return end
			self.timer = 0
			self:SetScript("OnUpdate", nil)
			
			self:Hide()
		end)
		]]
	elseif event == "MINIMAP_UPDATE_TRACKING" then
		Steak_UpdateMinimapTracking()
	end
end

f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("VARIABLES_LOADED")

f:RegisterEvent("WORLD_MAP_UPDATE")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_INDOORS")

f:RegisterEvent("ZONE_CHANGED_NEW_AREA")

f:RegisterEvent("CLOSE_WORLD_MAP")
f:RegisterEvent("WORLD_MAP_NAME_UPDATE")
f:RegisterEvent("MINIMAP_PING")

f:RegisterEvent("UPDATE_INVENTORY_DURABILITY")

--f:RegisterEvent("MINIMAP_UPDATE_TRACKING")

f:SetScript("OnEvent", OnEvent)
f:SetScript("OnUpdate", function(self, elapsed)
	local unitX, unitY = GetPlayerMapPosition("player")

	if unitX == 0 and unitY == 0 then
		if IsInInstance() then MapFrame_UpdateTextures() end

		if PlayerArrow then PlayerArrow:Hide() end
		return
	end

	local mapWidth = MapFrameSC:GetWidth()
	local mapHeight = MapFrameSC:GetHeight()

	local currentScale = MapFrameSC:GetScale()
	local scrollX = ((unitX * mapWidth * currentScale) - (self:GetWidth() / 2)) / currentScale
	local scrollY = ((unitY * mapHeight * currentScale) - (self:GetHeight() / 2)) / currentScale

	if not InCombatLockdown() then
		self:SetHorizontalScroll(scrollX)
		self:SetVerticalScroll(scrollY)
	end

	local offsetX, offsetY = 0, 0

	local mmX = (unitX * mapWidth) + offsetX
	local mmY = (-unitY * mapHeight) - offsetY

	if PlayerArrow then
		PlayerArrow:Show()

		local facing = GetPlayerFacing()

		if facing then PlayerArrow.texture:SetRotation(facing) end

		PlayerArrow:ClearAllPoints()
		PlayerArrow:SetPoint("CENTER", MapFrameSC, "TOPLEFT", mmX, mmY)
	end
end)

f:SetScript("OnMouseWheel", function(self, delta)
	if delta > 0 and MapFrameSC:GetScale() < 2 then
		--MapFrameSC:SetScale(MapFrameSC:GetScale()+0.01)
		MapFrameSC:SetScale(MapFrameSC:GetScale()+0.05)
	elseif MapFrameSC:GetScale() > 0.4 then
		--MapFrameSC:SetScale(MapFrameSC:GetScale()-0.01)
		MapFrameSC:SetScale(MapFrameSC:GetScale()-0.05)
	end
end)

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	tooltip:ClearAllPoints()
	tooltip:SetOwner(parent, "ANCHOR_NONE")
	tooltip:SetPoint("BOTTOMRIGHT", MapFrame, "TOPRIGHT", -20, 20)
end)
