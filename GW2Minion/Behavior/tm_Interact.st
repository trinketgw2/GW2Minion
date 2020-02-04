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
						runcode = "if(context.tm_interact_targetid) then\n\t\tif(Player.castinfo.skillid ~= 0) then\n\t\t\t\td(\"[tm_Interact]: Waiting.\")\n\t\t\t\tself:running()\n\t\t\t\treturn\n\t\tend\nend\nself:success()",
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
						info = "Set up interact target",
						monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
						runcode = "if(context.tm_interact_targetid) and table.valid(context.tm_interact_targetinfo) then\n\t\tif(context.tm_interact_targetinfo.closedialog and Player:IsConversationOpen()) then\n\t\t\t\tlocal clist_n = table.size(Player:GetConversationOptions())\n\t\t\t\t\t\tPlayer:SelectConversationOptionByIndex(clist_n)\n\t\tend\n\n\t\tif(context.tm_interact_blacklist[context.tm_interact_targetid]) then\n\t\t\t\tcontext.tm_interact_targetid = nil\n\t\t\t\tcontext.tm_interact_targetpos = nil\n\t\t\t\tcontext.tm_interact_targetinfo = nil\n\t\t\t\tPlayer:StopMovement()\n\t\t\t\tself:running()\n\t\t\t\treturn\n\t\telse\n\t\t\t\tself:success()\n\t\t\t\treturn \n\t\tend\n\t\nelseif(table.valid(context.tm_interact_targets)) then\n\t\tlocal mergedList = gw2_common_functions.GetAllTargets(\"interactable,onmesh\")\n\t\tlocal validtargets = {}\n\n\t\tif(table.valid(mergedList)) then\n\t\t\t\tfor _,target in pairs(mergedList) do\n\t\t\t\t\t\tfor _,targetinfo in ipairs(context.tm_interact_targets) do\n\t\t\t\t\t\t\t\tif(target.contentid == targetinfo.contentid and type(targetinfo.maxinteract) == \"number\" and context.tm_interact_interactcount[target.contentid]) then\n\t\t\t\t\t\t\t\t\t\tif(context.tm_interact_interactcount[target.contentid] >= targetinfo.maxinteract) then\n\t\t\t\t\t\t\t\t\t\t\t\tcontext.tm_interact_blacklist[target.id] = true\n\t\t\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\t\t\tend\n\n\t\t\t\t\t\t\t\tif(not context.tm_interact_blacklist[target.id] and target.contentid == targetinfo.contentid and target.pathdistance < 99999) then\n\t\t\t\t\t\t\t\t\t\ttable.insert(validtargets, target)\n\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\tend\n\t\t\t\tend\n\t\tend\n\n\t\tlocal nearest = nil\n\t\tif(table.valid(validtargets)) then\n\t\t\t\ttable.sort(validtargets, function(a,b) return a.pathdistance < b.pathdistance end)\n\n\t\t\t\tnearest = select(2, next(validtargets))\n\t\tend\n\t\t\n\t\tcontext.tm_interact_targetid = nil\n\t\tcontext.tm_interact_targetinfo = nil\n\t\tif(table.valid(nearest)) then\n\t\t\t\tcontext.tm_interact_targetid = nearest.id\n\t\t\t\tcontext.tm_interact_targetpos = nearest.pos\n\n\t\t\t\tif(not context.tm_interact_interactcount[nearest.contentid]) then\n\t\t\t\t\t\tcontext.tm_interact_interactcount[nearest.contentid] = 0\n\t\t\t\tend\n\n\t\t\t\tfor _,interacttarget in pairs(context.tm_interact_targets) do\n\t\t\t\t\t\tif(nearest.contentid == interacttarget.contentid) then\n\t\t\t\t\t\t\t\tcontext.tm_interact_targetinfo = interacttarget\n\t\t\t\t\t\tend\n\t\t\t\tend\n\t\tend\n\n\t\tif(context.tm_interact_targetid and context.tm_interact_targetinfo) then\n\t\t\t\tself:success()\n\t\t\t\treturn\n\t\tend\nend\nself:fail()",
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
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
								runcode = "if(context.tm_interact_targetid and not context.tm_interact_blacklist[context.tm_interact_targetid]) then\n\t\tlocal dist = math.distance3d(context.tm_interact_targetpos,ml_global_information.Player_Position)\n\t\tif(dist > 1000) then\n\t\t\t\tcontext.moveto_position = context.tm_interact_targetpos\n\t\t\t\tself:fail()\n\t\t\t\treturn\n\t\tend\n\t\t\n\t\tif(context.tm_interact_interacting) then\n\t\t\t\tif(TimeSince(context.tm_interact_interacting) > 15000) then\n\t\t\t\t\t\td(\"[tm_Interact]: This is taking too long. Blacklisting.\")\n\t\t\t\t\t\tcontext.tm_interact_blacklist[context.tm_interact_targetid] = true\n\t\t\t\t\t\tcontext.tm_interact_targetid = nil\t\t\t\n\t\t\t\telseif(Player.castinfo.skillid == 0) then\n\t\t\t\t\t\td(\"[tm_Interact]: Ended.\")\n\t\t\t\t\t\tif(context.tm_interact_targetinfo.oncepertarget ~= false) then\n\t\t\t\t\t\t\t\tcontext.tm_interact_blacklist[context.tm_interact_targetid] = true\n\t\t\t\t\t\tend\n\n\t\t\t\t\t\tif(context.tm_interact_targetinfo.closedialog and Player:IsConversationOpen()) then\n\t\t\t\t\t\t\t\tlocal clist_n = table.size(Player:GetConversationOptions())\n\t\t\t\t\t\t\t\tif(clist_n > 0) then\n\t\t\t\t\t\t\t\t\t\tPlayer:SelectConversationOptionByIndex(clist_n-1)\n\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\tend\n\n\t\t\t\t\t\tcontext.tm_interact_targetid = nil\n\t\t\t\telse\n\t\t\t\t\t\td(\"[tm_Interact]: Waiting...\")\n\t\t\t\t\t\tself:running()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\t\tend\n\t\t\n\t\tif(context.tm_interact_targetid) then\n\t\t\t\tlocal target = CharacterList:Get(context.tm_interact_targetid) or GadgetList:Get(context.tm_interact_targetid)\n\t\t\t\tif(table.valid(target) and target.interactable) then\n\t\t\t\t\t\tif(not target.isininteractrange) then\n\t\t\t\t\t\t\t\tcontext.moveto_position = target.pos\n\t\t\t\t\t\t\t\tself:fail()\n\t\t\t\t\t\t\t\treturn\n\t\t\t\t\t\telse\n\t\t\t\t\t\t\t\tPlayer:StopMovement()\n\t\t\t\t\t\t\t\tlocal pTarget = Player:GetTarget()\n\t\t\t\t\t\t\t\tif(target.selectable and (pTarget == nil or pTarget.id ~= target.id)) then\n\t\t\t\t\t\t\t\t\t\tPlayer:SetTarget(target.id)\n\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\t\t\tPlayer:SetFacing(target.pos.x,target.pos.y,target.pos.z)\n\t\t\t\t\t\t\t\tPlayer:Interact(target.id)\n\t\t\t\t\t\t\t\tcontext.tm_interact_interacting = ml_global_information.Now\n\t\t\t\t\t\t\t\tcontext.tm_interact_interactcount[target.contentid] = context.tm_interact_interactcount[target.contentid] + 1\n\t\t\t\t\t\t\t\td(\"[tm_Interact]: Interacting.\")\n\t\t\t\t\t\t\t\tml_global_information.Wait(math.random(750,1300))\n\t\t\t\t\t\t\t\tself:running()\n\t\t\t\t\t\t\t\treturn\n\t\t\t\t\t\tend\n\t\t\t\telse\n\t\t\t\t\td(\"[tm_Interact]: Target missing or not interactable.\")\n\t\t\t\t\tcontext.tm_interact_blacklist[context.tm_interact_targetid] = true\n\t\t\t\tend\n\t\tend\nend\ncontext.tm_interact_targetinfo = nil\ncontext.tm_interact_interacting = nil\ncontext.moveto_position = nil\ncontext.moveto_targetid = nil\nself:success()",
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
										runcode = "if(table.valid(context.moveto_position)) then\n\t\tself:success()\nelse\n\t\tself:fail()\nend",
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
										stoppingdistance = 110,
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
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Active Child: '..tostring(self.actualTask or 'None'))",
							},
						},
					},
					settings = 
					{
					},
					variables = 
					{
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
		filename = "tm_Interact.st",
		finishcode = "context.tm_interact_interacting = nil\ncontext.tm_interact_targetid = nil\ncontext.tm_interact_targetpos = nil\n\nif(context.tm_interact_targetinfo and context.tm_interact_targetinfo.closedialog and Player:IsConversationOpen()) then\n\t\tlocal clist_n = table.size(Player:GetConversationOptions())\n\t\tif(clist_n > 0) then\n\t\t\t\tPlayer:SelectConversationOptionByIndex(clist_n-1)\n\t\tend\nend",
		info = "",
		menucode = "",
		monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Filename: '..self.variables.filename) GUI:Text('Filepath: '..self.filepath)",
		runcode = "context.tm_interact_targets = self.settings.targets\ncontext.tm_interact_blacklist = context.tm_interact_blacklist or {}",
		startcode = "context.tm_interact_interactcount = context.tm_interact_interactcount or {}",
		subtreeuicode = "local targets = self.settings.targets or {}\nlocal changed = false\nif(table.valid(targets)) then\n\t\tGUI:Separator()\n\t\tGUI:Columns(4)\n\t\tGUI:Text(GetString(\"Name\")) GUI:NextColumn()\n\t\tGUI:Text(GetString(\"ContentID\")) GUI:NextColumn()\n\t\tGUI:Text(GetString(\"Options\")) GUI:NextColumn() GUI:NextColumn()\n\t\tfor i,target in ipairs(targets) do\n\t\t\t\tGUI:Separator()\n\n\t\t\t\tGUI:Text(string.valid(target.name) and target.name or \"unknown\") GUI:NextColumn()\n\t\t\t\tGUI:Text(target.contentid) GUI:NextColumn()\n\t\t\t\t\n\t\t\t\tlocal maxinteract = GUI:InputInt(GetString(\"Max interact\")..\"##\"..i, target.maxinteract or 1, 0)\n\t\t\t\tif(maxinteract <= 0) then maxinteract = 1 end\n\n\t\t\t\tlocal oncepertarget = GUI:Checkbox(GetString(\"Once per target\")..\"##\"..i, target.oncepertarget or false)\n\t\t\t\tlocal closedialog = GUI:Checkbox(GetString(\"Close dialog\")..\"##\"..i, target.closedialog or false)\n\n\t\t\t\tif(maxinteract ~= target.maxinteract) then\n\t\t\t\t\t\ttarget.maxinteract = maxinteract\n\t\t\t\t\t\tchanged = true\n\t\t\t\tend\n\t\t\t\tif(oncepertarget ~= target.oncepertarget) then\n\t\t\t\t\t\ttarget.oncepertarget = oncepertarget\n\t\t\t\t\t\tchanged = true\n\t\t\t\tend\n\t\t\t\tif(closedialog ~= target.closedialog) then\n\t\t\t\t\t\ttarget.closedialog = closedialog\n\t\t\t\t\t\tchanged = true\n\t\t\t\tend\n\t\t\t\tGUI:NextColumn()\n\t\t\t\tif(GUI:Button(\"Delete##tminteract\"..i)) then\n\t\t\t\t\t\ttable.remove(targets, i)\n\t\t\t\t\t\tchanged = true\n\t\t\t\tend\n\t\t\t\tGUI:NextColumn()\n\t\t\t\t\n\t\tend\n\t\tGUI:Columns(1)\n\t\tGUI:Separator()\nend\nlocal target_inList = false\nlocal target = Player:GetTarget()\nif(table.valid(target)) then\n\t\tif(not target.onmesh or target.pathdistance > 99999) then\n\t\t\t\tGUI:Text(\"Target not on mesh or no valid path found\")\n\t\telseif(not target.interactable) then\n\t\t\t\tGUI:Text(\"Target not interactable\")\n\t\t\t\ttarget = nil\n\t\telseif(not target.ischaracter and not target.isgadget and not target.isentity) then\n\t\t\t\tGUI:Text(\"Target is not a character or gadget\")\n\t\telseif(target.contentid == 17513) then\n\t\t\t\tGUI:Text(\"THIS IS NOT A VALID TARGET\")\n\t\t\t\ttarget = nil\n\t\tend\n\t\t\n\t\tif table.valid(target) and target.contentid then\n\t\t\t\tfor _,interacttarget in pairs(targets) do\n\t\t\t\t\t\tif(target.contentid == interacttarget.contentid) then\n\t\t\t\t\t\t\t\tGUI:Text(\"Target already in list\")\n\t\t\t\t\t\t\t\ttarget_inList = true\n\t\t\t\t\t\t\t\ttarget = nil\n\t\t\t\t\t\t\t\tbreak\n\t\t\t\t\t\tend\n\t\t\t\tend\n\t\tend\nend\n\nif(table.valid(target)) then\n\t\tif(GUI:Button(\"Add target##tminteract\")) then\n\t\t\t\tif((target.ischaracter or target.isgadget or target.isentity) and target.interactable) then\n\t\t\t\t\t\ttable.insert(targets, {contentid = target.contentid, name = target.name, character = target.ischaracter, gadget = target.isgadget, entity = target.isentity})\n\t\t\t\t\t\tchanged = true\n\t\t\t\telse\n\t\t\t\t\t\td(\"[tm_Interact]: No target selected or target not interactable\")\n\t\t\t\tend\n\t\tend\nelseif not target_inList then\n\t\t\t\tGUI:Text(GetString(\"No target selected\"))\nend\nif(changed) then\n\t\tself.settings.targets = targets\nend",
	},
}



return tbl
