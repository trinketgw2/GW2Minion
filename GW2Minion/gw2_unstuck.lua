gw2_unstuck = {}
gw2_unstuck.gui = {open = false; visible = false; name = GetString("Unstuck")}
gw2_unstuck.updatetick = 0
gw2_unstuck.stucktick = 0
gw2_unstuck.stuckhistory = {}
gw2_unstuck.movementtype = { forward = false; backward = false; swimpup = false; swimdown = false; }
gw2_unstuck.statuscodes = {
	ENTRY_NOT_HANDLED = 1;
	ENTRY_HANDLED = 2;
	STOP_BOT = 3;
}
gw2_unstuck.version = 1

function gw2_unstuck.Start()
	d("[Unstuck]: Started")
	gw2_unstuck.Stop()
end

-- Reset all unstuck variables
function gw2_unstuck.Stop()
	gw2_unstuck.laststuckentry = nil
	gw2_unstuck.laststuckposition = nil
	gw2_unstuck.usedwaypointlasttick = {
		id = nil;
		pos = nil;
		lastplayerpos = nil;
		timestamp = 0;
	}

	gw2_unstuck.lastposition = nil
	gw2_unstuck.lastonmeshposition = nil
	gw2_unstuck.lastraycastdetails = nil
	gw2_unstuck.distmoved = 0
	gw2_unstuck.offmeshwptrycount = 0
	gw2_unstuck.offmeshwptrytime = ml_global_information.Now
	gw2_unstuck.lasttimeonmesh = ml_global_information.Now

	-- Set to true if the player is expected to handle jumping and stuff themselves (like in assist start)
	gw2_unstuck.manualcontrolmode = false
	
	gw2_unstuck.Reset()
end

-- Reset some basic unstuck variables
function gw2_unstuck.Reset()
	gw2_unstuck.lastaction = nil
	gw2_unstuck.stuckcount = 0
	gw2_unstuck.threshold = Settings.GW2Minion.stuckthreshold
	gw2_unstuck.lastresult = false
	gw2_unstuck.pathblockingobject = nil
	gw2_unstuck.STUCKTYPE = "onmesh"

	if(ml_global_information.Player_OnMesh) then 
		gw2_unstuck.offmeshwptrytime = ml_global_information.Now
		gw2_unstuck.offmeshwptrycount = 0
		gw2_unstuck.lasttimeonmesh = ml_global_information.Now
	end
	
	for k,movementtype in pairs(gw2_unstuck.movementtype) do
		if(movementtype) then Player:UnSetMovement(movementtype) end
		gw2_unstuck.movementtype[k] = false
	end
	
	-- Specify a unstuck_mode before the navigation call to handle unstuck diffrently. Currently not used
	gw2_unstuck.unstuck_mode = nil
end

-- Only reset position for now
function gw2_unstuck.SoftReset()
	-- Set position to be over the current threshold so it doesn't trigger unstuck next tick
	local threshold = gw2_unstuck.ActiveThreshold() + 1
	local ppos = Player.pos
	
	gw2_unstuck.lastposition = {x=ppos.x + threshold; y = ppos.y; z = ppos.z} 
	gw2_unstuck.lastaction = nil
	--gw2_unstuck.stucktick = ml_global_information.Now
end

