require "playerStats"

	player.state = "idle"
	--player.sprites.default = love.graphics.newImage("images/playerLeft.PNG")
	player.sprites.default = love.graphics.newImage("images/Swordguy idleLeft.PNG")
	player.sprites.hurt = love.graphics.newImage("images/playerHurtLeft.PNG")
	player.sprites.dead = love.graphics.newImage("images/playerDeadLeft.PNG")
	player.sprites.dashLeft = love.graphics.newImage("images/Swordguy dashLeft.PNG") 
	player.sprites.dashRight = love.graphics.newImage("images/Swordguy dashRight.PNG") --left/right mirrors the sprite, so this isn't needed.
	player.sprites.runLeft = love.graphics.newImage("images/Swordguy runLeft.PNG")
	player.sprites.runRight = love.graphics.newImage("images/Swordguy runRight.PNG")
	player.sprites.jumpLeft = love.graphics.newImage("images/Swordguy jumpLeft.PNG")
	player.sprites.fallLeft = love.graphics.newImage("images/Swordguy fallLeft.PNG")
	
	player.activeSprite = player.sprites.default

function player:update(dt, platforms, boxes)
	player:updatePlayerState(dt)
	player:updateEXP()
	player:updateAttack(dt)
	player:applyJump(dt)
	
	if player.hasTakenDamage then
	
		player.activeSprite = player.sprites.hurt
	
		player.damageEffectTimer = player.damageEffectTimer + dt
		if player.damageEffectTimer > player.damageEffectTimerMax then
			player.hasTakenDamage = false
			player.damageEffectTimer = 0
		end
	end

	--POSITION ADJUSTMENTS------------
	
	--if not player.isTouchingFloor then 
	player:applyGravity(dt)
	--

	--maximum speed (x and fallspeed)
	if player.xSpeed > player.maxSpeed then
		player.xSpeed = player.maxSpeed
	elseif player.xSpeed < -player.maxSpeed then
		player.xSpeed = -player.maxSpeed
	end
	
	player.next_x = player.x + player.xSpeed
	player.next_y = player.y + player.ySpeed
	
	player:boundaryCollisions(platforms, boxes)

	--apply next position
	player.y = player.next_y
	player.x = player.next_x
	
	--update hitbox position
	if player.facingDirection == "right" then
		player.attack.hitbox.x = player.x+player.width/2 + player.attack.hitbox.xOffset
		player.attack.hitbox.y = player.y+ player.attack.hitbox.yOffset
	elseif player.facingDirection == "left" then
		player.attack.hitbox.x = player.x+player.width/2 - player.attack.hitbox.xOffset - player.attack.hitbox.width
		player.attack.hitbox.y = player.y - player.attack.hitbox.yOffset
	end
	
	player:applyFriction(dt)
end


function player:updateEXP()
	if player.exp >= player.expToLevel then
		player.level = player.level + 1
		player.exp = (player.exp - player.expToLevel)
		player.expToLevel = math.ceil((player.expToLevel+1)^player.expModifier)
		player.hasLeveled = true
	else
		player.hasLeveled = false
	end
end

function player:updateAttack(dt)
	--ATTACKING
	--(currently) independent of player's state
	
	if love.keyboard.isDown(player.attackButton) and player.attack.cooldownTimer == 0 and player.attack.hitboxTimer == 0 and player.canAttack then
		player.hasAttacked = true
	end

	if player.hasAttacked then
		player.attack.hitbox.isActive = true
		player.canAttack = false
		player.hasAttacked = false
	end

	if player.attack.hitbox.isActive then
		if player.attack.hitboxTimer < player.attack.hitboxDuration then
			player.attack.hitboxTimer = player.attack.hitboxTimer + dt
		else
			player.attack.hitbox.isActive = false
			player.attack.hitboxTimer = 0
			player.attack.cooldownIsActive = true
		end
	end

	if player.attack.cooldownIsActive then
		if player.attack.cooldownTimer < player.attack.cooldown then
			player.attack.cooldownTimer = player.attack.cooldownTimer + dt
		else
			player.attack.cooldownTimer = 0
			player.attack.cooldownIsActive = false
		end
	end
end

