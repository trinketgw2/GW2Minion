gw2_sell_manager = {}
gw2_sell_manager.active = true
gw2_sell_manager.salvageTick = 0
gw2_sell_manager.toolTip = false
gw2_sell_manager.filterList = {list = {}, nameList = {}, currID = 1,}
gw2_sell_manager.singleItemList = {list = {}, nameList = {}, currID = 1,}
gw2_sell_manager.inventoryList = {list = {}, nameList = {}, currID = 1,}
gw2_sell_manager.soulbindOptions = {
	nameList = {"false","true","either",},
	idList = {["false"] = 1, ["true"] = 2, ["either"] = 3,},
	currID = 1,
}
gw2_sell_manager.tempFilter = {
	new = true,
	name = "",
	soulbound = "false",
	rarity = {Common = false, Fine = false, Masterwork = false, Rare = false, Exotic = false},
	itemType = {Armor = false, Back = false, Bag = false, Consumable = false, Container = false, CraftingMaterial = false, Gathering = false, Gizmo = false, MiniDeck = false, SalvageTool = false, Trinket = false, Trophy = false, UpgradeComponent = false, Weapon = false,},
}
gw2_sell_manager.tempSingleItem = {
	new = true,
	itemID = 0,
	name = "",
}
gw2_sell_manager.customChecks = {}


-- Gui stuff here.
gw2_sell_manager.mainWindow = {
	name = GetString("sellmanager"),
	open = false,
	visible = true,
}

function gw2_sell_manager.ModuleInit()
	-- Init Module.

	-- init active stuff here.
	if (Settings.gw2_sell_manager.active == nil) then
		Settings.gw2_sell_manager.active = true
	end
	gw2_sell_manager.active = Settings.gw2_sell_manager.active
	-- end active init.

	-- init tooltip stuff here.
	if (Settings.gw2_sell_manager.toolTip == nil) then
		Settings.gw2_sell_manager.toolTip = true
	end
	gw2_sell_manager.toolTip = Settings.gw2_sell_manager.toolTip
	-- end tooltip init.

	-- init filter stuff here.
	if (Settings.gw2_sell_manager.filterList == nil) then
		Settings.gw2_sell_manager.filterList = {list = {}, nameList = {}, currID = 1}
	end
	gw2_sell_manager.filterList = Settings.gw2_sell_manager.filterList
	gw2_sell_manager.filterListUpdate()
	-- end filter init.

	-- init single-item stuff here.
	if (Settings.gw2_sell_manager.singleItemList == nil) then
		Settings.gw2_sell_manager.singleItemList = {list = {}, nameList = {}, currID = 1}
	end
	gw2_sell_manager.singleItemList = Settings.gw2_sell_manager.singleItemList
	gw2_sell_manager.singleItemListUpdate()
	-- end single-item init.

	-- init inventorylist stuff here.
	gw2_sell_manager.updateInventoryItems()

	-- tracking charactername to prevent returning true because of missing data when loading
	gw2_sell_manager.character = false

	-- init button in minionmainbutton
	ml_gui.ui_mgr:AddMember({ id = "GW2MINION##SELLMGR", name = "Sell", onClick = function() gw2_sell_manager.mainWindow.open = gw2_sell_manager.mainWindow.open ~= true end, tooltip = "Click to open \"Sell Manager\" window.", texture = GetStartupPath().."\\GUI\\UI_Textures\\sell.png"},"GW2MINION##MENU_HEADER")
end

