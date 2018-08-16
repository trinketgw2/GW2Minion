-- Adds additional options to the Blacklistmanager in the minionlib
gw2_blacklistmanager = {}
gw2_blacklistmanager.ticks = 0
gw2_blacklistmanager.currentmapid = 0
gw2_blacklistmanager.lists = {}

function gw2_blacklistmanager.ModuleInit()
	gw2_blacklistmanager.lists[GetString("Vendor buy")] = ml_list_mgr.AddList(GetString("Vendor buy"), gw2_blacklistmanager.DrawVendor)
	gw2_blacklistmanager.lists[GetString("Vendor repair")] = ml_list_mgr.AddList(GetString("Vendor repair"), gw2_blacklistmanager.DrawVendor)
	gw2_blacklistmanager.lists[GetString("Vendor sell")] = ml_list_mgr.AddList(GetString("Vendor sell"), gw2_blacklistmanager.DrawVendor)
	gw2_blacklistmanager.lists[GetString("Sell items")] = ml_list_mgr.AddList(GetString("Sell items"), gw2_blacklistmanager.DrawInventory)		
	gw2_blacklistmanager.lists[GetString("Monsters")] = ml_list_mgr.AddList(GetString("Monsters"), gw2_blacklistmanager.DrawMonster)
	gw2_blacklistmanager.lists[GetString("Map objects")] = ml_list_mgr.AddList(GetString("Map objects"), gw2_blacklistmanager.DrawMonster)
	gw2_blacklistmanager.lists[GetString("Temporary Combat")] = ml_list_mgr.AddList(GetString("Temporary Combat"), gw2_blacklistmanager.DrawTemporaryCombat)
	
	local eventlist = ml_list_mgr.AddList(GetString("Event"), gw2_blacklistmanager.DrawEvent)
	eventlist.GUI.vars = { mapid = 0, name = "", pos = { x = 0, y = 0, z = 0}, id = 0, expiration_s = 0}
	gw2_blacklistmanager.lists[GetString("Event")] = eventlist
	
		-- Forcefully remove players
	if(gw2_blacklistmanager.lists[GetString("Monsters")]) then
		local tmpentries = ml_list_mgr.FindEntries(GetString("Monsters"),"id=42646")
		if(table.valid(tmpentries)) then
			for k,_ in pairs(tmpentries) do
				gw2_blacklistmanager.lists[GetString("Monsters")]:DeleteEntry(k)
			end
		end
	end
end
RegisterEventHandler("Module.Initalize",gw2_blacklistmanager.ModuleInit)

function gw2_blacklistmanager.OnUpdate(_,ticks)
	if(TimeSince(gw2_blacklistmanager.ticks) > 1000) then
		gw2_blacklistmanager.ticks = ticks
		
		local lists = {GetString("Temporary Combat"), GetString("Vendor sell"), GetString("Vendor repair"), GetString("Vendor buy")}
		
		if(gw2_blacklistmanager.currentmapid ~= ml_global_information.CurrentMapID) then
			gw2_blacklistmanager.currentmapid = ml_global_information.CurrentMapID
			
			-- Remove entries blacklisted by id if the map changes			
			for _,listname in pairs(lists) do
				if(gw2_blacklistmanager.lists[listname]) then
					local tmpentries = ml_list_mgr.FindEntries(listname,"expiration~=0,mapid~="..tostring(ml_global_information.CurrentMapID))
					if(table.valid(tmpentries)) then
						for k,_ in pairs(tmpentries) do
							gw2_blacklistmanager.lists[listname]:DeleteEntry(k)
						end
					end
				end
			end
		end
		
		-- check if an entry has an additional function that, if it evaluates to true will remove the entry from the list
		for _,listname in pairs(lists) do
			if(gw2_blacklistmanager.lists[listname]) then
				local tmpentries = ml_list_mgr.FindEntries(listname,"expiration~=0,mapid~="..tostring(ml_global_information.CurrentMapID))
				if(table.valid(tmpentries)) then
					for id,k in pairs(tmpentries) do
						if( k.removefunc and type(k.removefunc) == "function" and k.removefunc(k.id) == true)then
							gw2_blacklistmanager.lists[listname]:DeleteEntry(k)
						end
					end
				end
			end
		end
	end
end
RegisterEventHandler("Gameloop.Update", gw2_blacklistmanager.OnUpdate)

-- COMMON FUNCTIONS 