function player:applyJump(dt)
	if player.hasEnteredJumpSquat then
		player.jumpSquatFrameTimer = player.jumpSquatFrameTimer + dt

		if not love.keyboard.isDown(player.jumpButton) then
			player.jumpImpulse = player.shortHopImpulse
		else
			player.jumpImpulse = player.fullJumpImpulse
		end

		if player.jumpSquatFrameTimer > player.jumpSquat then
			player.hasJumped = true
			player.jumpSquatFrameTimer = 0
			player.hasEnteredJumpSquat = false
		end
	end

	if player.hasJumped then
		player.ySpeed = -player.jumpImpulse
		player.hasJumped = false
		player.canJump = false
		player.isJumping = true
	end
end

function player:boundaryCollisions()
	--player touches ground
	if (player.next_y+player.height > g.getHeight()-ground.height) then
		player.isTouchingFloor = true
	else
		player.isTouchingFloor = false
	end
	while (player.next_y+player.height > g.getHeight()-ground.height) do
		player.next_y = player.next_y - 0.1
		player.isTouchingFloor = true
		if not love.keyboard.isDown(player.jumpButton) then
			player.canJump = true
		end
		player.ySpeed = 0
	end
	
	--player touches platforms (no intersection from above)
	for i=1, #platforms do
		if player.next_x + player.width > platforms[i].x and
			player.next_y + player.height > platforms[i].y and
			player.x < platforms[i].x + platforms[i].width and
			player.y < platforms[i].y then
			
			if platforms[i].isTangible then
			
				if player.ySpeed > 0 then
					while player.next_y + player.height > platforms[i].y do
						player.next_y = player.next_y - 0.01
					end
					
					player.ySpeed = 0
					player.isTouchingFloor = true
					player.isOnPlatform = true
					if not love.keyboard.isDown(player.jumpButton) then
						player.canJump = true
					end
					if not love.keyboard.isDown(player.downButton) then
						player.canDropThroughPlatform = true
					end
					
					if love.keyboard.isDown(player.downButton) and platforms[i].isDropThroughable and player.canDropThroughPlatform then
						platforms[i].isTangible = false
						player.isOnPlatform = false
					end
				end
			end
		else --reset the platforms' tangibility if player is not intersecting
			platforms[i].isTangible = true
		end
	end
	
	--player touches boxes (no intersection from any direction)
	for i=1, #boxes do
	
		--from above
		if player.x + player.width > boxes[i].x and
			player.next_y + player.height > boxes[i].y and
			player.x < boxes[i].x + boxes[i].width and
			player.y < boxes[i].y then
			
			if player.ySpeed > 0 then
				while player.next_y + player.height > boxes[i].y do
					player.next_y = player.next_y - 0.01
				end
				player.ySpeed = 0
				player.isTouchingFloor = true
				player.canJump = true
			end
		end
		
		--from below
		if player.x + player.width > boxes[i].x and
			player.next_y < boxes[i].y + boxes[i].height and
			player.x < boxes[i].x + boxes[i].width and
			player.y > boxes[i].y then
			
			if player.ySpeed < 0 then
				while player.next_y < boxes[i].y do
					player.next_y = player.next_y + 0.01
				end
				player.ySpeed = 0
			end
		end
		
		--from the left
		if player.next_x + player.width > boxes[i].x and
			player.y + player.height > boxes[i].y and
			player.y < boxes[i].y + boxes[i].height and
			player.x < boxes[i].x then
					
			if player.xSpeed > 0 then
				while player.next_x > boxes[i].x do
					player.next_x = player.next_x - 0.01
				end
				player.xSpeed = 0
			end
		end
		
		--from the right
		if player.next_x < boxes[i].x + boxes[i].width and
			player.y + player.height > boxes[i].y and
			player.y < boxes[i].y + boxes[i].height and
			player.x + player.width > boxes[i].x then
					
			if player.xSpeed < 0 then
				while player.next_x < boxes[i].x + boxes[i].width do
					player.next_x = player.next_x + 0.1
				end
				player.xSpeed = 0
			end
		end
	end

	--stay within screen boundaries
	while(player.next_x < 0) do
		player.next_x = player.next_x/2
		player.xSpeed = player.xSpeed/2
	end
	while(player.next_x + player.width > g.getWidth()) do
		player.next_x = player.next_x - 0.1
		player.xSpeed = player.xSpeed/2
	end
end

function player:applyFriction(dt)
	-- x-axis friction while on ground
	if player.xSpeed > 0 and player.isTouchingFloor then
		local new_xSpeed = player.xSpeed - player.friction*dt
		if new_xSpeed < 0 then player.xSpeed = 0
		else player.xSpeed = player.xSpeed - player.friction*dt
		end
	end
	if player.xSpeed < 0 and player.isTouchingFloor then
		local new_xSpeed = player.xSpeed + player.friction*dt
		if new_xSpeed > 0 then player.xSpeed = 0
		else player.xSpeed = player.xSpeed + player.friction*dt
		end
	end
