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
						info = "Select vendor",
						monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
						runcode = "if(Settings.gw2_buy_manager.active and (gw2_buy_manager.NeedToBuySalvageKits(context.buy_nearby) or gw2_buy_manager.NeedToBuyGatheringTools(context.buy_nearby))) then\n\t\tlocal marker = gw2_buy_manager.getClosestBuyMarker(context.buy_nearby)\n\t\tif(table.valid(marker)) then\n\t\t\t\tcontext.buy_marker_characterid = marker.characterid\n\t\t\t\tself:success()\n\t\t\t\treturn\n\t\tend\nend  \ncontext.buy_marker_characterid = nil\nself:fail()",
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
								info = "Check buy status",
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
								runcode = "if(context.buy_marker_characterid) then\n\t\tif(gw2_blacklistmanager.CheckBlacklistEntry(GetString(\"Vendor buy\"),context.buy_marker_characterid)) then\n\t\t\t\td(\"[Buy]: Vendor blacklisted\")\n\t\t\t\tcontext.buy_marker_characterid = nil\n\t\tend\nend\n\nif(not gw2_buy_manager.NeedToBuySalvageKits(context.buy_nearby) and not gw2_buy_manager.NeedToBuyGatheringTools(context.buy_nearby)) then\n\t\tcontext.buy_marker_characterid = nil\nend\n\nself:fail()",
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
								info = "Set up marker",
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
								runcode = "context.buy_marker = nil\nif(context.buy_marker_characterid) then\n\t\tlocal MList = MapMarkerList(\"onmesh,agentID=\"..context.buy_marker_characterid)\n\t\tif(table.valid(MList)) then\n\t\t\t\tlocal _,marker = next(MList)\n\t\t\t\tif(table.valid(marker)) then\n\t\t\t\t\t\tcontext.buy_marker = marker\n\t\t\t\t\t\tself:fail()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\t\tend\n\n\t\tif(not table.valid(context.buy_marker)) then\n\t\t\t\td(\"[Buy]: Vendor missing or not on mesh\")\n\t\t\t\tgw2_blacklistmanager.AddBlacklistEntry(GetString(\"Vendor buy\"), context.buy_marker_characterid, \"Missing vendor\", ml_global_information.Now + 50000)\n\t\tend\nend\ncontext.buy_marker_characterid = nil\nself:fail()",
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
								info = "Buy",
								monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
								runcode = "if(table.valid(context.buy_marker)) then\n\t\tlocal marker = context.buy_marker\n\t\tif(marker.distance > 1500) then\n\t\t\t\tself:fail()\n\t\t\t\treturn\n\t\tend\n\t\t\n\t\tlocal vendor = CharacterList:Get(marker.characterid) or GadgetList:Get(marker.characterid)\n\t\t  \n\t\tif(table.valid(vendor)) then\n\t\t\tif(vendor.interactable and vendor.selectable) then\n\t\t\t\tif(vendor.distance > 130 or not vendor.isininteractrange) then\n\t\t\t\t\t\t\tself:fail()\n\t\t\t\t\t\t\treturn\n\t\t\t\tend\n\t\t\t\t\n\t\t\t\tPlayer:StopMovement()\n\n\t\t\t\tlocal target = Player:GetTarget()\n\t\t\t\tif(target == nil or target.id ~= vendor.id) then\n\t\t\t\t\t\tPlayer:SetTarget(vendor.id)\n\t\t\t\t\t\tself:running()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\n\t\t\t\tif(gw2_buy_manager.buyAtMerchant(vendor)) then\n\t\t\t\t\t\tself:running()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\t\t\telse\n\t\t\t\t\td(\"[Buy]: Vendor not interactable or not selectable.\")\n\t\t\t\t\tgw2_blacklistmanager.AddBlacklistEntry(GetString(\"Vendor buy\"), vendor.id, vendor.name, ml_global_information.Now + 1200000)\n\t\t\tend\n\t\telse\n\t\t\t\td(\"[Buy]: Vendor not found.\")\n\t\t\t\tgw2_blacklistmanager.AddBlacklistEntry(GetString(\"Vendor buy\"), marker.characterid, \"Vendor not found\", ml_global_information.Now + 1200000)\n\t\tend\nend\ncontext.buy_marker = nil\nself:fail()",
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
										info = "Move to buy marker",
										monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))",
										runcode = "if(table.valid(context.buy_marker)) then\n\t\tcontext.moveto_position = context.buy_marker.pos\n\t\tself:success()\nelse\n\t\tself:fail()\nend",
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
										usewaypoints = true,
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
								info = "Move to buy marker",
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
		filename = "Buy.st",
		finishcode = "",
		info = "Buy\nOptional parameter:\ncontext.buy_nearby = true/false",
		menucode = "",
		monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Filename: '..self.variables.filename) GUI:Text('Filepath: '..self.filepath)",
		runcode = "",
		startcode = "",
		subtreeuicode = "",
	},
}



return tbl