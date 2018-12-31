gw2_buy_manager = {}
gw2_buy_manager.availableOnMap = {
	lastMap = 0,
	salvage = {},
	gathering = {},
} -- Set in init

gw2_buy_manager.cities = {
	50
}

gw2_buy_manager.changingmaps = {
	currentmapid = nil;
	targetmapid = nil
}

local merchants = {
	default = ml_global_information.VendorBuy;
	toolvendor = {887588}
}
gw2_buy_manager.merchants = merchants

local walletentry = {
	Coin = 1;
	Karma = 2;
}
gw2_buy_manager.walletentry = walletentry

gw2_buy_manager.GATHERTOOLS = {
	None = 0;
	Copper = 1;
	Iron = 2;
	Steel = 3;
	Darksteel = 4;
	Mithril = 5;
	Orichalcum = 6;
	Leatherworker = 7;
	Tailor = 8;
	Scavenger = 9;
	Watchknight = 10;
	Flying = 11;
	Industrious = 12;
	Bounty = 13;
}
-- Easily reach the key name
gw2_buy_manager.GATHERTOOLS_inverted = table.invert(gw2_buy_manager.GATHERTOOLS)

gw2_buy_manager.SALVAGEKITS = {
	Crude = 1;
	Basic = 2;
	Fine = 3;
	Journeyman = 4;
	Master = 5;
	BlackLion = 6;
}

-- Easily reach the key name
gw2_buy_manager.SALVAGEKITS_inverted = table.invert(gw2_buy_manager.SALVAGEKITS)

gw2_buy_manager.tooltypes = {
	[gw2_buy_manager.GATHERTOOLS.Copper] = {name = GetString("Copper"), currency = walletentry.Coin, minlevel = 0, merchant = merchants.default; cityonly = false; };
	[gw2_buy_manager.GATHERTOOLS.Iron] = {name = GetString("Iron"), currency = walletentry.Coin, minlevel = 10, merchant = merchants.default; cityonly = false; };
	[gw2_buy_manager.GATHERTOOLS.Steel] = {name = GetString("Steel"), currency = walletentry.Coin, minlevel = 20, merchant = merchants.default; cityonly = false; };
	[gw2_buy_manager.GATHERTOOLS.Darksteel] = {name = GetString("Darksteel"), currency = walletentry.Coin, minlevel = 30, merchant = merchants.default; cityonly = false; };
	[gw2_buy_manager.GATHERTOOLS.Mithril] = {name = GetString("Mithril"), currency = walletentry.Coin, minlevel = 40, merchant = merchants.default; cityonly = false; };
	[gw2_buy_manager.GATHERTOOLS.Orichalcum] = {name = GetString("Orichalcum"), currency = walletentry.Coin, minlevel = 60, merchant = merchants.default; cityonly = false; };
	[gw2_buy_manager.GATHERTOOLS.Leatherworker] = {name = GetString("Leatherworker's"), currency = walletentry.Karma, minlevel = 60, merchant = merchants.toolvendor; cityonly = true; };
	[gw2_buy_manager.GATHERTOOLS.Tailor] = {name = GetString("Tailor's"), currency = walletentry.Karma, minlevel = 60, merchant = merchants.toolvendor; cityonly = true; };
	[gw2_buy_manager.GATHERTOOLS.Scavenger] = {name = GetString("Scavenger's"), currency = walletentry.Karma, minlevel = 60, merchant = merchants.toolvendor; cityonly = true; };
	[gw2_buy_manager.GATHERTOOLS.Watchknight] = {name = GetString("Watchknight's"), currency = walletentry.Karma, minlevel = 60, merchant = merchants.toolvendor; cityonly = true; };
	[gw2_buy_manager.GATHERTOOLS.Flying] = {name = GetString("Flying"), currency = walletentry.Karma, minlevel = 60, merchant = merchants.toolvendor; cityonly = true; };
	[gw2_buy_manager.GATHERTOOLS.Industrious] = {name = GetString("Industrious"), currency = walletentry.Karma, minlevel = 60, merchant = merchants.toolvendor; cityonly = true; };
	[gw2_buy_manager.GATHERTOOLS.Bounty] = {name = GetString("Bounty"), currency = walletentry.Karma, minlevel = 60, merchant = merchants.toolvendor; cityonly = true; };
}

