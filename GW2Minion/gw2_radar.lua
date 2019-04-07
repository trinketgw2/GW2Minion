--[[
	MMOMINION GW2 RADAR.
	Created by: Jorith
	
	Add type to track to rader:
	
	local player_friend = {
		name		= "Player Friend", -- Name of this type.
		groupName	= "player", -- Name of the group it belongs to.
		list		= "CharacterList", -- What entity list to check for this type.
		variables	= { -- default set of variables. More can be added, but use would have to programmed in.
			compass	= {guiType = "Checkbox",	name = "compass",	value = false,}, -- guiType specifies the kind of gui element. (only "Checkbox" and "ColorEdit4" are supported atm, let me know if you need more.)
			radar3D	= {guiType = "Checkbox",	name = "radar 3D",	value = false,},
			color	= {guiType = "ColorEdit4",	name = "Color",		value = 2516647680,},
		},
		filter = { -- The filters for this type. Each line is a seperate filter, entity only has to match one complete filter.
			{["isplayer"] = true, ["attitude"] = GW2.ATTITUDE.Friendly, ["alive"] = true,}, -- filter for "player == true" AND "attitude" == GW2.ATTITUDE.Friendly AND "alive" == true
			{["isplayer"] = true, ["attitude"] = GW2.ATTITUDE.Friendly, ["alive"] = false,}, -- filter for "player == true" AND "attitude" == GW2.ATTITUDE.Friendly AND "alive" == false
		},
	}
	gw2_radar.addType(player_friend) -- add the created entry to the radar.
	

]]
-- Create radar variable.
gw2_radar = {}

-- gw2_radar variables.
gw2_radar.mainWindow		= {name = "Radar", open = false, visible = false}
gw2_radar.parseTicks		= 0
gw2_radar.parseTickDelay	= 30 -- About 30 times a second.
gw2_radar.computeTicks		= 0
gw2_radar.computeTickDelay	= 15 -- About 60 times a second.
gw2_radar.compassData		= {}
gw2_radar.compassActive		= false
gw2_radar.radar3DActive		= false
gw2_radar.compassShowPath	= false
gw2_radar.radar3DShowPath	= false
gw2_radar.radarTypes		= {}
gw2_radar.settingsGroups	= {}
gw2_radar.filterList		= {}
gw2_radar.trackEntities		= {}
gw2_radar.compassPath		= {}
gw2_radar.icons				= {
	--[profession] = pathToIcon_profession
}


function gw2_radar.Init()
	gw2_radar.updateCompassData()
	
	Settings.gw2_radar.compassActive = Settings.gw2_radar.compassActive or false
	gw2_radar.compassActive = Settings.gw2_radar.compassActive
	
	Settings.gw2_radar.radar3DActive = Settings.gw2_radar.radar3DActive or false
	gw2_radar.radar3DActive = Settings.gw2_radar.radar3DActive
	
	Settings.gw2_radar.compassShowPath = Settings.gw2_radar.compassShowPath or false
	gw2_radar.compassShowPath = Settings.gw2_radar.compassShowPath
	
	Settings.gw2_radar.compassPathColor = Settings.gw2_radar.compassPathColor or 4294967295
	gw2_radar.compassPathColor = Settings.gw2_radar.compassPathColor
	
	gw2_radar.loadSettings()
	gw2_radar.updateFilterList()
	
end

