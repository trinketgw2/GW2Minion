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
						info = "Check for gather tools",
						monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
						runcode = "if(self.lasttoolcheck == nil or TimeSince(self.lasttoolcheck) > 10000) then\t\t\n\t\tself.lasttoolcheck = ml_global_information.Now\n\t\tlocal fTool = table.valid(Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.ForagingTool))\n\t\tlocal lTool = table.valid(Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.LoggingTool))\n\t\tlocal mTool = table.valid(Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MiningTool))\n\t\tif(not fTool or not lTool or not mTool) then\n\t\t\t\tself.lasttoolcheckfailed = true\n\t\t\t\td(\"[Gather]: One or more gather tools not equipped!\")\n\t\t\t\td(string.format(\"[Gather]: ftool=%s, ltool=%s, mtool=%s\", tostring(fTool), tostring(lTool), tostring(mTool)))\n\t\telse\n\t\t\t\tself.lasttoolcheckfailed = false\n\t\tend\nend\n\nif(self.lasttoolcheckfailed) then\n\t\tself:fail()\nelse\n\t\tself:success()\nend",
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
						info = "Find gatherable",
						monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
						runcode = "if (ml_global_information.Player_Inventory_SlotsFree < 2 ) then \n\t\tself:fail()\n\t\treturn\nend\nif(context.gather_targetid) then\n\t\tself:success()\n\t\treturn\nelseif(context.gather_targetid == nil) then\n\t\tlocal filter = \"shortestpath,onmesh,gatherable,interactable,selectable\"\n\t\t\n\t\tif(context.gather_maxdistance) then\n\t\t\t\tfilter = filter .. \",maxdistance=\"..context.gather_maxdistance\n\t\tend\n\t\t\n\t\tlocal GList = GadgetList(filter)\n\n\t\tif(table.valid(GList)) then\n\t\t\t\tlocal _,gatherable = next(GList)\n\t\t\t\tif(table.valid(gatherable) and gatherable.pathdistance < 999999) then\n\t\t\t\t\t\td(\"[Gather]: New gatherable found\")\n\t\t\t\t\t\tcontext.gather_targetid = gatherable.id\n\t\t\t\t\t\tcontext.gather_position = gatherable.pos\n\t\t\t\t\t\tself:success()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\t\tend\nend\nself:fail()\n\n",
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
								info = "Gather",
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
								runcode = "if(context.gather_targetid and ml_global_information.Player_Inventory_SlotsFree >= 2) then\n\t\tlocal dist = math.distance3d(ml_global_information.Player_Position,context.gather_position)\n\t\tif(dist < 1500) then\n\t\t\t\tlocal target = GadgetList:Get(context.gather_targetid)\n\t\t\n\t\t\t\tif(target and target.gatherable and target.interactable and target.selectable) then\n\n\t\t\t\t\t\tif( dist < 300 and Player.mounted) then \n\t\t\t\t\t\t\t\tPlayer:Dismount() \n\t\t\t\t\t\tend\n\n\t\t\t\t\t\tif(target.isininteractrange and dist < 130) then\n\t\t\t\t\t\t\t\tlocal pTarget = Player:GetTarget()\n\t\t\t\t\t\t\t\tif(not pTarget or pTarget.id ~= target.id) then\n\t\t\t\t\t\t\t\t\t\tPlayer:SetTarget(target.id)\t\t\t\n\t\t\t\t\t\t\t\tend\n\n\t\t\t\t\t\t\t\tgw2_common_functions.NecroLeaveDeathshroud()\n\t\t\t\t\t\t\t\t\n\t\t\t\t\t\t\t\tif(ml_global_information.Player_IsMoving) then\n\t\t\t\t\t\t\t\t\t\tPlayer:StopMovement()\n\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\n\t\t\t\t\t\t\t\t-- Check if in water and prevent stuck.\n\t\t\t\t\t\t\t\tif (ml_global_information.Player_SwimState == GW2.SWIMSTATE.Swimming) then\n\t\t\t\t\t\t\t\t\t\tPlayer:SetMovement(3)\n\t\t\t\t\t\t\t\t\t\tPlayer:SetFacingExact(target.pos.x,target.pos.y,target.pos.z)\n\t\t\t\t\t\t\t\t\t\tself.circling = true\n\t\t\t\t\t\t\t\telseif (self.circling == true) then\n\t\t\t\t\t\t\t\t\t\tPlayer:UnSetMovement(3)\n\t\t\t\t\t\t\t\t\t\tself.circling = false\n\t\t\t\t\t\t\t\tend\n\n\t\t\t\t\t\t\t\tPlayer:SetFacing(target.pos.x,target.pos.y,target.pos.z)\n\t\t\t\t\t\t\t\tif ( Player:GetCurrentlyCastedSpell() == ml_global_information.MAX_SKILLBAR_SLOTS ) then\n\t\t\t\t\t\t\t\t\t\tPlayer:Interact(target.id)\n\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\t\t\tself:running()\n\t\t\t\t\t\t\t\treturn\n\t\t\t\t\t\tend\n\n\t\t\t\telse\n\t\t\t\t\t\td(\"[Gather]: Node is gathered or missing.\")\n\t\t\t\t\t\tcontext.gather_targetid = nil\n\t\t\t\t\t\tself:success()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\t\tend\nend \n\nself:fail()",
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
										runcode = "if(context.gather_targetid) then\n\t\tcontext.moveto_position = context.gather_position\n\t\tself:success()\nelse\n\t\tself:fail()\nend",
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
		filename = "Gather.st",
		finishcode = "context.gather_targetid = nil\ncontext.gather_position = nil",
		info = "Gather",
		menucode = "",
		monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Filename: '..self.variables.filename) GUI:Text('Filepath: '..self.filepath)\nif(context and context.gather_targetid and context.gather_position) then\n\t\tGUI:Text(\"Distance to gatherable: \" .. math.ceil(math.distance3d(ml_global_information.Player_Position,context.gather_position)))\nend",
		runcode = "",
		startcode = "",
		subtreeuicode = "",
	},
}



return tbl