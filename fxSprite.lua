FxSprite = {}
FxSprite.__index = FxSprite

--to (eventually) do: replace text with sprite numbers (using a sprite sheet)

--Damage text dynamically appears wherever damage is taken, then fades out over time.

function FxSprite:new(name)
	local fxSprite = {
	
		x = x,
		y = y,
		animFrameTimer = 0,
		frameTime = 3/60,
		loopCounter = 0,
		loops = 2,
		isVisible = true,
		currentFrame = 1,
		currentSprite = nil,
	}
	
	fxSprite.sprites = {}
	fxSprite.sprites.name = name --must be "fastfall spark"
	
	fxSprite.sprites.fastfall = {}
	fxSprite.sprites.fastfall[1] = love.graphics.newImage("images/fastfall spark1.PNG")
	fxSprite.sprites.fastfall[2] = love.graphics.newImage("images/fastfall spark2.PNG")
	fxSprite.currentSprite = fxSprite.sprites.fastfall[1]
	
	setmetatable(fxSprite, FxSprite)
	return fxSprite
end
	
	
function FxSprite:update(dt)

	if self.sprites.name == "fastfall spark" then
		self.animFrameTimer = self.animFrameTimer + dt
		if self.animFrameTimer >= self.frameTime then
			self.animFrameTimer = 0
			
			if self.currentFrame < #self.sprites.fastfall then
				self.currentFrame = self.currentFrame + 1
			else
				self.currentFrame = 1
			end
			
			self.currentSprite = self.sprites.fastfall[self.currentFrame]
			
			self.loopCounter = self.loopCounter + 1
			
			if self.loopCounter > self.loops then
				self.isVisible = false
			end
		end
	end
end