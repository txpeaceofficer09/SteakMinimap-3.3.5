local f = CreateFrame("Frame", nil, UIParent)

local repairIcons = {}

local function SaveRepairVendor()
	if not CanMerchantRepair() then return end

	local mapID = GetCurrentMapAreaID()
	if not mapID or mapID == 0 then return end

	local x, y = GetPlayerMapPosition("player")
	if x == 0 and y == 0 then return end

	SteakRepairVendorDB[mapID] = SteakRepairVendorDB[mapID] or {}

	-- dedupe: ignore if within 1% of an existing vendor
	for _, v in ipairs(SteakRepairVendorDB[mapID]) do
		if math.abs(v.x - x) < 0.01 and math.abs(v.y - y) < 0.01 then return end
	end

	local name = UnitName("npc") or UnitName("target") or "Repair Vendor"

	table.insert(SteakRepairVendorDB[mapID], { x = x, y = y, name = name })
end

function SteakMap_UpdateRepairVendors()
	for _, icon in ipairs(repairIcons) do icon:Hide() end

	local mapID = GetCurrentMapAreaID()
	local vendors = SteakRepairVendorDB[mapID]
	if not vendors then return end

	for i, v in ipairs(vendors) do
		local icon = repairIcons[i]

		if not icon then
			icon = CreateFrame("Button", nil, MapFrameSC)
			icon:SetSize(16, 16)

			local tex = icon:CreateTexture(nil, "OVERLAY")
			tex:SetAllPoints()
			tex:SetTexture("Interface\\MINIMAP\\TRACKING\\Repair.blp")
			icon.tex = tex

			icon.text = icon:CreateFontString(nil, "OVERLAY")
			icon.text:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 7, "OUTLINE")
			icon.text:SetPoint("TOP", icon, "BOTTOM", 0, -2)
			icon.text:Hide()

			icon:SetScript("OnEnter", function(self) self.text:Show() end)
			icon:SetScript("OnLeave", function(self) self.text:Hide() end)

			repairIcons[i] = icon
		end

		local mapW = MapFrameSC:GetWidth()
		local mapH = MapFrameSC:GetHeight()

		local finalX = v.x * mapW
		local finalY = -v.y * mapH

		icon:ClearAllPoints()
		icon:SetPoint("CENTER", MapFrameSC, "TOPLEFT", finalX, finalY)
		icon.text:SetText(v.name)
		icon:Show()
	end
end

local function OnEvent(self, event, ...)
	if event == "VARIABLES_LOADED" then
		SteakRepairVendorDB = SteakRepairVendorDB or {}
	elseif event == "MERCHANT_SHOW" then
		SaveRepairVendor()

		SteakMap_UpdateRepairVendors()
	else
		SteakMap_UpdateRepairVendors()
	end
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("MERCHANT_SHOW")
f:RegisterEvent("WORLD_MAP_UPDATE")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_INDOORS")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("WORLD_MAP_NAME_UPDATE")

f:SetScript("OnEvent", OnEvent)
