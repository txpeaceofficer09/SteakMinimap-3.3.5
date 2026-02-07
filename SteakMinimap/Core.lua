local f = CreateFrame("ScrollFrame", "MapFrame", UIParent)
CreateFrame("Frame", "MMBF", UIParent)
MMBF:SetSize(50, 50)
MMBF:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
MMBF:Show()

--local MAP_SCALE = 4*0.68
--local MAP_SCALE = 2.05
--local MAP_SCALE = 1.875
local MAP_SCALE = 1

local MAPW = 1002 * MAP_SCALE
local MAPH = 662 * MAP_SCALE

local TXTW = 256 * MAP_SCALE
local TXTH = 256 * MAP_SCALE

f:EnableKeyboard(false)
f:EnableMouse(true)
f:EnableMouseWheel(true)

f:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 20)
f:SetSize(190, 150)
f:SetBackdrop( { bgFile = "Interface\\DialogFrame\\UI-DialogBox-BackGround-Dark", edgeFile = nil, tile = true, tileSize = 32, edgeSize = 0, insets = { left = 0, right = 0, top = 0, bottom = 0 } } )

f:SetFrameStrata("HIGH")
--f:SetFrameLevel(MainMenuBar:GetFrameLevel()+10)
f:SetFrameLevel(25)

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

local questBlobs = {}
local function CreateBlob(index, questID)
	if not questBlobs[index] then
		local BlobFrame = CreateFrame("QuestPOIFrame", "MapBlobFrame_"..index, MapFrameSC)

		BlobFrame:SetPoint("TOPLEFT", MapFrameSC, "TOPLEFT", 0, 0)
		BlobFrame:SetSize(1002, 662)
		BlobFrame:Show()

		BlobFrame:SetFillTexture("Interface\\WorldMap\\UI-QuestBlob-Inside")
		BlobFrame:SetBorderTexture("Interface\\WorldMap\\UI-QuestBlob-Outside")

		BlobFrame:SetFillAlpha(128)
		BlobFrame:SetBorderAlpha(255)
		BlobFrame:SetBorderScalar(1.0) -- Thickness of the border

		--BlobFrame:SetFillColor(blobColors[index].r, blobColors[index].g, blobColors[index].b, blobColors[index].a)
		--BlobFrame:SetBorderColor(blobColors[index].r, blobColors[index].g, blobColors[index].b, blobColors[index].a+100)

		questBlobs[index] = BlobFrame
	end

	return questBlobs[index]
end

--local PlayerArrow = CreateFrame("Frame", "MapFramePlayerArrowFrame", MapFrame)
local PlayerArrow = CreateFrame("Frame", "MapFramePlayerArrowFrame", MapFrameSC)
PlayerArrow:SetSize(64, 64)
--PlayerArrow:SetPoint("CENTER", MapFrame, "CENTER", 0, 0)
PlayerArrow:SetFrameLevel(MapFrameSC:GetFrameLevel() + 25)

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

local function MapFrame_UpdateBlobs()
    --MapBlobFrame:Update() -- Internal engine refresh
    for _, blob in ipairs(questBlobs) do blob:Hide() end

    for i = 1, GetNumQuestLogEntries() do
        --local _, _, _, _, _, isHeader, _, _, questID = GetQuestLogTitle(i)
        local questTitle, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(i)
        if not isHeader and questID then
            -- Draw the blob regardless of whether it has a specific POI icon

            --MapBlobFrame:DrawQuestBlob(questID, true)

            local BlobFrame = questBlobs[i] or CreateBlob(i)

            --BlobFrame:DrawQuestBlob(questID, isComplete)
            BlobFrame:DrawQuestBlob(questID, not isComplete)
        end
    end
end

local UnitDots = {}
local function GetUnitDot(index)
    if not UnitDots[index] then
        local dot = CreateFrame("Frame", "MapFrameUnitDot"..index, MapFrameSC)
        dot:SetSize(16, 16)
        
        local tex = dot:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints()
        -- Using the standard "blip" texture or a simple circle
        tex:SetTexture("Interface\\Minimap\\ObjectIcons")
        tex:SetTexCoord(0.5, 0.75, 0, 0.25) -- This is the standard "Party Member" dot
        
        dot.tex = tex
        UnitDots[index] = dot
    end
    return UnitDots[index]