-- Gui draw function.
function gw2_sell_manager.mainWindow.Draw(event,ticks)
	if (gw2_sell_manager.mainWindow.open) then 
		-- set size on first use only.
		GUI:SetNextWindowSize(250,400,GUI.SetCond_FirstUseEver)
		-- update visible and open variables.
		gw2_sell_manager.mainWindow.visible, gw2_sell_manager.mainWindow.open = GUI:Begin(gw2_sell_manager.mainWindow.name, gw2_sell_manager.mainWindow.open, GUI.WindowFlags_AlwaysAutoResize) --+GUI.WindowFlags_NoCollapse
		if (gw2_sell_manager.mainWindow.visible) then
			-- Status field.
			-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			GUI:Spacing()
			GUI:BeginGroup()
			gw2_sell_manager.active = GUI:Checkbox(GetString("active"), gw2_sell_manager.active)
			Settings.gw2_sell_manager.active = gw2_sell_manager.active
			GUI:EndGroup()
			if (GUI:IsItemHovered() and gw2_sell_manager.toolTip) then
				GUI:SetTooltip("Turn Sell Manager on or off.")
			end
			-----------------------------------------------------------------------------------------------------------------------------------
			GUI:Separator()
			-----------------------------------------------------------------------------------------------------------------------------------
			-- Filter group here.
			-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			GUI:SetNextTreeNodeOpened(true, GUI.SetCond_Appearing) -- open the tree *BUG* conditions not working as expected.
			if (GUI:TreeNode(GetString("filters"))) then -- create the tree, only pop inside if.
				GUI:PushItemWidth(200)
				gw2_sell_manager.filterList.currID = GUI:ListBox("##msellm-filterlist",gw2_sell_manager.filterList.currID,gw2_sell_manager.filterList.nameList, 5)
				GUI:PopItemWidth()
				GUI:SameLine()
				GUI:BeginGroup()
				GUI:Spacing()
				-- NewFilter Button.
				-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
				if (GUI:Button(GetString("newfilter"), 100,25)) then
					GUI:OpenPopup("##msellm-filterPopup")
					gw2_sell_manager.tempFilter = {
						new = true,
						name = "",
						soulbound = false,
						rarity = {Common = false, Fine = false, Masterwork = false, Rare = false, Exotic = false},
						itemType = {Armor = false, Back = false, Bag = false, Consumable = false, Container = false, CraftingMaterial = false, Gathering = false, Gizmo = false, MiniDeck = false, SalvageTool = false, Trinket = false, Trophy = false, UpgradeComponent = false, Weapon = false,},
					}
				end
				if (GUI:IsItemHovered() and gw2_sell_manager.toolTip) then
					GUI:SetTooltip("Create a new filter.")
				end
				-- Edit Button.
				-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
				if (GUI:Button(GetString("editfilter"), 100,25)) then
					if (gw2_sell_manager.filterList.list[gw2_sell_manager.filterList.currID] ~= nil) then
						GUI:OpenPopup("##msellm-filterPopup")
						gw2_sell_manager.tempFilter = gw2_sell_manager.filterList.list[gw2_sell_manager.filterList.currID]
						gw2_sell_manager.soulbindOptions.currID = gw2_sell_manager.soulbindOptions.idList[gw2_sell_manager.filterList.list[gw2_sell_manager.filterList.currID].soulbound]
					end
				end
				if (GUI:IsItemHovered() and gw2_sell_manager.toolTip) then
					GUI:SetTooltip("Edit the selected filter.")
				end
				-- Create New/Edit filter button response.
				GUI:SetNextWindowPosCenter(GUI.SetCond_Always)
				GUI:SetNextWindowSize(400, 420, GUI.SetCond_Once)
				if (GUI:BeginPopup("##msellm-filterPopup")) then
					GUI:Spacing()
					GUI:Text(GetString("Filter details:"))
					GUI:Spacing()
					-----------------------------------------------------------------------------------------------------------------------------------
					GUI:Separator()
					-----------------------------------------------------------------------------------------------------------------------------------
					--name
					GUI:AlignFirstTextHeightToWidgets()
					GUI:Text(GetString("Name:"))
					GUI:SameLine(180)
					gw2_sell_manager.tempFilter.name = GUI:InputText("##msellm-filtername",gw2_sell_manager.tempFilter.name)
					--prefkit
					GUI:AlignFirstTextHeightToWidgets()
					GUI:Text(GetString("soulbound"))
					GUI:SameLine(180)
					gw2_sell_manager.soulbindOptions.currID = GUI:Combo("##msellm-filtersoulbindoption",gw2_sell_manager.soulbindOptions.currID,gw2_sell_manager.soulbindOptions.nameList)
					gw2_sell_manager.tempFilter.soulbound = gw2_sell_manager.soulbindOptions.nameList[gw2_sell_manager.soulbindOptions.currID]
					--rarity
					GUI:AlignFirstTextHeightToWidgets()
					GUI:Text(GetString("rarity"))
					GUI:SameLine(180)
					GUI:BeginChild("##msellm-filterrarity", 209, 80, true)
					gw2_sell_manager.tempFilter.rarity.Common = GUI:Checkbox(GetString("rarityCommon"),gw2_sell_manager.tempFilter.rarity.Common)
					GUI:SameLine(110)
					gw2_sell_manager.tempFilter.rarity.Fine = GUI:Checkbox(GetString("rarityFine"),gw2_sell_manager.tempFilter.rarity.Fine)
					gw2_sell_manager.tempFilter.rarity.Masterwork = GUI:Checkbox(GetString("rarityMasterwork"),gw2_sell_manager.tempFilter.rarity.Masterwork)
					GUI:SameLine(110)
					gw2_sell_manager.tempFilter.rarity.Rare = GUI:Checkbox(GetString("rarityRare"),gw2_sell_manager.tempFilter.rarity.Rare)
					gw2_sell_manager.tempFilter.rarity.Exotic = GUI:Checkbox(GetString("rarityExotic"),gw2_sell_manager.tempFilter.rarity.Exotic)
					GUI:EndChild()
					--itemtype
					GUI:AlignFirstTextHeightToWidgets()
					GUI:Text(GetString("Item-types:"))
					GUI:SameLine(110)
					GUI:BeginChild("##msellm-filteritemtype", 279, 173, true)
					gw2_sell_manager.tempFilter.itemType.Armor = GUI:Checkbox(GetString("Armor"),gw2_sell_manager.tempFilter.itemType.Armor)
					GUI:SameLine(155)
					gw2_sell_manager.tempFilter.itemType.Back = GUI:Checkbox(GetString("Back"),gw2_sell_manager.tempFilter.itemType.Back)
					gw2_sell_manager.tempFilter.itemType.Bag = GUI:Checkbox(GetString("Bag"),gw2_sell_manager.tempFilter.itemType.Bag)
					GUI:SameLine(155)
					gw2_sell_manager.tempFilter.itemType.Consumable = GUI:Checkbox(GetString("Consumable"),gw2_sell_manager.tempFilter.itemType.Consumable)
					gw2_sell_manager.tempFilter.itemType.CraftingMaterial = GUI:Checkbox(GetString("Crafting-Material"),gw2_sell_manager.tempFilter.itemType.CraftingMaterial)
					GUI:SameLine(155)
					gw2_sell_manager.tempFilter.itemType.Gathering = GUI:Checkbox(GetString("Gathering"),gw2_sell_manager.tempFilter.itemType.Gathering)
					gw2_sell_manager.tempFilter.itemType.Gizmo = GUI:Checkbox(GetString("Gizmo"),gw2_sell_manager.tempFilter.itemType.Gizmo)
					GUI:SameLine(155)
					gw2_sell_manager.tempFilter.itemType.MiniDeck = GUI:Checkbox(GetString("MiniDeck"),gw2_sell_manager.tempFilter.itemType.MiniDeck)
					gw2_sell_manager.tempFilter.itemType.SalvageTool = GUI:Checkbox(GetString("Salvage-Tool"),gw2_sell_manager.tempFilter.itemType.SalvageTool)
					GUI:SameLine(155)
					gw2_sell_manager.tempFilter.itemType.Trinket = GUI:Checkbox(GetString("Trinket"),gw2_sell_manager.tempFilter.itemType.Trinket)
					gw2_sell_manager.tempFilter.itemType.UpgradeComponent = GUI:Checkbox(GetString("Upgrade-Component"),gw2_sell_manager.tempFilter.itemType.UpgradeComponent)
					GUI:SameLine(155)
					gw2_sell_manager.tempFilter.itemType.Weapon = GUI:Checkbox(GetString("Weapon"),gw2_sell_manager.tempFilter.itemType.Weapon)
					gw2_sell_manager.tempFilter.itemType.Container = GUI:Checkbox(GetString("Container"),gw2_sell_manager.tempFilter.itemType.Container)
					GUI:SameLine(155)
					gw2_sell_manager.tempFilter.itemType.Trophy = GUI:Checkbox(GetString("Trophy"),gw2_sell_manager.tempFilter.itemType.Trophy)
					GUI:EndChild()
					-- Layout spacing.
					GUI:Spacing()
					-----------------------------------------------------------------------------------------------------------------------------------
					GUI:Separator()
					------------------------------------------------------------------------------------------------------------------------
					-- Layout spacing.
					GUI:Dummy(100,20)
					GUI:Spacing()
					-- CANCEL BUTTON.
					-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
					GUI:SameLine(80)
					if (GUI:Button(GetString("cancel"),80,30)) then
						GUI:CloseCurrentPopup()
					end
					-- OK BUTTON.
					-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
					GUI:SameLine(240)
					if (GUI:Button(GetString("ok"),80,30)) then
						if (gw2_sell_manager.validFilter(gw2_sell_manager.tempFilter)) then
							-- save new filter here.
							if (gw2_sell_manager.tempFilter.new) then
								gw2_sell_manager.tempFilter.new = nil
								table.insert(gw2_sell_manager.filterList.list, gw2_sell_manager.tempFilter)
							-- save edited filter here.
							else
								gw2_sell_manager.filterList.list[gw2_sell_manager.filterList.currID] = gw2_sell_manager.tempFilter
							end
							-- update.
							gw2_sell_manager.filterListUpdate()
							GUI:CloseCurrentPopup()
						else
							GUI:OpenPopup("Invalid Filter.")
						end
					end
					GUI:SetNextWindowPosCenter(GUI.SetCond_Always)
					GUI:SetNextWindowSize(400, 140, GUI.SetCond_Always)
					if (GUI:BeginPopupModal("Invalid Filter.",true,GUI.WindowFlags_NoResize+GUI.WindowFlags_NoMove+GUI.WindowFlags_ShowBorders)) then
						GUI:Spacing()
						GUI:SameLine(150)
						GUI:Text(GetString("Invalid Filter."))
						GUI:Spacing()
						GUI:SameLine(135)
						GUI:SetWindowFontScale(0.8)
						GUI:Text(GetString("Please check the filter."))
						GUI:SetWindowFontScale(1)
						
						GUI:Spacing()
						GUI:Separator()
						GUI:Dummy(100,20)
						GUI:Spacing()
						GUI:SameLine(160)
						if (GUI:Button(GetString("ok"),80,30)) then
							GUI:CloseCurrentPopup()
						end
						GUI:EndPopup()
					end
					GUI:EndPopup()
				end
				
				-- Delete Button.
				-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
				if (GUI:Button(GetString("deletefilter"), 100,25)) then
					if (gw2_sell_manager.filterList.list[gw2_sell_manager.filterList.currID] ~= nil) then
						GUI:OpenPopup("##msellm-deletefilterPopup")
					end
				end
				if (GUI:IsItemHovered() and gw2_sell_manager.toolTip) then
					GUI:SetTooltip("Delete the selected filter.")
				end
				GUI:SetNextWindowPosCenter(GUI.SetCond_Always)
				GUI:SetNextWindowSize(400, 140, GUI.SetCond_Always)
				if (GUI:BeginPopupModal("##msellm-deletefilterPopup",true,GUI.WindowFlags_NoResize+GUI.WindowFlags_NoMove+GUI.WindowFlags_ShowBorders)) then
					GUI:Spacing()
					GUI:SameLine(50)
					GUI:Text(GetString("Are you sure you want to delete this filter?"))
					GUI:Spacing()
					GUI:SameLine(80)
					GUI:SetWindowFontScale(0.8)
					GUI:Text(GetString("Press \"Delete\" to delete, \"Cancel\" to cancel. "))
					GUI:SetWindowFontScale(1)
					
					GUI:Spacing()
					GUI:Separator()
					GUI:Dummy(100,20)
					GUI:Spacing()
					GUI:SameLine(80)
					if (GUI:Button(GetString("cancel"),80,30)) then
						GUI:CloseCurrentPopup()
					end
					GUI:SameLine(240)
					if (GUI:Button(GetString("delete"),80,30)) then
						table.remove(gw2_sell_manager.filterList.list, gw2_sell_manager.filterList.currID)
						gw2_sell_manager.filterListUpdate()
						GUI:CloseCurrentPopup()
					end
					GUI:EndPopup()
				end
				
				GUI:EndGroup()
				GUI:TreePop()
			end
			-----------------------------------------------------------------------------------------------------------------------------------
			GUI:Separator()
			-----------------------------------------------------------------------------------------------------------------------------------
			
			-- Single item group here.
			-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			GUI:SetNextTreeNodeOpened(true, GUI.SetCond_FirstUseEver)
			if (GUI:TreeNode(GetString("singleitems"))) then
				GUI:PushItemWidth(200)
				gw2_sell_manager.singleItemList.currID = GUI:ListBox("##msellm-singleitemlist",gw2_sell_manager.singleItemList.currID,gw2_sell_manager.singleItemList.nameList, 5)
				GUI:PopItemWidth()
				GUI:SameLine()
				
				GUI:BeginGroup()
				GUI:Spacing()
				-- New-Item Button.
				-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
				if (GUI:Button(GetString("newitem"), 100,25)) then
					GUI:OpenPopup("##msellm-itemPopup")
					gw2_sell_manager.updateInventoryItems()
					gw2_sell_manager.tempSingleItem = {
						new = true,
						itemID = 0,
						name = "",
					}
				end
				if (GUI:IsItemHovered() and gw2_sell_manager.toolTip) then
					GUI:SetTooltip("Add a new item.")
				end
				-- Create Button response.
				GUI:SetNextWindowPosCenter(GUI.SetCond_Always)
				GUI:SetNextWindowSize(400, 160,GUI.SetCond_Once)
				if (GUI:BeginPopup("##msellm-itemPopup")) then
					GUI:Spacing()
					GUI:Text(GetString("Choose an item:"))
					GUI:Spacing()
					-----------------------------------------------------------------------------------------------------------------------------------
					GUI:Separator()
					-----------------------------------------------------------------------------------------------------------------------------------
					--name
					GUI:AlignFirstTextHeightToWidgets()
					GUI:Text(GetString("Item:"))
					GUI:PushItemWidth(240)
					GUI:SameLine(150)
					if (gw2_sell_manager.tempSingleItem.new) then
						gw2_sell_manager.inventoryList.currID = GUI:Combo("##msellm-inventorylist",gw2_sell_manager.inventoryList.currID,gw2_sell_manager.inventoryList.nameList)
						gw2_sell_manager.tempSingleItem.itemID = gw2_sell_manager.inventoryList.list[gw2_sell_manager.inventoryList.currID].itemID
						gw2_sell_manager.tempSingleItem.name = gw2_sell_manager.inventoryList.list[gw2_sell_manager.inventoryList.currID].name
					else
						GUI:InputText("##msellm-editItemName",gw2_sell_manager.tempSingleItem.name,GUI.InputTextFlags_ReadOnly)
					end
					-----------------------------------------------------------------------------------------------------------------------------------
					GUI:Separator()
					-----------------------------------------------------------------------------------------------------------------------------------
					-- Layout spacing.
					GUI:Dummy(100,20)
					GUI:Spacing()
					-- CANCEL BUTTON.
					-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
					GUI:SameLine(80)
					if (GUI:Button(GetString("cancel"),80,30)) then
						GUI:CloseCurrentPopup()
					end
					-- OK BUTTON.
					-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
					GUI:SameLine(240)
					if (GUI:Button(GetString("ok"),80,30)) then
						-- save new single item here.
						if (gw2_sell_manager.tempSingleItem.new) then
							gw2_sell_manager.tempSingleItem.new = nil
							table.insert(gw2_sell_manager.singleItemList.list, gw2_sell_manager.tempSingleItem)
						-- save edited single-item here.
						else
							gw2_sell_manager.singleItemList.list[gw2_sell_manager.singleItemList.currID] = gw2_sell_manager.tempSingleItem
						end
						-- update.
						gw2_sell_manager.singleItemListUpdate()
						GUI:CloseCurrentPopup()
					end
					GUI:EndPopup()
				end
				
				-- Delete Button.
				-->>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<
				if (GUI:Button(GetString("Delete Item"), 100,25)) then
					if (gw2_sell_manager.singleItemList.list[gw2_sell_manager.singleItemList.currID] ~= nil) then
						GUI:OpenPopup("Delete Item?")
					end
				end
				if (GUI:IsItemHovered() and gw2_sell_manager.toolTip) then
					GUI:SetTooltip("Delete the selected item.")
				end
				GUI:SetNextWindowPosCenter(GUI.SetCond_Always)
				GUI:SetNextWindowSize(400, 140, GUI.SetCond_Always)
				if (GUI:BeginPopupModal("Delete Item?",true,GUI.WindowFlags_NoResize+GUI.WindowFlags_NoMove+GUI.WindowFlags_ShowBorders)) then
					GUI:Spacing()
					GUI:SameLine(50)
					GUI:Text(GetString("Are you sure you want to delete this item?"))
					GUI:Spacing()
					GUI:SameLine(80)
					GUI:SetWindowFontScale(0.8)
					GUI:Text(GetString("Press \"Delete\" to delete, \"Cancel\" to cancel. "))
					GUI:SetWindowFontScale(1)
					
					GUI:Spacing()
					GUI:Separator()
					GUI:Dummy(100,20)
					GUI:Spacing()
					GUI:SameLine(80)
					if (GUI:Button(GetString("cancel"),80,30)) then
						GUI:CloseCurrentPopup()
					end
					GUI:SameLine(240)
					if (GUI:Button(GetString("delete"),80,30)) then
						table.remove(gw2_sell_manager.singleItemList.list, gw2_sell_manager.singleItemList.currID)
						gw2_sell_manager.singleItemListUpdate()
						GUI:CloseCurrentPopup()
					end
					GUI:EndPopup()
				end
				GUI:EndGroup()
				GUI:TreePop()
			end
			-----------------------------------------------------------------------------------------------------------------------------------
			GUI:Separator()
			-----------------------------------------------------------------------------------------------------------------------------------
		end
		GUI:End()
	end

