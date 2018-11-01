gw2_combat_movement = {}

gw2_combat_movement.combatmovement = {
	combat = false,
	range = false,
	allowed = true,
}

function gw2_combat_movement:DoCombatMovement(target)
	
	local fightdistance = ml_global_information.AttackRange or 154

	-- Combat movement is disabled
	if(not self.combatmovement.allowed) then
		if(self.combatmovement.combat or self.combatmovement.range) then
			self:StopCombatMovement()
		end
		-- Make sure it's reset so it doesn't stick around for too long
		self.combatmovement.allowed = true
		return false
	end
	
	if (self.combatmovement.range and (target == nil or ( not target.isplayer and target.distance < fightdistance and target.los))) then d("[gw2_combat_movement]: In range, stopping..") Player:StopMovement() self.combatmovement.range = false end  -- "range" is "moving into combat range"
	
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
			d("[gw2_combat_movement]: Can't move, stop trying.")
			Player:StopMovement()
			self.combatmovement.combat = false
		end
	
	elseif(self.combatmovement.combat) then -- Stop active combat movement.		 
		d("[gw2_combat_movement]: Stopping active combat movement.")
		Player:StopMovement()
		self.combatmovement.combat = false
	end
end

function gw2_combat_movement:GetCombatMovement() 
	return self.combatmovement
end

function gw2_combat_movement:CombatMovementCanMove()
	if(not self.combatmovement.allowed) then return false end
	
	return not self.combatmovement.combat 
end

function gw2_combat_movement:StopCombatMovement()
	self.combatmovement.combat = false
	self.combatmovement.range = false
	self.combatmovement.allowed = true
	Player:StopHorizontalMovement()
end

-- Must always be called before DoCombatMovement()
function gw2_combat_movement:PreventCombatMovement()
	self.combatmovement.allowed = false
end

-- Compatability for a while
for k,v in pairs(gw2_combat_movement) do
	if(type(v) == "function") then
		gw2_common_functions[k] = function(...)
			d("gw2_common_functions:"..k.."(...) is deprecated, please change your code to use gw2_combat_movement:"..k.."(...)")
			v(...)
		end
	else
		gw2_common_functions[k] = v
	end
	
end