function gw2_unstuck.HandleStuck()
	-- Throttle
	if(gw2_unstuck.stucktick > 0 and TimeSince(gw2_unstuck.stucktick) < 150 ) then
		return gw2_unstuck.lastresult
	end
	
	gw2_unstuck.stucktick = ml_global_information.Now
	
	-- Don't handle unstuck
	if(gw2_unstuck.manualcontrolmode) then
		gw2_unstuck.Reset()
		gw2_unstuck.lastresult = false
		return gw2_unstuck.lastresult		
	end
	
	if(not ml_global_information.Player_Alive) then
		gw2_unstuck.Reset()
		gw2_unstuck.lastresult = true
		return gw2_unstuck.lastresult
	end
	
	if(not ml_global_information.Player_CanMove) then
		gw2_unstuck.lastresult = true
		return gw2_unstuck.lastresult
	end
	
	-- Make sure we are actually in the game and not a cutscene 
	if(ml_global_information.GameState ~= GW2.GAMESTATE.GAMEPLAY) then
		gw2_unstuck.lastresult = true
		return gw2_unstuck.lastresult
	end
	
	-- Frostbite (Locked in ice)
	if(gw2_common_functions.HasBuffs(Player, "37211")) then		
		local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
		if(skill and skill.cooldown == 0) then
			Player:CastSpell(GW2.SKILLBARSLOT.Slot_1)
			-- Throttle the cast so it doesn't go on cooldown without getting out
			gw2_unstuck.stucktick = ml_global_information.Now + 250
		end
		gw2_unstuck.lastresult = true
		return gw2_unstuck.lastresult
	end
	
	-- Check conditions
	if(gw2_common_functions.HasBuffs(Player, ml_global_information.ImmobilizeConditions)) then
		gw2_unstuck.lastresult = true
		return gw2_unstuck.lastresult
	end
	
	-- Check if we used a waypoint last time, then wait a bit.
	if(gw2_unstuck.usedwaypointlasttick.id) then
		
		if(not ml_global_information.Player_InCombat) then
			if(Player:IsMoving()) then Player:StopMovement() end
			
			local dist = math.distance3d(Player.pos,gw2_unstuck.usedwaypointlasttick.lastplayerpos)
			local timestamp = TimeSince(gw2_unstuck.usedwaypointlasttick.timestamp)

			if(dist < 500) then
				d("[Unstuck]: Waiting for waypointing to finish.")
				if(timestamp > 7000) then
					gw2_unstuck.Reset()
					local wpdist = math.distance3d(Player.pos,gw2_unstuck.usedwaypointlasttick.pos)
					if(dist > 200) then
						d("[Unstuck]: Failed to use waypoint. (Distance > " .. math.round(dist,2) ..")")
						gw2_unstuck.stuckhandlers.stop()
					end
					gw2_unstuck.usedwaypointlasttick.id = nil
				end
				gw2_unstuck.stucktick = ml_global_information.Now + 1000
				
				gw2_unstuck.lastresult = true
				return gw2_unstuck.lastresult
			else
				if(timestamp > 2000) then
					gw2_unstuck.usedwaypointlasttick.id = nil
				else
					d("[Unstuck]: Waypointing finished, but we wait a bit.")
					gw2_unstuck.lastresult = true
					return gw2_unstuck.lastresult
				end
			end
		else
			gw2_unstuck.usedwaypointlasttick.id = nil
		end
	end
	
	if(gw2_unstuck.OnMesh()) then
		gw2_unstuck.STUCKTYPE = "onmesh"
		gw2_unstuck.lasttimeonmesh = ml_global_information.Now
		
		if(table.valid(gw2_unstuck.lastposition)) then
			-- Attack the object detected in the last unstuck tick
			if(table.valid(gw2_unstuck.pathblockingobject)) then
				gw2_unstuck.lastresult = gw2_unstuck.stuckhandlers.attack(gw2_unstuck.pathblockingobject)
				if(not gw2_unstuck.lastresult) then
					gw2_unstuck.pathblockingobject = nil
				end
			else
				gw2_unstuck.lastresult = gw2_unstuck.HandleStuck_MovedDistanceCheck()
			end
		end
		gw2_unstuck.lastposition = Player.pos
		gw2_unstuck.lastonmeshposition = Player.pos
	end

	return gw2_unstuck.lastresult
end

function gw2_unstuck.OnMesh()
	if(not Player.onmesh and not gw2_unstuck.manualcontrolmode and not ml_navigation.navconnection) then
		local meshstate = NavigationManager:GetNavMeshState()
		if(meshstate == GLOBAL.MESHSTATE.MESHEMPTY or meshstate == GLOBAL.MESHSTATE.MESHBUILDING or not string.valid(ml_mesh_mgr.currentfilename)) then
			d("[Unstuck]: No mesh loaded for this map.")
			gw2_unstuck.lastresult = true
			return gw2_unstuck.lastresult
		end
		
		gw2_unstuck.STUCKTYPE = "offmesh"
		gw2_unstuck.lastresult = gw2_unstuck.HandleOffMesh()
		gw2_unstuck.lastposition = Player.pos
		
		return false
	end
	return true
end

