-- Create parser variable.
gw2_combatdata = {}

-- gw2_combatdata variables.
gw2_combatdata.mainWindow			= {
	name	= GetString("Combat Data"),
	open	= false,
	visible	= false,
	tabs	= {
		player		= true,
		team		= false,
		everyone	= false,
	}
}
gw2_combatdata.active2				= true
gw2_combatdata.updateTicks			= 0
gw2_combatdata.upateTickDelay		= 250
gw2_combatdata.cleanTicks			= 0
gw2_combatdata.cleanTickDelay		= 30000
gw2_combatdata.partyIDUpdateTicks	= 0
gw2_combatdata.partyIDUpdateDelay	= 1000
gw2_combatdata.damageLog			= {}
gw2_combatdata.healLog				= {}
gw2_combatdata.combatLog			= {}
gw2_combatdata.timeLastUpdate		= 0
gw2_combatdata.checkAllEntities		= true
gw2_combatdata.displayIDs			= {}
gw2_combatdata.columns				= {}
gw2_combatdata.selectedColumn		= {}
gw2_combatdata.columnSort			= "name"
gw2_combatdata.iconPath				= GetLuaModsPath() .. "GW2Minion\\Icons\\"
gw2_combatdata.icons				= {}
gw2_combatdata.selectedTargetData	= {}
gw2_combatdata.buffLog				= { -- WIP.
	boon = {
		[743]		= "Aegis",
		[17675]		= "Aegis",
		[9286]		= "Blooslust",
		[9285]		= "Blooslust",
		[9281]		= "Blooslust",
		[725]		= "Fury",
		[740]		= "Might",
		[717]		= "Protection",
		[1187]		= "Quickness",
		[718]		= "Regeneration",
		[17674]		= "Regeneration",
		[26980]		= "Resistance",
		[873]		= "Retaliation",
		[1122]		= "Stability",
		[719]		= "Swiftness",
		[726]		= "Vigor",
	},
	condition = {
		[736]		= "Bleeding",
		[720]		= "Blind",
		[737]		= "Burning",
		[722]		= "Chilled",
		[861]		= "Confusion",
		[721]		= "Crippled",
		[791]		= "Fear",
		[727]		= "Immobilized",
		[723]		= "Poison",
		[26766]		= "Slow",
		[19426]		= "Torment",
		[738]		= "Vulnerability",
		[742]		= "Weakness",
	}
}



function gw2_combatdata.Init()
	
	Settings.gw2_combatdata.active2 = Settings.gw2_combatdata.active2 or true
	gw2_combatdata.active2 = Settings.gw2_combatdata.active2
	
	Settings.gw2_combatdata.columns = Settings.gw2_combatdata.columns or {
		[1] = {
			name			= GetString("Name"),
			visible			= true,
			width			= 100,
			minWidth		= 50,
			variableName	= "name",
		},
		[2] = {
			name			= GetString("Target Name"),
			visible			= true,
			width			= 100,
			minWidth		= 50,
			variableName	= "targetName",
		},
		[3] = {
			name			= GetString("DPS"),
			visible			= true,
			width			= 50,
			minWidth		= 25,
			variableName	= "dps",
		},
		[4] = {
			name			= GetString("HPS"),
			visible			= true,
			width			= 50,
			minWidth		= 25,
			variableName	= "hps",
		},
		[5] = {
			name			= GetString("Cleave-DPS"),
			visible			= true,
			width			= 50,
			minWidth		= 25,
			variableName	= "cdps",
		},
		[6] = {
			name			= GetString("Damage"),
			visible			= true,
			width			= 50,
			minWidth		= 50,
			variableName	= "damage",
		},
		[7] = {
			name			= GetString("Heal"),
			visible			= true,
			width			= 50,
			minWidth		= 50,
			variableName	= "heal",
		},
		[8] = {
			name			= GetString("Cleave-Damage"),
			visible			= true,
			width			= 50,
			minWidth		= 50,
			variableName	= "cDamage",
		},
		[9] = {
			name			= GetString("Combat Time"),
			visible			= true,
			width			= 50,
			minWidth		= 50,
			variableName	= "engagementTime",
		},
		[10] = {
			name			= GetString("TTK"),
			visible			= true,
			width			= 50,
			minWidth		= 50,
			variableName	= "ttk",
		},
	}
	
	gw2_combatdata.columns = Settings.gw2_combatdata.columns
	
	gw2_combatdata.icons = {
		profession = {
			[1] = gw2_combatdata.iconPath .. "Profession\\Guardian.png",
			[2] = gw2_combatdata.iconPath .. "Profession\\Warrior.png",
			[3] = gw2_combatdata.iconPath .. "Profession\\Engineer.png",
			[4] = gw2_combatdata.iconPath .. "Profession\\Ranger.png",
			[5] = gw2_combatdata.iconPath .. "Profession\\Thief.png",
			[6] = gw2_combatdata.iconPath .. "Profession\\Elementalist.png",
			[7] = gw2_combatdata.iconPath .. "Profession\\Mesmer.png",
			[8] = gw2_combatdata.iconPath .. "Profession\\Necromancer.png",
			[9] = gw2_combatdata.iconPath .. "Profession\\Revenant.png",
		},
	}
	
	
	-- init button in minionmainbutton
	ml_gui.ui_mgr:AddMember({ id = "GW2MINION##COMBATDATA", name = "DPS Meter", onClick = function() gw2_combatdata.mainWindow.open = gw2_combatdata.mainWindow.open ~= true end, tooltip = "Click to open \"Combat Data\" window.", texture = GetStartupPath().."\\GUI\\UI_Textures\\sword.png"},"GW2MINION##MENU_HEADER")
