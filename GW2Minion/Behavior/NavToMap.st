local tbl = 
{
	class = "SubTree",
	nodes = 
	{
		
		{
			class = "PrioritySelector",
			nodes = 
			{
				
				{
					class = "Action",
					nodes = 
					{
					},
					settings = 
					{
					},
					variables = 
					{
						finishcode = "",
						info = "Wait for mesh to load",
						monitorcode = "",
						runcode = "local meshstate = NavigationManager:GetNavMeshState()\n\nif(meshstate ~= GLOBAL.MESHSTATE.MESHREADY) then\n\t\td(\"[NavToMap]: Waiting for the mesh to load.\")\n\t\tself:running()\n\t\treturn\nend\n\nself:fail()",
						startcode = "",
					},
				},
				
				{
					class = "Action",
					nodes = 
					{
					},
					settings = 
					{
					},
					variables = 
					{
						finishcode = "",
						info = "Target map check",
						monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
						runcode = "if(not context.movetomap_targetmapid) then\n\td(\"[MoveToMap]: No target map set\")\nend\n\nif(context.movetomap_targetmapid == ml_global_information.CurrentMapID) then\n\td(\"[MoveToMap]: Target map reached\")\n\tself:success()\n\treturn\nend\n\nself:fail()",
						startcode = "",
					},
				},
				
				{
					class = "Action",
					nodes = 
					{
					},
					settings = 
					{
					},
					variables = 
					{
						finishcode = "",
						info = "Update node data",
						monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
						runcode = "if(context.movetomap_targetmapid) then\n\t\tif (ml_global_information.CurrentMapID ~= context.movetomap_lastmapid ) then\n\t\t\t\tPlayer:StopMovement()\n\t\t\t\tif(context.movetomap_lastmapid) then\n\t\t\t\t\t\tml_global_information.Wait(2000,5000)\n\t\t\t\tend\n\t\t\t\tcontext.movetomap_lastmapid = ml_global_information.CurrentMapID\n\t\t\t\tcontext.movetomap_gatereached = false\n\t\t\t\tcontext.movetomap_usedwaypoint = false\n\t\t\t\t\n\t\t\t\tself:running()\n\t\t\t\treturn\n\t\tend\n\n\t\tif(context.movetomap_gatedistance and not context.movetomap_gatereached and context.movetomap_gatedistance < 60) then\n\t\t\t\tcontext.movetomap_gatereached = true\n\t\t\t\tPlayer:StopMovement()\n\t\t\t\tself:running()\n\t\t\t\treturn\n\t\tend\n\n\t\tlocal nodedata = ml_nav_manager.GetNextPathPos(ml_global_information.Player_Position, ml_global_information.CurrentMapID, context.movetomap_targetmapid )\n\t\tif(table.valid(nodedata)) then\n\t\t\t\tcontext.movetomap_nextpathpos = nodedata\n\t\t\t\tcontext.movetomap_gatedistance = math.distance3d(nodedata,ml_global_information.Player_Position)\n\t\tend\n\nend\nself:fail()",
						startcode = "",
					},
				},
				
				{
					class = "PrioritySelector",
					nodes = 
					{
						
						{
							class = "Action",
							nodes = 
							{
							},
							settings = 
							{
							},
							variables = 
							{
								finishcode = "",
								info = "Leave instance",
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
								runcode = "if (gw2_common_functions.PlayerInInstance()) then\n\t\tml_global_information.Wait(math.random(2000,6000))\n\t\tPlayer:LeaveInstance()\n\t\tself:running()\nelse\n\t\tself:fail()\nend",
								startcode = "",
							},
						},
						
						{
							class = "Action",
							nodes = 
							{
							},
							settings = 
							{
							},
							variables = 
							{
								finishcode = "",
								info = "Use waypoint",
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
								runcode = "-- Waypoint Usage\nif(context.movetomap_targetmapid) then\n\t\tif (context.movetomap_usewaypoints == true and not context.movetomap_usedwaypoint and Inventory:GetInventoryMoney() > (139*math.log10(ml_global_information.Player_Level))*2) then\n\t\t\t\tlocal waypoint = {}\n\t\t\t\tif (table.valid(context.movetomap_position)) then\n\t\t\t\t\t\twaypoint = gw2_common_functions.GetClosestWaypointToPos(context.movetomap_targetmapid,context.movetomap_position)\n\t\t\t\telse\n\t\t\t\t\t\tlocal wpList = gw2_datamanager.GetLocalWaypointList(context.movetomap_targetmapid)\n\t\t\t\t\t\tif (table.valid(wpList)) then\n\t\t\t\t\t\t\t\twaypoint = wpList[math.random(1,table.size(wpList))]\n\t\t\t\t\t\tend\n\t\t\t\tend\n\t\t\t\td(waypoint)\n\t\t\t\tif(table.valid(waypoint) == false) then\n\t\t\t\t\t\twaypoint = gw2_common_functions.GetClosestWaypointToMap(context.movetomap_targetmapid)\n\t\t\t\t\t\tif(table.valid(waypoint) and waypoint.mapid == ml_global_information.CurrentMapID) then\n\t\t\t\t\t\t\t\twaypoint = nil\n\t\t\t\t\t\tend\n\t\t\t\tend\n\n\t\t\t\tif (table.valid(waypoint) and ml_global_information.Player_InCombat == false) then\n\t\t\t\t\t\tPlayer:StopMovement()\n\t\t\t\t\t\tPlayer:TeleportToWaypoint(waypoint.id)\n\t\t\t\t\t\tml_global_information.Wait(math.random(3000,8000))\n\t\t\t\t\t\tcontext.movetomap_usedwaypoint = true\n\t\t\t\t\t\tself:running()\n\t\t\t\t\t\treturn\n\t\t\t\telseif (table.valid(waypoint) == false) then\n\t\t\t\t\t\tcontext.movetomap_usedwaypoint = true\n\t\t\t\tend\n\t\tend\nend\nself:fail()",
								startcode = "",
							},
						},
						
						{
							class = "Sequence",
							nodes = 
							{
								
								{
									class = "Action",
									nodes = 
									{
									},
									settings = 
									{
									},
									variables = 
									{
										finishcode = "",
										info = "",
										monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
										runcode = "if(context.movetomap_targetmapid and context.movetomap_nextpathpos and context.movetomap_gatedistance and context.movetomap_gatedistance > 50 and not context.movetomap_gatereached) then\n\t\tcontext.moveto_position = context.movetomap_nextpathpos\n\t\tself:success()\nelse\n\t\tself:fail()\nend ",
										startcode = "",
									},
								},
								
								{
									class = "SubTree",
									nodes = 
									{
									},
									settings = 
									{
										randomMovement = true,
										randomizestoppingdistance = false,
										smoothturns = true,
										stoppingdistance = 50,
										stoppingidstancemaxrange = 100,
										usewaypoints = true,
									},
									variables = 
									{
										filename = "MoveTo.st",
									},
								},
							},
							settings = 
							{
							},
							variables = 
							{
								info = "",
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Active Child: '..tostring(self.actualTask or 'None'))",
							},
						},
						
						{
							class = "Action",
							nodes = 
							{
							},
							settings = 
							{
							},
							variables = 
							{
								finishcode = "",
								info = "Move to portal",
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
								runcode = "local nodedata = context.movetomap_nextpathpos\nif(table.valid(nodedata)) then\n\tif ( nodedata.type == \"Dungeon\" ) then\n\t\tif ( Player:IsInstanceDialogShown() ) then\n\t\t\tlocal dInfo = Player:GetInstanceInfo()\n\t\t\t\n\t\t\t-- Join/Open dungeon depending on our role\n\t\t\tif ( Player:JoinInstance() == false ) then\n\t\t\t\t-- check for available dungeonModeIDs and selected them\t\t\t\t\t\t\t\t\t\t\n\t\t\t\tlocal modeID = 0\n\t\t\t\tif ( nodedata.modeID ~= nil ) then\n\t\t\t\t\tif ( dInfo.instanceModeID == tonumber(nodedata.modeID) ) then modeID = dInfo.instanceModeID end\n\t\t\t\t\tif ( dInfo.instanceMode2ID == tonumber(nodedata.modeID) ) then modeID = dInfo.instanceMode2ID end\n\t\t\t\tend\n\t\t\t\t\n\t\t\t\tif ( nodedata.mode ~= nil and nodedata.mode == \"Exploration\" and modeID ~= 0 ) then\n\t\t\t\t\td(\"Opening new Exploration instance.\")\n\t\t\t\t\tPlayer:OpenInstance(modeID,0)\t\t\t\t\t\t\t\t\t\t\t\n\t\t\t\t\t\n\t\t\t\telseif ( nodedata.mode ~= nil and nodedata.mode == \"Story\" and modeID ~= 0 ) then\n\t\t\t\t\td(\"Opening new Story instance.\")\n\t\t\t\t\tPlayer:OpenInstance(modeID,0)\n\t\t\t\t\t\n\t\t\t\telse\n\t\t\t\t\tPlayer:OpenInstance()\n\t\t\t\t\td(\"Opening instance.\")\n\t\t\t\tend\n\t\t\t\t\n\t\t\telse\n\t\t\t\td(\"Joining Dungeon...\")\n\t\t\t\t\n\t\t\tend\t\n\t\t\tml_global_information.Wait(2000)\n\t\t\tself:success()\n\t\t\treturn\n\t\tend\n\tend\n\n\tif ( not ml_global_information.Player_IsMoving ) then\n\t\tPlayer:SetFacingH(nodedata.hx,nodedata.hy,nodedata.hz)\n\t\tPlayer:SetMovement(GW2.MOVEMENTTYPE.Forward)\n\tend\n\tself:running()\nelse\n\tself:fail()\nend",
								startcode = "",
							},
						},
					},
					settings = 
					{
					},
					variables = 
					{
						info = "",
						monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Active Child: '..tostring(self.runningTask or 'None'))",
					},
				},
			},
			settings = 
			{
			},
			variables = 
			{
				info = "Requires: context.movetomap_targetmapid",
				monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Active Child: '..tostring(self.runningTask or 'None'))",
			},
		},
	},
	settings = 
	{
	},
	variables = 
	{
		filename = "NavToMap.st",
		finishcode = "context.movetomap_targetmapid = nil\ncontext.movetomap_usewaypoints = nil\ncontext.movetomap_usedwaypoint = nil\ncontext.movetomap_nextpathpos = nil\ncontext.movetomap_gatedistance = nil",
		info = "Move to map\ncontext.movetomap_targetmapid\n\nOptional:\ncontext.movetomap_position",
		menucode = "",
		monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Filename: '..self.variables.filename) GUI:Text('Filepath: '..self.filepath)\n\nif(context) then\n\t\tGUI:Text('Target map: '..tostring(context.movetomap_targetmapid))\n\t\tGUI:Text('Current map: '..tostring(ml_global_information.CurrentMapID))\n\t\tGUI:Text('Next gate distance: '..tostring(context.movetomap_gatedistance))\n\t\tGUI:Text('Gate reached: '..tostring(context.movetomap_gatereached))\nend",
		runcode = "",
		startcode = "context.movetomap_targetmapid = context.movetomap_targetmapid or self.settings.targetmapid\ncontext.movetomap_usewaypoints = self.settings.usewaypoints",
		subtreeuicode = "if(table.valid(gw2_datamanager.mapData)) then\n\tlocal maplist = {}\n\tlocal mapnamelist = {}\n\t\n\tfor mapID,map in pairs(gw2_datamanager.mapData) do\n\t\t\tif(ml_nav_manager.GetNode(mapID)) then\n\t\t\t\t\tlocal name = map.map_name..\" (\"..mapID..\")\"\n\t\t\t\t\ttable.insert(mapnamelist, name)\n\t\t\t\t\ttable.insert(maplist, {id = mapID, name = name})\n\t\t\tend\n\tend\n\ttable.sort(mapnamelist)\n\ttable.sort(maplist, function(a,b) return a.name < b.name end)\n\t\n\tlocal selectedIndex,changed = GUI:Combo(\"Select map\", self.settings.selectedmapindex or 1, mapnamelist)\n\tif(changed) then\n\t\t\tself.settings.selectedmapindex = selectedIndex\n\t\t\tself.settings.targetmapid = maplist[selectedIndex].id\n\tend\n\t\n\tlocal checked,pressed = GUI:Checkbox(\"Use waypoints\", self.settings.usewaypoints or false)\n\tif(pressed) then\n\t\t\tself.settings.usewaypoints = checked\n\tend\nelse\n\tGUI:Text(\"No map data available\")\nend\n",
	},
}



return tbl