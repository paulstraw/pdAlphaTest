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
	self.currentLevel = nil
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
			"collCount: " .. collisionsCount,
			400,
			0,
			kTextAlignment.right
		)
		gfx.popContext()
	end)
end

function Player:_checkAlphaCollision(collision)
	local cTouch = collision.touch
	local cNormal = collision.normal

	util.debugDraw(function()
		-- Collision normal
		gfx.drawCircleAtPoint(cTouch.x, cTouch.y, 3)
		local normalX = cTouch.x + cNormal.x * 16
		local normalY = cTouch.y + cNormal.y * 16
		gfx.drawLine(cTouch.x, cTouch.y, normalX, normalY)

		self.sprite:getImage():draw(
			self.x - halfSpriteSize,
			self.y - halfSpriteSize
		)
	end)

	-- Find hit tile position based on touch point and normal
	-- Start at center of self when collision happened (touch point)
	local hitTilePos = {x = cTouch.x, y = cTouch.y}
	-- Move into tile (not centered in tile, but that shouldn't matter)
	hitTilePos.x -= cNormal.x * (halfSpriteSize + halfTileSize)
	hitTilePos.y -= cNormal.y * (halfSpriteSize + halfTileSize)

	-- Get position in tilemap (1 indexing)
	local tileX = mathCeil(hitTilePos .x/ tileSize)
	local tileY = mathCeil(hitTilePos.y / tileSize)

	-- Check two neighbors perpendicular to normal to help with corner detection
	local n1TileX = tileX + collision.normal.y
	local n1TileY = tileY + collision.normal.x
	local n2TileX = tileX - collision.normal.y
	local n2TileY = tileY - collision.normal.x

	local tilemap = self.currentLevel.map
	local getTileAtPos = tilemap.getTileAtPosition
	local tilesToCheck = {
		{
			x = tileX,
			y = tileY,
			tile = getTileAtPos(tilemap, tileX, tileY),
		},
		{
			x = n1TileX,
			y = n1TileY,
			tile = getTileAtPos(tilemap, n1TileX, n1TileY),
		},
		{
			x = n2TileX,
			y = n2TileY,
			tile = getTileAtPos(tilemap, n2TileX, n2TileY),
		},
	}

	util.debugDraw(function()
		for i, tileToCheck in ipairs(tilesToCheck) do
			gfx.drawCircleAtPoint(
				(tileToCheck.x - 0.5) * tileSize,
				(tileToCheck.y - 0.5) * tileSize,
				3
			)
		end
	end)

	for i, tileToCheck in ipairs(tilesToCheck) do
		self:_checkTileAlphaCollision(tileToCheck, tilemap)
	end
end

function Player:_checkTileAlphaCollision(tileToCheck, tilemap)
	if tileToCheck.tile == nil then
		return
	end

	local imagetable = self.currentLevel.imagetable

	-- Get tile pixel coords
	local tileX = (tileToCheck.x - 1) * tileSize
	local tileY = (tileToCheck.y - 1) * tileSize
	local tileImage = imagetable:getImage(tileToCheck.tile)

	util.debugDraw(function()
		gfx.pushContext()
		-- gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		tileImage:draw(tileX, tileY)
		gfx.popContext()
	end)

	-- Finally check alpha collision with the tile
	local alphaColl = gfx.checkAlphaCollision(
		self.sprite:getImage(),
		self.x - halfSpriteSize,
		self.y - halfSpriteSize,
		gfx.kImageUnflipped,
		tileImage,
		tileX,
		tileY,
		gfx.kImageUnflipped
	)

	if alphaColl then
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