end

-- Draw main column window.
function gw2_combatdata.Draw(_, ticks)
	if (GetGameState() == GW2.GAMESTATE.GAMEPLAY) then
		-- Draw selected target information.
		gw2_combatdata.DrawSelectedTargetInfo(ticks)
		
		-- Draw detailed Combat data window.
		gw2_combatdata.DrawCombatDataWindow(ticks)
		
	end
end

-- Draw selected target info.
function gw2_combatdata.DrawSelectedTargetInfo(ticks)
	if (table.valid(gw2_combatdata.selectedTargetData)) then
		-- Create invisible window as draw region.
		local screenSizeX, screenSizeY = GUI:GetScreenSize()
		GUI:SetNextWindowSize(screenSizeX,screenSizeY,GUI.SetCond_Always)
		GUI:SetNextWindowPosCenter(GUI.SetCond_Always)
		GUI:PushStyleColor(GUI.Col_WindowBg, 0, 0, 0, 0)
		GUI:Begin("DPS Free Draw Space", true, GUI.WindowFlags_NoInputs + GUI.WindowFlags_NoBringToFrontOnFocus + GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoCollapse)
		GUI:PopStyleColor(1)
			
			-- DPS.
			local playerCombatData = gw2_combatdata.combatLog[ml_global_information.Player_ID]
			if (table.valid(playerCombatData)) then
				GUI:AddRectFilled((screenSizeX / 2) - 178, 38, (screenSizeX / 2) + 70, 53, 2533359615)
				GUI:AddRect((screenSizeX / 2) - 178, 38, (screenSizeX / 2) + 70, 53, 4278190080)
				if (playerCombatData.targetid == gw2_combatdata.selectedTargetData.id) then
					GUI:AddText((screenSizeX / 2) - 176, 39, 4278190080, "DPS: " .. playerCombatData.dps .. " | TTK: " .. string.format('%.2d:%.2d', math.mod(playerCombatData.ttk/60,60), math.mod(playerCombatData.ttk,60)))
				else
					GUI:AddText((screenSizeX / 2) - 176, 39, 4278190080, "DPS:0 TTK:00:00")
				end
			end
			
			-- Draw Selected target Health.
			local sPos = {
				x = (screenSizeX / 2) - 175,
				y = 86,
			}
			GUI:AddText(sPos.x, sPos.y, 4294967295, math.round(gw2_combatdata.selectedTargetData.health.current) .. "/" .. gw2_combatdata.selectedTargetData.health.max)
		GUI:End()
		
		
	end
end

