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
						info = "",
						monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
						runcode = "if(not context.revive_targetid or not context.revive_position) then\n\t\tcontext.revive_targetid = nil\n\t\tcontext.revive_position = nil\nend\n\nself:fail()\n",
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
						info = "Check player health",
						monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
						runcode = "if(context.revive_targetid) then\n\t\tlocal minhp = type(context.revive_minplayerhp) == \"number\" and context.revive_minplayerhp or 30\n\t\tif(ml_global_information.Player_Health.percent < minhp) then\n\t\t\t\tcontext.revive_targetid = nil\n\t\t\t\tcontext.revive_position = nil\n\t\t\t\tPlayer:Jump()\n\t\tend\nend\n\nself:fail()",
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
						runcode = "if(context.revive_targetid and context.revive_position) then\n\t\tlocal dist = math.distance3d(ml_global_information.Player_Position,context.revive_position)\n\t\tif(dist > 1500) then\n\t\t\t\tself:fail()\n\t\t\t\treturn\n\t\telse\n\t\t\t\tlocal target = CharacterList:Get(context.revive_targetid)\n\t\t\t\tif(table.valid(target) and (target.downed or (not PvPManager:IsInMatch() and target.dead)) and target.onmesh and target.isreachable) then\n\t\t\t\t\t\tif(target.distance > 130 or not target.isininteractrange) then\n\t\t\t\t\t\t\t\tcontext.revive_position = target.pos\n\t\t\t\t\t\t\t\tself:fail()\n\t\t\t\t\t\t\t\treturn\n\t\t\t\t\t\tend\n\t\t\t\t\t \n\t\t\t\t\t\tlocal pTarget = Player:GetTarget()\n\t\t\t\t\t\tif(pTarget == nil or pTarget.id ~= target.id) then\n\t\t\t\t\t\t\t\tPlayer:SetTarget(target.id)\n\t\t\t\t\t\tend\n\n\t\t\t\t\t\tPlayer:StopMovement()\n\t\t\t\t\t\tPlayer:SetFacing(target.pos.x,target.pos.y,target.pos.z)\n\t\t\t\t\t\tPlayer:Interact(target.id)\n\t\t\t\t\t\tml_global_information.Wait(math.random(500,900))\n\t\t\t\t\t\tself:running()\n\t\t\t\t\t\treturn\n\t\t\t\telse\n\t\t\t\t\t\tif(PvPManager:IsInMatch()) then\n\t\t\t\t\t\t\t\td(\"[Revive]: Target is alive or dead already.\")\n\t\t\t\t\t\telse\n\t\t\t\t\t\t\t\td(\"[Revive]: Target is alive or gone.\")\n\t\t\t\t\t\tend\n\t\t\t\tend\n\t\tend\nend\ncontext.revive_targetid = nil\ncontext.revive_position = nil\nself:fail()",
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
								runcode = "if(context.revive_position) then\n\t\tcontext.moveto_position = context.revive_position\n\t\tself:success()\nelse\n\t\tself:fail()\nend",
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
								stoppingdistance = 120,
								stoppingidstancemaxrange = 240,
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
		filename = "ReviveActionHandler.st",
		finishcode = "context.revive_position = nil\ncontext.revive_targetid = nil",
		info = "Revive action\ncontext.revive_position\ncontext.revive_targetid",
		menucode = "",
		monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Filename: '..self.variables.filename) GUI:Text('Filepath: '..self.filepath)",
		runcode = "",
		startcode = "",
		subtreeuicode = "",
	},
}



return tbl