function gw2_unstuck.HandleOffMesh()
	local offmeshtime = TimeSince(gw2_unstuck.lasttimeonmesh)
	local ppos = Player.pos	
	local maxwptrycount = 10
	
	d("[Unstuck]: Player not on mesh at (X: "..tostring(math.round(ppos.x,1)).." Y: "..tostring(math.round(ppos.y,1)).." Z: "..tostring(math.round(ppos.z,1)).." MAPID: "..tostring( ml_global_information.CurrentMapID).." - ("..tostring(math.round(offmeshtime / 1000)).."s)")
	d("[Unstuck]: Waypoint try count: " .. gw2_unstuck.offmeshwptrycount .. " of " .. maxwptrycount)
	
	if(offmeshtime > 2000) then
		local p = NavigationManager:GetClosestPointOnMesh(ppos)
		if(table.valid(p) and p.distance > 0 and p.distance < 500) then
			d("[Unstuck]: Moving blindly to nearby mesh.")
			if(not gw2_unstuck.HandleStuck_MovedDistanceCheck()) then
				gw2_unstuck.stuckhandlers.moveto(p)
			end
		end
	end
	
	if(gw2_unstuck.lasttimeonmesh > 0 and offmeshtime > 15000 and TimeSince(gw2_unstuck.offmeshwptrytime) > 5000) then
		if(table.valid(gw2_unstuck.lastonmeshposition)) then
			gw2_obstacle_manager.AddAvoidanceArea({pos = gw2_unstuck.lastonmeshposition, radius = 50})
		end
		
		if(not gw2_unstuck.stuckhandlers.waypoint()) then
			Player:StopMovement()

			gw2_unstuck.offmeshwptrycount = gw2_unstuck.offmeshwptrycount + 1
			gw2_unstuck.offmeshwptrytime = ml_global_information.Now
			if(gw2_unstuck.offmeshwptrycount > maxwptrycount) then
				gw2_unstuck.stuckhandlers.stop()
			else
				d("[Unstuck]: In combat or no waypoint found. Try count: " .. gw2_unstuck.offmeshwptrycount .. " of 10")
			end

		else
			return true
		end	
	end
	
	return false
end

