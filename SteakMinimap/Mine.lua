local f = CreateFrame("Frame", nil, UIParent)

local mineIcons = {}
local awaitingMineLoot = false

local MINIMAP_ZOOM_YARDS = {
	[0] = 300,
	[1] = 240,
	[2] = 180,
	[3] = 120,
	[4] = 80,
	[5] = 60
}

local MINE_ITEM_IDS = {
	["Copper Ore"] = 2770,
	["Tin Ore"] = 2771,
	["Silver Ore"] = 2775,
	["Iron Ore"] = 2772,
	["Gold Ore"] = 2776,
	["Mithril Ore"] = 3858,
	["Truesilver Ore"] = 7911,
	["Thorium Ore"] = 10620,
	["Fel Iron Ore"] = 23424,
	["Adamantite Ore"] = 23425,
	["Khorium Ore"] = 23426,
	["Eternium Ore"] = 23427,
	["Cobalt Ore"] = 36909,
	["Saronite Ore"] = 36912,
	["Titanium Ore"] = 36910
}

local function ExtractItem(msg)
	return msg:match("%[(.+)%]")
end

local function SaveMineNode(mineName)
	if not mineName or not awaitingMineLoot then return end

	SetMapToCurrentZone()
	local mapID = GetCurrentMapAreaID()
	if not mapID or mapID == 0 then return end

	local x, y = GetPlayerMapPosition("player")
	if x == 0 and y == 0 then return end

	SteakMineDB[mapID] = SteakMineDB[mapID] or {}

	for _, v in ipairs(SteakMineDB[mapID]) do
		if v.name == mineName and math.abs(v.x - x) < 0.002 and math.abs(v.y - y) < 0.002 then
			return
		end
	end

	table.insert(SteakMineDB[mapID], { x = x, y = y, name = mineName })
end

function SteakMap_UpdateMineNodes()
	for _, icon in ipairs(mineIcons) do icon:Hide() end

	SetMapToCurrentZone()
	local mapID = GetCurrentMapAreaID()
	local mines = SteakMineDB[mapID]
	if not mines then return end

	local px, py = GetPlayerMapPosition("player")
	if not px or px == 0 or py == 0 then return end

	local minimapW = Minimap:GetWidth()
	local minimapH = Minimap:GetHeight()

	local zoom = Minimap:GetZoom()
	local yardRadius = MINIMAP_ZOOM_YARDS[zoom] or 100

	-- Convert yards → pixels
	local pixelPerYard = minimapW / (yardRadius * 2)

	for i, v in ipairs(mines) do
		local icon = mineIcons[i]

		if not icon then
			icon = CreateFrame("Button", nil, Minimap)
			icon:SetSize(16, 16)

			local tex = icon:CreateTexture(nil, "BACKGROUND")
			tex:SetAllPoints()

			local iconPath = "Interface\\AddOns\\SteakMinimap\\Mine\\"..v.name:gsub("'", ""):gsub("%s+", "_"):lower()..".tga"

			tex:SetTexture(iconPath)
			icon.tex = tex

			mineIcons[i] = icon
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

local function OnEvent(self, event, ...)
	if event == "VARIABLES_LOADED" then
		SteakMineDB = SteakMineDB or {}
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, spellName, spellRank = ...
		
		if unit == "player" and spellName == "Mining" then
			awaitingMineLoot = true
			f:SetScript("OnUpdate", function(self, elapsed)
				self.timer = (self.timer or 0) + elapsed
				if self.timer < 0.5 then return end
				self.timer = 0
				
				awaitingMineLoot = false
			end)
		end
	elseif event == "CHAT_MSG_LOOT" then
		local mine = ExtractItem(...)

		if not mine then return end

		--if mine:match("Lotus$") then return end
		--if mine:match("^Crystallized") then return end

		SaveMineNode(mine)
		SteakMap_UpdateMineNodes()
	else
		SteakMap_UpdateMineNodes()
	end
end

f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("WORLD_MAP_UPDATE")
f:RegisterEvent("ZONE_CHANGED_INDOORS")
f:RegisterEvent("WORLD_MAP_NAME_UPDATE")
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
f:RegisterEvent("CHAT_MSG_LOOT")

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("PLAYER_STARTED_MOVING")
f:RegisterEvent("PLAYER_STOPPED_MOVING")

--f:SetScript("OnEvent", OnEvent)
