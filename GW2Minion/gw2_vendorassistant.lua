gw2_vendorassistant = {}
gw2_vendorassistant.window = {
	open = false,
	visible = true,
	name = GetString("Vendor Assistant")
}

gw2_vendorassistant.vendoropen = false
gw2_vendorassistant.vendorcheck = 0
gw2_vendorassistant.timer = 0
gw2_vendorassistant.buying = false
gw2_vendorassistant.selling = false

function gw2_vendorassistant.Init()
	if(Settings.GW2Minion.autosell == nil) then Settings.GW2Minion.autosell = false end
	if(Settings.GW2Minion.autobuy == nil) then Settings.GW2Minion.autobuy = false end
end

-- Draw gui
function gw2_vendorassistant.Draw()
	gw2_vendorassistant.window.open = gw2_vendorassistant.vendoropen
	
	if(gw2_vendorassistant.window.open) and Settings.GW2Minion.vendorassist then
		GUI:SetNextWindowSize(320,170,GUI.SetCond_Once)
		GUI:SetNextWindowPosCenter(GUI.SetCond_FirstUseEver)
		
		gw2_vendorassistant.window.visible, gw2_vendorassistant.window.open = GUI:Begin(gw2_vendorassistant.window.name, gw2_vendorassistant.window.open, GUI.WindowFlags_NoCollapse)

		if(gw2_vendorassistant.window.visible) then
		
			Settings.GW2Minion.autobuy = GUI:Checkbox(GetString("Auto buy items"), Settings.GW2Minion.autobuy or false)	
			Settings.GW2Minion.autosell = GUI:Checkbox(GetString("Auto sell items"), Settings.GW2Minion.autosell or false)
			GUI:Separator()
			if(GUI:Button(GetString("Buy items now"),200,0)) then
				gw2_vendorassistant.buying = true
			end
			
			if(GUI:Button(GetString("Sell items now"),200,0)) then
				gw2_vendorassistant.selling = true
			end
			GUI:Separator()
			GUI:TextWrapped(GetString("Sell settings are set in the Sell Manager"))
			GUI:TextWrapped(GetString("Buy settings are set in the Buy Manager"))
		end
		
		GUI:End()
	end
end

-- Update conditions
function gw2_vendorassistant.Update()
	if(ml_global_information.GameState == GW2.GAMESTATE.GAMEPLAY) then
		if(BehaviorManager:CurrentBTreeName() == GetString("AssistMode") or not BehaviorManager:Running()) then
			if(gw2_vendorassistant.vendoropen or TimeSince(gw2_vendorassistant.vendorcheck) > 500) then
				gw2_vendorassistant.vendorcheck = ml_global_information.Now
				gw2_vendorassistant.vendoropen = Inventory:IsVendorOpened()	
			end
		else
			gw2_vendorassistant.vendoropen = false
		end
		
		if(TimeSince(gw2_vendorassistant.timer) > 250) then
			gw2_vendorassistant.timer = ml_global_information.Now
			
			if(gw2_vendorassistant.BuyItems()) then
				return
			end
			
			if(gw2_vendorassistant.SellItems()) then
				return
			end
		end
		
		if(gw2_vendorassistant.vendoropen) then
			return
		end
	end
	
	gw2_vendorassistant.vendoropen = false
	gw2_vendorassistant.buying = false
	gw2_vendorassistant.selling = false
end

-- Buy items
function gw2_vendorassistant.BuyItems()
	if((Settings.GW2Minion.autobuy or gw2_vendorassistant.buying) and gw2_vendorassistant.vendoropen) then
		if(gw2_buy_manager.vendorSellsCheck() and (gw2_buy_manager.NeedToBuySalvageKits(true) or gw2_buy_manager.NeedToBuyGatheringTools(true))) then
			if(gw2_common_functions.handleConversation("buy") == nil) then return end
			
			if(gw2_common_functions.handleConversation("buy")) then
				if(gw2_buy_manager.buyItems()) then
					gw2_vendorassistant.buying = true
					return true
				end
			end
		end
	end
	
	gw2_vendorassistant.buying = false
	return false
end

-- Sell items
function gw2_vendorassistant.SellItems()
	if((Settings.GW2Minion.autosell or gw2_vendorassistant.selling) and gw2_vendorassistant.vendoropen) then
		local junkitems = Inventory("rarity="..GW2.ITEMRARITY.Junk..",exclude_contentid="..gw2_blacklistmanager.GetExcludeString(GetString("Sell items")))
		if(gw2_sell_manager.haveItemToSell() or table.valid(junkitems)) then
			if(gw2_common_functions.handleConversation("sell") == nil) then return end
			
			if(gw2_common_functions.handleConversation("sell")) then
				if(gw2_sell_manager.sellItems()) then
					gw2_vendorassistant.selling = true
					return true
				end
			end
		end
	end
	
	gw2_vendorassistant.selling = false
	return false
end
 
RegisterEventHandler("Module.Initalize", gw2_vendorassistant.Init, "gw2_vendorassistant.Init")
RegisterEventHandler("Gameloop.Draw", gw2_vendorassistant.Draw, "gw2_vendorassistant.Draw")
RegisterEventHandler("Gameloop.Draw", gw2_vendorassistant.Update, "gw2_vendorassistant.Update")
