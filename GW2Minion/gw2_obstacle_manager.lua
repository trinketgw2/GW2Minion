-- Avoidance area manager
-- Entries are stored in list manager and loaded as needed
-- Areas can be managed from the list manager
gw2_obstacle_manager = {}
gw2_obstacle_manager.ticks = 0
gw2_obstacle_manager.obstacles = {}
gw2_obstacle_manager.avoidanceareas = {} -- Set in init
-- Save trigger
gw2_obstacle_manager.avoidanceareaschanged = false
-- If the version changes, all stored avoidance areas are removed
gw2_obstacle_manager.version = 1

local AvoidanceAreaOptions = class("AvoidanceAreaOptions")
function AvoidanceAreaOptions:initialize(options)
	self.id = options.id or nil; -- Identifier, for easy removal
	self.pos = table.valid(options.pos) and table.shallowcopy(options.pos) or {}; -- Target position
	self.time = nil; -- Used for internal timetracking
	self.duration = options.duration or true; -- how long it should last (ms), true will last until reload
	self.radius = options.radius or 50;
	self.showaddmessage = options.showaddmessage or true; -- Show message in console when added
	self.mapid = options.mapid or ml_global_information.CurrentMapID;
	self.version = nil; -- Set to obstacle manager version when added
	self.manual = options.manual or false; -- Avoidance area was manually added with the list manager
end

-- Override default avoidance area handler to avoid collisions
function gw2_obstacle_manager.MLAddAvoidanceArea(self, pos, radius) 
	gw2_obstacle_manager.AddAvoidanceArea({pos = pos, radius = radius})
end
ml_navigation.AddAvoidanceArea = gw2_obstacle_manager.MLAddAvoidanceArea

-- Pass a table of AvoidanceAreaOptions values eg. {pos = {xyz}, radius = 50, duration = 5000}
function gw2_obstacle_manager.AddAvoidanceArea(opt)
	local options = AvoidanceAreaOptions:new(opt)
	
	if(table.valid(options.pos)) then
		local newpos = NavigationManager:GetClosestPointOnMesh(options.pos)
		if(newpos ~= nil) then
			options.pos.z = newpos.z
		end

		if(options.id == nil) then
			options.id = string.hash(options.pos.x.."_"..options.pos.y.."_"..options.pos.z.."_"..options.mapid)
		end

		options.version = gw2_obstacle_manager.version

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
				if(type(options.duration) == "number" and options.duration > 0) then
					d("[gw2_obstacle_manager]: Avoidance area added with duration : "..math.ceil(options.duration/1000).."s")
				else
					d("[gw2_obstacle_manager]: Avoidance area added.")
				end
			end
			
			gw2_obstacle_manager.avoidanceareaschanged = true
			return options.id
		end
	end
	return nil
end

-- Add an avoidance area at a target Character, Agent or Gadget. Pass options for additional properties like duration
function gw2_obstacle_manager.AddAvoidanceAreaAtTarget(target, options)
	if(table.valid(target) and table.valid(target.pos)) then
		options = AvoidanceAreaOptions:new(options)
		options.pos = target.pos
		options.radius = options.radius or target.radius
		gw2_obstacle_manager.AddAvoidanceArea(options)
	end
end

-- Remove an avoidance area by position
function gw2_obstacle_manager.RemoveAvoidanceArea(options,mapid)
	options = AvoidanceAreaOptions:new(options)
	mapid = mapid and "mapid="..mapid or ""
	
	if(table.valid(options.pos)) then
		local entries = ml_list_mgr.FindEntries(GetString("Avoidance areas"), mapid)
		if(table.valid(entries)) then
			for i,avoidancearea in pairs(entries) do
				if(avoidancearea.pos.x == avoidancearea.pos.x and avoidancearea.pos.y == options.pos.y and avoidancearea.pos.z == options.pos.z) then
					gw2_obstacle_manager.avoidanceareas:DeleteEntry(i)
					gw2_obstacle_manager.avoidanceareaschanged = true
				end
			end
		end
	end
end