-- Draw column functions.
function gw2_combatdata.DrawCombatDataWindow(ticks)
	if (gw2_combatdata.mainWindow.open) then
		GUI:SetNextWindowSize(850,250,GUI.SetCond_FirstUseEver)
		gw2_combatdata.mainWindow.visible, gw2_combatdata.mainWindow.open = GUI:Begin(gw2_combatdata.mainWindow.name, gw2_combatdata.mainWindow.open) --,GUI.WindowFlags_NoTitleBar)
		if (gw2_combatdata.mainWindow.visible) then
			-- Active checkbox.
			gw2_combatdata.active2,changed = GUI:Checkbox("##CombatData_Active",gw2_combatdata.active2)
			Settings.gw2_combatdata.active2 = gw2_combatdata.active2
			GUI:SameLine()
			GUI:Text(GetString("Active"))
			GUI:Separator()
			
			if (Settings.gw2_combatdata.active2) then
				-- Get width and color.
				local tabButtonWidth = (GUI:GetContentRegionAvailWidth() / table.size(gw2_combatdata.mainWindow.tabs)) - GUI:GetStyle().itemspacing.x/2
				local activeTabColor = GUI:GetStyle().colors[GUI.Col_ButtonActive]
				
				-- Highlight player tab if selected.
				local playerHighlighted = false
				if (gw2_combatdata.mainWindow.tabs.player) then
					GUI:PushStyleColor(GUI.Col_Button,activeTabColor[1],activeTabColor[2],activeTabColor[3], activeTabColor[4])
					playerHighlighted = true
				end
				if (GUI:Button(GetString("Player##CombatdataParser"), tabButtonWidth, 0)) then
					gw2_combatdata.mainWindow.tabs = {
						player = true,
						team = false,
						everyone = false,
					}
				end
				if (playerHighlighted == true) then
					GUI:PopStyleColor(1)
					gw2_combatdata.displayIDs = {[ml_global_information.Player_ID] = true,}
				end
				GUI:SameLine()
				
				-- Highlight team tab if selected.
				local teamHighlighted = false
				if (gw2_combatdata.mainWindow.tabs.team) then
					GUI:PushStyleColor(GUI.Col_Button,activeTabColor[1],activeTabColor[2],activeTabColor[3], activeTabColor[4])
					teamHighlighted = true
				end
				if (GUI:Button(GetString("Team##CombatdataParser"), tabButtonWidth, 0)) then
					gw2_combatdata.mainWindow.tabs = {
						player = false,
						team = true,
						everyone = false,
					}
				end
				if (teamHighlighted == true) then
					GUI:PopStyleColor(1)
					if (ticks - gw2_combatdata.partyIDUpdateTicks > gw2_combatdata.partyIDUpdateDelay) then
						gw2_combatdata.partyIDUpdateTicks = ticks
						gw2_combatdata.displayIDs = {}
						local squad = Player:GetSquad()
						if (table.valid(squad)) then
							for _,squadMember in pairs(squad) do
								gw2_combatdata.displayIDs[squadMember.id] = true
							end
						else
							local party = Player:GetParty()
							if (table.valid(party)) then
								for _,partyMember in pairs(party) do
									if (partyMember.hasparty) then
										gw2_combatdata.displayIDs[partyMember.id] = true
									end
								end
							end
						end
					end
				end
				GUI:SameLine()
				
				-- Highlight everyone tab if selected.
				local everyoneHighlighted = false
				if (gw2_combatdata.mainWindow.tabs.everyone) then
					GUI:PushStyleColor(GUI.Col_Button,activeTabColor[1],activeTabColor[2],activeTabColor[3], activeTabColor[4])
					everyoneHighlighted = true
				end
				if (GUI:Button(GetString("All##CombatdataParser"), tabButtonWidth, 0)) then
					gw2_combatdata.mainWindow.tabs = {
						player = false,
						team = false,
						everyone = true,
					}
				end
				if (everyoneHighlighted == true) then
					GUI:PopStyleColor(1)
					gw2_combatdata.displayIDs = true
				end
				GUI:Separator()
				
				-- Draw columns.
				gw2_combatdata.DrawCombatDataColumns()
			end
		end
		GUI:End()
	end
end

