require "player"
require "enemy"
require "damageText"
require "levelUp"
require "shaderEx"
require "camera"
require "tombstone"
require "UI_window"
require "item"


--mfw I'm not making a smash clone, it's a maplestory clone.

--THINGS TO DO:
-- player dash mechanics, + walking/running
-- double jump
-- item pick up
-- level/tile design?

frame_limit = true

function love.load()

	if frame_limit then
		min_dt = 1/60
		next_time = love.timer.getTime()
	end
	SCREEN_WIDTH = 1080
	SCREEN_HEIGHT = 720
	g = love.graphics
	love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT, {resizable=false, vsync=true})
	
	camera:setScale(1,1)
	
	wavyDeathShader = Shader.new("waves")
	shaderTimer = 0.1

	gravity_const = 9.8
	
	ground = {}
	ground.color = {0,255,100}
	ground.height = 100
	
	platforms = {}
	for i=1, 5 do
		local platform = {}
		platform.isDropThroughable = true
		platform.isTangible = false
		platform.x = 0 + i*100
		platform.y = g.getHeight() - ground.height - i*100
		platform.color = {50,50,50}
		platform.height = 10
		platform.width = 150
		table.insert(platforms, platform)
	end
	
	boxes = {}
	for i=1, 1 do
		local box = {}
		box.x = 600
		box.y = 500
		box.width = 100
		box.height = 80
		box.color = {25,25,25}
		table.insert(boxes, box)
	end
	
	background = {}
	background.color = {0,100,255}
	
	UI = {}
	UI.expBarContainer = {x=360/2, y=SCREEN_HEIGHT-80, width=2*SCREEN_WIDTH/3, height=8, color={255,255,255}}
	UI.expBar = {x=UI.expBarContainer.x+1, y=UI.expBarContainer.y+1, width=0, maxWidth=UI.expBarContainer.width, height=7, color={255,255,0}}
	
	UI_windows = {}
	local testWindow = UI_window:new()
	testWindow.height = 300
	testWindow.width = 200
	testWindow:setPosition(300,300)
	testWindow.text = [[Sword Guy
	
	HP:
	MP:
	
	STR:
	DEX:
	INT:
	LUK:]]
	testWindow.isVisible = false
	table.insert(UI_windows, testWindow)
	
	enemies = {}

	enemySpawner = {}
	enemySpawner.delay = 4 --spawns 1 enemy every 5 seconds
	enemySpawner.timer = 0
	enemySpawner.ON = false
	
	damageTextQueue = {} --holds all currently displayed damage text objects
	levelUpQueue = {}
	
	gameOver = false
	tombstone = Tombstone:new()
	
	slimeTestSpritesheet = g.newImage("images/slime idle.PNG")
	slimeFrames = {}
	slimeFrames[1] = g.newQuad(0,0,32,32, slimeTestSpritesheet:getDimensions())
	slimeFrames[2] = g.newQuad(0,32,32,32, slimeTestSpritesheet:getDimensions())
	slimeFrames.currentFrame = 1
	slimeFrames.activeFrame = slimeFrames[slimeFrames.currentFrame]
	slimeFrames.frameTimer = 0
	slimeFrames.frameTimerMax = 1
	
	-- testSlime = Enemy:new()
	-- testSlime.sprites = slimeFrames
	-- table.insert(enemies, testSlime)
	
end

function love.update(dt)
	if frame_limit then	next_time = next_time + min_dt end
	
	if not gameOver then
		player:update(dt, platforms, boxes)

		playerEnemyInteractions(dt)
		
		if enemySpawner.ON then
			spawnEnemies(dt)
		end
	end
	
	camera.x = player.x - g.getWidth()/2
	camera.y = player.y - g.getHeight()/2 - 100	
	updateEXP_UI(dt)
	updateEnemies(dt)
	updateDamageTextQueue(dt)
	updateUI_windows(dt)
	
	if player.state == "dead" then
		player.activeSprite = player.sprites.dead
		updateTombstone(dt)
		shaderTimer = shaderTimer + dt
		wavyDeathShader:send("waves_time", shaderTimer)
	end
end

---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------


function updateEnemies(dt)
	for i=1, #enemies do
		enemies[i]:update(dt) 
		if enemies[i].state == "dead" then
			table.remove(enemies, i)
		break
		end
	end
end