-- Remove an avoidance area by the id given when added
function gw2_obstacle_manager.RemoveAvoidanceAreaByID(id,mapid)
	if(id ~= nil) then
		mapid = mapid and "mapid="..mapid or ""
		
		local entries = ml_list_mgr.FindEntries(GetString("Avoidance areas"), mapid)
		if(table.valid(entries)) then
			for i,avoidancearea in pairs(entries) do
				if(avoidancearea.id == id) then
					gw2_obstacle_manager.avoidanceareas:DeleteEntry(i)
					gw2_obstacle_manager.avoidanceareaschanged = true
				end
			end
		end
	end
end

-- Call to pass avoidance areas over to the NavigationManager
function gw2_obstacle_manager.SetupAvoidanceAreas()
	NavigationManager:ClearAvoidanceAreas()
	ml_navigation.avoidanceareas = {}
	local entries = ml_list_mgr.FindEntries(GetString("Avoidance areas"), "mapid="..ml_global_information.CurrentMapID)
	if(table.valid(entries)) then
		for _,entry in pairs(entries) do
			local pos = entry.pos
			if(NavigationManager:IsOnMesh(pos.x,pos.y,pos.z)) then
				table.insert(ml_navigation.avoidanceareas, { x = math.round(pos.x,0),  y = math.round(pos.y,0), z = math.round(pos.z,0), r = entry.radius  })
			end
		end
	end
	NavigationManager:SetAvoidanceAreas(ml_navigation.avoidanceareas)
	gw2_obstacle_manager.avoidanceareaschanged = false
end

-- Remove all entires that have been added by the bot
function gw2_obstacle_manager.ClearAutomatic()
	local removed = false
	local entries = gw2_obstacle_manager.avoidanceareas:GetList()
	if(table.valid(entries)) then
		for i,entry in pairs(entries) do
			if(not entry.manual) then
				d("[gw2_obstacle_manager]: Removing avoidance area " .. tostring(entry.id))
				gw2_obstacle_manager.avoidanceareas:DeleteEntry(i)
				removed = true
			end
		end
	end
	if(removed) then
		gw2_obstacle_manager.avoidanceareaschanged = true
	end
end

function gw2_obstacle_manager.ModuleInit()
	gw2_obstacle_manager.avoidanceareas = ml_list_mgr.AddList(GetString("Avoidance areas"), gw2_obstacle_manager.DrawAvoidanceAreas)
	
	-- Remove entries if the version changes
	local entries = gw2_obstacle_manager.avoidanceareas:GetList()
	if(table.valid(entries)) then
		for i,entry in pairs(entries) do
			if(entry.version ~= gw2_obstacle_manager.version) then
				d("[gw2_obstacle_manager]: Version changed, removing avoidance area " .. tostring(entry.id))
				gw2_obstacle_manager.avoidanceareas:DeleteEntry(i)
			end
		end
	end
end
RegisterEventHandler("Module.Initalize",gw2_obstacle_manager.ModuleInit)

function gw2_obstacle_manager.MapChanged()
	d("[gw2_obstacle_manager]: Map changed, loading stored avoidance areas.")
	gw2_obstacle_manager.SetupAvoidanceAreas()
end
RegisterEventHandler("gw2minion.MapChanged",gw2_obstacle_manager.MapChanged)

