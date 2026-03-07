local f = CreateFrame("Frame", nil, UIParent)

local UnitDots = {}

local function OnUpdate(self, elapsed)
	local prefix = (GetNumRaidMembers() > 0) and "raid" or "party"
	local count = (prefix == "raid") and GetNumRaidMembers() or GetNumPartyMembers()

	for _, dot in pairs(UnitDots) do dot:Hide() end

	for i=1,count do
		local unit = prefix..i

		if not UnitIsUnit(unit, "player") then
			local x, y = GetPlayerMapPosition(unit)

			if x > 0 and y > 0 then
				local dot = UnitDots[i]

				if not dot then
					dot = CreateFrame("Frame", nil, MapFrameSC)
					dot:SetSize(6, 6)

					local icon = dot:CreateTexture(nil, "BACKGROUND")
					icon:SetAllPoints(dot)
					icon:SetTexture("Interface\\AddOns\\SteakMinimap\\unitdot.tga")
					dot.icon = icon

					UnitDots[i] = dot
				end

				dot:ClearAllPoints()
				dot:SetPoint("CENTER", MapFrameSC, "TOPLEFT", x * MapFrameSC:GetWidth(), -y * MapFrameSC:GetHeight())

				iconIndex = GetRaidTargetIndex(unit)
				isDead = UnitIsDead(unit)
				isOffline = not UnitIsConnected(unit)

				if isOffline then
					dot.icon:SetTexture("Interface\\CharacterFrame\\Disconnect-Icon")
				elseif isDead then
					dot.icon:SetTexture("Interface\\Minimap\\POIIcons")
					dot.icon:SetTexCoord(0.56640625, 0.6328125, 0.00390625, 0.0703125)
				elseif iconIndex then
					dot.icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..iconIndex)
				else
					local _, class = UnitClass(unit)
					local color = RAID_CLASS_COLORS[class] or {r=1, g=1, b=1}

					dot.icon:SetTexture("Interface\\AddOns\\SteakMinimap\\unitdot.tga")
					dot.icon:SetVertexColor(color.r, color.g, color.b)
				end

				dot:Show()
			end
		end
	end
end

f:SetScript("OnUpdate", OnUpdate)
