DamageText = {}
DamageText.__index = DamageText

--to (eventually) do: replace text with sprite numbers (using a sprite sheet)

--Damage text dynamically appears wherever damage is taken, then fades out over time.

function DamageText:new(x, y, value, color)
	local damageText = {
	
		x = x,
		y = y,
		value = value,
		color = color,
		durationTimer = 0, 
		durationTimerMax = 1,
		active = true,
	}
	setmetatable(damageText, DamageText)
	return damageText
end
	
	
function DamageText:update(dt)
	self.durationTimer = self.durationTimer + dt
	if self.durationTimer >= self.durationTimerMax then
		self.durationTimer = 0
		self.active = false 	--marked for deletion
	end
end