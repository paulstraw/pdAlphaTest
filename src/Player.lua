class("Player").extends()
local Player <const> = Player

local gfx <const> = playdate.graphics
local roundToNearest <const> = util.roundToNearest

local playerImages <const> = gfx.imagetable.new('img/player')
local speed <const> = 1

function Player:init(startX, startY)
	self.x = startX
	self.y = startY
	self.currentLevel = nil
	self.angle = 0
	self.moveX = 0
	self.moveY = 0

	self.sprite = gfx.sprite.new(self:_getImage(self.angle))
	self.sprite:add()
	self.sprite:moveTo(self.x, self.y)

	self:_initInput()
end

function Player:setLevel(level)
	self.currentLevel = level
end

function Player:_getImage(degrees)
  return playerImages:getImage(
    (roundToNearest(degrees, 45) % 360) / 45 + 1
  )
end

function Player:setAngle(newAngle)
	self.angle = newAngle
	self.sprite:setImage(self:_getImage(newAngle))
end

function Player:update()
	self.x += self.moveX * speed
	self.y += self.moveY * speed

	self.sprite:moveTo(self.x, self.y)
end

function Player:_initInput()
	playdate.inputHandlers.push({
		upButtonDown = function()
			self.moveY -= 1
		end,

		upButtonUp = function()
			self.moveY += 1
		end,

		rightButtonDown = function()
			self.moveX += 1
		end,

		rightButtonUp = function()
			self.moveX -= 1
		end,

		downButtonDown = function()
			self.moveY += 1
		end,

		downButtonUp = function()
			self.moveY -= 1
		end,

		leftButtonDown = function()
			self.moveX -= 1
		end,

		leftButtonUp = function()
			self.moveX += 1
		end,
	})
end
