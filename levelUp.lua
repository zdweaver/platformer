LevelUp = {}
LevelUp.__index = LevelUp

function LevelUp:new(x,y, image)
	local levelUp = {
	
	x = x,
	y = y,
	image = image,
	timer = 0,
	timerMax = 3.5,
	fadeOutBeginsAt = 2,
	active = true,
	}
	setmetatable(levelUp, LevelUp)
	return levelUp
end