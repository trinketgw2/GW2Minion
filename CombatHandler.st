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
						interruptcode = "",
						monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
						runcode = "if( context.combat_targetid ) then\n\t\tself:success()\n\t\treturn\nend\n\nself:fail()",
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
								info = "Setting up movement",
								interruptcode = "",
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
								runcode = "if(context.combat_moveintocombatrange == nil) then\n\t\tcontext.combat_moveintocombatrange = true\nend\nself:fail()",
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
										interruptcode = "",
										monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
										runcode = "if(not table.valid(context.combat_targetpos)) then\n\td(\"[Combat]: No valid context.combat_targetpos\")\nelseif (context.combat_moveintocombatrange and context.combat_targetid) then\n\t\tif (math.distance3d(ml_global_information.Player_Position,context.combat_targetpos) > 2500 ) then \n\t\t\t\tcontext.moveto_position = context.combat_targetpos\n\t\t\t\tself:success()\n\t\t\t\treturn\n\t\tend\nend\nself:fail()",
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
										stoppingdistance = 2400,
										stoppingidstancemaxrange = 5000,
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
								finishcode = "",
								info = "",
								interruptcode = "",
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Active Child: '..tostring(self.actualTask or 'None'))",
								runcode = "",
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
								info = "Update target",
								interruptcode = "",
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
								runcode = "if ( context.combat_targetid ) then\n\t\tlocal combatmovement = gw2_common_functions:GetCombatMovement() or {}\n\t\tlocal target = CharacterList:Get(context.combat_targetid) or GadgetList:Get(context.combat_targetid)\n\t\tif (table.valid(target) and target.attackable and (target.alive or target.downed) and not gw2_blacklistmanager.CheckBlacklistEntry(GetString(\"Monsters\"),target.contentid) and not gw2_blacklistmanager.CheckBlacklistEntry(GetString(\"Temporary Combat\"),target.id) and (BehaviorManager:CurrentBTreeName() == GetString(\"AssistMode\") or target.isreachable)) then\n\t\t\t\t-- continue in the PrioritySelector parent\n\t\t\t\tcontext.combat_target = target\n\t\t\t\tcontext.combat_targetid = target.id\n\t\t\t\tcontext.combat_targetpos = target.pos\n\t\telse\n\t\t\t\tif(target and not target.isreachable) then\n\t\t\t\t\t\td(\"[CombatHandler]: Target '\"..target.name..\"' is not reachable, ignoring it until we can reach it again.\")\n\t\t\t\t\t\tgw2_blacklistmanager.AddBlacklistEntry(GetString(\"Temporary Combat\"), target.id, target.name, 5000, gw2_common_functions.BlackListUntilReachableAndAttackable)\n\t\t\t\telse\n\t\t\t\t\t\td(\"[CombatHandler]: Target is dead or not attackable.\")\n\t\t\t\tend\n\n\t\t\t\tcontext.combat_targetid = nil\n\t\t\t\tcontext.combat_target = nil\n\t\t\t\tcontext.combat_targetpos = nil\n\t\t\t\tcontext.combat_moveintocombatrange = nil\n\t\t\t\tcontext.combat_onmeshcheck = nil\n\t\t\t\tcontext.combat_targetcheck = nil\n\t\t\t\tcombatmovement.range = false\n\t\t\t\tcombatmovement.combat = false\n\t\tend\nelse\n\t\tcontext.combat_target = nil\nend\nself:fail()",
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
								info = "Check target health",
								interruptcode = "",
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
								runcode = "context.combat_targetcheck = context.combat_targetcheck or {}\nlocal onmeshcheck = context.combat_onmeshcheck == nil and true or context.combat_onmeshcheck\n\nif(context.combat_target) then\n\t\tlocal target_health = context.combat_target.health.percent\n\t\t\n\t\tif(context.combat_target.id == context.combat_targetcheck.id and context.combat_target.contentid == context.combat_targetcheck.contentid) then\n\t\t\t\t-- Reset health if the target gains more then 5% health since the last tick (3% ooc rate)\n\t\t\t\tif(context.combat_targetcheck.currenthealth and target_health-context.combat_targetcheck.currenthealth > 5) then\n\t\t\t\t\t\tcontext.combat_targetcheck.health = target_health\n\t\t\t\t\t\tcontext.combat_targetcheck.healthresets = context.combat_targetcheck.healthresets + 1\n\t\t\t\tend\n\n\t\t\t\t-- Ignore health checks if we are in range and los of a player or if combat movement is off\n\t\t\t\tif(context.combat_lastactiveskillrange and BehaviorManager:CurrentBTreeName() == GetString(\"AssistMode\") and context.combat_target.isplayer) then\n\t\t\t\t\t\tif(context.combat_moveintocombatrange == false or (context.combat_lastactiveskillrange >= context.combat_target.distance + context.combat_target.radius and context.combat_target.los)) then\n\t\t\t\t\t\t\t\tcontext.combat_targetcheck = nil\n\t\t\t\t\t\t\t\tself:fail()\n\t\t\t\t\t\t\t\treturn\n\t\t\t\t\t\tend\n\t\t\t\tend\n\n\t\t\t\tif(context.combat_targetcheck and context.combat_target.onmesh and context.combat_target.pathdistance < 9999999) then\n\t\t\t\t\t\tcontext.combat_targetcheck.lastTimeOnMesh = ml_global_information.Now\n\t\t\t\tend\n\n\t\t\t\tif(context.combat_targetcheck.healthresets and context.combat_targetcheck.healthresets > 20) then\n\t\t\t\t\t\td(\"[CombatHandler]: Target has reset health or healed more 20 times. Blacklisting.\")\n\t\t\t\t\t\tgw2_blacklistmanager.AddBlacklistEntry(GetString(\"Temporary Combat\"), context.combat_target.id, context.combat_target.name, 90000)\n\t\t\t\t\t\tcontext.combat_targetcheck = nil\n\t\t\t\t\t\tself:success()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\t\tend\n\t\t\n\t\tlocal checktime = 15000\n\t\tif(not context.combat_target.los) then\n\t\t\t\tchecktime = 35000\n\t\telseif(math.distance3d(context.combat_target.pos,ml_global_information.Player_Position) > ml_global_information.AttackRange) then\n\t\t\t\tchecktime = 45000\n\t\tend\n\t\t\n\t\tif(not context.combat_target.aggro) then\n\t\t\t\tchecktime = checktime + 25000\n\t\tend\n\n\t\tif(context.combat_targetid ~= context.combat_targetcheck.id or context.combat_target.contentid ~= context.combat_targetcheck.contentid) then\n\t\t\t\tcontext.combat_targetcheck = {\n\t\t\t\t\t\tid = context.combat_target.id,\n\t\t\t\t\t\tcontentid = context.combat_target.contentid,\n\t\t\t\t\t\thealth = target_health,\n\t\t\t\t\t\tlastTicks = ml_global_information.Now,\n\t\t\t\t\t\tlastTimeOnMesh = ml_global_information.Now,\n\t\t\t\t\t\tcurrenthealth = target_health,\n\t\t\t\t\t\thealthresets = 0\n\t\t\t\t}\n\t\telseif(onmeshcheck and context.combat_targetcheck.lastTimeOnMesh and TimeSince(context.combat_targetcheck.lastTimeOnMesh) > 5000) then\n\t\t\t\td(\"[CombatHandler]: Target has not been on the mesh for five seconds. Blacklisting.\")\n\t\t\t\tgw2_blacklistmanager.AddBlacklistEntry(GetString(\"Temporary Combat\"), context.combat_target.id, context.combat_target.name, 9000)\n\t\t\t\tcontext.combat_targetcheck = nil\n\t\t\t\tself:success()\n\t\t\t\treturn\n\t\telseif(TimeSince(context.combat_targetcheck.lastTicks) > checktime) then\n\t\t\t\tif (target_health >= context.combat_targetcheck.health) then\n\t\t\t\t\t\td(\"[CombatHandler]: Target not losing health. Blacklisting.\")\n\t\t\t\t\t\tgw2_blacklistmanager.AddBlacklistEntry(GetString(\"Temporary Combat\"), context.combat_target.id, context.combat_target.name, 90000)\n\t\t\t\t\t\tcontext.combat_targetcheck = nil\n\t\t\t\t\t\tself:success()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\t\t\t\tcontext.combat_targetcheck.health = target_health\n\t\t\t\tcontext.combat_targetcheck.lastTicks = ml_global_information.Now\n\t\tend\n\t\tcontext.combat_targetcheck.currenthealth = target_health\nend\nself:fail()",
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
								info = "Check target boons",
								interruptcode = "",
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
								runcode = "if( context.combat_target ) then\n\t\tif (gw2_common_functions.HasBuffs(context.combat_target,ml_global_information.InvulnerabilityConditions)) then\n\t\t\t\td(\"[CombatHandler]: Target is invulnerable. Blacklisting.\")\n\t\t\t\tgw2_blacklistmanager.AddBlacklistEntry(GetString(\"Temporary Combat\"),context.combat_target.id,context.combat_target.name,15000)\n\t\t\t\tcontext.combat_targetid = nil\n\t\t\t\tcontext.combat_target = nil\n\t\t\t\tPlayer:StopMovement()\n\t\tend\nend\nself:fail()",
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
								finishcode = "context.combat_moveintocombatrange = nil",
								info = "Handle combat",
								interruptcode = "",
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
								runcode = "if ( context.combat_targetid and context.combat_target) then\n\t\tSkillManager:SetTarget(context.combat_targetid)\n\t\tlocal activeskillrange = ml_global_information.AttackRange\n\t\tlocal combatmovement = gw2_common_functions:GetCombatMovement() \n\t\tlocal canmove = gw2_common_functions:CombatMovementCanMove()\n\t\tlocal inlos = context.combat_target.los\n\n\t\tlocal ctarget = Player:GetTarget()\n\t\tif(ctarget == nil or ctarget.id ~= context.combat_targetid) then\n\t\t\t\tPlayer:SetTarget(context.combat_targetid)\n\t\tend\n\t\t\n\t\t-- Target is off the mesh, can't move into range\n\t\tif(context.combat_targetcheck and context.combat_targetcheck.id == context.combat_targetid and context.combat_targetcheck.lastTimeOnMesh and TimeSince(context.combat_targetcheck.lastTimeOnMesh) > 200) then\n\t\t\t\td(\"[CombatHandler]: Target is off the mesh, can't move into range\")\n\t\t\t\tcanmove = false\n\t\tend\n\n\t\tif(activeskillrange < 300) then\n\t\t\t\tactiveskillrange = activeskillrange + context.combat_target.radius\n\t\tend\n\t\t\n\t\tcontext.combat_lastactiveskillrange = activeskillrange\n\n\t\tlocal rangedistance = activeskillrange\n\t\tif(activeskillrange > 300) then\n\t\t\t\trangedistance = activeskillrange / 1.2\n\t\tend\n\t\t\n\t\t-- Check if we are within skill range\n\t\tif(combatmovement and combatmovement.range and context.combat_target.distance < rangedistance and inlos) then\n\t\t\t\t\t d(\"cmb 2\") \n\t\t\t\t\tPlayer:StopMovement()\n\t\t\t\t\tcombatmovement.range = false\n\t\tend\n\t\t\n\t\tif(context.combat_moveintocombatrange and canmove) then\n\n\t\t\t\tif(combatmovement and (context.combat_target.distance > activeskillrange or (context.combat_target.distance > 154 and not inlos))) then\n\t\t\t\t\t\tcombatmovement.range = false\n\t\t\t\t\t\tgw2_unstuck.unstuck_mode = \"combat\"\n\t\t\t\t\t\tlocal tPos = context.combat_target.pos\n\n\t\t\t\t\t\tif(context.combat_target.isreachable and Player:MoveTo(tPos.x,tPos.y,tPos.z, context.combat_target.id, inlos and rangedistance or 154,false,false,true) >= 0) then\n\t\t\t\t\t\t\t\tcombatmovement.range = true\n\t\t\t\t\t\tend\n\t\t\t\tend\n\t\tend\n\t\tself:running()\n\t\treturn\nend\nself:fail()",
								startcode = "",
							},
						},
					},
					settings = 
					{
					},
					variables = 
					{
						finishcode = "",
						info = "",
						interruptcode = "",
						monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Active Child: '..tostring(self.runningTask or 'None'))",
						runcode = "",
						startcode = "",
					},
				},
			},
			settings = 
			{
			},
			variables = 
			{
				finishcode = "",
				info = "",
				interruptcode = "",
				monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Active Child: '..tostring(self.actualTask or 'None'))",
				runcode = "",
				startcode = "",
			},
		},
	},
	settings = 
	{
	},
	variables = 
	{
		filename = "CombatHandler.st",
		finishcode = "",
		info = "Handle combat\ncontext.combat_targetid\ncontext.combat_targetpos\n\nOptional (But recommended)\ncontext.combat_moveintocombatrange = true/false -- enable or disable moving into combat range (default true)\ncontext.combat_onmeshcheck = true/false -- set to false to ignore onmesh blacklisting (default true)",
		interruptcode = "",
		menucode = "",
		monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Filename: '..self.variables.filename) GUI:Text('Filepath: '..self.filepath)",
		runcode = "",
		startcode = "",
		subtreeuicode = "",
	},
}



return tbl