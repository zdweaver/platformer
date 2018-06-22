Enemy = {}
Enemy.__index = Enemy

function Enemy:new()
	local enemy = { 
	
		x = 200,
		y = 550,
		next_x = nil,
		next_y = nil,

		xSpeed = 0,
		ySpeed = 0,
		width = 15,
		height = 15,
		color = {20,20,155},
		weight = 5,
		speed = 0.5,
		maxSpeed = 1.5,
		
		--stats--
		HP = 20,
		MP = 5,
		expGiven = 1,
		strength = 25,
		dexterity = 5,
		intelligence = 5,
		luck = 5,
		knockback = 3.5, --applied to player on contact
		
		hasAlreadyTakenDamage = false, --one cycle flag (to prevent dmg application every cycle)
		hasTakenDamage = false, 	   --updates timer in Enemy.lua
		damageEffectTimer = 0,
		damageEffectTimerMax = 0.333,
		damageColor = {255,0,0},
	}
	
	enemy.behaviors = {"wander", "aggro"} --to be implemented: aggro when damaged
	enemy.behaviors.active = "wander"
	enemy.currentMove = nil				 --to allow for random init
	enemy.moves = {left, right, idle}
	enemy.moves.left =  {durationMin=0.5, durationMax=1.5, timer=0, name="left"}
	enemy.moves.right = {durationMin=0.5, durationMax=1.5, timer=0, name="right"}
	enemy.moves.idle =  {durationMin=0.5, durationMax=1.5, timer=0, name="idle"}
	
	setmetatable(enemy,Enemy)
	return enemy
end

function Enemy:update(dt)

	self:applyMovementPattern(self.behaviors.active, dt)
	
	--damage coloration effect
	if self.hasTakenDamage then
		self.damageEffectTimer = self.damageEffectTimer + dt
		if self.damageEffectTimer > self.damageEffectTimerMax then
			self.hasTakenDamage = false
			self.damageEffectTimer = 0
		end
	end
	
	--gravity
	self.ySpeed = self.ySpeed + gravity_const*dt
	
	if(self.xSpeed > self.maxSpeed) then
		self.xSpeed = self.maxSpeed
	end
	if(self.xSpeed < -self.maxSpeed) then
		self.xSpeed = -self.maxSpeed
	end
	
	self.next_x = self.x + self.xSpeed
	self.next_y = self.y + self.ySpeed

	--player touches ground
	if (self.next_y+self.height > g.getHeight()-ground.height) then
		self.isTouchingFloor = true
	else
		self.isTouchingFloor = false
	end
	while (self.next_y+self.height > g.getHeight()-ground.height) do
		self.next_y = self.next_y - 0.1
		self.isTouchingFloor = true
		self.canJump = true
		self.ySpeed = 0
	end

	--stay within screen boundaries
	while(self.next_x < 0) do
		self.next_x = self.next_x/2
		self.xSpeed = self.xSpeed/2
	end
	while(self.next_x + self.width > g.getWidth()) do
		self.next_x = self.next_x - 0.1
		self.xSpeed = self.xSpeed/2
	end

	--apply next position
	self.y = self.next_y
	self.x = self.next_x
end

function Enemy:applyMovementPattern(pattern, dt)	
	if pattern == "wander" then
	
		--if initializing, select a movement at random
		if self.currentMove == nil then
			self:selectRandomMove()
		end

		self.moves[self.currentMove].timer = self.moves[self.currentMove].timer + dt
		if self.moves[self.currentMove].timer >= self.moves[self.currentMove].durationMax then
			self.moves[self.currentMove].timer = 0
			self:selectRandomMove()
		else
			self:applyMovement(self.currentMove, dt)
		end
	end
end

function Enemy:selectRandomMove()
	local rand = math.random(1,3)
	
	--hard coded b/c apparently I don't know how to traverse tables
	if rand == 1 then self.currentMove = "left"
	elseif rand == 2 then self.currentMove = "right"
	elseif rand == 3 then self.currentMove = "idle"
	end

end


function Enemy:applyMovement(direction, dt)
	if direction == "left" then
		self.xSpeed = self.xSpeed - self.speed*dt
	elseif direction == "right" then
		self.xSpeed = self.xSpeed + self.speed*dt
	end
end