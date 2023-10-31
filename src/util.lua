util = {}

local mathFloor <const> = math.floor

function util.roundToNearest(num, mult)
	return mathFloor(num / mult + 0.5) * mult
end

local ddFns = {}
function util.debugDraw(fn)
	table.insert(ddFns, fn)
end

function playdate.debugDraw()
	for i, fn in ipairs(ddFns) do
		fn()
	end

	ddFns = {}
end
