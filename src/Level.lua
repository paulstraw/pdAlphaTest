class("Level").extends()
local Level <const> = Level

local gfx <const> = playdate.graphics

local tileImages <const> = gfx.imagetable.new('img/tiles')

function Level:init(levelData, width)
	local map = gfx.tilemap.new()
	map:setImageTable(tileImages)
	map:setTiles(levelData, width)

	self.map = map
end

function Level:update()
	self.map:draw(0, 0)
end
