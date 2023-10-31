import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

import "util"

import "Player"

local gfx <const> = playdate.graphics


local player = Player(200, 120)

-- Just here to control px-perfect player speed
playdate.display.setRefreshRate(20)

gfx.clear(gfx.kColorBlack)
gfx.setBackgroundColor(gfx.kColorBlack)

local tileImages <const> = gfx.imagetable.new('img/tiles')

-- Sprites for alpha collision test
local spr1 <const> = gfx.sprite.new(tileImages:getImage(1))
spr1:setCollideRect(0, 0, spr1:getSize())
spr1:moveTo(170, 120)
spr1:add()
local spr5 <const> = gfx.sprite.new(tileImages:getImage(5))
spr5:setCollideRect(0, 0, spr5:getSize())
spr5:moveTo(230, 120)
spr5:add()

-- Sprites for collision count test
local cc1Spr5 <const> = gfx.sprite.new(tileImages:getImage(5))
cc1Spr5:setCollideRect(0, 0, cc1Spr5:getSize())
cc1Spr5:moveTo(180, 60)
cc1Spr5:add()
local cc2Spr5 <const> = gfx.sprite.new(tileImages:getImage(5))
cc2Spr5:setCollideRect(0, 0, cc2Spr5:getSize())
cc2Spr5:moveTo(220, 60)
cc2Spr5:add()

function playdate.update()
	player:setAngle(playdate.getCrankPosition())
	player:update()

	gfx.sprite.update()

	playdate.drawFPS(382, 225)
end
