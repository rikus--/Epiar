

-- This is the Introduction Message that greets new players.
-- Notice that we use spaces here since Label can't parse tabs.
welcomeMessage = [[
                                                  Welcome to Epiar

We hope you like it. We're still working on it.


The Epiar controls in a nutshell:
    - Move the ship with the Arrow keys.
    - Land on a Planet by hitting L when you are near it.

    - Fire with the Spacebar once you buy a gun.
    - To target ships:
          - Hit TAB to cycle through nearby ships.
          - Hit t to select the closest ship.
          - Click on the ship.
    - To board a disabled target hit B while you are near it.

    - View the map by hitting m or M.
    - To change the keyboard layout or volume controls, press ?.

    - Quit by hitting escape.

For more information about Epiar, please visit:

                                                  epiar.net

If you have any questions, comments, or bug reports please send us email at:

                                                  epiar-devel@epiar.net

Thanks for playing!
]]

-- Generate a Random Lua Seed
function randomizeseed()
	math.randomseed(os.time())
	-- Absorb the first few non-random random results
	for s =1,10 do
		math.random();
	end
end

--------------------------------------------------------------------------------
-- Basic Utilities

--- Pause the game
function togglePause()
	if 1 == Epiar.ispaused() then
		Epiar.unpause()
	else
		Epiar.pause()
	end
end

function toggleQuadrantMap()
	local currentMap = HUD.getMapDisplay()
	if( currentMap=="QUADRANT") then
		HUD.setMapDisplay("NONE")
	else
		HUD.setMapDisplay("QUADRANT")
	end
end

function toggleUniverseMap()
	local currentMap = HUD.getMapDisplay()
	if( currentMap=="UNIVERSE") then
		HUD.setMapDisplay("NONE")
	else
		HUD.setMapDisplay("UNIVERSE")
	end
end

