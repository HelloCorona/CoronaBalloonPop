local Fonts = require("Fonts")
local GameConfig = require("GameConfig")
local EnterFrameManager = require("managers.EnterFrameManager")
local ColorUtils = require("utils.ColorUtils")
local GameUXManager = require("managers.GameUXManager")
local MathUtils = require("utils.MathUtils")
local Balloon = require("scenes.controls.Balloon")
local Bomb = require("scenes.controls.Bomb")
local MissionFailedPopup = require("scenes.controls.MissionFailedPopup")
local LifeBox = require("scenes.controls.LifeBox")

--##############################  Main Code Begin  ##############################--
local composer = require( "composer" )

local scene = composer.newScene()

local createBg, createBalloons, startGame, on_DecreaseLife
local startGameTimer, stopGameTimer, pauseGameTimer, resumeGameTimer
local balloonLayer, createBalloonsTimer
local scoreTxt

local maxTime = 120 -- 변하지 않는 값
local gameTime = 0 -- 현재 경과된 시간

-- "scene:create()"
function scene:create( event )
	local sceneGroup = self.view
	
	-- 배경음악
	GameConfig.playBGM("sounds/game.mp3")

	--=========== 배경 생성 Begin ===========--
	local bg = createBg(sceneGroup)
	--=========== 배경 생성 End ===========--
    
    --=========== 풍선 생성 Begin ===========--
    balloonLayer = display.newGroup()
    sceneGroup:insert(balloonLayer)
    --=========== 풍선 생성 End ===========--
    
    --=========== 생명 박스 생성 Begin ===========--
    local lifeBox = LifeBox.create(sceneGroup)
    lifeBox.x, lifeBox.y = 10, 10
    --=========== 생명 박스 생성 End ===========--
    
    --=========== 스코어 텍스트 생성 Begin ===========--
    scoreTxt = display.newText(sceneGroup, GameConfig.getScore(), 0, 50, 0, 0, Fonts.NotoSans, 50)
    scoreTxt:setFillColor(ColorUtils.hexToPercent("5f9fa4"))
    scoreTxt.anchorX = 0.5
    scoreTxt.x = __appContentWidth__ * 0.5
    
    local function on_ChangeScore(e)
        scoreTxt.text = e.score
    end
    Runtime:addEventListener("changeScore", on_ChangeScore)
    --=========== 스코어 텍스트 생성 End ===========--
    
	--=========== 게임 타이머 Begin ===========--
	local gTimer
    local gTimerPaused
    
	-- 게임 타이머 시작
	startGameTimer = function (totalTime)
        gameTime = 0
        gTimerPaused = false
        
		local function on_Timer(e)
            gameTime = e.count
            
			-- 타임 아웃!!
			if totalTime <= e.count then
				stopGameTimer()
				
				-- 이 게임은 시간과 상관없음
			end
		end
		gTimer = timer.performWithDelay(1000, on_Timer, totalTime)
	end
	
	-- 게임 타이머 정지
	stopGameTimer = function ()
        gTimerPaused = false
		if gTimer ~= nil then timer.cancel(gTimer) end
		gTimer= nil
	end
    
    pauseGameTimer = function ()
        if gTimerPaused then return end
        
        timer.pause(gTimer)
        gTimerPaused = true
    end
    
    resumeGameTimer = function ()
        if not gTimerPaused then return end
        
        timer.resume(gTimer)
        gTimerPaused = false
    end
	--=========== 게임 타이머 End ===========--
    
    startGame()
end

-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )

-- -------------------------------------------------------------------------------

-- 배경 생성
createBg = function (sceneGroup)
	local bg = display.newImage(sceneGroup, "images/game_bg.png", 0, 0)

	local scaleFactor = __appContentWidth__ / bg.width

	bg.width, bg.height = bg.width * scaleFactor, bg.height * scaleFactor
	bg.y = __appContentHeight__ - bg.height

	return bg
end

-- 풍선 생성
createBalloons = function ()
    local createBalloon
    
    createBalloon = function(e)
        local Class = (math.random(0, 3) == 2 and Bomb or Balloon)
        local balloon = Class.create(balloonLayer, (gameTime + 5) * 0.3)
        balloon.x, balloon.y = math.random(20, __appContentWidth__ - balloon.width - 20), __appContentHeight__
        
        createBalloonsTimer = timer.performWithDelay((1 - (gameTime / (maxTime + 1))) * 500, createBalloon, 1)
    end
    createBalloon(nil)
end

-- 생명 감소 이벤트 핸들러
on_DecreaseLife = function (e)
    local _newLifeCount = GameConfig.getPlayerLifeCount() - 1
    GameConfig.setPlayerLifeCount(_newLifeCount)

    -- 게임 오버!!
    if _newLifeCount <= 0 then
        Runtime:removeEventListener("decreaseLife", on_DecreaseLife)
        if createBalloonsTimer then timer.cancel(createBalloonsTimer) end

        -- 모든 풍선이 다 터졌는지 체크
        --[[local function on_CheckEnd(e2)
            if EnterFrameManager.enterFrameFunctions == nil then -- 엔터프레임 완료
               Runtime:removeEventListener("enterFrame", on_CheckEnd)
               print("모든 풍선이 다 터짐")
            end
        end
        Runtime:addEventListener("enterFrame", on_CheckEnd)]]
        
        -- 실패 팝업창
        local failedPopup = MissionFailedPopup.create(startGame)
        scene.view:insert(failedPopup)
    end
end

-- 게임 (재)시작
startGame = function ()
    -- 모두 정지
    EnterFrameManager.removeAllListeners()
    for id, value in pairs(timer._runlist) do
        timer.cancel(value)
    end
    
    for i = balloonLayer.numChildren, 1, -1 do
        balloonLayer:remove(i)
    end
    
    GameConfig.init() -- 게임 데이터 초기화
    startGameTimer(maxTime) -- 타이머 시동
    createBalloons() -- 풍선 생성
    GameConfig.setScore(0)
    GameConfig.setPlayerLifeCount(GameConfig.getPlayerLifeCount())
    Runtime:addEventListener("decreaseLife", on_DecreaseLife)
end
-- -------------------------------------------------------------------------------

return scene
--##############################  Main Code End  ##############################--