end

-- Filter list functions.
function gw2_sell_manager.filterListUpdate()
	gw2_sell_manager.filterList.nameList = {}
	for id,filter in ipairs(gw2_sell_manager.filterList.list) do
		table.insert(gw2_sell_manager.filterList.nameList,filter.name)
	end
	Settings.gw2_sell_manager.filterList = gw2_sell_manager.filterList
end

function gw2_sell_manager.itemMatchesFilter(nItem)
	if (table.valid(nItem)) then
		for _,filter in pairs(gw2_sell_manager.filterList.list) do
			if (filter.soulbound == "either" or filter.soulbound == tostring(nItem.soulbound)) then
				local matchFilterRarity = false
				local matchFilterItemType = false
				for id,allowed in pairs(filter.rarity) do
					if (allowed and GW2.ITEMRARITY[id] == nItem.rarity) then
						matchFilterRarity = true
						break
					end
				end
				if (matchFilterRarity) then
					for id,allowed in pairs(filter.itemType) do
						if (allowed and GW2.ITEMTYPE[id] == nItem.itemtype) then
							matchFilterItemType = true
							break
						end
					end
					if (matchFilterItemType) then
						return true,nItem
					end
				end
			end
		end
	end
	return false
end

function gw2_sell_manager.validFilter(filter)
	return (table.valid(filter) and string.valid(filter.name) and table.contains(filter.rarity,true) and table.contains(filter.itemType,true))
