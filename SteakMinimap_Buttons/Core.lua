local SteakMinimap = SteakMinimap
local mapBorder = SteakMinimap.Frames.MapBorder

local Module = {}

Module.Events = {
	"PLAYER_ENTERING_WORLD"
}

function Module:Contains(tbl, value)
	for _, v in ipairs(tbl) do
		if v == value then
			return true
		end
	end

	return false
end

function Module:IsQuestieFrame(frame)
	local name = frame:GetName()

	return name and name:match("^Questie") ~= nil
end

function Module:IsGathererFrame(frame)
	local name = frame:GetName()

	return name and name:match("^GatherNote") ~= nil
end

function Module:HideFrame(frame)
	if not frame then
		return
	end

	if not self.hidden[frame] then
		self.hidden[frame] = true

		frame:HookScript("OnShow", function(self)
			self:Hide()
		end)
	end

	frame:Hide()
end

function Module:GetMaxSize(tbl)
	local w, h = 0, 0

	for _, button in pairs(tbl) do
		local w2, h2 = button:GetSize()

		if w2 > w then w = w2 end
		if h2 > h then h = h2 end
	end

	if h > w then w = h end

	return w
end

function Module:RegisterButton(button)
	if not self:Contains(self.buttons, button) then
		table.insert(self.buttons, button)
	end
end

function Module:CollectChildren(parent)
	if not parent then return end

	local children = { parent:GetChildren() }

	for _, child in pairs(children) do
		if self:Contains(self.hideThese, child) then
			self:HideFrame(child)
		elseif self:Contains(self.difficulty, child) then
			child:SetParent(mapBorder)
			child:SetFrameLevel(mapBorder:GetFrameLevel() + 2)
			child:ClearAllPoints()
			child:SetPoint("TOPRIGHT", mapBorder, "TOPRIGHT", 0, 0)
		elseif child ~= MinimapPing and not self:IsQuestieFrame(child) and not self:IsGathererFrame(child) then
			self:RegisterButton(child)
		end
	end
end

function Module:Initialize()
	self.maxRows = 6

	self.hideThese = {
		MinimapCluster,
		MinimapBackdrop,
		TimeManagerClockButton,
		MinimapZoomOut,
		MinimapZoomIn,
		MiniMapWorldMapButton,
		MinimapZoneTextButton,
		GameTimeFrame
	}

	self.priority = {
		MinimapMailFrame,
		MinimapTrackingButton,
		MinimapLFGFrame,
		MinimapBattlefieldFrame
	}

	self.difficulty = {
		GuildInstanceDifficulty,
		MiniMapInstanceDifficulty
	}

	self.hidden = {}
	self.buttons = {}

	self.frame = CreateFrame("Frame", "SteakMinimapButtons", mapBorder)

	self.frame:SetSize(50, 50)
	self.frame:SetPoint("TOPRIGHT", mapBorder, "TOPLEFT", -4, 0)

	for _, frame in pairs(self.hideThese) do
		self:HideFrame(frame)
	end

	WatchFrame:SetParent(UIParent)
	WatchFrame:ClearAllPoints()
	WatchFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -20, -20)

	self.frame:SetScript("OnUpdate", function(_, elapsed) self:OnUpdate(elapsed) end)
end

function Module:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:Update()
	end
end

function Module:OnUpdate(elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer < 0.2 then return end
	self.timer = 0

	self:Update()
end

function Module:Update()
	for _, frame in pairs(self.difficulty) do
		if frame then
				frame:SetParent(mapBorder)
				frame:SetFrameLevel(mapBorder:GetFrameLevel() + 2)
				frame:ClearAllPoints()
				frame:SetPoint("TOPRIGHT", mapBorder, "TOPRIGHT", 0, 0)
		end
	end

	self:CollectChildren(Minimap)
	self:CollectChildren(MinimapCluster)
	self:CollectChildren(MinimapBackdrop)

	local buttons = {}

	for _, button in pairs(self.buttons) do
		if button:IsShown() then table.insert(buttons, button) end
	end

	local x, y = 0, 0

	local size = self:GetMaxSize(buttons)

	for i, button in ipairs(buttons) do
		button:ClearAllPoints()
		button:SetParent(mmbf)

		if i % self.maxRows == 1 and i ~= 1 then
			y = 0
			x = x + size
		end

		button:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -x, -y)

		y = y + size
	end
end

SteakMinimap:RegisterModule(Module)
