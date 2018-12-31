-- Heartquest controller
gw2_tm_heartquest = {}
gw2_tm_heartquest.lastcheck = 0
gw2_tm_heartquest.laststatus = true
gw2_tm_heartquest.lastid = 0

function gw2_tm_heartquest:CanTaskRun_TM(taskProperties,customProperties)
	return gw2_tm_heartquest:CanTaskStart_TM(taskProperties,customProperties)
end

function gw2_tm_heartquest:CanTaskStart_TM(taskProperties,customProperties)
	if(not customProperties or type(customProperties.hqid) ~= "number" or customProperties.hqid == 0) then
		d("[gw2_tm_heartquest]: No valid hqid set. Ending task.")
		return false
	end
	
	-- Reset status if this is a new task
	if(gw2_tm_heartquest.lastid ~= customProperties.hqid) then
		gw2_tm_heartquest.lastid = customProperties.hqid
		gw2_tm_heartquest.laststatus = true
	end
	
	if(TimeSince(gw2_tm_heartquest.lastcheck) > 1000) then
		gw2_tm_heartquest.lastcheck = ml_global_information.Now
		
		if (taskProperties.mapid ~= ml_global_information.CurrentMapID) then
			gw2_tm_heartquest.laststatus = true
			return gw2_tm_heartquest.laststatus
		end
		
		if(table.valid(customProperties)) then

			local MList = MapMarkerList("issubregion,contentid=31373,71075")
			if(table.valid(MList)) then
				for _,marker in pairs(MList) do
					if(marker.subregionid == customProperties.hqid) then
						d("[tm_heartquest]: HeartQuest already done. Ending task.")
						gw2_tm_heartquest.laststatus = false
						return gw2_tm_heartquest.laststatus
					end
				end
			end
		end
		
		gw2_tm_heartquest.laststatus = true
	end
	
	return gw2_tm_heartquest.laststatus
end

-- Heropoint controller
gw2_tm_heropoint = {}
gw2_tm_heropoint.lastcheck = 0
gw2_tm_heropoint.laststatus = true
gw2_tm_heropoint.lastpos = nil

function gw2_tm_heropoint:CanTaskRun_TM(taskProperties,customProperties)
	return gw2_tm_heropoint:CanTaskStart_TM(taskProperties,customProperties)
end

function gw2_tm_heropoint:CanTaskStart_TM(taskProperties,customProperties)
	-- Reset status if this is a new task
	if(gw2_tm_heropoint.lastpos == nil or math.distance3d(taskProperties.pos,gw2_tm_heropoint.lastpos) > 5) then
		gw2_tm_heropoint.lastpos = table.shallowcopy(taskProperties.pos)
		gw2_tm_heropoint.laststatus = true
	end
	
	if(TimeSince(gw2_tm_heropoint.lastcheck) > 1000) then
		gw2_tm_heropoint.lastcheck = ml_global_information.Now
		local heroPointList = MapMarkerList("contentid="..GW2.MAPMARKER.SkillpointComplete)
		for _,heroPoint in pairs(heroPointList) do
			if (table.valid(heroPoint)) then
				local distanceToHPTask = math.distance3d(heroPoint.pos,taskProperties.pos)
				if (distanceToHPTask < 500) then
					gw2_tm_heropoint.laststatus = false
					return gw2_tm_heropoint.laststatus
				end
			end
		end

		gw2_tm_heropoint.laststatus = true
	end
	
	return gw2_tm_heropoint.laststatus
end

-- Waypoint controller
gw2_tm_waypoint = {}
function gw2_tm_waypoint:CanTaskRun_TM(taskProperties,customProperties)
	return self:CanTaskStart_TM(taskProperties,customProperties)
end

function gw2_tm_waypoint:CanTaskStart_TM(taskProperties,customProperties)
	if(table.valid(taskProperties) and table.valid(customProperties)) then
		if(taskProperties.mapid == ml_global_information.CurrentMapID) then
			if(type(customProperties.waypointid) == "number") then
				local wp = WorldMap:HasWaypoint(customProperties.waypointid)
				if(wp == true) then
					d("[tm_Discoverwaypoint]: Waypoint already discovered. Ending task.")
					return false
				end
			end
		end
	end
	return true
end


-- Test controller
gw2_tm_test = {}
gw2_tm_test.lastcheck = 0
function gw2_tm_test:CanTaskRun_TM(taskProperties,customProperties)
	if(gw2_tm_test.lastcheck == 0) then gw2_tm_test.lastcheck = ml_global_information.Now end
	if(TimeSince(gw2_tm_test.lastcheck) > 15000) then
		gw2_tm_test.lastcheck = ml_global_information.Now
		return false
	end
	return true
end

