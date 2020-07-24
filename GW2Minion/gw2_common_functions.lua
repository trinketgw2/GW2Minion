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
			if(table.valid(target) and target.alive and target.attackable and not gw2_blacklistmanager.IsMonsterBlacklisted(target) and target.isreachable) then
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
						local pdist = NavigationManager:GetPathDistance(marker.pos,target.pos)

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
				if(gagdet.alive and gadget.isreachable) then
					local dist = math.distance3d(gagdet.pos,marker.pos)
					if(dist <= radius) then
						local pdist = NavigationManager:GetPathDistance(marker.pos,gagdet.pos)

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

-- return true/false if player is in an instance ('else' Part only works for dungeons and normal instances, not while using "home instance stone" or "hall of monuments portal stone") 
function gw2_common_functions.PlayerInInstance()
    if table.valid(gw2_datamanager.mapData[ml_global_information.CurrentMapID]) then
        return gw2_datamanager.mapData[ml_global_information.CurrentMapID].type == "Instance"
    else
        local partyInfo = ml_global_information.PlayerParty
        if (table.valid(partyInfo)) then
            for _,member in pairs(partyInfo) do
                if (member.id == ml_global_information.Player_ID and member.isunknown1 ~= nil and member.isunknown1 ~= 0) then
                    return true
                end
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

-- get difference in degrees.
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

-- get unit vector.
function gw2_common_functions.normalize(pos)
	local magnitude = math.sqrt(pos.x * pos.x + pos.y * pos.y)

	if magnitude == 1 then
		return pos
	elseif magnitude > 1e-5 then
		pos.x = pos.x / magnitude
		pos.y = pos.y / magnitude
	else
		pos.x = 0
		pos.y = 0
	end

	return pos
end

-- get shorter turning direction. origin and heading from player.
function gw2_common_functions.getTurnDirection(targetPos)
	local origin = Player and Player.pos
	if (table.valid(origin) and table.valid(targetPos)) then
		local endHeading = gw2_common_functions.normalize({ x = targetPos.x - origin.x, y = targetPos.y - origin.y })
		local bearingCurrentHeading = math.deg(math.tan(origin.hy / origin.hx))
		local bearingGoalHeading = math.deg(math.tan(endHeading.y / endHeading.x))
		local delta = (bearingGoalHeading - bearingCurrentHeading + 540) % 360 - 180
		return delta < 0 and GW2.MOVEMENTTYPE.TurnLeft or GW2.MOVEMENTTYPE.TurnRight
	end
end

-- get absolute angle with interval of [0,180]
function gw2_common_functions.angle2DToTargetInDeg(origin,heading,target)
	local currentHeading = gw2_common_functions.normalize(heading)
	local goalHeading = gw2_common_functions.normalize({ x = target.x - origin.x, y = target.y - origin.y })
	local currentHeadingDotGoalHeading = (currentHeading.x * goalHeading.x) + (currentHeading.y * goalHeading.y)
	local currentHeadingDotcurrentHeading = (currentHeading.x * currentHeading.x) + (currentHeading.y * currentHeading.y)
	local goalHeadingDotGoalHeading = (goalHeading.x * goalHeading.x) + (goalHeading.y * goalHeading.y)
	return math.acos(currentHeadingDotGoalHeading / math.sqrt(currentHeadingDotcurrentHeading * goalHeadingDotGoalHeading)) * 180 / math.pi
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
		return NavigationManager:IsReachable(startpos,targetpos)
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
			local maxblacklistduration = existing.pvp and 300000 or 1800000 -- 5 min, 30 min
			if(TimeSince(existing.time) > maxblacklistduration) then table.remove(randompointsused, i) end
			
			-- The position is too close to a recently used randompos, ignore it.
			if(math.distance3d(existing.pos,pos) < 2000) then
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
		d("[gw2_common_functions]: Trying to find a random point from the level map")
		local pos = gw2_datamanager.GetRandomPositionInLevelRange(ml_global_information.Player_Level)
		if(_validpos(pos)) then
			if(_validpath(pos)) then
				d(string.format("[gw2_common_functions]: Random point found in level map. Distance: %s, pos = {x=%s;y=%s;z=%s}", math.round(math.distance3d(pos,ml_global_information.Player_Position)), math.round(pos.x,2), math.round(pos.y,2), math.round(pos.z,2)))
				randompos = pos
			else
				table.insert(randompointsused, {pos = pos, pvp = ml_global_information.Player_InPVPArea, time = ml_global_information.Now, status = "no valid path", type = "levelmap"})
			end
		end
	end

	-- 2nd try
	if(randompos == nil) then
		d("[gw2_common_functions]: Trying to find a random point from markers")
		local MList = MapMarkerList("onmesh,mindistance=5000")
		if(table.valid(MList)) then
			-- Only try a few markers
			local i, MList_n = 0, table.size(MList)
			while not randompos and i < (MList_n > 10 and 10 or MList_n) do
				local marker = table.randomvalue(MList)
				if(table.valid(marker) and _validpos(marker.pos)) then
					if(_validpath(marker.pos)) then
						d(string.format("[gw2_common_functions]: Random point found in markers. Distance: %s, pos = {x=%s;y=%s;z=%s}", math.round(math.distance3d(marker.pos,ml_global_information.Player_Position)), math.round(marker.pos.x,2), math.round(marker.pos.y,2), math.round(marker.pos.z,2)))
						randompos = marker.pos
					else
						table.insert(randompointsused, {pos = marker.pos, pvp = ml_global_information.Player_InPVPArea, time = ml_global_information.Now, status = "no valid path", type = "marker"})
					end
				end
				i = i + 1
			end
		end
	end
	
	-- 3rd try
	if (randompos == nil and ml_global_information.Player_SwimState == GW2.SWIMSTATE.NotInWater) then
		d("[gw2_common_functions]: Trying to find a random point anywhere on the mesh")
		local i = 0
		while not randompos and i < 10 do
			local pos = NavigationManager:GetRandomPoint(5000) -- 5000 beeing mindistance to player
			if (_validpos(pos)) then
				if(_validpath(pos)) then
					d(string.format("[gw2_common_functions]: Random point found on the mesh. Distance: %s, pos = {x=%s;y=%s;z=%s}", math.round(math.distance3d(pos,ml_global_information.Player_Position)), math.round(pos.x,2), math.round(pos.y,2), math.round(pos.z,2)))
					randompos = pos
				else
					table.insert(randompointsused, {pos = pos, pvp = ml_global_information.Player_InPVPArea, time = ml_global_information.Now, status = "no valid path", type = "randompoint"})
				end
			end
			i = i + 1
		end
	end

	if (table.valid(randompos)) then
		table.insert(randompointsused, {pos = randompos, pvp = ml_global_information.Player_InPVPArea, time = ml_global_information.Now, status = "used", type = "valid"})
		return randompos
	end
	
	d("[gw2_common_functions]: No random point found")
	
	return nil