function playerEnemyInteractions(dt)

	for i=1, #enemies do
				
		--check if player hits enemy
		--deal damage, kill enemy, give player exp
		if player.attack.hitbox.isActive then
			if checkCollision(player.attack.hitbox, enemies[i]) and enemies[i].hasAlreadyTakenDamage == false then
			
				enemies[i].hasAlreadyTakenDamage = true 	--cycles off
				enemies[i].hasTakenDamage = true 			--begins effect
				
				--apply damage
				enemies[i].HP = enemies[i].HP - player.attack.damage
				
				--display damage
				local damageText = DamageText:new(enemies[i].x, enemies[i].y, player.attack.damage, {255,155,0})
				table.insert(damageTextQueue, damageText)
				
				--kill enemy, give EXP
				if enemies[i].HP <= 0 then
					enemies[i].state = "dead"
					player.exp = player.exp + enemies[i].expGiven
				end			
			end
		elseif enemies[i].hasAlreadyTakenDamage == true then
			enemies[i].hasAlreadyTakenDamage = false
		end
		
		--check if enemy hits player (contact damage)
		if not player.hasTakenDamage then --player is invulnerable while damage effect plays
			if checkCollision(enemies[i], player) and player.hasAlreadyTakenDamage == false then
			
				player.hasAlreadyTakenDamage = true 	--cycles off
				player.hasTakenDamage = true 			--begins effect

				player.HP = player.HP - enemies[i].strength
				
				if player.HP <= 0 then
					player.state = "dead"
					--player.hasDied = true
				end
				
				local damageText = DamageText:new(player.x, player.y, enemies[i].strength, {255,0,0})
				table.insert(damageTextQueue, damageText)
				
				--figure out which side the enemy hit the player from
				--if player is left of enemy, knockback to left
				if enemies[i].x+enemies[i].width/2 > player.x+player.width then
					player.xSpeed = player.xSpeed - enemies[i].knockback
					player.ySpeed = player.ySpeed - enemies[i].knockback
				elseif enemies[i].x+enemies[i].width/2 < player.x+player.width then
					player.xSpeed = player.xSpeed + enemies[i].knockback
					player.ySpeed = player.ySpeed - enemies[i].knockback
				end
			
				
				if player.HP <= 0 then
					gameOver = true
				end
			end
		
		end
		if player.damageEffectTimer == 0 then
			player.hasAlreadyTakenDamage = false --reset the flag to take damage again
		end
	end
	
	--clean up dead enemies
	for i=1, #enemies do
	
	end
end

function checkCollision(object1, object2)
	if object1.x < object2.x + object2.width 
	and	object2.x < object1.x + object1.width
	and	object1.y < object2.y + object2.height 
	and object2.y < object1.y + object1.height then
		return true
	else
		return false
	end
end

function spawnEnemies(dt)
	if enemySpawner.timer < enemySpawner.delay then
		enemySpawner.timer = enemySpawner.timer + dt
	else
		enemySpawner.timer = 0
		local enemy = Enemy:new()
		enemy.sprites = slimeFrames
		enemy.x = math.random(100, g.getWidth()-100)
		table.insert(enemies, enemy)
	end
end

function updateEXP_UI(dt)
	UI.expBar.width = UI.expBar.maxWidth*(player.exp/player.expToLevel)
	
	if player.hasLeveled then --determined in player.lua file; active for one cycle
		local x = player.x-player.width-23
		local y = player.y-30
		local image = g.newImage("images/Level Up small.PNG")
		local levelUp = LevelUp:new(x,y, image)
		table.insert(levelUpQueue, levelUp)
	end
	
	for i=1, #levelUpQueue do
		if levelUpQueue[i].active then
			levelUpQueue[i].timer = levelUpQueue[i].timer + dt
			if levelUpQueue[i].timer > levelUpQueue[i].timerMax then
				levelUpQueue[i].active = false
			end
		else
			table.remove(levelUpQueue, i)
			break
		end
		
	end
end

function updateDamageTextQueue(dt)
	for i=1, #damageTextQueue do
		if damageTextQueue[i].active then
			damageTextQueue[i]:update(dt)
		else
			table.remove(damageTextQueue, i)
			break
		end
	end
end

function updateTombstone(dt)
	tombstone.x = player.x - 2
	
	local ground_y = g.getHeight() - ground.height - 10
	
	if (tombstone.y + tombstone.height) < (ground_y) then
		tombstone.y = tombstone.y + 500*dt
	else
		tombstone.y = (g.getHeight() - ground.height)
	end
end

