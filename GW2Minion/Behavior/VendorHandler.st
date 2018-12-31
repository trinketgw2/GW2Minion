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
						monitorcode = "GUI:Text('Last State: '..tostring(self:getState()))\nlocal vendorcheck = 0\nif(self.vendorcheck) then\n\t\tlocal remaining = 5000-TimeSince(self.vendorcheck)\n\t\tif(remaining > 0) then\n\t\t\t\tvendorcheck = math.ceil(remaining/1000)\n\t\tend\nend\nGUI:Text(\"Next vendor check: \"..vendorcheck..\"s\")\n",
						runcode = "if(context.buy_marker or context.sell_marker or context.repair_marker) then\n\t\tself:success()\n\t\treturn\nend\n\nif(self.vendorcheck == nil or TimeSince(self.vendorcheck) > 5000) then\n\t\tself.vendorcheck = ml_global_information.Now\n\t\tself:success()\n\t\treturn\nend\n\nself:fail()",
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
						runcode = "if(Settings.gw2_sell_manager.active) then\n\t\tcontext.sell_nearby = gw2_sell_manager.needToSell(true) and table.valid(gw2_sell_manager.getClosestSellMarker(true))\nend\n\ncontext.repair_nearby = gw2_repair_manager.NeedToRepair(true) and table.valid(gw2_repair_manager.getClosestRepairMarker(true))\n\nif(Settings.gw2_buy_manager.active) then\n\t\tcontext.buy_nearby = (gw2_buy_manager.NeedToBuySalvageKits(true) or gw2_buy_manager.NeedToBuyGatheringTools(true)) and table.valid(gw2_buy_manager.getClosestBuyMarker(true))\nend\n\nself:success()",
						startcode = "",
					},
				},
				
				{
					class = "Selector",
					nodes = 
					{
						
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
								filename = "Repair.st",
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
								filename = "Sell.st",
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
								filename = "Buy.st",
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
		filename = "VendorHandler.st",
		finishcode = "",
		info = "Vendor / Repair",
		menucode = "",
		monitorcode = "GUI:Text('Last State: '..tostring(self:getState())) GUI:Text('Filename: '..self.variables.filename) GUI:Text('Filepath: '..self.filepath)",
		runcode = "",
		startcode = "",
		subtreeuicode = "",
	},
}



return tbl