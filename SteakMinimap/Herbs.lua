local f = CreateFrame("Frame", nil, UIParent)

local herbIcons = {}
local awaitingHerbLoot = false

local MINIMAP_ZOOM_YARDS = {
	[0] = 300,
	[1] = 240,
	[2] = 180,
	[3] = 120,
	[4] = 80,
	[5] = 60
}

local HERB_ITEM_IDS = {
	["Peacebloom"]        = 2447,
	["Silverleaf"]        = 765,
	["Earthroot"]         = 2449,
	["Mageroyal"]         = 785,
	["Briarthorn"]        = 2450,
	["Bruiseweed"]        = 2453,
	["Wild Steelbloom"]   = 3355,
	["Kingsblood"]        = 3356,
	["Grave Moss"]        = 3369,
	["Liferoot"]          = 3357,
	["Fadeleaf"]          = 3818,
	["Khadgar's Whisker"] = 3358,
	["Wintersbite"]       = 3819,
	["Stranglekelp"]      = 3820,
	["Goldthorn"]         = 3821,
	["Firebloom"]         = 4625,
	["Sungrass"]          = 8838,
	["Arthas' Tears"]     = 8836,
	["Blindweed"]         = 8839,
	["Ghost Mushroom"]    = 8845,
	["Gromsblood"]        = 8846,
	["Golden Sansam"]     = 13464,
	["Dreamfoil"]         = 13463,
	["Mountain Silversage"]= 13465,
	["Plaguebloom"]       = 13466,
	["Icecap"]            = 13467,
	["Black Lotus"]       = 13468,
	["Felweed"]           = 22785,
	["Dreaming Glory"]    = 22786,
	["Ragveil"]           = 22787,
	["Flame Cap"]         = 22788,
	["Terocone"]          = 22789,
	["Ancient Lichen"]    = 22790,
	["Netherbloom"]       = 22791,
	["Nightmare Vine"]    = 22792,
	["Mana Thistle"]      = 22793,
	["Goldclover"]        = 36901,
	["Tiger Lily"]        = 36904,
	["Talandra's Rose"]   = 36907,
	["Lichbloom"]         = 36905,
	["Icethorn"]          = 36906,
	["Frozen Herb"]       = 39970
}

local function ExtractItem(msg)
	return msg:match("%[(.+)%]")
end

local function SaveHerbNode(herbName)
	if not herbName or not awaitingHerbLoot then return end

	SetMapToCurrentZone()
	local mapID = GetCurrentMapAreaID()
	if not mapID or mapID == 0 then return end

	local x, y = GetPlayerMapPosition("player")
	if x == 0 and y == 0 then return end

	SteakHerbDB[mapID] = SteakHerbDB[mapID] or {}

	for _, v in ipairs(SteakHerbDB[mapID]) do
		--if v.name == herbName and math.abs(v.x - x) < 0.01 and math.abs(v.y - y) < 0.01 then
		if v.name == herbName and math.abs(v.x - x) < 0.002 and math.abs(v.y - y) < 0.002 then
			return
		end
	end

	table.insert(SteakHerbDB[mapID], { x = x, y = y, name = herbName })
end

--[[
function SteakMap_UpdateHerbNodes()
	for _, icon in ipairs(herbIcons) do icon:Hide() end

	local mapID = GetCurrentMapAreaID()
	local herbs = SteakHerbDB[mapID]

	if not herbs then return end

	for i, v in ipairs(herbs) do
		local icon = herbIcons[i]

		if not icon then
			icon = CreateFrame("Button", nil, MapFrameSC.overlay)
			icon:SetSize(16, 16)
			icon:SetFrameStrata(MapFrameSC.overlay:GetFrameStrata())
			icon:SetFrameLevel(MapFrameSC.overlay:GetFrameLevel()+1)

			local tex = icon:CreateTexture(nil, "BACKGROUND")
			tex:SetAllPoints()
			--tex:SetTexture("Interface\\MINIMAP\\TRACKING\\ObjectHerb.blp")
			local itemID = HERB_ITEM_IDS[v.name]
			--local iconPath = itemID and GetItemIcon(itemID) or "Interface\\MINIMAP\\TRACKING\\ObjectHerb.blp"
			local iconPath = "Interface\\AddOns\\SteakMinimap\\Herb\\"..v.name:gsub("'", ""):gsub("%s+", "_"):lower()..".tga"
			tex:SetTexture(iconPath)
			icon.tex = tex

			icon.text = icon:CreateFontString(nil, "ARTWORK")
			icon.text:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", 7, "OUTLINE")
			icon.text:SetPoint("TOP", icon, "BOTTOM", 0, -2)
			icon.text:Hide()

			icon:SetScript("OnEnter", function(self) self.text:Show() end)
			icon:SetScript("OnLeave", function(self) self.text:Hide() end)

			herbIcons[i] = icon
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
]]

