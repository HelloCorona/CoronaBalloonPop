local EnterFrameManager = require("managers.EnterFrameManager")
local MathUtils = require("utils.MathUtils")

local Class = {}

--========= 게임 스코어 Get/Set Begin =========--
local _score

Class.getScore = function ()
    return _score
end

Class.setScore = function (value)
    _score = value
    
    local evt = {name="changeScore", score=_score}
	Runtime:dispatchEvent(evt)
end
--========= 게임 스코어 Get/Set End =========--

--========= 플레이어 생명 갯수 Get/Set Begin =========--
local _playerLifeCount

Class.getPlayerLifeCount = function ()
	return tonumber(_playerLifeCount)
end

Class.setPlayerLifeCount = function (value)
	_playerLifeCount = tonumber(value)

	local evt = {name="changePlayerLifeCount", count=_playerLifeCount}
	Runtime:dispatchEvent(evt)
end
--========= 플레이어 생명 갯수 Get/Set End =========--

--========= 일시정지 관련 Get/Fn Begin =========--
local _isPaused = false
local timerIDs = nil

Class.isPaused = function ()
	return _isPaused
end

Class.pauseGame = function (dispatchEvent)
	dispatchEvent = dispatchEvent or true
	
	if _isPaused == true then return end
	
	_isPaused = true
	
	--===== 일시 정지 Begin =====--
	-- physics.pause()는 GameScene의 상황에 따라
	EnterFrameManager.pause()
	transition.pause()
	
	timerIDs = {}
	for k, v in pairs(timer._runlist) do
		table.insert(timerIDs, v)
		timer.pause(v)
	end
	--===== 일시 정지 End =====--
	
	if dispatchEvent == true then Runtime:dispatchEvent({name="pauseGame"}) end
end

Class.resumeGame = function (dispatchEvent)
	dispatchEvent = dispatchEvent or true
	
	if _isPaused == false then return end
	
	_isPaused = false
	
	--===== 일시 정지 Begin =====--
	-- physics.start()는 GameScene의 상황에 따라
	EnterFrameManager.resume()
	transition.resume()
	
	for k, v in pairs(timerIDs) do
		timer.resume(v)
	end
	timerIDs = nil
	--===== 일시 정지 End =====--

	if dispatchEvent == true then Runtime:dispatchEvent({name="resumeGame"}) end
end
--========= 일시정지 관련 Get/Fn End =========--

--========= 사운드 제어 Begin =========--
local bgmChannel = nil
Class.playBGM = function (sndPath)
	Class.stopBGM()
	
	local gbm = audio.loadStream(sndPath)
	bgmChannel = audio.play( gbm, { channel=1, loops=-1 } )
end

Class.stopBGM = function ()
	if bgmChannel ~= nil then audio.stop(bgmChannel) end
	bgmChannel = nil
end

Class.playEffectSound = function (sndPath)
	local snd = audio.loadSound(sndPath)
	local availableChannel = audio.findFreeChannel()
	audio.play( snd, { channel=availableChannel } )
end

Class.stopAllSounds = function ()
	audio.stop()
end

Class.setVolume = function (value)
	audio.setVolume(value)
end
--========= 사운드 제어 End =========--

--========= 설정 초기화 Begin =========--
Class.init = function ()
    _score = 0
    _playerLifeCount = 5
	_isPaused = false
	
	EnterFrameManager.init()
end
--========= 설정 초기화 End =========--

return Class