end

-- Single-item list functions.
function gw2_sell_manager.singleItemListUpdate()
	gw2_sell_manager.singleItemList.nameList = {}
	for id,item in ipairs(gw2_sell_manager.singleItemList.list) do
		table.insert(gw2_sell_manager.singleItemList.nameList,item.name)
	end
	Settings.gw2_sell_manager.singleItemList = gw2_sell_manager.singleItemList
end

function gw2_sell_manager.singleItemListContains(nItem)
	if (table.valid(nItem)) then
		for _,eItem in pairs(gw2_sell_manager.singleItemList.list) do
			if (eItem.itemID == nItem.itemID) then
				return true,nItem
			end
		end
	end
	return false
end

-- Inventory functions.
function gw2_sell_manager.updateInventoryItems()
	local inventory = Inventory("")
	gw2_sell_manager.inventoryList.list = {}
	gw2_sell_manager.inventoryList.nameList = {}
	gw2_sell_manager.inventoryList.currID = 1
	for id,nItem in pairsByValueAttribute(inventory,"name") do
		if (table.valid(nItem) and gw2_sell_manager.singleItemListContains(nItem) == false) then
			table.insert(gw2_sell_manager.inventoryList.list,nItem)
			table.insert(gw2_sell_manager.inventoryList.nameList,nItem.name)
		end
	end
