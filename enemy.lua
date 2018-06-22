Enemy = {}
Enemy.__index = Enemy

function Enemy:new()
	local enemy = { 
	
		state = "idle",
	
		x = 800,
		y = 550,
		next_x = nil,
		next_y = nil,

		xSpeed = 0,
		ySpeed = 0,
		width = 15,
		height = 15,
		color = {20,20,155},
		weight = 5,
		speed = 6,
		
		--stats--
		HP = 100,
		MP = 100,
		expGiven = 10,
		strength = 5,
		dexterity = 5,
		intelligence = 5,
		luck = 5,
	}
	
	enemy.movementPattern = {}
	
	setmetatable(enemy,Enemy)
	return enemy
end

function Enemy:update(dt)


	
	--gravity
	self.ySpeed = self.ySpeed + gravity_const*dt
	
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

