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
						runcode = "if ml_navigation.fight_aggro and math.distance3d(ml_navigation.fight_aggro.pos, Player.pos) < 1200 and Player.inCombat then\n   local target = gw2_common_functions.AggroTargetAtPos(ml_navigation.fight_aggro.pos, 1200)\n\n   if target then\n      context.combat_targetid = target.id\n      context.combat_targetpos = target.pos\n      context.combat_moveintocombatrange = true\n      self:success()\n      return\n   end\nend\n\nml_navigation.fight_aggro = nil\nself:fail()",
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
						runcode = "if self.settings.state == 2 then\n\t\tself:fail()\nelse\n\t\tself:success()\nend",
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
				monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Active Child: '..tostring(self.actualTask or 'None'))",
			},
		},
	},
	settings = 
	{
	},
	variables = 
	{
		filename = "HandleOMCAggro.st",
		finishcode = "",
		info = "Handles Aggro before a OMC\nchecking for ml_navigation.fight_aggro",
		menucode = "",
		monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Filename: '..self.variables.filename) GUI:Text('Filepath: '..self.filepath)",
		runcode = "",
		startcode = "",
		subtreeuicode = "self.settings = self.settings or {}\nself.settings.range = GUI:InputInt(\"Range\", self.settings.range or 1200, 1, 1)\nself.settings.state = GUI:Combo(\"return on success\", self.settings.state or 1, {\"success\", \"fail\"})\n",
	},
}



return tbl