-- id can be ANYTHING. It's an identifier. Depends on the list.
-- Events use eventid, vendors use id, inventory items use itemid, monsters use both id and contentid.
-- Add an entry to listname.
function gw2_blacklistmanager.AddBlacklistEntry(listname, id, name, duration, removefromblacklistfunction)
	if(listname and id and table.valid(gw2_blacklistmanager.lists[listname])) then
		
		-- Force no permanent player blacklisting
		if (listname == GetString("Monsters") and id == 42646) then
			d("BLACKLISTING PLAYERS BY CONTENTID IS NOT ALLOWED.")
			return
		end
		
		-- Don't blacklist players for too long, else spvp and wvwvw are not working well
		if ( listname == GetString("Temporary Combat")) then
			if(type(duration) ~= "number" or duration < 1000) then duration = 5000 end
			
			if(duration > 5000) then
				local target = CharacterList:Get(id)
				if ( table.valid(target) and target.isplayer) then
					duration = 2500
				end
			end
		end
				
		duration = duration or 0
		if(type(duration) == "number" and duration > 0 and duration < ml_global_information.Now) then
			duration = ml_global_information.Now + duration
		end
		
		gw2_blacklistmanager.lists[listname]:AddEntry({id = id, name = name or "unknown", mapid = ml_global_information.CurrentMapID, expiration = duration, removefunc = removefromblacklistfunction})
	end
end

-- Get a semicolon delimited list of all entry ids from listname
function gw2_blacklistmanager.GetExcludeString(listname)
	local entries = ml_list_mgr.FindEntries(listname)
	local retval = ""

	if(table.valid(entries)) then
		for _,entry in pairs(entries) do
			retval = string.add(retval, tostring(entry.id), ";")
		end
	end

	return retval
end

-- Get the full monster blacklist string. (",exclude_contentid=monsters,exclude=temporary combat")
function gw2_blacklistmanager.GetMonsterExcludeString()
	local filterstring = ""
	local contentid_blacklist = gw2_blacklistmanager.GetExcludeString(GetString("Monsters"))
	local id_blacklist = gw2_blacklistmanager.GetExcludeString(GetString("Temporary Combat"))

	if (string.valid(contentid_blacklist)) then
		filterstring = filterstring..",exclude_contentid="..contentid_blacklist
	end
	
	if (string.valid(id_blacklist)) then
		filterstring = filterstring..",exclude="..id_blacklist
	end
	
	return filterstring
end

-- Check if an item exists in listname
function gw2_blacklistmanager.CheckBlacklistEntry(listname, id)
	if(listname and id) then
		return table.valid(ml_list_mgr.FindEntries(listname,"id="..id))
	end
	return false
end

-- DRAW FUNCTIONS

-- Draw monster list
gw2_blacklistmanager.temporaryMonsterEntryDuration = 0
function gw2_blacklistmanager:DrawMonster()
	GUI:Separator();
	
	GUI:Text(GetString("Blacklist") .. " " .. self.name)
	GUI:Text(GetString("Select a target then click the blacklist button"))
	GUI:Text(GetString("This will blacklist " .. string.lower(self.name) .. " of the same type"))
	GUI:Text(GetString("A duration of 0 is permanent"))
	
	GUI:Separator();
	
	gw2_blacklistmanager.temporaryMonsterEntryDuration = GUI:InputInt(GetString("Duration").." (s)", gw2_blacklistmanager.temporaryMonsterEntryDuration)
	if(type(gw2_blacklistmanager.temporaryMonsterEntryDuration) ~= "number" or gw2_blacklistmanager.temporaryMonsterEntryDuration < 0) then
		gw2_blacklistmanager.temporaryMonsterEntryDuration = 0
	end
	
	if(GUI:Button(GetString("Blacklist current target type"))) then

		local expiration = 0
		if(gw2_blacklistmanager.temporaryMonsterEntryDuration > 0) then
			expiration = ml_global_information.Now + gw2_blacklistmanager.temporaryMonsterEntryDuration*1000
		end
		
		local target = Player:GetTarget()
		if(table.valid(target)) then
			if(not target.isplayer) then
				self:AddEntry({id = target.contentid, name = target.name or "unknown", mapid = ml_global_information.CurrentMapID, expiration = expiration})
			else
				d("You cannot permanently blacklist players.")
			end
		else
			d("No target selected")
		end
	end
	
	GUI:Separator();
	GUI:Separator();
		-- Draw the list entries
	
	GUI:Spacing(5);
	GUI:Columns(5, "##listdetail-view", true)
	GUI:SetColumnOffset(1,100); GUI:SetColumnOffset(2,160); GUI:SetColumnOffset(3,260); GUI:SetColumnOffset(4,360);	GUI:SetColumnOffset(5,460);
	GUI:Text(GetString("Name")); GUI:NextColumn();
	GUI:Text(GetString("ID")); GUI:NextColumn();
	GUI:Text(GetString("Map ID")); GUI:NextColumn();
	GUI:Text(GetString("Duration")); GUI:NextColumn(); GUI:NextColumn();
	GUI:Separator();
	
	local entries = self.entries
	if (table.valid(entries)) then
		for i, entry in pairs(entries) do
			GUI:Text(entry.name); GUI:NextColumn();
			GUI:Text(entry.id); GUI:NextColumn();
			GUI:Text(entry.mapid); GUI:NextColumn();
			local expiration = tonumber(entry.expiration)
			if(type(expiration) ~= "number") then
				expiration = 0
			end
			
			if(expiration > 0) then
				expiration = math.ceil((expiration-ml_global_information.Now)/1000)
			end
			
			GUI:Text(tostring(expiration)); GUI:NextColumn();
			if (GUI:Button(GetString("Delete").."##"..i)) then
				self:DeleteEntry(i);
			end
			GUI:NextColumn();
		end
	end
