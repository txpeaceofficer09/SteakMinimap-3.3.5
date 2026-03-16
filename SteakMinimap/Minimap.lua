local mm = CreateFrame("Minimap", "SteakMinimap", MapFrameSC)

local zoneOverride = {
	["Barrens"] = {
		["Minimap"] = {
			["Size"] = { width = 40, height = 40 },
			["Zoom"] = 1
		}
	},
	["BlastedLands"] = {
		["Minimap"] = {
			["Size"] = { width = 145, height = 145 },
			["Zoom"] = 1
		}
	},
	["Desolace"] = {
		["Minimap"] = {
			["Size"] = { width = 90, height = 90 },
			["Zoom"] = 1
		}
	},
	["EasternPlaguelands"] = {
		["Minimap"] = {
			["Size"] = { width = 95, height = 95 },
			["Zoom"] = 1
		}
	},
	["IcecrownGlacier"] = {
		["Minimap"] = {
			["Size"] = { width = 70, height = 70 },
			["Zoom"] = 1
		}
	},
	["LakeWintergrasp"] = {
		["Minimap"] = {
			["Size"] = { width = 140, height = 140 },
			["Zoom"] = 1
		}
	},
	["Maraudon"] = {
		["Minimap"] = {
			["Size"] = { width = 70, height = 70 },
			["Zoom"] = 1
		}
	},
	["Ogrimmar"] = {
		["Minimap"] = {
			["Size"] = { width = 75, height = 75 },
			["Zoom"] = 3
		}
	},
	["SholazarBasin"] = {
		["Minimap"] = {
			["Size"] = { width = 90, height = 90 },
			["Zoom"] = 1
		}
	},
	["SwampOfSorrows"] = {
		["Minimap"] = {
			["Size"] = { width = 150, height = 150 },
			["Zoom"] = 1
		}
	},
	["Tanaris"] = {
		["Minimap"] = {
			["Size"] = { width = 59, height = 59 },
			["Zoom"] = 1
		}
	},
	["Undercity"] = {
		["Minimap"] = {
			["Size"] = { width = 130, height = 130 },
			["Zoom"] = 1
		}
	},
	["Zangarmarsh"] = {
		["Minimap"] = {
			["Size"] = { width = 85, height = 85 },
			["Zoom"] = 1
		}
	}
}

local function IsInCity()
    local channels = {GetChannelList()}
    
    for i = 1, #channels, 2 do
        local id, name = channels[i], channels[i+1]

        if string.find(name, "Trade") then
            return true
        end
    end

    return false 
end

function SteakMap_UpdateMinimap()
	local mapFileName = GetMapInfo()

	if not InCombatLockdown() then
		if mapFileName and zoneOverride[mapFileName] then
			local override = zoneOverride[mapFileName]
			local zoom = override.Minimap.Zoom or 1
			local size = override.Minimap.Size or {width = 100, height = 100}

			mm:SetZoom(zoom)
			mm:SetSize(size.width, size.height)
		elseif IsInInstance() then
			mm:Hide()
		elseif IsInCity() then
			mm:SetZoom(3)
			mm:SetSize(150, 150)
			mm:Show()
		else
			mm:Show()
			mm:SetSize(70, 70)
			mm:SetZoom(1)
		end
	end
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		mm:SetFrameLevel(MapFrameSC:GetFrameLevel()+2)
		TimeManagerClockButton:Hide()
		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetPoint("TOPLEFT", UIParent, "TOPRIGHT", 0, 0)
		MinimapCluster:Hide()
		Minimap:Hide()
		mm:SetAlpha(0)
		--mm:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
	elseif event == "PLAYER_LOGIN" then
		mm:SetMovable(true)
		mm:SetUserPlaced(true)
		--mm:SetParent(MapFrameSC)
	elseif event == "WORLD_MAP_UPDATE" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "WORLD_MAP_NAME_UPDATE" or event == "ZONE_CHANGED_NEW_AREA" then
		MapFrame_UpdateTextures()
	end
end

mm:RegisterEvent("PLAYER_LOGIN")
mm:RegisterEvent("PLAYER_ENTERING_WORLD")

mm:RegisterEvent("WORLD_MAP_UPDATE")
mm:RegisterEvent("ZONE_CHANGED")
mm:RegisterEvent("ZONE_CHANGED_INDOORS")
mm:RegisterEvent("ZONE_CHANGED_NEW_AREA")
mm:RegisterEvent("CLOSE_WORLD_MAP")
mm:RegisterEvent("WORLD_MAP_NAME_UPDATE")

--f:RegisterEvent("MINIMAP_UPDATE_TRACKING")

mm:SetScript("OnEvent", OnEvent)

mm:SetScript("OnUpdate", function(self, elapsed)
	local unitX, unitY = GetPlayerMapPosition("player")

	if unitX == 0 and unitY == 0 then return end
	if InCombatLockdown() then return end

	SteakMap_UpdateMinimap()

	if IsAltKeyDown() then
		self:SetAlpha(1)
	else
		self:SetAlpha(0)
	end

	local mapWidth = MapFrameSC:GetWidth()
	local mapHeight = MapFrameSC:GetHeight()

	local offsetX = 0
	local offsetY = 0

	local mmX = (unitX * mapWidth) + offsetX
	local mmY = (-unitY * mapHeight) - offsetY

	self:ClearAllPoints()
	self:SetPoint("CENTER", MapFrameSC, "TOPLEFT", mmX, mmY)
end)
