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
	returnButton.x = 100
	returnButton.y = 50

	-- SOUND 
	audio.setVolume(1)
	local soundTable = {
		rockFX = audio.loadSound("rockFX.mp3"),
		scissorFX = audio.loadSound("scissorFX.mp3"),
		paperFX = audio.loadSound("paperFX.mp3")
	}
	backgroundMusic = audio.loadStream("bensound-energy.mp3",0)
	function startGame()
		-- GAME CONFIGURATION
		local player1HP = 20
		local player2HP = 20
		local bulletSpeed = 400
		local impact = -1

		local sheetData1 = {
			width = 276.29,
			height = 238.29,
			numFrames = 49,
			sheetContentWidth = 1934,
			sheetContentHeight = 1668
		}
		local sheet1 = graphics.newImageSheet("2.png",sheetData1)
		local sequenceDataCat = {
			{
				name = "idle",
				frames = {5,6,7,12,13,14,19,20,21,26},
				time = 3000,
				loopCount = 0
			},
			{
				name = "sad",
				--frames = {1,2,3,4,8,9,10,15,16,17},
				frames = {2,3,2,3,2,3,2,3,2,3},
				time = 1000,
				loopCount = 0
			},
			{
				name = "happy",
				frames = {29,30,31,36,37,38,43,44},
				time = 1000,
				loopCount = 0
			}
		};
		local player1 = display.newSprite(sheet1,sequenceDataCat)
		local player2 = display.newSprite(sheet1,sequenceDataCat)

		-- CREATING PLAYERS
		--local player1 = display.newImageRect("crate.png", 90, 90)
		player1.x = display.contentCenterX - display.contentCenterX / 1.2
		player1.y = grass.y - 90
		player1:scale(0.5,0.5)
		player1:play()

		--local player2 = display.newImageRect("crate.png", 90, 90)
		player2.x = display.contentCenterX + display.contentCenterX / 1.2
		player2.y = grass.y - 90
		player2:scale(-0.5,0.5)
		player2:play()

		-- HP bar
		local healthBar1 = display.newRect(300,300,100,10)
		healthBar1.x = player1.x
		healthBar1.y = player1.y - 80
		healthBar1:setFillColor(0,255,0)

		local damageBar1 = display.newRect(300,300,100,10)
		damageBar1:setFillColor(255,0,0)
		damageBar1.x = player1.x
		damageBar1.y = player1.y - 80
		damageBar1.strokeWidth = 1
		damageBar1:setStrokeColor(255,255,255,0.5)
		-- hp = 20, bar = 100, - 5 each times 

		local healthBar2 = display.newRect(300,300,100,10)
		healthBar2.x = player2.x
		healthBar2.y = player2.y - 80
		healthBar2:setFillColor(0,255,0)

		local damageBar2 = display.newRect(300,300,100,10)
		damageBar2:setFillColor(255,0,0)
		damageBar2.x = player2.x
		damageBar2.y = player2.y - 80
		damageBar2.strokeWidth = 1
		damageBar2:setStrokeColor(255,255,255,0.5)

		--hit box
		local hitBox1 = display.newRect(300,300,30,30)
		hitBox1.x = player1.x
		hitBox1.y = player1.y
		hitBox1:setFillColor(255,255,255)
		physics.addBody(hitBox1, "static")
		hitBox1.myName = "PLAYER1"
		hitBox1.alpha = 0

		local hitBox2 = display.newRect(300,300,30,30)
		hitBox2.x = player2.x
		hitBox2.y = player2.y
		hitBox2:setFillColor(255,255,255)
		physics.addBody(hitBox2, "static")
		hitBox2.myName = "PLAYER2"
		hitBox2.alpha = 0

		-- BUTTONS
		local rock1 = display.newImageRect("rock.png", 70,70)
		rock1.x = player1.x - 20
		rock1.y = player1.y - 425
		local label1 = display.newText("Q",264,10, native.systemFont, 30)
		label1.x = rock1.x
		label1.y = rock1.y-60

		local rock2 = display.newImageRect("rock.png", 70,70)
		rock2.x = player2.x + 20
		rock2.y = player2.y - 425
		local label2 = display.newText("I",264,10, native.systemFont, 30)
		label2.x = rock2.x
		label2.y = rock2.y-60

		local scissor1 = display.newImageRect("scissor.png", 50,70)
		scissor1.x = player1.x - 20
		scissor1.y = player1.y - 300
		local label3 = display.newText("W",264,10, native.systemFont, 30)
		label3.x = scissor1.x
		label3.y = scissor1.y-60

		local scissor2 = display.newImageRect("scissor.png", 50,70)
		scissor2.x = player2.x + 20
		scissor2.y = player2.y - 300
		local label4 = display.newText("O",264,10, native.systemFont, 30)
		label4.x = scissor2.x
		label4.y = scissor2.y-60

		local paper1 = display.newImageRect("paper.png", 50,70)
		paper1.x = player1.x - 20
		paper1.y = player1.y - 175
		local label5 = display.newText("E",264,10, native.systemFont, 30)
		label5.x = paper1.x
		label5.y = paper1.y-60

		local paper2 = display.newImageRect("paper.png", 50,70)
		paper2.x = player2.x + 20
		paper2.y = player2.y - 175
		local label6 = display.newText("P",264,10, native.systemFont, 30)
		label6.x = paper2.x
		label6.y = paper2.y-60
	
		-- GARBAGE COLLECTOR
		local function destroyObj (obj)
			if obj ~= nil then
				obj:removeSelf()
			end
		end

		-- EVENT LISTENER
		local function onKeyEvent(event)
			if event.keyName == "q" then
				local rockBullet1 = display.newImageRect("rock.png", 40, 40)
				rockBullet1.x = player1.x+30
				rockBullet1.y = player1.y-5
				physics.addBody(rockBullet1, "dynamic",{ radius = 10, bounce = 0.5 })
				rockBullet1.gravityScale = 0
				rockBullet1.isBullet = true
				rockBullet1:setLinearVelocity(bulletSpeed,0)
				rockBullet1.myName = "ROCK"
				sceneGroup:insert(rockBullet1)
				audio.play(soundTable["rockFX"])
			elseif event.keyName == "w" then
				local scissorBullet1 = display.newImageRect("scissor.png", 40, 40)
				scissorBullet1.x = player1.x+30
				scissorBullet1.y = player1.y-5
				physics.addBody(scissorBullet1, "dynamic",{ radius = 10, bounce = 0.5 })
				scissorBullet1.gravityScale = 0
				scissorBullet1.isBullet = true
				scissorBullet1:setLinearVelocity(bulletSpeed,0)
				scissorBullet1.myName = "SCISSOR"
				sceneGroup:insert(scissorBullet1)
				audio.play(soundTable["scissorFX"])
			elseif event.keyName == "e" then
				local paperBullet1 = display.newImageRect("paper.png", 40, 40)
				paperBullet1.x = player1.x+30
				paperBullet1.y = player1.y-5
				physics.addBody(paperBullet1, "dynamic",{ radius = 10, bounce = 0.5 })
				paperBullet1.gravityScale = 0
				paperBullet1.isBullet = true
				paperBullet1:setLinearVelocity(bulletSpeed,0)
				sceneGroup:insert(paperBullet1)
				paperBullet1.myName = "PAPER"
				audio.play(soundTable["paperFX"])
			elseif event.keyName == "i" then
				local rockBullet2 = display.newImageRect("rock.png", 40, 40)
				rockBullet2.x = player2.x-30
				rockBullet2.y = player2.y-5
				physics.addBody(rockBullet2, "dynamic",{ radius = 10, bounce = 0.5 })
				rockBullet2.gravityScale = 0
				rockBullet2.isBullet = true
				rockBullet2:setLinearVelocity(-bulletSpeed,0)
				rockBullet2.myName = "ROCK"
				sceneGroup:insert(rockBullet2)
				audio.play(soundTable["rockFX"])
			elseif event.keyName == "o" then
				local scissorBullet2 = display.newImageRect("scissor.png", 40, 40)
				scissorBullet2.x = player2.x-30
				scissorBullet2.y = player2.y-5
				physics.addBody(scissorBullet2, "dynamic",{ radius = 10, bounce = 0.5 })
				scissorBullet2.gravityScale = 0
				scissorBullet2.isBullet = true
				scissorBullet2:setLinearVelocity(-bulletSpeed,0)
				scissorBullet2.myName = "SCISSOR"
				sceneGroup:insert(scissorBullet2)
				audio.play(soundTable["scissorFX"])
			elseif event.keyName == "p" then
				local paperBullet2 = display.newImageRect("paper.png", 40, 40)
				paperBullet2.x = player2.x-30
				paperBullet2.y = player2.y-5
				physics.addBody(paperBullet2, "dynamic",{ radius = 10, bounce = 0.5 })
				paperBullet2.gravityScale = 0
				paperBullet2.isBullet = true
				paperBullet2:setLinearVelocity(-bulletSpeed,0)
				paperBullet2.myName = "PAPER"
				sceneGroup:insert(paperBullet2)
				audio.play(soundTable["paperFX"])
			end
			return false
		end

		local function returnButtonTap()
			composer.gotoScene( "menu", "fade", 500 )
		end
		-- need replay button, back to main menu button, clear text object

		local counter = false
		-- CHECK WINNING CONDITION
		function checkWin()
			if player1HP == 0 or player2HP == 0 then
				if player1HP == 0 then 
					local text = display.newText("Player 2 wins !!", display.contentCenterX,display.contentCenterY,native.systemFont,44)
					sceneGroup:insert(text)
					player1:setSequence("happy")
					player1:play()
					player2:setSequence("sad")
					player2:play()
				elseif player2HP == 0 then
					local text = display.newText("Player 1 wins !!", display.contentCenterX,display.contentCenterY,native.systemFont,44)
					sceneGroup:insert(text)
					player2:setSequence("happy")
					player2:play()
					player1:setSequence("sad")
					player1:play()
				end
				--composer.gotoScene("menu")
				if counter == false then
					rock1:removeSelf()
					rock1 = nil
					rock2:removeSelf()
					rock2 = nil
					scissor1:removeSelf()
					scissor1 = nil
					scissor2:removeSelf()
					scissor2 = nil
					paper1:removeSelf()
					paper1 = nil
					paper2:removeSelf()
					paper2 = nil
					counter = true
					label1:removeSelf()
					label1 = nil
					label2:removeSelf()
					label2 = nil
					label3:removeSelf()
					label3 = nil
					label4:removeSelf()
					label4 = nil
					label5:removeSelf()
					label5 = nil
					label6:removeSelf()
					label6 = nil
					Runtime:removeEventListener("key", onKeyEvent )
				end
			end
		end

		-- UPDATE HP BAR 
		function updateHPbar(hpBar)
			if hpBar.x ~= nil and hpBar.width ~= nil then 
				hpBar.x = hpBar.x - 2.5
				hpBar.width = hpBar.width - 5
			end
			checkWin()
		end

		-- COLLSION HANDLER AND UPDATER
		local function onGlobalCollision(event)
			if event.phase == "began" then
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
					destroyObj(event.object2)
					print("case 8")
				-- P vs S case
				elseif event.object1.myName == "PAPER" and event.object2.myName == "SCISSOR" then
					destroyObj(event.object1)
					print("case 9")
				-- HP COUNTER
				elseif event.object1.myName == "PLAYER2" and event.object2.myName == "ROCK" then
					player2HP = player2HP - 1
					updateHPbar(healthBar2)
					player1:setSequence("happy")
					player1:play()
					player2:setSequence("sad")
					player2:play()
					destroyObj(event.object2)
				elseif event.object1.myName == "PLAYER1" and event.object2.myName == "ROCK" then
					player1HP = player1HP - 1
					updateHPbar(healthBar1)
					player2:setSequence("happy")
					player2:play()
					player1:setSequence("sad")
					player1:play()
					destroyObj(event.object2)
				elseif event.object1.myName == "PLAYER2" and event.object2.myName == "SCISSOR" then
					player2HP = player2HP - 1
					updateHPbar(healthBar2)
					player1:setSequence("happy")
					player1:play()
					player2:setSequence("sad")
					player2:play()
					destroyObj(event.object2)
				elseif event.object1.myName == "PLAYER1" and event.object2.myName == "SCISSOR" then
					player1HP = player1HP - 1
					updateHPbar(healthBar1)
					player2:setSequence("happy")
					player2:play()
					player1:setSequence("sad")
					player1:play()
					destroyObj(event.object2)
				elseif event.object1.myName == "PLAYER2" and event.object2.myName == "PAPER" then
					player2HP = player2HP - 1
					updateHPbar(healthBar2)
					player1:setSequence("happy")
					player1:play()
					player2:setSequence("sad")
					player2:play()
					destroyObj(event.object2)
				elseif event.object1.myName == "PLAYER1" and event.object2.myName == "PAPER" then
					player1HP = player1HP - 1
					updateHPbar(healthBar1)
					player2:setSequence("happy")
					player2:play()
					player1:setSequence("sad")
					player1:play()
					destroyObj(event.object2)
				end
				print(""..player2HP.."")
				print(""..player1HP.."")
			end
		end

		-- LISTENER
		--rock1:addEventListener("tap", rock1Tap)
		--rock2:addEventListener("tap", rock2Tap)
		--scissor1:addEventListener("tap", scissor1Tap)
		--scissor2:addEventListener("tap", scissor2Tap)
		--paper1:addEventListener("tap", paper1Tap)
		--paper2:addEventListener("tap", paper2Tap)
		returnButton:addEventListener("tap", returnButtonTap)
		
		
		Runtime:addEventListener("collision", onGlobalCollision)
		Runtime:addEventListener( "key", onKeyEvent )

		
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
		sceneGroup:insert( returnButton )
		sceneGroup:insert(damageBar1)
		sceneGroup:insert(healthBar1)
		sceneGroup:insert(damageBar2)
		sceneGroup:insert(healthBar2)
	end

end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		startGame()
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
		audio.stop()
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