end

local poiDots = {}
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
    local mapW = MapFrameSC:GetWidth()
    local mapH = MapFrameSC:GetHeight()

    for _, child in ipairs({MapFrameSC:GetChildren()}) do
    	if strsub(child:GetName(), 1, 15) == "MapFrameSC_POI_" then child:Hide() end
    end

    for i = 1, GetNumQuestLogEntries() do
        --local questTitle, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(i)
        local _, _, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(i)
        
        if not isHeader then
            local _, posX, posY, objective = QuestPOIGetIconInfo(questID)

            if posX and posX > 0 then
                --local name = "MapFrameSC_POI_" .. questID
                local name = "MapFrameSC_POI_"
                local btn = _G[name]

                if isComplete then
                	--name = name.."Complete_"..i
                	name = name.."Complete_"..questID
                else
                	--name = name.."Number_"..i
                	name = name.."Number_"..questID
                end

                if not btn then
					if ( isComplete ) then
                    	    btn = CreateFrame("Button", name, MapFrameSC, "QuestPOICompletedTemplate");
                	else
                        	btn = CreateFrame("Button", name, MapFrameSC, "QuestPOITemplate");
                	end

                	--btn:SetScript("OnEnter", function(self) self.grow = true; end)
					--btn:SetScript("OnLeave", function(self) self.grow = false; end)
					btn:SetScript("OnEnter", nil)
					btn:SetScript("OnLeave", nil)
					btn:SetScript("OnClick", nil)
					btn:EnableMouse(false)
                end

                local finalX = posX * mapW
                local finalY = -posY * mapH

                btn:SetParent(MapFrameSC)
                btn:ClearAllPoints()
                btn:SetPoint("CENTER", MapFrameSC, "TOPLEFT", finalX, finalY)
                btn:SetFrameLevel(MapFrameSC:GetFrameLevel() + 5)

                -- 6. Set the Icon (Numeric or Question Mark)
                --if isComplete then
                --    QuestPOI_SelectButtonType(btn, QUEST_POI_COMPLETE_SWAP, i)
                --else
                --    QuestPOI_SelectButtonType(btn, QUEST_POI_NUMERIC, i)
                --end

				local yOffset = 0.5 + floor(i / QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
				local xOffset = mod(i, QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
				if btn.number then btn.number:SetTexCoord(xOffset, xOffset + QUEST_POI_ICON_SIZE, yOffset, yOffset + QUEST_POI_ICON_SIZE); end

                btn:Show()
            end
        end
    end
end

function MoveMinimapButtons()
	local frames = {}
	local kids = {Minimap:GetChildren()}

	local hideThese = {"MinimapBackdrop", "TimeManagerClockButton", "MinimapZoomOut", "MinimapZoomIn", "MiniMapWorldMapButton", "MinimapZoneTextButton"}

	for k, v in pairs(kids) do
		if v:GetName() == "GuildInstanceDifficulty" or v:GetName() == "MiniMapInstanceDifficulty" then
			v:SetParent(MapFrame)
			v:SetFrameLevel(MapFrameSC:GetFrameLevel()+2)
			v:SetPoint("TOPLEFT", MapFrame, "TOPLEFT", 0, 0)
		elseif v:GetName() == nil or tContains(hideThese, v:GetName()) then
			v:Hide()
		elseif v:GetName() ~= "MiniMapTracking" then
			tinsert(frames, v:GetName())			
		end
	end

	kids = {MinimapCluster:GetChildren()}

	for k, v in pairs(kids) do
		if v:GetName() == "GuildInstanceDifficulty" or v:GetName() == "MiniMapInstanceDifficulty" then
			v:SetParent(MapFrame)
			v:SetFrameLevel(MapFrameSC:GetFrameLevel()+2)
			v:SetPoint("TOPLEFT", MapFrame, "TOPLEFT", 0, 0)
		elseif tContains(hideThese, v:GetName()) then
			v:Hide()
		else
			tinsert(frames, v:GetName())
		end
	end

	kids = {MinimapBackdrop:GetChildren()}

	for k, v in pairs(kids) do
		if v:GetName() == "GuildInstanceDifficulty" or v:GetName() == "MiniMapInstanceDifficulty" then
			v:SetParent(MapFrame)
			v:SetFrameLevel(MapFrameSC:GetFrameLevel()+2)
			v:SetPoint("TOPLEFT", MapFrame, "TOPLEFT", 0, 0)
		elseif tContains(hideThese, v:GetName()) then
			v:Hide()
		else
			tinsert(frames, v:GetName())
		end
	end

	local sortTbl = {"GameTimeFrame", "MiniMapTrackingButton"}

	for k, v in pairs(frames) do
		if tContains(sortTbl, v) then
			-- Do nothing the frame is already there.
		elseif _G[v]:IsVisible() then
			tinsert(sortTbl, 3, v)
		else
			tinsert(sortTbl, v)
		end
	end

	for k, v in pairs(sortTbl) do
		local frame = _G[v]

		frame:SetParent(MMBF)
		frame:ClearAllPoints()

		if k == 1 then
			frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
		else
			frame:SetPoint("TOP", _G[sortTbl[(k-1)]], "BOTTOM", 0, 0)
		end
	end

	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetParent(UIParent)
	MiniMapTracking:SetAllPoints(MiniMapTrackingButton)

	WatchFrame:SetParent(UIParent)
	WatchFrame:ClearAllPoints()
	WatchFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -50, -200)
end

function MapFrame_UpdateTextures()
	local mapFileName, textureHeight, textureWidth = GetMapInfo()
	local dungeonLevel = GetCurrentMapDungeonLevel()

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
			--_G["MapFrameTexture"..i]:SetTexture("Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName..dungeonLevel.."_"..i)
			--_G["MapFrameTexture"..i]:SetTexture("Interface\\AddOns\\SteakMinimap\\WorldMap\\"..mapFileName.."\\"..mapFileName..dungeonLevel.."_"..i)
			_G["MapFrameTexture"..i]:SetTexture(prefix..mapFileName.."\\"..mapFileName..dungeonLevel.."_"..i)
			--if IsInInstance() then print(prefix..mapFileName.."\\"..mapFileName..dungeonLevel.."_"..i) end
		else
			--_G["MapFrameTexture"..i]:SetTexture("Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName..i)
			--_G["MapFrameTexture"..i]:SetTexture("Interface\\AddOns\\SteakMinimap\\WorldMap\\"..mapFileName.."\\"..mapFileName..i)
			_G["MapFrameTexture"..i]:SetTexture(prefix..mapFileName.."\\"..mapFileName..i)
			--if IsInInstance() then print(prefix..mapFileName.."\\"..mapFileName..i) end
		end
	end

	if IsInCity() or IsInInstance() then
		Minimap:SetZoom(3)
	else
		--Minimap:SetZoom(0)
		Minimap:SetZoom(1)
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
		--Minimap:SetSize(80.882352941176, 80.882352941176)
		--Minimap:SetSize(165, 165)
		--Minimap:SetSize(220, 220)
		TimeManagerClockButton:Hide()
		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetPoint("TOPLEFT", UIParent, "TOPRIGHT", 0, 0)
		MinimapCluster:Hide()
		Minimap:SetAlpha(0)
		MapFrameSC:SetSize(MAPW, MAPH)
		self:SetScrollChild(MapFrameSC)
		MoveMinimapButtons()
		Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
		self:Show()

		MapFrame_UpdateQuestIcons()
		MapFrame_UpdateBlobs()
	elseif event == "WORLD_MAP_UPDATE" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "WORLD_MAP_NAME_UPDATE" then
		MapFrame_UpdateTextures()
		MapFrame_UpdateQuestIcons()
		MapFrame_UpdateBlobs()
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		MapFrame_UpdateTextures()
		MapFrame_UpdateQuestIcons()
		MapFrame_UpdateBlobs()
	elseif event == "QUEST_LOG_UPDATE" or event == "QUEST_POI_UPDATE" then
		MapFrame_UpdateQuestIcons()
		MapFrame_UpdateBlobs()
	end	
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("VARIABLES_LOADED")

f:RegisterEvent("WORLD_MAP_UPDATE");
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_INDOORS")

f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("WORLD_MAP_UPDATE")

f:RegisterEvent("CLOSE_WORLD_MAP");
f:RegisterEvent("WORLD_MAP_NAME_UPDATE");
--f:RegisterEvent("PARTY_MEMBERS_CHANGED");
--f:RegisterEvent("RAID_ROSTER_UPDATE");
--f:RegisterEvent("DISPLAY_SIZE_CHANGED");
f:RegisterEvent("QUEST_LOG_UPDATE");
f:RegisterEvent("QUEST_POI_UPDATE");
--f:RegisterEvent("SKILL_LINES_CHANGED");
--f:RegisterEvent("REQUEST_CEMETERY_LIST_RESPONSE");

f:SetScript("OnEvent", OnEvent)
f:SetScript("OnUpdate", function(self, elapsed)
	local unitX, unitY = GetPlayerMapPosition("player")

	if unitX == 0 and unitY == 0 then
		if IsInInstance() then MapFrame_UpdateTextures() end

		PlayerArrow:Hide()
		Minimap:Hide()

		return
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
	PlayerArrow:SetPoint("CENTER", MapFrameSC, "TOPLEFT", mmX, mmY)

	local currentScale = MapFrameSC:GetScale()
    local scrollX = ((unitX * mapWidth * currentScale) - (self:GetWidth() / 2)) / currentScale
    local scrollY = ((unitY * mapHeight * currentScale) - (self:GetHeight() / 2)) / currentScale

    self:SetHorizontalScroll(scrollX)
    self:SetVerticalScroll(scrollY)

    self.dotTimer = (self.dotTimer or 0) + elapsed

    if self.dotTimer >= 0.1 then
    	local prefix = (GetNumRaidMembers() > 0) and "raid" or "party"
    	local count = (prefix == "raid") and GetNumRaidMembers() or GetNumPartyMembers()

    	for _, dot in pairs(UnitDots) do dot:Hide() end

    	for i=1,count do
    		local unit = prefix..i

    		if not UnitIsUnit(unit, "player") then
    			local uX, uY = GetPlayerMapPosition(unit)

    			if uX > 0 and uY > 0 then
    				local dot = GetUnitDot(i)

    				local posX = (uX * mapWidth) / MapFrameSC:GetScale()
    				local posY = (uY * mapHeight) / MapFrameSC:GetScale()

    				dot:ClearAllPoints()
    				dot:SetPoint("CENTER", MapFrameSC, "TOPLEFT", posX, posY)

				local iconIndex = GetRaidTargetIndex(unit)
				local isDead = UnitIsDead(unit)
				local isOffline = not UnitIsConnected(unit)

				if iconIndex then
					dot.tex:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")

					local left = (iconIndex - 1) % 4 * 0.25
					local right = left + 0.25
					local top = math.floor((iconIndex - 1) / 4) * 0.25
					local bottom = top + 0.25

					dot.tex:SetTexCoord(left, right, top, bottom)
					dot.tex:SetVertexColor(1, 1, 1) -- Keep icons original color
				elseif isOffline then
					dot.tex:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
					dot.tex:SetTexCoord(0.5, 1, 0, 0.5) -- Disconnected icon
					dot.tex:SetVertexColor(0.5, 0.5, 0.5)
				elseif isDead then
					dot.tex:SetTexture("Interface\\TargetingFrame\\UI-TargetofTargetFrame-Flash") 
					dot.tex:SetTexCoord(0, 1, 0, 1)
					dot.tex:SetVertexColor(0.2, 0.2, 0.2) -- Very dark for dead
					--dot.tex:SetVertexColor(0.5, 0.5, 0.5)
    				else
					dot.tex:SetTexture("Interface\\Minimap\\ObjectIcons")
					dot.tex:SetTexCoord(0.5, 0.75, 0, 0.25) -- This is the standard "Party Member" dot

    					local _, class = UnitClass(unit)
    					local color = RAID_CLASS_COLORS[class] or {r=1, g=1, b=1}

    					dot.tex:SetVertexColor(color.r, color.g, color.b)
    				end

    				dot:Show()
    			end
    		end
		end

		self.dotTimer = 0

		--self.growTimer = (self.growTimer or 0) + elapsed

		--if self.growTimer >= 0.01 then
    		local width = MapFrame:GetWidth()
    		local height = MapFrame:GetHeight()

	    	local scaleX = (500-190)/2
    		local scaleY = (500-150)/2

    		if (self.grow or false) == true then
	    		if width < 500 then width = width + scaleX end
    			if width > 500 then width = 500 end

   				if height < 500 then height = height + scaleY end
   				if height > 500 then height = 500 end
   			else
   				if width > 190 then width = width - scaleX end
   				if width < 190 then width = 190 end

   				if height > 150 then height = height - scaleY end
   				if height < 150 then height = 150 end
	   		end

			MapFrame:SetSize(width, height)

	   		--self.growTimer = 0
	   	--end

	end
end)

local growFrames = { MapFrame, Minimap, MapFrameSC }
for _, frame in ipairs(growFrames) do
	frame:SetScript("OnEnter", function(self) MapFrame.grow = true end)
	frame:SetScript("OnLeave", function(self) MapFrame.grow = false end)
end

--MapFrame:SetScript("OnEnter", function(self) self.grow = true; end)
--MapFrame:SetScript("OnLeave", function(self) self.grow = false; end)

--Minimap:SetScript("OnEnter", function(self) MapFrame.grow = true; end)
--Minimap:SetScript("OnLeave", function(self) MapFrame.grow = false; end)

--MapFrameSC:SetScript("OnEnter", function(self) MapFrame.grow = true; end)
--MapFrameSC:SetScript("OnLeave", function(self) MapFrame.grow = false; end)

--MapFrameSC:SetScript("OnEnter", function(self) MapFrame:SetSize(500, 500) end)
--MapFrameSC:SetScript("OnLeave", function(self) MapFrame:SetSize(190, 150) end)

--MapFrame:EnableMouse(false)
--Minimap:EnableMouse(false)

f:SetScript("OnMouseWheel", function(self, delta)
	if delta > 0 and MapFrameSC:GetScale() < 1 then
		MapFrameSC:SetScale(MapFrameSC:GetScale()+0.01)
	elseif MapFrameSC:GetScale() > 0.5 then
		MapFrameSC:SetScale(MapFrameSC:GetScale()-0.01)
	end
end)

MMBF:SetScript("OnUpdate", function(self, elapsed)
	self.timer = (self.timer or 0) + elapsed

	if self.timer >= 1 then
		local kids = {self:GetChildren()}
		local frames = {"GameTimeFrame", "MiniMapTrackingButton"}
	    local hideThese = {"MinimapBackdrop", "TimeManagerClockButton", "MinimapZoomOut", "MinimapZoomIn", "MiniMapWorldMapButton", "MinimapZoneTextButton"}

		for k, v in pairs(kids) do
			if not tContains(frames, v:GetName()) and v:IsVisible() and strsub(v:GetName(), 1, 10) ~= "GatherNote" and strsub(v:GetName(), 1, 12) ~= "QuestieFrame" and strsub(v:GetName(), 1, 13) ~= "GatherMatePin" then
				tinsert(frames, 3, v:GetName())
			elseif not tContains(frames, v:GetName()) and not v:IsVisible() and strsub(v:GetName(), 1, 10) ~= "GatherNote" then
				tinsert(frames, v:GetName())
			end
		end

		for k, v in pairs(frames) do
			local frame = _G[v]

			if k == 1 then
				frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
			else
				frame:SetPoint("TOP", _G[frames[(k-1)]], "BOTTOM", 0, 0)
			end
		end

		MoveMinimapButtons()

		WatchFrame:SetParent(UIParent)
		WatchFrame:ClearAllPoints()
		WatchFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -50, -200)

		self.timer = 0
	end
end)

SLASH_STEAKMINIMAP1 = "/steakmap"
SlashCmdList["STEAKMINIMAP"] = function(msg)
	
end

SLASH_MAPSCALE1 = "/mapscale"
SlashCmdList["MAPSCALE"] = function(msg)
    local factor = tonumber(msg)
    local f = MapFrameSC
    if f and factor then
        -- Scale the main frame
        f:SetSize(1002 * factor, 662 * factor)
        
        -- Scale all child textures and font strings
        local children = {f:GetRegions()}
        for i = 1, #children do
            local obj = children[i]
            if obj.SetSize then
                obj:SetSize(256 * factor, 256 * factor)
            end
        end
        print("Map textures and frame scaled by factor: " .. factor)
    else
    	print("Map scale: "..MAP_SCALE)
    end
end

--GameTooltip:SetFrameLevel(MapFrame:GetFrameLevel()+100)