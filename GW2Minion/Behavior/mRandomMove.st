local tbl = 
{
	class = "SubTree",
	nodes = 
	{
		
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
						monitorcode = "",
						runcode = "context.cStatus = \"random\"\nself:success()",
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
								info = "",
								monitorcode = "",
								runcode = "---get random wp to go 40k range and generate random position\nif context.rm == nil then context.rm = {} end\nself.mapid = self.mapid or context.mapid\nif not context.listedWp then\n    context.listedWp = {[0]=true}\nend\nif self.mapid ~= context.mapid then\n    self.mapid = context.mapid\n    context.listedWp = {[0]=true}\n    context.rm = {}\nend\n\nif not table.valid(context.rm.randomWp) then\n    local wlist = WaypointList()\n\n    local randolist = {}\n    ---get random wp in 30000\n    for i , b in pairs(wlist) do\n        if not context.listedWp[b.id] and b.distance < 30000 then\n            if not table.valid(randolist) then\n                randolist= {[0] = b}\n            else\n                table.insert(randolist,1,b)\n            end\n        end\n    end\n    --d(randolist)\n    if table.valid(randolist) then\n        context.rm.randomWp = randolist[math.random(0,table.size(randolist))]\n    else\n        d(\"[madaobase] refresh random to\")\n        context.listedWp = {[0]=true}\n        self:success()\n        return\n    end\n\nend\n\nif table.valid(context.rm.randomWp) then\n    if context.rm.randomWp.pathdistance >= 10000000 then\n        d(\"[madaobase] this is not on the same map d/random\")\n        context.rm.randomWp = nil\n        self:success()\n        return\n    end\n    self:fail()\n    return\nend\nself:success()",
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
								info = "",
								monitorcode = "",
								runcode = "---get random pos around wp +- 4000 atm\nif table.valid(context.rm.randomPos) then\n    --\td(\"random pos valid\")\n    self:fail()\n    return\nend\n\nif table.valid(context.rm.randomWp) then\n    --generate random cordi and test it every 5sec\n\n    if not table.valid(context.rm.randomPos) and (not self.time or ml_global_information.Now - self.time > 5000) then\n        self.time = ml_global_information.Now\n        local wpos = context.rm.randomWp.pos\n        local xrando = wpos.x + math.random(0,8000) - 4000\n        local yrando = wpos.y + math.random(0,8000) - 4000\n\n        local rpos = NavigationManager:GetClosestPointOnMeshFrom2D({x=xrando,y=yrando,z=wpos.z})\n        d(rpos)\n        if table.valid(rpos) and rpos.z ~= 0 and NavigationManager:IsOnMesh(rpos) then\n            context.rm.randomPos = rpos\n        end\n        if table.valid(context.rm.randomPos) then\n            context.moveto_position = context.rm.randomPos\n            context.randoTag = ml_global_information.Now\n            self:fail()\n            return\n        end\n    end\n\n    self:fail()\n    return\nend\nself:success()",
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
								info = "",
								monitorcode = "",
								runcode = "--set random context.moveto_position\nif not context.moveto_position then\n    if table.valid(context.rm.randomPos) then\n        context.moveto_position = context.rm.randomPos\n    else\n        context.moveto_position = context.rm.randomWp.pos\n    end\nend\n\nif context.moveto_position then\n    if math.distance3d(context.moveto_position,Player.pos) < 1000 then\n        context.moveto_position = nil\n        context.rm = {}\n        self:success()\n        return\n    end\n    self:fail()\n    return\nend\nself:success()",
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
										monitorcode = "",
										runcode = "if context.moveto_position then\n\tself:success()\n\treturn\nend\n\tself:fail()",
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
										stoppingdistance = 25,
										stoppingidstancemaxrange = 50,
										usewaypoints = false,
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
					},
					settings = 
					{
					},
					variables = 
					{
						info = "",
						monitorcode = "",
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
	},
	settings = 
	{
	},
	variables = 
	{
		filename = "mRandomMove.st",
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