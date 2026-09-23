-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\HomeNameItem.lua

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
local HomeNameItem = Class.LightClass("HomeNameItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function HomeNameItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget

	self:setVisible(false)
end

function HomeNameItem:onUpdate()
	self:setVisible(true)
	self:tryPopupItem()
end

function HomeNameItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	self:addRunItem(data)
	self:initUContainer(data)
end

function HomeNameItem:hideById(force)
	local data = self:firstRunItem()

	if data then
		self:recycleToast(data, force)
	end

	self:clearHomelandTipTimer()
end

function HomeNameItem:onClearRunningList(force)
	if force then
		self:hideById(true)
	else
		self:setVisible(false)
	end
end

function HomeNameItem:initUContainer(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function(loadedItem)
			if IsNil(loadedItem) or self.uContainer.content ~= loadedItem then
				return
			end

			self:renderItem(loadedItem, data)
		end))
	else
		self:renderItem(self.uContainer.content, data)
	end

	self:clearHomelandTipTimer()

	if pg.me and pg.me.space and pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
		self.homelandTipTimer = self:startTimer(self:guardRunCallback(data, function()
			self.homelandTipTimer = nil

			self:hideById()
		end), 5)
	end
end

function HomeNameItem:clearHomelandTipTimer()
	if self.homelandTipTimer then
		self:killTimer(self.homelandTipTimer)

		self.homelandTipTimer = nil
	end
end

function HomeNameItem:onSceneUnload()
	self:clearAllData(true)
end

function HomeNameItem:renderItem(item, param)
	local oc = item:GetComponent("ObjectReference")
	local txtHomelandName = oc:GetRefValue("homeName")
	local upGradeUContainer = oc:GetRefValue("upGradeUContainer")
	local homeName = param.name or ""
	local _h = HomeNameItem._platformHooks

	homeName = _h and _h.renderItemName and _h.renderItemName(self, item, param, homeName) or homeName

	ClientTextUtils.setText(txtHomelandName, homeName)

	if param.level then
		upGradeUContainer:SetActive(true)

		if not upGradeUContainer:CheckURLLoaded() then
			upGradeUContainer:LoadDefaultUrlManually(self:guardRunCallback(param, function()
				local objectReference = upGradeUContainer.content:GetComponent("ObjectReference")
				local textUSDFText = objectReference:GetRefValue("textUSDFText")

				ClientTextUtils.setText(textUSDFText, param.level)
			end, item))
		else
			local objectReference = upGradeUContainer.content:GetComponent("ObjectReference")
			local textUSDFText = objectReference:GetRefValue("textUSDFText")

			ClientTextUtils.setText(textUSDFText, param.level)
		end
	else
		upGradeUContainer:SetActive(false)
	end

	if _h and _h.renderItem then
		_h.renderItem(self, item, param)
	end
end

function HomeNameItem:onRecycleFinished(data, reason)
	self:setVisible(false)
end

return HomeNameItem
