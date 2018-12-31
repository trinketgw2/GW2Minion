gw2_gui_manager = {}

gw2_gui_manager.messages = {}
gw2_gui_manager.debugmarkers = {}

-- Queue bot messages to show them in order and not collide with each other
function gw2_gui_manager.QueueMessage(messagefn)
	table.insert(gw2_gui_manager.messages, messagefn)
end

-- Queue bot messages to show them in order and not collide with each other
function gw2_gui_manager.AddMarker(name, marker)
	gw2_gui_manager.debugmarkers[name] = marker
	marker.type = name
end

-- Draw messages if there are any (return false in the function to remove from queue)
local function DrawMessages()
	if(#gw2_gui_manager.messages > 0 and type(gw2_gui_manager.messages[1]) == "function") then
		local result = gw2_gui_manager.messages[1]() -- Call the draw function
		if(not result) then
			table.remove(gw2_gui_manager.messages, 1)
		end
	end
end
RegisterEventHandler("Gameloop.Draw", DrawMessages)

-- Draw messages if there are any (return false in the function to remove from queue)
local function DrawMarkers()
	
	local sx,sy = GUI:GetScreenSize()

	GUI:SetNextWindowSize(sx,sy,GUI.SetCond_Always)
	GUI:SetNextWindowPosCenter(GUI.SetCond_Always)
	GUI:PushStyleColor(GUI.Col_WindowBg, 0, 0, 0, 0)
	GUI:Begin("gw2_gui_manager debug draw space", true, GUI.WindowFlags_NoInputs + GUI.WindowFlags_NoBringToFrontOnFocus + GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoCollapse)
	GUI:PopStyleColor(1)

	if(table.valid(gw2_gui_manager.debugmarkers)) then
		for _,marker in pairs(gw2_gui_manager.debugmarkers) do
			local spos = RenderManager:WorldToScreen(marker.pos)
			if(spos) then
				local circle_size = 10
				if(circle_size) then
					marker.guidata = marker.guidata or {}

					if(marker.guidata.lastdistanceupdate == nil or TimeSince(marker.guidata.lastdistanceupdate) > 150) then
						marker.guidata.lastdistanceupdate = ml_global_information.Now
						marker.guidata.distance = math.distance3d(ml_global_information.Player_Position,marker.pos)
						marker.guidata.scale = math.max(0.4, math.abs((marker.guidata.distance - 6000) / 6000))
						marker.guidata.color = GUI:ColorConvertFloat4ToU32(marker.color.r,marker.color.g,marker.color.b,marker.color.a)
						marker.guidata.t_color = GUI:ColorConvertFloat4ToU32(1,1,1,0.8)

						marker.guidata.t_text = "Type: " .. marker.type
						local dx, dy = GUI:CalcTextSize(marker.guidata.t_text)
						marker.guidata.dx = dx
						marker.guidata.dy = dy
					end

					local scale = marker.guidata.scale
					local dx,dy = marker.guidata.dx, marker.guidata.dy

					
					GUI:AddRectFilled(spos.x - (dx/2) - 5, spos.y - 50 - (circle_size*scale) - (dy*1.4), spos.x + (dx/2) + 5, spos.y - 50 - (circle_size*scale) - (dy*1.4) + dy, marker.guidata.t_color, 0, 0)
					GUI:AddText(spos.x - (dx/2), spos.y - 50 - (circle_size*scale) - (dy*1.4) , marker.guidata.color, marker.guidata.t_text)

					GUI:AddCircleFilled(spos.x, spos.y - 50, circle_size*scale, marker.guidata.color)
				end
			end
		end
	end
	
	GUI:End()
end
RegisterEventHandler("Gameloop.Draw", DrawMarkers)
