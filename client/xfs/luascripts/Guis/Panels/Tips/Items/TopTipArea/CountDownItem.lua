-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\CountDownItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local GmToolUtils = require("Utils.GmToolUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local HotkeyConst = require("Const.HotkeyConst")
local Utils = require("Common.Utils.Utils")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local UICtrl = require("Guis.UICtrl")
local CallbackHandler = require("Core.Common.CallbackHandler")
local CountDownItem = Class.LightClass("CountDownItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function CountDownItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function CountDownItem:pushData(data)
	self:enqueue(data)
	self:tryPopupMatchTip()
end

function CountDownItem:onUpdate()
	self:tryPopupItem()
	self:tryEnterWarnState()
end

function CountDownItem:tryEnterWarnState()
	local data = self:firstRunItem()

	if not data or data._warned or not data.countDown then
		return
	end

	if not data.warnDuration or data.warnDuration <= 0 then
		return
	end

	local cd = data.countDown
	local remaining

	if data.positiveTiming then
		remaining = (cd.totalSecond or 0) - (cd.currentSecond or 0)
	else
		remaining = cd.currentSecond or 0
	end

	if remaining <= data.warnDuration then
		cd:TryChangePage("State", 1)

		data._warned = true
	end
end

function CountDownItem:tryPopupMatchTip()
	local num = #self.dataQueue
	local index, priority = 0, 0

	for i = num, 1, -1 do
		local data = self.dataQueue[i]

		if data.endTime > Time.realSecondCache then
			if priority < data.priority then
				priority = data.priority
				index = i
			end
		else
			table.remove(self.dataQueue, i)

			if index > 1 then
				index = index - 1
			end
		end
	end

	if index <= 0 and self:isRunning() then
		return
	end

	if self:isRunning() then
		local data = self:firstRunItem()

		if priority <= data.priority then
			return
		end

		self:removeItem(data)
		self:enqueue(data)
	elseif index == 0 then
		index = 1
	end

	if self:isQueueEmpty() then
		return
	end

	local data = table.remove(self.dataQueue, index)

	self:addRunItem(data)
	self:initUContainer(data)
end

function CountDownItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	self:tryPopupMatchTip()
end

function CountDownItem:hideById(id)
	local param = self:firstRunItem()

	if param and param.uniqueId == id then
		self:recycleToast(param, true)
	end

	local num = #self.dataQueue

	for i = num, 1, -1 do
		local data = self.dataQueue[i]

		if data.uniqueId == id then
			table.remove(self.dataQueue, i)
		end
	end
end

function CountDownItem:onClearRunningList(force)
	local param = self:firstRunItem()

	if param then
		self:recycleToast(param, force)
	end
end

function CountDownItem:onUIVisibleToHide()
	self:finished()
end

function CountDownItem:initUContainer(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function(loadedItem)
			if IsNil(loadedItem) or self.uContainer.content ~= loadedItem then
				return
			end

			self:innerParseItem(loadedItem, data, true)
		end))
	else
		self:innerParseItem(self.uContainer.content, data)
	end
end

function CountDownItem:refresh(...)
	if self.uContainer.content == nil then
		return
	end

	local uniqueId, extraData = table.unpack({
		...
	})
	local param = self:firstRunItem()

	if param == nil or param.uniqueId ~= uniqueId then
		return
	end

	table.merge(param, extraData)
	self:renderItem(self.uContainer.content, param)
end

function CountDownItem:innerParseItem(item, data)
	if item == nil then
		return
	end

	self:renderItem(item, data)
	item:InvokeCallback(CS.XGUI.EInvokeTime.User1)
end

function CountDownItem:renderItem(item, data, playVx)
	local objectReference = item:GetComponent("ObjectReference")
	local countDown = objectReference:GetRefValue("countDownUCountDown")
	local infoText = objectReference:GetRefValue("infoText")
	local funcBtn = objectReference:GetRefValue("funcBtn")
	local animation = objectReference:GetRefValue("countDownAnimation")
	local btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	local iconTimeUImage = objectReference:GetRefValue("iconTimeUImage")

	if playVx then
		animation:Play("VX_Pb_TipsGene_Frame_CountDown_In")
	end

	local duration = data.duration or 0
	local endTime = data.startTime + duration
	local remainTime = endTime - Time.realSecondCache

	if remainTime <= 0 then
		self:recycleToast(data)

		return
	end

	data.endTime = endTime
	data.countDown = countDown
	countDown.useGameTime = data.useGameTime or false
	data._warned = false

	if data.warnDuration and data.warnDuration > 0 then
		local warnDelay = duration - data.warnDuration

		if warnDelay > 0 then
			if remainTime <= data.warnDuration then
				countDown:TryChangePage("State", 1)

				data._warned = true
			else
				countDown:TryChangePage("State", 0)
			end
		end
	else
		countDown:TryChangePage("State", 0)
	end

	if data.positiveTiming then
		countDown.positiveTiming = true

		countDown:Play(0, duration)
	else
		countDown.positiveTiming = false

		countDown:Play(remainTime, duration)
	end

	countDown.luaFinished = self:guardRunCallback(data, function()
		self:recycleToast(data)

		if data.finishCb then
			data.finishCb()
		end
	end, item)

	if string.isNilOrEmpty(data.infoText) then
		infoText:SetActive(false)
	else
		infoText:SetActive(true)
		ClientTextUtils.setText(infoText, data.infoText)
	end

	if data.customFunc then
		funcBtn:SetActive(true)

		funcBtn.luaClick = self:guardRunCallback(data, function()
			data.customFunc.luaFunc()
		end, item)

		ClientTextUtils.setText(funcBtn:Find("TxtName"):GetComponent("USDFText"), data.customFunc.desc)

		local keyBind = funcBtn:GetComponent("KeyBindingPro")

		keyBind.actionPath = data.customFunc.actionPath
	else
		funcBtn:SetActive(false)
	end

	if data.closeFunc then
		btnCloseUButton:SetActive(true)

		btnCloseUButton.luaClick = data.closeFunc
		self.closeFunc = data.closeFunc

		local setKey = "Hud/CountDownItemClose"
		local btnCloseRef = btnCloseUButton.gameObject:GetComponent("ObjectReference")
		local keyCloseHotKeyContent = btnCloseRef:GetRefValue("keyHotKeyContent")

		if keyCloseHotKeyContent then
			keyCloseHotKeyContent:SetHotKeyPaths(setKey)
			LuaUIUtils.waitHotKeyContentObjectReference(self, keyCloseHotKeyContent, self:guardRunCallback(data, function(objectReference)
				self.progressPressContainerUContainer = objectReference:GetRefValue("progressPressContainerUContainer")

				if not self.progressPressContainerUContainer then
					return
				end

				self.progressPressContainerUContainer:SetActive(true)
				self.progressPressContainerUContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function()
					self.keyProgressPress = self.progressPressContainerUContainer.content

					self.keyProgressPress:ProgressToValue(0, nil)

					local closeBinding = KeyBindingPro.GetOrAddKeyBindingByName(btnCloseUButton.gameObject, "CountDownItemClose")

					closeBinding.isVirtual = true
					closeBinding.actionPath = setKey
					closeBinding.priority = 1
					closeBinding.luaTrigger = self:guardRunCallback(data, function(inputInfo)
						if pg.game.input:isUsingGamepad() then
							UICtrl.longClickLuafunction(self, inputInfo, setKey, 0.55, 0.25, CallbackHandler(self, "onCountDownItemClose"), self.keyProgressPress, self:guardRunCallback(data, function()
								self.keyProgressPress:ProgressToValue(0, nil)
							end, item))

							return false
						end
					end, item)
				end, item))
			end, item))
		end
	else
		btnCloseUButton:SetActive(false)
	end

	if playVx then
		item:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end

	if data.overrideIcon then
		iconTimeUImage.url = data.overrideIcon
	end
