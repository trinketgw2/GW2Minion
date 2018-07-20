gw2_strings =
{
    ["en"] =
    {
        aLogin    		                = "LoginName",
		aPassword  		                = "Password",
		aAutologin 		                = "Autologin",
		startStop                       = "StartStop",
		startBot                        = "Start Bot",
		stopBot                         = "Stop Bot",
		
		vendors							= "Vendors",
		vendorEnabled					= "Sell Items",
		vendorsbuy						= "VendorsBuyTools",
		blacklistVendor					= "Blacklist Vendor",		
		
		rarityMax                       = "Max Rarity",
		rarityNone                      = "None",
        rarityJunk                      = "Junk",
        rarityCommon                    = "Common",
        rarityFine                      = "Fine",
        rarityMasterwork                = "Masterwork",
        rarityRare                      = "Rare",
        rarityExotic                    = "Exotic",
        salvage                         = "Salvage",
        enableSalvage                   = "EnableSalvage",
		salvageItems                    = "Items",
		
		sellmanager						= "SellManager",
		selleditor						= "SellEditor",
		sellGroup						= "Sell Settings",				
		active							= "Active",
		newfiltername					= "New Filter Name",
		newfilter						= "New Filter",
		generalSettings					= "General Settings",
		sellfilters						= "Sell Multiple Items by Filter",
		name							= "Name",
		minLevel						= "Min Level",
		maxLevel						= "Max Level",
		markerTime						= "Marker Time (s)",
		useAetherytes					= "Use Aetherytes",
		resetDutyTimer 					= "Reset Timer: ",
		soulbound						= "Souldbound",
		itemtype						= "Itemtype",
		rarity							= "Rarity",
		preferedKit						= "Prefered Kit",
		weapontype						= "Weapontype",
		itemid							= "Item ID",
		sellByID						= "Sell Single Items",
		sellItemList					= "Sell Itemlist",
		sellByIDtems					= "Item to Sell",
		sellByIDAddItem					= "Add Item",
		sellByIDRemoveItem				= "Remove Item",
		filterdetails					= "Filter Details",
		buyGroup						= "Buy Settings",
		repairDamaged					= "Repair Damaged >",
		repairBroken					= "Repair Broken >",		
		salvagefilters					= "Salvage Multiple Items by Filter",
		salvageByID						= "Salvage Single Items",
		salvageItemList					= "Salvage Itemlist",
		salvageByIDtems					= "Item to Salvage",
		salvageByIDAddItem				= "Add Item",
		salvageByIDRemoveItem			= "Remove Item",
		salvagemanager					= "Salvage Manager",
		salvageeditor					= "Salvage Editor",
		
		--buymanager
		buymanager						= "Buy Manager",
		buyAllKits						= "Buy all Kits",
		buyBestKits						= "Buy best Kit",
		salvageKits						= "Buy Salvage Kits",
		gatherTools						= "Buy Gathering Tools",
		kitStock						= "Max Kit Stock",
		toolStock						= "Max Tool Stock",
		copperTools						= "Copper Tools",
		ironTools						= "Iron Tools",
		steelTools						= "Steel Tools",
		darksteelTools					= "Darksteel Tools",
		mithrilTools					= "Mithril Tools",
		orichalcumTools					= "Orichalcum Tools",
		buyCrude						= "Crude Kit",
		buyBasic						= "Basic Kit",
		buyFine							= "Fine Kit",
		buyJourneyman					= "Journeyman Kit",
		buyMaster						= "Master Kit",
		unlimitedKit					= "Unlimited Kit",
		mysticKit						= "Mystic Kit",
				
		--taskmanager
		customTasks						= "CustomTasks",
		taskManager						= "TaskManager",
		taskEditor						= "TaskEditor",
		tasks							= "Current Tasks",
		taskSetupTasks					= "Setup Tasks",
		taskCurrentTask					= "Current Task",
		taskAddTask						= "Add New Task",
		taskNewTaskProfile				= "Create New Profile",
		taskStartConditions				= "Start Conditions",
		taskCustomConditions			= "Custom Conditions",
		taskType						= "Type",
		taskPreTaskIDsComplete			= "PreTaskID Completed",
		taskStartMapID					= "Start MapID",
		taskStartMapPos					= "Start MapPosition",
		taskUseCurretPos				= "Update Position & MapID",
		taskRadius						= "Max Radius around Startposition",
		taskMinLvl						= "Min PlayerLevel",
		taskMaxLvl						= "Max PlayerLevel",
		taskMinDuration					= "Min Task Duration (s)",
		taskMaxDuration					= "Max Task Duration (s)",
		taskCoolDownDuration			= "Task Cooldown (s)",
		taskPartySize					= "Min PartySize",
		taskDeleteTask					= "Delete Task",
		taskMoveDownTask				= "Move Task Down",
		taskMoveUpTask					= "Move Task Up",
		taskMoveTo						= "MoveTo Position",
		taskHeartQuest					= "HeartQuest",
		taskVista						= "Vista",
		taskSkillpoint					= "Skillpoint",
		taskTypeInteractKill			= "Interact&Kill",
		taskAllowTeleports				= "Allow short Teleports",
		taskTypeInteract				= "Interact",
		taskSmoothTurn					= "Smooth Turning",
		taskRandomPos					= "Randomize Targetposition",
		taskTalk						= "Talk",
		taskspvp						= "sPvP",
		useWaypoint						= "Use Waypoint",
		
    },                                  

}
-- merge  the minionlib strings with our gw2 specific ones
for language,data in pairs(gw2_strings) do
	for skey,str in pairs(data) do
		if ( ml_miniondbstrings[skey] == nil ) then
			ml_miniondbstrings[skey] = { [language] = str }
			
		else
			if ( ml_miniondbstrings[skey][language] == nil ) then
				ml_miniondbstrings[skey][language] = str
			end
		end
	end	
end
for language,data in pairs(ml_strings) do
	for skey,str in pairs(data) do
		if ( ml_miniondbstrings[skey] == nil ) then
			ml_miniondbstrings[skey] = { [language] = str }
			
		else
			if ( ml_miniondbstrings[skey][language] == nil ) then
				ml_miniondbstrings[skey][language] = str
			end
		end
	end	
end