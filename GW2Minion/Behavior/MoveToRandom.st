local tbl = 
{
	class = "SubTree",
	nodes = 
	{
		
		{
			class = "AlwaysSucceed",
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
								runcode = "if(context.movetorandom_randompoint == nil and context.movetorandom_lastrandompointfailedlookup ~= nil) then\n\t\tlocal ts = TimeSince(context.movetorandom_lastrandompointfailedlookup)\n\t\tif(ts < 30000) then\n\t\t\t\tPlayer:StopMovement()\n\t\t\t\td(string.format(\"[MoveToRandom]: We failed to find a random point. Waiting to not spam path lookup (%s of %ss). \", math.round(ts/1000,0), 30))\n\t\t\t\tself:running()\n\t\t\t\treturn\n\t\telse\n\t\t\t\tcontext.movetorandom_lastrandompointfailedlookup = nil\n\t\tend\nend\nself:success()",
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
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
								runcode = "if (context.movetorandom_randompoint == nil) then\n\t\tif(ml_global_information.Player_OnMesh) then\n\t\t\t\t\t\tPlayer:StopMovement()\n\t\t\t\t\t\tcontext.movetorandom_randompoint = gw2_common_functions.GetRandomPoint()\n\t\telse\n\t\t\t\t-- Select the nearest waypoint so we at least have somewhere to go if we start offmesh\n\t\t\t\tlocal WPList = WaypointList()\n\t\t\t\tlocal nearesst = nil\n    local nearestdist = 99999999\n    for wid,wpentry in pairs(WPList) do\n       if(not wpentry.contested and wpentry.onmesh and ( not nearesst or (wpentry.distance < nearestdist))) then\n          nearestdist = wpentry.distance\n          nearesst = wpentry\n       end\n    end\n\t\t\t\tif(nearesst and nearesst.pos) then\n\t\t\t\t\t\tcontext.movetorandom_randompoint = nearesst.pos\n\t\t\t\tend\n\t\tend\n\n\t\tif(table.valid(context.movetorandom_randompoint)) then\n\t\t\t\tcontext.movetorandom_lastrandompointfetched = ml_global_information.Now\n\t\t\t\tcontext.movetorandom_randompoint_notreachable = nil\n\t\tend\nend\n\nif(table.valid(context.movetorandom_randompoint)) then\n\t\tself:success()\nelse\n\t\tcontext.movetorandom_lastrandompointfailedlookup = ml_global_information.Now\n\t\tself:fail()\nend",
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
										runcode = "if(context.movetorandom_lastrandompointfetched) then\n\t\tself.rndtimer = self.rndtimer or math.random(1000,3500)\n\t\tlocal ts = TimeSince(context.movetorandom_lastrandompointfetched)\n\t\tif(ts < self.rndtimer) then\n\t\t\t\tPlayer:StopMovement()\n\t\t\t\td(string.format(\"[MoveToRandom]: We just got a new random point. Waiting a bit. (%s of %ss). \", math.round(ts/1000,0), math.round(self.rndtimer/1000,0)))\n\t\t\t\tself:running()\n\t\t\t\treturn\n\t\tend\n\t\tself.rndtimer = nil\nend\nself:fail()",
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
										monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
										runcode = "if(table.valid(context.movetorandom_randompoint)) then\n\t\tif(context.moveto_stoppingdistance) then\n\t\t\t\tlocal dist = math.distance3d(context.movetorandom_randompoint,ml_global_information.Player_Position)\n\t\t\t\tif(dist <= context.moveto_stoppingdistance or dist < 150) then\n\t\t\t\t\t\tcontext.movetorandom_randompoint = nil\n\t\t\t\t\t\tself:success()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\t\tend\n\n\t\tif(not NavigationManager:IsReachable(context.movetorandom_randompoint)) then\n\t\t\t\tif(context.movetorandom_randompoint_notreachable == nil) then\n\t\t\t\t\t\tcontext.movetorandom_randompoint_notreachable = ml_global_information.Now\n\t\t\t\tend\n\t\t\t\t\n\t\t\t\tif(TimeSince(context.movetorandom_randompoint_notreachable) > 60000) then\n\t\t\t\t\t\td(\"[MoveToRandom]: Random point not reachable for over 60 seconds, resetting\")\n\t\t\t\t\t\tcontext.movetorandom_randompoint = nil\n\t\t\t\t\t\tself:success()\n\t\t\t\t\t\treturn\t\t\n\t\t\t\tend\n\t\telse\n\t\t\t\tcontext.movetorandom_randompoint_notreachable = nil\n\t\tend\nend\nself:fail()",
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
												runcode = "if(table.valid(context.movetorandom_randompoint)) then\n\t\tcontext.moveto_position = context.movetorandom_randompoint\n\t\tself:success()\nelse\n\t\tself:fail()\nend",
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
												randomizestoppingdistance = true,
												smoothturns = true,
												stoppingdistance = 750,
												stoppingidstancemaxrange = 2000,
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
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Active Child: '..tostring(self.runningTask or 'None'))",
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
				monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
			},
		},
	},
	settings = 
	{
	},
	variables = 
	{
		filename = "MoveToRandom.st",
		finishcode = "",
		info = "Move to random",
		menucode = "",
		monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Filename: '..self.variables.filename) GUI:Text('Filepath: '..self.filepath)\n\nif(context) then\n\t\tif(context.movetorandom_randompoint) then\n\t\t\t\tlocal dist = math.distance3d(ml_global_information.Player_Position,context.movetorandom_randompoint)\n\t\t\t\tGUI:Text(\"Distance: \" .. tostring(math.round(dist,2)))\n\t\t\t\tGUI:Text(\"Stopping distance: \" .. tostring(context.moveto_stoppingdistance))\n\t\t\t\tGUI:Text(\"Distance to end pos: \" .. tostring(math.round(dist-context.moveto_stoppingdistance,2)))\n\t\tend\nend",
		runcode = "",
		startcode = "",
		subtreeuicode = "",
	},
}



return tbl