end

function CountDownItem:onCountDownItemClose()
	if self.closeFunc then
		self.closeFunc()
	end
end

function CountDownItem:hideArea(flags)
	if table.contains(flags, TipAreaConst.UITipAreaFlag.AreaFlag_FullScreen) then
		local param = self:firstRunItem()

		if param.useGameTime and not param._countDownPauseCache and self:checkTimePause() then
			self:pauseCountDown(param)
		end
	end
end

function CountDownItem:showArea(flags)
	local param = self:firstRunItem()

	if not param.useGameTime then
		return
	end

	if self:checkTimePause() then
		if not param._countDownPauseCache then
			self:pauseCountDown(param)
		end
	elseif param._countDownPauseCache then
		self:resumeCountDown(param)
	end
end

function CountDownItem:checkTimePause()
	local timeZoneList = pg.pawn.timeScaleMgr.timeZones
	local finalTimeScale = pg.pawn:getFinalTimeScale()

	return not Utils.tableIsEmptyOrNil(timeZoneList) or finalTimeScale == 0
end

function CountDownItem:pauseCountDown(param)
	local currentSecond = param.countDown.currentSecond
	local totalSecond = param.countDown.totalSecond

	param._countDownPauseCache = {
		currentSecond,
		totalSecond
	}

	param.countDown:Stop()
end

function CountDownItem:resumeCountDown(param)
	local currentSecond = param._countDownPauseCache[1]
	local totalSecond = param._countDownPauseCache[2]

	param.countDown:Play(currentSecond, totalSecond)

	param._countDownPauseCache = nil
end

function CountDownItem:GMPushData(data)
	data.startTime = Time.realSecondCache
end

return CountDownItem
