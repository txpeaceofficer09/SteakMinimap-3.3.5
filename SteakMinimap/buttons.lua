CreateFrame("Frame", "MMBF", UIParent)
MMBF:SetSize(50, 50)
MMBF:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)

function SteakMap_MoveMinimapButtons()
	local frames = {}
	local kids = {Minimap:GetChildren()}

	local hideThese = {"MinimapBackdrop", "TimeManagerClockButton", "MinimapZoomOut", "MinimapZoomIn", "MiniMapWorldMapButton", "MinimapZoneTextButton"}

	--GameTimeFrame:SetParent(MMBF)
	--GameTimeFrame:ClearAllPoints()
	--GameTimeFrame:SetPoint("TOPRIGHT", MMBF, "TOPRIGHT", 0, 0)

	for k, v in pairs(kids) do
		if v:GetName() == "GuildInstanceDifficulty" or v:GetName() == "MiniMapInstanceDifficulty" then
			v:SetParent(MapFrame)
			v:SetFrameLevel(MapFrameSC:GetFrameLevel()+2)
			v:SetPoint("TOPRIGHT", MapFrame, "TOPRIGHT", 0, 0)
		elseif tContains(hideThese, v:GetName()) then
			v:Hide()
		elseif v:GetName() ~= "MiniMapTracking" then
			tinsert(frames, v)
		end
	end

	kids = {MinimapCluster:GetChildren()}

	for k, v in pairs(kids) do
		if v:GetName() == "GuildInstanceDifficulty" or v:GetName() == "MiniMapInstanceDifficulty" then
			--v:SetParent(MapFrame)
			v:SetParent(mapBorder)
			--v:SetFrameLevel(MapFrameSC:GetFrameLevel()+2)
			v:SetFrameLevel(mapBorder:GetFrameLevel()+2)
			--v:SetPoint("TOPRIGHT", MapFrame, "TOPRIGHT", 0, 0)
			v:SetPoint("TOPRIGHT", mapBorder, "TOPRIGHT", 0, 0)
		elseif tContains(hideThese, v:GetName()) then
			v:Hide()
		else
			tinsert(frames, v)
		end
	end

	kids = {MinimapBackdrop:GetChildren()}

	for k, v in pairs(kids) do
		if v:GetName() == "GuildInstanceDifficulty" or v:GetName() == "MiniMapInstanceDifficulty" then
			--v:SetParent(MapFrame)
			v:SetParent(mapBorder)
			--v:SetFrameLevel(MapFrameSC:GetFrameLevel()+2)
			v:SetFrameLevel(mapBorder:GetFrameLevel()+2)
			--v:SetPoint("TOPRIGHT", MapFrame, "TOPRIGHT", 0, 0)
			v:SetPoint("TOPRIGHT", mapBorder, "TOPRIGHT", 0, 0)
		elseif tContains(hideThese, v:GetName()) then
			v:Hide()
		else
			tinsert(frames, v)
		end
	end

	local sortTbl = {GameTimeFrame, MiniMapTrackingButton, MiniMapMailFrame, MiniMapLFGFrame, MiniMapBattlefieldFrame}

	local offset = 3

	for k, v in pairs(frames) do
		if tContains(sortTbl, v) then
			-- Do nothing the frame is already there.
		elseif v:IsShown() and v:IsVisible() then
			tinsert(sortTbl, v)
		else
			--tinsert(sortTbl, v)
		end
	end
	
	for k, v in pairs(sortTbl) do
		v:SetParent(MMBF)
		v:ClearAllPoints()

		if k == 1 then
			v:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
		else
			v:SetPoint("TOP", sortTbl[(k-1)], "BOTTOM", 0, 0)
		end
	end

	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetParent(UIParent)
	MiniMapTracking:SetAllPoints(MiniMapTrackingButton)

	WatchFrame:SetParent(UIParent)
	WatchFrame:ClearAllPoints()
	WatchFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -50, -200)
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		SteakMap_MoveMinimapButtons()
	end
	--[[
	self:SetScript("OnUpdate", function(self, elapsed)
		self.timer = (self.timer or 0) + elapsed
		
		if self.timer >= 0.1 then
			self:SetScript("OnUpdate", nil)
			SteakMap_MoveMinimapButtons()
		end
	end)
	]]
end

local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer < 1 then return end
	self.timer = 0

	SteakMap_MoveMinimapButtons()
end

MMBF:RegisterEvent("PLAYER_ENTERING_WORLD")

MMBF:SetScript("OnEvent", OnEvent)
MMBF:SetScript("OnUpdate", OnUpdate)

MiniMapInstanceDifficulty:HookScript("OnShow", function(self)
	self:ClearAllPoints()
	--self:SetParent(MapFrame)
	self:SetParent(mapBorder)
	--self:SetPoint("TOPRIGHT", MapFrame, "TOPRIGHT", 0, 0)
	self:SetPoint("TOPRIGHT", mapBorder, "TOPRIGHT", 0, 0)
end)
