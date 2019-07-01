gw2_nav_manager = {}

function gw2_nav_manager.ModuleInit()
	ml_node.DistanceTo = gw2_nav_manager.NodeDistanceTo
end

-- Set up scoring for map entry points
function gw2_nav_manager.NodeDistanceTo(self,id)
	local neighbor = self:GetNeighbor(id)
	local neighborNode = ml_nav_manager.GetNode(id)
	
	if(table.valid(neighbor) and table.valid(neighborNode)) then
		local nodeEntry = neighborNode:GetNeighbor(self.id)
		if(table.valid(nodeEntry)) then
			local lowestCost = math.huge
			for id, exitPos in pairs(neighbor) do
				if (table.valid(exitPos)) then
					for _,entryPos in pairs(nodeEntry) do
						local cost = math.distance3d(entryPos,exitPos)
						if (cost < lowestCost) then
							lowestCost = cost
						end
					end
				end
			end
			return lowestCost
		end
	end
	
	return 1
end

RegisterEventHandler("Module.Initalize", gw2_nav_manager.ModuleInit, "gw2_nav_manager.ModuleInit")