gw2_taskmanager = {}
function gw2_taskmanager.Init()
	if(ml_task_mgr) then
		ml_task_mgr.min_level = 0
		ml_task_mgr.max_level = 80 
		ml_task_mgr.GetMapName = gw2_datamanager.GetMapName
		ml_task_mgr.btreepath = GetLuaModsPath()..[[GW2Minion\Behavior]]
		ml_task_mgr.taskpath = GetLuaModsPath()..[[GW2Minion\TaskManagerProfiles\]]
		ml_task_mgr.GetMapID = function() return ml_global_information.CurrentMapID end
		ml_task_mgr.GetPlayerPos = function() return ml_global_information.Player_Position end
		ml_task_mgr.DrawBotProperties = gw2_taskmanager.DrawBotProperties
		ml_task_mgr.Init()
		
		-- Main task types
		ml_task_mgr.AddTaskType("tm_grind", "GrindMode.bt", nil, {displayname = GetString("Grind mode")})
		ml_task_mgr.AddTaskType("tm_gather", "GatherMode.bt", nil, {displayname = GetString("Gather mode")})
		ml_task_mgr.AddTaskType("tm_moveto", "blank.st", nil, {allowpretasks = true; displayname = GetString("Move to location")})
		ml_task_mgr.AddTaskType("tm_generic", "blank.st", nil, {allowpretasks = true; allowposttasks = true; allowsubtasks = true; displayname = GetString("Generic task")})
		ml_task_mgr.AddTaskType("tm_wait", "Wait.st", nil, {displayname = GetString("Wait")})
		ml_task_mgr.AddTaskType("tm_vista", "tm_Vista.st", nil, {allowpretasks = true; allowposttasks = true; displayname = GetString("View vista"); requireduration = true; minduration = 180})
		ml_task_mgr.AddTaskType("tm_heropoint", "blank.st", gw2_tm_heropoint, {allowpretasks = true; allowposttasks = true; allowsubtasks = true; displayname = GetString("Heropoint")})
		ml_task_mgr.AddTaskType("tm_hq", "tm_HeartQuest.st", gw2_tm_heartquest, {allowpretasks = true; allowposttasks = true; allowsubtasks = true; displayname = GetString("Heartquest")})
		ml_task_mgr.AddTaskType("tm_discoverwaypoint", "tm_Discoverwaypoint.st", gw2_tm_waypoint, {displayname = GetString("Discover waypoint")})
		ml_task_mgr.AddTaskType("tm_buy", "tm_Buy.st", nil, {allowpretasks = true; allowposttasks = true;displayname = GetString("Buy kits and tools")})
		ml_task_mgr.AddTaskType("tm_usewaypoint", "tm_Usewaypoint.st", nil, {displayname = GetString("Use waypoint")})
		
		-- Sub task types
		ml_task_mgr.AddSubTaskType("tm_st_movetomultiple", "tm_MoveToMultiple.st", nil, {displayname = GetString("Move to multiple locations")})
		ml_task_mgr.AddSubTaskType("tm_st_moveto", "tm_MoveTo.st", nil, {displayname = GetString("Move to location")})
		ml_task_mgr.AddSubTaskType("tm_st_interact", "tm_Interact.st", nil, {displayname = GetString("Interact")})
		ml_task_mgr.AddSubTaskType("tm_st_fightaggro", "HandleAggro.st", nil, {displayname = GetString("Fight aggro")})
		ml_task_mgr.AddSubTaskType("tm_st_killspecific", "tm_CombatHandler.st", nil, {displayname = GetString("Kill specific targets")})
		ml_task_mgr.AddSubTaskType("tm_st_hqstatus", "tm_CheckHQStatus.st", nil, {displayname = GetString("Check HQ status")})
		ml_task_mgr.AddSubTaskType("tm_st_talk", "tm_Talk.st", nil, {displayname = GetString("Talk")})
		ml_task_mgr.AddSubTaskType("tm_st_changemesh", "tm_ChangeMesh.st", nil, {displayname = GetString("Change mesh")})
		ml_task_mgr.AddSubTaskType("tm_st_useitem", "tm_UseItem.st", nil, {displayname = GetString("Use inventory item")})
		-- not ready ml_task_mgr.AddSubTaskType("tm_st_deliver", "tm_Deliver.st", nil, {displayname = GetString("Deliver item")})	
		ml_task_mgr.AddSubTaskType("tm_st_useskill", "tm_UseSkill.st", nil, {displayname = GetString("Use skill")})	
		ml_task_mgr.AddSubTaskType("tm_st_wait", "Wait.st", nil, {displayname = GetString("Wait")})	
		ml_task_mgr.AddSubTaskType("tm_st_emote", "tm_Emote.st", nil, {displayname = GetString("Emote")})	
		ml_task_mgr.AddSubTaskType("tm_st_usewaypoint", "tm_Usewaypoint.st", nil, {displayname = GetString("Use waypoint")})
		
		-- For testing				
		--ml_task_mgr.AddTaskType("tm_subtask_test", "blank.st", gw2_tm_test, {allowpretasks = true; allowposttasks = true; allowsubtasks = true; displayname = GetString("Subtask Test")})
		--ml_task_mgr.AddSubTaskType("tm_st_test", "blank.st", nil, {displayname = GetString("Do nothing")})	
	end
end

-- Draw bot specific properties in the task dialog
function gw2_taskmanager.DrawBotProperties(taskProperties)
	if(table.valid(taskProperties)) then
		if(taskProperties.gw2_trytosurvive == nil) then taskProperties.gw2_trytosurvive = false end
		if(taskProperties.gw2_failondeath == nil) then taskProperties.gw2_failondeath = false end
		if(taskProperties.gw2_failondeathcount == nil) then taskProperties.gw2_failondeathcount = 4 end
		
		taskProperties.gw2_trytosurvive = GUI:Checkbox(GetString("Fight aggro before reaching the start position"), taskProperties.gw2_trytosurvive)
		if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("If the health starts getting low before reaching the start position, start fighting aggro enemies.")) end
		
		taskProperties.gw2_failondeath = GUI:Checkbox(GetString("Fail the task if dying before the start position"), taskProperties.gw2_failondeath)
		if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("Stop running this task if we die too much.")) end
		
		if(taskProperties.gw2_failondeath) then
			taskProperties.gw2_failondeathcount = GUI:InputInt(GetString("Max death count"),taskProperties.gw2_failondeathcount)
			if (GUI:IsItemHovered()) then GUI:SetTooltip(GetString("How many times we have to die before failing the task.")) end
			if(taskProperties.gw2_failondeathcount < 0) then taskProperties.gw2_failondeathcount = 0 end
		end
	end
end

RegisterEventHandler("Module.Initalize",gw2_taskmanager.Init)
