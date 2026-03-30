local f = CreateFrame("Frame", nil, UIParent)

local ReagentIcons = {}

local reagents = {
	"Infernal Stone",
	"Demonic Figurine",
	"Arcane Powder",
	"Wild Berries",
	"Wild Thornroot",
	"Holy Candle",
	"Sacred Candle",
	"Anhh",
	"Rune of Teleportation",
	"Rune of Portals",
	"Symbol of Divinity",
}

local function IsReagentVendor()
	--[[
	for i = 1, GetMerchantNumItems() do
		local name = GetMerchantItemInfo(i)
		for _, item in ipairs(reagents) do
			if item == name then return true end
		end
	end
	]]
	local flags = UnitOccupation("target")

	if flags and bit.band(flags, 0x00000800) ~= 0 then return true end

	return false
end

local function SaveReagentVendor()
	if not IsReagentVendor() then return end

	local mapID = GetCurrentMapAreaID()
	if not mapID or mapID == 0 then return end

	local x, y = GetPlayerMapPosition("player")
	if x == 0 and y == 0 then return end

	SteakReagentVendorDB[mapID] = SteakReagentVendorDB[mapID] or {}

	for _, v in ipairs(SteakReagentVendorDB[mapID]) do
		if math.abs(v.x - x) < 0.01 and math.abs(v.y - y) < 0.01 then return end
	end

	local name = UnitName("target") or "Reagent Vendor"

	table.insert(SteakReagentVendorDB[mapID], { x = x, y = y, name = name })
end

function SteakMap_UpdateReagentVendors()
	for _, icon in ipairs(ReagentIcons) do icon:Hide() end

	local mapID = GetCurrentMapAreaID()
	local vendors = SteakReagentVendorDB[mapID]
	if not vendors then return end

	for i, v in ipairs(vendors) do
		local icon = ReagentIcons[i]

		if not icon then
			icon = CreateFrame("Button", nil, MapFrameSC.overlay)
			icon:SetSize(16, 16)
			icon:SetFrameStrata(MapFrameSC.overlay:GetFrameStrata())
			icon:SetFrameLevel(MapFrameSC.overlay:GetFrameLevel()+1)

			local tex = icon:CreateTexture(nil, "OVERLAY")
			tex:SetAllPoints()
			tex:SetTexture("Interface\\MINIMAP\\TRACKING\\Reagents.blp")
			icon.tex = tex

			icon.text = icon:CreateFontString(nil, "OVERLAY")
			icon.text:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 7, "OUTLINE")
			icon.text:SetPoint("TOP", icon, "BOTTOM", 0, -2)
			icon.text:Hide()

			icon:SetScript("OnEnter", function(self) self.text:Show() end)
			icon:SetScript("OnLeave", function(self) self.text:Hide() end)

			ReagentIcons[i] = icon
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
		SteakReagentVendorDB = SteakReagentVendorDB or {}
	elseif event == "MERCHANT_SHOW" then
		SaveReagentVendor()

		SteakMap_UpdateReagentVendors()
	else
		SteakMap_UpdateReagentVendors()
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