end

-- Salvage List stuff here.
function gw2_sell_manager.createItemList()
	local inventoryItems = Inventory("exclude_contentid="..gw2_blacklistmanager.GetExcludeString(GetString("Sell items")))
	local filteredItems = {}
	if (table.valid(inventoryItems)) then
		for slot,nItem in pairs(inventoryItems) do
			nItem = nItem
			if (gw2_sell_manager.itemMatchesFilter(nItem) or gw2_sell_manager.singleItemListContains(nItem)) then
				nItem.slot = slot
				table.insert(filteredItems,nItem)
			end
		end
	end
	return filteredItems
end

-- working checks here.
function gw2_sell_manager.haveItemToSell()
	if (table.valid(gw2_sell_manager.createItemList())) then
		return true
	end
	return false
end

-- Get closest sellMarker
function gw2_sell_manager.getClosestSellMarker(nearby)
	local closestLocation = nil
	local listArg = (nearby == true and ",maxdistance=5000" or "")
	local markers = gw2_sell_manager.getMarkerList(listArg)
	if ( table.valid(markers) ) then
		for _,marker in pairs(markers) do
			if (closestLocation == nil or closestLocation.distance > marker.distance) then
				if (nearby == true and marker.pathdistance < 4000) then
					closestLocation = marker
				elseif (nearby ~= true) then
					closestLocation = marker
				end
			end	
		end
	end

	return closestLocation