function gw2_unstuck.HandleStuck_MovedDistanceCheck()
	if(table.valid(gw2_unstuck.lastposition)) then
		local ppos = Player.pos
		if(ml_global_information.Player_SwimState ~= GW2.SWIMSTATE.NotInWater) then
			-- Swimming straight up or down is a valid thing
			gw2_unstuck.distmoved = math.distance3d(ppos,gw2_unstuck.lastposition)
		else
			gw2_unstuck.distmoved = math.distance2d(ppos,gw2_unstuck.lastposition)
		end
		
		local threshold = gw2_unstuck.ActiveThreshold()
		local mincount = (gw2_unstuck.unstuck_mode == nil or gw2_unstuck.unstuck_mode == "combat") and 3 or 2

		if(gw2_unstuck.distmoved < threshold) then
			gw2_unstuck.lastaction = nil
			if(gw2_unstuck.stuckcount >= mincount) then
				d(string.format("[Unstuck]: Distance moved: %s. Threshold: %s. Stuckcount: %s.", math.floor(gw2_unstuck.distmoved), math.floor(threshold), gw2_unstuck.stuckcount))
			end
			gw2_unstuck.stuckcount = gw2_unstuck.stuckcount + 1

			local _,stuckentry = gw2_unstuck.AddStuckEntry(ppos)
			
			if(gw2_unstuck.STUCKTYPE == "onmesh") then
				local lastaction = gw2_unstuck.HandleStuckEntry(stuckentry)

				if(lastaction > gw2_unstuck.statuscodes.ENTRY_NOT_HANDLED) then
					-- If stop code is recieved return true to prevent moving, else return false
					return lastaction == gw2_unstuck.statuscodes.STOP_BOT
				end
			end

			if(ml_global_information.Player_SwimState ~= GW2.SWIMSTATE.NotInWater) then
				if(gw2_unstuck.HandleStuck_Swimming(mincount)) then
					return true
				end
			elseif(gw2_unstuck.stuckcount > mincount+10) then
				gw2_obstacle_manager.AddAvoidanceArea({pos = Player.pos, radius = 25})
				gw2_unstuck.stuckhandlers.movebackward()
				gw2_unstuck.threshold = 200
				gw2_unstuck.stucktick = ml_global_information.Now + 2000
				return true
			elseif(gw2_unstuck.stuckcount > mincount+8) then
				local dir = math.random(4,5)
				gw2_unstuck.lastaction = "dodgeforward"..(dir == 4 and "left" or "right")
				gw2_unstuck.stuckhandlers[gw2_unstuck.lastaction]()
				return true
			elseif(gw2_unstuck.stuckcount > mincount+6) then
				local hit,hitx,hity,hitz,a,b,c
			
				hit,hitx,hity,hitz,a,b,c = RayCast(ppos.x, ppos.y, ppos.z, ppos.x+(ppos.hx*400), ppos.y+(ppos.hy*400), ppos.z-55, 0)
				if(hit) then
					d("[Unstuck]: Something is in front of us.")
					local GList = ( GadgetList("maxdistance=3000"))
					if (table.valid(GList)) then
						local id, gadget  = next( GList )
						local target = nil
						while id and gadget and target == nil do
							if(gadget.isunknown8 == a) then
								target = gadget
							end
							id,gadget  = next(GList, id)
						end
						
						if(not table.valid(target)) then
							target = Player:GetInteractableTarget()
						end
						
						if(not table.valid(target)) then
							local GList = ( GadgetList("nearest,maxdistance=500"))
							if(table.valid(GList)) then
								target = select(2,next(GList))
							end
						end
						
						if(table.valid(target) and target.isgadget) then
							if(gw2_unstuck.lastraycastdetails == nil or target.id ~= gw2_unstuck.lastraycastdetails.id) then
								gw2_unstuck.lastraycastdetails = { id = target.id, pos = {x = hitx, y = hity, z = Player.pos.z}, a = a, b = b, c = c }
								
								-- First try interacting
								if(gw2_unstuck.stuckhandlers.interact(target.id)) then
									gw2_unstuck.lastaction = "interact"
									return true
								end
								
								-- Store the object to continue attacking in the nest tick
								gw2_unstuck.pathblockingobject = { id = target.id, health = (target.health and target.health.current or 100), pos = {x = hitx, y = hity, z = hitz}, start = ml_global_information.Now, lasthealthcheck = ml_global_information.Now}
								
								-- Try attacking
								if(gw2_unstuck.stuckhandlers.attack(gw2_unstuck.pathblockingobject)) then
									gw2_unstuck.lastaction = "attack"
									return true	
								end
							end
						end
					end
				end
				
				-- Try to find a free spot 60 degrees to left side of the player
				local posleft = gw2_unstuck.rotateposition(60, {x = ppos.x+(ppos.hx*100), y = ppos.y+(ppos.hx*100), z = ppos.z-55})
				hit,hitx,hity,hitz,a,b,c = RayCast(ppos.x, ppos.y, ppos.z, posleft.x, posleft.y, posleft.z-55, 0)
				if(not hit and gw2_unstuck.stuckhandlers.moveto(posleft)) then
					d("[Unstuck]: Free space on the left.")
					gw2_unstuck.lastaction = "moveto"
					stuckentry.handlevars = posleft
					gw2_obstacle_manager.AddAvoidanceArea({pos = Player.pos, radius = 25})
					if(gw2_unstuck.stuckhandlers.moveto(posleft)) then
						return true
					end
				end
				
				-- Try to find a free spot 60 degrees to the right side of the player
				local posright = gw2_unstuck.rotateposition(-60, {x = ppos.x+(ppos.hx*100), y = ppos.y+(ppos.hx*100), z = ppos.z-55})
				hit,hitx,hity,hitz,a,b,c = RayCast(ppos.x, ppos.y, ppos.z, posright.x, posright.y, posright.z-55, 0)
				if(not hit and gw2_unstuck.stuckhandlers.moveto(posright)) then
					d("[Unstuck]: Free space on the right.")
					gw2_unstuck.lastaction = "moveto"
					stuckentry.handlevars = posright
					gw2_obstacle_manager.AddAvoidanceArea({pos = Player.pos, radius = 25})
					if(gw2_unstuck.stuckhandlers.moveto(posright)) then
						return true
					end
				end
			elseif(gw2_unstuck.stuckcount > mincount+1) then
				gw2_unstuck.lastaction = "jump"
				gw2_unstuck.stuckhandlers.jump()
				return true
			elseif(gw2_unstuck.stuckcount > mincount) then
				ml_navigation:ResetCurrentPath()
				-- Start moving forward
				gw2_unstuck.lastaction = "moveforward"
				gw2_unstuck.stuckhandlers.moveforward()
				return true
			end

			gw2_unstuck.laststuckposition = ppos
			return false
		end
				
		-- If something is right in front of us and there is nothing in front and above us, just jump.
		--[[ NOT READY YET
		if(ml_global_information.Player_SwimState == GW2.SWIMSTATE.NotInWater and gw2_unstuck.stuckcount < mincount) then
			local distmoved = math.distance2d(gw2_unstuck.lastposition,Player.pos)

			-- raycast almost at ground level in front of bot (area ahead blocked)
			local rpos1_hit, rpos1_x, rpos1_y, rpos1_z = RayCast(ppos.x, ppos.y, ppos.z-25, ppos.x+(ppos.hx*60), ppos.y+(ppos.hy*60), ppos.z-25)
			
			-- raycast above the bot in a straight line (area ahead above clear)
			local rpos2_hit, rpos2_x, rpos2_y, rpos2_z = RayCast(ppos.x, ppos.y, ppos.z-70, ppos.x+(ppos.hx*110), ppos.y+(ppos.hy*110), ppos.z-70) 
			
			if(rpos1_hit and not rpos2_hit) then
				d("[Unstuck]: Something is right in front of us, but there is free space above us.")
				gw2_unstuck.stuckhandlers.simplejump()
			end
		end]]
		
		-- If an action was performed at the last tick that got us freed, decrease the stuckcount on the stored stuck entry
		if(gw2_unstuck.laststuckentry and gw2_unstuck.lastaction) then
			gw2_unstuck.laststuckentry.handled = gw2_unstuck.lastaction
			if(gw2_unstuck.laststuckentry.stuckcount > 2) then
				gw2_unstuck.laststuckentry.stuckcount = gw2_unstuck.laststuckentry.stuckcount - 2
			elseif(gw2_unstuck.laststuckentry.stuckcount > 0) then
				gw2_unstuck.laststuckentry.stuckcount = gw2_unstuck.laststuckentry.stuckcount - 1
			end
		end
	end

	gw2_unstuck.Reset()
	
	return false