gw2_buy_manager.salvagekits = {
	[gw2_buy_manager.SALVAGEKITS.Crude] = {id = 23038, minlevel = 0, name = GetString("Crude Salvage Kit"), rarity = 1, currency = walletentry.Coin, merchant = merchants.default};
	[gw2_buy_manager.SALVAGEKITS.Basic] = {id = 23040, minlevel = 0, name = GetString("Basic Salvage Kit"), rarity = 1, currency = walletentry.Coin, merchant = merchants.default };
	[gw2_buy_manager.SALVAGEKITS.Fine] = {id = 23041, minlevel = 0, name = GetString("Fine Salvage Kit"), rarity = 2, currency = walletentry.Coin, merchant = merchants.default };
	[gw2_buy_manager.SALVAGEKITS.Journeyman] = {id = 23042, minlevel = 0, name = GetString("Journeyman Salvage Kit"), rarity = 3, currency = walletentry.Coin, merchant = merchants.default };
	[gw2_buy_manager.SALVAGEKITS.Master] = {id = 23043, minlevel = 0, name = GetString("Master Salvage Kit"), rarity = 4, currency = walletentry.Coin, merchant = merchants.default };
	[gw2_buy_manager.SALVAGEKITS.BlackLion] = {id = 23043, minlevel = 0, name = GetString("Black Lion Salvage Kit"), rarity = 5, currency = nil, merchant = nil };
}

-- Available to buy
gw2_buy_manager.tools = {
	foraging = {
		[gw2_buy_manager.GATHERTOOLS.Copper] = 23029;
		[gw2_buy_manager.GATHERTOOLS.Iron] = 22992;
		[gw2_buy_manager.GATHERTOOLS.Steel] = 23004;
		[gw2_buy_manager.GATHERTOOLS.Darksteel] = 23005;
		[gw2_buy_manager.GATHERTOOLS.Mithril] = 23008;
		[gw2_buy_manager.GATHERTOOLS.Orichalcum] = 22997;
		[gw2_buy_manager.GATHERTOOLS.Leatherworker] = 87454;
		[gw2_buy_manager.GATHERTOOLS.Tailor] = 87388;
		[gw2_buy_manager.GATHERTOOLS.Scavenger] = 87384;
		[gw2_buy_manager.GATHERTOOLS.Watchknight] = 87445;
		[gw2_buy_manager.GATHERTOOLS.Flying] = 87446;
		[gw2_buy_manager.GATHERTOOLS.Industrious] = 87423;
		[gw2_buy_manager.GATHERTOOLS.Bounty] = 87472;
	},
	logging = {
		[gw2_buy_manager.GATHERTOOLS.Copper] = 23030;
		[gw2_buy_manager.GATHERTOOLS.Iron] = 22994;
		[gw2_buy_manager.GATHERTOOLS.Steel] = 23002;
		[gw2_buy_manager.GATHERTOOLS.Darksteel] = 23006;
		[gw2_buy_manager.GATHERTOOLS.Mithril] = 23009;
		[gw2_buy_manager.GATHERTOOLS.Orichalcum] = 23000;
		[gw2_buy_manager.GATHERTOOLS.Leatherworker] = 87444;
		[gw2_buy_manager.GATHERTOOLS.Tailor] = 87404;
		[gw2_buy_manager.GATHERTOOLS.Scavenger] = 87411;
		[gw2_buy_manager.GATHERTOOLS.Watchknight] = 87401;
		[gw2_buy_manager.GATHERTOOLS.Flying] = 87441;
		[gw2_buy_manager.GATHERTOOLS.Industrious] = 87393;
		[gw2_buy_manager.GATHERTOOLS.Bounty] = 87406;
	};
	mining = {
		[gw2_buy_manager.GATHERTOOLS.Copper] = 23031;
		[gw2_buy_manager.GATHERTOOLS.Iron] = 22995;
		[gw2_buy_manager.GATHERTOOLS.Steel] = 23003;
		[gw2_buy_manager.GATHERTOOLS.Darksteel] = 23007;
		[gw2_buy_manager.GATHERTOOLS.Mithril] = 23010;
		[gw2_buy_manager.GATHERTOOLS.Orichalcum] = 23001;
		[gw2_buy_manager.GATHERTOOLS.Leatherworker] = 87449;
		[gw2_buy_manager.GATHERTOOLS.Tailor] = 87453;
		[gw2_buy_manager.GATHERTOOLS.Scavenger] = 87463;
		[gw2_buy_manager.GATHERTOOLS.Watchknight] = 87431;
		[gw2_buy_manager.GATHERTOOLS.Flying] = 87416;
		[gw2_buy_manager.GATHERTOOLS.Industrious] = 87437;
		[gw2_buy_manager.GATHERTOOLS.Bounty] = 87455;
	},
	-- Basically the same as the other list since there are only 1 type of salvage kit for each type
	salvage = {
		[gw2_buy_manager.SALVAGEKITS.Crude] = gw2_buy_manager.salvagekits[gw2_buy_manager.SALVAGEKITS.Crude].id;
		[gw2_buy_manager.SALVAGEKITS.Basic] = gw2_buy_manager.salvagekits[gw2_buy_manager.SALVAGEKITS.Basic].id;
		[gw2_buy_manager.SALVAGEKITS.Fine] = gw2_buy_manager.salvagekits[gw2_buy_manager.SALVAGEKITS.Fine].id;
		[gw2_buy_manager.SALVAGEKITS.Journeyman] = gw2_buy_manager.salvagekits[gw2_buy_manager.SALVAGEKITS.Journeyman].id;
		[gw2_buy_manager.SALVAGEKITS.Master] = gw2_buy_manager.salvagekits[gw2_buy_manager.SALVAGEKITS.Master].id;
	}
}

