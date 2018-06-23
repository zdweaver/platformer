Tombstone = {}
Tombstone.__index = Tombstone

function Tombstone:new()
	local tombstone = {
	
	x = 0,
	y = 0,
	height = 0,
	image = image,
	
	}
	tombstone.image = g.newImage("images/tombstone.PNG")
	
	setmetatable(tombstone, Tombstone)
	return tombstone
end