end

function gw2_sell_manager.getMarkerList(filter)
	filter = filter or ""
	local markers = {}
	local MList = MapMarkerList("onmesh"..filter..",exclude_characterid="..gw2_blacklistmanager.GetExcludeString(GetString("Vendor sell")))
	if(table.valid(MList)) then
		for _,marker in pairs(MList) do
			if (table.contains(ml_global_information.VendorSell,marker.contentid)) then
				table.insert(markers, marker)
			end
		end
	end
	return markers
end

--sellhere.
gw2_sell_manager.lastVendorID = nil
gw2_sell_manager.VendorSellHistroy = {}
function gw2_sell_manager.sellAtVendor(vendor)
	if (vendor) then
		-- Reset vendorhistory on new vendor
		if ( gw2_sell_manager.lastVendorID == nil or gw2_sell_manager.lastVendorID ~= vendor.id ) then
			gw2_sell_manager.lastVendorID = vendor.id
			gw2_sell_manager.VendorSellHistroy = {}
			gw2_sell_manager.VendorSellHistroy.interactcount = 0
		end
		
		if(gw2_sell_manager.VendorSellHistroy.interactcount > 15) then
			d("[gw2_sell_manager]: Vendor blacklisted: Tried interacting multiple times.")
			gw2_blacklistmanager.AddBlacklistEntry(GetString("Vendor sell"), vendor.id, vendor.name, true)			
		end
		
		if (Inventory:IsVendorOpened() == false and Player:IsConversationOpen() == false) then
			d("[gw2_sell_manager]: Opening Vendor... ")
			Player:Interact(vendor.id)
			gw2_sell_manager.VendorSellHistroy.interactcount = gw2_sell_manager.VendorSellHistroy.interactcount + 1
			ml_global_information.Wait(1500)
			return true
		else
			local result = gw2_common_functions.handleConversation("sell")
			if (result == false) then
				d("[gw2_sell_manager]: Vendor blacklisted: Could not handle conversation.")
				gw2_blacklistmanager.AddBlacklistEntry(GetString("Vendor sell"), vendor.id, vendor.name, true)
				return false
			elseif (result == nil) then
				ml_global_information.Wait(math.random(520,1200))
				return true
			end
		end
		if(gw2_sell_manager.sellItems()) then
			return true
		end
		ml_global_information.Wait(math.random(520,750))
	end
	return false
