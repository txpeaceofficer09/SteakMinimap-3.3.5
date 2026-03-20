local f = CreateFrame("Frame", nil, UIParent)

local poiDots = {}

function MapFrame_UpdatePOI()
	for _, poi in ipairs(poiDots) do poi:Hide() end

	if not SteakMapConfigDB.showPOI then return end

	for i=1,GetNumMapLandmarks() do
		local icon = poiDots[i]
		
		if not icon then
			icon = CreateFrame("Button", nil, MapFrameSC)

			icon:SetSize(32, 32)
			icon:SetFrameStrata(MapFrameSC:GetFrameStrata())
			icon:SetFrameLevel(MapFrameSC:GetFrameLevel()+1)

			--poi:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			icon:SetScript("OnEnter", WorldMapPOI_OnEnter)
			icon:SetScript("OnLeave", WorldMapPOI_OnLeave)
			icon:SetScript("OnClick", WorldMapPOI_OnClick)
			
			local tex = icon:CreateTexture(nil, "OVERLAY")
			tex:SetSize(16, 16)
			tex:SetPoint("CENTER", 0, 0)
			tex:SetTexture("Interface\\Minimap\\POIIcons")
			
			icon.tex = tex
			poiDots[i] = icon
		end
		
		local name, description, textureIndex, x, y, mapLinkID = GetMapLandmarkInfo(i)
		local x1, x2, y1, y2 = WorldMap_GetPOITextureCoords(textureIndex)
		
		icon.tex:SetTexCoord(x1, x2, y1, y2)

		x = x * MapFrameSC:GetWidth()
		y = -y * MapFrameSC:GetHeight()
		
		icon:SetPoint("CENTER", MapFrameSC, "TOPLEFT", x, y)
		icon.name = name
		icon.description = description
		icon.mapLinkID = mapLinkID
	
		icon:Show()
	end
end

local function OnEvent(self, event, ...)
	MapFrame_UpdatePOI()
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("WORLD_MAP_UPDATE")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_INDOORS")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("CLOSE_WORLD_MAP")
f:RegisterEvent("WORLD_MAP_NAME_UPDATE")

f:SetScript("OnEvent", OnEvent)