gw2_buy_manager.toolnames = {}
gw2_buy_manager.salvagekitnames = {}
gw2_buy_manager.currenttoolindex = gw2_buy_manager.GATHERTOOLS.Orichalcum

gw2_buy_manager.lastVendorID = nil
gw2_buy_manager.vendorbuyactivity = {}
gw2_buy_manager.vendoritemhistory = {}

gw2_buy_manager.default_settings = {
	tooltype = gw2_buy_manager.GATHERTOOLS.Orichalcum;
	toolstack = 0;
	crudekit = 0;
	basickit = 0;
	finekit = 0;
	journeymankit = 0;
	masterkit = 0;
	sharedsettings = false;
	enabled = false;
	isglobal = false;
	buyincities = false;
}

-- Cache for often requested values
gw2_buy_manager.cache = {}
gw2_buy_manager.cache.gathertools = {timestamp = nil; tools = nil;}
gw2_buy_manager.cache.salvagekits = {timestamp = nil; kits = nil;}

-- Gui stuff here.
gw2_buy_manager.mainWindow = {
	name = GetString("Buy Manager"),
	open = false,
	visible = true,
}

gw2_buy_manager.SettingsVersion = 1

function gw2_buy_manager.ModuleInit()
	-- init button in minionmainbutton
	ml_gui.ui_mgr:AddMember({ id = "GW2MINION##BUYMGR", name = "Buy", onClick = function() gw2_buy_manager.mainWindow.open = gw2_buy_manager.mainWindow.open ~= true end, tooltip = "Click to open \"Buy Manager\" window.", texture = GetStartupPath().."\\GUI\\UI_Textures\\buy.png"},"GW2MINION##MENU_HEADER")
	
	for id,tool in pairs(gw2_buy_manager.tooltypes) do
		gw2_buy_manager.availableOnMap.gathering[id] = true
	end
	
	for id,tool in pairs(gw2_buy_manager.salvagekits) do
		gw2_buy_manager.availableOnMap.salvage[id] = true
	end
end
RegisterEventHandler("Module.Initalize",gw2_buy_manager.ModuleInit)

function gw2_buy_manager.PlayerChanged()
	if(Settings.gw2_buy_manager.version ~= gw2_buy_manager.SettingsVersion) then
		Settings.gw2_buy_manager = {}
		gw2_buy_manager.PopulateDefaultSettings()
		Settings.gw2_buy_manager.version = gw2_buy_manager.SettingsVersion
		gw2_gui_manager.QueueMessage(gw2_buy_manager.DrawSettingsChanged)
	end
	
	gw2_buy_manager.PopulateDefaultSettings()

	local settings = gw2_buy_manager.GetSettings()
	gw2_buy_manager.currenttoolindex = settings.tooltype
end
RegisterEventHandler("gw2minion.PlayerChanged",gw2_buy_manager.PlayerChanged)

-- Gui draw function.
function gw2_buy_manager.Draw(event,ticks)
	if (gw2_buy_manager.mainWindow.open) then 
		-- set size on first use only.
		GUI:SetNextWindowSize(300,400,GUI.SetCond_FirstUseEver)
		-- update visible and open variables.
		gw2_buy_manager.mainWindow.visible, gw2_buy_manager.mainWindow.open = GUI:Begin(gw2_buy_manager.mainWindow.name, gw2_buy_manager.mainWindow.open, GUI.WindowFlags_AlwaysAutoResize) --+GUI.WindowFlags_NoCollapse
		if (gw2_buy_manager.mainWindow.visible) then
			gw2_buy_manager.DrawSettings()
		end
		GUI:End()
	end
end
RegisterEventHandler("Gameloop.Draw", gw2_buy_manager.Draw)

