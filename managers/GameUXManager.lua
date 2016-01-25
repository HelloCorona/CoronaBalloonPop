local Class = {}

local isTapped = false

Class.applyMotionButton = function (btn, touchEventCallBack, completeCallback, tapCallBack)
	local function on_Touch(e)
		if btn.enabled == false then return end
		
		local phase = e.phase
		if phase == "began" then
			display:getCurrentStage():setFocus(btn)
			transition.cancel(btn)
			isTapped = false
			btn.xScale = 0.9
			btn.yScale = 0.9
		elseif phase == "ended" then
			display:getCurrentStage():setFocus(nil)
			
			transition.to(btn, {time=100, xScale=1.15, yScale=1.15,
				onComplete = function ()
					transition.to(btn, {time=100, xScale=0.9, yScale=0.9,
						onComplete = function ()
							transition.to(btn, {time=100, xScale=1, yScale=1,
								onComplete = function ()
									-- 완료되었을 때 탭(tap)이 되었는지 여부를 넘겨줌
									if completeCallback then completeCallback(isTapped) end
									isTapped = false
								end
							})
						end
					})
				end
			})
		end
		
		if touchEventCallBack then touchEventCallBack(e) end
	end
	btn:addEventListener("touch", on_Touch)
	
	local function on_Tap(e)
		if btn.enabled == false then return end
		
		isTapped = true
		if tapCallBack then tapCallBack() end
	end
	btn:addEventListener("tap", on_Tap)
end

return Class