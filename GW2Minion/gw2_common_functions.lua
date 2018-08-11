gw2_common_functions = {}

function gw2_common_functions.HasBuffs(entity, buffIDs)
    if ( entity ) then
		local buffs = entity.buffs
		if(table.valid(buffs)) then
			return gw2_common_functions.BufflistHasBuffs(buffs, buffIDs)
		end
	end
    return false
end

function gw2_common_functions.BufflistHasBuffs(bufflist, buffIDs)

	if(table.valid(bufflist) == false) then return false end
	
	if(table.valid(buffIDs)) then
		local buffstr = ""
		for buffID,_ in pairs(buffIDs) do
			buffstr = string.add(buffstr, tostring(buffID), ",")
		end
		buffIDs = buffstr
	end
	
	for _orids in string.split(tostring(buffIDs),",") do
		local found = false
		if(string.valid(_orids)) then
			for _andid in string.split(_orids,"+") do
					found = false
				for i, buff in pairs(bufflist) do

					if (buff.id == tonumber(_andid)) then
						found = true
					end
				end
				if (not found) then
					break
				end
			end
		end
		if (found) then
			return true
		end
	end
    return false
end

function gw2_common_functions.CountConditions(bufflist)
	local count = 0
	if ( bufflist ) then
		for _,buff in pairs(bufflist) do
			local bskID = buff.id
			if ( bskID and ml_global_information.ConditionsEnum[bskID] ~= nil) then
				count = count + 1
			end
		end
	end
	return count
end

function gw2_common_functions.CountBoons(bufflist)
	local count = 0
	if ( bufflist ) then
		for _,buff in pairs(bufflist) do
			local bskID = buff.id
			if ( bskID and ml_global_information.BoonsEnum[bskID] ~= nil) then
				count = count + 1
			end
		end
	end
	return count
end

function gw2_common_functions.NecroLeaveDeathshroud()
	if (Player.profession == 8 ) then
		local deathshroud = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_13)
		if ( deathshroud ~= nil and (deathshroud.skillid == 10585 or deathshroud.skillid == 30961 ) and Player:GetCurrentlyCastedSpell() == ml_global_information.MAX_SKILLBAR_SLOTS ) then
			Player:CastSpell(GW2.SKILLBARSLOT.Slot_13)
			return true
		end
	end
	return false
end

function gw2_common_functions.GetPartyMemberByName( name )
	local partylist = ml_global_information.Player_Party
	if (table.valid(partylist)) then
		local i, member  = next( partylist )
		while i and member do
			if (member.name == name) then
				return member
			end
			i, member  = next(partylist, i)
		end
	end
	return nil
end

function gw2_common_functions.MoveOnlyStraightForward()
	if ( Player:IsMoving() ) then
		local movdirs = Player:GetMovement()
		if (movdirs.left) then
			Player:UnSetMovement(2)
			return true
		elseif (movdirs.right) then
			Player:UnSetMovement(3)
			return true
		end
	end
	return false
end

function gw2_common_functions.FinishEnemy()
	if ( ml_global_information.Player_IsMoving == false and ml_global_information.Player_Health.percent > 15 ) then
		local EList = CharacterList("nearest,downed,attackable,interactable,selectable,maxdistance=175")
		if ( EList ) then
			local id,entity = next (EList)
			if ( id and entity ) then
				if ( entity.isininteractrange ) then
					local target = Player:GetTarget()
					if ( not target or target.id ~= entity.id ) then
						Player:SetTarget(entity.id)
					end
					Player:Interact( entity.id )
					return true
				end
			end
		end
	end
	return false
end

-- Get the nearest waypoint to a certain position
-- mapid = the map you want to get a waypoint for
-- pos = near this position
-- mapid_pos = if the position is in another map then the target mapid, set this to the mapid of the position
-- For example if you want to get the nearest waypoint from your current position to another map
function gw2_common_functions.GetClosestWaypointToPos(mapid,pos,mapid_pos)
	local waypoint = nil
	local mapData = gw2_datamanager.GetLocalWaypointListByDistance(mapid,pos,mapid_pos)
	if (table.valid(mapData)) then
		local i,wdata = next(mapData)
		while wdata and not waypoint do
			if (not wdata.contested and wdata.onmesh and wdata.discovered) then
				waypoint = wdata
			end
			
			i,wdata = next(mapData,i)
		end
	end
	return waypoint
end

-- Traverse the map navigation path (in reverse) and find the closest available waypoint to your intended target
function gw2_common_functions.GetClosestWaypointToMap(targetMapID, currentMapID)

	currentMapID = currentMapID ~= nil and currentMapID or ml_global_information.CurrentMapID
	local pos = ml_global_information.Player_Pos

	if(targetMapID ~= nil) then	
		local currNode = ml_nav_manager.GetNode(currentMapID)
		local destNode = ml_nav_manager.GetNode(targetMapID)
		
		if(currNode and destNode) then
			-- Walk the path in reverse to see if any close maps have waypoints
			local navPath = ml_nav_manager.GetPath(destNode, currNode)

			if(table.valid(navPath)) then
				local prevNode = nil
				local closestWaypoint = nil
				
				local i,node = next(navPath)
				while i and node and not closestWaypoint do
					if(prevNode == nil) then
						-- Target map
						local _,nextNode = next(navPath, i)
						if(nextNode and nextNode.neighbors and table.valid(nextNode.neighbors[node.id])) then
							local entryPos = nextNode.neighbors[node.id][1]
							local waypointlist = gw2_datamanager.GetLocalWaypointListByDistance(node.id, entryPos, nextNode.id)
							if (table.valid(waypointlist)) then
								closestWaypoint = select(2,next(waypointlist))
							end
						end
					else
						if(node.neighbors and table.valid(node.neighbors[prevNode.id])) then
							local exitPos = node.neighbors[prevNode.id][1]
							local waypointlist = gw2_datamanager.GetLocalWaypointListByDistance(node.id, exitPos)
							if (table.valid(waypointlist)) then
								closestWaypoint = select(2,next(waypointlist))
							end
						end
					end
					
					prevNode = node
					i,node = next(navPath, i)
				end
				
				if(table.valid(closestWaypoint)) then
					return closestWaypoint
				end
			end
		end
	end
	
	return nil
