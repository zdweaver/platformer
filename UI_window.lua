UI_window = {}
UI_window.__index = UI_window

function UI_window:new()
	local ui_window = {
		x = 0,
		y = 0,
		width = 100,
		height = 100,
		isVisible = true,
		hasMouseFocus = false,
		canBeClicked = false,
		isHeld = false,
		isSelectedByMouse = false,
		backgroundColor = {0,0,0,255},
		hoverColor = {0,0,0,230},
		selectedColor = {20,20,20,230},
		currentColor = {0,0,0,230},
		clickedAtX = 0,
		clickeAtY = 0,
		text = "",
		textColor = {255,255,255},
	
	}
	setmetatable(ui_window, UI_window)
	return ui_window
end



function UI_window:setPosition(x,y)
	self.x = x
	self.y = y
end

