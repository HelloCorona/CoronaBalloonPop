local GameConfig = require("GameConfig")

local Class = {}

Class.create = function (_parent)
    local mainG = display.newGroup()
    _parent:insert(mainG)
    
    local function addLife()
		local life = display.newImage(mainG, "images/heart.png", 0, 0)
		__setScaleFactor(life)

		local lastChild = mainG[mainG.numChildren - 1]
		if lastChild ~= nil then
			life.x = lastChild.x + lastChild.width + 5
		end
	end

	local function subtractLife()
		mainG:remove(mainG.numChildren)
	end
    
    local function on_ChangePlayerLifeCount(e)
		local val = e.count - mainG.numChildren
		if val < 0 then -- 생명이 줄었음
			for i = math.abs(val), 1, -1 do subtractLife() end
		else -- 생명이 늘었음
			for i = 1, math.abs(val) do addLife() end
		end
	end
	Runtime:addEventListener("changePlayerLifeCount", on_ChangePlayerLifeCount)
    
    -- 초기 생명 설정
	for i = 1, GameConfig.getPlayerLifeCount() do addLife() end
    
    return mainG
end

return Class