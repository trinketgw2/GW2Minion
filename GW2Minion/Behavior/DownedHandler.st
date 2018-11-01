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
						runcode = "if (ml_global_information.Player_HealthState == GW2.HEALTHSTATE.Downed ) then\n\t\tlocal assistmode = BehaviorManager:CurrentBTreeName() == GetString(\"AssistMode\")\n\n\t\tcontext.downedstate = true\n\t\tcontext.combat_target = nil\n\t\tcontext.combat_targetid = nil\n\t\tcontext.combat_moveintocombatrange = false\n\t\tcontext.combat_onmeshcheck = false\n\t\tgw2_combat_movement:StopCombatMovement()\n\t\tif ( ml_global_information.Player_IsMoving == true ) then\n\t\t\tPlayer:StopMovement()\n\t\tend\n\n\t\tif(assistmode == false or Settings.GW2Minion.assistuseskillsdownstate) then\n\t\t\t\t-- Heal \n\t\t\t\tif(Player.castinfo.slot == GW2.SKILLBARSLOT.Slot_4) then\n\t\t\t\t\t\tml_global_information.Wait(500)\n\t\t\t\t\t\tself:running()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\n\t\t\t\tlocal healskill = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_4)\n\t\t\t\tif(healskill and healskill.cooldown == 0) then\n\t\t\t\t\t\tPlayer:CastSpell(GW2.SKILLBARSLOT.Slot_4)\n\t\t\t\t\t\tml_global_information.Wait(500)\n\t\t\t\t\t\tself:running()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\n\t\t\t\t-- Attack nearby target\n\t\t\t\tlocal target = gw2_common_functions.GetBestDownstateTarget()\n\t\t\t\tif (table.valid(target)) then\n\t\t\t\t\t\tcontext.combat_targetid = target.id\n\t\t\t\t\t\tcontext.combat_targetpos = target.pos\n\t\t\t\t\t\tSkillManager:SetTarget(context.combat_targetid)\n\t\t\t\t\t\tself:fail()\n\t\t\t\t\t\treturn\n\t\t\t\tend \n\t\tend\n\t\tself:running()\nelseif(context.downedstate) then\n\t\t-- Make sure to force reset the running combat tree\n\t\tcontext.downedstate = false\n\t\tcontext.combat_targetid = nil\n\t\tcontext.combat_target = nil\n\t\tcontext.combat_onmeshcheck = nil\n\t\tcontext.combat_moveintocombatrange = nil\n\t\tself:success()\nelse\n\t\tself:fail()\nend",
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
								runcode = "if (context.downedstate and ml_global_information.Player_HealthState == GW2.HEALTHSTATE.Downed ) then\n\t\tself:success()\nelse\n\t\tself:fail()\nend",
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
		filename = "DownedHandler.st",
		finishcode = "",
		info = "Downed Handler",
		menucode = "",
		monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Filename: '..self.variables.filename) GUI:Text('Filepath: '..self.filepath)",
		runcode = "",
		startcode = "",
		subtreeuicode = "",
	},
}



return tbl