function updateUI_windows(dt)


	for i=1, #UI_windows do
		if UI_windows[i].isVisible then
		
			local mouse_x = love.mouse.getX()
			local mouse_y = love.mouse.getY()
		
			--if mouse is inside window, it's in focus.
			if mouse_x >= UI_windows[i].x and 
			mouse_x <= UI_windows[i].x + UI_windows[i].width and
			mouse_y >= UI_windows[i].y and
			mouse_y <= UI_windows[i].y + UI_windows[i].height then
				UI_windows[i].hasMouseFocus = true
			else
				UI_windows[i].hasMouseFocus = false
				UI_windows[i].currentColor = UI_windows[i].backgroundColor
			end
			
			if UI_windows[i].hasMouseFocus then
				if not love.mouse.isDown(1) then
					UI_windows[i].canBeClicked = true
					UI_windows[i].isSelectedByMouse = false
					UI_windows[i].isHeld = false
				end
				
				UI_windows[i].currentColor = UI_windows[i].hoverColor
			else
				UI_windows[i].canBeClicked = false
			end
			
			if UI_windows[i].canBeClicked and love.mouse.isDown(1) then
				UI_windows[i].isHeld = true
			end
			
			if UI_windows[i].isHeld then
				UI_windows[i].currentColor = UI_windows[i].selectedColor
				UI_windows[i].x = mouse_x - UI_windows[i].width/2
				UI_windows[i].y = mouse_y - UI_windows[i].height/2	
			end
			
		end
	end
end


function love.draw()		
	--draw background
	g.setBackgroundColor(background.color)

	--draw ground
	g.setColor(ground.color)
	g.rectangle("fill", -1000, g.getHeight()-ground.height, g.getWidth()+2000, ground.height+1000)
	
	--draw platforms
	for i=1, #platforms do
		g.setColor(platforms[i].color)
		g.rectangle("fill", platforms[i].x, platforms[i].y, platforms[i].width, platforms[i].height)
	end
	
	--draw boxes
	for i=1, #boxes do
		g.setColor(boxes[i].color)
		g.rectangle("fill", boxes[i].x, boxes[i].y, boxes[i].width, boxes[i].height)
	end
	
	drawEnemies()
	
	-- if testSlime.facingDirection == "right" then
		-- g.draw(slimeTestSpritesheet, slimeFrames[testSlime.currentFrame], testSlime.x+20, testSlime.y-14, 0, -1, 1)
	-- else
		-- g.draw(slimeTestSpritesheet, slimeFrames[testSlime.currentFrame], testSlime.x, testSlime.y-14)
	-- end
	
	if player.state == "dead" then
		drawTombstone()
		player.attack.hitbox.isActive = false
	end
	
	drawPlayer()
	
	--draw player's attack hitbox
	if player.attack.hitbox.isActive then
		g.setColor(255,0,0)
		g.rectangle("fill", player.attack.hitbox.x, player.attack.hitbox.y, player.attack.hitbox.width, player.attack.hitbox.height)
	end
	
	drawDamageText()
	drawLevelUpEffect()
	
	--below here, graphics don't move w/ the camera
	--camera:unset()
	
	drawEXP_UI()

	--draw UI windows
	for i=1, #UI_windows do
	
		if UI_windows[i].isVisible then
			local window = UI_windows[i]
			g.setColor(window.currentColor)
			g.rectangle("fill", window.x, window.y, window.width, window.height) --draw the window
			 
			g.setColor(window.textColor)
			g.print(window.text, window.x, window.y) --print its text
		end
	
	end
	
	
	--text--------------------------------

	
	g.setColor(255,255,255)
	if player.canJump then
		g.print("can jump", 200, 200)
	end
	
	if player.isTouchingFloor then
		g.print("touching floor (friction applied)", 200, 220)
	end

	g.print(player.state, 200, 240)
	g.print("FPS: "..tostring(love.timer.getFPS( )), 5, 5)
	g.print("x speed: "..player.xSpeed, 5, 25)
	g.print("y speed: "..player.ySpeed, 5, 35)
	g.print("Level "..player.level, 5, 50)
	g.print("Exp: "..player.exp, 5, 70)
	g.print("Exp to level: "..player.expToLevel, 5, 90)
	g.print("HP: "..player.HP, 150, 50)
	g.print("Dash timer: "..player.dashTimer, 5, 150)
	
	local expRatio = (player.exp/player.expToLevel)*100
	g.print(expRatio.."%", 5, 110)

	
	if frame_limit then
		local cur_time = love.timer.getTime()
		if next_time <= cur_time then
			next_time = cur_time
			return
		end
		love.timer.sleep(next_time - cur_time)
	end

end