end

-- Draw vendor list (repair/sell/buy)
gw2_blacklistmanager.temporaryVendorEntryDuration = 3600
function gw2_blacklistmanager:DrawVendor()
	GUI:Separator();
	GUI:Text(GetString("Blacklist") .. " " .. self.name)
	GUI:Text(GetString("These are temporary items. They will be removed when you change maps."))
	GUI:Separator();
	
	gw2_blacklistmanager.temporaryVendorEntryDuration = GUI:InputInt(GetString("Duration").." (s)", gw2_blacklistmanager.temporaryVendorEntryDuration)
	if(type(gw2_blacklistmanager.temporaryVendorEntryDuration) ~= "number" or gw2_blacklistmanager.temporaryVendorEntryDuration < 0) then
		gw2_blacklistmanager.temporaryVendorEntryDuration = 3600
	end
		
	if(GUI:Button(GetString("Blacklist current target"))) then
		local expiration = 0
		if(gw2_blacklistmanager.temporaryVendorEntryDuration > 0) then
			expiration = ml_global_information.Now + gw2_blacklistmanager.temporaryVendorEntryDuration*1000
		end
		
		local target = Player:GetTarget()
		if(table.valid(target)) then
			self:AddEntry({id = target.id, name = target.name or "unknown", mapid = ml_global_information.CurrentMapID, expiration = expiration})
		else
			d("No target selected")
		end
	end
	
	GUI:Separator();
	GUI:Separator();
		-- Draw the list entries
	
	GUI:Spacing(5);
	GUI:Columns(5, "##listdetail-view", true)
	GUI:SetColumnOffset(1,100); GUI:SetColumnOffset(2,160); GUI:SetColumnOffset(3,260); GUI:SetColumnOffset(4,360);	GUI:SetColumnOffset(5,460);
	GUI:Text(GetString("Name")); GUI:NextColumn();
	GUI:Text(GetString("ID")); GUI:NextColumn();
	GUI:Text(GetString("Map ID")); GUI:NextColumn();
	GUI:Text(GetString("Duration")); GUI:NextColumn(); GUI:NextColumn();
	GUI:Separator();
	
	local entries = self.entries
	if (table.valid(entries)) then
		for i, entry in pairs(entries) do
			GUI:Text(entry.name); GUI:NextColumn();
			GUI:Text(entry.id); GUI:NextColumn();
			GUI:Text(entry.mapid); GUI:NextColumn();
			local expiration = tonumber(entry.expiration)
			if(type(expiration) ~= "number") then
				expiration = 0
			end
			
			if(expiration > 0) then
				expiration = math.ceil((expiration-ml_global_information.Now)/1000)
			end
			
			GUI:Text(tostring(expiration)); GUI:NextColumn();
			if (GUI:Button(GetString("Delete").."##"..i)) then
				self:DeleteEntry(i);
			end
			GUI:NextColumn();
		end
	end
end

