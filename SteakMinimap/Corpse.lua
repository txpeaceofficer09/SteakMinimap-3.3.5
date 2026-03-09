local f = CreateFrame("Frame", nil, UIParent)

local corpse = CreateFrame("Frame", "SteakCorpseIcon", MapFrameSC, "WorldMapCorpseTemplate")
--local corpse = CreateFrame("Frame", "SteakCorpse", MapFrameSC, "SecureHandlerStateTemplate")
--RegisterStateDriver(corpse, "visibility", "[@player,nodead] hide; [@player,dead] show; hide")
MapFrameSC.corpse = corpse
--[[
local corpse = CreateFrame("Frame", "SteakCorpse", MapFrameSC)

corpse:SetSize(32, 32)
corpse.icon = corpse:CreateTexture(nil, "BACKGROUND")
corpse.icon:SetAllPoints()
corpse.icon:SetTexture("Interface\\AddOns\\SteakMinimap\\corpse.tga")
MapFrameSC.corpse = corpse
]]

local function UpdateCorpseOnMap()
	local x, y = GetCorpseMapPosition()

	if not x or not y or ( x == 0 and y == 0 ) then
		MapFrameSC.corpse:Hide()
		return
	end

	local w, h = MapFrameSC:GetSize()

	MapFrameSC.corpse:ClearAllPoints()
	MapFrameSC.corpse:SetPoint("CENTER", MapFrameSC, "TOPLEFT", x * w, -y * h)
	MapFrameSC.corpse:Show()
end

local function OnEvent(self, event, ...)
	UpdateCorpseOnMap()
end

local function OnUpdate(self, elapsed)
	UpdateCorpseOnMap()
end

--[[
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_ALIVE")
f:RegisterEvent("PLAYER_UNGHOST")
f:RegisterEvent("PLAYER_GHOST")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_DEAD")

f:SetScript("OnEvent", OnEvent)
]]

f:SetScript("OnUpdate", OnUpdate)