end

-- Gets all targets (Characters and Gadgets) from filterstring
function gw2_common_functions.GetAllTargets(filterstring)
	filterstring = string.valid(filterstring) and filterstring or ""
	
	local mergedList = {}
	
	local CList = CharacterList(filterstring)
	local GList = GadgetList(filterstring)
	
	if(table.valid(CList)) then
		for _,character in pairs(CList) do
			table.insert(mergedList, character)
		end
	end
	
	if(table.valid(GList)) then
		for _,gadget in pairs(GList) do
			table.insert(mergedList, gadget)
		end
	end
	
	return mergedList
end

-- Tries to get a "best target" to attack
function gw2_common_functions.GetBestCharacterTarget( maxrange )
		
	local range = maxrange
	if ( range == nil ) then
		range = ml_global_information.AttackRange
	end

	if ( range < 200 ) then range = 750 end -- extend search range a bit for melee chars

	local hostileCheck = Settings.GW2Minion.ignoreyellowmobs and "hostile," or ""

	local target = gw2_common_functions.GetCharacterTargetExtended("aggro,onmesh,nearest,los,maxdistance="..tostring(range))

	if (target == nil) then target = gw2_common_functions.GetCharacterTargetExtended("onmesh," .. hostileCheck .. "nearest,los,maxdistance="..tostring(range)) end

	if (target == nil) then target = gw2_common_functions.GetCharacterTargetExtended("aggro,onmesh,nearest") end

	if (target == nil) then target = gw2_common_functions.GetCharacterTargetExtended("onmesh," .. hostileCheck .. "nearest") end

	if (target == nil and not Settings.GW2Minion.ignoreyellowmobs) then target = gw2_common_functions.GetCharacterTargetExtended("onmesh,nearest,los,maxlevel=15") end

	if (target == nil and not Settings.GW2Minion.ignoreyellowmobs) then target = gw2_common_functions.GetCharacterTargetExtended("onmesh,nearest,maxlevel=15") end

	if(table.valid(target) and (not target.attackable or not target.isreachable)) then
		gw2_blacklistmanager.AddBlacklistEntry(GetString("Temporary Combat"), target.id, target.name, 5000, gw2_common_functions.BlackListUntilReachableAndAttackable)
		d("[GetBestCharacterTarget] - Blacklisting "..target.name.." ID: "..tostring(target.id))
		target = nil
	end
		
	if ( target and target.id ) then
		if ( target.distance < 1500 and target.los ) then
			Player:SetTarget(target.id)
		end
		return target
	else

		local currTarget = Player:GetTarget()
		if ( currTarget ~= nil and currTarget.attackable and currTarget.alive and currTarget.onmesh and currTarget.isreachable) then
			return target
		end
	end
	return nil
end
-- Tries to get a "best target" to attack for assist mode (maxdistance limited)
function gw2_common_functions.GetBestCharacterTargetForAssist( )
	
	gw2_common_functions.useCustomSMFilterSettings = true
	
	-- Ignore yellow check.
	local hostileCheck = Settings.GW2Minion.ignoreyellowmobs and ",hostile" or ""
	-- Try to get Enemy with los in range first
	local target = gw2_common_functions.GetCharacterTargetExtended("maxdistance="..tostring(ml_global_information.AttackRange).. hostileCheck .. ",los")
	
	-- Try to get downed enemy
	if(target == nil) then target = gw2_common_functions.GetCharacterTargetExtended("maxdistance="..tostring(ml_global_information.AttackRange).. hostileCheck .. ",los", GW2.HEALTHSTATE.Downed) end	
	-- Try to get Enemy without los in range
	if (target == nil) then target = gw2_common_functions.GetCharacterTargetExtended("maxdistance="..tostring(ml_global_information.AttackRange) .. hostileCheck) end
	-- Try to get Enemy without los in range + 250
	if (target == nil) then target = gw2_common_functions.GetCharacterTargetExtended("maxdistance="..tostring(ml_global_information.AttackRange + 250) .. hostileCheck) end
	-- 
	if (target == nil and not Settings.GW2Minion.ignoreyellowmobs) then target = gw2_common_functions.GetCharacterTargetExtended("maxdistance="..tostring(ml_global_information.AttackRange) .. "onmesh,nearest,los,maxlevel=15") end
	-- 
	if (target == nil and not Settings.GW2Minion.ignoreyellowmobs) then target = gw2_common_functions.GetCharacterTargetExtended("maxdistance="..tostring(ml_global_information.AttackRange) .. "onmesh,nearest,maxlevel=15") end

	gw2_common_functions.useCustomSMFilterSettings = nil

	if ( target and target.id ) then
		if ( target.distance < 1600 and target.los ) then
			Player:SetTarget(target.id)
		end
		return target
	else

		local currTarget = Player:GetTarget()
		if ( currTarget ~= nil and currTarget.attackable ) then
			return target
		end
	end
	return nil