function gw2_radar.Draw(_, ticks )
	-- Draw main radar gui.
	if (GetGameState() == GW2.GAMESTATE.GAMEPLAY) then 
		if (gw2_radar.mainWindow.open) then
			GUI:SetNextWindowSize(250,400,GUI.SetCond_FirstUseEver)
			gw2_radar.mainWindow.visible, gw2_radar.mainWindow.open = GUI:Begin(gw2_radar.mainWindow.name, gw2_radar.mainWindow.open)
			if (gw2_radar.mainWindow.visible) then
				GUI:BeginGroup()
					if (GUI:CollapsingHeader(GetString("compass"))) then
						GUI:Indent()
							GUI:BeginGroup()
								GUI:Separator()
									GUI:BeginGroup()
										GUI:AlignFirstTextHeightToWidgets()
										GUI:Text(GetString("active"))
										GUI:AlignFirstTextHeightToWidgets()
										GUI:Text(GetString("showpath"))
									GUI:EndGroup()
									GUI:SameLine(65)
									GUI:BeginGroup()
										gw2_radar.compassActive = GUI:Checkbox("###compass", gw2_radar.compassActive)
										Settings.gw2_radar.compassActive = gw2_radar.compassActive
										gw2_radar.compassShowPath = GUI:Checkbox("###showpath", gw2_radar.compassShowPath)
										Settings.gw2_radar.compassShowPath = gw2_radar.compassShowPath
										GUI:SameLine(0)
										local width = GUI:GetContentRegionAvailWidth()
										width = width > 200 and width or 200
										GUI:PushItemWidth(width)
										gw2_radar.compassPathColor = GUI:ColorConvertFloat4ToU32(GUI:ColorEdit4("###pathcolor",GUI:ColorConvertU32ToFloat4(gw2_radar.compassPathColor)))
										Settings.gw2_radar.compassPathColor = gw2_radar.compassPathColor
										GUI:PopItemWidth()
									GUI:EndGroup()
								GUI:Separator()
							GUI:EndGroup()
						GUI:Unindent()
					end
				GUI:EndGroup()
				GUI:BeginGroup()
					if (GUI:CollapsingHeader(GetString("3dradar"))) then
						GUI:Indent()
							GUI:BeginGroup()
								GUI:Separator()
									GUI:BeginGroup()
										GUI:AlignFirstTextHeightToWidgets()
										GUI:Text(GetString("active"))
									GUI:EndGroup()
									GUI:SameLine(65)
									GUI:BeginGroup()
										gw2_radar.radar3DActive = GUI:Checkbox("###3dradar", gw2_radar.radar3DActive)
										Settings.gw2_radar.radar3DActive = gw2_radar.radar3DActive
									GUI:EndGroup()
								GUI:Separator()
							GUI:EndGroup()
						GUI:Unindent()
					end
				GUI:EndGroup()
				GUI:Separator()
				gw2_radar.drawSettings()
			end
			
			GUI:End()
		end
		
		-- if () then -- TODO: waiting on map open.closed check.
			
			-- Delay parsing entities.
			-- Checks all required entity lists. Delay this function as much as possible to reduce system load.
			if (PvPManager:IsMatchFinished() ~= false and GetGameState() == GW2.GAMESTATE.GAMEPLAY) then -- checking gamestate once more, I have the feeling we are fucked by multithreading...
				if (ticks - gw2_radar.parseTicks >= gw2_radar.parseTickDelay ) then
					gw2_radar.parseTicks = ticks
					gw2_radar.parseEntities()
					gw2_radar.parseCompassPath()
				end
				-- Delay updating compass and position data.
				-- Delay this function as much as possible to reduce system load.
				if (ticks - gw2_radar.computeTicks >= gw2_radar.computeTickDelay) then
					gw2_radar.computeTicks = ticks
					gw2_radar.updateCompassData()
					gw2_radar.updateScreenPositionData()
				end
				
				-- 3D radar.
				gw2_radar.draw3DRadar()
				-- Compass.
				gw2_radar.drawCompass()
			end
		-- end
	end
end

function gw2_radar.loadSettings()
	for name,radarType in pairs(gw2_radar.radarTypes) do
		for attribute,guiItem in pairs(radarType.variables) do
			gw2_radar.radarTypes[name].variables[attribute].value = Settings.gw2_radar[radarType.name .. "_" .. attribute] or gw2_radar.radarTypes[name].variables[attribute].value
		end
	end
end

