-- Main config file of GW2Minion

wt_global_information = {}
wt_global_information.Currentprofession = nil
wt_global_information.Now = 0

wt_global_information.PVP = false
wt_global_information.MainWindow = { Name = "GW2Minion", x=100, y=120 , width=200, height=220 }
wt_global_information.BtnStart = { Name="StartStop" ,Event = "GUI_REQUEST_RUN_TOGGLE" }
wt_global_information.BtnPulse = { Name="Pulse" ,Event = "Debug.Pulse" }
wt_global_information.AttackEnemiesLevelMaxRangeAbovePlayerLevel = 3  
wt_global_information.CurrentMarkerList = nil
wt_global_information.SelectedMarker = nil
wt_global_information.AttackRange = 1200
wt_global_information.MaxLootDistance = 1200 -- Now used by "c_check_loot::evaluate()" in "wt_core_state_idle.lua"
wt_global_information.MaxReviveDistance = 800 -- New global used by "c_check_revive:evaluate()" in "wt_core_state_idle.lua"
wt_global_information.MaxGatherDistance = 4000
wt_global_information.MaxAggroDistanceFar = 1200
wt_global_information.MaxAggroDistanceClose = 500
wt_global_information.MaxSearchEnemyDistance = 2500
wt_global_information.lastrun = 0
wt_global_information.InventoryFull = 0
wt_global_information.LeaderID = nil
wt_global_information.PartyAggroTargets = {}
wt_global_information.FocusTarget = nil
wt_global_information.stats_lastrun = 0
wt_global_information.HasRepairMerchant = 0
wt_global_information.HasVendor = 0


gw2minion = { }

if (Settings.GW2MINION.version == nil ) then
	-- Init Settings for Version 1
	Settings.GW2MINION.version = 1.0
	Settings.GW2MINION.gEnableLog = "0"
end


if (Settings.GW2MINION.version <= 1.33 ) then
	Settings.GW2MINION.version = 1.34
	Settings.GW2MINION.gGW2MinionPulseTime = "150"
	Settings.GW2MINION.gEnableRepair = "0"
	Settings.GW2MINION.gIgnoreMarkerCap = "0"	
	Settings.GW2MINION.gMaxItemSellRarity = "2"
end

function wt_global_information.OnUpdate( event, tickcount )
	wt_global_information.Now = tickcount

	gGW2MiniondeltaT = tostring(tickcount - wt_global_information.lastrun)
	if (tickcount - wt_global_information.lastrun > tonumber(gGW2MinionPulseTime)) then
		wt_global_information.lastrun = tickcount	
		wt_core_controller.Run()
		--GUI_RefreshWindow(wt_global_information.MainWindow.Name)
	end	
	if ( gStats_enabled == "1" and tickcount - wt_global_information.stats_lastrun > 2000) then
		wt_global_information.stats_lastrun = tickcount	
		wt_global_information.GatherAndSendStats()
	end		
end

-- Module Event Handler
function gw2minion.HandleInit()
	wt_debug("received Module.Initalize")
	GUI_NewWindow(wt_global_information.MainWindow.Name,wt_global_information.MainWindow.x,wt_global_information.MainWindow.y,wt_global_information.MainWindow.width,wt_global_information.MainWindow.height)
	GUI_NewButton(wt_global_information.MainWindow.Name, wt_global_information.BtnStart.Name , wt_global_information.BtnStart.Event)
	GUI_NewButton(wt_global_information.MainWindow.Name, wt_global_information.BtnPulse.Name , wt_global_information.BtnPulse.Event)	
	GUI_NewSeperator(wt_global_information.MainWindow.Name);		
	GUI_NewField(wt_global_information.MainWindow.Name,"Pulse Time (ms)","gGW2MinionPulseTime","BotStatus");	
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Enable Log","gEnableLog","BotStatus");
	GUI_NewField(wt_global_information.MainWindow.Name,"State","gGW2MinionState","BotStatus");
	GUI_NewField(wt_global_information.MainWindow.Name,"Effect","gGW2MinionEffect","BotStatus");	
	GUI_NewField(wt_global_information.MainWindow.Name,"MainTask","gGW2MinionTask","BotStatus");
	GUI_NewField(wt_global_information.MainWindow.Name,"dT","gGW2MiniondeltaT","BotStatus");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Ignore Marker Level Cap","gIgnoreMarkerCap","Settings");
	GUI_NewCheckbox(wt_global_information.MainWindow.Name,"Repair Equippment","gEnableRepair","Settings");
	GUI_NewField(wt_global_information.MainWindow.Name,"Max ItemSell Rarity","gMaxItemSellRarity","Settings");
	
	GUI_FoldGroup(wt_global_information.MainWindow.Name,"BotStatus");
	GUI_FoldGroup(wt_global_information.MainWindow.Name,"Settings");
		
	gEnableLog = Settings.GW2MINION.gEnableLog
	gGW2MinionPulseTime = Settings.GW2MINION.gGW2MinionPulseTime 
	gEnableRepair = Settings.GW2MINION.gEnableRepair
	gIgnoreMarkerCap = Settings.GW2MINION.gIgnoreMarkerCap
	gMaxItemSellRarity = Settings.GW2MINION.gMaxItemSellRarity
	
	wt_debug("GUI Setup done")
	wt_core_controller.requestStateChange(wt_core_state_idle)
end

function gw2minion.GUIVarUpdate(Event, NewVals, OldVals)
	for k,v in pairs(NewVals) do
		if ( k == "gEnableLog" or k == "gGW2MinionPulseTime" or k == "gEnableRepair" or k == "gIgnoreMarkerCap" or k == "gMaxItemSellRarity" ) then
			Settings.GW2MINION[tostring(k)] = v
		end
	end
	GUI_RefreshWindow(wt_global_information.MainWindow.Name)