end

-- used in the combathandler to blacklist players until they are reachable and not just by a flat silly duration, that breaks the fast paced logic in spvp
gw2_common_functions.BlackListUntilReachableAndAttackable = function(id)
	local target = CharacterList:Get(id)
	return not target or (target.isreachable and target.attackable)
end

-- Input manager functions specific for gw2.
function gw2_common_functions.toggleBot()
	if (GetGameState() == GW2.GAMESTATE.GAMEPLAY) then
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

-- Mount Toggles
gw2_common_functions.Mount = {
	enum = {
		Beetle = 50908,
		Griffon = 44590,
		Jackal = 40215,
		Raptor = 41378,
		Skimmer = 40509,
		Skyscale = 55715,
		Springer = 41731,
		Warclaw = 54871,
	}
}

function gw2_common_functions.Mount.Griffon()
	if not Player.mounted then
		Player:SelectMount(gw2_common_functions.Mount.enum.Griffon)
		Player:Mount()
	else
		Player:Dismount()
	end
end
ml_input_mgr.registerFunction({
		name = GetString("Mount Griffon"),
		func = gw2_common_functions.Mount.Griffon,
	}
)

function gw2_common_functions.Mount.Jackal()
	if not Player.mounted then
		Player:SelectMount(gw2_common_functions.Mount.enum.Jackal)
		Player:Mount()
	else
		Player:Dismount()
	end
end
ml_input_mgr.registerFunction({
		name = GetString("Mount Jackal"),
		func = gw2_common_functions.Mount.Jackal,
	}
)

function gw2_common_functions.Mount.Raptor()
	if not Player.mounted then
		Player:SelectMount(gw2_common_functions.Mount.enum.Raptor)
		Player:Mount()
	else
		Player:Dismount()
	end
end
ml_input_mgr.registerFunction({
		name = GetString("Mount Raptor"),
		func = gw2_common_functions.Mount.Raptor,
	}
)

function gw2_common_functions.Mount.Beetle()
	if not Player.mounted then
		Player:SelectMount(gw2_common_functions.Mount.enum.Beetle)
		Player:Mount()
	else
		Player:Dismount()
	end
end
ml_input_mgr.registerFunction({
		name = GetString("Mount Roller Beetle"),
		func = gw2_common_functions.Mount.Beetle,
	}
)

function gw2_common_functions.Mount.Skimmer()
	if not Player.mounted then
		Player:SelectMount(gw2_common_functions.Mount.enum.Skimmer)
		Player:Mount()
	else
		Player:Dismount()
	end
end
ml_input_mgr.registerFunction({
		name = GetString("Mount Skimmer"),
		func = gw2_common_functions.Mount.Skimmer,
	}
)

function gw2_common_functions.Mount.Skyscale()
	if not Player.mounted then
		Player:SelectMount(gw2_common_functions.Mount.enum.Skyscale)
		Player:Mount()
	else
		Player:Dismount()
	end
end
ml_input_mgr.registerFunction({
		name = GetString("Mount Skyscale"),
		func = gw2_common_functions.Mount.Skyscale,
	}
)

function gw2_common_functions.Mount.Springer()
	if not Player.mounted then
		Player:SelectMount(gw2_common_functions.Mount.enum.Springer)
		Player:Mount()
	else
		Player:Dismount()
	end
end
ml_input_mgr.registerFunction({
		name = GetString("Mount Springer"),
		func = gw2_common_functions.Mount.Springer,
	}
)

function gw2_common_functions.Mount.Warclaw()
	if not Player.mounted then
		Player:SelectMount(gw2_common_functions.Mount.enum.Warclaw)
		Player:Mount()
	else
		Player:Dismount()
	end
end
ml_input_mgr.registerFunction({
		name = GetString("Mount Warclaw"),
		func = gw2_common_functions.Mount.Warclaw,
	}
)
