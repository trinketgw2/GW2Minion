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
						info = "Sell/Repair/Buy Check",
						monitorcode = "",
						runcode = "--Sell/Repair/Buy Check\n\nif Player.dead or Player.inCombat or Player.maptype == 4 or not Settings.LobbyMerchant.active then\n\t\tself:fail()\n\t\treturn\nend\n\n\nif ((gw2_sell_manager.needToSell(false) and Settings.gw2_sell_manager.active) or (Settings.gw2_buy_manager.active and (gw2_buy_manager.NeedToBuySalvageKits(false) or gw2_buy_manager.NeedToBuyGatheringTools(false))) or gw2_repair_manager.NeedToRepair(false)) then\n\td(\"[LobbyVendor]: Moving to PvP Lobby to manage our inventory.\")\n\tself:success()\n\treturn\nend\n\n\tif PvPManager:IsInPvPLobby() then\n\t\tPvPManager:LeavePvPLobby()\n\t\tml_global_information.Wait(3000,5000)\n\tend\n\t\nself:fail()",
						startcode = "",
					},
				},
				
				{
					class = "Selector",
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
								info = "Join Lobby & Repair Armor",
								monitorcode = "",
								runcode = "--Join Lobby & Repair Armor\n\n\tif not PvPManager:IsInPvPLobby() then\n\td(\"[LobbyVendor]: Joining PvP Lobby.\")\n\t\tPvPManager:JoinPvPLobby()\n\t\tml_global_information.Wait(3000,5000)\n\tend\n\n\tself:fail()",
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
										info = "getLobbyMerchant (sell)",
										monitorcode = "",
										runcode = "--getLobbyMerchant (sell)\n\nif (gw2_sell_manager.needToSell(false) and Settings.gw2_sell_manager.active) and PvPManager:IsInPvPLobby() then\n\td(\"[LobbyVendor:Sell]: Reached PvP Lobby. Looking for Merchant.\")\n\t\n\tlocal list = MapMarkerList(\"contentid=31301,onmesh\")\n\tlocal id,marker = next (list)\n\n\t\tif(table.valid(marker)) then\n\t\t\tcontext.sell_marker = marker\n\t\t\tcontext.moveto_position = context.sell_marker.pos\n\t\t\tself:success()\n\t\t\treturn\n\t\tend\n\tend\n\nself:fail()",
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
										stoppingdistance = 165,
										stoppingidstancemaxrange = 50,
										usewaypoints = false,
									},
									variables = 
									{
										filename = "MoveTo.st",
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
										info = "Sell",
										monitorcode = "",
										runcode = "--Sell\n\nif(table.valid(context.sell_marker)) then\n\n\t\tlocal marker = context.sell_marker\n\t\tif(marker.distance > 1500) then\n\t\t\t\tself:fail()\n\t\t\t\treturn\n\t\tend\n\t\t\n\t\tlocal vendor = CharacterList:Get(marker.characterid) or GadgetList:Get(marker.characterid)\n\t\t\n\t\tif(table.valid(vendor)) then\n\t\t\tif(vendor.interactable and vendor.selectable) then\n\t\t\t\tif(vendor.distance > 130 or not vendor.isininteractrange) then\n\t\t\t\t\t\t\tself:fail()\n\t\t\t\t\t\t\treturn\n\t\t\t\tend\n\t\t\t\t\n\t\t\t\tPlayer:StopMovement()\n\t\t\t\tlocal target = Player:GetTarget()\n\t\t\t\tif(target == nil or target.id ~= vendor.id) then\n\t\t\t\t\t\tPlayer:SetTarget(vendor.id)\n\t\t\t\t\t\tself:running()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\n\t\t\t\tif(gw2_sell_manager.sellAtVendor(vendor)) then\n\t\t\t\t\t\tfrenkeys_CustomTasks.SellItems()\n\t\t\t\t\t\tcontext.sell_selling = true\n\t\t\t\t\t\tself:running()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\t\t\telse\n\t\t\t\t\td(\"[LobbyVendor:Sell]: Vendor not interactable or not selectable.\")\n\t\t\t\t\tgw2_blacklistmanager.AddBlacklistEntry(GetString(\"Vendor sell\"), vendor.id, vendor.name, ml_global_information.Now + 1200000)\n\t\t\tend\n\t\telse\n\t\t\t\td(\"[LobbyVendor:Sell]: Vendor not found.\")\n\t\t\t\tgw2_blacklistmanager.AddBlacklistEntry(GetString(\"Vendor sell\"), marker.characterid, \"Vendor not found\", ml_global_information.Now + 1200000)\n\t\tend\nend\n\ncontext.sell_marker = nil\ncontext.sell_selling = false\ncontext.moveto_position = nil\nself:fail()",
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
										info = "getLobbyMerchant (buy)\n",
										monitorcode = "",
										runcode = "--getLobbyMerchant (buy)\n\nif Settings.gw2_buy_manager.active and (gw2_buy_manager.NeedToBuySalvageKits(false) or gw2_buy_manager.NeedToBuyGatheringTools(false)) and PvPManager:IsInPvPLobby() and ml_global_information.Player_Inventory_SlotsFree > 0 then\n\t\n\td(\"[LobbyVendor:Buy]: Reached PvP Lobby. Looking for Merchant.\")\n\t\n\tlocal list = MapMarkerList(\"contentid=31301,onmesh\")\n\tlocal id,marker = next (list)\n\n\t\tif(table.valid(marker)) then\n\t\t\tcontext.buy_marker = marker\n\t\t\tcontext.moveto_position = context.buy_marker.pos\n\t\t\tself:success()\n\t\t\treturn\n\t\tend\n\n\t\treturn\n\t\tend\n\nself:fail()\n",
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
										stoppingdistance = 165,
										stoppingidstancemaxrange = 50,
										usewaypoints = false,
									},
									variables = 
									{
										filename = "MoveTo.st",
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
										monitorcode = "",
										runcode = "--Buy \n\t\t\nif (not gw2_buy_manager.NeedToBuySalvageKits(true) and not gw2_buy_manager.NeedToBuyGatheringTools(true)) then \ncontext.buy_marker = nil\ncontext.moveto_position = nil\nself:success()\nreturn\nend\n\nif(table.valid(context.buy_marker)) then\n\t\tlocal marker = context.buy_marker\n\t\tif(marker.distance > 1500) then\n\t\t\tself:fail()\n\t\t\t\treturn\n\t\tend\n\n\t\tlocal vendor = CharacterList:Get(marker.characterid) or GadgetList:Get(marker.characterid)\n\t\t  \n\t\tif(table.valid(vendor)) then\n\t\t\tif(vendor.interactable and vendor.selectable) then\n\t\t\t\tif(vendor.distance > 130 or not vendor.isininteractrange) then -- or not vendor.isininteractrange) then\n\t\t\t\t\t\t\tself:fail()\n\t\t\t\t\t\t\treturn\n\t\t\t\tend\n\t\t\t\t\n\t\t\t\tPlayer:StopMovement()\n\n\t\t\t\tlocal target = Player:GetTarget()\n\t\t\t\tif(target == nil or target.id ~= vendor.id) then\n\t\t\t\t\t\tPlayer:SetTarget(vendor.id)\n\t\t\t\t\t\tself:running()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\n\t\t\t\tif (gw2_buy_manager.buyAtMerchant(vendor)) and ml_global_information.Player_Inventory_SlotsFree > 0 then\n\t\t\t\t\t\tself:running()\n\t\t\t\t\t\treturn\n\t\t\t\tend\n\t\t\telse\n\t\t\t\t\td(\"[LobbyVendor:Buy]: Vendor not interactable or not selectable.\")\n\t\t\t\t\tgw2_blacklistmanager.AddBlacklistEntry(GetString(\"Vendor buy\"), vendor.id, vendor.name, ml_global_information.Now + 1200000)\n\t\t\tend\n\t\telse\n\t\t\t\td(\"[LobbyVendor:Buy]: Vendor not found.\")\n\t\t\t\tgw2_blacklistmanager.AddBlacklistEntry(GetString(\"Vendor buy\"), marker.characterid, \"Vendor not found\", ml_global_information.Now + 1200000)\n\t\tend\nend\n\ncontext.buy_marker = nil\ncontext.moveto_position = nil\nself:fail()",
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
				monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Active Child: '..tostring(self.actualTask or 'None'))",
			},
		},
	},
	settings = 
	{
	},
	variables = 
	{
		filename = "Lobby_Vendor.st",
		finishcode = "",
		info = "requires Settings.LobbyMerchant.active = true",
		menucode = "",
		monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Filename: '..self.variables.filename) GUI:Text('Filepath: '..self.filepath)",
		runcode = "",
		startcode = "",
		subtreeuicode = "",
	},
}



return tbl