function gw2_obstacle_manager.OnUpdateHandler(_,tick)
	if(TimeSince(gw2_obstacle_manager.ticks) > BehaviorManager:GetTicksThreshold()) then
		gw2_obstacle_manager.ticks = tick
		
		if(gw2_obstacle_manager.avoidanceareaschanged) then
			gw2_obstacle_manager.SetupAvoidanceAreas()
		end

		-- Remove areas that are on a timer
		local entries = ml_list_mgr.FindEntries(GetString("Avoidance areas"), "mapid="..ml_global_information.CurrentMapID)
		local avoidanceRemoved = false
		if(table.valid(entries)) then
			for i,avoidancearea in pairs(entries) do
				if(type(avoidancearea.time) == "number" and type(avoidancearea.duration) == "number" and avoidancearea.duration > 0 and avoidancearea.time+avoidancearea.duration < ml_global_information.Now) then
					avoidanceRemoved = true
					gw2_obstacle_manager.avoidanceareas:DeleteEntry(i)
				end
			end
		end
		
		if(avoidanceRemoved) then
			gw2_obstacle_manager.avoidanceareaschanged = true
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
			duration = gw2_obstacle_manager.blAvoidanceAreaEntryDuration*1000
		end
		local newentry = {
			pos = ml_global_information.Player_Position;
			mapid = ml_global_information.CurrentMapID;
			duration = duration;
			radius = gw2_obstacle_manager.blAvoidanceAreaEntryRadius;
			manual = true;
		}
		gw2_obstacle_manager.AddAvoidanceArea(newentry)
		gw2_obstacle_manager.blAvoidanceAreaEntryDuration = 0
		gw2_obstacle_manager.blAvoidanceAreaEntryRadius = 50
	end
	
	GUI:SameLine()
	
	
	if(GUI:Button(GetString("Clear automatic areas"))) then
		GUI:OpenPopup(GetString("Are you sure?").."##obstaclemanager")
	end
	
	GUI:SetNextWindowSize(330,150)
	if (GUI:BeginPopupModal(GetString("Are you sure?").."##obstaclemanager",true,GUI.WindowFlags_NoResize+GUI.WindowFlags_NoMove+GUI.WindowFlags_ShowBorders)) then
		GUI:TextWrapped(GetString("This will delete all avoidance areas that have been added by the bot."))
		if (GUI:Button(GetString("OK"),150,0)) then
			gw2_obstacle_manager.ClearAutomatic()
			GUI:CloseCurrentPopup()
		end
		GUI:SameLine()
		if (GUI:Button(GetString("Cancel"),150,0)) then
			GUI:CloseCurrentPopup()
		end
		GUI:EndPopup()
	end
	
	GUI:Separator();
	GUI:Separator();
	
	GUI:Spacing(6);
	GUI:Columns(6, "##listdetail-view", true)
	GUI:SetColumnOffset(1,100); GUI:SetColumnOffset(2,160); GUI:SetColumnOffset(3,260); GUI:SetColumnOffset(4,360); GUI:SetColumnOffset(5,460); GUI:SetColumnOffset(6,560);
	GUI:Text(GetString("ID")); GUI:NextColumn();
	GUI:Text(GetString("Map ID")); GUI:NextColumn();
	GUI:Text(GetString("Duration")); GUI:NextColumn();
	GUI:Text(GetString("Version")); GUI:NextColumn();
	GUI:Text(GetString("Manual")); GUI:NextColumn(); GUI:NextColumn();
	GUI:Separator();

	-- Draw the list entries
	-- Draw current map first
	local mapentries = self:FindAll(ml_global_information.CurrentMapID,"mapid")
	if(table.valid(mapentries)) then
		gw2_obstacle_manager:DrawEntryTable(mapentries)
	end
	-- Draw everything else
	gw2_obstacle_manager:DrawEntryTable(self.entries,ml_global_information.CurrentMapID)
end

function gw2_obstacle_manager:DrawEntryTable(entries,excludemapid)
	if(table.valid(entries)) then

		if (table.valid(entries)) then
			for i, entry in pairs(entries) do
				if(excludemapid == nil or excludemapid ~= entry.mapid) then
					GUI:Text(entry.id); GUI:NextColumn();
					GUI:Text(entry.mapid); GUI:NextColumn();
					local duration = tonumber(entry.duration)
					if(type(duration) ~= "number") then
						duration = 0
					end
					
					if(duration > 0) then
						duration = math.ceil(((entry.time+duration)-ml_global_information.Now)/1000)
					end
					
					GUI:Text(tostring(duration)); GUI:NextColumn();
					
					GUI:Text(entry.version); GUI:NextColumn();
					GUI:Text(tostring(entry.manual)); GUI:NextColumn();
					
					if (GUI:Button(GetString("Delete").."##"..i)) then
						gw2_obstacle_manager.RemoveAvoidanceAreaByID(entry.id,entry.mapid)
					end
					GUI:NextColumn();
				end
			end
		end
	end
end