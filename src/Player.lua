class("Player").extends()
local Player <const> = Player

local gfx <const> = playdate.graphics
local roundToNearest <const> = util.roundToNearest
local debugDraw <const> = util.debugDraw
local mathCeil <const> = math.ceil
local mathFloor <const> = math.floor

local playerImages <const> = gfx.imagetable.new('img/player')
local speed <const> = 0.2
local runSpeedMultiplier <const> = 5
local halfSpriteSize <const> = 16
local tileSize <const> = 16
local halfTileSize <const> = tileSize * 0.5

function Player:init(startX, startY)
	self.x = startX
	self.y = startY
	self.angle = 0

	self.isUpDown = false
	self.isRightDown = false
	self.isDownDown = false
	self.isLeftDown = false
	self.isBDown = false

	self:_initSprite()
	self:_initInput()
end

function Player:_initSprite()
	local sprite = gfx.sprite.new(self:_getImage(self.angle))
	sprite:add()
	sprite:moveTo(self.x, self.y)

	sprite:setCollideRect(0, 0, sprite:getSize())
	sprite.collisionResponse = gfx.sprite.kCollisionTypeOverlap

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
	local moveX = self.isRightDown and speed or self.isLeftDown and -speed or 0
	local moveY = self.isDownDown and speed or self.isUpDown and -speed or 0

	if self.isBDown then
		moveX *= runSpeedMultiplier
		moveY *= runSpeedMultiplier
	end

	self.x += moveX
	self.y += moveY

	self.sprite:moveTo(
		mathFloor(self.x),
		mathFloor(self.y)
	)

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
			self.isUpDown = true
		end,

		upButtonUp = function()
			self.isUpDown = false
		end,

		rightButtonDown = function()
			self.isRightDown = true
		end,

		rightButtonUp = function()
			self.isRightDown = false
		end,

		downButtonDown = function()
			self.isDownDown = true
		end,

		downButtonUp = function()
			self.isDownDown = false
		end,

		leftButtonDown = function()
			self.isLeftDown = true
		end,

		leftButtonUp = function()
			self.isLeftDown = false
		end,

		BButtonDown = function()
			self.isBDown = true
		end,

		BButtonUp = function()
			self.isBDown = false
		end,
	})
end
