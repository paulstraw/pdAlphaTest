class("Player").extends()
local Player <const> = Player

local gfx <const> = playdate.graphics
local roundToNearest <const> = util.roundToNearest
local debugDraw <const> = util.debugDraw
local mathCeil <const> = math.ceil

local playerImages <const> = gfx.imagetable.new('img/player')
local speed <const> = 1
local halfSpriteSize <const> = 16
local tileSize <const> = 16
local halfTileSize <const> = tileSize * 0.5

function Player:init(startX, startY)
	self.x = startX
	self.y = startY
	self.angle = 0
	self.moveX = 0
	self.moveY = 0

	self:_initSprite()
	self:_initInput()
end

function Player:_initSprite()
	local sprite = gfx.sprite.new(self:_getImage(self.angle))
	sprite:add()
	sprite:moveTo(self.x, self.y)

	sprite:setCollideRect(0, 0, sprite:getSize())

	self.sprite = sprite
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

	self:_updateCollision()
end

function Player:_updateCollision()
	local _actualX, _actualY, collisions, collisionsCount = self.sprite:checkCollisions(self.x, self.y)

	if collisionsCount > 0 then
		for i = 1, collisionsCount do
			self:_checkAlphaCollision(collisions[i])
		end
	end

	util.debugDraw(function()
		gfx.pushContext()
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		gfx.drawTextAligned(
			"collCount: " .. collisionsCount .. "," .. #collisions,
			400,
			0,
			kTextAlignment.right
		)
		gfx.popContext()
	end)
end

function Player:_checkAlphaCollision(collision)
	if self.sprite:alphaCollision(collision.other) then
		util.debugDraw(function()
			gfx.pushContext()
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			gfx.drawTextAligned(
				"ALPHA COLL",
				400,
				16,
				kTextAlignment.right
			)
			gfx.popContext()
		end)
	end
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