function gw2_combatdata.DrawCombatDataColumns()
	-- Create list of visible collumns.
	local columnDrawList = {}
	for index,column in ipairs(gw2_combatdata.columns) do
		if (column.visible) then
			local columnData = column
			columnData.index = index
			columnData.visibleIndex = #columnDrawList + 1
			table.insert(columnDrawList,columnData)
		end
	end
	
	-- Check and iterate visible collumns list.
	if (table.valid(columnDrawList)) then
		local columnCount = #columnDrawList
		local windowWidth = GUI:GetWindowWidth()
		GUI:Columns(columnCount, "combatLog", true)
		for order,columnData in ipairs(columnDrawList) do
			
			GUI:BeginGroup()
				GUI:AlignFirstTextHeightToWidgets()
				GUI:Text(columnData.name)
				local newColumnWidth = GUI:GetColumnWidth()
				if (newColumnWidth ~= columnData.width) then
					columnDrawList[order].width = GUI:GetColumnWidth()
					if (columnDrawList[order].width < columnData.minWidth) then
						columnDrawList[order].width = columnData.minWidth
					-- elseif (columnDrawList[order].width > columnData.maxWidth) then -- TODO: decide if needed, else remove.
						-- columnDrawList[order].width = columnData.maxWidth
					end
					Settings.gw2_combatdata.columns = gw2_combatdata.columns
				end
				GUI:SetItemAllowOverlap()
				GUI:SameLine()
				GUI:Dummy(columnData.width,15)
			GUI:EndGroup()
			
			if (GUI:IsItemClicked(0)) then
				gw2_combatdata.columnSort = columnData.variableName
			
			elseif (GUI:IsItemClicked(1)) then
				gw2_combatdata.selectedColumn = columnData--table.deepcopy(columnData)
				GUI:OpenPopup("ColumnContext")
			end
			
			if (order < columnCount) then
				GUI:SetColumnOffset(GUI:GetColumnIndex() + 2,GUI:GetColumnOffset(GUI:GetColumnIndex() + 1) + columnDrawList[order + 1].width)
				GUI:SetColumnOffset(GUI:GetColumnIndex() + 1,GUI:GetColumnOffset(GUI:GetColumnIndex()) + columnDrawList[order].width)
			elseif (order == columnCount) then
				GUI:SetColumnOffset(GUI:GetColumnIndex() + 1,GUI:GetColumnOffset(GUI:GetColumnIndex()) + windowWidth)
			end
			
			
			-- Goto next column
			GUI:NextColumn()
			
		end
		-- Seperate columns names from the info they display.
		GUI:Separator()
		
		-- Display combat data.
		local combatDataList = gw2_combatdata.getDisplayCombatData()
		
		-- Show self/player always ontop of the list.
		local playerCombatData = combatDataList[ml_global_information.Player_ID]
		if (table.valid(playerCombatData)) then
			for _,columnData in pairs(columnDrawList) do
				-- Draw Column Content.
				gw2_combatdata.DrawColumnContent(columnData, playerCombatData)
				GUI:NextColumn()
			end
			combatDataList[ml_global_information.Player_ID] = nil
		end
		
		-- Show all other entries.
		local highlight = true
		local color = GUI:GetStyle().colors[GUI.Col_WindowBg]
		local colorU32 = GUI:ColorConvertFloat4ToU32(color[1] + (color[1] * 0.9), color[2] + (color[2] * 0.9), color[3] + (color[3] * 0.9), color[4])
		for _,combatData in table.pairsByValueAttribute(combatDataList, gw2_combatdata.columnSort, gw2_combatdata.sortColumn) do
			if (table.valid(combatData)) then
				for _,columnData in pairs(columnDrawList) do
					if (highlight) then
						local highlightPosX,highlightPosY  = GUI:GetCursorScreenPos()
						GUI:AddRectFilled( highlightPosX - 25, highlightPosY - (GUI:GetStyle().itemspacing.y / 2), highlightPosX + windowWidth, highlightPosY + GUI:GetItemsLineHeightWithSpacing() + (GUI:GetStyle().itemspacing.y / 2), colorU32, 0, 0)
					end
					-- Draw Column Content.
					gw2_combatdata.DrawColumnContent(columnData, combatData)
					
					GUI:NextColumn()
				end
				highlight = not highlight
			end
		end
		
		
		
		GUI:Columns(1)
		
		-- Draw column context menu.
		if (GUI:BeginPopup("ColumnContext")) then
			local selectedColumn = gw2_combatdata.selectedColumn
			local moveLeft = -1
			local moveRight = 1
			if (selectedColumn.visibleIndex > 2 and GUI:MenuItem(GetString("Move Left"))) then
				gw2_combatdata.moveColumn(moveLeft)
			end
			if (selectedColumn.visibleIndex ~= 1 and selectedColumn.visibleIndex < #gw2_combatdata.columns and GUI:MenuItem(GetString("Move Right"))) then
				gw2_combatdata.moveColumn(moveRight)
			end
			if (GUI:BeginMenu(GetString("Columns"))) then
				for index,columnData in ipairs(gw2_combatdata.columns) do
					if (index ~= 1) then
						if (GUI:MenuItem(columnData.name, "", columnData.visible, columnData.visible)) then
							columnData.visible = not columnData.visible
							if (gw2_combatdata.columnSort == columnData.variableName) then
								gw2_combatdata.columnSort = "name"
							end
							Settings.gw2_combatdata.columns = gw2_combatdata.columns
						end
					end
				end
				
				GUI:EndMenu()
			end
			
			GUI:EndPopup()
		end
	end
	
end

function gw2_combatdata.DrawColumnContent(columnData, combatData)
	if (table.valid(columnData) and table.valid(combatData)) then
		if (columnData.variableName == "name") then
			GUI:Image(gw2_combatdata.icons.profession[combatData.profession], GUI:GetItemsLineHeightWithSpacing(), GUI:GetItemsLineHeightWithSpacing())
			GUI:SameLine()
			GUI:AlignFirstTextHeightToWidgets()
			GUI:Text(combatData.name)
		elseif (columnData.variableName == "targetName") then
			GUI:AlignFirstTextHeightToWidgets()
			GUI:Text(combatData.targetName)
		elseif (columnData.variableName == "dps") then
			GUI:AlignFirstTextHeightToWidgets()
			GUI:Text(combatData.dps)
		elseif (columnData.variableName == "hps") then
			GUI:AlignFirstTextHeightToWidgets()
			GUI:Text(combatData.hps)
		elseif (columnData.variableName == "cdps") then
			GUI:AlignFirstTextHeightToWidgets()
			GUI:Text(combatData.cdps)
		elseif (columnData.variableName == "damage") then
			GUI:AlignFirstTextHeightToWidgets()
			GUI:Text(combatData.damage)
		elseif (columnData.variableName == "heal") then
			GUI:AlignFirstTextHeightToWidgets()
			GUI:Text(combatData.heal)
		elseif (columnData.variableName == "cDamage") then
			GUI:AlignFirstTextHeightToWidgets()
			GUI:Text(combatData.cDamage)
		elseif (columnData.variableName == "engagementTime") then
			GUI:AlignFirstTextHeightToWidgets()
			GUI:Text(string.format('%.2d:%.2d', math.mod(combatData.engagementTime/60,60), math.mod(combatData.engagementTime,60)))
		elseif (columnData.variableName == "ttk") then
			GUI:AlignFirstTextHeightToWidgets()
			GUI:Text(string.format('%.2d:%.2d', math.mod(combatData.ttk/60,60), math.mod(combatData.ttk,60)))
		end
	end
end

function gw2_combatdata.moveColumn(direction)
	if (table.valid(gw2_combatdata.selectedColumn)) then
		local moveLeft = -1
		local moveRight = 1
		local columnData = gw2_combatdata.selectedColumn
		if (direction == moveRight) then
			table.remove(gw2_combatdata.columns,columnData.index)
			columnData.index = columnData.index + 1
			table.insert(gw2_combatdata.columns,columnData.index,columnData)
		elseif (direction == moveLeft) then
			table.remove(gw2_combatdata.columns,columnData.index)
			columnData.index = columnData.index - 1
			table.insert(gw2_combatdata.columns,columnData.index,columnData)
		end
		Settings.gw2_combatdata.columns = gw2_combatdata.columns
	end
end

function gw2_combatdata.sortColumn(op1,op2)
	local type1, type2 = type(op1), type(op2)
	if (type1 ~= type2) then --cmp by type
		return type1 < type2
	elseif (type1 == "number" and type2 == "number") then
		return op1 > op2
	elseif (type1 == "string" and type2 == "string") then
		return op1 < op2
	elseif type1 == "boolean" and type2 == "boolean" then
		return op1 == true
	else
		return tostring(op1) < tostring(op2) --cmp by address
	end
end

-- Combat log functions.
function gw2_combatdata.updateLog()
	local combatData = GetCombatData(gw2_combatdata.checkAllEntities)
	if (table.valid(combatData)) then
		local currentLog = gw2_combatdata.damageLog
		local newestTime = gw2_combatdata.timeLastUpdate
		for id,data in ipairs(combatData) do
			if (data and data.source ~= nil and (data.type == 7 or data.type == 2 or data.type == 3) and data.time > gw2_combatdata.timeLastUpdate) then
				if (data.time > newestTime) then
					newestTime = data.time
				end
				if ((data.type == 2 or data.type == 3) and currentLog[data.source] and currentLog[data.source][data.target]) then
					currentLog[data.source][data.target].timeOfDeath = data.time
				elseif (data.type == 7) then
					-- Create log entry if not there.
					if (not table.valid(currentLog[data.source])) then
						currentLog[data.source] = {}
					end
					-- Create log entry if not there.
					if (not table.valid(currentLog[data.source][data.target])) then
						currentLog[data.source][data.target] = {combatLog = {}, timeOfEngagement = data.time, timeOfLastHit = 0, timeOfDeath = 0,}
					end
					-- Update time of engagement.
					if (currentLog[data.source][data.target].timeOfEngagement > data.time) then
						currentLog[data.source][data.target].timeOfEngagement = data.time
					end
					-- Update time of last hit.
					if (currentLog[data.source][data.target].timeOfLastHit < data.time) then
						currentLog[data.source][data.target].timeOfLastHit = data.time
					end
					
					-- Add Damage to source>target log.
					if (data.amount < 0) then
						-- Damage can come in at the same exact MS, if so, add damage number. (we only log damage as given time, not each dmg seperate.
						if (currentLog[data.source][data.target].combatLog[data.time]) then
							currentLog[data.source][data.target].combatLog[data.time] = currentLog[data.source][data.target].combatLog[data.time] + math.abs(data.amount)
						else
							currentLog[data.source][data.target].combatLog[data.time] = math.abs(data.amount)
						end
					
					-- Add Geak to heal log.
					elseif (data.amount > 0) then
						-- Create log entry if not there.
						if (not table.valid(gw2_combatdata.healLog[data.target])) then
							gw2_combatdata.healLog[data.target] = {}
						end
						gw2_combatdata.healLog[data.target][data.time] = data.amount
					end
				end
			end
		end
		gw2_combatdata.timeLastUpdate = newestTime
	end
end

function gw2_combatdata.cleanLog()
	-- Clean damage log file.
	local oldestEntryTime = 0
	for sourceID,targets in pairs(gw2_combatdata.damageLog) do
		-- check if source still has any targets.
		if (table.valid(gw2_combatdata.damageLog[sourceID])) then
			-- remove target that have not been hit for 30 seconds.
			for targetid,targetLog in pairs(targets) do
				if (targetLog.timeOfDeath > 0) then
					if ((targetLog.timeOfDeath + 60000) < GetSystemTime()) then
						if (gw2_combatdata.damageLog[sourceID][targetid]) then
							gw2_combatdata.damageLog[sourceID][targetid] = nil
						end
						gw2_combatdata.damageLog[targetid] = nil
					end
				elseif ((targetLog.timeOfLastHit + 30000) < GetSystemTime() and gw2_combatdata.damageLog[sourceID]) then
					gw2_combatdata.damageLog[sourceID][targetid] = nil
				end
				if (targetLog.timeOfEngagement < oldestEntryTime) then
					oldestEntryTime = targetLog.timeOfEngagement
				end
			end
		else
			-- remove source with no targets.
			gw2_combatdata.damageLog[sourceID] = nil
		end
	end
	
	-- Clean heal log file.
	for entityID,healLog in pairs(gw2_combatdata.healLog) do
		if (table.valid(healLog)) then
			for timestamp in pairs(healLog) do
				if (timestamp < oldestEntryTime) then
					gw2_combatdata.healLog[entityID][timestamp] = nil
				end
			end
		else
			gw2_combatdata.healLog[entityID] = nil
		end
	end
	
end

function gw2_combatdata.getSourceTarget(sourceID,combatLog)
	local combatData = {
		timeOfEngagement = 0,
		timeOfLastEncounter = 0,
		engagementTime = 0,
		damage = 0,
		dps = 0,
		cDamage = 0,
		cdps = 0,
		heal = 0,
		hps = 0,
		ttk = 0,
	}
	if (type(sourceID) == "number" and table.valid(combatLog) and type(combatLog.targetid) == "number") then
		local sourceLog = gw2_combatdata.damageLog[sourceID]
		if (table.valid(sourceLog)) then
			local sourceTargetLog = sourceLog[combatLog.targetid]
			-- Get time of engagement and last encounter.
			if (table.valid(sourceTargetLog)) then
				combatData.timeOfEngagement = sourceTargetLog.timeOfEngagement
				-- combatData.timeOfLastEncounter = sourceTargetLog.timeOfDeath > 0 and sourceTargetLog.timeOfDeath or sourceTargetLog.timeOfLastHit
				combatData.timeOfLastEncounter = sourceTargetLog.timeOfDeath > 0 and sourceTargetLog.timeOfDeath or GetSystemTime() -- TODO: replace time function.
			end
			-- Check if we have valid times.
			if (combatData.timeOfEngagement and combatData.timeOfLastEncounter) then
				-- Iterate the source log for damage.
				for sTargetID,targetLog in pairs(sourceLog) do
					if (table.valid(targetLog)) then
						-- iterate the combat log.
						for timestamp,damageAmount in pairs(targetLog.combatLog) do
							if (timestamp >= combatData.timeOfEngagement and timestamp <= combatData.timeOfLastEncounter) then
								if (sTargetID == combatLog.targetid) then
									combatData.damage = combatData.damage + damageAmount
								end
								combatData.cDamage = combatData.cDamage + damageAmount
							end
						end
					end
				end
			end
		end
		
		local healLog = gw2_combatdata.healLog[combatLog.targetid]
		if (table.valid(healLog)) then
			for timestamp,healAmount in pairs(healLog) do
				if (timestamp > combatData.timeOfEngagement and timestamp < combatData.timeOfLastEncounter) then
					combatData.heal = combatData.heal + healAmount
				end
			end
		end
		
		combatData.engagementTime = (combatData.timeOfLastEncounter - combatData.timeOfEngagement) / 1000
		combatData.dps = combatData.engagementTime > 0 and math.round(combatData.damage / combatData.engagementTime) or 0
		combatData.cdps = combatData.engagementTime > 0 and math.round(combatData.cDamage / combatData.engagementTime) or 0
		combatData.hps = combatData.engagementTime > 0 and math.round(combatData.heal / combatData.engagementTime) or 0
		combatData.ttk = combatData.dps > 0 and combatLog.targetHealth.current / combatData.dps or 0
	end
	
	return combatData
end

function gw2_combatdata.updateCombatData()
	-- Create new table.
	local trackedIDs = {}
	-- Log everyone else's data.
	local players = CharacterList("player")
	-- Add player to the characterlist data.
	if (Player and Player.id) then
		players[Player.id] = Player
	end
	if (table.valid(players)) then
		for _,player in pairs(players) do
			local playerID = player.id
			
			if (gw2_combatdata.combatLog[playerID]) then
				trackedIDs[playerID] = table.deepcopy(gw2_combatdata.combatLog[playerID],false)
			end
			if (not table.valid(trackedIDs[playerID])) then
				trackedIDs[playerID] = {
					name = "",
					profession = 0,
					targetid = 0,
					targetName = "",
					targetHealth = {max = 0, current = 0, percent = 100,},
					combatData = {},
					buffData = {},
				}
			end
			
			local targetChanged = false
			if (player.castinfo and player.castinfo.targetid > 0 and player.castinfo.targetid ~= playerID and player.castinfo.targetid ~= trackedIDs[playerID].targetid) then
				trackedIDs[playerID].targetid = player.castinfo.targetid
				targetChanged = true
			end
			
			if (table.valid(trackedIDs[playerID])) then
				if (not string.valid(trackedIDs[playerID].name)) then
					trackedIDs[playerID].name = player.name
				end
				
				if (trackedIDs[playerID].profession == 0) then
					trackedIDs[playerID].profession = player.profession
				end
				
				
				
				if (trackedIDs[playerID].targetid) then
					local target = CharacterList:Get(trackedIDs[playerID].targetid) or GadgetList:Get(trackedIDs[playerID].targetid) or AgentList:Get(trackedIDs[playerID].targetid)
					if (table.valid(target) and target.attackable) then
						if (not string.valid(trackedIDs[playerID].targetName) or targetChanged) then
							trackedIDs[playerID].targetName = target.name
						end
						trackedIDs[playerID].targetHealth = target.health or {max = 0, current = 0, percent = 100,}
					end
				end
				
				local combatData = {}
				if (string.valid(trackedIDs[playerID].targetName)) then
					combatData = gw2_combatdata.getSourceTarget(playerID,trackedIDs[playerID])
				end
				trackedIDs[playerID].dps = combatData.dps or 0
				trackedIDs[playerID].hps = combatData.hps or 0
				trackedIDs[playerID].cdps = combatData.cdps or 0
				trackedIDs[playerID].damage = combatData.damage or 0
				trackedIDs[playerID].heal = combatData.heal or 0
				trackedIDs[playerID].cDamage = combatData.cDamage or 0
				trackedIDs[playerID].engagementTime = combatData.engagementTime or 0
				trackedIDs[playerID].ttk = combatData.ttk or 0
				
			end
		end
	end
	
	gw2_combatdata.combatLog = trackedIDs
end

function gw2_combatdata.getDisplayCombatData()
	local displayData = {}
	if (table.valid(gw2_combatdata.displayIDs)) then
		for playerID in pairs(gw2_combatdata.displayIDs) do
			displayData[playerID] = gw2_combatdata.combatLog[playerID]
		end
	
	elseif (gw2_combatdata.displayIDs == true) then
		return table.deepcopy(gw2_combatdata.combatLog)
		-- for playerID,combatData in pairs(gw2_combatdata.combatLog) do
			-- displayData[playerID] = combatData
		-- end
	end
	return displayData
end

-- Selected target functions.
function gw2_combatdata.updateSelectedTargetData()
	local target = Player:GetTarget()
	if (table.valid(target) and target.attackable and table.valid(target.health)) then
		gw2_combatdata.selectedTargetData = {
			id = target.id,
			health = {
				current	= target.health.current,
				max		= target.health.max,
				percent	= target.health.percent,
			},
			
		}
	else
		gw2_combatdata.selectedTargetData = {}
	end
end

-- Buff log functions.



-- Buff functions.


-- Update Loop
function gw2_combatdata.Update(_,ticks)
	if (Settings.gw2_combatdata.active2) then
		if (ticks - gw2_combatdata.updateTicks >= gw2_combatdata.upateTickDelay) then
			gw2_combatdata.updateTicks = ticks
			gw2_combatdata.updateLog()
			gw2_combatdata.updateCombatData()
			gw2_combatdata.updateSelectedTargetData()
		end
		if (ticks - gw2_combatdata.cleanTicks >= gw2_combatdata.cleanTickDelay) then
			gw2_combatdata.cleanTicks = ticks
			gw2_combatdata.cleanLog()
		end
	end
end




RegisterEventHandler("Module.Initalize",gw2_combatdata.Init)
RegisterEventHandler("Gameloop.Draw", gw2_combatdata.Draw)
RegisterEventHandler("Gameloop.Update",gw2_combatdata.Update)