-- Draw temporary combat list
gw2_blacklistmanager.temporaryCombatEntryDuration = 10
function gw2_blacklistmanager:DrawTemporaryCombat()
	GUI:Separator();
	GUI:Text(GetString("Blacklist") .. " " .. self.name)
	GUI:Text(GetString("These are temporary items. Unique to a single monster."))
	GUI:Text(GetString("They will be removed in a few seconds or when you change maps."))
	GUI:Separator();
	
	gw2_blacklistmanager.temporaryCombatEntryDuration = GUI:InputInt(GetString("Duration").." (s)", gw2_blacklistmanager.temporaryCombatEntryDuration)
	if(type(gw2_blacklistmanager.temporaryCombatEntryDuration) ~= "number" or gw2_blacklistmanager.temporaryCombatEntryDuration < 1) then
		gw2_blacklistmanager.temporaryCombatEntryDuration = 10
	end
	
	if(GUI:Button(GetString("Blacklist current target"))) then

		local target = Player:GetTarget()
		if(table.valid(target)) then
			self:AddEntry({id = target.id, name = target.name or "unknown", mapid = ml_global_information.CurrentMapID, expiration = ml_global_information.Now + gw2_blacklistmanager.temporaryCombatEntryDuration*1000})
		else
			d("No target selected")
		end
	end
	
	GUI:Separator();
	GUI:Separator();
	-- Draw the list entries
	
	GUI:Spacing(5);
	GUI:Columns(5, "##listdetail-view", true)
	GUI:SetColumnOffset(1,100); GUI:SetColumnOffset(2,160); GUI:SetColumnOffset(3,260); GUI:SetColumnOffset(4,360);	GUI:SetColumnOffset(5,460);
	GUI:Text(GetString("Name")); GUI:NextColumn();
	GUI:Text(GetString("ID")); GUI:NextColumn();
	GUI:Text(GetString("Map ID")); GUI:NextColumn();
	GUI:Text(GetString("Duration")); GUI:NextColumn(); GUI:NextColumn();
	GUI:Separator();
	
	local entries = self.entries
	if (table.valid(entries)) then
		for i, entry in pairs(entries) do
			GUI:Text(entry.name); GUI:NextColumn();
			GUI:Text(entry.id); GUI:NextColumn();
			GUI:Text(entry.mapid); GUI:NextColumn();
			local expiration = tonumber(entry.expiration)
			if(type(expiration) ~= "number") then
				expiration = 0
			end
			
			if(expiration > 0) then
				expiration = math.ceil((expiration-ml_global_information.Now)/1000)
			end
			
			GUI:Text(tostring(expiration)); GUI:NextColumn();
			if (GUI:Button(GetString("Delete").."##"..i)) then
				self:DeleteEntry(i);
			end
			GUI:NextColumn();
		end
	end
end

-- Draw sellitems blacklist
gw2_blacklistmanager.inventoryIndexSelected = 1
gw2_blacklistmanager.inventoryLastCheck = 0
gw2_blacklistmanager.inventoryList = {}
function gw2_blacklistmanager:DrawInventory()
	local vars = self.GUI.vars
	
	GUI:Separator();
	GUI:Text(GetString("Blacklist") .. " " .. self.name)
	GUI:Text(GetString("Select an item in your inventory to blacklist from selling to vendors"))
	GUI:Separator();
	
	local useditems = {}
	if(table.valid(self.entries)) then
		for _,entry in pairs(self.entries) do
			useditems[entry.id] = true
		end
	end
		
	-- Don't update the inventory list all draw calls
	if(TimeSince(gw2_blacklistmanager.inventoryLastCheck) > 1000) then
		gw2_blacklistmanager.inventoryLastCheck = ml_global_information.Now

		local IList = Inventory("")
		

		if(table.valid(IList)) then
			local i = 1
			for _,item in pairs(IList) do	
				gw2_blacklistmanager.inventoryList[i] = {name = item.name; itemid = item.itemid}
				i = i + 1
			end
			table.sort(gw2_blacklistmanager.inventoryList, function(a,b) return string.lower(a.name) < string.lower(b.name) end)

		end
	end
	
	-- Draw the inventory combo
	if(table.valid(gw2_blacklistmanager.inventoryList)) then
		
		local comboList = {""}
		local itemList = {}
		
		for _,item in pairs(gw2_blacklistmanager.inventoryList) do
			if(not useditems[item.itemid]) then
				table.insert(comboList, item.name)
				table.insert(itemList, item)
				useditems[item.itemid] = true
			end
		end
		
		-- Reset the index if the last item was the last in the list
		local n_comboList = table.size(comboList)
		if(gw2_blacklistmanager.inventoryIndexSelected > n_comboList) then
			gw2_blacklistmanager.inventoryIndexSelected = n_comboList
		end
		
		GUI:Text(GetString("Inventory")..":")
		gw2_blacklistmanager.inventoryIndexSelected = GUI:Combo("##Inventory", gw2_blacklistmanager.inventoryIndexSelected, comboList)
		if(gw2_blacklistmanager.inventoryIndexSelected > 1) then
			GUI:SameLine()
			if(GUI:Button(GetString("Add to blacklist"))) then
				local item = itemList[gw2_blacklistmanager.inventoryIndexSelected-1]
				if(item) then
					self:AddEntry({id = item.itemid, name = item.name or "unknown", expiration = 0})
					gw2_blacklistmanager.inventoryLastCheck = 0
				end
			end
		end
	end
	
	GUI:Separator();
	GUI:Separator();
	
	-- Draw the list entries
	
	GUI:Spacing(4);
	GUI:Columns(4, "##listdetail-view", true)
	GUI:SetColumnOffset(1,100); GUI:SetColumnOffset(2,160); GUI:SetColumnOffset(3,260); GUI:SetColumnOffset(4,360);
	GUI:Text(GetString("Name")); GUI:NextColumn();
	GUI:Text(GetString("Item ID")); GUI:NextColumn();
	GUI:Text(GetString("Duration")); GUI:NextColumn(); GUI:NextColumn();
	GUI:Separator();
	
	local entries = self.entries
	if (table.valid(entries)) then
		for i, entry in pairs(entries) do
			GUI:Text(entry.name); GUI:NextColumn();
			GUI:Text(entry.id); GUI:NextColumn();
			GUI:Text(tostring(entry.expiration)); GUI:NextColumn();
			if (GUI:Button(GetString("Delete").."##"..i)) then
				self:DeleteEntry(i);
				gw2_blacklistmanager.inventoryLastCheck = 0
			end
			GUI:NextColumn();
		end
	end
