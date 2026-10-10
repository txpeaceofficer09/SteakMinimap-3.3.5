local SteakMinimap = SteakMinimap

local Module = {}

Module.Events = {
	"PLAYER_ENTERING_WORLD",
	"ZONE_CHANGED",
	"ZONE_CHANGED_INDOORS",
	"ZONE_CHANGED_NEW_AREA"
}

function Module:Initialize()
	local mapBorder = SteakMinimap.Frames.MapBorder

	self.frame = CreateFrame("Frame", "SteakZoneText", mapBorder)
	self.frame:SetPoint("TOPLEFT", mapBorder, "TOPLEFT", 4, -4)
	self.frame:SetFrameStrata("MEDIUM")

	self.text = SteakMinimap:CreateFont(self.frame, 10)

	self.text:SetPoint("CENTER", self.frame, "CENTER")
end

function Module:OnEvent(event, ...)
	local zone = GetRealZoneText()

	self.text:SetText(zone)

	self.frame:SetSize(self.text:GetWidth() + 20, self.text:GetHeight() + 6)
end


SteakMinimap:RegisterModule(Module)
