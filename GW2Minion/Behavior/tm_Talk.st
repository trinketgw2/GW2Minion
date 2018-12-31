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
						monitorcode = "",
						runcode = "context.talksteps_blacklist = context.talksteps_blacklist or {}\n\nif(not table.valid(context.talksteps) or not table.valid(context.talkagent)) then\n\t\t\t\tcontext.talktarget = nil\n\t\t\t\tcontext.talkagent = nil\nend\n\nif(Player.castinfo.skillid ~= 0) then\n\t\td(\"[Talk]: Channeling?\")\n\t\tself:running()\n\t\treturn\nend\n\nif(table.size(context.talksteps_blacklist) >= table.size(context.talksteps)) then\n\t\t\t\tcontext.talktarget = nil\n\t\t\t\tcontext.talkagent = nil\nend\n\nself:fail()",
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
								runcode = "context.talkagent_blacklist = context.talkagent_blacklist or {}\n\nif(table.valid(context.talkagent) and context.talkagent.contentid and context.talkagent.contentid > 0) then\n\t\tlocal TList = gw2_common_functions.GetAllTargets(\"maxdistance=2000,interactable,contentid=\"..context.talkagent.contentid)\n\t\t\n\t\tif(table.valid(TList)) then\n\t\t\t\tlocal nearest = nil\n\t\t\t\tfor _,target in pairs(TList) do\n\t\t\t\t\t\tif(not context.talkagent_blacklist[target.id] and (target.isininteractrange or (target.meshpos and target.meshpos.meshdistance < 200))) then\n\t\t\t\t\t\t\t\tif(nearest == nil or nearest.pathdistance > target.pathdistance) then\n\t\t\t\t\t\t\t\t\t\tnearest = target\n\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\tend\n\t\t\t\tend\n\n\t\t\t\tif(table.valid(nearest)) then\n\t\t\t\t\t\tcontext.talktarget = nearest.id\n\t\t\t\t\t\tself:success()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\t\tend\nend\ncontext.talktarget = nil\nself:fail()\n",
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
										runcode = "context.talksteps_blacklist = context.talksteps_blacklist or {}\n\ncontext.talk_interactcount = context.talk_interactcount or {}\n\nif(context.talktarget) then\n\t\tif(not context.talk_interactcount or not context.talk_interactcount[context.talktarget]) then\n\t\t\tcontext.talk_interactcount = {}\n\t\t\tcontext.talk_interactcount[context.talktarget] = 0\n\t\tend\n\t\t\n\t\tlocal talktarget = CharacterList:Get(context.talktarget) or GadgetList:Get(context.talktarget)\n\t\tif(table.valid(talktarget) and talktarget.interactable) then\n\t\t\t\tlocal pos = talktarget.pos\n\t\t\t\t-- What is this? It does not walk to the meshpos, but closest point on mesh.\n\t\t\t\t-- Making the meshdistance check useless on big stuff.\n\t\t\t\t-- Fixed check to find nearest in last action to counter. Keep eye out for bugs.\n\t\t\t\tlocal usingmeshpos = false\n\t\t\t\tif(talktarget.pathdistance >= 9999999) then\n\t\t\t\t\t\tlocal meshpos = talktarget.meshpos\n\t\t\t\t\t\tif(table.valid(meshpos) and meshpos.meshdistance < 200) then\n\t\t\t\t\t\t\t\tlocal meshpath = NavigationManager:GetPath(ml_global_information.Player_Position.x,ml_global_information.Player_Position.y,ml_global_information.Player_Position.z,meshpos.x,meshpos.y,meshpos.z)\n\t\t\t\t\t\t\t\tif(table.valid(meshpath)) then\n\t\t\t\t\t\t\t\t\t\tpos = meshpos\n\t\t\t\t\t\t\t\t\t\tusingmeshpos = true\n\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\tend\n\t\t\t\tend\n\n\t\t\t\tlocal r = talktarget.radius > 50 and talktarget.radius or 110\n\t\t\t\tif(table.valid(pos)) then\n\t\t\t\t\t\tif(math.distance3d(pos,ml_global_information.Player_Position) > (usingmeshpos and 50 or r)) then\n\t\t\t\t\t\t\t\tcontext.moveto_position = pos\n\t\t\t\t\t\t\t\tself:fail()\n\t\t\t\t\t\t\t\treturn\n\t\t\t\t\t\tend\n\n\t\t\t\t\t\tif(not talktarget.isininteractrange and talktarget.isgadget) then\n\t\t\t\t\t\t\t\tlocal GList = GadgetList(\"interactable\")\n\t\t\t\t\t\t\t\tif(table.valid(GList)) then\n\t\t\t\t\t\t\t\t\t\tfor _,interactable in pairs(GList) do\n\t\t\t\t\t\t\t\t\t\t\t\tif(context.talktarget ~= interactable.id and interactable.isininteractrange and talktarget.isunknown6 == interactable.isunknown6) then\n\t\t\t\t\t\t\t\t\t\t\t\t\t\td(\"[Talk]: We are at the target position, but not in interact range. We found a similar gadget. Trying that instead.\")\n\t\t\t\t\t\t\t\t\t\t\t\t\t\ttalktarget = interactable\n\t\t\t\t\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\tend\n\n\t\t\t\t\t\tif(not talktarget.isininteractrange) then\n\t\t\t\t\t\t\t\td(\"[Talk]: We are at the target position, but not in interact range. Canceling.\")\n\t\t\t\t\t\t\t\tcontext.talkagent_blacklist[context.talktarget] = true\n\t\t\t\t\t\t\t\tself:success()\n\t\t\t\t\t\t\t\treturn\n\t\t\t\t\t\tend\n\t\t\t\t\t\t\n\t\t\t\t\t\tif(context.talk_interactcount[talktarget.id] and context.talk_interactcount[talktarget.id] > 10) then\n\t\t\t\t\t\t\t\td(\"[Talk]: We have tried to talk to this object more then 10 times. Canceling.\")\n\t\t\t\t\t\t\t\tcontext.talkagent_blacklist[context.talktarget] = true\n\t\t\t\t\t\t\t\tself:success()\n\t\t\t\t\t\t\t\treturn\t\t\t\t\t\t\t\n\t\t\t\t\t\tend\n\t\t\t\t\t\t\n\t\t\t\t\t\tPlayer:StopMovement()\n\n\t\t\t\t\t\tif(talktarget.selectable) then\n\t\t\t\t\t\t\t\tlocal pTarget = Player:GetTarget()\n\t\t\t\t\t\t\t\tif(pTarget == nil or pTarget.id ~= talktarget.id) then\n\t\t\t\t\t\t\t\t\t\tPlayer:SetTarget(talktarget.id)\n\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\tend\n\t\t\t\t\t\t\n\t\t\t\t\t\tPlayer:SetFacing(talktarget.pos.x,talktarget.pos.y,talktarget.pos.z)\n\t\t\t\t\t\t\n\t\t\t\t\t\tlocal dialogOpen = Player:IsConversationOpen()\n\t\t\t\t\t\tif(not dialogOpen or talktarget.dead) then\n\t\t\t\t\t\t\t\tPlayer:Interact(talktarget.id)\n\t\t\t\t\t\t\t\tcontext.talk_interactcount[talktarget.id] = context.talk_interactcount[talktarget.id] + 1\n\t\t\t\t\t\t\t\tml_global_information.Wait(750,1450)\n\t\t\t\t\t\t\t\tself:running()\n\t\t\t\t\t\t\t\treturn\n\t\t\t\t\t\tend\n\t\t\t\t\t\t\n\t\t\t\t\t\tif(dialogOpen) then\n\t\t\t\t\t\t\t\tfor i,step in ipairs(context.talksteps) do\n\t\t\t\t\t\t\t\t\t\tif(not context.talksteps_blacklist[i]) then\n\t\t\t\t\t\t\t\t\t\t\t\tif(context.talktype == \"Index\") then\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tPlayer:SelectConversationOptionByIndex(step)\n\t\t\t\t\t\t\t\t\t\t\t\telse\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tPlayer:SelectConversationOption(step)\n\t\t\t\t\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\t\t\t\t\t\t\tml_global_information.Wait(750,1600)\n\t\t\t\t\t\t\t\t\t\t\t\tcontext.talksteps_blacklist[i] = true\n\t\t\t\t\t\t\t\t\t\t\t\tself:running()\n\t\t\t\t\t\t\t\t\t\t\t\treturn\n\t\t\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\t\t\tend\n\t\t\t\t\t\tend\n\t\t\t\tend\n\t\tend\n\t\tcontext.talkagent_blacklist[context.talktarget] = true\nend\ncontext.talktarget = nil\ncontext.talksteps_blacklist = nil\nself:fail()",
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
												runcode = "if(context.talktarget and table.valid(context.moveto_position)) then\n\t\tself:success()\nelse\n\t\tself:fail()\nend",
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
				monitorcode = "",
			},
		},
	},
	settings = 
	{
	},
	variables = 
	{
		filename = "tm_Talk.st",
		finishcode = "",
		info = "Talk",
		menucode = "",
		monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Filename: '..self.variables.filename) GUI:Text('Filepath: '..self.filepath)",
		runcode = "",
		startcode = "context.talktype = self.settings.talktype\ncontext.talksteps = self.settings.talksteps\ncontext.talkagent = self.settings.talkagent",
		subtreeuicode = "self.settings.talktype = self.settings.talktype or \"Index\"\nself.settings.talksteps = self.settings.talksteps or {}\nself.settings.talkagent = self.settings.talkagent or {contentid = 0; name = \"\"; character = false; gadget = false;}\n\nlocal talktypes = {\"Index\", \"Type\"}\nlocal selectedtype = 1\nfor i,type in pairs(talktypes) do\n\t\tif(self.settings.talktype == type) then\n\t\t\t\tselectedtype = i\n\t\t\t\tbreak\n\t\tend\nend\n\n\nlocal target = Player:GetTarget()\nif(table.valid(target) and (not target.onmesh or target.pathdistance > 99999)) then\n\t\tGUI:Text(\"Target not on mesh or no valid path found\")\nend\n\nself.settings.talkagent.contentid = GUI:InputInt(\"Content ID##tmtalk\", self.settings.talkagent.contentid, 0)\n\nif(GUI:Button(\"Update target##tmtalk\")) then\n\t\tif(table.valid(target) and target.interactable and (target.ischaracter or target.isgadget)) then\n\t\t\t\tself.settings.talkagent = {contentid = target.contentid; name = target.name; character = target.ischaracter; gadget = target.isgadget}\n\t\telse\n\t\t\t\td(\"No valid interactable target selected.\")\n\t\tend\nend\n\nlocal index, changed = GUI:Combo(\"Talk type##tmtalk\", selectedtype, talktypes)\nif(changed) then\n\t\tself.settings.talktype = talktypes[index]\nend\n\nif(self.settings.talktype == \"Index\") then\n\t\tGUI:Text(\"Talk indexes:\")\nelse\n\t\tGUI:Text(\"Talk types:\")\nend\n\nfor i,step in ipairs(self.settings.talksteps) do\n\t\tself.settings.talksteps[i] = GUI:InputInt(\"##tmtalk\"..i, step)\n\t\tGUI:SameLine()\n\t\tif(GUI:Button(\"Delete step##tmtalk\"..i)) then\n\t\t\t\ttable.remove(self.settings.talksteps, i)\n\t\tend\nend\n\nif(GUI:Button(\"Add talk step\")) then\n\t\ttable.insert(self.settings.talksteps, 0)\nend \n",
	},
}



return tbl