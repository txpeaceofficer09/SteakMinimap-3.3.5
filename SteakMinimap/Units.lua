local f = CreateFrame("Frame", nil, UIParent)

local UnitDots = {}

local function TexCoord(object, texture, columns, rows, column, row)
	local width = 1 / columns
	local height = 1 / rows

	object:SetTexture(texture)
	object:SetTexCood((column-1)*width, column*width, (row-1)*height, row*height)
end

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
					dot:SetSize(10, 10)

					local icon = dot:CreateTexture(nil, "BACKGROUND")
					icon:SetAllPoints(dot)
					icon:SetTexture("Interface\\AddOns\\SteakMinimap\\unitdot.tga")
					dot.icon = icon

					dot:EnableMouse(true)

					dot:SetScript("OnEnter", function(self)
						if not self.unit or not UnitExists(self.unit) then return end

						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
						GameTooltip:SetUnit(self.unit)
						GameTooltip:Show()
					end)

					dot:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

					UnitDots[i] = dot
				end

				dot:ClearAllPoints()
				dot:SetPoint("CENTER", MapFrameSC, "TOPLEFT", x * MapFrameSC:GetWidth(), -y * MapFrameSC:GetHeight())

				iconIndex = GetRaidTargetIndex(unit)
				isDead = UnitIsDead(unit)
				isOffline = not UnitIsConnected(unit)
				dot.unit = unit

				local _, class = UnitClass(unit)
				local color = RAID_CLASS_COLORS[class] or {r=1, g=1, b=1}

				if isOffline then
					dot.icon:SetTexture("Interface\\CharacterFrame\\Disconnect-Icon")
					--dot.icon:SetTexCood(0, 1, 0, 1)
				elseif isDead then
					--dot.icon:SetTexture("Interface\\Minimap\\POIIcons")
					--dot.icon:SetTexCoord(0.56640625, 0.6328125, 0.00390625, 0.0703125)
					dot.icon:SetTexture("Interface\\AddOns\\SteakMinimap\\skull.tga")
					dot.icon:SetVertexColor(color.r, color.g, color.b)
				elseif iconIndex then
					dot.icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..iconIndex)
					--dot.icon:SetTexCood(0, 1, 0, 1)
					dot.icon:SetVertexColor(1, 1, 1)
				else
					dot.icon:SetTexture("Interface\\AddOns\\SteakMinimap\\unitdot.tga")
					--dot.icon:SetTexCood(0, 1, 0, 1)
					dot.icon:SetVertexColor(color.r, color.g, color.b)
				end

				dot:Show()
			end
		end
	end
end

f:SetScript("OnUpdate", OnUpdate)
