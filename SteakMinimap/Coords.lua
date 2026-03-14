local coordFrame = CreateFrame("Frame", nil, UIParent)

coordFrame:SetSize(80, 20)
coordFrame:SetPoint("BOTTOMLEFT", MapFrame, "BOTTOMLEFT", 0, 0)
coordFrame:SetFrameStrata("HIGH")
coordFrame:SetFrameLevel(f:GetFrameLevel()+2)
coordFrame:SetBackdrop( { bgFile = "Interface\\DialogFrame\\UI-DialogBox-BackGround-Dark", edgeFile = nil, tile = true, tileSize = 32, edgeSize = 0, insets = { left = 0, right = 0, top = 0, bottom = 0 } } )

local coordText = coordFrame:CreateFontString(nil, "OVERLAY")
coordText:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 10, "OUTLINE")
coordText:SetPoint("BOTTOMLEFT", coordFrame, "BOTTOMLEFT", 5, 5)
coordText:SetTextColor(1, 1, 1)
coordText:SetDrawLayer("OVERLAY", 7) 
coordText:SetShadowColor(0, 0, 0, 1)
coordText:SetShadowOffset(1, -1)

local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer < 0.1 then return end
	self.timer = 0
	
	coordText:SetText(string.format("%.1f, %.1f", unitX * 100, unitY * 100))
	coordFrame:SetWidth(coordText:GetWidth()+10)	
end

coordFrame:SetScript("OnUpdate", OnUpdate)
