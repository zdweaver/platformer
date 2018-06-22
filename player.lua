
	player = {}
	player.state = "idle"

--PLAYER STATS--
----------------------------------------------------
----------------------------------------------------
	--positioning
	player.x = 30
	player.y = 720 - 100
	player.next_x = nil
	player.next_y = nil

	player.xSpeed = 0
	player.ySpeed = 0
	player.width = 15
	player.height = 15
	player.color = {190,190,190}
	player.weight = 5
	player.speed = 6

	--stats--
	player.HP = 100
	player.MP = 100
	player.exp = 0
	player.level = 1
	player.expToLevel = 1
	player.expModifier = 1.2
	player.hasLeveled = false
	player.strength = 5
	player.dexterity = 5
	player.intelligence = 5
	player.luck = 5
	

	--jump stats--
	player.canJump = false
	player.hasJumped = false --one-cycle flag
	player.isJumping = false
	player.fullJumpImpulse = 10 --const
	player.jumpImpulse = 10 --value applied
	player.shortHopImpulse = 6.7
	player.jumpSquat = 0.0666 --4 frames
	player.jumpSquatFrameTimer = 0
	player.hasEnteredJumpSquat = false
	player.jumpSquatBlobAmount = 1.3
	player.isTouchingFloor = false

	--dash stats--
	player.dashSpeed = 3
	player.dashTimeLength = 0.45 --sec
	player.dashTimer = 0

	--physics
	player.friction = 1.4

	--attacks
	player.attack = {}
	player.attack.button = "x"
	player.attack.damage = 4 + player.strength*1.2
	player.attack.hitbox = {x=0, y=0, width=40, height=10, xOffset = 30, yOffset = 0}
	player.attack.hitboxDuration = 0.05
	player.attack.hitboxTimer = 0
	player.attack.cooldown = .1
	player.attack.cooldownTimer = 0
	player.hasAttacked = false --one cycle flag
	player.canAttack = true --cycled with button release
	player.attack.hitbox.isActive = false
	player.attack.cooldownIsActive = false

---------------------------------------------------
----------------------------------------------------

function player:update(dt)

	player:updatePlayerState(dt)
	
	if player.exp >= player.expToLevel then
		player.level = player.level + 1
		player.exp = (player.exp - player.expToLevel)
		player.expToLevel = math.ceil((player.expToLevel+1)^player.expModifier)
		player.hasLeveled = true
	else
		player.hasLeveled = false
	end

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


	------------------------------------------


	--gravity
	player.ySpeed = player.ySpeed + gravity_const*dt

	--jump
	if player.hasEnteredJumpSquat then
		player.jumpSquatFrameTimer = player.jumpSquatFrameTimer + dt

		if not love.keyboard.isDown("up") then
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

	--calculating next position
	player.next_x = player.x + player.xSpeed
	player.next_y = player.y + player.ySpeed

	--player touches ground
	if (player.next_y+player.height > g.getHeight()-ground.height) then
		player.isTouchingFloor = true
	else
		player.isTouchingFloor = false
	end
	while (player.next_y+player.height > g.getHeight()-ground.height) do
		player.next_y = player.next_y - 0.1
		player.isTouchingFloor = true
		player.canJump = true
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

	--apply next position
	player.y = player.next_y
	player.x = player.next_x
	player.attack.hitbox.x = player.x + player.attack.hitbox.xOffset
	player.attack.hitbox.y = player.y + player.attack.hitbox.yOffset

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

		--DASH FROM GROUND---
		if (love.keyboard.isDown("left") or love.keyboard.isDown("a")) and player.isTouchingFloor then
			player.state = "dash_left"
		end
		if (love.keyboard.isDown("right") or love.keyboard.isDown("d")) and player.isTouchingFloor then
			player.state = "dash_right"
		end
		-------------------


		if (love.keyboard.isDown("down") or love.keyboard.isDown("d")) and player.isTouchingFloor then
			player.xSpeed = 0
		end
		if (love.keyboard.isDown("up") or love.keyboard.isDown("w") or love.keyboard.isDown("space")) and player.canJump then
			player.hasEnteredJumpSquat = true
		end


	--during a dash, player can:
	--1. dash opposite direction
	--2. jump (enters "jumpsquat" state)
	elseif player.state == "dash_left" then
		player.xSpeed = -player.dashSpeed
		player.dashTimer = player.dashTimer + dt
		if player.dashTimer > player.dashTimeLength then
			player.dashTimer = 0
			player.state = "run"
		end
		if (love.keyboard.isDown("right") or love.keyboard.isDown("d")) and player.isTouchingFloor then --dash dance!
			player.dashTimer = 0
			player.state = "dash_right"
		end
		if (love.keyboard.isDown("up") or love.keyboard.isDown("w") or love.keyboard.isDown("space")) and player.canJump then
			player.state = "jumpsquat"
		end

	elseif player.state == "dash_right" then
		player.xSpeed = player.dashSpeed
		player.dashTimer = player.dashTimer + dt
		if player.dashTimer > player.dashTimeLength then
			player.dashTimer = 0
			player.state = "run"
		end
		if (love.keyboard.isDown("left") or love.keyboard.isDown("a")) and player.isTouchingFloor then --dash dance!
			player.dashTimer = 0
			player.state = "dash_left"
		end
		if (love.keyboard.isDown("up") or love.keyboard.isDown("w") or love.keyboard.isDown("space")) and player.canJump then
			player.state = "jumpsquat"
		end


	elseif player.state == "run" then
		player.state = "idle"

	elseif player.state == "jumpsquat" then
		player.state = "idle"
	elseif player.state == "jump" then

		--AERIAL DRIFT
		if love.keyboard.isDown("right") or love.keyboard.isDown("d") and not player.isTouchingFloor then
			player.xSpeed = player.xSpeed + player.speed*dt
		end
		if (love.keyboard.isDown("left") or love.keyboard.isDown("a")) and not player.isTouchingFloor then
			player.xSpeed = player.xSpeed - player.speed*dt
		end


	elseif player.state == "fall" then

		--DRIFT-------
		if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
			player.xSpeed = player.xSpeed + player.speed*dt
		end
		if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
			player.xSpeed = player.xSpeed - player.speed*dt
		end
		-------------

		if player.isTouchingFloor then
			player.state = "idle"
		end
	end

	if player.ySpeed > 0 and not player.isTouchingFloor then
		player.state = "fall"
	end

	if player.ySpeed < 0 then
		player.state = "jump"
	end
end
