-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.pause()


	-- create a grey rectangle as the backdrop
	-- the physical screen will likely be a different shape than our defined content area
	-- since we are going to position the background from it's top, left corner, draw the
	-- background at the real top, left corner.
	local background = display.newImageRect ("background.png", display.actualContentWidth, 1080 )
	background.x = display.contentCenterX 
	background.y = display.contentCenterY + 50
 	--background.anchorX = 0 
	--background.anchorY = 0
	--background:setFillColor( .5 )
	
	-- make a crate (off-screen), position it, and rotate slightly
	--local crate = display.newImageRect( "crate.png", 90, 90 )
	--crate.x, crate.y = 160, -100
	--crate.rotation = 15
	
	-- add physics to the crate
	--physics.addBody( crate, { density=1.0, friction=0.3, bounce=0.3 } )
	
	-- create a grass object and add physics (with custom shape)
	local grass = display.newImageRect( "ground.png", display.contentWidth+50, 250 )
	--grass.anchorX = 0
	--grass.anchorY = 1
	--  draw the grass at the very bottom of the screen
	grass.x = display.contentCenterX
	grass.y = display.contentCenterY*2.4- grass.height
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local grassShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	physics.addBody( grass, "static", { friction=0.3, shape=grassShape } )

	local returnButton = display.newImageRect("9.png", 50,50)
	returnButton.x = 200
	returnButton.y = 150

	-- SOUND 
	audio.setVolume(1)
	local soundTable = {
		rockFX = audio.loadSound("rockFX.mp3"),
		scissorFX = audio.loadSound("scissorFX.mp3"),
		paperFX = audio.loadSound("paperFX.mp3")
	}
	backgroundMusic = audio.loadStream("bensound-energy.mp3",0)

	-- CREATING PLAYERS
	local player1 = display.newImageRect("crate.png", 90, 90)
	player1.x = display.contentCenterX - display.contentCenterX / 1.2
	player1.y = grass.y - 90
	physics.addBody(player1, "static")

	local player2 = display.newImageRect("crate.png", 90, 90)
	player2.x = display.contentCenterX + display.contentCenterX / 1.2
	player2.y = grass.y - 90
	physics.addBody(player2, "static")
	

	-- BUTTONS
	local rock1 = display.newImageRect("rock.png", 70,70)
	rock1.x = player1.x - 20
	rock1.y = player1.y - 425

	local rock2 = display.newImageRect("rock.png", 70,70)
	rock2.x = player2.x + 20
	rock2.y = player2.y - 425

	local scissor1 = display.newImageRect("scissor.png", 50,70)
	scissor1.x = player1.x - 20
	scissor1.y = player1.y - 300

	local scissor2 = display.newImageRect("scissor.png", 50,70)
	scissor2.x = player2.x + 20
	scissor2.y = player2.y - 300

	local paper1 = display.newImageRect("paper.png", 50,70)
	paper1.x = player1.x - 20
	paper1.y = player1.y - 175

	local paper2 = display.newImageRect("paper.png", 50,70)
	paper2.x = player2.x + 20
	paper2.y = player2.y - 175

	-- GARBAGE COLLECTOR
	local function destroyObj (obj)
		if obj ~= nil then
			obj:removeSelf()
		end
	end

	-- EVENT LISTENER
	local function rock1Tap()
		local text1 = display.newText("Rock1 tapped", 264, 10, native.systemFont, 60)
		text1.x = display.contentCenterX
		text1.y = 100
		sceneGroup:insert( text1)
		transition.fadeOut(text1, {time = 1000})

		local rockBullet1 = display.newImageRect("rock.png", 40, 40)
		rockBullet1.x = player1.x
		rockBullet1.y = player1.y-5
		physics.addBody(rockBullet1, "dynamic")
		rockBullet1.gravityScale = 0
		rockBullet1.isBullet = true
		rockBullet1:setLinearVelocity(400,0)
		rockBullet1.myName = "ROCK"
		sceneGroup:insert(rockBullet1)
		audio.play(soundTable["rockFX"])
	end

	local function scissor1Tap()
		local text1 = display.newText("Scissor1 tapped", 264, 10, native.systemFont, 60)
		text1.x = display.contentCenterX
		text1.y = 100
		sceneGroup:insert( text1)
		transition.fadeOut(text1, {time = 1000})

		local scissorBullet1 = display.newImageRect("scissor.png", 40, 40)
		scissorBullet1.x = player1.x
		scissorBullet1.y = player1.y-5
		physics.addBody(scissorBullet1, "dynamic")
		scissorBullet1.gravityScale = 0
		scissorBullet1.isBullet = true
		scissorBullet1:setLinearVelocity(400,0)
	    scissorBullet1.myName = "SCISSOR"
		sceneGroup:insert(scissorBullet1)
		audio.play(soundTable["scissorFX"])
	end

	local function paper1Tap()
		local text1 = display.newText("Paper1 tapped", 264, 10, native.systemFont, 60)
		text1.x = display.contentCenterX
		text1.y = 100
		sceneGroup:insert( text1)
		transition.fadeOut(text1, {time = 1000})

		local paperBullet1 = display.newImageRect("paper.png", 40, 40)
		paperBullet1.x = player1.x
		paperBullet1.y = player1.y-5
		physics.addBody(paperBullet1, "dynamic")
		paperBullet1.gravityScale = 0
		paperBullet1.isBullet = true
		paperBullet1:setLinearVelocity(400,0)
		sceneGroup:insert(paperBullet1)
		paperBullet1.myName = "PAPER"
		audio.play(soundTable["paperFX"])
	end

	local function rock2Tap()
		local text1 = display.newText("Rock2 tapped", 264, 10, native.systemFont, 60)
		text1.x = display.contentCenterX
		text1.y = 100
		sceneGroup:insert( text1)
		transition.fadeOut(text1, {time = 1000})

		local rockBullet2 = display.newImageRect("rock.png", 40, 40)
		rockBullet2.x = player2.x
		rockBullet2.y = player2.y-5
		physics.addBody(rockBullet2, "dynamic")
		rockBullet2.gravityScale = 0
		rockBullet2.isBullet = true
		rockBullet2:setLinearVelocity(-400,0)
		rockBullet2.myName = "ROCK"
		sceneGroup:insert(rockBullet2)
		audio.play(soundTable["rockFX"])
	end

	local function scissor2Tap()
		local text1 = display.newText("Rock2 tapped", 264, 10, native.systemFont, 60)
		text1.x = display.contentCenterX
		text1.y = 100
		sceneGroup:insert( text1)
		transition.fadeOut(text1, {time = 1000})

		local scissorBullet2 = display.newImageRect("scissor.png", 40, 40)
		scissorBullet2.x = player2.x
		scissorBullet2.y = player2.y-5
		physics.addBody(scissorBullet2, "dynamic")
		scissorBullet2.gravityScale = 0
		scissorBullet2.isBullet = true
		scissorBullet2:setLinearVelocity(-400,0)
		scissorBullet2.myName = "SCISSOR"
		sceneGroup:insert(scissorBullet2)
		audio.play(soundTable["scissorFX"])
	end

	local function paper2Tap()
		local text1 = display.newText("Rock2 tapped", 264, 10, native.systemFont, 60)
		text1.x = display.contentCenterX
		text1.y = 100
		sceneGroup:insert( text1)
		transition.fadeOut(text1, {time = 1000})

		local paperBullet2 = display.newImageRect("paper.png", 40, 40)
		paperBullet2.x = player2.x
		paperBullet2.y = player2.y-5
		physics.addBody(paperBullet2, "dynamic")
		paperBullet2.gravityScale = 0
		paperBullet2.isBullet = true
		paperBullet2:setLinearVelocity(-400,0)
		paperBullet2.myName = "PAPER"
		sceneGroup:insert(paperBullet2)
		audio.play(soundTable["paperFX"])
	end

	local function returnButtonTap()
		composer.gotoScene( "menu", "fade", 500 )
	end

	-- COLLSION HANDLER 
	local function onGlobalCollision(event)
		if event.phase == "ended" then
		    -- same object RR, SS, PP (1-3)
			if event.object1.myName == event.object2.myName then
				destroyObj(event.object1)
				destroyObj(event.object2)
				print("case 1-3")
			-- R vs S case (4))
			elseif event.object1.myName == "ROCK" and event.object2.myName == "SCISSOR" then
				destroyObj(event.object1)
				print("case 4")
			-- S vs R case (5)
			elseif event.object1.myName == "SCISSOR" and event.object2.myName == "ROCK" then
				destroyObj(event.object2)
				print("case 5")
			-- R vs P case
			elseif event.object1.myName == "ROCK" and event.object2.myName == "PAPER" then
				destroyObj(event.object1)
				print("case 6")
			-- P vs R case
			elseif event.object1.myName == "PAPER" and event.object2.myName == "ROCK" then
				destroyObj(event.object2)
				print("case 7")
			-- S vs P case
			elseif event.object1.myName == "SCISSOR" and event.object2.myName == "PAPER" then
				destroyObj(event.object1)
				print("case 8")
			-- P vs S case
			elseif event.object1.myName == "PAPER" and event.object2.myName == "SCISSOR" then
				destroyObj(event.object2)
				print("case 9")
			end
		end
	end

	-- LISTENER
	rock1:addEventListener("tap", rock1Tap)
	rock2:addEventListener("tap", rock2Tap)
	scissor1:addEventListener("tap", scissor1Tap)
	scissor2:addEventListener("tap", scissor2Tap)
	paper1:addEventListener("tap", paper1Tap)
	paper2:addEventListener("tap", paper2Tap)
	returnButton:addEventListener("tap", returnButtonTap)
	
	Runtime:addEventListener("collision", onGlobalCollision)

	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( grass)
	sceneGroup:insert( player1 )
	sceneGroup:insert( player2 )
	sceneGroup:insert( rock1 )
	sceneGroup:insert( rock2 )
	sceneGroup:insert( scissor1 )
	sceneGroup:insert( scissor2 )
	sceneGroup:insert( paper1 )
	sceneGroup:insert( paper2 )
	sceneGroup:insert (returnButton)

end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
		audio.play(backgroundMusic)
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		--audio.fade( 500 )
		audio.stop( )
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene