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
local questDots = {}
local questBlobs = {}

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

--local GatherMateReady = false

local blobColors = {
    {r=255, g=0,   b=0,   a=100}, -- 1: Red
    {r=0,   g=255, b=0,   a=100}, -- 2: Neon Green
    {r=0,   g=0,   b=255, a=100}, -- 3: Blue
    {r=255, g=255, b=0,   a=100}, -- 4: Yellow
    {r=255, g=0,   b=255, a=100}, -- 5: Magenta
    {r=0,   g=255, b=255, a=100}, -- 6: Cyan
    {r=255, g=128, b=0,   a=100}, -- 7: Orange
    {r=128, g=0,   b=255, a=100}, -- 8: Deep Purple
    {r=0,   g=128, b=0,   a=100}, -- 9: Dark Green
    {r=255, g=153, b=204, a=100}, -- 10: Hot Pink
    {r=153, g=255, b=153, a=100}, -- 11: Pale Green
    {r=102, g=102, b=102, a=100}, -- 12: Grey
    {r=255, g=255, b=255, a=100}, -- 13: White
    {r=102, g=51,  b=0,   a=100}, -- 14: Brown
    {r=0,   g=102, b=102, a=100}, -- 15: Teal
    {r=255, g=204, b=0,   a=100}, -- 16: Gold
    {r=204, g=255, b=0,   a=100}, -- 17: Lime
    {r=0,   g=204, b=153, a=100}, -- 18: Mint
    {r=0,   g=0,   b=128, a=100}, -- 19: Navy
    {r=255, g=102, b=102, a=100}, -- 20: Salmon
    {r=153, g=0,   b=0,   a=100}, -- 21: Maroon
    {r=204, g=153, b=255, a=100}, -- 22: Lavender
    {r=255, g=255, b=153, a=100}, -- 23: Cream
    {r=0,   g=51,  b=102, a=100}, -- 24: Midnight Blue
    {r=128, g=128, b=0,   a=100}  -- 25: Olive
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

local function MapFrame_UpdateQuestIcons()
	--if not WorldMapFrame:IsShown() then SetMapToCurrentZone() end

	--WorldMapFrame_Update()

	local mapW = MapFrameSC:GetWidth()
	local mapH = MapFrameSC:GetHeight()

	for _, poi in ipairs(questDots) do poi:Hide() end
	--for _, blob in ipairs(questBlobs) do blob:Hide() end
	
	local index = 1
	
	for i=1, GetNumQuestLogEntries() do
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
		
		--local _, _, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(i)
		local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(i)

		if not isHeader then
			local _, posX, posY, objective = QuestPOIGetIconInfo(questID)

			if posX and posX > 0 then
				if isComplete then
					poi.num:SetText("?")
				else
					poi.num:SetText(index)
				end
				
				local finalX = posX * mapW
				local finalY = -posY * mapH

				questDots[i].x = finalX
				questDots[i].y = finalY

				poi:ClearAllPoints()
				poi:SetPoint("CENTER", MapFrameSC, "TOPLEFT", finalX, finalY)

				poi.questID = questID
				poi.num:SetText(index)

				--[[
				local questBlob = questBlobs[i]
				
				if not questBlob then
					questBlob = CreateFrame("QuestPOIFrame", "MapBlobFrame_"..i, MapFrameSC)

					--questBlob:SetPoint("TOPLEFT", MapFrameSC, "TOPLEFT", 0, 0)
					--questBlob:SetSize(MapFrameSC:GetSize())
					questBlob:SetAllPoints(MapFrameSC)
					questBlob:Show()

					questBlob:SetFillTexture("Interface\\WorldMap\\UI-QuestBlob-Inside")
					questBlob:SetBorderTexture("Interface\\WorldMap\\UI-QuestBlob-Outside")

					questBlob:SetFillAlpha(128)
					questBlob:SetBorderAlpha(255)
					questBlob:SetBorderScalar(1.0) -- Thickness of the border

					--questBlob:SetFillColor(blobColors[i].r, blobColors[i].g, blobColors[i].b, blobColors[i].a)
					--questBlob:SetBorderColor(blobColors[i].r, blobColors[i].g, blobColors[i].b, blobColors[i].a+100)

					questBlobs[i] = blobFrame
				end
				
				questBlob:DrawQuestBlob(questID, not isComplete)
				]]
				
				poi:Show()
				index = index + 1
			end
		end
	end
end

function MapFrame_UpdateTextures()
	--SetMapToCurrentZone()

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
	end

	--MapFrameSC:SetSize(textureWidth, textureHeight)
	--[[
	for i=1,12 do
		_G["MapFrameTexture"..i]:SetSize(textureWidth/4, textureHeight/3)
	end
	]]

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
	if event == "ADDON_LOADED" then
--		local addonName = ...

--		if addonName == "GatherMate" then GatherMateReady = true end
	elseif event == "PLAYER_ENTERING_WORLD" then
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
		
		MapFrame_UpdateQuestIcons()
	elseif event == "VARIABLES_LOADED" then
		SteakMinimapZones = SteakMinimapZones or {}
	elseif event == "WORLD_MAP_UPDATE" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "WORLD_MAP_NAME_UPDATE" or event == "ZONE_CHANGED_NEW_AREA" then
		MapFrame_UpdateTextures()
		MapFrame_UpdateQuestIcons()
	elseif event == "QUEST_LOG_UPDATE" or event == "QUEST_POI_UPDATE" or event == "UNIT_QUEST_LOG_CHANGED" then
		--if not WorldMapFrame:IsShown() then SetMapToCurrentZone() end
   
		if not InCombatLockdown() and not WorldMapFrame:IsShown() and not QuestLogFrame:IsShown() then
			local mapSize = WORLDMAP_SETTINGS.size
			WORLDMAP_SETTINGS.size = WORLDMAP_WINDOWED_SIZE
			ShowUIPanel(WorldMapFrame)
			WorldMapFrame:ClearAllPoints()
			WorldMapFrame:SetClampedToScreen(false)
			WorldMapFrame:SetPoint("RIGHT", UIParent, "LEFT", -1000, 0)
			HideUIPanel(WorldMapFrame)
		end
		
		MapFrame_UpdateQuestIcons()
	elseif event == "MINIMAP_PING" then
		--print(...)
		local unit, x, y = ...
	end
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("VARIABLES_LOADED")

f:RegisterEvent("WORLD_MAP_UPDATE");
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_INDOORS")

f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("WORLD_MAP_UPDATE")

--f:RegisterEvent("ADDON_LOADED")

f:RegisterEvent("CLOSE_WORLD_MAP")
f:RegisterEvent("WORLD_MAP_NAME_UPDATE")
--f:RegisterEvent("PARTY_MEMBERS_CHANGED")
--f:RegisterEvent("RAID_ROSTER_UPDATE")
--f:RegisterEvent("DISPLAY_SIZE_CHANGED")
f:RegisterEvent("QUEST_LOG_UPDATE")
f:RegisterEvent("QUEST_POI_UPDATE")
f:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
f:RegisterEvent("MINIMAP_PING")
--f:RegisterEvent("SKILL_LINES_CHANGED")
--f:RegisterEvent("REQUEST_CEMETERY_LIST_RESPONSE")

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