function gw2_buy_manager.DrawSettings()
	-- Status field.
	GUI:Spacing()
	local settings = gw2_buy_manager.GetSettings()
	local changed = false
	
	settings.enabled, changed = GUI:Checkbox(GetString("Enabled"), settings.enabled or false)
	if(changed and settings.isglobal) then
		gw2_buy_manager.SaveSettings()
	end
	
	if (GUI:IsItemHovered()) then
		GUI:SetTooltip(GetString("Turn buying on or off."))
	end

	settings.buyincities, changed = GUI:Checkbox(GetString("Always buy in cities"), settings.buyincities or false)
	if(changed and settings.isglobal) then
		gw2_buy_manager.SaveSettings()
	end
	
	if (GUI:IsItemHovered()) then
		GUI:SetTooltip(GetString("Always buy tools and kits in cities.\nThis is default for the special gather tools."))
	end

	Settings.gw2_buy_manager.sharedsettings, changed = GUI:Checkbox(GetString("Shared settings"), Settings.gw2_buy_manager.sharedsettings or false)
	if(changed and settings.isglobal) then
		gw2_buy_manager.SaveSettings()
	end
	
	if (GUI:IsItemHovered()) then
		GUI:SetTooltip(GetString("Shared settings for all characters."))
	end
	GUI:Separator()
	
	gw2_buy_manager.DrawSalvageSettings()
	
	GUI:Separator()
	
	gw2_buy_manager.DrawGatherSettings()
end

function gw2_buy_manager.DrawSalvageSettings()
	GUI:SetNextTreeNodeOpened(true, GUI.SetCond_Appearing)
	if (GUI:TreeNode(GetString("Salvage kits"))) then
		local settings = gw2_buy_manager.GetSettings()

		local sx,sy = gw2_buy_manager.GetMaxTextSize()
		
		for k,v in pairs(gw2_buy_manager.tools.salvage) do
			GUI:AlignFirstTextHeightToWidgets()
			GUI:Text(gw2_buy_manager.salvagekits[k].name..":")
			GUI:SameLine(sx*1.3)
			GUI:PushItemWidth(160)
			local skey = string.lower(gw2_buy_manager.SALVAGEKITS_inverted[k].."kit")
			local changed = false
			
			settings[skey],changed = GUI:SliderInt("##mbuym-"..skey, settings[skey], 0, 25)
			
			if(changed and settings.isglobal) then
				gw2_buy_manager.SaveSettings()
			end
			
			GUI:PopItemWidth()
			if (GUI:IsItemHovered()) then
				GUI:SetTooltip(GetString("Number of kits to buy"))
			end

		end

		GUI:TreePop()
	end
end

function gw2_buy_manager.DrawGatherSettings()
	GUI:SetNextTreeNodeOpened(true, GUI.SetCond_Appearing) -- open the tree *BUG* conditions not working as expected.
	if (GUI:TreeNode(GetString("Gather tool"))) then -- create the tree, only pop inside if.
		local settings = gw2_buy_manager.GetSettings()
	
		local sx, sy = gw2_buy_manager.GetMaxTextSize()

		GUI:AlignFirstTextHeightToWidgets()
		GUI:Text(GetString("Tool type")..":")
		GUI:SameLine(sx*1.3)
		GUI:PushItemWidth(160)
		local changed = false
		gw2_buy_manager.currenttoolindex, changed = GUI:Combo("##mbuym-tooltobuy",gw2_buy_manager.currenttoolindex,gw2_buy_manager.GATHERTOOLS_inverted)
		if (changed) then
			settings.tooltype = gw2_buy_manager.currenttoolindex
			if(settings.isglobal) then 	gw2_buy_manager.SaveSettings() end
		end

		GUI:PopItemWidth()

		GUI:AlignFirstTextHeightToWidgets()
		GUI:Text(GetString("Tool stack")..":")
		GUI:SameLine(sx*1.3)
		GUI:PushItemWidth(160)
		settings.toolstack,changed = GUI:SliderInt("##mbuym-toolstack", settings.toolstack, 0, 25)
				
		if(changed and settings.isglobal) then
			gw2_buy_manager.SaveSettings()
		end
		
		GUI:PopItemWidth()
		if (GUI:IsItemHovered()) then
			GUI:SetTooltip(GetString("Number of tools to buy"))
		end

		
		GUI:TreePop()
	end
end