end
-- Tries to get a "best aggro target" to attack
function gw2_common_functions.GetBestAggroTarget(healthstate)
	local range = ml_global_information.AttackRange or 750
	
	if ( range < 200 ) then range = 750 end -- extend search range a bit for melee chars
	if ( range > 1000 ) then range = 1000 end -- limit search range a bit for ranged chars
	
	-- Try to get Aggro Enemy Players with los in range first
	local target = gw2_common_functions.GetCharacterTargetExtended("player,onmesh,lowesthealth,los,maxdistance="..tostring(range), healthstate)

	if ( not target ) then target = gw2_common_functions.GetCharacterTargetExtended("player,onmesh,nearest,maxdistance="..tostring(range*2), healthstate) end
	
	-- Try to get Aggro Enemy with los in range first
	if ( not target ) then target = gw2_common_functions.GetCharacterTargetExtended("aggro,onmesh,lowesthealth,los,maxdistance="..tostring(range), healthstate) end

	-- Try to get Aggro Enemy
	if ( not target ) then target = gw2_common_functions.GetCharacterTargetExtended("aggro,onmesh,nearest") end
	
	if(table.valid(target) and (not target.attackable or not target.isreachable)) then
		gw2_blacklistmanager.AddBlacklistEntry(GetString("Temporary Combat"), target.id, target.name, 5000, gw2_common_functions.BlackListUntilReachableAndAttackable)
		d("[GetBestAggroTarget] - Blacklisting "..target.name.." ID: "..tostring(target.id))
		target = nil
	end
	
	if ( target and target.id ) then
		if ( target.distance < 1500 and target.los ) then
			Player:SetTarget(target.id)
		end
		return target
	else

		local currTarget = Player:GetTarget()
		if ( currTarget ~= nil and currTarget.attackable and currTarget.aggro and currTarget.isreachable) then
			return currTarget
		end
	end
	return nil
end

-- Find the best event targets.
-- Filters mobs based on distance (and path distance) to the event center
function gw2_common_functions.GetBestEventTarget(marker,objectivedetails,radius)
	local filters = {
		"aggro,onmesh,lowesthealth,los",
		"aggro,onmesh,shortestpath",
		"aggro,onmesh,nearest",
		"hostile,onmesh,nearest"
	}
	
	if(table.valid(marker) and type(radius) == "number") then
		
		-- If the target can be found in the objective details, use that (event is target)
		if(table.valid(objectivedetails) and objectivedetails.value1) then
			local target = CharacterList:Get(objectivedetails.value1) or GadgetList:Get(objectivedetails.value1)
			if(table.valid(target) and target.alive and target.attackable and not gw2_blacklistmanager.IsMonsterBlacklisted(target) and target.pathdistance < 9999999) then
				return target
			end
		end
		
		-- Find mobs
		local i,filter = next(filters)
		while i and filter do
			local target = gw2_common_functions.GetCharacterTargetExtended(filter)

			if(table.valid(target)) then
				if((target.alive or target.downed) and target.isreachable) then
					local dist = math.distance3d(target.pos,marker.pos)
					if(dist <= radius) then
						local path = NavigationManager:GetPath(marker.pos.x,marker.pos.y,marker.pos.z,target.pos.x,target.pos.y,target.pos.z)
						local pdist = math.huge
						if(table.valid(path)) then pdist = PathDistance(path) end
						
						if(pdist <= radius) then
							return target
						end
					end

					gw2_blacklistmanager.AddBlacklistEntry(GetString("Temporary Combat"), target.id, target.name, 5000)
					d("[GetBestEventTarget] - Blacklisting "..target.name.." ID: "..tostring(target.id) .. ", out of event radius.")						
				else					
					if ( not target.isplayer ) then -- don't blacklist players which are dead for 90sec..stupid in spvp WHY THE FUCK IS PVP USING THE PVE EVENT TARGET FUNCTION
						gw2_blacklistmanager.AddBlacklistEntry(GetString("Temporary Combat"), target.id, target.name, 5000)
						d("[GetBestEventTarget] - Blacklisting "..target.name.." ID: "..tostring(target.id))
					end
				end
			end
			
			i,filter = next(filters,i)
		end
		
		-- Find attackable gadgets
		local GList = GadgetList("hostile,attackable,alive,onmesh,shortestpath"..gw2_blacklistmanager.GetMonsterExcludeString())
		if(table.valid(GList)) then
			local _,gagdet = next(GList)
			if(table.valid(gadget)) then
				if(gagdet.alive and gadget.pathdistance < 9999999) then
					local dist = math.distance3d(gagdet.pos,marker.pos)
					if(dist <= radius) then
						local path = NavigationManager:GetPath(marker.pos.x,marker.pos.y,marker.pos.z,gagdet.pos.x,gagdet.pos.y,gagdet.pos.z)
						local pdist = math.huge
						if(table.valid(path)) then pdist = PathDistance(path) end
						
						if(pdist <= radius) then
							return gagdet
						end
					end

					gw2_blacklistmanager.AddBlacklistEntry(GetString("Temporary Combat"), gagdet.id, gagdet.name, 5000)
					d("[GetBestEventTarget] - Blacklisting "..gagdet.name.." ID: "..tostring(gagdet.id) .. ", out of event radius.")
				else
					gw2_blacklistmanager.AddBlacklistEntry(GetString("Temporary Combat"), gagdet.id, gagdet.name, 5000)
					d("[GetBestEventTarget] - Blacklisting "..gagdet.name.." ID: "..tostring(gagdet.id))
				end
			end
		end
	end
	
	return nil
