Item = {}
Item.__index = Item

--all items are 10x10 in size by default

function Item:new()
	local item = { 
		x = 0,
		y = 0,
		width = 10,
		height = 10,
		sprite = nil,
		name = "",
		floatTimer = 0,
		floatTime = 1,
		floatHeightMin = 0, --pixels above surface
		floatHeightMax = 15,
		ascending = true,
		isVisible = true,
		ySpeed = 0,
		xSpeed = 0,
		gravity_const = 9.8,
		next_y = 0,
		isTouchingFloor = false, --if true, can be picked up
		hasBeenPickedUp = false,
	}
	
	item.sprites = {}
	item.sprites.sword = love.graphics.newImage("images/sword.PNG")
	
	setmetatable(item,Item)
	return item
end

function Item:update(dt)

	if not self.isTouchingFloor then
		self.ySpeed = self.ySpeed + gravity_const*dt
		
		self.next_y = self.y + self.ySpeed
	end
	
	if self.isTouchingFloor then
	
		if self.ascending then
			if self.floatTimer < self.floatTime then
				self.floatTimer = self.floatTimer + dt
				self.next_y = self.next_y - dt*10
			else
				self.ascending = false
				self.floatTimer = 0
			end
				
				
		else
			if self.floatTimer < self.floatTime then
				self.floatTimer = self.floatTimer + dt
				self.next_y = self.next_y + dt*10
			else
				self.ascending = true
				self.floatTimer = 0
			end
		end
	end
	
	self:boundaryCollisions(ground, platforms, boxes)
	
	self.y = self.next_y
end

function Item:boundaryCollisions(ground, platforms) --no boxes yet lol, gotta figure that shit out
	while self.next_y + self.height + self.floatHeightMin > g.getHeight()-ground.height do
		self.next_y = self.next_y - 0.1
		self.isTouchingFloor = true
		self.ySpeed = 0
	end
	
end