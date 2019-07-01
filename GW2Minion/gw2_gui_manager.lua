gw2_gui_manager = {}

gw2_gui_manager.messages = {}

-- Queue bot messages to show them in order and not collide with each other
function gw2_gui_manager.QueueMessage(messagefn)
	table.insert(gw2_gui_manager.messages, messagefn)
end

-- Draw messages if there are any (return false in the function to remove from queue)
function gw2_gui_manager.Draw()
	if(#gw2_gui_manager.messages > 0 and type(gw2_gui_manager.messages[1]) == "function") then
		local result = gw2_gui_manager.messages[1]() -- Call the draw function
		if(not result) then
			table.remove(gw2_gui_manager.messages, 1)
		end
	end
end
RegisterEventHandler("Gameloop.Draw", gw2_gui_manager.Draw, "gw2_gui_manager.Draw")