function gw2_buy_manager.DrawSettingsChanged()
	if(not GUI:IsPopupOpen(GetString("Buy manager settings changed"))) then
		GUI:OpenPopup(GetString("Buy manager settings changed"))
	end
	
	GUI:SetNextWindowSize(600,800)
	if (GUI:BeginPopupModal("Buy manager settings changed",true,GUI.WindowFlags_AlwaysAutoResize+GUI.WindowFlags_NoMove+GUI.WindowFlags_ShowBorders)) then	
		GUI:Text("The buy manager settings have changed or are invalid")
		GUI:Text("Please change your buy settings")
		GUI:Separator()
		gw2_buy_manager.DrawSettings()
		GUI:Separator()
		if(GUI:Button(GetString("Close"))) then
			GUI:EndPopup()
			return false
		end
		GUI:EndPopup()
	end
	return true
end

function gw2_buy_manager.GetMaxTextSize()
	local maxw = 0
	local maxh = 0
	
	for k,v in pairs(gw2_buy_manager.tools.salvage) do
		local sx, sy = GUI:CalcTextSize(gw2_buy_manager.salvagekits[k].name)
		if(sx > maxw) then maxw = sx end
		if(sy > maxh) then maxh = sy end
	end
	
	return maxw, maxh
end

function gw2_buy_manager.GetSettings()
	if(Settings.gw2_buy_manager.sharedsettings) then
		return Settings.Global.gw2_buy_manager
	end
	
	return Settings.gw2_buy_manager
end

function gw2_buy_manager.SaveSettings()
	-- Global needs a save trigger
	Settings.Global.gw2_buy_manager = Settings.Global.gw2_buy_manager
end

function gw2_buy_manager.PopulateDefaultSettings()
	if(Settings.Global.gw2_buy_manager == nil) then Settings.Global.gw2_buy_manager = {} end
	
	for k,v in pairs(gw2_buy_manager.default_settings) do
		if(Settings.gw2_buy_manager[k] == nil) then
			Settings.gw2_buy_manager[k] = v
		end
		
		if(Settings.Global.gw2_buy_manager[k] == nil) then
			Settings.Global.gw2_buy_manager[k] = v
		end
	end
	
	Settings.Global.gw2_buy_manager.isglobal = true
end

-- Working stuff here.
function gw2_buy_manager.vendorSellsCheck(vendor, mapid, tabindex)
	gw2_buy_manager.vendoritemhistory[mapid] = gw2_buy_manager.vendoritemhistory[mapid] or {}
	gw2_buy_manager.vendoritemhistory[mapid][vendor.id] = gw2_buy_manager.vendoritemhistory[mapid][vendor.id] or {}
	gw2_buy_manager.vendoritemhistory[mapid][vendor.id][tabindex] = gw2_buy_manager.vendoritemhistory[mapid][vendor.id][tabindex] or {}
	
	if(not table.valid(gw2_buy_manager.vendoritemhistory[mapid][vendor.id][tabindex])) then
		local vendorSalvageItems = VendorItemList("itemtype="..GW2.ITEMTYPE.SalvageTool)
		if(table.valid(vendorSalvageItems)) then
			local salvagekits = {}
			for _,itemid in pairs(gw2_buy_manager.tools.salvage) do
				salvagekits[itemid] = itemid
			end
			
			for _,vitem in pairs(vendorSalvageItems) do
				if(salvagekits[vitem.itemid]) then
					gw2_buy_manager.vendoritemhistory[mapid][vendor.id][tabindex][vitem.itemid] = true
				end
			end
		end

		local vendorGatheringItems = VendorItemList("itemtype="..GW2.ITEMTYPE.Gathering)	
		if(table.valid(vendorGatheringItems)) then
			local gathertools = {}
			for _,itemid in pairs(gw2_buy_manager.tools.foraging) do
				gathertools[itemid] = itemid
			end
			
			for _,itemid in pairs(gw2_buy_manager.tools.mining) do
				gathertools[itemid] = itemid
			end
			
			for _,itemid in pairs(gw2_buy_manager.tools.logging) do
				gathertools[itemid] = itemid
			end
			
			for _,vitem in pairs(vendorGatheringItems) do
				if(gathertools[vitem.itemid]) then
					gw2_buy_manager.vendoritemhistory[mapid][vendor.id][tabindex][vitem.itemid] = true
				end
			end
		end
	end
	
	if(table.valid(gw2_buy_manager.vendoritemhistory[mapid][vendor.id][tabindex])) then
		local neededKits = gw2_buy_manager.GetNeededSalvageKitList()
		local neededTools = gw2_buy_manager.GetNeededGatheringToolList()				
			
		if(table.valid(neededKits)) then
			for itemid,_ in pairs(neededKits) do
				if(gw2_buy_manager.vendoritemhistory[mapid][vendor.id][tabindex][itemid]) then
					return true
				end
			end
		end
		if(table.valid(neededTools)) then
			for itemid,_ in pairs(neededTools) do
				if(gw2_buy_manager.vendoritemhistory[mapid][vendor.id][tabindex][itemid]) then
					return true
				end
			end
		end
	end
	return false
