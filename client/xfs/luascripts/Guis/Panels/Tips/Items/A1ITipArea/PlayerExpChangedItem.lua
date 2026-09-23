-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1ITipArea\\PlayerExpChangedItem.lua

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
local DoTweenAnimMgr = DoTweenAnimMgr
local PlayerExpChangedItem = Class.LightClass("PlayerExpChangedItem", BaseQueueItem)
local Const = require("Common.Const.Const")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local ID_IMG_PROGRESS = "imgProgress"

function PlayerExpChangedItem:onInit()
	self.recycleTimeout = 2

	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function PlayerExpChangedItem:pushData(data)
	if #self.dataQueue > 0 then
		self:batchData(self.dataQueue[1], data)
	else
		self:enqueue(data)
	end
end

function PlayerExpChangedItem:batchData(data, newData)
	data.addExp = data.addExp + newData.addExp
	data.maxExp = newData.maxExp
	data.curExp = newData.curExp
	data.curLev = newData.newLevel
	data.newLevel = newData.newLevel
	data.isLvUp = data.isLvUp or newData.isLvUp
end

function PlayerExpChangedItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function PlayerExpChangedItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 4)

	self:addRunItem(data)
	self:initUContainer(data)
end

function PlayerExpChangedItem:onUIVisibleToHide()
	self:clearRunningList(true)
end

function PlayerExpChangedItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function PlayerExpChangedItem:refreshRemainTime()
	if self:isTimelineSuspended() then
		return
	end

	local data = self:firstRunItem()

	if data and (data.removing or Time.realSecondCache >= data.endTime) then
		self:recycleToast(data)
	end
end

function PlayerExpChangedItem:isCurrentContent(data, item)
	return self:firstRunItem() == data and not data.removing and NotNil(item) and NotNil(self.uContainer) and self.uContainer.content == item
end

function PlayerExpChangedItem:initUContainer(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function(item)
			self:renderItem(item, data)
		end))
	else
		self:renderItem(self.uContainer.content, data)
	end
end

function PlayerExpChangedItem:renderItem(item, data)
	if not self:isCurrentContent(data, item) then
		return
	end

	local rootWidget = item:GetComponent("UWidget")
	local objectReference = item:GetComponent("ObjectReference")
	local expProgress = objectReference:GetRefValue("expProgress")
	local imgProgress = objectReference:GetRefValue("imgProgress")
	local lvText = objectReference:GetRefValue("lvText")
	local expCur = objectReference:GetRefValue("expCur")
	local expAdd = objectReference:GetRefValue("expAdd")
	local args = data

	ClientTextUtils.setText(lvText, args.oldLevel)
	ClientTextUtils.setText(expCur, string.format("%d/%d", args.curExp, args.maxExp))
	ClientTextUtils.setText(expAdd, string.format("Exp+%d", args.addExp))

	expProgress.value = args.oldExp / args.maxExp
	imgProgress.renderOpacity = 1
	imgProgress.value = args.oldExp / args.maxExp

	local expEndValue = args.curExp / args.maxExp
	local startAnim = args.isLvUp and CS.XGUI.EInvokeTime.Custom1 or CS.XGUI.EInvokeTime.User1

	rootWidget:InvokeCallbackWithCallback(startAnim, self:guardRunCallback(data, function()
		if not self:isCurrentContent(data, item) then
			return
		end

		if args.isLvUp then
			expProgress:ProgressToValue(1, self:guardRunCallback(data, function()
				if not self:isCurrentContent(data, item) then
					return
				end

				ClientTextUtils.setText(lvText, args.curLev)

				if args.isLvUp then
					pg.game.audio:playEvent("SFX_UI_Player_Upgrade")
					rootWidget:InvokeCallback(CS.XGUI.EInvokeTime.User3)
				end

				expProgress.value = 0

				expProgress:ProgressToValue(expEndValue, function()
					return
				end, 1)
			end, item), 0.5)
			imgProgress:ProgressToValue(1, self:guardRunCallback(data, function()
				if not self:isCurrentContent(data, item) then
					return
				end

				ClientTextUtils.setText(lvText, args.curLev)

				if args.isLvUp then
					pg.game.audio:playEvent("SFX_UI_Player_Upgrade")
					rootWidget:InvokeCallback(CS.XGUI.EInvokeTime.User3)
				end

				imgProgress.value = 0

				imgProgress:ProgressToValue(expEndValue, self:guardRunCallback(data, function()
					if not self:isCurrentContent(data, item) then
						return
					end

					DoTweenAnimMgr.DoFloat(imgProgress.gameObject, 1, 0, LuaUIUtils.TweenId(ID_IMG_PROGRESS), 0.5, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
						return
					end, self:guardRunCallback(data, function(value)
						if not self:isCurrentContent(data, item) then
							return
						end

						imgProgress.renderOpacity = value
					end, item), function()
						return
					end, false)
				end, item), 1)
			end, item), 0.5)
		else
			expProgress:ProgressToValue(expEndValue, self:guardRunCallback(data, function()
				if not self:isCurrentContent(data, item) then
					return
				end

				ClientTextUtils.setText(lvText, args.curLev)

				if args.isLvUp then
					rootWidget:InvokeCallback(CS.XGUI.EInvokeTime.User3)
				end
			end, item), 0.5)
			imgProgress:ProgressToValue(expEndValue, self:guardRunCallback(data, function()
				if not self:isCurrentContent(data, item) then
					return
				end

				DoTweenAnimMgr.DoFloat(imgProgress.gameObject, 1, 0, LuaUIUtils.TweenId(ID_IMG_PROGRESS), 0.5, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
					return
				end, self:guardRunCallback(data, function(value)
					if not self:isCurrentContent(data, item) then
						return
					end

					imgProgress.renderOpacity = value
				end, item), function()
					return
				end, false)
			end, item), 0.5)
		end
	end, item))

	local rumbleName = args.isLvUp and "CommonHigh" or "CommonMiddle"

	pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, rumbleName)
	pg.game.audio:playEvent("SFX_UI_Player_Getexperience")
end

return PlayerExpChangedItem
