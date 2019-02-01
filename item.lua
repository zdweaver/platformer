Item = {}
Item.__index = Item

function Item:new()
	local item = { 
		x = 0,
		y = 0,
		width = 0,
		height = 0,
		sprite = nil,
		desc = "",
	}
	setmetatable(item,Item)
	return item
end