end

-- Swimming unstuck
function gw2_unstuck.HandleStuck_Swimming(mincount)
	if(Player.movementstate == GW2.MOVEMENTSTATE.AboveWaterMoving or Player.movementstate == GW2.MOVEMENTSTATE.AboveWaterNotMoving) then
		-- Swimming on surface
		if(gw2_unstuck.stuckcount > mincount+5) then
			gw2_unstuck.stuckhandlers.swimdown()
			gw2_unstuck.stuckhandlers.moveforward()
			gw2_unstuck.stucktick = ml_global_information.Now + math.random(500,1000)
			return true
		elseif(gw2_unstuck.stuckcount > mincount) then
			gw2_unstuck.stuckhandlers.moveforward()
			gw2_unstuck.stuckhandlers.jump()
			return true
		end
	else
		if(gw2_unstuck.stuckcount > mincount+5) then
			gw2_unstuck.stuckhandlers.swimdown()
			gw2_unstuck.stuckhandlers.moveforward()
			gw2_unstuck.stucktick = ml_global_information.Now + math.random(500,1000)
			return true
		elseif(gw2_unstuck.stuckcount > mincount) then
			gw2_unstuck.stuckhandlers.swimup()
			gw2_unstuck.stuckhandlers.moveforward()
			gw2_unstuck.stucktick = ml_global_information.Now + math.random(500,1000)
			return true
		end
	end
	
	return false
end

-- Handle the stored stuck entry.
-- Perform the last stored action if we succeded to get unstuck here the last time we visited this pos. (If possible)
function gw2_unstuck.HandleStuckEntry(entry)
	local status = gw2_unstuck.statuscodes.ENTRY_NOT_HANDLED
	if(table.valid(gw2_unstuck.laststuckentry)) then
		-- Increment the stuck count for this entry if it exists
		local _,oldentry = gw2_unstuck.GetStuckEntry(entry.pos)
		if(oldentry and TimeSince(entry.modified) > 500) then
			entry.stuckcount = entry.stuckcount + 1
			entry.modified = ml_global_information.Now
		end

		if(entry.stuckcount > 25) then
			d("[Unstuck]: We have been stuck at this location 25 times.")
			gw2_unstuck.stuckhandlers.stop()
			status = gw2_unstuck.statuscodes.STOP_BOT
		elseif(entry.stuckcount > 15) then
			d("[Unstuck]: We have been stuck at this location " .. entry.stuckcount .. " times.")
			gw2_obstacle_manager.AddAvoidanceArea({pos = Player.pos, radius = 50})
			entry.waypointcount = entry.waypointcount + 1
			status = gw2_unstuck.statuscodes.ENTRY_HANDLED
			if(entry.waypointcount < 5) then
				gw2_unstuck.stuckhandlers.waypoint()
			else
				d("[Unstuck]: We have waypointed away or tried to waypoint away from this location more then 5 times.")
				gw2_unstuck.stuckhandlers.stop()
				status = gw2_unstuck.statuscodes.STOP_BOT
			end
		elseif(entry.handled and gw2_unstuck.stuckhandlers[entry.handled] and not table.deepcompare(gw2_unstuck.laststuckentry,entry)) then
			d("[Unstuck]: We managed to get unstuck here last time using: " .. entry.handled)
			if(gw2_unstuck.stuckhandlers[entry.handled](entry.handlevars)) then
				status = gw2_unstuck.statuscodes.ENTRY_HANDLED
			end
		end
	end
	
	gw2_unstuck.laststuckentry = entry
	
	return status
end

function gw2_unstuck.AddStuckEntry(pos)
	local k,entry = gw2_unstuck.GetStuckEntry(pos)
	
	if(not entry) then
		local now = ml_global_information.Now
		gw2_unstuck.stuckhistory[now] = {
			pos = pos;
			stuckcount = 0;
			handled = false;
			added = now;
			mapid = ml_global_information.CurrentMapID;
			modified = now;
			inwater = ml_global_information.Player_SwimState ~= GW2.SWIMSTATE.NotInWater;
			waypointcount = 0;
			mode = gw2_unstuck.unstuck_mode;
			type = gw2_unstuck.STUCKTYPE;
		}
		k,entry = now,gw2_unstuck.stuckhistory[now]
	end

	return k,entry
end