function gw2_radar.drawSettings()
	for groupName,group in pairs(gw2_radar.settingsGroups) do
		GUI:BeginGroup()
			if (GUI:CollapsingHeader(groupName)) then
				GUI:Indent()
					GUI:BeginGroup()
						for _,setting in pairs(group) do
							if (GUI:CollapsingHeader(setting.name)) then
								GUI:Separator()
									for attribute,guiItem in pairs(setting.variables) do
										GUI:BeginGroup()
											GUI:AlignFirstTextHeightToWidgets()
											GUI:Text(GetString(guiItem.name))
										GUI:EndGroup()
										GUI:SameLine(100)
										GUI:BeginGroup()
											gw2_radar.radarTypes[setting.name].variables[attribute].value = gw2_radar.drawGUI(setting,guiItem) -- TODO: function that creates specified gui item.
											Settings.gw2_radar[setting.name .. "_" .. attribute] = guiItem.value
										GUI:EndGroup()
									end
								GUI:Separator()
							end
						end
					GUI:EndGroup()
				GUI:Unindent()
			end
		GUI:EndGroup()
	end
end

function gw2_radar.drawGUI(group,guiItem)
	if (table.valid(guiItem)) then
		if (guiItem.guiType == "Checkbox") then
			return GUI:Checkbox("###" .. group.name .. "_" .. guiItem.name,guiItem.value)
		elseif (guiItem.guiType == "ColorEdit4") then
			local width = GUI:GetContentRegionAvailWidth()
			width = width > 200 and width or 200
			GUI:PushItemWidth(width)
			local r,g,b,a,changed = GUI:ColorEdit4("###" .. group.name .. "_" .. guiItem.name,GUI:ColorConvertU32ToFloat4(guiItem.value))
			GUI:PopItemWidth()
			return GUI:ColorConvertFloat4ToU32(r,g,b,a),changed
		end
	end
end

function gw2_radar.draw3DRadar()
	if (gw2_radar.radar3DActive) then
		-- 3D Radar
		GUI:SetNextWindowSize(gw2_radar.compassData.sSize.x,gw2_radar.compassData.sSize.y,GUI.SetCond_Always)
		GUI:SetNextWindowPosCenter(GUI.SetCond_Always)
		GUI:PushStyleColor(GUI.Col_WindowBg, 0, 0, 0, 0)
		GUI:Begin("Vision Draw Space", true, GUI.WindowFlags_NoInputs + GUI.WindowFlags_NoBringToFrontOnFocus + GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoCollapse)
		GUI:PopStyleColor(1)
		
		for _,entity in pairs(gw2_radar.trackEntities) do
			if (table.valid(entity) and entity.variables and entity.variables.radar3D.value) then
				local sPos = entity.sPos
				if (table.valid(sPos)) then
					local maxDistance =  6000
					local minDistance = 1000
					local distance = entity.distance < minDistance and minDistance or entity.distance > maxDistance and maxDistance or entity.distance
					local scale = (distance - maxDistance) / (minDistance - maxDistance)
					
					-- TODO: add race, profession, speciliztion image.
					-- GUI:AddImage(GetLuaModsPath() .. [[Icons\]] .. [[\Necromancer_tango_icon_20px.png]], sPos.x + (10*scale), sPos.y - (10*scale), sPos.x - (10*scale), sPos.y + (10*scale))
					local dotScale = scale < 0.5 and 0.5 or scale
					GUI:AddCircleFilled( sPos.x, sPos.y, (5 * dotScale), entity.variables.color.value)
					
					if (scale > 0.5) then
						GUI:SetWindowFontScale(scale)
						local text = "["..entity.name.."]["..math.round(entity.distance).."]"
						local textSizeX, textSizeY = GUI:CalcTextSize(text)
						GUI:AddText(sPos.x - (textSizeX/2), sPos.y+textSizeY, 4294967295, text)
						
						if (table.valid(entity.health)) then
							local scaledRect = {
								x1 = (sPos.x - (37 * scale)),
								y1 = (sPos.y + (30 * scale)),
								x2 = (sPos.x + (37 * scale)),
								y2 = (sPos.y + (37 * scale)),
							}
							local scaledRectFilled = {
								x1 = (sPos.x - (35 * scale)),
								y1 = (sPos.y + (32 * scale)),
								x2 = (sPos.x + (-35 + (70 * (entity.health.percent/100))) * scale),
								y2 = (sPos.y + (35 * scale)),
							}
							GUI:AddRectFilled(scaledRectFilled.x1, scaledRectFilled.y1, scaledRectFilled.x2, scaledRectFilled.y2, GUI:ColorConvertFloat4ToU32(math.abs((-100+entity.health.percent)/100), entity.health.percent/100, 0, 1))
							GUI:AddRect(scaledRect.x1, scaledRect.y1, scaledRect.x2, scaledRect.y2, 4294967295)
							GUI:AddText(sPos.x + (40 * scale), sPos.y + (26 * scale), 4294967295, tostring(entity.health.percent).."%")
						end
						GUI:SetWindowFontScale(1)
					end
				end
			end
		end
		
		GUI:End()
		
	end
