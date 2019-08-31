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
						info = "Find Aggro Target and Set the aggro context.combat_targetid",
						monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
						runcode = "local target = gw2_common_functions.GetBestAggroTarget()\nif (table.valid(target) and not gw2_blacklistmanager.CheckBlacklistEntry(GetString(\"Monsters\"),target.contentid) and not gw2_blacklistmanager.CheckBlacklistEntry(GetString(\"Temporary Combat\"),target.id)) then\n\t\tif(context.combat_targetid ~= target.id) then\n\t\t\t\t Player:StopMovement()\n\t\tend\n\t\tcontext.combat_targetid = target.id\n\t\tcontext.combat_targetpos = target.pos\n\t\tcontext.status = \"Attacking Target \"..target.name\n\t\tself:success()\n\t\treturn\nelseif(table.valid(target)) then\n\t\tcontext.combat_targetid = nil\nend\n\nself:fail()\n",
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
								info = "Aggro CombatOverWatch - updates context.combat_target ",
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
								runcode = "if ( context.combat_targetid ) then\n\t\tlocal target = CharacterList:Get(context.combat_targetid) or GadgetList:Get(context.combat_targetid)\n\n\t\tif (table.valid(target) and not gw2_blacklistmanager.CheckBlacklistEntry(GetString(\"Monsters\"),target.contentid) and not gw2_blacklistmanager.CheckBlacklistEntry(GetString(\"Temporary Combat\"),target.id) and (target.isaggro or target.isplayer) and target.attackable and (target.alive or target.downed)) then\n\t\t\t\tcontext.combat_targetid = target.id\n\t\t\t\tcontext.combat_targetpos = target.pos\n\n\t\t\t\t-- switch aggro target if a better one was found\n\t\t\t\tlocal bettertarget = gw2_common_functions.GetBestAggroTarget()\n\t\t\t\tif (table.valid(bettertarget) and bettertarget.id ~= target.id and not gw2_blacklistmanager.CheckBlacklistEntry(GetString(\"Monsters\"),bettertarget.contentID) and not gw2_blacklistmanager.CheckBlacklistEntry(GetString(\"Temporary Combat\"),bettertarget.id)) then\n\t\t\t\t\t\tcontext.combat_targetid = bettertarget.id\n\t\t\t\t\t\tcontext.combat_targetpos = bettertarget.pos\n\t\t\t\t\t\tcontext.status = \"Attacking Target \"..bettertarget.name\n\t\t\t\tend\n\t\t\t\tcontext.combat_moveintocombatrange = true\n\t\telse\n\t\t\t\td(\"[HandleAggro] - Aggro Target is dead or gone\")\n\t\t\t\tcontext.combat_targetid = nil\n\t\t\t\tcontext.combat_target = nil\n\t\tend\nend\nself:fail()",
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
							},
							variables = 
							{
								filename = "CombatHandler.st",
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
				filename = "HandleAggro",
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
		filename = "HandleAggro.st",
		finishcode = "",
		info = "Handle Aggro",
		menucode = "",
		monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Filename: '..self.variables.filename) GUI:Text('Filepath: '..self.filepath)",
		runcode = "",
		startcode = "",
		subtreeuicode = "",
	},
}



return tbl