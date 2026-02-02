local f = CreateFrame("ScrollFrame", "MapFrame", UIParent)
CreateFrame("Frame", "MMBF", UIParent)
MMBF:SetSize(50, 50)
MMBF:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
MMBF:Show()

local MAP_SCALE = 1.5

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

--f:Hide()
f:Show()

local PlayerArrow = CreateFrame("Frame", "MapFramePlayerArrowFrame", MapFrame)
PlayerArrow:SetSize(64, 64)
PlayerArrow:SetPoint("CENTER", MapFrame, "CENTER", 0, 0)
PlayerArrow:SetFrameLevel(MapFrameSC:GetFrameLevel() + 10)

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

function MoveMinimapButtons()
	local frames = {}
	local kids = {Minimap:GetChildren()}

	local hideThese = {"MinimapBackdrop", "TimeManagerClockButton", "MinimapZoomOut", "MinimapZoomIn", "MiniMapWorldMapButton", "MinimapZoneTextButton"}

	for k, v in pairs(kids) do
		if v:GetName() == "GuildInstanceDifficulty" or v:GetName() == "MiniMapInstanceDifficulty" then
			v:SetParent(MapFrame)
			v:SetFrameLevel(MapFrameSC:GetFrameLevel()+2)
			v:SetPoint("TOPLEFT", MapFrame, "TOPLEFT", 0, 0)
		elseif tContains(hideThese, v:GetName()) then
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

	for i=1, NUM_WORLDMAP_DETAIL_TILES, 1 do
		if dungeonLevel > 0 then
			--_G["MapFrameTexture"..i]:SetTexture("Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName..dungeonLevel.."_"..i)
			_G["MapFrameTexture"..i]:SetTexture("Interface\\AddOns\\SteakMiniMap\\WorldMap\\"..mapFileName.."\\"..mapFileName..dungeonLevel.."_"..i)
		else
			--_G["MapFrameTexture"..i]:SetTexture("Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName..i)
			_G["MapFrameTexture"..i]:SetTexture("Interface\\AddOns\\SteakMiniMap\\WorldMap\\"..mapFileName.."\\"..mapFileName..i)
		end
	end

	if IsInCity() or IsInInstance() then
		Minimap:SetZoom(3)
	else
		Minimap:SetZoom(1)
	end
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		Minimap:SetParent("MapFrame")
		Minimap:SetPoint("CENTER", MapFrame, "CENTER", 0, 0)
		Minimap:SetFrameLevel(MapFrameSC:GetFrameLevel()+2)
		Minimap:SetSize(150, 150)
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
	elseif event == "WORLD_MAP_UPDATE" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "WORLD_MAP_NAME_UPDATE" then
		MapFrame_UpdateTextures()
	end	
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("VARIABLES_LOADED")

f:RegisterEvent("WORLD_MAP_UPDATE");
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_INDOORS")

f:RegisterEvent("CLOSE_WORLD_MAP");
f:RegisterEvent("WORLD_MAP_NAME_UPDATE");
--f:RegisterEvent("PARTY_MEMBERS_CHANGED");
--f:RegisterEvent("RAID_ROSTER_UPDATE");
--f:RegisterEvent("DISPLAY_SIZE_CHANGED");
--f:RegisterEvent("QUEST_LOG_UPDATE");
--f:RegisterEvent("QUEST_POI_UPDATE");
--f:RegisterEvent("SKILL_LINES_CHANGED");
--f:RegisterEvent("REQUEST_CEMETERY_LIST_RESPONSE");

--local function MapUnitFrame_Update(self, elapsed)
--	self.timer = (self.timer or 0) + elapsed
--
--	if self.timer >= 2 then
--		local unit = strsub(self:GetName(), 4)
--
--		if strsub(unit, 1, 4) == "raid" then
--			if UnitName(unit) then
--				local unitX, unitY = GetPlayerMapPosition(unit)
--
--				if unitX > 0 and unitY > 0 then
--					self:SetPosition("CENTER", MapFrameSC, "TOPLEFT", unitX*(1002*0.5), unitY*(668*0.5))
--					self:Show()
--				end
--			else
--				self:Hide()
--			end
--		else
--			if UnitName(unit) then
--				local unitX, unitY = GetPlayerMapPosition(unit)
--
--				if unitX > 0 and unitY > 0 then
--					self:SetPosition("CENTER", MapFrameSC, "TOPLEFT", unitX*(1002*0.5), unitY*(668*0.5))
--				end
--			else
--				self:Hide()
--			end
--		end
--
--		self.timer = 0
--	end
--end

f:SetScript("OnEvent", OnEvent)
f:SetScript("OnUpdate", function(self, elapsed)
	local unitX, unitY = GetPlayerMapPosition("player")

	if unitX == 0 and unitY == 0 and IsInInstance() then
		MapFrame_UpdateTextures()
		PlayerArrow:Hide()
	else
		local facing = GetPlayerFacing()

		if facing then
			local angle = GetTime()

			local s = math.sin(angle)
			local c = math.cos(angle)

	    		PlayerArrow.texture:SetRotation(facing)
		end

		PlayerArrow:Show()
	end

	if unitX == 0 and unitY == 0 and Minimap:IsVisible() then
		Minimap:Hide()
	elseif unitX > 0 and unitY > 0 and not Minimap:IsVisible() then
		Minimap:Show()
	end

	self:SetHorizontalScroll(((unitX*(MapFrameSC:GetWidth()*MapFrameSC:GetScale()))-(MapFrame:GetWidth()/2))/MapFrameSC:GetScale())
	self:SetVerticalScroll(((unitY*(MapFrameSC:GetHeight()*MapFrameSC:GetScale()))-(MapFrame:GetHeight()/2))/MapFrameSC:GetScale())
end)

f:SetScript("OnMouseWheel", function(self, delta)
	if delta > 0 and MapFrameSC:GetScale() < 1 then
		MapFrameSC:SetScale(MapFrameSC:GetScale()+0.01)
	elseif MapFrameSC:GetScale() > 0.5 then
		MapFrameSC:SetScale(MapFrameSC:GetScale()-0.01)
	end
	Minimap:SetScale(MapFrameSC:GetScale())
end)

f:Hide()

MMBF:SetScript("OnUpdate", function(self, elapsed)
	self.timer = (self.timer or 0) + elapsed

	if self.timer >= 1 then
		local kids = {self:GetChildren()}
		local frames = {"GameTimeFrame", "MiniMapTrackingButton"}

		for k, v in pairs(kids) do
			if not tContains(frames, v:GetName()) and v:IsVisible() and strsub(v:GetName(), 1, 10) ~= "GatherNote" then
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

		WatchFrame:SetParent(UIParent)
		WatchFrame:ClearAllPoints()
		WatchFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -50, -200)

		self.timer = 0
	end
end)