function gw2_unstuck.GetStuckEntry(pos)
	if(table.valid(gw2_unstuck.stuckhistory)) then
		for k,stuckentry in pairs(gw2_unstuck.stuckhistory) do
			if(math.distance3d(pos,stuckentry.pos) < 40) then
				return k,stuckentry
			end
		end
	end
	return nil
end

function gw2_unstuck.ActiveThreshold()
	local threshold = gw2_unstuck.threshold * (gw2_common_functions.HasBuffs(Player, ml_global_information.SpeedBoons) and 1.33 or 1) -- Increased threshold with swiftness
	
	if ( Player.swimming == GW2.SWIMSTATE.Diving ) then
		threshold = threshold / 2
	end
	
	if (ml_global_information.Player_InCombat or gw2_common_functions.HasBuffs(Player, ml_global_information.SlowConditions) or gw2_unstuck.movementtype.backward) then
		-- We only move half (or less) the distance with conditions that slow movement
		threshold = threshold / 2
	end
	
	return threshold
end

-- Stuck handlers for reuse
gw2_unstuck.stuckhandlers = {}
function gw2_unstuck.stuckhandlers.simplejump()
	d("[Unstuck]: Trying to jump.")
	Player:Jump()
	return true
end

function gw2_unstuck.stuckhandlers.jump()
	d("[Unstuck]: Trying to jump.")
	gw2_unstuck.stuckhandlers.moveforward()
	Player:Jump()
	return true
end

function gw2_unstuck.stuckhandlers.dodgeforwardright()
	d("[Unstuck]: Trying to dodge forward to the right.")
	Player:Evade(4)
	return true
end

function gw2_unstuck.stuckhandlers.dodgeforwardleft()
	d("[Unstuck]: Trying to dodge forward to the left.")
	Player:Evade(5)
	return true
end

function gw2_unstuck.stuckhandlers.moveto(pos)
	d("[Unstuck]: Trying to move to a position.")
	if(table.valid(pos)) then
		Player:SetFacing(pos.x,pos.y,pos.z)
		gw2_unstuck.stuckhandlers.moveforward()
		gw2_unstuck.stucktick = ml_global_information.Now + math.random(1500,2000)
		return true
	end
	return false
end

function gw2_unstuck.stuckhandlers.moveforward()
	d("[Unstuck]: Trying to move forward.")
	gw2_unstuck.movementtype.forward = GW2.MOVEMENTTYPE.Forward
	Player:SetMovement(GW2.MOVEMENTTYPE.Forward)
	return true
end

function gw2_unstuck.stuckhandlers.movebackward()
	d("[Unstuck]: Trying to move backward.")
	gw2_unstuck.movementtype.backward = GW2.MOVEMENTTYPE.Backward
	Player:SetMovement(GW2.MOVEMENTTYPE.Backward)
	return true
end

function gw2_unstuck.stuckhandlers.swimup()
	d("[Unstuck]: Trying to swim up.")
	Player:StopMovement()
	Player:SetMovement(GW2.MOVEMENTTYPE.SwimUp)
	gw2_unstuck.movementtype.swimup = GW2.MOVEMENTTYPE.SwimUp
	return true
end

function gw2_unstuck.stuckhandlers.swimdown()
	d("[Unstuck]: Trying to swim down.")
	Player:StopMovement()
	Player:SetMovement(GW2.MOVEMENTTYPE.SwimDown)
	gw2_unstuck.movementtype.swimdown = GW2.MOVEMENTTYPE.SwimDown
	return true
end

function gw2_unstuck.stuckhandlers.waypoint()
	d("[Unstuck]: Trying to use a waypoint.")
	if(gw2_unstuck.usedwaypointlasttick and gw2_unstuck.usedwaypointlasttick.timestamp > 0 and TimeSince(gw2_unstuck.usedwaypointlasttick.timestamp) < 30000) then
		d("[Unstuck]: Used a waypoint less then 30 seconds ago.")
		gw2_unstuck.stuckhandlers.stop()
		gw2_unstuck.usedwaypointlasttick.id = nil
	elseif (Inventory:GetInventoryMoney() > 200 and not ml_global_information.Player_InCombat) then
		local wp = gw2_common_functions.GetClosestWaypointToPos(ml_global_information.CurrentMapID,Player.pos)
		if(table.valid(wp)) then
			if (wp.distance > 500) then
				Player:StopMovement()
				Player:TeleportToWaypoint(wp.id)
				gw2_unstuck.Reset()
				gw2_unstuck.usedwaypointlasttick = {id = wp.id; pos = wp.pos, timestamp = ml_global_information.Now, lastplayerpos = Player.pos}
				
				return true
			else
				d("[Unstuck]: We are too close to a Waypoint to Teleport again.")
				gw2_unstuck.usedwaypointlasttick.id = nil
				return false
			end
		end
		gw2_unstuck.usedwaypointlasttick.id = nil
		d("[Unstuck]: No Waypoint to teleport to nearby found.")
	else
		gw2_unstuck.usedwaypointlasttick.id = nil
		d("[Unstuck]: Not enough gold or in combat, cannot use waypoint.")
	end
	return false
