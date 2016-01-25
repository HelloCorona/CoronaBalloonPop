local EnterFrameManager = require("managers.EnterFrameManager")
local particleDesigner = require( "managers.particleDesigner" )
local GameConfig = require("GameConfig")

local Class = {}

Class.create = function (_parent, bulletSpeed)
    local mainG = display.newGroup()
    _parent:insert(mainG)
    
	-- 풍선 생성 (화면 밖으로 나가는 계산을 간편하게 하기 위해 좌상단을 기준점으로 함)
	local bomb = display.newImage(mainG, "images/bomb.png", 0, 0)
	__setScaleFactor(bomb)

	local areaRect = display.newRect(mainG, 0, bomb.height - 30, bomb.width * 0.75, 52)
	areaRect.alpha = 0.01
    
    --============ 폭탄 스프라이트 생성 Begin ============--
    local spriteG = display.newGroup()
	local options = { frames = require("images.explosion").frames }
	local umaSheet = graphics.newImageSheet( "images/explosion.png", options )
	local spriteOptions = { name="explosion", start=1, count=16, time=300, loopCount=1 }
	local spriteInstance = display.newSprite( spriteG, umaSheet, spriteOptions )
	__setScaleFactor(spriteG)
    spriteG.x, spriteG.y = -17, 18
    spriteInstance.isVisible = false
	mainG:insert(spriteG)
	--============ 폭탄 스프라이트 생성 End ============--
    
    local function on_BalloonTouch(e)
    	if e.phase == "began" then
            mainG:removeEventListener("touch", on_BalloonTouch)
	        bomb:removeSelf()
            
            -- 사운드
			GameConfig.playEffectSound("sounds/bomb.mp3")
	        
	        spriteInstance.isVisible = true
	        spriteInstance:play()
            
            local evt = {name="decreaseLife"}
            Runtime:dispatchEvent(evt)
	        
	        local function destroy()
	            mainG.destroy()
	        end
	        timer.performWithDelay(300, destroy)
	    end
        
        return true
    end
    mainG:addEventListener("touch", on_BalloonTouch)
    
	-- 이동
	mainG.on_EnterFrame = EnterFrameManager.addListener(function (e)
		mainG.y = mainG.y - bulletSpeed
		if mainG.y < -mainG.height then
            mainG.destroy()
        end
	end)

	--===================================
	--
	-- Public Methods
	--
	--===================================

	-- 총알 제거
	mainG.destroy = function ()
		EnterFrameManager.removeListener(mainG.on_EnterFrame)
		mainG:removeSelf()
	end
    
	return mainG
end

return Class