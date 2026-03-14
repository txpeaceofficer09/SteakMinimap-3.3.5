local f = CreateFrame("Frame", nil, UIParent)

local poiDots = {}

function MapFrame_UpdatePOI()
	for _, poi in ipairs(poiDots) do poi:Hide() end

	if not SteakMapConfigDB.showPOI then return end

	for i=1,GetNumMapLandmarks() do
		local poi = poiDots[i]
		
		if not poi then
			local poi = CreateFrame("Button", nil, MapFrameSC)
			
			poi:SetSize(32, 32)
			poi:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			poi:SetScript("OnEnter", WorldMapPOI_OnEnter)
			poi:SetScript("OnLeave", WorldMapPOI_OnLeave)
			poi:SetScript("OnClick", WorldMapPOI_OnClick)
			
			local tex = poi:CreateTexture(nil, "OVERLAY")
			tex:SetSize(16, 16)
			tex:SetPoint("CENTER", 0, 0)
			tex:SetTexture("Interface\\Minimap\\POIIcons")
			
			poi.tex = tex
			poiDots[i] = poi
		end
		
		local name, description, textureIndex, x, y, mapLinkID = GetMapLandmarkInfo(i)
		local x1, x2, y1, y2 = WorldMap_GetPOITextureCoords(textureIndex)
		
		poi.tex:SetTexCoord(x1, x2, y1, y2)
		x = x * MapFrameSC:GetWidth()
		y = -y * MapFrameSC:GetHeight()
		
		poi:SetPoint("CENTER", MapFrameSC, "TOPLEFT", x, y)
		poi.name = name
		poi.description = description
		poi.mapLinkID = mapLinkID
		
		poi:Show()
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