end

function gw2_unstuck.stuckhandlers.attack(object)
	d("[Unstuck]: Trying to attack.")
	if(table.valid(object)) then
		local skill = Player:GetSpellInfo(GW2.SKILLBARSLOT.Slot_1)
		local target = GadgetList:Get(object.id)
		
		if(TimeSince(object.start) > 60000 or not table.valid(skill) or skill.maxrange == 0 or not table.valid(target) or target.alive == false or target.attackable == false) then
			d("[Unstuck]: Target destroyed or invalid")
			return false
		end
		
		if(TimeSince(object.start) > 10000 and TimeSince(object.lasthealthcheck) > 5000) then
			object.lasthealthcheck = ml_global_information.Now
			if(object.health <= target.health.current) then
				d("[Unstuck]: Target not losing health")
				return false
			end
			object.health = target.health.current
		end

		Player:StopMovement()
		
		local maxrange = skill.maxrange > 150 and skill.maxrange or 150
		local dist = math.distance2d(Player.pos,object.pos)
		
		Player:SetFacingExact(object.pos.x,object.pos.y,target.pos.z)
		if(dist > maxrange) then
			gw2_unstuck.stuckhandlers.moveforward()
			return true
		end
		
		-- Work around a weird issue with some skills that wont cast if too close to the target
		if(target.distance < 150) then
			gw2_unstuck.stuckhandlers.movebackward()
		end
		
		local ptarget = Player:GetTarget()
		if(ptarget == nil or ptarget.id ~= target.id) then
			Player:SetTarget(target.id)
		end
		
		if(Player.castinfo.duration == 0) then
			if(skill.isgroundtargeted) then
				Player:CastSpell(skill.slot,object.pos.x,object.pos.y,target.pos.z)
			else
				Player:CastSpell(skill.slot,target.id)
			end
		end
		return true
	end
	return false
end

function gw2_unstuck.stuckhandlers.interact(id)
	d("[Unstuck]: Trying to interact.")
	if(id) then
		local target = GadgetList:Get(id)
		if(table.valid(target)) then
			if(target.interactable and target.isininteractrange) then
				if(target.selectable) then
					Player:SetTarget(target.id)
				end
				Player:SetFacingExact(target.x,target.y,target.z)
				Player:Interact(target.id)
				gw2_unstuck.stucktick = ml_global_information.Now + math.random(750,1000)
				return true
			end
		end
	end
	return false
end

function gw2_unstuck.stuckhandlers.stop()
	d("[Unstuck]: Stopping the bot.")
	Player:StopMovement()
	ml_global_information.Stop()
	BehaviorManager:Stop()
end

-- Rotate pos around center.
function gw2_unstuck.rotateposition(deg,pos,center)
	deg = deg*(math.pi/180)
	center = center or Player.pos

	local rotated = {}
	local x = pos.x-center.x
	local y = pos.y-center.y
	local c = math.cos(deg)
	local s = math.sin(deg)

	rotated.x = (x * c) - (y * s) + center.x
	rotated.y = (y * s) + (x * c) + center.y
	rotated.z = pos.z

	return rotated
end

function gw2_unstuck.Init()
	-- Reset stuck threshold if changes are needed
	if(Settings.GW2Minion.stuckversion ~= gw2_unstuck.version) then
		Settings.GW2Minion.stuckthreshold = nil
		Settings.GW2Minion.stuckversion = gw2_unstuck.version
	end
	if(Settings.GW2Minion.stuckthreshold == nil or type(Settings.GW2Minion.stuckthreshold) ~= "number") then Settings.GW2Minion.stuckthreshold = 30 end
	
	ml_gui.ui_mgr:AddMember({ id = "GW2MINION##UNSTUCKMGR", name = GetString("Unstuck"), onClick = function() gw2_unstuck.gui.open = gw2_unstuck.gui.open ~= true end, tooltip = "Click to open \"Unstuck\" window.", texture = GetStartupPath().."\\GUI\\UI_Textures\\unstuck.png"},"GW2MINION##MENU_HEADER")
	
	gw2_unstuck.Stop()
end
RegisterEventHandler("Module.Initalize",gw2_unstuck.Init)

