SteakMinimap = SteakMinimap or {}
local SteakMinimap = SteakMinimap

SteakMinimap.Modules = {}
SteakMinimap.Frames = {}

local mapBorder = CreateFrame("Frame", "SteakMapBorder", UIParent)
mapBorder:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -1, 20)
mapBorder:SetSize(220, 220)
mapBorder:SetFrameStrata("LOW")
SteakMinimap.Frames.MapBorder = mapBorder

function SteakMinimap:SetBackdrop(frame)
	local borderColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

	frame:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = { left = -1, right = -1, top = -1, bottom = -1 } })
	frame:SetBackdropColor(0, 0, 0, 0.8)
	frame:SetBackdropBorderColor(borderColor.r or 1, borderColor.g or 0.5, borderColor.b or 0, 1)
end

function SteakMinimap:CreateFont(frame, size)
	local text = frame:CreateFontString(nil, "OVERLAY")

	text:SetFont("Interface\\AddOns\\SteakMinimap\\Audiowide-Regular.ttf", size or 10, "OUTLINE")

	return text
end

function SteakMinimap:RegisterModule(module)
	assert(module, "SteakMinimap:RegisterModule() requires a module")

	table.insert(self.Modules, module)

	module.Core = self

	if module.Events then
		for _, event in ipairs(module.Events) do
			self:RegisterEvent(event)
		end
	end
end

function SteakMinimap:RegisterEvent(event)
	self.Frames.MapBorder:RegisterEvent(event)
end

function SteakMinimap:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		Minimap:ClearAllPoints()
		Minimap:SetParent(mapBorder)
		Minimap:SetPoint("CENTER", mapBorder, "CENTER", 0, 0)
		Minimap:SetSize(mapBorder:GetWidth()-2, mapBorder:GetHeight()-2)
		Minimap:SetScale(1)
		Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
	end

	for _, module in ipairs(self.Modules) do
		if module.OnEvent and module.Initialized then
			module:OnEvent(event, ...)
		end
	end
end

function SteakMinimap:OnUpdate(elapsed)
	local start = debugprofilestop()

	for _, module in ipairs(self.Modules) do
		if module.Initialize and not module.Initialized then
			module:Initialize()
			module.Initialized = true

			if debugprofilestop() - start >= 3 then return end
		end
	end

	for _, module in ipairs(self.Modules) do
		if module.OnUpdate and module.Initialized then
			module:OnUpdate(elapsed)
		end
	end
end

mapBorder:SetScript("OnEvent", function(_, event, ...) SteakMinimap:OnEvent(event, ...) end)
mapBorder:SetScript("OnUpdate", function(_, elapsed) SteakMinimap:OnUpdate(elapsed) end)

SteakMinimap:SetBackdrop(mapBorder)
SteakMinimap:RegisterEvent("PLAYER_ENTERING_WORLD")
