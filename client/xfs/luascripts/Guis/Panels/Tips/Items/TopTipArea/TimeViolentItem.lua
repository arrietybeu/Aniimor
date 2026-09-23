-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\TimeViolentItem.lua

local Class = require("Core.Framework.Class")
local ok, CountDownItem = pcall(require, "Guis.Panels.Tips.Items.TOPTipArea.CountDownItem")

if not ok then
	CountDownItem = require("Guis.Panels.Tips.Items.TopTipArea.CountDownItem")
end

local ClientTextUtils = require("Utils.ClientTextUtils")
local Time = require("Core.Common.Time")
local TimeViolentItem = Class.LightClass("TimeViolentItem", CountDownItem)

local function runCountDown(data, countDown, startTime, duration, onFinish)
	local endTime = startTime + duration
	local remainTime = endTime - Time.realSecondCache

	if remainTime <= 0 then
		onFinish()

		return false
	end

	data.endTime = endTime
	data.countDown = countDown

	if countDown then
		countDown.useGameTime = data.useGameTime or false
		countDown.positiveTiming = data.positiveTiming and true or false

		if countDown.positiveTiming then
			countDown:Play(0, duration)
		else
			countDown:Play(remainTime, duration)
		end

		function countDown.luaFinished()
			onFinish()
		end
	end

	return true
end

function TimeViolentItem:refreshInfoText(data, infoText)
	if infoText then
		if data._violentState == 0 or string.isNilOrEmpty(data.textKey) then
			infoText:SetActive(false)
		else
			infoText:SetActive(true)
			ClientTextUtils.setText(infoText, pg.getGameString(data.textKey))
		end
	end
end

function TimeViolentItem:renderItem(item, data, playVx)
	local objectReference = item:GetComponent("ObjectReference")

	if objectReference == nil then
		local remainTime = data.endTime - Time.realSecondCache

		if remainTime <= 0 then
			self:recycleToast(data)
		end

		return
	end

	local countDown = objectReference:GetRefValue("countDownUCountDown")
	local infoText = objectReference:GetRefValue("txtViolentUBaseText")
	local rootComponent = objectReference:GetRefValue("rootComponent")
	local duration = data.duration or 0
	local loopDuration = data.loopTime or 1

	if duration <= 0 then
		self:recycleToast(data)

		return
	end

	local tipType = tonumber(data.type) or 0

	if tipType < 0 or tipType > 2 then
		tipType = 0
	end

	if tipType == 0 then
		data._violentState = 0

		rootComponent:TryChangePage("Violent", 0)
		runCountDown(data, countDown, data.startTime, duration, self:guardRunCallback(data, function()
			self:recycleToast(data)

			if data.finishCb then
				data.finishCb()
			end
		end, item))
	elseif tipType == 1 then
		if data._violentState == 1 then
			rootComponent:TryChangePage("Violent", 1)

			if countDown then
				countDown:Stop()

				countDown.luaFinished = nil
			end
		else
			data._violentState = 0

			rootComponent:TryChangePage("Violent", 0)
			runCountDown(data, countDown, data.startTime, duration, self:guardRunCallback(data, function()
				data._violentState = 1

				self:refreshInfoText(data, infoText)
				rootComponent:TryChangePage("Violent", 1)

				if countDown then
					countDown:Stop()

					countDown.luaFinished = nil
				end
			end, item))
		end
	else
		local loopRound

		loopRound = self:guardRunCallback(data, function()
			if data.removing then
				return
			end

			rootComponent:TryChangePage("Violent", 2)
			self:refreshInfoText(data, infoText)
			item:InvokeCallback(CS.XGUI.EInvokeTime.User1)
			runCountDown(data, countDown, Time.realSecondCache, loopDuration, loopRound)
		end, item)

		if data.isRecover then
			rootComponent:TryChangePage("Violent", 2)
			self:refreshInfoText(data, infoText)
			item:InvokeCallback(CS.XGUI.EInvokeTime.User1)

			local startTime = data._violentLoopStartTime or Time.realSecondCache

			runCountDown(data, countDown, startTime, loopDuration, loopRound)
		elseif data._violentLooping then
			rootComponent:TryChangePage("Violent", 2)
		else
			data._violentState = 0

			rootComponent:TryChangePage("Violent", 0)
			runCountDown(data, countDown, data.startTime, duration, self:guardRunCallback(data, function()
				data._violentState = 2
				data._violentLooping = true

				loopRound()
			end, item))
		end
	end
end

return TimeViolentItem
