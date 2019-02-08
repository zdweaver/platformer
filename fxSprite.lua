FxSprite = {}
FxSprite.__index = FxSprite

sprites = {}

fastfall = {}
fastfall[1] = love.graphics.newImage("images/fastfall spark1.PNG")
fastfall[2] = love.graphics.newImage("images/fastfall spark2.PNG")
table.insert(sprites, fastfall)

sparkle = {}
sparkle[1] = love.graphics.newImage("images/sword pickUpFlash1.PNG")
sparkle[2] = love.graphics.newImage("images/sword pickUpFlash2.PNG")
sparkle[3] = love.graphics.newImage("images/sword pickUpFlash3.PNG")
sparkle[4] = love.graphics.newImage("images/sword pickUpFlash4.PNG")
sparkle[5] = love.graphics.newImage("images/sword pickUpFlash5.PNG")
table.insert(sprites, sparkle)



function FxSprite:new(name)
	local fxSprite = {
	
		x = x,
		y = y,
		animFrameTimer = 0,
		frameTime = 5/60,
		isVisible = true,
		currentFrame = 1,
		currentSprite = nil,
		name = name,
		selection = 0,
	}
	
	--set initial frame
	if fxSprite.name == "fastfall spark" then
		fxSprite.currentSprite = sprites[1][1]
		fxSprite.selection = 1
	end
		
	if fxSprite.name == "sparkle" then
		fxSprite.currentSprite = sprites[2][1]
		fxSprite.selection = 2
	end
	
	setmetatable(fxSprite, FxSprite)
	return fxSprite
end
	
	
function FxSprite:update(dt)
	
	self.animFrameTimer = self.animFrameTimer + dt
	
	--advance the frames
	if self.animFrameTimer >= self.frameTime then
		self.animFrameTimer = 0
	
		
		if self.currentFrame < (#sprites[self.selection]) then
			self.currentFrame = self.currentFrame + 1
		else
			self.isVisible = false --end of animation
		end

		self.currentSprite = sprites[self.selection][self.currentFrame]
	end
end