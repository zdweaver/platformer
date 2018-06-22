require "player"
require "enemy"
require "damageText"

--mfw I'm not making a smash clone, it's a maplestory clone.

function love.load()
	SCREEN_WIDTH = 1080
	SCREEN_HEIGHT = 720
	g = love.graphics
	love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT, {resizable=false, vsync=true})

	gravity_const = 9.8

	platform = {}
	platform.x = g.getWidth()/2
	platform.y = g.getHeight()/2 + 100
	platform.color = {50,50,50}
	platform.height = 2
	platform.width = 180
	
	background = {}
	background.color = {10,10,20}

	ground = {}
	ground.color = {0,255,100}
	ground.height = 100
	
	UI = {}
	UI.expBarContainer = {x=360/2, y=SCREEN_HEIGHT-80, width=2*SCREEN_WIDTH/3, height=8, color={255,255,255}}
	UI.expBar = {x=UI.expBarContainer.x+1, y=UI.expBarContainer.y+1, width=0, maxWidth=UI.expBarContainer.width, height=7, color={255,255,0}}
	
	levelUp = g.newImage("images/Level Up small.PNG")
	levelUpTimerMax = 3.5
	levelUpTimer = 0
	levelUpFadeOutTimerBeginsAt = 2
	levelUpDisplayActive = false
	
	enemies = {}
	
	enemySpawner = {}
	enemySpawner.delay = 1 --spawns 1 enemy every 5 seconds
	enemySpawner.timer = 1
	
	damageTextQueue = {} --holds all currently displayed damage text objects
	
	gameOver = false
	tombstone = {}
	tombstone.x = nil
	tombstone.y = 0
	tombstone.height = 10
	tombstone.image = g.newImage("images/tombstone.PNG")
end

function love.update(dt)
	if not gameOver then
		player:update(dt)
		playerEnemyInteractions(dt)
		spawnEnemies(dt)
		updateEXP_UI(dt)
	end
	player:applyGravity(dt)
	updateEnemies(dt)
	updateDamageTextQueue(dt)
	
	if player.state == "dead" then
		updateTombstone(dt)
	end
end

---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

function updateEnemies(dt)
	for i=1, #enemies do
		enemies[i]:update(dt) 
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
		if enemies[i].state == "dead" then
			table.remove(enemies, i)
			break
		end
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
		enemy.x = math.random(100, g.getWidth()-100)
		table.insert(enemies, enemy)
	end
end

function updateEXP_UI(dt)
	UI.expBar.width = UI.expBar.maxWidth*(player.exp/player.expToLevel)
	
	if player.hasLeveled then --determined in player.lua file; active for one cycle
		levelUpDisplayActive = true
	end
		
	if levelUpDisplayActive then
		levelUpTimer = levelUpTimer + dt
		if levelUpTimer >= levelUpTimerMax then
			levelUpDisplayActive = false
			levelUpTimer = 0
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
		tombstone.y = (g.getHeight() - ground.height) - 10
	end
end


function love.draw()

	--draw background
	g.setBackgroundColor(background.color)

	--draw ground
	g.setColor(ground.color)
	g.rectangle("fill", 0, g.getHeight()-ground.height, g.getWidth(), ground.height)

	--draw platform
	-- g.setColor(platform.color)
	-- g.rectangle("fill", platform.x, platform.y, platform.width, platform.height)
	
	drawEnemies()
	
	if player.state == "dead" then
		drawTombstone()
	end
	
	drawPlayer()
	
	--draw player's attack hitbox
	if player.attack.hitbox.isActive then
		g.setColor(255,0,0)
		g.rectangle("fill", player.attack.hitbox.x, player.attack.hitbox.y, player.attack.hitbox.width, player.attack.hitbox.height)
	end
	
	drawEXP_UI()
	
	
	--text--------------------------------
	drawDamageText()
	
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
	
	local expRatio = (player.exp/player.expToLevel)*100
	g.print(expRatio.."%", 5, 110)
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
			g.setColor(player.color[1], player.color[2], player.color[3], 100)
	end

	if player.jumpSquatFrameTimer > 0 then
		local adjusted_x = player.x-((player.width*player.jumpSquatBlobAmount)-player.width)/2
		local adjusted_y = player.y+player.height/2
		local adjusted_width = player.width*player.jumpSquatBlobAmount
		local adjusted_height = player.height/2
		g.rectangle("fill", adjusted_x,	adjusted_y, adjusted_width, adjusted_height)
	else	
	
		--draw the sprite
		if player.facingDirection == "left" then
			g.draw(player.activeSprite, player.x, player.y)
		elseif player.facingDirection == "right" then
			g.draw(player.activeSprite, player.x+player.width, player.y, 0, -1, 1)
		end
	end
end

function drawEnemies()
	for i=1, #enemies do
	
		if enemies[i].hasTakenDamage then
			local red = 255-255*(enemies[i].damageEffectTimer/enemies[i].damageEffectTimerMax)
			local green = enemies[i].color[2]*(enemies[i].damageEffectTimer/enemies[i].damageEffectTimerMax)
			local blue = enemies[i].color[3]*(enemies[i].damageEffectTimer/enemies[i].damageEffectTimerMax)
			g.setColor(red, green, blue)
		else
			g.setColor(enemies[i].color)
		end
		g.rectangle("fill", enemies[i].x, enemies[i].y, enemies[i].width, enemies[i].height)
		
		--HP
		g.setColor(255,255,255)
		g.print(enemies[i].HP, enemies[i].x, enemies[i].y)
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
	
	--draw level up graphic
	if levelUpDisplayActive then
		local x = player.x-player.width-23
		local y = player.y-30
		if levelUpTimer < levelUpFadeOutTimerBeginsAt then
			g.setColor(255,255,255, 255*(2*levelUpTimer/levelUpTimerMax)) --fade in
		else
			g.setColor(255,255,255, 255-255*((levelUpTimer-levelUpFadeOutTimerBeginsAt)/(levelUpTimerMax-levelUpFadeOutTimerBeginsAt))) --fade out
		end
		
		g.draw(levelUp, x, y-levelUpTimer*5)
	end
end

function drawDamageText()
	
	g.setNewFont(15)
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
	if key == "x" and player.canAttack == false then
		player.canAttack = true
	end
end