end

function gw2_common_functions.GetCharacterTargetExtended( filterstring, healthstate )
    
	if ( filterstring ) then
		filterstring = filterstring..",attackable,nocritter"
	else
		filterstring = "attackable,nocritter"
	end

	if(healthstate == nil or healthstate == GW2.HEALTHSTATE.Alive) then
		filterstring = filterstring..",alive"
	elseif(healthstate == GW2.HEALTHSTATE.Downed) then
		filterstring = filterstring..",downed"
	end

	-- Only in AssistMode we want to allow these settings	
	if ( gw2_common_functions.useCustomSMFilterSettings ) then
		if (Settings.GW2Minion.smmode == 2) then filterstring = filterstring..",player" end		-- Attackmode for Assist : 1 = Everything, 2 = Players
		if (Settings.GW2Minion.smtargetmode == 2) then filterstring = filterstring..",lowesthealth" end
		if (Settings.GW2Minion.smtargetmode == 3) then filterstring = filterstring..",nearest" end
		if (Settings.GW2Minion.smtargetmode == 4) then filterstring = filterstring..",clustered=600" end
	end
	
	filterstring = filterstring..gw2_blacklistmanager.GetMonsterExcludeString()

	local TargetList = CharacterList(filterstring)
	if ( TargetList ) then
		local id,entry = next(TargetList)
		if (id and entry ) then
		
			if(not gw2_common_functions.HasBuffs(entry,ml_global_information.InvulnerabilityConditions)) then
				return entry
			else
				d("[GetCharacterTargetExtended] - Target has invulnerability conditions. Blacklisting "..entry.name.." ID: "..tostring(entry.id))
				gw2_blacklistmanager.AddBlacklistEntry(GetString("Temporary Combat"), entry.id, entry.name, 5000)
			end
		end
	end
	return nil
end

-- Downed state target needs to be a bit different and ignore assist settings
function gw2_common_functions.GetBestDownstateTarget()
	local filterstring = gw2_blacklistmanager.GetMonsterExcludeString()
	
	local CList = CharacterList("player,attackable,lowesthealth,los,maxdistance=900"..filterstring)
	if ( not table.valid(CList)) then
		CList = CharacterList("aggro,attackable,lowesthealth,los,maxdistance=900"..filterstring)
	end
	if(table.valid(CList)) then
		local _,target = next(CList)
		if(table.valid(target) and (target.alive or target.downed)) then
			return target
		end
	end
	return nil
end

