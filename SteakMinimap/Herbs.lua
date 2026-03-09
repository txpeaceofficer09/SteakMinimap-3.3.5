local f = CreateFrame("Frame", nil, UIParent)

local gmHerbDots = {}

local function OnEvent(self, event, ...)
	for _, dot in pairs(gmHerbDots) do dot:Hide() end

	if not GatherMateHerbDB then return end

	local zoneName = GetZoneText()
	if not zoneName then return end

	local zoneInfo = GatherMate.zoneData[zoneName]
	if not zoneInfo then return end

	local zoneID = zoneInfo[3]
	if not zoneID then return end

	local herbData = GatherMateHerbDB[zoneID]
	if not herbData then return end

	local mapW, mapH = MapFrameSC:GetSize()

	local index = 1
	for coord, herbType in pairs(herbData) do
		local x = floor(coord / 10000) / 10000
		local y = (coord % 10000) / 10000

		local dot = gmHerbDots[index]

		if not gmHerbDots[index] then
			dot = CreateFrame("Frame", nil, MapFrameSC)
			dot:SetSize(16, 16)

			local tex = dot:CreateTexture(nil, "OVERLAY")
			tex:SetAllPoints()
			dot.tex = tex
			gmHerbDots[index] = dot
		end

	        dot:ClearAllPoints()
	        dot:SetPoint("CENTER", MapFrameSC, "TOPLEFT", x * mapW, -y * mapH)

		local icon = GatherMate.nodeTextures["Herb Gathering"][herbType]

		if icon then
			dot.tex:SetTexture(icon)
		else
			dot.tex:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		end

		dot:Show()

		index = index + 1
	end
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("WORLD_MAP_UPDATE")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_INDOORS")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("WORLD_MAP_UPDATE")
f:RegisterEvent("CLOSE_WORLD_MAP")
f:RegisterEvent("WORLD_MAP_NAME_UPDATE")
f:RegisterEvent("LOOT_CLOSED")

f:SetScript("OnEvent", OnEvent)
