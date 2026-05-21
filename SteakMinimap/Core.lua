local mapBorder = CreateFrame("Frame", nil, UIParent)

--local MMAPW = 312
local MMAPW = 220
local MMAPH = 220

local borderColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

mapBorder:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -1, 20)
mapBorder:SetSize(MMAPW, MMAPH)
mapBorder:SetBackdrop( { bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = { left = -1, right = -1, top = -1, bottom = -1 } } )
mapBorder:SetBackdropColor(0, 0, 0, 0.8)
mapBorder:SetBackdropBorderColor(borderColor.r or 1, borderColor.g or 0.5, borderColor.b or 0, 1)
mapBorder:SetFrameStrata("LOW")

local label = CreateFrame("Frame", "SteakZoneText", mapBorder)
label:SetPoint("TOPLEFT", mapBorder, "TOPLEFT", 4, -4)
label:SetFrameStrata("MEDIUM")

local bg = label:CreateTexture(nil, "BACKGROUND")
bg:SetTexture(0, 0, 0, 0.8)
bg:SetAllPoints()
label.bg = bg

local text = label:CreateFontString(nil, "OVERLAY")
text:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 10, "OUTLINE")
text:SetPoint("CENTER", label, "CENTER", 0, 0)
label.text = text

local coordFrame = CreateFrame("Frame", nil, UIParent)

coordFrame:SetSize(80, 20)
coordFrame:SetPoint("BOTTOMLEFT", mapBorder, "BOTTOMLEFT", 4, 4)
coordFrame:SetFrameStrata("MEDIUM")
coordFrame:SetFrameLevel(mapBorder:GetFrameLevel()+2)
coordFrame:SetBackdrop( { bgFile = "Interface\\DialogFrame\\UI-DialogBox-BackGround-Dark", edgeFile = nil, tile = true, tileSize = 32, edgeSize = 0, insets = { left = 0, right = 0, top = 0, bottom = 0 } } )

local coordText = coordFrame:CreateFontString(nil, "OVERLAY")
coordText:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 10, "OUTLINE")
coordText:SetPoint("BOTTOMLEFT", coordFrame, "BOTTOMLEFT", 5, 5)
coordText:SetTextColor(1, 1, 1)
coordText:SetDrawLayer("OVERLAY", 7) 
coordText:SetShadowColor(0, 0, 0, 1)
coordText:SetShadowOffset(1, -1)

local mmbf = CreateFrame("Frame", nil, UIParent)
mmbf:SetSize(50, 50)
mmbf:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)

local function MoveMinimapButtons()
	local frames = {}

	local hideThese = {"MinimapBackdrop", "TimeManagerClockButton", "MinimapZoomOut", "MinimapZoomIn", "MiniMapWorldMapButton", "MinimapZoneTextButton"}

	local kids = {Minimap:GetChildren()}

	for k, v in pairs(kids) do
		if v:GetName() == "GuildInstanceDifficulty" or v:GetName() == "MiniMapInstanceDifficulty" then
			v:SetParent(mapBorder)
			v:SetFrameLevel(mapBorder:GetFrameLevel()+2)
			v:SetPoint("TOPRIGHT", mapBorder, "TOPRIGHT", 0, 0)
		elseif tContains(hideThese, v:GetName()) then
			v:Hide()
		else
			tinsert(frames, v:GetName())
		end
	end

	kids = {MinimapCluster:GetChildren()}

	for k, v in pairs(kids) do
		if v:GetName() == "GuildInstanceDifficulty" or v:GetName() == "MiniMapInstanceDifficulty" then
			v:SetParent(mapBorder)
			v:SetFrameLevel(mapBorder:GetFrameLevel()+2)
			v:SetPoint("TOPRIGHT", mapBorder, "TOPRIGHT", 0, 0)
		elseif tContains(hideThese, v:GetName()) then
			v:Hide()
		else
			tinsert(frames, v:GetName())
		end
	end

	kids = {MinimapBackdrop:GetChildren()}

	for k, v in pairs(kids) do
		if v:GetName() == "GuildInstanceDifficulty" or v:GetName() == "MiniMapInstanceDifficulty" then
			v:SetParent(mapBorder)
			v:SetFrameLevel(mapBorder:GetFrameLevel()+2)
			v:SetPoint("TOPRIGHT", mapBorder, "TOPRIGHT", 0, 0)
		elseif tContains(hideThese, v:GetName()) then
			v:Hide()
		else
			tinsert(frames, v:GetName())
		end
	end

	local sortTbl = {"GameTimeFrame", "MiniMapTrackingButton", "MiniMapMailFrame", "MiniMapLFGFrame", "MiniMapBattlefieldFrame"}

	local offset = 3

	for k, v in pairs(frames) do
		if tContains(sortTbl, v) then
			-- Do nothing the frame is already there.
		elseif _G[v]:IsShown() and _G[v]:IsVisible() then
			tinsert(sortTbl, v)
		else
			--tinsert(sortTbl, v)
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

