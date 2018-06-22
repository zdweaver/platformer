Tombstone = {}
Tombstone.__index = Tombstone

function Tombstone:new(x,y, image)
	local tombstone = {
	
	x = x,
	y = y,
	image = image,
	
	}
	setmetatable(tombstone, Tombstone)
	return tombstone
end