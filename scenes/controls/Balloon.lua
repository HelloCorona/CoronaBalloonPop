local EnterFrameManager = require("managers.EnterFrameManager")
local particleDesigner = require( "managers.particleDesigner" )
local GameConfig = require("GameConfig")

local Class = {}

Class.create = function (_parent, bulletSpeed)
	-- 풍선 생성 (화면 밖으로 나가는 계산을 간편하게 하기 위해 좌상단을 기준점으로 함)
	local balloon = display.newImage(_parent, "images/balloon"..math.random(1, 5)..".png", 0, 0)
	__setScaleFactor(balloon)
    
    local function on_BalloonTouch(e)
    	if e.phase == "began" then
            balloon:removeEventListener("touch", on_BalloonTouch)
	        -- 폭파 파티클
	        local emitter = particleDesigner.newEmitter("images/ExplorParticle.json")
	        emitter.x, emitter.y = e.x, e.y

	        balloon.destroy()
            
            -- 사운드
			GameConfig.playEffectSound("sounds/touch.mp3")
            
            GameConfig.setScore(GameConfig.getScore() + 1)
	    end
        
        return true
    end
    balloon:addEventListener("touch", on_BalloonTouch)
    
	-- 이동
	balloon.on_EnterFrame = EnterFrameManager.addListener(function (e)        
		balloon.y = balloon.y - bulletSpeed
		if balloon.y < -balloon.height then
            local evt = {name="decreaseLife"}
            Runtime:dispatchEvent(evt)
            
            balloon.destroy()
        end
	end)

	--===================================
	--
	-- Public Methods
	--
	--===================================

	-- 총알 제거
	balloon.destroy = function ()
		EnterFrameManager.removeListener(balloon.on_EnterFrame)
		balloon:removeSelf()
	end
    
	return balloon
end

return Class