local function OnUpdate(self, elapsed)
	self.coordTimer = (self.coordTimer or 0) + elapsed
	self.buttonUpdate = (self.buttonUpdate or 0) + elapsed
	
	if self.coordTimer >= 0.2 then
		local x, y = GetPlayerMapPosition("player")
	
		coordText:SetText(string.format("%.1f, %.1f", x * 100, y * 100))
		coordFrame:SetSize(math.max(coordFrame:GetWidth(), coordText:GetStringWidth()+10), coordText:GetHeight()+6)

		self.coordTimer = 0
	end

	if self.buttonUpdate >= 2 then
		MoveMinimapButtons()

		self.buttonUpdate = 0
	end
end

local function OnEvent(self, event, ...)
	if event == "UPDATE_INVENTORY_DURABILITY" then
		if not InCombatLockdown() then
			DurabilityFrame:ClearAllPoints()
			DurabilityFrame:SetPoint("TOPRIGHT", mapBorder, "TOPLEFT", -5, 0)
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		Minimap:SetParent(mapBorder)
		Minimap:ClearAllPoints()
		Minimap:SetPoint("CENTER", mapBorder, "CENTER", 0, 0)
		Minimap:SetSize(MMAPW-2, MMAPH-2)
		Minimap:SetScale(1)
		MinimapNorthTag:Hide()

		TimeManagerClockButton:Hide()
		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetPoint("TOPLEFT", UIParent, "TOPRIGHT", 0, 0)
		MinimapCluster:Hide()
		Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")

		DurabilityFrame:ClearAllPoints()
		DurabilityFrame:SetPoint("TOPRIGHT", mapBorder, "TOPLEFT", -5, 0)

		label.text:SetText(GetRealZoneText())
		label:SetSize(label.text:GetWidth()+20, label.text:GetHeight()+6)
	elseif event:match("^ZONE_CHANGED") then
		label.text:SetText(GetRealZoneText())
		label:SetSize(label.text:GetWidth()+20, label.text:GetHeight()+6)
	end
end

mapBorder:RegisterEvent("ZONE_CHANGED")
mapBorder:RegisterEvent("ZONE_CHANGED_INDOORS")
mapBorder:RegisterEvent("ZONE_CHANGED_NEW_AREA")
mapBorder:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
mapBorder:RegisterEvent("PLAYER_ENTERING_WORLD")

--mapBorder:RegisterEvent("MINIMAP_UPDATE_TRACKING")
--mapBorder:RegisterEvent("PLAYER_LOGIN")
--mapBorder:RegisterEvent("VARIABLES_LOADED")
--mapBorder:RegisterEvent("WORLD_MAP_UPDATE")
--mapBorder:RegisterEvent("CLOSE_WORLD_MAP")
--mapBorder:RegisterEvent("WORLD_MAP_NAME_UPDATE")
--mapBorder:RegisterEvent("MINIMAP_PING")

mapBorder:SetScript("OnEvent", OnEvent)
mapBorder:SetScript("OnUpdate", OnUpdate)

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	tooltip:ClearAllPoints()
	tooltip:SetOwner(parent, "ANCHOR_NONE")
	tooltip:SetPoint("BOTTOMRIGHT", mapBorder, "TOPRIGHT", -20, 20)
end)

MiniMapInstanceDifficulty:HookScript("OnShow", function(self)
	self:ClearAllPoints()
	self:SetParent(mapBorder)
	self:SetPoint("TOPRIGHT", mapBorder, "TOPRIGHT", 0, 0)
end)