function drawPlayer()

	g.setColor(player.color)
	
	if player.hasTakenDamage then
		local red = player.color[1]+255-255*(player.damageEffectTimer/player.damageEffectTimerMax)
		local green = player.color[2]*(player.damageEffectTimer/player.damageEffectTimerMax)
		local blue = player.color[3]*(player.damageEffectTimer/player.damageEffectTimerMax)
		g.setColor(red, green, blue)
	end
	if player.state == "dead" then
		g.setColor(player.color[1], player.color[2], player.color[3], 50)
	end

	if player.jumpSquatFrameTimer > 0 then
		local adjusted_x = player.x-((player.width*player.jumpSquatBlobAmount)-player.width)/2
		local adjusted_y = player.y+player.height/2
		local adjusted_width = player.width*player.jumpSquatBlobAmount
		local adjusted_height = player.height/2
		g.rectangle("fill", adjusted_x,	adjusted_y, adjusted_width, adjusted_height)
	else
	
		if player.hurtboxVisible then
			g.setColor(255,255,255, 100)
			g.rectangle("fill", player.x, player.y, player.width, player.height)
			g.setColor(player.color)
		end
	
		--draw the sprite
		if player.facingDirection == "left" then
			if player.state == "dead" then
				g.setShader(wavyDeathShader)
				g.draw(player.activeSprite, player.x, player.y)
				g.setShader()
			else
				g.draw(player.activeSprite, player.x, player.y)
			end
		elseif player.facingDirection == "right" then
			if player.state == "dead" then
				g.setShader(wavyDeathShader)
				g.draw(player.activeSprite, player.x+player.width, player.y, 0, -1, 1)
				g.setShader()
			else
				g.draw(player.activeSprite, player.x+player.width, player.y, 0, -1, 1)
			end
		end
	end
end

function drawEnemies()
	for i=1, #enemies do
	
		-- if enemies[i].hasTakenDamage then
			-- local red = 255-255*(enemies[i].damageEffectTimer/enemies[i].damageEffectTimerMax)
			-- local green = enemies[i].color[2]*(enemies[i].damageEffectTimer/enemies[i].damageEffectTimerMax)
			-- local blue = enemies[i].color[3]*(enemies[i].damageEffectTimer/enemies[i].damageEffectTimerMax)
			-- g.setColor(red, green, blue)
		-- else
			-- g.setColor(enemies[i].color)
		-- end

		g.setColor(255,255,255)
	
	if enemies[i].facingDirection == "right" then
		g.draw(slimeTestSpritesheet, slimeFrames[enemies[i].currentFrame], enemies[i].x+20, enemies[i].y-14, 0, -1, 1)
	else
		g.draw(slimeTestSpritesheet, slimeFrames[enemies[i].currentFrame], enemies[i].x, enemies[i].y-14)
	end
		
		--HP
		g.setColor(255,255,255)
		g.print(enemies[i].HP, enemies[i].x, enemies[i].y-30)
	end
end

function drawLevelUpEffect()
	for i=1, #levelUpQueue do
		if levelUpQueue[i].active then
			local x = player.x-player.width-23
			local y = player.y-30
			if levelUpQueue[i].timer < levelUpQueue[i].fadeOutBeginsAt then
				g.setColor(255,255,255, 255*(2*levelUpQueue[i].timer/levelUpQueue[i].timerMax))
			else
				g.setColor(255,255,255, 255-255*((levelUpQueue[i].timer-levelUpQueue[i].fadeOutBeginsAt)/(levelUpQueue[i].timerMax-levelUpQueue[i].fadeOutBeginsAt))) --fade out
			end
			g.draw(levelUpQueue[i].image, x, y-levelUpQueue[i].timer*5)
		end
	end
end


function drawEXP_UI()

	--draw empty fill first
	g.setColor(100,100,100)
	g.rectangle("fill", UI.expBarContainer.x, UI.expBarContainer.y, UI.expBarContainer.width, UI.expBarContainer.height)
	
	--draw outline of container
	g.setColor(UI.expBarContainer.color)
	g.rectangle("line", UI.expBarContainer.x, UI.expBarContainer.y, UI.expBarContainer.width, UI.expBarContainer.height)
	
	--draw exp bar
	g.setColor(UI.expBar.color)
	if UI.expBar.width > UI.expBarContainer.width then 
		UI.expBar.width = UI.expBarContainer.width 
	end
	g.rectangle("fill", UI.expBar.x, UI.expBar.y, UI.expBar.width, UI.expBar.height)
	
	
	
	
end

function drawDamageText()
	
	--g.setNewFont(15)
	for i=1, #damageTextQueue do
	
		g.setColor(damageTextQueue[i].color)
		
		local y_position = damageTextQueue[i].y - 10 - 40*(damageTextQueue[i].durationTimer/damageTextQueue[i].durationTimerMax)
		
		--weird ass bug I can't figure out??
		if y_position ~= damageTextQueue[i].y - 10 then
			g.print(damageTextQueue[i].value, damageTextQueue[i].x, y_position)
		end
	end
	g.setNewFont(12)
end

function drawTombstone()
	g.draw(tombstone.image, tombstone.x, tombstone.y)
end



function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
	end
end

function love.keyreleased(key)
	if key == player.attackButton and player.canAttack == false then
		player.canAttack = true
	end
	
	if key == player.leftButton then
	--	player.canDashLeft = true
	end
	if key == player.rightButton then
	--	player.canDashRight = true
	end
end