end

function gw2_buy_manager.setMapAvailablity(salvageItems,gatheringItems)
	for id,tool in pairs(gw2_buy_manager.salvagekits) do
		gw2_buy_manager.availableOnMap.salvage[id] = false
	end
	
	if(table.valid(salvageItems)) then
		for _,item in pairs(salvageItems) do
			for id,itemid in pairs(gw2_buy_manager.tools.salvage) do
				if (item.itemid == itemid) then gw2_buy_manager.availableOnMap.salvage[id] = true end
			end
		end
	end
	
	for id,tool in pairs(gw2_buy_manager.tooltypes) do
		gw2_buy_manager.availableOnMap.gathering[id] = false
	end
	
	if(table.valid(gatheringItems)) then
		for _,item in pairs(gatheringItems) do
			for id,itemid in pairs(gw2_buy_manager.tools.foraging) do
				if (item.itemid == itemid) then gw2_buy_manager.availableOnMap.gathering[id] = true end
			end
		end
	end
end

function gw2_buy_manager.NeedToBuySalvageKits(nearby)
	local settings = gw2_buy_manager.GetSettings()
	local neededKits = gw2_buy_manager.GetNeededSalvageKitList()
	for itemID,count in pairs(neededKits) do
		if (nearby == true and count > 0) then
			-- Buy if the vendor is nearby and we have less then the current setting left
			return true
		elseif (nearby ~= true) then
			-- Only buy if we have no kits left
			if (itemID == gw2_buy_manager.tools.salvage[gw2_buy_manager.SALVAGEKITS.Crude] and count == tonumber(settings.crudekit)) or
			(itemID == gw2_buy_manager.tools.salvage[gw2_buy_manager.SALVAGEKITS.Basic] and count == tonumber(settings.basickit)) or
			(itemID == gw2_buy_manager.tools.salvage[gw2_buy_manager.SALVAGEKITS.Fine] and count == tonumber(settings.finekit)) or
			(itemID == gw2_buy_manager.tools.salvage[gw2_buy_manager.SALVAGEKITS.Journeyman] and count == tonumber(settings.journeymankit)) or
			(itemID == gw2_buy_manager.tools.salvage[gw2_buy_manager.SALVAGEKITS.Master] and count == tonumber(settings.masterkit)) then
				return true
			end
		end
	end
	return false
end

function gw2_buy_manager.GetNeededSalvageKitList(nocache)
	if(nocache) then gw2_buy_manager.cache.salvagekits.timestamp = nil end
	
	if(gw2_buy_manager.cache.salvagekits.timestamp == nil or TimeSince(gw2_buy_manager.cache.salvagekits.timestamp) > 1000) then
		local settings = gw2_buy_manager.GetSettings()
		local neededKits = {}
		local salvagekits = gw2_buy_manager.tools.salvage
		
		if (tonumber(settings.crudekit) > 0 and gw2_buy_manager.availableOnMap.salvage[gw2_buy_manager.SALVAGEKITS.Crude]) then
			neededKits[salvagekits[gw2_buy_manager.SALVAGEKITS.Crude]] = tonumber(settings.crudekit)
		end
		
		if (tonumber(settings.basickit) > 0 and gw2_buy_manager.availableOnMap.salvage[gw2_buy_manager.SALVAGEKITS.Basic]) then
			neededKits[salvagekits[gw2_buy_manager.SALVAGEKITS.Basic]] = tonumber(settings.basickit)
		end
		
		if (tonumber(settings.finekit) > 0 and gw2_buy_manager.availableOnMap.salvage[gw2_buy_manager.SALVAGEKITS.Fine]) then
			neededKits[salvagekits[gw2_buy_manager.SALVAGEKITS.Fine]] = tonumber(settings.finekit)
		end
		
		if (tonumber(settings.journeymankit) > 0 and gw2_buy_manager.availableOnMap.salvage[gw2_buy_manager.SALVAGEKITS.Journeyman]) then
			neededKits[salvagekits[gw2_buy_manager.SALVAGEKITS.Journeyman]] = tonumber(settings.journeymankit)
		end
		
		if (tonumber(settings.masterkit) > 0 and gw2_buy_manager.availableOnMap.salvage[gw2_buy_manager.SALVAGEKITS.Master]) then
			neededKits[salvagekits[gw2_buy_manager.SALVAGEKITS.Master]] = tonumber(settings.masterkit)
		end
		
		local ownedKits = Inventory("itemtype=" .. GW2.ITEMTYPE.SalvageTool)
		for _,kit in pairs(ownedKits) do
			if (neededKits[kit.itemid]) then
				neededKits[kit.itemid] = neededKits[kit.itemid] - 1
			end
		end
		
		gw2_buy_manager.cache.salvagekits.timestamp = ml_global_information.Now
		gw2_buy_manager.cache.salvagekits.kits = neededKits
	end
	
	return gw2_buy_manager.cache.salvagekits.kits