gw2_common_functions.vendorHistory = {
	LastID = 0,
	EntryTime = 0,
	repair = 0,
	Shop=0,
	KarmaShop=0,
	Continue=0,
	Story=0,
	Return=0,
}
function gw2_common_functions.handleConversation(result)
	if (Player:IsConversationOpen() and (Inventory:IsVendorOpened() == false or result == "repair") and string.valid(result)) then
		local curVendor = Player:GetTarget()
		-- Reset the conversationHistory when we got a new or different vendorMarker
		if (curVendor and curVendor.id and (gw2_common_functions.vendorHistory.LastID ~= curVendor.id or TimeSince(gw2_common_functions.vendorHistory.EntryTime) > 60000)) then
			gw2_common_functions.vendorHistory = {
				LastID = curVendor.id,
				EntryTime = ml_global_information.Now,
				Repair = 0,
				Shop=0,
				KarmaShop=0,
				Continue=0,
				Story=0,
				Return=0,
			}
		end

		local options = Player:GetConversationOptions()
		if (options) then
			-- for sell&buy order: #shop , #karmashop, #repair, #Story, #Continue, #Back, #Close
			-- for repair order: #repair, #Story, #Continue, #Back, #Close
			for index=0, #options do
				local conversation = options[index]
				if (conversation.type == GW2.CONVERSATIONOPTIONS.Repair and result == "repair" and gw2_common_functions.vendorHistory["Repair"] < 5) then
					-- Repair is almost always the first option and repair is often the wrong type
					if(gw2_common_functions.vendorHistory["Repair"] < 2) then
						Player:SelectConversationOptionByIndex(0)
					else
						Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Repair)
					end
					
					gw2_common_functions.vendorHistory["Repair"] = gw2_common_functions.vendorHistory["Repair"] + 1
					return true
				elseif (conversation.type == GW2.CONVERSATIONOPTIONS.Shop and (result == "sell" or result == "buy") and gw2_common_functions.vendorHistory["Shop"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Shop)
					gw2_common_functions.vendorHistory["Shop"] = gw2_common_functions.vendorHistory["Shop"] + 1
					return
				elseif (conversation.type == GW2.CONVERSATIONOPTIONS.KarmaShop and result == "sell" and gw2_common_functions.vendorHistory["KarmaShop"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.KarmaShop)
					gw2_common_functions.vendorHistory["KarmaShop"] = gw2_common_functions.vendorHistory["KarmaShop"] + 1
					return
				end
			end
			for index=0, #options do -- this is needed because NPCs often have the GW2.CONVERSATIONOPTIONS.Repair ID although they are offering vendoring
				local conversation = options[index]
				if (conversation.type == GW2.CONVERSATIONOPTIONS.Repair and (result == "sell" or result == "buy") and gw2_common_functions.vendorHistory["Repair"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Repair)
					gw2_common_functions.vendorHistory["Repair"] = gw2_common_functions.vendorHistory["Repair"] + 1
					return
				end
			end
			for index=0, #options do
				local conversation = options[index]
				if (conversation.type == GW2.CONVERSATIONOPTIONS.Continue and gw2_common_functions.vendorHistory["Continue"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Continue)
					gw2_common_functions.vendorHistory["Continue"] = gw2_common_functions.vendorHistory["Continue"] + 1
					return
				elseif (conversation.type == GW2.CONVERSATIONOPTIONS.Story and gw2_common_functions.vendorHistory["Story"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Story)
					gw2_common_functions.vendorHistory["Story"] = gw2_common_functions.vendorHistory["Story"] + 1
					return
				elseif (conversation.type == GW2.CONVERSATIONOPTIONS.Return and gw2_common_functions.vendorHistory["Return"] < 5) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Return)
					gw2_common_functions.vendorHistory["Return"] = gw2_common_functions.vendorHistory["Return"] + 1
					return
				end
			end
			for index=0, #options do
				local conversation = options[index]
				if (conversation.type == GW2.CONVERSATIONOPTIONS.Close) then
					Player:SelectConversationOption(GW2.CONVERSATIONOPTIONS.Close)
					return false
				end
			end
		end
	elseif (Inventory:IsVendorOpened() and string.valid(result)) then
		if (result == "buy") then
			if (Inventory:GetVendorServiceType() == GW2.VENDORSERVICETYPE.VendorBuy) then
				return true
			else
				Inventory:SetVendorServiceType(GW2.VENDORSERVICETYPE.VendorBuy)
			end
		elseif (result == "sell") then
			if (Inventory:GetVendorServiceType() == GW2.VENDORSERVICETYPE.VendorSell) then
				return true
			else
				Inventory:SetVendorServiceType(GW2.VENDORSERVICETYPE.VendorSell)
			end
		end
	end
end

function gw2_common_functions.GetTargetByID(targetID)
	return CharacterList:Get(targetID) or GadgetList:Get(targetID)
end

function gw2_common_functions.GetProfessionName(profession)
	profession = profession or Player.profession or 10
	if (type(profession) == "number" and profession < 10) then
		local name = table.invert(GW2.CHARCLASS)[profession]
		if (string.valid(name)) then
			return name
		end
	end
	return "NoClass"
end

-- return true/false if player is in an instance (only works for dungeons and normal instances, not while using "home instance stone" or "hall of monuments portal stone") 
function gw2_common_functions.PlayerInInstance()
	local partyInfo = ml_global_information.Player_Party
	if (table.valid(partyInfo)) then
		for _,member in pairs(partyInfo) do
			if (member.id == ml_global_information.Player_ID and member.isunknown1 ~= nil and member.isunknown1 ~= 0) then
				return true
			end
		end
	end
	return false
end

-- Can move in direction(dir=0->7).
function gw2_common_functions.CanMoveDirection(direction,distance)
	if (direction and type(direction) == "number") then
		local forwardLeft,forwardRight,backwardLeft,backwardRight = 4,5,6,7
		local directionToDegree = {[GW2.MOVEMENTTYPE.Forward] = 0, [GW2.MOVEMENTTYPE.Backward] = 180, [GW2.MOVEMENTTYPE.Left] = 270, [GW2.MOVEMENTTYPE.Right] = 90, [forwardLeft] = 315, [forwardRight] = 45, [backwardLeft] = 225, [backwardRight] = 135,}
		local stepSize = 25
		local steps = distance / stepSize
		for step=1,steps do
			if (Player:CanMoveDirection(directionToDegree[direction],(stepSize*step)) == false) then
				return false
			end
		end
		return true
	end
	return false
end

-- Can evade in direction(dir=0->7).
function gw2_common_functions.CanEvadeDirection(direction)
	if (direction and type(direction) == "number") then
		local stepSize = 15
		local steps = 350 / stepSize
		for step=1,steps do
			if (Player:CanEvade(direction,(stepSize*step)) == false) then
				return false
			end
		end
		return true
	end
	return false
end

-- Evade(dir=0->7).
gw2_common_functions.lastEvade = 0
function gw2_common_functions.Evade(direction)
	if (ml_global_information.Player_Health.percent < Settings.GW2Minion.evadehpthreshold and ml_global_information.Player_Endurance >= 50) then
		local evadeTarget = false
		if (type(direction) ~= "number") then
			local aggroTargets = CharacterList("aggro,alive,attackable,maxdistance=2000")
			
			if ( not table.valid(aggroTargets)) then  -- TODO: only check this if there can be hostile players. -- and PvPManager:IsInMatch()) then -- needa similar wvwvw check.
				aggroTargets = CharacterList("player,attackable,alive,los,maxdistance=1200")
			end
			
			if (table.valid(aggroTargets)) then
				for _,target in pairs(aggroTargets) do
					local cinfo = target.castinfo
					if (table.valid(cinfo) and cinfo.targetid == ml_global_information.Player_ID and cinfo.slot ~= ml_global_information.MAX_SKILLBAR_SLOTS and ml_global_information.Player_CastInfo.duration == 0 and TimeSince(gw2_common_functions.lastEvade) > 1500) then
						evadeTarget = true
						break
					end
				end
			end
		end
		if ((type(direction) == "number" and direction ~= 3) or evadeTarget) then -- silly fix, but SM uses direction 3 to evade towards a target, while unstuck uses 4 and 5 to evade left n right. But we want it only to evade when being attacked
			direction = tonumber(direction) or math.random(0,7)
			if (gw2_common_functions.CanEvadeDirection(direction)) then
				Player:Evade(direction)
				gw2_common_functions.lastEvade = ml_global_information.Now
				return true
			end
		end
		return false
	end
end

-- heading to radian.
function gw2_common_functions.headingToRadian(pos)
	if (table.valid(pos)) then
		local radian = math.atan2(pos.hx,pos.hy)
		if (radian < 0) then radian = radian + math.pi * 2 end
		return radian
	end
end

-- radian to degrees.
function gw2_common_functions.radianToDegrees(radian)
	local degrees = ((radian * 180) / math.pi) + 90
	if (degrees > 360) then
		degrees = degrees - 360
	end
	return degrees
end

-- get differance in degrees.
function gw2_common_functions.getDegreeDiffTargets(targetIDA,targetIDB) -- gw2_common_functions.getDegreeDiffTargets(targetID,Player.id) player relative to target.
	local targetA = CharacterList:Get(targetIDA) or GadgetList:Get(targetIDA)
	local targetB = CharacterList:Get(targetIDB) or GadgetList:Get(targetIDB)
	if (table.valid(targetA) and table.valid(targetB)) then
		local radianA = gw2_common_functions.headingToRadian(targetA.pos)
		local degreeA = gw2_common_functions.radianToDegrees(radianA)
		local radianB = math.atan2(targetB.pos.x - targetA.pos.x, targetB.pos.y - targetA.pos.y)
		local degreeB = gw2_common_functions.radianToDegrees(radianB)
		local diffDegree = degreeB - degreeA
		if (targetA.isGadget or targetB.isGadget) then diffDegree = diffDegree - 90 end
		if (diffDegree < 0) then diffDegree = 360 + diffDegree end
		return diffDegree
	end
end

-- Filter entity list by relative position.
function gw2_common_functions.filterRelativePostion(entityList,dir)
	local returnList = {}
	if (table.valid(entityList)) then
		local playerID = Player.id
		for _,entity in pairs(entityList) do
			if (table.valid(entity.pos)) then
				local diffDegree = gw2_common_functions.getDegreeDiffTargets(playerID, entity.id)
				--local degrees = {[0] = 0, [1] = 45, [2] = 90, [3] = 135, [4] = 180, [5] = 225, [6] = 270, [7] = 315,}
				local forwardLeft,forwardRight,backwardLeft,backwardRight = 4,5,6,7
				local directionToDegree = {[GW2.MOVEMENTTYPE.Forward] = 0, [GW2.MOVEMENTTYPE.Backward] = 180, [GW2.MOVEMENTTYPE.Left] = 270, [GW2.MOVEMENTTYPE.Right] = 90, [forwardLeft] = 315, [forwardRight] = 45, [backwardLeft] = 225, [backwardRight] = 135,}
				local minDegree = directionToDegree[dir] - 22.5 < 0 and 360 - 22.5 or directionToDegree[dir] - 22.5
				local maxDegree = directionToDegree[dir] + 22.5 > 360 and 0 + 22.5 or directionToDegree[dir] + 22.5
				if (tonumber(minDegree) < tonumber(maxDegree) and tonumber(diffDegree) >= tonumber(minDegree) and tonumber(diffDegree) <= tonumber(maxDegree)) then
					table.insert(returnList,entity)
				elseif (tonumber(minDegree) > tonumber(maxDegree) and (tonumber(diffDegree) >= tonumber(minDegree) or tonumber(diffDegree) <= tonumber(maxDegree))) then
					table.insert(returnList,entity)
				end
			end
		end
	end
	return returnList
end

-- Check if there is a valid path between startpos and targetpos.
function gw2_common_functions.ValidPath(startpos,targetpos,allowpartialpath)
	if(table.valid(startpos) and table.valid(targetpos)) then
		local path = NavigationManager:GetPath(startpos.x,startpos.y,startpos.z,targetpos.x,targetpos.y,targetpos.z,false)
		if(table.valid(path)) then
			
			if(allowpartialpath) then
				return true
			end
			
			-- No partial path allowed, so check if the last entry is at the target position
			local n_path = table.size(path)
			if(n_path > 1) then
				if(path[n_path-1].type == "PARTIAL_PATH") then
					return false
				end
			end
			
			return true
		end

	end
	
	return false
end

-- Try to get a random position on the mesh around targetpos and check if it is reachable by the bot
function gw2_common_functions.GetRandomPointOnCircle(targetpos, min, max, maxtries)
	maxtries = type(maxtries) == "number" and maxtries or 1
	
	local trycount = 0
	while trycount < maxtries do
		trycount = trycount + 1
		
		local pos = NavigationManager:GetRandomPointOnCircle(targetpos.x, targetpos.y, targetpos.z, min, max)
		if(table.valid(pos)) then
			-- Try to get a pos about the same height as the player
			local heightdiff = ml_global_information.Player_Position.z - pos.z
			if((heightdiff < 50 and heightdiff > -50) and gw2_common_functions.ValidPath(ml_global_information.Player_Position,pos)) then
				return pos
			end
		end
	end
	
	return nil
end

-- Get a random position on the map.
-- First try the levelmap, then try to get a position from markers, then any random position on the mesh around the player
gw2_common_functions.randompointsused = {}
function gw2_common_functions.GetRandomPoint()
	if(not gw2_common_functions.randompointsused[ml_global_information.CurrentMapID]) then
		gw2_common_functions.randompointsused = {}
		gw2_common_functions.randompointsused[ml_global_information.CurrentMapID] = {}
	end
	
	local randompointsused = gw2_common_functions.randompointsused[ml_global_information.CurrentMapID]
	
	-- Check if the position has been recently used. If it has, ignore it.
	local function _validpos(pos)
		if (not table.valid(pos)) then return false end
		
		for i,existing in ipairs(randompointsused) do
			if(TimeSince(existing.time) > 1800000) then table.remove(randompointsused, i) end
			
			-- The position is too close to a recently used randompos, ignore it.
			if(math.distance3d(existing.pos,pos) < 500) then
				return false
			end
		end
		
		return true
	end
	
	-- Make sure that the position is reachable by the bot
	local function _validpath(pos)
		if(table.valid(pos)) then
			return NavigationManager:IsReachable(pos.x,pos.y,pos.z)
		end
		return false
	end
	
	local randompos = nil
	
	-- 1st try
	if (table.valid(gw2_datamanager.levelmap)) then
		d("Trying to find a random point from the level map")
		local pos = gw2_datamanager.GetRandomPositionInLevelRange(ml_global_information.Player_Level)
		if(_validpos(pos)) then
			if(_validpath(pos)) then
				randompos = pos
			else
				table.insert(randompointsused, {pos = pos, time = ml_global_information.Now, status = "no valid path", type = "levelmap"})
			end
		end
	end
	
	-- 2nd try
	if(randompos == nil) then
		d("Trying to find a random point from markers")
		local MList = MapMarkerList("onmesh,mindistance=5000")
		if(table.valid(MList)) then
			local i, MList_n = 0, table.size(MList)
			while not randompos and i < (MList_n > 10 and 10 or MList_n) do
				local marker = table.randomvalue(MList)
				if(table.valid(marker) and _validpos(marker.pos)) then
					if(_validpath(marker.pos)) then
						randompos = marker.pos
					else
						table.insert(randompointsused, {pos = marker.pos, time = ml_global_information.Now, status = "no valid path", type = "marker"})
					end
				end
				i = i + 1
			end
		end
	end
	
	-- 3rd try
	if (randompos == nil) then
		d("Trying to find a random point anywhere on the mesh")
		local i = 0
		while not randompos and i < 10 do
			local pos = NavigationManager:GetRandomPoint(5000) -- 5000 beeing mindistance to player
			if (_validpos(pos)) then
				if(_validpath(pos)) then
					randompos = pos
				else
					table.insert(randompointsused, {pos = pos, time = ml_global_information.Now, status = "no valid path", type = "randompoint"})
				end
			end
			i = i + 1
		end
	end
	
	if (table.valid(randompos)) then
		table.insert(randompointsused, {pos = randompos, time = ml_global_information.Now, status = "used", type = "valid"})
		return randompos
	end
	
	d("No random point found")
	
	return nil
end

gw2_common_functions.combatmovement = {
	combat = false,
	range = false,
	allowed = true,
}

function gw2_common_functions:DoCombatMovement(target)
	
	local fightdistance = ml_global_information.AttackRange or 154
	
	if (self.combatmovement.range and (target == nil or ( target.distance < fightdistance and target.los))) then d("CombatMovement: InRange, Stopping..") Player:StopMovement() self.combatmovement.range = false end  -- "range" is "moving into combat range"
	
	if ( table.valid(target) and target.distance <= fightdistance and target.alive and ml_global_information.Player_Alive and ml_global_information.Player_OnMesh) then -- and ml_global_information.Player_Health.percent < 99
		local isimmobilized	= gw2_common_functions.BufflistHasBuffs(ml_global_information.Player_Buffs, ml_global_information.ImmobilizeConditions)

		if (not isimmobilized) then		
			local forward,backward,left,right,forwardLeft,forwardRight,backwardLeft,backwardRight = GW2.MOVEMENTTYPE.Forward,GW2.MOVEMENTTYPE.Backward,GW2.MOVEMENTTYPE.Left,GW2.MOVEMENTTYPE.Right,4,5,6,7
			local currentMovement = ml_global_information.Player_MovementDirections
			local movementDirection = {[forward] = true, [backward] = true,[left] = true,[right] = true,}
			local tDistance = target.distance
			
			-- Stop walking into range.
			-- if (self.combatmovement.range and tDistance < fightdistance - 250) then Player:StopMovement() self.combatmovement.range = false end  -- "range" is "moving into combat range"
			-- Face target.
			local tpos = target.pos
			Player:SetFacingExact(tpos.x, tpos.y, tpos.z)
			-- Range, walking too close to enemy, stop walking forward.
			if (fightdistance > 300 and tDistance < fightdistance) then movementDirection[forward] = false end
			-- Range, walking too far from enemy, stop walking backward.
			if (fightdistance > 300 and tDistance > fightdistance * 0.95) then movementDirection[backward] = false end
			-- Melee, walking too close to enemy, stop walking forward.
			if (tDistance < target.radius) then movementDirection[forward] = false end
			-- Melee, walking too far from enemy, stop walking backward.
			if (fightdistance <= 300 or tDistance > fightdistance) then movementDirection[backward] = false end
			-- We are strafing too far from target, stop walking left or right. We are in a melee fight, moving around the target just makes us spin.
			if (tDistance > fightdistance or tDistance < 250) then
				movementDirection[left] = false
				movementDirection[right] = false
			end
			-- Can we move in direction, while staying on the mesh.
			if (movementDirection[forward] and gw2_common_functions.CanMoveDirection(forward,400) == false) then movementDirection[forward] = false end
			if (movementDirection[backward] and gw2_common_functions.CanMoveDirection(backward,400) == false) then movementDirection[backward] = false end
			if (movementDirection[left] and gw2_common_functions.CanMoveDirection(left,400) == false) then movementDirection[left] = false end
			if (movementDirection[right] and gw2_common_functions.CanMoveDirection(right,400) == false) then movementDirection[right] = false end
			--
			if (movementDirection[forward]) then
				if (movementDirection[left] and gw2_common_functions.CanMoveDirection(forwardLeft,300) == false) then
					movementDirection[left] = false
				end
				if (movementDirection[right] and gw2_common_functions.CanMoveDirection(forwardRight,300) == false) then
					movementDirection[right] = false
				end
			elseif (movementDirection[backward]) then
				if (movementDirection[left] and gw2_common_functions.CanMoveDirection(backwardLeft,300) == false) then
					movementDirection[left] = false
				end
				if (movementDirection[right] and gw2_common_functions.CanMoveDirection(backwardRight,300) == false) then
					movementDirection[right] = false
				end
			end

			-- Can we move in direction, while not walking towards potential enemy's.
			local targets = CharacterList("alive,los,notaggro,attackable,hostile,exclude="..target.id)

			if (movementDirection[forward] and table.size(gw2_common_functions.filterRelativePostion(targets,forward)) > 0) then movementDirection[forward] = false end
			if (movementDirection[backward] and table.size(gw2_common_functions.filterRelativePostion(targets,backward)) > 0) then movementDirection[backward] = false end
			if (movementDirection[left] and table.size(gw2_common_functions.filterRelativePostion(targets,left)) > 0) then movementDirection[left] = false end
			if (movementDirection[right] and table.size(gw2_common_functions.filterRelativePostion(targets,right)) > 0) then movementDirection[right] = false end
			--
			if (movementDirection[forward]) then
				if (movementDirection[left] and table.size(gw2_common_functions.filterRelativePostion(targets,forwardLeft)) > 0) then
					movementDirection[left] = false
				end
				if (movementDirection[right] and table.size(gw2_common_functions.filterRelativePostion(targets,forwardRight)) > 0) then
					movementDirection[right] = false
				end
			elseif (movementDirection[backward]) then
				if (movementDirection[left] and table.size(gw2_common_functions.filterRelativePostion(targets,backwardLeft)) > 0) then
					movementDirection[left] = false
				end
				if (movementDirection[right] and table.size(gw2_common_functions.filterRelativePostion(targets,backwardRight)) > 0) then
					movementDirection[right] = false
				end
			end

			-- We know where we can move, decide where to go.
			if (movementDirection[forward] and movementDirection[backward]) then -- Can move forward and backward, choose.
				
				-- Range, try to stay back from target.
				if (fightdistance > 300) then
					movementDirection[forward] = false
					if (tDistance >= fightdistance - 250) then
						movementDirection[backward] = false
					end
				end
				-- Melee, try to stay close to target.
				if (fightdistance <= 300) then
					movementDirection[backward] = false
					if (tDistance <= fightdistance) then
						movementDirection[forward] = false
					end
				end
				
			end
			if (movementDirection[left] and movementDirection[right]) then -- Can move left and right, choose.
				if (currentMovement.left) then -- We are moving left already.
					if (math.random(0,250) ~= 3) then -- Keep moving left gets higher chance.
						movementDirection[right] = false
					else
						movementDirection[left] = false
					end
				elseif (currentMovement.right) then -- We are moving right already.
					if (math.random(0,250) ~= 3) then -- Keep moving right gets higher chance.
						movementDirection[left] = false
					else
						movementDirection[right] = false
					end
				end
			end

			-- Execute combat movement.
			for direction,canMove in pairs(movementDirection) do
				if (canMove) then
					Player:SetMovement(direction)
				else
					Player:UnSetMovement(direction)
				end
			end
			self.combatmovement.combat = true
			return
		-- cant move anyway, stop trying.
		else
			d("Combatmovement: cant move anyway, stop trying.")
			Player:StopMovement()
			self.combatmovement.combat = false
		end
	
	elseif(self.combatmovement.combat) then -- Stop active combat movement.		 
		d("Combatmovment:Stop active combat movement.")
		Player:StopMovement()
		self.combatmovement.combat = false
	end
end
function gw2_common_functions:GetCombatMovement() 
	return self.combatmovement
end
function gw2_common_functions:CombatMovementCanMove()
	return not self.combatmovement.combat
end
function gw2_common_functions:StopCombatMovement()
	self.combatmovement.combat = false
	self.combatmovement.range = false
	self.combatmovement.allowed = true
	Player:StopHorizontalMovement()
end

-- used in the combathandler to blacklist players until they are reachable and not just by a flat silly duration, that breaks the fast paced logic in spvp
gw2_common_functions.BlackListUntilReachableAndAttackable = function(id)
	local target = CharacterList:Get(id)
	return not target or (target.isreachable and target.attackable)
end

-- Input manager functions specific for gw2.
function gw2_common_functions.toggleBot()
	if (GetGameState() == GW2.GAMESTATE.GAMEPLAY and NavigationManager:GetNavMeshState() == GLOBAL.MESHSTATE.MESHREADY) then
		if (BehaviorManager:Running()) then
			BehaviorManager:Stop()
			Player:StopMovement()
		else
			BehaviorManager:Start()
		end
	end
end

ml_input_mgr.registerFunction({
		name = GetString("Toggle Bot"),
		func = gw2_common_functions.toggleBot,
	}
)
