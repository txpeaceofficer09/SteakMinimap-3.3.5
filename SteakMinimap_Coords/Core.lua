local SteakMinimap = SteakMinimap
local mapBorder = SteakMinimap.Frames.MapBorder

local Module = {}

Module.Events = {
	"PLAYER_ENTERING_WORLD"
}

function Module:Initialize()
	self.frame = CreateFrame("Frame", "SteakCoords", mapBorder)
	self.frame:SetSize(80, 20)
	self.frame:SetPoint("BOTTOMLEFT", mapBorder, "BOTTOMLEFT", 4, 4)
	self.frame:SetFrameStrata("MEDIUM")
	self.frame:SetFrameLevel(mapBorder:GetFrameLevel() + 2)

	self.text = SteakMinimap:CreateFont(self.frame, 10)
	self.text:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 5, 5)

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
	local x, y = GetPlayerMapPosition("player")

	if not x or not y then
		self.text:SetText("")
		return
	end

	self.text:SetFormattedText("%.1f, %.1f", x * 100, y * 100)

	self.frame:SetSize(math.max(80, self.text:GetStringWidth() + 10), self.text:GetHeight() + 6)
end

SteakMinimap:RegisterModule(Module)
