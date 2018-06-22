require "player"
require "enemy"
--mfw I'm not making a smash clone, it's a maplestory clone.


function love.load()
	SCREEN_WIDTH = 1080
  SCREEN_HEIGHT = 720
	g = love.graphics
	love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT, {resizable=false, vsync=true})

	gravity_const = 18 --:^)

	platform = {}
	platform.x = g.getWidth()/2
	platform.y = g.getHeight()/2 + 100
	platform.color = {50,50,50}
	platform.height = 2
	platform.width = 180

	ground = {}
	ground.color = {0,255,100}
	ground.height = 100
	
	UI = {}
	UI.expBarContainer = {x=360/2, y=SCREEN_HEIGHT-80, width=2*SCREEN_WIDTH/3, height=8, color={255,255,255}}
	UI.expBar = {x=UI.expBarContainer.x+1, y=UI.expBarContainer.y+1, width=0, maxWidth=UI.expBarContainer.width, height=7, color={255,255,0}}
	
	levelUp = g.newImage("Level Up small.PNG")
	levelUpTimerMax = 3.5
	levelUpTimer = 0
	levelUpDisplayActive = false
	
	enemies = {}
	
	enemySpawner = {}
	enemySpawner.delay = 1 --spawns 1 enemy every 5 seconds
	enemySpawner.timer = 0
end



function love.update(dt)
	player:update(dt)
	
	--updateEXP_UI()
	
	--leveling shenanigans
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
	
	--spawning enemies
	if enemySpawner.timer < enemySpawner.delay then
		enemySpawner.timer = enemySpawner.timer + dt
	else
		enemySpawner.timer = 0
		local enemy = Enemy:new()
		enemy.x = math.random(100, g.getWidth()-100)
		table.insert(enemies, enemy)
	end
	
	--check if player hits enemy
	--deal damage, kill enemy, give player exp
	for i=1, #enemies do
		enemies[i]:update(dt)
		if player.attack.hitbox.isActive then
			if checkCollision(player.attack.hitbox, enemies[i]) then
				enemies[i].HP = enemies[i].HP - player.attack.damage
				if enemies[i].HP <= 0 then
					enemies[i].state = "dead"
					player.exp = player.exp + enemies[i].expGiven
				end
			end	
		end
	end
	
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



function love.draw()

	--draw ground
	g.setColor(ground.color)
	g.rectangle("fill", 0, g.getHeight()-ground.height, g.getWidth(), ground.height)

	--draw platform
	g.setColor(platform.color)
	g.rectangle("fill", platform.x, platform.y, platform.width, platform.height)

	--draw enemies + their HP
	for i=1, #enemies do
		g.setColor(enemies[i].color)
		g.rectangle("fill", enemies[i].x, enemies[i].y, enemies[i].width, enemies[i].height)
		
		g.setColor(255,255,255)
		g.print(enemies[i].HP, enemies[i].x, enemies[i].y)
	end
	drawPlayer()
	
	--draw player's attack hitbox
	if player.attack.hitbox.isActive then
		g.setColor(255,0,0)
		g.rectangle("fill", player.attack.hitbox.x, player.attack.hitbox.y, player.attack.hitbox.width, player.attack.hitbox.height)
	end
	
	--draw UI (exp bar)
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
		g.setColor(255,255,255, 255*(2*levelUpTimer/levelUpTimerMax))
		g.draw(levelUp, x, y-levelUpTimer*10)
	end
	
	--text--
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
	g.print("Level "..player.level, 5, 50)
	g.print("Exp: "..player.exp, 5, 70)
	g.print("Exp to level: "..player.expToLevel, 5, 90)

	local expRatio = (player.exp/player.expToLevel)*100
	g.print(expRatio.."%", 5, 110)
end




function drawPlayer()

	if player.state == "idle" or player.state == "jump" then
		g.setColor(player.color)
		
	elseif player.state == "dash_left" or player.state == "dash_right" then
		g.setColor(125,125,255)

	elseif player.state == "run" then
		g.setColor(125, 125, 125)
	elseif player.state == "fall" then
		g.setColor(55,55,55)
	
	end

	if player.jumpSquatFrameTimer > 0 then
		local adjusted_x = player.x-((player.width*player.jumpSquatBlobAmount)-player.width)/2
		local adjusted_y = player.y+player.height/2
		local adjusted_width = player.width*player.jumpSquatBlobAmount
		local adjusted_height = player.height/2
		g.rectangle("fill", adjusted_x,	adjusted_y, adjusted_width, adjusted_height) --player blobs a little bit during jumpsquat lmao
	else
		g.rectangle("fill", player.x, player.y, player.width, player.height)
	end
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