--- Creates a random ship
function createRandomShip(X,Y,Range,models,engines,weapons,alliance)
	if models==nil then
		local models = Epiar.models()
	end
	if engines==nil then
		local engines = Epiar.engines()
	end
	if weapons==nil then
		local weapons = Epiar.weapons()
	end
	if alliance==nil then
		alliance = choose(Epiar.alliances())
	end
	local name = choose( {
		"Bob", "Joe", "Fred", "Sally", "Frank",
		"Hillary", "Bruce", "Patrick", "Jimbo", "Richard",
		"John", "Chuck", "Arthur", "James", "Bill",
		"Helen", "Ken", "Marcus", "Violet", "Ethel",
		"Gary", "Scott", "Thomas", "Russel", "Steve",
	} )
	local X = X + about(Range)
	local Y = Y + about(Range)
	local model = choose(models)
	local engine = choose(engines)
	local plans = {"Hunter", "Trader", "Patrol", "Bully" }
	local pirateModels = { "Fleet Guard", "Kartanal", "Terran Assist", "Patitu", "Terran Corvert Mark I", "Large Vesper", "Raven", "Hammer Freighter"  }
	local escortModels = { "Fleet Guard", "Terran XV", "Kartanal", "Patitu", "Terran Corvert Mark I"  }

	local p = plans[math.random(#plans)]
	-- Turn some Hunters into anti-player Pirates if the player is far enough along
	if PLAYER:GetCredits() > 10000 and p == "Hunter" and math.random(20) == 1 then p = "Pirate" end
	if p == "Pirate" then
		model = pirateModels[math.random(#pirateModels)]
		engine = "Ion Engines"
	end

	s = Ship.new(name,X,Y,model,engine,p,alliance)

	if p == "Pirate" then
		setHuntHostile(s:GetID(), PLAYER:GetID() )
		local escort = Ship.new("an escort",X-150,Y-150, choose(escortModels), "Ion Engines","Escort",alliance)
		setAccompany(escort:GetID(), s:GetID())
	end

	s:SetRadarColor(255,0,0)

	-- give every AI the standard weapons of their ship class
	attachStandardWeapons(s,weapons)

        local creditsMax = math.random(40,90) * math.sqrt( s:GetTotalCost() )
        local randCredits = math.random( creditsMax )
	s:SetCredits(randCredits)

	return s
end

function attachStandardWeapons(cur_ship,weapons)

	-- first clear the weapon list
	for weap,ammo in pairs( cur_ship:GetWeapons() ) do
		cur_ship:RemoveFromWeaponList(weap)
	end

	-- then populate the weapon list from the standard slot contents
	for slot,weap in pairs( cur_ship:GetWeaponSlotContents() ) do
		cur_ship:AddToWeaponList(weap)
	end
end


--- List of options
function options()
	Epiar.pause()
	if UI.search("/Window'Options'/") ~= nil then
		closeOptions()
		return
	end
	local width=300
	local height=400
	local tabwidth=width-20
	local tabheight=height-100
	optionTabs = UI.newTabCont( 10, 30, tabwidth, tabheight,"Options Tabs")
	UI.newWindow( 30,100,width,height,"Options",
		optionTabs,
		UI.newButton( 60, height-50, 60, 30, "Save", "saveOptions(); closeOptions()" ),
		UI.newButton( 160, height-50, 60, 30, "Cancel", "closeOptions()" )
	)

	-- General Game Options
	-- ( No developer stuff here. )
	gameTab = UI.newTab("Game")
	optionTabs:add(gameTab)
	gameLabel      = UI.newLabel(20, 5, "Game Options:", 0)
	fullScreen      = UI.newCheckbox(20,  30, ( Epiar.getoption("options/video/fullscreen") ), "Run as Full Screen")
	randomUniverse  = UI.newCheckbox(20,  50, ( Epiar.getoption("options/simulation/random-universe") ), "Create a Random Universe")
	autoLoad        = UI.newCheckbox(20,  70, ( Epiar.getoption("options/simulation/automatic-load") ), "Automatically Load the last Player")
	gameTab:add( gameLabel, fullScreen, randomUniverse, autoLoad)

	-- Sounds
	soundsTab = UI.newTab("Audio")
	optionTabs:add(soundsTab)

	soundsLabel     = UI.newLabel(20, 5, "Sound Options:", 0)
	backgroundSound = UI.newCheckbox(20,  30, ( Epiar.getoption("options/sound/background") ), "Background sounds")
	weaponsSound    = UI.newCheckbox(20,  50, ( Epiar.getoption("options/sound/weapons")    ), "Weapons sounds")
	enginesSound    = UI.newCheckbox(20,  70, ( Epiar.getoption("options/sound/engines")    ), "Engines sounds")
	explosionsSound = UI.newCheckbox(20,  90, ( Epiar.getoption("options/sound/explosions") ), "Explosions sounds")
	buttonsSound    = UI.newCheckbox(20, 110, ( Epiar.getoption("options/sound/buttons")    ), "Buttons sounds")
	--[[soundVolume     = { Textbox = UI.newTextbox(20,  150, 30, 1,Epiar.getoption("options/sound/soundvolume")),
						Label = UI.newLabel(55, 165, "Sound volume (0-1)")}
	musicVolume     = { Textbox = UI.newTextbox(20,  170, 30, 1, Epiar.getoption("options/sound/musicvolume")),
						Label = UI.newLabel(55, 185, "Music volume (0-1)")}
						--]]
	soundVolume = { Slider = UI.newSlider(20, 140, 80, 16, "Sound Volume", Audio.getSoundVolume(), "Audio.setSoundVolume"),
					Label = UI.newLabel( 105, 140, "Sound Volume", 0)}
	musicVolume = { Slider = UI.newSlider(20, 170, 80, 16, "Music Volume", Audio.getMusicVolume(), "Audio.setMusicVolume"),
					Label = UI.newLabel( 105, 170, "Music Volume", 0)}
	soundsTab:add(  soundsLabel,
					backgroundSound,
					weaponsSound,
					enginesSound,
					explosionsSound,
					buttonsSound,
					soundVolume.Slider,
					soundVolume.Label,
					musicVolume.Slider,
					musicVolume.Label)

	-- Debugging
	debugTab = UI.newTab("Developer")
	optionTabs:add(debugTab)
	debugLabel      = UI.newLabel(20, 5, "Debug Options:", 0)
	xmlfileLogging  = UI.newCheckbox(20, 30, ( Epiar.getoption("options/log/xml") ), "Save Log Messages")
	stdoutLogging   = UI.newCheckbox(20, 50, ( Epiar.getoption("options/log/out") ), "Print Log Messages")
	alertLogging    = UI.newCheckbox(20, 70, ( Epiar.getoption("options/log/alert") ), "Alert Log Messages")
	uiLogging       = UI.newCheckbox(20, 90, ( Epiar.getoption("options/log/ui") ), "Save UI as XML")
	spriteLogging   = UI.newCheckbox(20,110 , ( Epiar.getoption("options/log/sprites") ), "Save Sprites as XML")
	aiStateDisplay  = UI.newCheckbox(20,130, ( Epiar.getoption("options/development/debug-ai") ), "Display AI State Machine")
	uiDebugging     = UI.newCheckbox(20,150, ( Epiar.getoption("options/development/debug-ui") ), "Display UI Debug Information")
	spritesMap      = UI.newCheckbox(20,170, ( Epiar.getoption("options/development/ships-worldmap") ), "Display Ships on the Universe Map")
	debugTab:add( debugLabel, xmlfileLogging, stdoutLogging, alertLogging, uiLogging, spriteLogging, aiStateDisplay, uiDebugging, spritesMap )

	-- Command Keys
	keyTab = UI.newTab( "Keyboard")
	optionTabs:add(keyTab)
	keyLabel = UI.newLabel(20, 5, "Keyboard Options:", 0)
	keyTab:add(keyLabel)
	local off_x,off_y = 20,30
	keyinput = {} -- Global. We'll need this later.
	labels = {}
	for i=1,#commands do
		local key, name = commands[i][1], commands[i][2]
		keyinput[name] = UI.newTextbox(off_x,off_y,70,1)
		keyinput[name]:setText(key)
		labels[name] = UI.newLabel(off_x+80,off_y-3,name)
		off_y = off_y +20
		keyTab:add(keyinput[name])
		keyTab:add(labels[name])
	end

	function saveOptions()
		-- General Game Options
		Epiar.setoption("options/video/fullscreen",           fullScreen      :IsChecked() and 1 or 0 )
		Epiar.setoption("options/simulation/random-universe", randomUniverse  :IsChecked() and 1 or 0 )
		Epiar.setoption("options/simulation/automatic-load",  autoLoad        :IsChecked() and 1 or 0 )

		-- Sound Options
		Epiar.setoption("options/sound/background", backgroundSound :IsChecked() and 1 or 0 )
		Epiar.setoption("options/sound/weapons",    weaponsSound    :IsChecked() and 1 or 0 )
		Epiar.setoption("options/sound/engines",    enginesSound    :IsChecked() and 1 or 0 )
		Epiar.setoption("options/sound/explosions", explosionsSound :IsChecked() and 1 or 0 )
		Epiar.setoption("options/sound/buttons",    buttonsSound    :IsChecked() and 1 or 0 )

		-- Developer Options
		Epiar.setoption("options/log/xml",          xmlfileLogging  :IsChecked() and 1 or 0 )
		Epiar.setoption("options/log/out",          stdoutLogging   :IsChecked() and 1 or 0 )
		Epiar.setoption("options/log/alert",        alertLogging    :IsChecked() and 1 or 0 )
		Epiar.setoption("options/log/ui",           uiLogging       :IsChecked() and 1 or 0 )
		Epiar.setoption("options/log/sprites",      spriteLogging   :IsChecked() and 1 or 0 )
		Epiar.setoption("options/development/debug-ai", aiStateDisplay :IsChecked() and 1 or 0 )
		Epiar.setoption("options/development/debug-ui", uiDebugging :IsChecked() and 1 or 0 )
		Epiar.setoption("options/development/ships-worldmap", spritesMap :IsChecked() and 1 or 0 )

		-- Keyboard Options
		for i=1,#commands do
			local oldkey, name = commands[i][1], commands[i][2]
			if keyinput[name] ~= nil then
				newkey = keyinput[name]:GetText()
				if newkey ~= oldkey then
					Epiar.UnRegisterKey(sdlkey(oldkey), commands[i][4])
					Epiar.RegisterKey(sdlkey(newkey), commands[i][4], commands[i][3])
					HUD.newAlert(string.format("Registered %q to %q", newkey, name))
					commands[i][1] = keyinput[name]:GetText()
				end
			end
		end
	end
	function closeOptions()
		UI.search("/Window'Options'/"):close();
		Epiar.unpause()
	end
end

function createSystems(seed)
	local alliances = Epiar.alliances()
	local technologies = Epiar.technologies()
	local r = 200000
	local stationGraphic = "Resources/Graphics/station1.png"
	local planetGraphics = {}
	for p=1,21 do
		table.insert(planetGraphics, "Resources/Graphics/planet"..p..".png" )
	end
	local system = {}

	-- Use a specific Seed to create these Systems
	if seed ~= nil then
		math.randomseed(seed)
	else
		randomizeseed()
	end

	-- Create a bunch of random Star Systems
	local starSystems = {
		"Xen", "Artegga", "Vazzen", "Rilburn", "Burasu",
		"Garor", "Hushaw", "Chenal", "Siana", "Hyanallophos",
		"Allyphos", "Eorith", "Hanacal", "Tyeosur", "Mosalia",
		"Untania", "Tonulia", "Anusia", "Denacia",
	}
	for s=1,#starSystems do
		local x = about(r)
		local y = about(r)
		local alliance = alliances[ math.random(#alliances) ]
		local numPlanets = math.random(3)
		local numStations = math.random(3) -1
		local numGates = math.random(3)-1
		system[s] = { ["x"]=x,
		              ["y"]=y,
		              ["alliance"]=alliance,
		              ["numPlanets"]=numPlanets,
		              ["numStations"]=numStations,
		              ["numGates"]=numGates}
	end

	-- Create a system at 0,0 so that new players are attached to the gate grid
	table.insert( system, { 
		              ["x"]=0,
		              ["y"]=0,
		              ["alliance"]=alliances[ math.random(#alliances) ],
		              ["numPlanets"]=0,
		              ["numStations"]=0,
		              ["numGates"]=0})
	for g=1,3 do
		local other = math.random(#starSystems)
		if other==systemNum then
			other=other+((other==#starSystems) and 1 or -1 )
		end
		local otherSystem = system[ other ]
		local gx = about(5000)
		local gy = about(5000)
		local ox = otherSystem.x + about(5000)
		local oy = otherSystem.y + about(5000)
		Epiar.NewGatePair(gx,gy,ox,oy)
	end

	for systemNum= 1,#starSystems do
		local systemName = starSystems[systemNum]
		local s = system[systemNum]

		-- Create the Planets
		for p=1,s.numPlanets do
			local px = s.x + about(30000)
			local py = s.y + about(30000)
			local name = systemName .." "..p
			Planet.NewPlanet(
				name,
				px,py,
				planetGraphics[ math.random(#planetGraphics) ],
				s.alliance,
				1,math.random(3)-1,math.random(3)-1,math.random(10)*1000,
				technologies[ math.random(#technologies) ]
				)
		end

		-- Create the Stations
		if s.numStations>0 then
			for n=1,s.numStations do
				local px = s.x + about(10000)
				local py = s.y + about(10000)
				local name = systemName .." Outpost "..n
				Planet.NewPlanet(
					name,
					px,py,
					stationGraphic,
					s.alliance,
					1,0,0,(30+math.random(100))*100,
					technologies[ math.random(#technologies) ]
					)
			end
		end

		-- Create the Gates
		if s.numGates>0 then
			for g=1,s.numGates do
				local otherSystem = system[ math.random(#starSystems) ]
				local gx = s.x + about(10000)
				local gy = s.y + about(10000)
				local ox = otherSystem.x + about(10000)
				local oy = otherSystem.y + about(10000)
				Epiar.NewGatePair(gx,gy,ox,oy)
			end
		end
	end
end

function createRandomShipForPlanet(id)
	planet = Epiar.getSprite(id)
	if (planet ~= nil) and (planet:GetType() == 0x01) then
		x,y = planet:GetPosition()
		influence = planet:Influence()
		models = planet:GetModels()
		engines = planet:GetEngines()
		weapons = planet:GetWeapons()
		alliance = planet:GetAlliance()
		createRandomShip(x,y,influence,models,engines,weapons)
	end
end

--- Buys a ship
function buyShip(model)
	if model==nil then
		local viewerLabel = UI.search("/Window/Tabs'Store'/'ShipYard'/Frame[1]/Label[0]/")
		if viewerLabel ~= nil then
			model = viewerLabel:GetText()
			print('Buying ',model)
		else
			print('Could not interpret nil model for buyShip()')
			return
		end
	end
	print('Buying ',model)
	local price = Epiar.getMSRP(model)
	local player_credits = PLAYER:GetCredits()
	if player_credits >= price then
		currentModel = PLAYER:GetModelName()
		if currentModel ~= model then
			PLAYER:SetCredits( player_credits - price + (2/3.0)*(Epiar.getMSRP(currentModel)) )
			HUD.newAlert("Enjoy your new "..model.." for "..price.." credits.")

			-- clear these based on the old slot list
			for slot,weap in pairs( PLAYER:GetWeaponSlotContents() ) do
				PLAYER:RemoveFromWeaponList(weap)
				HUD.closeStatus(weap..":");
			end

			PLAYER:SetModel(model) -- slot list gets updated by SetModel()
			PLAYER:ChangeWeapon()

			-- update weapon list and HUD to match the new slot list
			for slot,weap in pairs( PLAYER:GetWeaponSlotContents() ) do
				PLAYER:AddToWeaponList(weap)
				HUD.newStatus(weap..":",130,0, string.format("playerAmmo(%q)",weap))

				PLAYER:ChangeWeapon()
			end

			PLAYER:Repair(10000)
		else
			HUD.newAlert("You already have a "..model)
		end
	else
		HUD.newAlert("You can't afford to buy a "..model)
		HUD.newAlert(string.format("You only have %d credits, but you need %d.",player_credits,price))
	end
	return 1
end

function buyOutfit(outfit)
	if outfit==nil then
		local viewerLabel = UI.search("/Window/Tabs'Store'/'Outfitting'/Frame[1]/Label[0]/")
		if viewerLabel ~= nil then
			outfit = viewerLabel:GetText()
			print('Buying ',outfit)
		else
			print('Could not interpret nil model for buyShip()')
			return
		end
	end
	local price = Epiar.getMSRP(outfit)
	local player_credits = PLAYER:GetCredits()
	if player_credits < price then
		print("Account overdrawn...")
		HUD.newAlert("You can't afford to buy a "..outfit)
		return
	end

	print("Debiting your account...")

	PLAYER:SetCredits( player_credits - price )

	print("Installing Outfit...")
	
	if ( Set(Epiar.weapons())[outfit] ) then
		print("Weapon...")
		local weaponsAndAmmo = PLAYER:GetWeapons()

		local weapCount = 0;
		--for weap,ammo in pairs(weaponsAndAmmo) do weapCount = weapCount + 1 end
		for slot,weap in pairs( PLAYER:GetWeaponSlotContents() ) do
			if weap ~= "" then
				weapCount = weapCount + 1
			end
		end

		local weaponInfo = Epiar.getWeaponInfo(outfit)
		if weaponInfo["Ammo Consumption"] ~= 0 then
			PLAYER:AddAmmo(outfit,100)
			HUD.newAlert( (string.format("Added 100 ammo for %s",outfit ) ) )
		end

		local wsCount = PLAYER:GetWeaponSlotCount();
		if weapCount >= wsCount then
			HUD.newAlert( "You can't hold any more weapons" )
			return
		end

		HUD.newAlert("Enjoy your new "..outfit.." system for "..price.." credits")
		PLAYER:AddWeapon(outfit)
		HUD.newStatus(outfit..":",130,0, string.format("playerAmmo(%q)",outfit))
	elseif ( Set(Epiar.engines())[outfit] ) then
		print("Engine...")
		PLAYER:SetEngine(outfit)
		HUD.newAlert("Enjoy your new "..outfit.." system for "..price.." credits")
	elseif ( Set(Epiar.outfits())[outfit] ) then
		print("Outfit...")
		PLAYER:AddOutfit(outfit)
		HUD.newAlert("Enjoy your new "..outfit.." system for "..price.." credits")
	else
		print("Unknown Outfit: "..outfit)
	end
	print("Outfit Purchase complete")
end

function sellOutfit(outfit)
	if outfit==nil then
		local viewerLabel = UI.search("/Window/Tabs'Store'/'Outfitting'/Frame[1]/Label[0]/")
		if viewerLabel ~= nil then
			outfit = viewerLabel:GetText()
			print('Selling ',outfit)
		else
			print('Could not interpret nil model for buyShip()')
			return
		end
	end

	print("Removing Outfit...")

	if ( Set(Epiar.weapons())[outfit] ) then
		print("Weapon...")
		local weaponsAndAmmo = PLAYER:GetWeapons()
		if weaponsAndAmmo[outfit]~=nil then
			PLAYER:RemoveWeapon(outfit)
			HUD.closeStatus(outfit..":");
		else
			HUD.newAlert("You don't have a "..outfit.."!")
			return
		end
		local weaponInfo = Epiar.getWeaponInfo(outfit)
		if weaponInfo["Ammo Consumption"] ~= 0 then
			-- Do something about selling a weapon that has ammo. I'm thinking
			-- it should remove 100 ammo with each sale, and RemoveAmmo()
			-- should set ammo to zero if it would have gone negative.
			--PLAYER:RemoveAmmo(outfit,100)
			-- Or, better yet, ammunition should be bought and sold separately.
		end
	elseif ( Set(Epiar.engines())[outfit] ) then
		print("Engine...")
		HUD.newAlert("You can't sell your engines!")
		return

	elseif ( Set(Epiar.outfits())[outfit] ) then
		print("Outfit...")
		local playerOutfits = PLAYER:GetOutfits()

		local found = false

		for n,po in pairs(playerOutfits) do
			if po == outfit then
				if found == false then PLAYER:RemoveOutfit(outfit) end
				found = true
			end
		end

		if found == false then
			HUD.newAlert("You don't have a "..outfit.."!")
			return
		end
		
	else
		print("Unknown Outfit: "..outfit)
		return
	end

	local price = Epiar.getMSRP(outfit)
	local adjustedPrice = math.floor( price * 0.65) -- only get back 65% of MSRP

	local player_credits = PLAYER:GetCredits()

	print("Crediting your account...")

	PLAYER:SetCredits( player_credits + adjustedPrice )
	HUD.newAlert("You sold your "..outfit.." system for "..adjustedPrice.." credits")
	print("Outfit Selling complete")
end

--- Trade a Commodity
function tradeCommodity(transaction, commodity, count, price)
	local player_credits = PLAYER:GetCredits()
	local cargo,stored,storable = PLAYER:GetCargo()
	print "Trading..."
	if transaction=="buy" then
		print("Tonnage available:",storable-stored)
		print("Tonnage requested:",count)
		print("Tonnage affordable:",player_credits/price)
		trueCount = math.min(storable-stored,count,math.floor(player_credits/price)) -- Can't buy more than this
		stored = PLAYER:StoreCommodities( commodity,trueCount )
		if(stored ~= trueCount) then
			print("ARG! That wasn't supposed to happen!")
		end
		PLAYER:SetCredits( player_credits - trueCount*price )
		HUD.newAlert(string.format("You bought %d tons of %s for %d credits",trueCount,commodity,price*trueCount))
	elseif transaction=="sell" then
		print("Tonnage stored:",cargo[commodity] or 0)
		print("Tonnage requested:",count)
		trueCount = math.min(count,cargo[commodity] or 0) -- Can't sell more than this
		print("Discarding "..trueCount.." Tonnes")
		discarded = PLAYER:DiscardCommodities( commodity,trueCount )
		print("Discarded "..discarded.." Tonnes")
		if(discarded ~= trueCount) then
			print("ARG! That wasn't supposed to happen!")
		end
		PLAYER:SetCredits( player_credits + trueCount*price )
		HUD.newAlert(string.format("You sold %d tons of %s for %d credits",trueCount,commodity,price*trueCount))
	else
		error( string.format( "Sorry, trading Commodities doesn't understand transaction %q", transaction ) )
	end
	
	local commodityBox = UI.search(string.format("/Window/'Store'/'Trade'/Textbox%q/", commodity))
	if commodityBox ~= nil then
		local cargo,stored,storable = PLAYER:GetCargo()
		commodityBox:setText( cargo[commodity] or 0)
	end

	print "Done Trading..."
	return 1
end

function storeView(containerPath, itemType, itemName )
	local getters = {
		["ship"]=Epiar.getModelInfo,
		["weapon"]=Epiar.getWeaponInfo,
		["engine"]=Epiar.getEngineInfo,
		["outfit"]=Epiar.getOutfitInfo,
	}
	local iteminfo = getters[itemType](itemName)

	-- Reset the Item Viewer
	local viewer = UI.search( containerPath .. "Frame[1]/")
	if viewer ~= nil then viewer:close() end
	viewer = UI.newFrame( 180, 10, 390, 325)
	UI.search( containerPath ):add( viewer )

	viewer:add( UI.newLabel(195, 15, iteminfo["Name"], 1) )
	viewer:add( UI.newLabel(195, 35, iteminfo["MSRP"] .. " Credits", 1) )

	local yoff = 50
	viewer:add( UI.newPicture(10, yoff, 200, 200, iteminfo["Picture"] or iteminfo["Image"]) )

	for statname,value in pairs(iteminfo) do
		-- print(statname, value )
		-- Skip these kinds
		if statname == "Name"
		or statname == "MSRP"
		or statname == "Picture"
		or statname == "Image"
		or statname == "Sound"
		or statname == "Animation"
		or type(value) == "table" then
			-- Do Nothing
		else
			if type(value)=="number" and math.floor(value) ~= value then
				value = string.format("%.2f", value)
			end
			viewer:add( UI.newLabel(220, yoff, statname) )
			viewer:add( UI.newLabel(330, yoff, value) )
			yoff = yoff + 21
		end
	end

end

--- Land on a planet
function landingDialog(id)
	-- Create the Planet Landing Screen
	if UI.search("/Window/Tabs'Store'/") ~= nil then return end

	Epiar.pause()
	planet = Epiar.getSprite(id)
	
	local height = 500
	local width = 600
	local boxsize = 120

	landingWin = UI.newWindow( 200,100,width,height, string.format("%s",planet:GetName()))
	storeframe = UI.newTabCont( 10, 30, width - 20, height - 80,"Store")
	landingWin:add(storeframe)

	function addToStoreList( storeList, list, yoff, cmd, container )
		for i,name in ipairs(list) do
			local callback = string.format( cmd, container, name )
			local pic = UI.newPicture( 15, yoff, boxsize, boxsize, name, 0, 0, 0, 1)
			pic:setLuaClickCallback( callback )
			storeList:add( pic )
			storeList:add( UI.newButton( 15, yoff+boxsize, boxsize, 20, name, callback ))
			yoff = yoff + 30 + boxsize
		end
		return yoff
	end

	-- Shipyard
	local shipyard = UI.newTab("ShipYard")
	local shipList = UI.newFrame( 10, 10, 160, 360 )
	shipyard:add( shipList )
	local yoff = 10
	local models = planet:GetModels()
	yoff = addToStoreList( shipList, models, yoff, "storeView(%q, 'ship', %q)",  "/Window/Tabs'Store'/'ShipYard'/" )
	shipyard:add( UI.newButton( width-150,340,100,30,"Buy","buyShip()" ))
	storeframe:add(shipyard)

	storeView( "/Window/Tabs'Store'/'ShipYard'/" , 'ship',models[1])

	-- Outfitting
	outfitting = UI.newTab("Outfitting")
	local outfitList = UI.newFrame( 10, 10, 160, 360 )
	outfitting:add( outfitList )
	yoff = 10
	local weapons = planet:GetWeapons()
	local engines = planet:GetEngines()
	local outfits = planet:GetOutfits()
	yoff = addToStoreList( outfitList, weapons, yoff, "storeView(%q, 'weapon', %q)", "/Window/Tabs'Store'/'Outfitting'/")
	yoff = addToStoreList( outfitList, engines, yoff, "storeView(%q, 'engine', %q)", "/Window/Tabs'Store'/'Outfitting'/")
	yoff = addToStoreList( outfitList, outfits, yoff, "storeView(%q, 'outfit', %q)", "/Window/Tabs'Store'/'Outfitting'/")
	storeframe:add(outfitting)
	outfitting:add( UI.newButton( width-250,340,100,30,"Sell","sellOutfit()" ))
	outfitting:add( UI.newButton( width-150,340,100,30,"Buy","buyOutfit()" ))

	if #weapons > 0 then     storeView( "/Window/Tabs'Store'/'Outfitting'/" , 'weapon', weapons[1])
	elseif #engines > 0 then storeView( "/Window/Tabs'Store'/'Outfitting'/" , 'engine', engines[1])
	elseif #outfits > 0 then storeView( "/Window/Tabs'Store'/'Outfitting'/" , 'outfit', outfits[1])
	end

	-- Trade
	trade = UI.newTab("Trade")
	tradeCounts = {} -- This global variable
	local commodities = Epiar.commodities()
	local currentCargo,stored,storable = PLAYER:GetCargo()
	for i,commodity in pairs(commodities) do
		local yoff = 20+i*20
		local msrp = Epiar.getMSRP(commodity)
		local price_offset = math.random(-3,3)
		local priceMeanings = { "(Very Low)","(Low)","","","","(High)","(Very High)" }
		local price = msrp + ( price_offset*msrp/10 )
		--print (commodity.."is "..priceMeanings[price_offset+4].." at "..price.." instead of "..msrp)
		local count = 10
		trade:add( UI.newLabel(10,yoff,string.format("%s at %d %s",commodity,price,priceMeanings[price_offset+4]),0) )
		tradeCounts[commodity] = UI.newTextbox(300,yoff,30,1, currentCargo[commodity] or 0, commodity)
		trade:add( tradeCounts[commodity] )
		trade:add( UI.newButton(330,yoff,30,20,"Buy",string.format("tradeCommodity('buy',%q,%d,%d)",commodity,count,price )))
		trade:add( UI.newButton(360,yoff,30,20,"Sell",string.format("tradeCommodity('sell',%q,%d,%d)",commodity,count,price )))
	end
	storeframe:add(trade)

	-- Employment
	missions = UI.newTab("Employment")
	availableMissionsTypes = {"ReturnAmbassador", "DestroyPirate", "CollectArtifacts", "ShippingRoutes", "ProtectFreighter" }
	rareMissionTypes = {"DestroyGaryTheGold"}
	availableMissions = {} -- This is a global variable
	yoff = 5
	local numMissions = math.random(2,7)
	for i = 1,numMissions do
		local missionType
		if math.random(50) == 1 then
			missionType = choose(rareMissionTypes)
		else
			missionType = choose(availableMissionsTypes)
		end
		availableMissions[i] = _G[missionType].Create()
		missions:add(
			UI.newFrame( 10, yoff, width -70, 150,
				UI.newLabel( 10, 10, availableMissions[i].Name ),
				UI.newLabel( 10, 40, linewrap(availableMissions[i].Description) ),
				UI.newButton( width-190, 20, 100, 20, "Accept",  string.format("PLAYER:AcceptMission(%q, availableMissions[%d])", missionType, i) )
			)
		)
		yoff = yoff + 170
	end
	storeframe:add(missions)

	landingWin:add(UI.newButton( 10,height-40,100,30,"Repair","PLAYER:Repair(10000)" ))
	landingWin:add(UI.newButton( 110,height-40,100,30,"Weapon Config","weaponConfigDialog()" ))
	landingWin:add(UI.newButton( width-110,height-40,100,30,string.format("Leave "), "Epiar.savePlayer();Epiar.unpause();landingWin:close();landingWin=nil" ))
end

function intro()
	local height = 550
	local width = 600
	introWin = UI.newWindow( 200, 100, width, height, "Welcome to Epiar")
	
	introWin:add(
		UI.newLabel( 50, 50, welcomeMessage),
		UI.newButton( width/2-50, height-70, 100, 30, "I'm Ready!", "introComplete()")
	)

	Epiar.pause()
end

function introComplete()
	if UI.search("/Window'Welcome to Epiar'/") == nil then return end
	introWin:close()
	introWin = nil
	-- Unpause if the player loading screen isn't active
	if PLAYER ~= nil then Epiar.unpause() end
end

--- UI demo
function ui_demo()
	if UI.search("/Window'User Interface Demo'/") ~= nil then return end

	-- Create the widgets
	demo_win = UI.newWindow( 200, 100, 400, 300, "User Interface Demo")
	demo_text1 = UI.newTextbox( 50, 50, 100, 1)
	demo_text2 = UI.newTextbox( 250, 50, 100, 1)
	demo_drop = UI.newDropdown( 250, 100, 100, 30, {"A","B","C"})
	io.write("DEBUG '"..( Epiar.getoption("options/development/debug-quadtree") ).."'\n")

	-- Modify the Widgets
	demo_swap = function()
		s1 = demo_text1:GetText()
		s2 = demo_text2:GetText()
		demo_text1:setText(s2)
		demo_text2:setText(s1)
	end

	demo_button = UI.newButton( 175, 50, 14*3, 18, "<->", "demo_swap()")

	-- Attach the widgets to the window
	demo_win:add(demo_text1)
	demo_win:add(demo_text2)
	demo_win:add(demo_button)
	demo_win:add(demo_drop)

	demo_win:setFormButton( demo_button )
end

-- interactive weapon slot configuration
function weaponConfigDialog()
	if UI.search("/Window'Weapon Configuration'/") ~= nil then return end

	local slotCount = PLAYER:GetWeaponSlotCount()

	local height = 60 + (40*slotCount)
	if height < 275 then height = 275 end -- accommodate the instruction text

	local width = 500

	local leftFrame = UI.newFrame( 10, 60, 240, height )
	local rightFrame = UI.newFrame( 250, 60, 240, height )

	local slotPlural = ""
	if slotCount ~= 1 then slotPlural = "s" end
	local shipLabel = UI.newLabel(20, 30, (string.format("Your %s has %d weapon slot%s...", PLAYER:GetModelName(), slotCount, slotPlural)), 0)
	local slotsLabel = UI.newLabel(50, 10, "Weapon slot:", 0)
	local fgLabel = UI.newLabel(150, 10, "Firing group:", 0)

	--local weapLabel = UI.newLabel(25, 5, "Weapons available:", 0)

	local wcInstructions = [[To move a weapon from one slot to another, click on the first slot, then click on the one you want to swap it with.

				There are two firing groups, Primary and Secondary. To switch the firing group of a slot, click on the firing group button.

				Although you may have your own preferences, it is recommended that, if you have a weapon which requires ammo (e.g. missile launcher), you keep it in a firing group separate from your main group.

				Grouping missiles into a salvo is a possibility if you have more than one launcher.]]

	wcInstructions = linewrap( string.gsub(wcInstructions, "\t*", ""), 32, true )

	local instructionsLabel = UI.newLabel(25, 5, wcInstructions, 0)

	local wcDialog = UI.newWindow( 300,50,width,height+30+30+40, "Weapon Configuration")

	wcDialog:add(shipLabel)
	wcDialog:add(leftFrame, rightFrame);
	wcDialog:add(UI.newButton( 200, height+30+30, 100, 30, "Finish", "weaponConfigFinish()"))

	leftFrame:add(slotsLabel, fgLabel);
	rightFrame:add(instructionsLabel);

	-- when assignWeaponToSlot() is called, if this is nil, set it;
	-- if it's set, swap the slot contents, update the buttons,
	-- then set it back to nil.
	pickedSlot = nil

	slotButtons = { }
	slotFGButtons = { }

	for slot =0,(slotCount-1) do
		local slotName = PLAYER:GetWeaponSlotName(slot)
		local slotStatus = PLAYER:GetWeaponSlotStatus(slot)
		local slotFG = PLAYER:GetWeaponSlotFG(slot)
		local slotFGName = "Primary"
		if slotFG == 1 then slotFGName = "Secondary" end

		local slotLabel = UI.newLabel( 15, 45+(40*slot), (string.format("%s:", slotName)), 0)
		slotButtons[slot] = UI.newButton( 50, 45+(40*slot)+20, 100, 20, (string.format("%s", slotStatus)), (string.format("assignWeaponToSlot(%d)", slot)))
		slotFGButtons[slot] = UI.newButton( 150, 45+(40*slot)+20, 75, 20, slotFGName, (string.format("alternateFiringGroup(%d)", slot)))
		leftFrame:add(slotLabel,slotButtons[slot],slotFGButtons[slot]);
	end

	local w = 0

end

function assignWeaponToSlot(slot)
	if(pickedSlot == nil) then
		pickedSlot = slot
	else
		-- swap contents of pickedSlot and slot
		local s = PLAYER:GetWeaponSlotStatus(slot)
		PLAYER:SetWeaponSlotStatus(slot, PLAYER:GetWeaponSlotStatus(pickedSlot) )
		PLAYER:SetWeaponSlotStatus(pickedSlot, s)

		-- now they have been swapped, so update the buttons
		slotButtons[slot]:setText( PLAYER:GetWeaponSlotStatus(slot) )
		slotButtons[pickedSlot]:setText( PLAYER:GetWeaponSlotStatus(pickedSlot) )

		pickedSlot = nil
	end
end

function alternateFiringGroup(slot)
	local fg = PLAYER:GetWeaponSlotFG(slot)
	fg = (fg+1)%2
	PLAYER:SetWeaponSlotFG(slot, fg)
	slotFGButtons[slot]:setText( (PLAYER:GetWeaponSlotFG(slot) == 0 and "Primary" or "Secondary") )
end

function weaponConfigFinish()
	-- the slot editing itself took place while the dialog was open, so nothing more needs to be done at this point
	local wcDialog = UI.search("/Window'Weapon Configuration'/")
	-- this should cover all widget cleanup
	wcDialog:close()
end