end

function wt_global_information.Reset()
	Player:StopMoving()	
	wt_global_information.CurrentMarkerList = nil
	wt_global_information.SelectedMarker = nil
	wt_global_information.AttackRange = 1200
	wt_global_information.MaxLootDistance = 1200
	wt_global_information.lastrun = 0
	wt_global_information.InventoryFull = 0
	wt_core_state_vendoring.junksold = false 
	wt_core_state_combat.CurrentTarget = 0
	c_aggro.TargetList = {}
	wt_core_taskmanager.task_list = { }
	wt_core_taskmanager.possible_tasks = { }
	wt_core_taskmanager.current_task = nil
	wt_core_taskmanager.markerList = { }
	wt_global_information.LeaderID = nil
	wt_global_information.PartyAggroTargets = {}
	wt_global_information.FocusTarget = nil
	wt_global_information.HasRepairMerchant = 0
	wt_global_information.HasVendor = 0
	if ( gMinionEnabled == "1" and MultiBotIsConnected( ) ) then		
		MultiBotLeaveChannel( "gw2minion" )
		MultiBotDisconnect( )
	end		
	wt_core_controller.requestStateChange(wt_core_state_idle)
end

function wt_global_information.GatherAndSendStats() 
	if ( MultiBotIsConnected() ) then		
		MultiBotSend("name=" .. tostring(Player.name) .."("..tostring(Player.level)..")","setval");
		MultiBotSend("health=" .. tostring(math.floor(Player.health.current)),"setval");
		MultiBotSend("maxhealth=" .. tostring(Player.health.max),"setval");
		MultiBotSend("healthstate=" .. tostring(Player.healthstate),"setval");
		MultiBotSend("endurance=" .. tostring(Player.endurance),"setval");
		MultiBotSend("money=" .. tostring(Inventory:GetInventoryMoney()),"setval");
		MultiBotSend("freeslots=" .. tostring(ItemList.freeSlotCount),"setval");
		MultiBotSend("onmesh=" .. tostring(Player.onmesh),"setval");		
		local pPos = Player.pos
		MultiBotSend("pos=" .. tostring(math.floor(pPos.x).. "|" ..math.floor(pPos.y).. "|" ..math.floor(pPos.z)),"setval");		
		
		local TID = Player:GetTarget()
		if (TID ~= nil and TID ~= 0 and wt_core_controller.shouldRun ~=nil and wt_core_controller.shouldRun==true) then
			local Target = CharacterList:Get(TID)
			if ( Target ~= nil ) then
				MultiBotSend("target=" ..tostring(Target.name) .."("..tostring(Target.health.percent).."%)","setval");
			end			
		else
			MultiBotSend("target=None","setval");
		end	
		
		if (gGW2MinionState ~= nil and wt_core_controller.shouldRun ~=nil and wt_core_controller.shouldRun==true) then
			MultiBotSend("state=" ..tostring(gGW2MinionState),"setval");
		else
			MultiBotSend("state=None","setval");
		end	
		
		if (gGW2MinionEffect ~= nil and wt_core_controller.shouldRun ~=nil and wt_core_controller.shouldRun==true) then
			MultiBotSend("effect=" ..tostring(gGW2MinionEffect),"setval");
		else
			MultiBotSend("effect=None","setval");
		end	
			
		if (wt_core_controller ~= nil and wt_core_controller.shouldRun ~=nil and wt_core_controller.shouldRun==true) then
			MultiBotSend("running=true","setval");
		else
			MultiBotSend("running=false","setval");
		end
		
		if (wt_global_information.LeaderID ~= nil and wt_global_information.LeaderID == Player.characterID) then
			MultiBotSend("role=Leader","setval");
		else
			MultiBotSend("role=Minion","setval");
		end
		
	else
		wt_debug("Trying to connect to MultibotComServer....")
		if ( not MultiBotConnect( gIP , tonumber(gPort) , gPw) ) then
			gStats_enabled = "0"
			wt_debug("Cannot reach MultibotComServer... Make sure you have started the MultibotComServer.exe and the correct Password,IP and Port!")
		else			
			MultiBotJoinChannel("remotecmd")
			MultiBotJoinChannel("gw2minion")
			wt_debug("Successfully Joined MultiBotServer channels !")			
		end	
	end
end

-- Handler for the Buttons in the GW2 Minion Server Browser
function wt_global_information.HandleCMDMultiBotMessages( event, message,channel )
	if ( channel ~= nil and channel == "remotecmd" ) then
		d("Command Message:" .. tostring(channel) .. "->" .. tostring(message))
		if( tostring(message) == "Stop" ) then
			wt_core_controller.ToggleRun()
			wt_debug("StartStop Button Pressed")
		elseif (tostring(message) == "Teleport" ) then
			Player:RespawnAtClosestResShrine()
			wt_debug("Teleport Button Pressed")
		elseif (tostring(message) == "ExitGW2" ) then			
			wt_debug("ExitGW2 Button Pressed")
			ExitGW()
		end
	end
end


-- Register Event Handlers
RegisterEventHandler("Module.Initalize",gw2minion.HandleInit)
RegisterEventHandler("Gameloop.Update",wt_global_information.OnUpdate)
RegisterEventHandler("GUI.Update",gw2minion.GUIVarUpdate)
RegisterEventHandler("MULTIBOT.Message",wt_global_information.HandleCMDMultiBotMessages)

