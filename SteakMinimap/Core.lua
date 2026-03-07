local f = CreateFrame("ScrollFrame", "MapFrame", UIParent)

local MAPW = 1002
local MAPH = 662

local TXTW = 256
local TXTH = 256

local MMAPW = 312
local MMAPH = 220

f:EnableKeyboard(false)
f:EnableMouse(true)
f:EnableMouseWheel(true)

f:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 20)
f:SetSize(MMAPW, MMAPH)
f:SetBackdrop( { bgFile = "Interface\\DialogFrame\\UI-DialogBox-BackGround-Dark", edgeFile = nil, tile = true, tileSize = 32, edgeSize = 0, insets = { left = 0, right = 0, top = 0, bottom = 0 } } )

f:SetFrameStrata("HIGH")
f:SetFrameLevel(25)

local coordFrame = CreateFrame("Frame", nil, UIParent)
coordFrame:SetSize(80, 20)
coordFrame:SetPoint("BOTTOMLEFT", MapFrame, "BOTTOMLEFT", 0, 0)
coordFrame:SetFrameStrata("HIGH")
coordFrame:SetFrameLevel(f:GetFrameLevel()+2)
coordFrame:SetBackdrop( { bgFile = "Interface\\DialogFrame\\UI-DialogBox-BackGround-Dark", edgeFile = nil, tile = true, tileSize = 32, edgeSize = 0, insets = { left = 0, right = 0, top = 0, bottom = 0 } } )

--local coordText = coordFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
local coordText = coordFrame:CreateFontString(nil, "OVERLAY")
coordText:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 10, "OUTLINE")
coordText:SetPoint("BOTTOMLEFT", coordFrame, "BOTTOMLEFT", 5, 5)
coordText:SetTextColor(1, 1, 1)
coordText:SetDrawLayer("OVERLAY", 7) 
coordText:SetShadowColor(0, 0, 0, 1)
coordText:SetShadowOffset(1, -1)

local sc = CreateFrame("Frame", "MapFrameSC", MapFrame)

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
sc:Show()

f:Show()

local poiDots = {}

local zoneOverride = {
	["Barrens"] = {
		["Minimap"] = {
			["Size"] = { width = 40, height = 40 },
			["Zoom"] = 1
		}
	},
	["BlastedLands"] = {
		["Minimap"] = {
			["Size"] = { width = 145, height = 145 },
			["Zoom"] = 1
		}
	},
	["Desolace"] = {
		["Minimap"] = {
			["Size"] = { width = 90, height = 90 },
			["Zoom"] = 1
		}
	},
	["EasternPlaguelands"] = {
		["Minimap"] = {
			["Size"] = { width = 95, height = 95 },
			["Zoom"] = 1
		}
	},
	["IcecrownGlacier"] = {
		["Minimap"] = {
			["Size"] = { width = 70, height = 70 },
			["Zoom"] = 1
		}
	},
	["LakeWintergrasp"] = {
		["Minimap"] = {
			["Size"] = { width = 140, height = 140 },
			["Zoom"] = 1
		}
	},
	["Maraudon"] = {
		["Minimap"] = {
			["Size"] = { width = 70, height = 70 },
			["Zoom"] = 1
		}
	},
	["Ogrimmar"] = {
		["Minimap"] = {
			["Size"] = { width = 75, height = 75 },
			["Zoom"] = 3
		}
	},
	["SholazarBasin"] = {
		["Minimap"] = {
			["Size"] = { width = 90, height = 90 },
			["Zoom"] = 1
		}
	},
	["SwampOfSorrows"] = {
		["Minimap"] = {
			["Size"] = { width = 150, height = 150 },
			["Zoom"] = 1
		}
	},
	["Tanaris"] = {
		["Minimap"] = {
			["Size"] = { width = 59, height = 59 },
			["Zoom"] = 1
		}
	}
}

local PlayerArrow = CreateFrame("Frame", "MapFramePlayerArrowFrame", MapFrameSC)
PlayerArrow:SetSize(64, 64)
PlayerArrow:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
PlayerArrow:SetFrameStrata("DIALOG")
PlayerArrow:SetFrameLevel(Minimap:GetFrameLevel()+50)

PlayerArrow.texture = PlayerArrow:CreateTexture(nil, "OVERLAY")
PlayerArrow.texture:SetAllPoints(PlayerArrow)
PlayerArrow.texture:SetTexture("Interface\\AddOns\\SteakMiniMap\\Default.tga")

PlayerArrow:Show()
PlayerArrow.texture:Show()

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

local function CreatePOI(index)
	if not poiDots[index] then
		local dot = CreateFrame("Button", "MapFramePOI"..index, MapFrameSC)

		dot:SetSize(32, 32)
		dot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		dot:SetScript("OnEnter", WorldMapPOI_OnEnter)
		dot:SetScript("OnLeave", WorldMapPOI_OnLeave)
		dot:SetScript("OnClick", WorldMapPOI_OnClick)

		local tex = dot:CreateTexture(dot:GetName().."Texture", "OVERLAY")
		tex:SetSize(16, 16)
		tex:SetPoint("CENTER", 0, 0)
		tex:SetTexture("Interface\\Minimap\\POIIcons")

		dot.tex = tex
		poiDots[index] = dot
	end

	return poiDots[index]
end