end

function gw2_radar.drawCompass()
	if (gw2_radar.compassActive or gw2_radar.compassShowPath) then
		-- 2D Radar Compass overlay.
		GUI:SetNextWindowPos(gw2_radar.compassData.pos.x, gw2_radar.compassData.pos.y, GUI.SetCond_Always)
		GUI:SetNextWindowSize(gw2_radar.compassData.width, gw2_radar.compassData.height) --gw2_radar.compassData.mouseover == 0 and gw2_radar.compassData.width or gw2_radar.compassData.width - 25
		GUI:PushStyleVar(GUI.StyleVar_WindowRounding, 0)
		GUI:PushStyleVar(GUI.StyleVar_WindowPadding, 0,0)
		GUI:PushStyleColor(GUI.Col_WindowBg, 0, 0, 0, 0)
		GUI:Begin("Vision Compass Space", true, GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoMove + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoScrollWithMouse + GUI.WindowFlags_NoCollapse + GUI.WindowFlags_NoSavedSettings + GUI.WindowFlags_NoInputs + GUI.WindowFlags_NoFocusOnAppearing + GUI.WindowFlags_NoBringToFrontOnFocus)
		GUI:PopStyleVar(2)
		GUI:PopStyleColor(1)
		
		if (gw2_radar.compassActive) then
			local markerSize = 5 - gw2_radar.compassData.zoomlevel
			local mousePos = {}
			mousePos.x,mousePos.y = GUI:GetMousePos()
			local hovering = false
			
			for _,entity in pairs(gw2_radar.trackEntities) do
				if (table.valid(entity) and entity.variables and entity.variables.compass.value) then
					local rPos = entity.rPos
					if (table.valid(rPos) and rPos.x and rPos.y) then
						GUI:AddRectFilled(rPos.x - markerSize, rPos.y - markerSize, rPos.x + markerSize, rPos.y + markerSize, entity.variables.color.value)
						GUI:AddRect(rPos.x - markerSize, rPos.y - markerSize, rPos.x + markerSize, rPos.y + markerSize, 4294967295)
						-- hover overlay. TODO: still needs refinement. Covers-up/collides with ingame tooltips.
						if (mousePos.x > rPos.x - markerSize and mousePos.x < rPos.x + markerSize and mousePos.y > rPos.y - markerSize and mousePos.y < rPos.y + markerSize and not hovering) then
							hovering = true
							GUI:PushStyleVar(GUI.StyleVar_WindowPadding, 0,0)
							GUI:PushStyleVar(GUI.StyleVar_WindowRounding, 0)
							GUI:PushStyleColor(GUI.Col_WindowBg,0,0,0,0)
							
							local text = entity.name .. "\n" .. math.round(entity.distance) .. GetString(" away")
							local textSize = {}
							textSize.x,textSize.y = GUI:CalcTextSize(text)
							
							local mousePos = {}
							mousePos.x,mousePos.y = GUI:GetMousePos()
							GUI:SetNextWindowPos(mousePos.x-(textSize.x+15), mousePos.y-70, GUI.SetCond_Always)
							
							GUI:SetNextWindowSize(textSize.x+15, 40,GUI.SetCond_Always)
							GUI:BeginTooltip() -- creating own tooltip to force no rounding.
								GUI:Dummy(1,1)
								GUI:Dummy(0,0)
								GUI:SameLine()
								GUI:TextWrapped(text)
							GUI:EndTooltip()
							
							GUI:PopStyleVar(2)
							GUI:PopStyleColor(1)
						end
					end
				end
			end
			
			-- Draw Player/Self
			local cPos = gw2_radar.compassData.cPos
			GUI:AddRectFilled(cPos.x - markerSize, cPos.y - markerSize, cPos.x + markerSize, cPos.y + markerSize,  4278255360)
			GUI:AddRect(cPos.x - markerSize, cPos.y - markerSize, cPos.x + markerSize, cPos.y + markerSize,  4278190335)
		end
		
		if (gw2_radar.compassShowPath) then
			-- Compass path.
			gw2_radar.drawCompassPath()
		end
		
		GUI:End()
	end
