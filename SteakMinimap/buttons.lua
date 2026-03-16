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
			v:SetPoint("TOPLEFT", MapFrame, "TOPLEFT", 0, 0)
		elseif v:GetName() == nil or tContains(hideThese, v:GetName()) or v:GetName():match("^QuestieFrame") then
			v:Hide()
		elseif v:GetName() == "MinimapPing" then
			v:SetParent(MapFrameSC)
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
	local priority = {"MiniMapMailFrame", "MiniMapLFGFrame"}

	local offset = 3

	for k, v in pairs(frames) do
		if tContains(sortTbl, v) then
			-- Do nothing the frame is already there.
		elseif _G[v]:IsShown() then
			tinsert(sortTbl, offset, v)
			if tContains(priority, v) then offset = offset + 1 end
		else
			tinsert(sortTbl, v)
		end
		--[[
		if not tContains(sortTbl, v) and _G[v]:IsVisible() then
			tinsert(sortTbl, 3, v)
		else
			tinsert(sortTbl, v)
		end
		]]
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