end

-- Draw event blacklist
function gw2_blacklistmanager:DrawEvent()
	local vars = self.GUI.vars
	
	ml_gui.DrawTabs(self.GUI.main_tabs)
	GUI:Separator();
	
	GUI:Spacing(5);
	
	-- dbk: Add
	if (self.GUI.main_tabs.tabs[1].isselected) then
		if (GUI:Button(GetString("Pull nearest event details"))) then
			local MList = MapMarkerList("nearest,isevent")
			if(table.valid(MList)) then
				local _,marker = next(MList)
				if(table.valid(marker)) then
					vars.mapid, vars.id, vars.name, vars.expiration_s = Player.localmapid, marker.eventid, marker.name or "unknown", math.ceil((ml_global_information.Now + 7200000)/1000)
				end
			end

		end
		
		GUI:PushItemWidth(150)
		GUI:Text(GetString("Map ID:")); GUI:SameLine(100); 
		vars.mapid = GUI:InputText("##listdetail-mapid",vars.mapid)
		GUI:Text(GetString("Event ID:")); GUI:SameLine(100); 
		vars.id = GUI:InputText("##listdetail-id",vars.id)
		GUI:Text(GetString("Name:")); GUI:SameLine(100);
		vars.name = GUI:InputText("##listdetail-name",vars.name)
		GUI:Text(GetString("Duration: (s)")); GUI:SameLine(100); 
		vars.expiration_s = GUI:InputInt("##listdetail-expiration",vars.expiration_s)
		GUI:PopItemWidth()
		
		if (GUI:Button(GetString("Add Entry"))) then
			local details = { id = vars.id, mapid = vars.mapid, name = vars.name, expiration = vars.expiration_s*1000, expiration_s = vars.expiration_s }
			self:AddEntry(details)
		end
	end
	
	-- dbk: Edit
	if (self.GUI.main_tabs.tabs[2].isselected) then
	
		GUI:Separator();
		GUI:Columns(4, "##listdetail-view", true)
		GUI:SetColumnOffset(1,100); GUI:SetColumnOffset(2,160); GUI:SetColumnOffset(3,260); GUI:SetColumnOffset(4,360);
		GUI:Text(GetString("Name")); GUI:NextColumn();
		GUI:Text(GetString("Map ID")); GUI:NextColumn();
		GUI:Text(GetString("Event ID")); GUI:NextColumn(); GUI:NextColumn();
		GUI:Separator();
		
		local entries = self.entries
		if (table.valid(entries)) then
			for i, entry in pairs(entries) do
				GUI:Text(entry.name); GUI:NextColumn();
				GUI:Text(entry.mapid); GUI:NextColumn();
				GUI:Text(entry.id); GUI:NextColumn();
				if (GUI:Button(GetString("Delete"))) then
					self:DeleteEntry(i); 
				end
				GUI:NextColumn();
			end
		end
		
		GUI:Columns(1)
	end	
end