end

function gw2_radar.drawCompassPath()
	if (gw2_radar.compassShowPath and table.valid(gw2_radar.compassPath)) then
		for _,pathLine in pairs(gw2_radar.compassPath) do
			GUI:AddLine(pathLine.x1, pathLine.y1, pathLine.x2, pathLine.y2, pathLine.color, 3.0)
		end
	end
end

function gw2_radar.parseCompassPath()
	table.clear(gw2_radar.compassPath)
	if (gw2_radar.compassShowPath) then
		local path = ml_navigation.path
		local lastPos = gw2_radar.compassData.cPos
		if (table.valid(path) and table.valid(lastPos)) then
			for id,pathPointPos in ipairs(path) do
				if (id >= ml_navigation.pathindex and table.valid(pathPointPos)) then
					local currPos = gw2_radar.worldToCompass(pathPointPos)
					if (table.valid(currPos)) then
						if (currPos.x and currPos.y) then
							gw2_radar.compassPath[#gw2_radar.compassPath + 1] = {x1 = lastPos.x, y1 = lastPos.y, x2 = currPos.x, y2 = currPos.y, color = gw2_radar.compassPathColor,}
						elseif (currPos.ex and currPos.ey) then
							gw2_radar.compassPath[#gw2_radar.compassPath + 1] = {x1 = lastPos.x, y1 = lastPos.y, x2 = currPos.ex, y2 = currPos.ey, color = gw2_radar.compassPathColor,}
							break
						end
						lastPos = {x = currPos.x, y = currPos.y,}
					else
						break
					end
				end
			end
		end
	end
end

function gw2_radar.ToggleWindow()
	gw2_radar.mainWindow.open = not gw2_radar.mainWindow.open
end

-- Update Loop
function gw2_radar.Update(_,ticks)
	if (ticks - gw2_radar.computeTicks >= gw2_radar.computeTickDelay) then
		gw2_radar.parseEntities()
		gw2_radar.parseCompassPath()
	end
end

-- Functional Code.
-- Add track Type.
function gw2_radar.addType(radarType)
	if (table.valid(radarType)) then
		gw2_radar.radarTypes[radarType.name] = radarType
		gw2_radar.updateSettingsGroups()
		gw2_radar.updateFilterList()
	end
end

-- Update settings groups to draw.
function gw2_radar.updateSettingsGroups()
	table.clear(gw2_radar.settingsGroups)
	for _,radarType in pairs(gw2_radar.radarTypes) do
		if (table.valid(radarType)) then
			gw2_radar.settingsGroups[radarType.groupName] = gw2_radar.settingsGroups[radarType.groupName] or {}
			gw2_radar.settingsGroups[radarType.groupName][radarType.name] = radarType
		end
	end
end

-- Update compass data.
function gw2_radar.updateCompassData() -- TODO: redo this mess. Order stuff, and dont cashe non used stuff.
	gw2_radar.compassData = HackManager:GetCompassData()
	
	
	-- adjust size for 'interface size' setting.
	if (GetGameRegion() == 2) then -- for now just adjust for cn default size. TODO: fix with actual interface size when data available.
		gw2_radar.compassData.width = gw2_radar.compassData.width + 38
		gw2_radar.compassData.height = gw2_radar.compassData.height + 38
	end
	
	
	local screenSizeX, screenSizeY = GUI:GetScreenSize()
	gw2_radar.compassData.sSize = {x = screenSizeX, y = screenSizeY,}
	
	-- TESTCODE!
	-- scales radar with different window-mode sizes.
	-- todo: scale calculation still seems off, but right direction of thinking here.
	-- local proportionX = screenSizeX / (1920 * 0.01) 
	-- local proportionY = screenSizeY / (1080 * 0.01) 
	
	-- local proportion = proportionX < proportionY and proportionX or proportionY
	
	-- local compassScaleSizeX = (gw2_radar.compassData.width * 0.01) * proportion 
	-- local compassScaleSizeY = (gw2_radar.compassData.height * 0.01) * proportion 
	
	-- gw2_radar.compassData.width = compassScaleSizeX
	-- gw2_radar.compassData.height = compassScaleSizeY
	
	-- END TESTCODE!!!
	
	gw2_radar.compassData.pos = {x = gw2_radar.compassData.sSize.x - gw2_radar.compassData.width, y = gw2_radar.compassData.topposition == 0 and gw2_radar.compassData.sSize.y - gw2_radar.compassData.height - 37 or 0,} -- 37 is the bottom offset.
	gw2_radar.compassData.cPos = {x = gw2_radar.compassData.pos.x + (gw2_radar.compassData.width / 2), y = gw2_radar.compassData.pos.y + (gw2_radar.compassData.height / 2)}
	gw2_radar.compassData.pPos = Player.pos
	
	local currDirection = gw2_radar.compassData.rotation == 0 and math.atan2(0,1) or math.atan2(gw2_radar.compassData.lookat.x - gw2_radar.compassData.eye.x, gw2_radar.compassData.lookat.y - gw2_radar.compassData.eye.y)
	gw2_radar.compassData.cosTheta = math.cos(currDirection)
	gw2_radar.compassData.sinTheta = math.sin(currDirection)
	
	local scaleAdjust = GetGameRegion() == 1 and 8500 or 6000 -- TODO: find the actual scaling it does with diff ui sizes for future.
	gw2_radar.compassData.scale = (gw2_radar.compassData.maxwidth / scaleAdjust) / (gw2_radar.compassData.zoomlevel+1) -- WIKI: "Zoomed in, the horizontal and vertical range of the compass is 4250 units and the diagonal range is 6000 units." - edit: seems to be from middle out.
end

function gw2_radar.worldToCompass(ePos)
	local rPos = {
		x = ((ePos.x - gw2_radar.compassData.pPos.x) * gw2_radar.compassData.scale), --PvPManager:IsInMatch() and (ePos.x - ((map_rect.upperRight.x - map_rect.lowerLeft.x)/2)) or 
		y = ((ePos.y - gw2_radar.compassData.pPos.y) * gw2_radar.compassData.scale), --PvPManager:IsInMatch() and (ePos.y - map_rect.y) or 
	}
	rPos = {
		x = (gw2_radar.compassData.cosTheta * rPos.x - gw2_radar.compassData.sinTheta * rPos.y),
		y = (gw2_radar.compassData.sinTheta * rPos.x + gw2_radar.compassData.cosTheta * rPos.y) * -1,
	}
	rPos = {
		x = gw2_radar.compassData.cPos.x + rPos.x,
		y = gw2_radar.compassData.cPos.y + rPos.y,
	}
	
	local compassPos = {
		x1 = gw2_radar.compassData.pos.x,
		y1 = gw2_radar.compassData.pos.y,
		x2 = gw2_radar.compassData.pos.x + gw2_radar.compassData.width,
		y2 = gw2_radar.compassData.pos.y + gw2_radar.compassData.height,
	}
	if (rPos.x < compassPos.x1 or rPos.y < compassPos.y1 or rPos.x > compassPos.x2 or rPos.y > compassPos.y2) then
		rPos = {
			x = nil,
			y = nil,
			ex = rPos.x < compassPos.x1 and compassPos.x1 or rPos.x > compassPos.x2 and compassPos.x2 or rPos.x,
			ey = rPos.y < compassPos.y1 and compassPos.y1 or rPos.y > compassPos.y2 and compassPos.y2 or rPos.y,
		}
	end
	return rPos
end

-- Create Filter list.
function gw2_radar.updateFilterList()
	for _,radarType in pairs(gw2_radar.radarTypes) do
		if (table.valid(radarType) and (radarType.variables.compass.value or radarType.variables.radar3D.value)) then
			gw2_radar.filterList[radarType.list] = gw2_radar.filterList[radarType.list] or {}
			table.insert(gw2_radar.filterList[radarType.list],radarType)
		end
	end
end

-- Parse entities. (hehe tities...)
function gw2_radar.parseEntities()
	if (gw2_radar.compassActive or gw2_radar.radar3DActive) then
		local newTrackEntities = {}
		for listName,radarTypes in pairs(gw2_radar.filterList) do
			local entityList = _G[listName]("")
			for _,entity in pairs(entityList) do
				if (table.valid(entity)) then
					for _,radarType in pairs(radarTypes) do
						if (table.valid(radarType)) then
							if (gw2_radar.matchFilterEntity(entity,radarType.filter)) then
								local currEntity = gw2_radar.trackEntities[entity.id]
								newTrackEntities[entity.id] = {
									id			= currEntity and currEntity.id or entity.id,
									name		= currEntity and string.valid(currEntity.name) and currEntity.name or entity.name,
									variables	= radarType.variables,
									pos			= entity.pos,
									health		= entity.health,
									distance	= entity.distance,
								}
								break
							end
						end
					end
				end
			end
		end
		gw2_radar.trackEntities = newTrackEntities
	else
		table.clear(gw2_radar.trackEntities)
	end
end

-- Match entity to filter.
function gw2_radar.matchFilterEntity(entity, filterData)
	if (table.valid(entity) and table.valid(filterData)) then
		for _,filter in pairs(filterData) do
			if (table.valid(filter)) then
				local entityMatchFilter = true
				for attribute,wantedValue in pairs(filter) do
					if (string.valid(attribute) and (entity[attribute] == nil or entity[attribute] ~= wantedValue)) then
						entityMatchFilter = false
						break
					end
				end
				if (entityMatchFilter) then
					return true
				end
			end
		end
	end
	return false
end

-- Update entity screen and/or minimap positions.
function gw2_radar.updateScreenPositionData()
	for _,entity in pairs(gw2_radar.trackEntities) do
		if (table.valid(entity)) then
			entity.rPos = gw2_radar.compassActive and entity.variables.compass.value and gw2_radar.worldToCompass(entity.pos) or nil
			entity.sPos = gw2_radar.radar3DActive and entity.variables.radar3D.value and RenderManager:WorldToScreen(entity.pos) or nil
		end
	end
end



RegisterEventHandler("Module.Initalize",gw2_radar.Init)
RegisterEventHandler("Gameloop.Draw", gw2_radar.Draw)
-- RegisterEventHandler("Gameloop.Update",gw2_radar.Update)
RegisterEventHandler("Radar.toggle", gw2_radar.ToggleWindow)



--- ADD ENTRIES HERE:

local player_friend = {
	name		= GetString("Player Friend"),
	groupName	= GetString("player"),
	list		= "CharacterList",
	variables	= {
		compass	= {guiType = "Checkbox",	name = "compass",	value = false,},
		radar3D	= {guiType = "Checkbox",	name = "radar 3D",	value = false,},
		color	= {guiType = "ColorEdit4",	name = "Color",		value = 2516647680,},
	},
	filter = {
		{["isplayer"] = true, ["attitude"] = GW2.ATTITUDE.Friendly,},
	},
}
gw2_radar.addType(player_friend)

local player_foe = {
	name		= GetString("Player Foe"),
	groupName	= GetString("player"),
	list		= "CharacterList",
	variables	= {
		compass	= {guiType = "Checkbox",	name = "compass",	value = false,},
		radar3D	= {guiType = "Checkbox",	name = "radar 3D",	value = false,},
		color	= {guiType = "ColorEdit4",	name = "Color",		value = 2533294335,},
	},
	filter = {
		{["isplayer"] = true, ["attitude"] = GW2.ATTITUDE.Hostile,},
	},
}
gw2_radar.addType(player_foe)

local npc_friend = {
	name		= GetString("Npc Friend"),
	groupName	= GetString("npc"),
	list		= "CharacterList",
	variables	= {
		compass	= {guiType = "Checkbox",	name = "compass",	value = false,},
		radar3D	= {guiType = "Checkbox",	name = "radar 3D",	value = false,},
		color	= {guiType = "ColorEdit4",	name = "Color",		value = 2533359360,},
	},
	filter = {
		{["isplayer"] = false, ["attitude"] = GW2.ATTITUDE.Friendly,},
		{["isplayer"] = false, ["attitude"] = GW2.ATTITUDE.Unattackable,},
	},
}
gw2_radar.addType(npc_friend)

local npc_foe = {
	name		= GetString("Npc Foe"),
	groupName	= GetString("npc"),
	list		= "CharacterList",
	variables	= {
		compass	= {guiType = "Checkbox",	name = "compass",	value = false,},
		radar3D	= {guiType = "Checkbox",	name = "radar 3D",	value = false,},
		color	= {guiType = "ColorEdit4",	name = "Color",		value = 2516582655,},
	},
	filter = {
		{["isplayer"] = false, ["attitude"] = GW2.ATTITUDE.Hostile, ["alive"] = true,},
	},
}
gw2_radar.addType(npc_foe)

local npc_neutral = {
	name		= GetString("Npc Neutral"),
	groupName	= GetString("npc"),
	list		= "CharacterList",
	variables	= {
		compass	= {guiType = "Checkbox",	name = "compass",	value = false,},
		radar3D	= {guiType = "Checkbox",	name = "radar 3D",	value = false,},
		color	= {guiType = "ColorEdit4",	name = "Color",		value = 2516647935,},
	},
	filter = {
		{["isplayer"] = false, ["attitude"] = GW2.ATTITUDE.Neutral, ["alive"] = true,},
	},
}
gw2_radar.addType(npc_neutral)

local ore_mine = { -- TODO: gadget/ore not showing up, no such thing as usable... thnx fx :P
	name		= GetString("Ore Mine"),
	groupName	= GetString("Ore"),
	list		= "GadgetList",
	variables	= {
		compass	= {guiType = "Checkbox",	name = "compass",	value = false,},
		radar3D	= {guiType = "Checkbox",	name = "radar 3D",	value = false,},
		color	= {guiType = "ColorEdit4",	name = "Color",		value = 2519411499,},
	},
	filter = {
		{["interactable"] = true, ["resourceType"] = GW2.RESOURCETYPE.Mine,},
	},
}
gw2_radar.addType(ore_mine)

local ore_herb = {
	name		= GetString("Ore Herb"),
	groupName	= GetString("Ore"),
	list		= "GadgetList",
	variables	= {
		compass	= {guiType = "Checkbox",	name = "compass",	value = false,},
		radar3D	= {guiType = "Checkbox",	name = "radar 3D",	value = false,},
		color	= {guiType = "ColorEdit4",	name = "Color",		value = 2523070252,},
	},
	filter = {
		{["interactable"] = true, ["resourceType"] = GW2.RESOURCETYPE.Herb,},
	},
}
gw2_radar.addType(ore_herb)

local ore_wood = {
	name		= GetString("Ore Wood"),
	groupName	= GetString("Ore"),
	list		= "GadgetList",
	variables	= {
		compass	= {guiType = "Checkbox",	name = "compass",	value = false,},
		radar3D	= {guiType = "Checkbox",	name = "radar 3D",	value = false,},
		color	= {guiType = "ColorEdit4",	name = "Color",		value = 2518495047,},
	},
	filter = {
		{["interactable"] = true, ["resourceType"] = GW2.RESOURCETYPE.Wood,},
		{["interactable"] = true, ["resourceType"] = GW2.RESOURCETYPE.Wood,},
	},
}
gw2_radar.addType(ore_wood)