local label = CreateFrame("Frame", "SteakZoneText", MapFrame)
label:SetPoint("TOPLEFT", MapFrame, "TOPLEFT", 4, -4)

local bg = label:CreateTexture(nil, "BACKGROUND")
bg:SetTexture(0, 0, 0, 0.8)
bg:SetAllPoints()
label.bg = bg

local text = label:CreateFontString(nil, "OVERLAY")
text:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 10, "OUTLINE")
text:SetPoint("CENTER", label, "CENTER", 0, 0)
label.text = text

local function OnEvent(self, event, ...)
	self.text:SetText(GetRealZoneText())
	self:SetSize(self.text:GetWidth()+20, self.text:GetHeight()+6)
end

label:RegisterEvent("PLAYER_ENTERING_WORLD")
--label:RegisterEvent("WORLD_MAP_UPDATE")
label:RegisterEvent("ZONE_CHANGED")
label:RegisterEvent("ZONE_CHANGED_INDOORS")
label:RegisterEvent("ZONE_CHANGED_NEW_AREA")
--label:RegisterEvent("WORLD_MAP_NAME_UPDATE")

label:SetScript("OnEvent", OnEvent)