end

function gw2_buy_manager.NeedToBuyGatheringTools(nearby)
	local neededTools = gw2_buy_manager.GetNeededGatheringToolList()
	local settings = gw2_buy_manager.GetSettings()
	
	for itemid,tool in pairs(neededTools) do
		if (nearby == true and tool.count > 0) then
			return true
		elseif (nearby ~= true and tool.count == tonumber(settings.toolstack)) then
			return true
		end
	end
	return false
end

function gw2_buy_manager.checkForInfTools(tool)
	if(1==1) then return false end
	 -- the stackcount is no longer 0 for unstackable. Weapontype seems to indicate unlim tools atm. Better then nothing.
	return (tool and tool.rarity == 4 and tool.weapontype == 1 and true or false) -- tool.stackcount == 0 and true or false)
end

function gw2_buy_manager.GetNeededGatheringToolList(nocache)
	if(nocache) then gw2_buy_manager.cache.gathertools.timestamp = nil end
	
	if(gw2_buy_manager.cache.gathertools.timestamp == nil or TimeSince(gw2_buy_manager.cache.gathertools.timestamp) > 1000) then
		local settings = gw2_buy_manager.GetSettings()
		local wantedTool = gw2_buy_manager.tooltypes[settings.tooltype]
		local neededTools = {}
		local wantedCount = tonumber(settings.toolstack)

		if(settings.tooltype ~= gw2_buy_manager.GATHERTOOLS.None) then
			local cityonly = wantedTool.cityonly
			
			if (wantedCount > 0 and gw2_buy_manager.availableOnMap.gathering[settings.tooltype] and wantedTool.minlevel <= ml_global_information.Player_Level) then
				local fTool = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.ForagingTool)
				local lTool = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.LoggingTool)
				local mTool = Inventory:GetEquippedItemBySlot(GW2.EQUIPMENTSLOT.MiningTool)

				if (gw2_buy_manager.checkForInfTools(fTool) == false) then
					neededTools[gw2_buy_manager.tools.foraging[settings.tooltype]] = {count = wantedCount, tooltype = wantedTool}
				end
				
				if (gw2_buy_manager.checkForInfTools(lTool) == false) then
					neededTools[gw2_buy_manager.tools.logging[settings.tooltype]] = {count = wantedCount, tooltype = wantedTool}
				end
				
				if (gw2_buy_manager.checkForInfTools(mTool) == false) then
					neededTools[gw2_buy_manager.tools.mining[settings.tooltype]] = {count = wantedCount, tooltype = wantedTool}
				end
				
				local ownedKits = Inventory("itemtype=" .. GW2.ITEMTYPE.Gathering)
				for _,tool in pairs(ownedKits) do
					if (neededTools[tool.itemid]) then
						neededTools[tool.itemid].count = neededTools[tool.itemid].count - 1
					end
				end
			end
		end
		
		gw2_buy_manager.cache.gathertools.timestamp = ml_global_information.Now
		gw2_buy_manager.cache.gathertools.tools = neededTools
	end
	return gw2_buy_manager.cache.gathertools.tools
end

function gw2_buy_manager.getClosestBuyMarker(nearby)
	local closestLocation = nil
	local listArg = (nearby == true and ",maxdistance=4000" or "")
	local markers = gw2_buy_manager.getMarkerList(listArg)
	if(table.valid(markers)) then
		for _,merchant in pairs(markers) do
			if (closestLocation == nil or closestLocation.distance > merchant.distance) then
				if (nearby == true and merchant.pathdistance < 4000) then
					closestLocation = merchant
				elseif (nearby ~= true) then
					closestLocation = merchant
				end
			end
		end
	end
	return closestLocation
end

function gw2_buy_manager.getMarkerList(filter)
	filter = filter or ""	
	local cid = ""
	local vendors = {}
	-- Get the vendors for special gathering tools
	local toollist = gw2_buy_manager.GetNeededGatheringToolList()
	if(table.valid(toollist)) then
		local merchants = {}
		for itemid,tool in pairs(toollist) do
			for _,merchant in pairs(tool.tooltype.merchant) do
				merchants[merchant] = merchant
			end
		end
		for _,contentid in pairs(merchants) do
			cid = string.add(cid, tostring(contentid), ";")
		end
	else
		for _,contentid in pairs(ml_global_information.VendorBuy) do
			cid = string.add(cid, tostring(contentid), ";")
		end			
	end

	local markers = MapMarkerList("onmesh,contentID="..cid..filter..",exclude_characterid="..gw2_blacklistmanager.GetExcludeString(GetString("Vendor buy")))
	if(table.valid(markers)) then
		return markers
	end
	
	return nil