--[[
function SteakMap_UpdateHerbNodes()
	for _, icon in ipairs(herbIcons) do icon:Hide() end

	SetMapToCurrentZone()
	local mapID = GetCurrentMapAreaID()
	local herbs = SteakHerbDB[mapID]

	if not herbs then return end

	local px, py = GetPlayerMapPosition("player")
	if not px or px == 0 or py == 0 then return end

	local minimapW = Minimap:GetWidth()
	local minimapH = Minimap:GetHeight()

	local zoom = Minimap:GetZoom()
	local yardRadius = MINIMAP_ZOOM_YARDS[zoom] or 100

	-- Convert yards → pixels
	local pixelPerYard = minimapW / (yardRadius * 2)

	for i, v in ipairs(herbs) do
		local icon = herbIcons[i]

		if not icon then
			icon = CreateFrame("Button", nil, Minimap)
			icon:SetSize(16, 16)

			local tex = icon:CreateTexture(nil, "BACKGROUND")
			tex:SetAllPoints()

			local iconPath = "Interface\\AddOns\\SteakMinimap\\Herb\\"..v.name:gsub("'", ""):gsub("%s+", "_"):lower()..".tga"

			tex:SetTexture(iconPath)
			icon.tex = tex

			herbIcons[i] = icon
		end

		-- World map normalized offset
		local dx = (v.x - px)
		local dy = (v.y - py)

		-- Convert normalized map coords → yards
		-- 1000 yards is a decent approximation for most Wrath zones
		local yardsX = dx * 1000
		local yardsY = dy * 1000

		-- Convert yards → minimap pixels
		local pxOffset = yardsX * pixelPerYard
		local pyOffset = yardsY * pixelPerYard

		-- Hide nodes outside minimap
		if math.abs(pxOffset) <= minimapW/2 and math.abs(pyOffset) <= minimapH/2 then
			icon:ClearAllPoints()
			icon:SetPoint("CENTER", Minimap, "CENTER", pxOffset, -pyOffset)
			icon:Show()
		else
			icon:Hide()
		end
	end
end
]]

function SteakMap_UpdateHerbNodes()
    for _, icon in ipairs(herbIcons) do icon:Hide() end

    SetMapToCurrentZone()
    local mapID = GetCurrentMapAreaID()
    local herbs = SteakHerbDB[mapID]
    if not herbs then return end

    local px, py = GetPlayerMapPosition("player")
    if not px or px == 0 or py == 0 then return end

    -- REAL zone size in yards (Wrath API)
    local zoneW, zoneH = GetMapWorldSize(mapID)
    if not zoneW or not zoneH then return end

    local minimapW = Minimap:GetWidth()
    local minimapH = Minimap:GetHeight()

    local zoom = Minimap:GetZoom()
    local yardRadius = MINIMAP_ZOOM_YARDS[zoom] or 100
    local pixelPerYard = minimapW / (yardRadius * 2)

    -- Minimap rotation (Wrath API)
    local facing = GetPlayerFacing()
    local sinF = math.sin(facing)
    local cosF = math.cos(facing)

    for i, v in ipairs(herbs) do
        local icon = herbIcons[i]

        if not icon then
            icon = CreateFrame("Button", nil, Minimap)
            icon:SetSize(16, 16)

            local tex = icon:CreateTexture(nil, "BACKGROUND")
            tex:SetAllPoints()

            local iconPath = "Interface\\AddOns\\SteakMinimap\\Herb\\"..v.name:gsub("'", ""):gsub("%s+", "_"):lower()..".tga"
            tex:SetTexture(iconPath)
            icon.tex = tex

            herbIcons[i] = icon
        end

        -- Convert normalized → yards
        local dx = (v.x - px) * zoneW
        local dy = (v.y - py) * zoneH

        -- Rotate opposite minimap rotation
        local rdx = dx * cosF - dy * sinF
        local rdy = dx * sinF + dy * cosF

        -- Convert yards → minimap pixels
        local pxOffset = rdx * pixelPerYard
        local pyOffset = rdy * pixelPerYard

        -- Hide nodes outside minimap
        if math.abs(pxOffset) <= minimapW/2 and math.abs(pyOffset) <= minimapH/2 then
            icon:ClearAllPoints()
            icon:SetPoint("CENTER", Minimap, "CENTER", pxOffset, -pyOffset)
            icon:Show()
        else
            icon:Hide()
        end
    end
end

local function OnEvent(self, event, ...)
	if event == "VARIABLES_LOADED" then
		SteakHerbDB = SteakHerbDB or {}
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, spellName, spellRank = ...
		
		if unit == "player" and spellName == "Herb Gathering" then
			awaitingHerbLoot = true
			f:SetScript("OnUpdate", function(self, elapsed)
				self.timer = (self.timer or 0) + elapsed
				if self.timer < 0.5 then return end
				self.timer = 0
				
				awaitingHerbLoot = false
			end)
		end
	elseif event == "CHAT_MSG_LOOT" then
		local herb = ExtractItem(...)

		if not herb then return end

		if herb:match("Lotus$") then return end
		if herb:match("^Crystallized") then return end

		SaveHerbNode(herb)
		--SteakMap_UpdateHerbNodes()
	else
		--SteakMap_UpdateHerbNodes()
	end
end

local updateThrottle = 0

local function ThrottledUpdate(self, elapsed)
    updateThrottle = updateThrottle + elapsed
    if updateThrottle < 0.1 then return end   -- update 10 times per second
    updateThrottle = 0

    SteakMap_UpdateHerbNodes()
end

f:RegisterEvent("VARIABLES_LOADED")
--f:RegisterEvent("WORLD_MAP_UPDATE")
--f:RegisterEvent("ZONE_CHANGED_INDOORS")
--f:RegisterEvent("WORLD_MAP_NAME_UPDATE")
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
f:RegisterEvent("CHAT_MSG_LOOT")

--f:RegisterEvent("PLAYER_ENTERING_WORLD")
--f:RegisterEvent("ZONE_CHANGED")
--f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
--f:RegisterEvent("PLAYER_STARTED_MOVING")
--f:RegisterEvent("PLAYER_STOPPED_MOVING")

--f:SetScript("OnEvent", OnEvent)
--f:SetScript("OnUpdate", ThrottledUpdate)