end

function gw2_sell_manager.sellItems()
	local iList = gw2_sell_manager.createItemList()
	local slowdown = math.random(0,1)
	local soldstuff = false
	if ( table.valid(iList) ) then
		if ( slowdown == 0 ) then
			for _,item in pairs(iList) do
				d("[gw2_sell_manager]: Selling: "..item.name)
				item:Sell()
				local uniqueItemID = item.itemid .. item.slot
				if (not gw2_sell_manager.VendorSellHistroy[uniqueItemID]) then
					gw2_sell_manager.VendorSellHistroy[uniqueItemID] = 1
				elseif (gw2_sell_manager.VendorSellHistroy[uniqueItemID] < 5) then
					gw2_sell_manager.VendorSellHistroy[uniqueItemID] = gw2_sell_manager.VendorSellHistroy[uniqueItemID] + 1
				else
					d("[gw2_sell_manager]: Could not sell "..item.name..", blacklisting it")
					gw2_blacklistmanager.AddBlacklistEntry(GetString("Sell items"), item.itemID, item.name, true)
				end
				return true
			end
		end
		return true
	end
	
	if(not gw2_sell_manager.VendorSellHistroy.sellingjunk) then
		gw2_sell_manager.VendorSellHistroy.sellingjunk = 0
		d("[gw2_sell_manager]: Selling junk...")
		Inventory:SellJunk()
		return true
	end
	
	if(gw2_sell_manager.VendorSellHistroy.sellingjunk) then
		-- Throttle it a little bit
		if(gw2_sell_manager.VendorSellHistroy.sellingjunk > 1) then
			local junkitems = Inventory("rarity="..GW2.ITEMRARITY.Junk..",exclude_contentid="..gw2_blacklistmanager.GetExcludeString(GetString("Sell items")))
			if(table.valid(junkitems)) then
				d("[gw2_sell_manager]: There were junk items left over from last tick. Blacklisting them.")
				for _,item in pairs(junkitems) do
					d("[gw2_sell_manager]: Junk item "..item.name..", blacklisting it for 15 minutes")
					gw2_blacklistmanager.AddBlacklistEntry(GetString("Sell items"), item.itemID, item.name or "junk item", 15*60*1000)				
				end
			end
		else
			gw2_sell_manager.VendorSellHistroy.sellingjunk = gw2_sell_manager.VendorSellHistroy.sellingjunk + 1
			return true
		end
	end
	
	-- No more items to sell
	d("[gw2_sell_manager]: Selling finished...")
	gw2_sell_manager.VendorSellHistroy = {}
	gw2_sell_manager.VendorSellHistroy.interactcount = 0