end

function gw2_buy_manager.buyAtMerchant(vendor,mapid)
	if (gw2_buy_manager.lastVendorID == nil or gw2_buy_manager.lastVendorID ~= vendor.id ) then
		gw2_buy_manager.lastVendorID = vendor.id
		gw2_buy_manager.vendorbuyactivity = {}
		gw2_buy_manager.vendorbuyactivity.interactcount = 0
		gw2_buy_manager.vendorbuyactivity.tabindex = 0
		gw2_buy_manager.vendorbuyactivity.tabhistory = {}
	end
	
	if(gw2_buy_manager.vendorbuyactivity.interactcount > 15) then
		d(GetString("Vendor blacklisted: Tried interacting multiple times."))
		gw2_blacklistmanager.AddBlacklistEntry(GetString("Vendor buy"), vendor.id, vendor.name, true)			
	end
	
	if (Inventory:IsVendorOpened() == false and Player:IsConversationOpen() == false) then
		d(GetString("Opening Vendor").."...")
		Player:Interact(vendor.id)
		gw2_buy_manager.vendorbuyactivity.interactcount = gw2_buy_manager.vendorbuyactivity.interactcount + 1
		ml_global_information.Wait(1500)
		return true
	else
		local result = gw2_common_functions.handleConversation("buy")
		if (result == false) then
			d(GetString("Vendor blacklisted: Can not handle conversation."))
			gw2_blacklistmanager.AddBlacklistEntry(GetString("Vendor buy"), vendor.id, vendor.name, true)
			return false
		elseif (result == nil) then				
			ml_global_information.Wait(math.random(520,1200))
			return true
		end
	end

	if(VendorItemList.tabindexmax >= gw2_buy_manager.vendorbuyactivity.tabindex) then
		if(not gw2_buy_manager.vendorbuyactivity.tabhistory[gw2_buy_manager.vendorbuyactivity.tabindex] and gw2_buy_manager.vendorbuyactivity.tabindex ~= VendorItemList.tabindex) then
			d(GetString("Looking for the right tool tab"))
			Inventory:SetVendorServiceType(GW2.VENDORSERVICETYPE.VendorBuy, gw2_buy_manager.vendorbuyactivity.tabindex)
			ml_global_information.Wait(math.random(520,1200))
			return true
		end
		
		if (gw2_buy_manager.vendorSellsCheck(vendor,mapid,gw2_buy_manager.vendorbuyactivity.tabindex) == false) then
			gw2_buy_manager.vendorbuyactivity.tabhistory[gw2_buy_manager.vendorbuyactivity.tabindex] = false
			gw2_buy_manager.vendorbuyactivity.tabindex = gw2_buy_manager.vendorbuyactivity.tabindex + 1
			return true
		end
	end
	
	if(gw2_buy_manager.vendorbuyactivity.tabhistory[VendorItemList.tabindexmax] == false) then
		d(GetString("Vendor blacklisted: Does not have needed tools/kits."))
		gw2_blacklistmanager.AddBlacklistEntry(GetString("Vendor buy"), vendor.id, vendor.name, true)
		return false	
	end
	
	-- No cache when buying
	gw2_buy_manager.cache.gathertools.timestamp = nil
	gw2_buy_manager.cache.salvagekits.timestamp = nil
	
	return gw2_buy_manager.buyItems()
end

function gw2_buy_manager.buyItems()
	local vendorItems = VendorItemList("")
	local slowdown = math.random(0,3)
	if (table.valid(vendorItems) ) then
		if ( slowdown == 0) then

			local neededKits = gw2_buy_manager.GetNeededSalvageKitList(true)
			local neededTools = gw2_buy_manager.GetNeededGatheringToolList(true)				
			
			for _,item in pairs(vendorItems) do
				local itemID = item.itemid
				if ((neededKits[itemID] and neededKits[itemID] > 0) or (neededTools[itemID] and neededTools[itemID].count > 0)) then
					d(GetString("Buying")..": "..item.name)
					item:Buy()
					return true
				end
			end
			return true
		end
		gw2_buy_manager.vendorbuyactivity.interactcount = 0
		return true
	end
	
	return false
end
