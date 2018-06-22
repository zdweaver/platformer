require "playerStats"

	player.state = "idle"
	player.sprites.default = love.graphics.newImage("images/playerLeft.PNG")
	player.sprites.hurt = love.graphics.newImage("images/playerHurtLeft.PNG")
	player.activeSprite = player.sprites.default

function player:update(dt)
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
	else
		player.activeSprite = player.sprites.default
	end
	

	--POSITION ADJUSTMENTS------------

	--maximum speed (x and fallspeed)
	if player.xSpeed > player.maxSpeed then
		player.xSpeed = player.maxSpeed
	elseif player.xSpeed < -player.maxSpeed then
		player.xSpeed = -player.maxSpeed
	end
	
	player.next_x = player.x + player.xSpeed
	player.next_y = player.y + player.ySpeed
	
	player:boundaryCollisions()

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
	
	if love.keyboard.isDown(player.attack.button) and player.attack.cooldownTimer == 0 and player.attack.hitboxTimer == 0 and player.canAttack then
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
	
		if love.keyboard.isDown("left") and player.isTouchingFloor then
			player.xSpeed = player.xSpeed - player.speed*dt
			player.facingDirection = "left"
		end
		if love.keyboard.isDown("right") and player.isTouchingFloor then
			player.xSpeed = player.xSpeed + player.speed*dt
			player.facingDirection = "right"
		end


		if love.keyboard.isDown("down") and player.isTouchingFloor then
			--player.xSpeed = 0
		end
		if love.keyboard.isDown(player.jumpButton) and player.canJump then
			player.hasEnteredJumpSquat = true
		end

	elseif player.state == "run" then
		player.state = "idle"

	elseif player.state == "jumpsquat" then
		player.state = "idle"
	elseif player.state == "jump" then

		if love.keyboard.isDown("left") and not player.isTouchingFloor then
			player.xSpeed = player.xSpeed - player.speed*dt
		end
		if love.keyboard.isDown("right") and not player.isTouchingFloor then
			player.xSpeed = player.xSpeed + player.speed*dt

		end
	

	elseif player.state == "fall" then
	
		--down must be released before fast fall is enabled
		if not love.keyboard.isDown("down") then
			player.canFastFall = true
		end
		
		
		if love.keyboard.isDown("down") and player.canFastFall then
			player.fastFallActive = true
			player.canFastFall = false
		end

		if love.keyboard.isDown("left") then
			player.xSpeed = player.xSpeed - player.speed*dt
		end
		if love.keyboard.isDown("right") then
			player.xSpeed = player.xSpeed + player.speed*dt
		end

		if player.isTouchingFloor then
			player.state = "idle"
		end
	end
	
	if player.state == "fast fall" then
	
		if love.keyboard.isDown("left") then
			player.xSpeed = player.xSpeed - player.speed*dt
		end
		if love.keyboard.isDown("right") then
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
		player.state = "idle"
		player.fastFallActive = false
	end

	if player.ySpeed < 0 then
		player.state = "jump"
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