end

--needtosell.
function gw2_sell_manager.needToSell(nearby)
	if gw2_sell_manager.character == ml_global_information.Player_Name then
		local junkitems = Inventory("rarity="..GW2.ITEMRARITY.Junk..",exclude_contentid="..gw2_blacklistmanager.GetExcludeString(GetString("Sell items")))
		local selljunk = table.size(junkitems) > 3 or (table.valid(junkitems) and ((ml_global_information.Player_Inventory_SlotsFree*100)/Inventory.slotcount) < 15)
		local sellitems =  gw2_sell_manager.ItemsToSell() > 3 or (gw2_sell_manager.ItemsToSell() > 0 and ((ml_global_information.Player_Inventory_SlotsFree*100)/Inventory.slotcount) < 15)

		if (table.valid(gw2_sell_manager.createItemList()) or selljunk or sellitems) then
			if (nearby and ((ml_global_information.Player_Inventory_SlotsFree*100)/Inventory.slotcount) < 33) then
				return true
			elseif (ml_global_information.Player_Inventory_SlotsFree <= 2) then
				return true
			end
		end
	else
		gw2_sell_manager.character = ml_global_information.Player_Name
	end

	return false
end

function gw2_sell_manager.ItemsToSell()
local count = table.size(Inventory("rarity="..GW2.ITEMRARITY.Junk..",exclude_contentid="..gw2_blacklistmanager.GetExcludeString(GetString("Sell items"))))
local inventory_list = Inventory("")

	for k,v in pairs(inventory_list) do
		if v.rarity ~= GW2.ITEMRARITY.Junk then
		local filter_matched = false
			for k2,v2 in pairs(gw2_sell_manager.singleItemList.list) do
				if v2.itemID == v.itemID then 
					filter_matched = true
					count = count + 1
				end
			end
			
			if not filter_matched and gw2_sell_manager.itemMatchesFilter(v) then
					count = count + 1		
			end
		end
	end
	return count
end

-- Toggle menu. TODO: replace with new gui stuff yeah.
function gw2_sell_manager.ToggleMenu()
	gw2_sell_manager.mainWindow.open = gw2_sell_manager.mainWindow.open ~= true
end

-- Register Events here.
RegisterEventHandler("Module.Initalize", gw2_sell_manager.ModuleInit, "gw2_sell_manager.ModuleInit")
RegisterEventHandler("Gameloop.Draw", gw2_sell_manager.mainWindow.Draw, "gw2_sell_manager.mainWindow.Draw")
