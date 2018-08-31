-- Avoidance area manager
-- Entries are stored in list manager and loaded as needed
-- Areas can be managed from the list manager
gw2_obstacle_manager = {}
gw2_obstacle_manager.ticks = 0
gw2_obstacle_manager.obstacles = {}
gw2_obstacle_manager.avoidanceareas = {} -- Set in init

local AvoidanceAreaOptions = class("AvoidanceAreaOptions")
function AvoidanceAreaOptions:initialize(options)
	self.id = options.id or nil; -- Identifier, for easy removal
	self.pos = table.valid(options.pos) and table.shallowcopy(options.pos) or {}; -- Target position
	self.time = nil; -- Used for internal timetracking
	self.duration = options.duration or true; -- how long it should last (ms), true will last until reload
	self.radius = options.radius or 50;
	self.showaddmessage = options.showaddmessage or true; -- Show message in console when added
	self.mapid = options.mapid or ml_global_information.CurrentMapID;
end

-- Override default avoidance area handler to avoid collisions
function gw2_obstacle_manager.MLAddAvoidanceArea(self, pos, radius) 
	gw2_obstacle_manager.AddAvoidanceArea({pos = pos, radius = radius})
end
ml_navigation.AddAvoidanceArea = gw2_obstacle_manager.MLAddAvoidanceArea

function gw2_obstacle_manager.AddAvoidanceArea(opt)
	local options = AvoidanceAreaOptions:new(opt)
	
	if(table.valid(options.pos)) then
		local newpos = NavigationManager:GetClosestPointOnMesh(options.pos)
		if(newpos ~= nil) then
			options.pos.z = newpos.z
		end

		if(options.id == nil) then
			options.id = options.pos.x.."_"..options.pos.y.."_"..options.pos.z.."_"..options.mapid
		end
		
		local add = true
		local entries = ml_list_mgr.FindEntries(GetString("Avoidance areas"), "mapid="..ml_global_information.CurrentMapID)
		local i,existing = next(entries)
		
		while i and existing and add do
			if(math.distance2d(existing.pos,options.pos) < existing.radius) then
				add = false
			end
			i,existing = next(entries,i)
		end

		if(add) then
			options.time = options.time or ml_global_information.Now
			options.class = nil

			gw2_obstacle_manager.avoidanceareas:AddEntry(options)

			if(options.showaddmessage) then
				if(type(options.duration) == "number") then
					d("[gw2_obstacle_manager]: Avoidance area added with duration : "..math.ceil(options.duration/1000).."s")
				else
					d("[gw2_obstacle_manager]: Avoidance area added.")
				end
			end
			
			gw2_obstacle_manager.SetupAvoidanceAreas()
		end
	end
end

function gw2_obstacle_manager.AddAvoidanceAreaAtTarget(target, options)
	if(table.valid(target) and table.valid(target.pos)) then
		options = AvoidanceAreaOptions:new(options)
		options.pos = target.pos
		options.radius = options.radius or target.radius
		gw2_obstacle_manager.AddAvoidanceArea(options)
	end
end

-- Remove an avoidance area by position
function gw2_obstacle_manager.RemoveAvoidanceArea(options)
	options = AvoidanceAreaOptions:new(options)
	if(table.valid(options.pos)) then
		local entries = ml_list_mgr.FindEntries(GetString("Avoidance areas"), "mapid="..ml_global_information.CurrentMapID)
		if(table.valid(entries)) then
			for i,avoidancearea in pairs(entries) do
				if(avoidancearea.pos.x == avoidancearea.pos.x and avoidancearea.pos.y == options.pos.y and avoidancearea.pos.z == options.pos.z) then
					gw2_obstacle_manager.avoidanceareas:DeleteEntry(i)
					gw2_obstacle_manager.SetupAvoidanceAreas()
				end
			end
		end
	end
end

-- Remove an avoidance area by the id given when added
function gw2_obstacle_manager.RemoveAvoidanceAreaByID(id)
	if(id ~= nil) then
		local entries = ml_list_mgr.FindEntries(GetString("Avoidance areas"), "mapid="..ml_global_information.CurrentMapID)
		if(table.valid(entries)) then
			for i,avoidancearea in pairs(entries) do
				if(avoidancearea.id == id) then
					gw2_obstacle_manager.avoidanceareas:DeleteEntry(i)
					gw2_obstacle_manager.SetupAvoidanceAreas()
				end
			end
		end
	end
end

function gw2_obstacle_manager.SetupAvoidanceAreas()
	ml_navigation.avoidanceareas = {}
	local entries = ml_list_mgr.FindEntries(GetString("Avoidance areas"), "mapid="..ml_global_information.CurrentMapID)
	if(table.valid(entries)) then
		for _,entry in pairs(entries) do
			local pos = entry.pos
			table.insert(ml_navigation.avoidanceareas, { x = math.round(pos.x,0),  y = math.round(pos.y,0), z = math.round(pos.z,0), r = entry.radius  })
		end
	else
		NavigationManager:ClearAvoidanceAreas()
	end
	NavigationManager:SetAvoidanceAreas(ml_navigation.avoidanceareas)