function MapFrame_UpdateTextures()
	local mapFileName, textureHeight, textureWidth = GetMapInfo()
	local dungeonLevel = GetCurrentMapDungeonLevel()

	if IsInCity() or IsInInstance() then
		Minimap:SetZoom(3)
		Minimap:SetSize(150, 150)
	else
		Minimap:SetSize(70, 70)
		Minimap:SetZoom(1)
	end

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

	local numPOIs = GetNumMapLandmarks()
	if ( #poiDots < numPOIs ) then
		for i=#poiDots+1,numPOIs do
			CreatePOI(i)
		end
	end

	for i=1, #poiDots do
		local namePOI = "MapFramePOI"..i
		local mapPOI = _G[namePOI]

		if ( i <= numPOIs ) then
			local name, description, textureIndex, x, y, mapLinkID = GetMapLandmarkInfo(i);
			local x1, x2, y1, y2 = WorldMap_GetPOITextureCoords(textureIndex)
			
			_G[namePOI.."Texture"]:SetTexCoord(x1, x2, y1, y2)
			x = x * MapFrameSC:GetWidth()
			y = -y * MapFrameSC:GetHeight()
			mapPOI:SetPoint("CENTER", "MapFrameSC", "TOPLEFT", x, y)
			mapPOI.name = name
			mapPOI.description = description
			mapPOI.mapLinkID = mapLinkID

			mapPOI:Show()
		else
			mapPOI:Hide()
		end
	end
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		Minimap:SetFrameLevel(MapFrameSC:GetFrameLevel()+2)
		Minimap:SetParent(MapFrameSC)
		Minimap:SetSize(150, 150)
		TimeManagerClockButton:Hide()
		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetPoint("TOPLEFT", UIParent, "TOPRIGHT", 0, 0)
		MinimapCluster:Hide()
		Minimap:SetAlpha(0)
		MapFrameSC:SetSize(MAPW, MAPH)
		self:SetScrollChild(MapFrameSC)
		Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
		self:Show()
	elseif event == "VARIABLES_LOADED" then
		SteakMinimapZones = SteakMinimapZones or {}
	elseif event == "WORLD_MAP_UPDATE" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "WORLD_MAP_NAME_UPDATE" or event == "ZONE_CHANGED_NEW_AREA" then
		MapFrame_UpdateTextures()
	elseif event == "MINIMAP_PING" then
		local unit, x, y = ...
	end
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("VARIABLES_LOADED")

f:RegisterEvent("WORLD_MAP_UPDATE")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_INDOORS")

f:RegisterEvent("ZONE_CHANGED_NEW_AREA")

f:RegisterEvent("CLOSE_WORLD_MAP")
f:RegisterEvent("WORLD_MAP_NAME_UPDATE")
f:RegisterEvent("MINIMAP_PING")

f:SetScript("OnEvent", OnEvent)
f:SetScript("OnUpdate", function(self, elapsed)
	local unitX, unitY = GetPlayerMapPosition("player")

	if unitX == 0 and unitY == 0 then
		if IsInInstance() then MapFrame_UpdateTextures() end

		PlayerArrow:Hide()
		Minimap:Hide()

		return
	end

	local mapFileName = GetMapInfo()

	if mapFileName and zoneOverride[mapFileName] then
		local override = zoneOverride[mapFileName]
		local zoom = override.Minimap.Zoom or 1
		local size = override.Minimap.Size or {width = 100, height = 100}

		Minimap:SetZoom(zoom)
		Minimap:SetSize(size.width, size.height)
	end

	PlayerArrow:Show()
	Minimap:Show()

	local facing = GetPlayerFacing()

	if facing then PlayerArrow.texture:SetRotation(facing) end

	local mapWidth = MapFrameSC:GetWidth()
	local mapHeight = MapFrameSC:GetHeight()

	local offsetX = 0
	local offsetY = 0

	local mmX = (unitX * mapWidth) + offsetX
	local mmY = (-unitY * mapHeight) - offsetY

	Minimap:ClearAllPoints()
	Minimap:SetPoint("CENTER", MapFrameSC, "TOPLEFT", mmX, mmY)

	local currentScale = MapFrameSC:GetScale()
	local scrollX = ((unitX * mapWidth * currentScale) - (self:GetWidth() / 2)) / currentScale
	local scrollY = ((unitY * mapHeight * currentScale) - (self:GetHeight() / 2)) / currentScale

	self:SetHorizontalScroll(scrollX)
	self:SetVerticalScroll(scrollY)

	self.coordTimer = (self.coordTimer or 0) + elapsed

	if self.coordTimer >= 0.1 then
		coordText:SetText(string.format("%.1f, %.1f", unitX * 100, unitY * 100))
		coordFrame:SetWidth(coordText:GetWidth()+10)

		self.coordTimer = 0
	end
end)

f:SetScript("OnMouseWheel", function(self, delta)
	if delta > 0 and MapFrameSC:GetScale() < 2 then
		MapFrameSC:SetScale(MapFrameSC:GetScale()+0.01)
	elseif MapFrameSC:GetScale() > 0.4 then
		MapFrameSC:SetScale(MapFrameSC:GetScale()-0.01)
	end

	--[[
	for _, child in ipairs({MapFrameSC:GetChildren()}) do
		if child ~= Minimap then
			child:SetScale(1 / MapFrameSC:GetScale())
			local resize = 1 / child:GetScale()
			child:SetSize(child:GetWidth() * resize, child:GetHeight() * resize)
		end
	end
	]]
end)

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	tooltip:ClearAllPoints()
	tooltip:SetOwner(parent, "ANCHOR_NONE")
	tooltip:SetPoint("BOTTOMRIGHT", MapFrame, "TOPRIGHT", -20, 20)
end)