end

function player:updatePlayerState(dt)

	if player.state == "idle" then
		player.activeSprite = player.sprites.default
	end

	if player.state == "idle" or player.state == "dash" then
	
		if love.keyboard.isDown(player.leftButton) and player.isTouchingFloor and player.canDashLeft then
			if not player.hasBegunToDash then
				player.facingDirection = "left"
				player.hasBegunToDash = true
				player.state = "dash"
			end

		end
		if love.keyboard.isDown(player.rightButton) and player.isTouchingFloor and player.canDashRight then
			if not player.hasBegunToDash then
				player.facingDirection = "right"
				player.hasBegunToDash = true
				player.state = "dash"
			end
		end

		if love.keyboard.isDown(player.downButton) and player.isTouchingFloor then
			player.xSpeed = player.xSpeed / 1.1
		end
		if love.keyboard.isDown(player.jumpButton) and player.canJump then
			player.hasEnteredJumpSquat = true --triggers the jump
		end

	elseif player.state == "jumpsquat" then
		player.state = "jumpsquat"
	elseif player.state == "jump" then
	
		player.activeSprite = player.sprites.jumpLeft

		--aerial drift
		if love.keyboard.isDown(player.leftButton) and not player.isTouchingFloor then
			player.xSpeed = player.xSpeed - player.speed*dt
		end
		if love.keyboard.isDown(player.rightButton) and not player.isTouchingFloor then
			player.xSpeed = player.xSpeed + player.speed*dt
		end
	

	elseif player.state == "fall" then
	
		player.activeSprite = player.sprites.fallLeft
	
		--down must be released before fast fall is enabled
		if not love.keyboard.isDown(player.downButton) then
			player.canFastFall = true
		end
		 
		
		if love.keyboard.isDown(player.downButton) and player.canFastFall and not player.isOnPlatform then
			player.fastFallActive = true
			player.canFastFall = false
		end

		if love.keyboard.isDown(player.leftButton) then
			player.xSpeed = player.xSpeed - player.speed*dt
		end
		if love.keyboard.isDown(player.rightButton) then
			player.xSpeed = player.xSpeed + player.speed*dt
		end

		if player.isTouchingFloor then
			player.state = "idle"
			player.activeSprite = player.sprites.default
		end
	end
	
	-- DASHING --------------------------------------------------	
	if player.hasBegunToDash then
		player.dashTimer = 0
		player.dashTimerIsActive = true
		player.hasBegunToDash = false
	end
	
	if player.state == "dash" then
		player:dash(player.facingDirection, dt)
		player.dashTimer = player.dashTimer + dt
		if player.dashTimer > player.dashTimeLength then
			player.dashTimer = 0
			player.dashTimerIsActive = false
			player.state = "idle"
			player.activeSprite = player.sprites.default
		end
	else
		player.dashTimer = 0
	end
		
	-----------------------------------------------------------
	
	if player.state == "fast fall" then
	
		if love.keyboard.isDown(player.leftButton) then
			player.xSpeed = player.xSpeed - player.speed*dt
		end
		if love.keyboard.isDown(player.rightButton) then
			player.xSpeed = player.xSpeed + player.speed*dt
		end

		if player.isTouchingFloor then
			player.state = "idle"
		end		
	end

	if player.ySpeed > 0 and not player.isTouchingFloor then --and not player.state == "fast fall" then
		player.state = "fall"
		if player.fastFallActive then
			player.state = "fast fall"
		end
	elseif player.isTouchingFloor then
		player.fastFallActive = false
		if not player.state == "dash" then
			player.state = "idle"
		end
		
	end

	if player.ySpeed < 0 then
		player.state = "jump"
		player.dashTimer = 0
	end
end

function player:dash(dir, dt)

	player.activeSprite = player.sprites.dashLeft --flips automatically
	
	if dir == "right" then
		player.xSpeed = player.dashSpeed * dt*100

	elseif dir == "left" then
		player.xSpeed = -player.dashSpeed * dt*100
	end
end



function player:applyGravity(dt)
	--gravity (affected by fast fall)
	if player.state == "fast fall" then
		player.ySpeed = player.fastFallSpeed
	else
		player.ySpeed = player.ySpeed + gravity_const*(player.weight/2.5)*dt
	end
end