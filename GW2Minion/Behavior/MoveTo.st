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
					class = "SubTree",
					nodes = 
					{
					},
					settings = 
					{
					},
					variables = 
					{
						filename = "SwimHandler.st",
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
						info = "Do movement",
						monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
						runcode = "if ( table.valid ( context.moveto_position )) then \n\t\tlocal dist = ml_navigation:GetRaycast_Player_Node_Distance(context.moveto_position, ml_global_information.Player_Position )\n--\t\tlocal dist = math.distance3d(context.moveto_position, ml_global_information.Player_Position )\n\t\t-- Calculate the stoppingdistance, take the target radius into account\n\t\tlocal targetradius = self.targetradius or 25\n\t\tlocal stopdist = self.lowerstoppingdistance or 25\n\t\t\n\t\t-- We reached the targetposition already?\n\t\tstopdist = context.moveto_stoppingdistance or stopdist\n\n\t\tif ( dist <= stopdist) then\n\t\t\t\td(\"[Move To Position] - Target Position reached\")\n\t\t\t\tcontext.moveto_targettype = nil\n\t\t\t\tcontext.moveto_targetid = nil\n\t\t\t\tif(Player.mounted) then Player:Dismount() end\n\t\t\t\tself:success()\n\t\t\t\treturn\n\t\telse\n\n\t\t\t\t-- Waypoint Usage\n\t\t\t\tif (context.moveto_usewaypoints == true and ml_global_information.Player_InCombat == false and ml_global_information.Player_Alive and dist > 15000 and Inventory:GetInventoryMoney() > 500) then\t\t\t\t\n\t\t\t\t\t\tlocal waypoint = gw2_common_functions.GetClosestWaypointToPos(ml_global_information.CurrentMapID,context.moveto_position)\n\t\t\t\t\t\tif (table.valid(waypoint) and table.valid(waypoint.pos)) then\n\t\t\t\t\t\t\tlocal wDist = math.distance2d(waypoint.pos,context.moveto_position)\n\n\t\t\t\t\t\t\tif (wDist < (dist/2)) then\n\t\t\t\t\t\t\t\t\t\tPlayer:StopMovement()\n\t\t\t\t\t\t\t\t\t\tPlayer:TeleportToWaypoint(waypoint.id)\n\t\t\t\t\t\t\t\t\t\tml_global_information.Wait(5000)\n\t\t\t\t\t\t\t\t\t\tcontext.moveto_usewaypoints = false\n\t\t\t\t\t\t\t\t\t\tself:running()\n\t\t\t\t\t\t\t\t\t\treturn\n\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\tend\n\t\t\t\t\t\tcontext.moveto_usewaypoints = false\n\t\t\t\tend\n\n\t\t\t\t-- HandleStuck\n\t\t\t\tgw2_unstuck.unstuck_mode = context.unstuck_mode\n\t\t\t\tlocal newnodecount = Player:MoveTo(context.moveto_position.x,context.moveto_position.y,context.moveto_position.z, context.combat_targetid or 0, stopdist,context.moveto_randomMovement,context.moveto_smoothturns)\n\t\t\t\tcontext.newnodecount = newnodecount\n\t\t\t\tif ( newnodecount < 0 ) then\n\t\t\t\t\t\td(\"[Move To Position] - No Valid Path Found, Result: \"..tostring(newnodecount)..\" To Position:\"..tostring(math.floor(context.moveto_position.x))..\"/\"..tostring(math.floor(context.moveto_position.y))..\"/\"..tostring(math.floor(context.moveto_position.z)))\n\t\t\t\t\t\tif ( not self.failedcounter ) then self.failedcounter = 0 end\n\t\t\t\t\t\tif ( self.failedcounter < 10 ) then\n\t\t\t\t\t\t\t\tself.failedcounter = self.failedcounter + 1\n\t\t\t\t\t\t\t\tself:running()\n\t\t\t\t\t\t\t\treturn\n\t\t\t\t\t\telse\n\t\t\t\t\t\t\t\td(\"[Move To Position] - 10 x No Valid Path Found, MoveTo Failed\")\t\t\t\t\t\n\t\t\t\t\t\tend\n\t\t\t\t\t\tcontext.moveto_targettype = nil\n\t\t\t\t\t\tcontext.moveto_targetid = nil\n\t\t\t\t\t\tcontext.moveto_position = nil\n\t\t\t\t\t\tPlayer:StopMovement()\n\t\t\t\t\t\tself:fail()\n\t\t\t\t\t\treturn\n\t\t\t\telse\n\t\t\t\t\t\tself.failedcounter = 0\n\t\t\t\tend\n\t\tend\n\t\tself:running()\nelse\n\t\td(\"[Move To Position] - Invalid context.moveto_position !\")\n\t\tcontext.moveto_targettype = nil\n\t\tcontext.moveto_targetid = nil\n\t\tcontext.moveto_position = nil\n\t\tPlayer:StopMovement()\n\t\tself:fail()\nend",
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
				monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) \nGUI:Text('Active Child: '..tostring(self.actualTask or 'None'))\nGUI:Text('Running Child: '..tostring(self.runningTask or 'None'))\nGUI:Text('Is Node Running: '..tostring(self.nodeRunning or 'No'))\nGUI:Text('Parent: '..tostring(self.parent.parent.variables.info))",
			},
		},
	},
	settings = 
	{
	},
	variables = 
	{
		filename = "MoveTo.st",
		finishcode = "",
		info = "Move to Position. \nRequired input argument: context.moveto_position",
		menucode = "",
		monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Filename: '..self.variables.filename) GUI:Text('Filepath: '..self.filepath)\n\nif(context) then\n\t\tif(context.moveto_position) then\n\t\t\t\tlocal dist = math.distance3d(ml_global_information.Player_Position,context.moveto_position)\n\t\t\t\tGUI:Text(\"Distance to target position: \" .. tostring(math.round(dist,2)))\n\t\tend\nend",
		runcode = "",
		startcode = "-- Setting the custom subtree settings in the context, which gets passed down to childnodes\ncontext.moveto_stoppingdistance = self.settings.stoppingdistance or 25\nif(self.settings.randomizestoppingdistance) then\n\t\tcontext.moveto_stoppingdistance = math.random(self.settings.stoppingdistance, self.settings.stoppingidstancemaxrange)\nend\ncontext.moveto_randomMovement = self.settings.randomMovement or false\ncontext.moveto_smoothturns = self.settings.smoothturns or false\ncontext.moveto_usewaypoints = self.settings.usewaypoints or false\ncontext.moveto_follownavsystem = false",
		subtreeuicode = "if ( self.settings.stoppingdistance == nil ) then self.settings.stoppingdistance = 25 end\nself.settings.stoppingdistance = GUI:InputInt(GetString(\"Stopping Distance\"), self.settings.stoppingdistance, 1, GUI.InputTextFlags_CharsDecimal)\n\nif ( self.settings.randomizestoppingdistance == nil ) then self.settings.randomizestoppingdistance = false end\nself.settings.randomizestoppingdistance = GUI:Checkbox(GetString(\"Randomize stopping distance\"), self.settings.randomizestoppingdistance)\n\nif ( self.settings.stoppingidstancemaxrange == nil ) then self.settings.stoppingidstancemaxrange = self.settings.stoppingdistance*2 end\nif(self.settings.randomizestoppingdistance) then\n\t\tself.settings.stoppingidstancemaxrange = GUI:InputInt(GetString(\"Stopping Distance Max Range\"), self.settings.stoppingidstancemaxrange, 1, GUI.InputTextFlags_CharsDecimal)\n\t\tif(self.settings.stoppingidstancemaxrange < self.settings.stoppingdistance) then\n\t\t\t\tself.settings.stoppingidstancemaxrange = self.settings.stoppingdistance\n\t\tend\nend\n\nif ( self.settings.randomMovement == nil ) then self.settings.randomMovement = true end\nself.settings.randomMovement = GUI:Checkbox(GetString(\"Random Movement\"), self.settings.randomMovement )\n\nif ( self.settings.smoothturns == nil ) then self.settings.smoothturns = true end\nself.settings.smoothturns = GUI:Checkbox(GetString(\"Smooth Turns\"), self.settings.smoothturns )\n\nif ( self.settings.usewaypoints == nil ) then self.settings.usewaypoints = false end\nself.settings.usewaypoints = GUI:Checkbox(GetString(\"Use Waypoints\"), self.settings.usewaypoints )\nif ( GUI:IsItemHovered() ) then GUI:SetTooltip( \"When enabled, MoveTo will use waypoints if they are closer to the targetposition.\" ) end",
	},
}



return tbl