function gw2_unstuck.Update(_, tick)
	if(TimeSince(gw2_unstuck.updatetick) > 1000) then
		gw2_unstuck.updatetick = tick
		
		for k,entry in pairs(gw2_unstuck.stuckhistory) do			
			if(TimeSince(entry.modified) > 120000) then
				-- Decrease the stuck count over time
				if(entry.stuckcount > 0) then
					entry.stuckcount = entry.stuckcount - 1
					entry.modified = ml_global_information.Now
				elseif(entry.handled == false) then
					gw2_unstuck.stuckhistory[k] = nil
				end
			elseif(entry.mapid ~= ml_global_information.CurrentMapID and entry.handled == false) then
				-- No need to store unhandled entries if we change map
				gw2_unstuck.stuckhistory[k] = nil
			end
		end
	end
end
RegisterEventHandler("Gameloop.Update",gw2_unstuck.Update)

---- GUI
function gw2_unstuck.Draw()
	if(gw2_unstuck.gui.open) then
		GUI:SetNextWindowSize(550,400,GUI.SetCond_Appearing)
		gw2_unstuck.gui.visible, gw2_unstuck.gui.open = GUI:Begin(gw2_unstuck.gui.name, gw2_unstuck.gui.open)
		
		if(gw2_unstuck.gui.visible) then
			Settings.GW2Minion.stuckthreshold = GUI:SliderInt(GetString("Threshold"), Settings.GW2Minion.stuckthreshold, 20, 60)
			GUI:Separator()

			GUI:Text(GetString("With swiftness")..": "..tostring(math.round(Settings.GW2Minion.stuckthreshold*1.33,2)))
			GUI:Text(GetString("In combat")..": "..tostring(math.round(Settings.GW2Minion.stuckthreshold/2,2)))
			GUI:Text(GetString("Active threshold")..": "..tostring(math.round(gw2_unstuck.ActiveThreshold(),2)))
			
			GUI:Text(GetString("Current stuck count")..": "..tostring(gw2_unstuck.stuckcount))
			GUI:Text(GetString("Distance moved")..": "..tostring(math.round(gw2_unstuck.distmoved,2)))
			
			GUI:Separator()

			local history = {}
			if(table.valid(gw2_unstuck.stuckhistory)) then
				for _,entry in pairs(gw2_unstuck.stuckhistory) do
					table.insert(history, entry)
				end
				table.sort(history, function(a,b) return a.added > b.added end)
			end
			
			if(GUI:ListBoxHeader(GetString("Stuck history"), table.size(history), 5)) then
				for i=1,#history do
					local entry = history[i]
					if(GUI:Selectable(entry.mapid.." / "..math.ceil(entry.pos.x)..","..math.ceil(entry.pos.y)..","..math.ceil(entry.pos.z).." / "..GetString("Handled")..": " .. tostring(entry.handled), gw2_unstuck.gui.selectedstuckentry == entry.added)) then
						gw2_unstuck.gui.selectedstuckentry = entry.added
					end
				end
				GUI:ListBoxFooter()
			end
			GUI:Text(GetString("Latest entry first"))

			GUI:Separator()
			if(gw2_unstuck.gui.selectedstuckentry) then
				local entry = gw2_unstuck.stuckhistory[gw2_unstuck.gui.selectedstuckentry]
				if(entry and entry.handled == false and entry.stuckcount == 0) then
					GUI:Text(GetString("Entry will be removed in")..": "..tostring(math.ceil((120000-TimeSince(entry.modified))/1000)).."s")
					GUI:Separator()
				end
				GUI:Columns(2, "##unstuck-details", true)
				GUI:SetColumnOffset(1,200) GUI:SetColumnOffset(2,600)
				
				GUI:Text(GetString("Key")); GUI:NextColumn();
				GUI:Text(GetString("Value")); GUI:NextColumn();
				GUI:Separator()

				if(entry) then
					-- Sort keys alphabetically
					local entrysorted = {}
					for k,v in pairs(entry) do
						table.insert(entrysorted, {key = k, value = v})
					end
					table.sort(entrysorted, function(a,b) return a.key < b.key end)
					
					for i=1,#entrysorted do
						local entry_details = entrysorted[i]
						local detail = tostring(entry_details.value)
						
						GUI:Text(entry_details.key) GUI:NextColumn()
						
						if(entry_details.key == "pos" and table.valid(entry_details.value)) then
							detail = string.format("{x=%s;y=%s;z=%s}",math.round(entry_details.value.x,2),math.round(entry_details.value.y,2),math.round(entry_details.value.z,2))
							GUI:InputText("##"..entry.added,detail,GUI.InputTextFlags_ReadOnly+GUI.InputTextFlags_AutoSelectAll)
						else
							GUI:Text(detail) 
						end
						
						GUI:NextColumn()
					end
				end
				GUI:Columns(1)
			end
		end
		GUI:End()
	end
end
RegisterEventHandler("Gameloop.Draw",gw2_unstuck.Draw)