end

function gw2_obstacle_manager.ModuleInit()
	gw2_obstacle_manager.avoidanceareas = ml_list_mgr.AddList(GetString("Avoidance areas"), gw2_obstacle_manager.DrawAvoidanceAreas)
end
RegisterEventHandler("Module.Initalize",gw2_obstacle_manager.ModuleInit)

function gw2_obstacle_manager.MapChanged()
	gw2_obstacle_manager.SetupAvoidanceAreas()
end
RegisterEventHandler("gw2minion.MapChanged",gw2_obstacle_manager.MapChanged)

function gw2_obstacle_manager.OnUpdateHandler(_,tick)
	if(TimeSince(gw2_obstacle_manager.ticks) > BehaviorManager:GetTicksThreshold()) then
		gw2_obstacle_manager.ticks = tick
		
		local entries = ml_list_mgr.FindEntries(GetString("Avoidance areas"), "mapid="..ml_global_information.CurrentMapID)
		local avoidanceRemoved = false
		if(table.valid(entries)) then
			for i,avoidancearea in pairs(entries) do
				if(type(avoidancearea.time) == "number" and type(avoidancearea.duration) == "number" and avoidancearea.duration > 0 and TimeSince(avoidancearea.time) > avoidancearea.duration) then
					avoidanceRemoved = true
					gw2_obstacle_manager.avoidanceareas:DeleteEntry(i)
				end
			end
		end
		
		if(avoidanceRemoved) then
			gw2_obstacle_manager.SetupAvoidanceAreas()
		end
	end
end
RegisterEventHandler("Gameloop.Update",gw2_obstacle_manager.OnUpdateHandler)

gw2_obstacle_manager.blAvoidanceAreaEntryDuration = 0
gw2_obstacle_manager.blAvoidanceAreaEntryRadius = 50
function gw2_obstacle_manager:DrawAvoidanceAreas()
	GUI:Separator();

	GUI:TextWrapped(GetString("Avoidance areas are places on the mesh the bot will try to avoid walking over."))
	GUI:Text(GetString("A duration of 0 is permanent"))
	
	GUI:Separator();
	
	gw2_obstacle_manager.blAvoidanceAreaEntryDuration = GUI:InputInt(GetString("Duration").." (s)", gw2_obstacle_manager.blAvoidanceAreaEntryDuration)
	if(type(gw2_obstacle_manager.blAvoidanceAreaEntryDuration) ~= "number" or gw2_obstacle_manager.blAvoidanceAreaEntryDuration < 0) then
		gw2_obstacle_manager.blAvoidanceAreaEntryDuration = 0
	end
	
	gw2_obstacle_manager.blAvoidanceAreaEntryRadius = GUI:InputInt(GetString("Radius"), gw2_obstacle_manager.blAvoidanceAreaEntryRadius)
	if(type(gw2_obstacle_manager.blAvoidanceAreaEntryRadius) ~= "number" or gw2_obstacle_manager.blAvoidanceAreaEntryRadius < 25) then
		gw2_obstacle_manager.blAvoidanceAreaEntryRadius = 25
	end
	
	if(GUI:Button(GetString("Add avoidance area"))) then
		
		local duration = 0
		if(gw2_obstacle_manager.blAvoidanceAreaEntryDuration > 0) then
			duration = ml_global_information.Now + gw2_obstacle_manager.blAvoidanceAreaEntryDuration*1000
		end
		local newentry = {pos = ml_global_information.Player_Position, mapid = ml_global_information.CurrentMapID, duration = duration, radius = gw2_obstacle_manager.blAvoidanceAreaEntryRadius}
		gw2_obstacle_manager.AddAvoidanceArea(newentry)
	end
	
	GUI:Separator();
	GUI:Separator();
		-- Draw the list entries
	
	GUI:Spacing(4);
	GUI:Columns(4, "##listdetail-view", true)
	GUI:SetColumnOffset(1,100); GUI:SetColumnOffset(2,160); GUI:SetColumnOffset(3,260); GUI:SetColumnOffset(4,360);
	GUI:Text(GetString("ID")); GUI:NextColumn();
	GUI:Text(GetString("Map ID")); GUI:NextColumn();
	GUI:Text(GetString("Duration")); GUI:NextColumn(); GUI:NextColumn();
	GUI:Separator();

	local entries = self.entries
	if (table.valid(entries)) then
		for i, entry in pairs(entries) do
			GUI:Text(entry.id); GUI:NextColumn();
			GUI:Text(entry.mapid); GUI:NextColumn();
			local expiration = tonumber(entry.duration)
			if(type(duration) ~= "number") then
				duration = 0
			end
			
			if(duration > 0) then
				duration = math.ceil((duration-ml_global_information.Now)/1000)
			end
			
			GUI:Text(tostring(duration)); GUI:NextColumn();
			if (GUI:Button(GetString("Delete").."##"..i)) then
				gw2_obstacle_manager.RemoveAvoidanceAreaByID(entry.id)
			end
			GUI:NextColumn();
		end
	end
end