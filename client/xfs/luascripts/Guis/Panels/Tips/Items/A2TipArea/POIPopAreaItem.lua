-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A2TipArea\\POIPopAreaItem.lua

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
local POIPopAreaItem = Class.LightClass("POIPopAreaItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function POIPopAreaItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function POIPopAreaItem:pushData(data)
	data.uniqueId = data.uniqueId or 0
	data.priority = data.priority or 0
	data.state = data.state or 0

	if self:checkCanPushStack(data) then
		self:enqueue(data)
	end
end

function POIPopAreaItem:checkCanPushStack(data)
	if data.state == 1 then
		for _, v in ipairs(self.dataQueue) do
			if v.id == data.id and v.uniqueId == data.uniqueId and v.priority == data.priority then
				return false
			end
		end

		for _, v in ipairs(self.runList) do
			if v.id == data.id and v.uniqueId == data.uniqueId and v.priority == data.priority then
				return false
			end
		end

		local oldIndex = -1

		for i, v in ipairs(self.dataQueue) do
			if v.id == data.id and data.priority > v.priority then
				oldIndex = i

				break
			end
		end

		if oldIndex > 0 then
			table.remove(self.dataQueue, oldIndex)
		end
	end

	return true
end

function POIPopAreaItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function POIPopAreaItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 4)

	self:addRunItem(data)
	self:initUContainer(data)
end

function POIPopAreaItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function POIPopAreaItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function POIPopAreaItem:initUContainer(data)
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
end

function POIPopAreaItem:renderItem(item, data)
	local objectReference = item.transform:GetComponent("ObjectReference")
	local root = objectReference:GetRefValue("root")
	local iconAreaUImage = objectReference:GetRefValue("iconAreaUImage")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local txtLevelUBaseText = objectReference:GetRefValue("txtLevelUBaseText")
	local vXIconAreaUImage = objectReference:GetRefValue("vXIconAreaUImage")
	local subtitleUSDFText = objectReference:GetRefValue("textPVEUSDFText")
	local areaTipsUComponent = objectReference:GetRefValue("areaTipsUComponent")

	if data.args and data.args.subTitle then
		subtitleUSDFText.gameObject:SetActiveEx(not data.isFirst)
		txtLevelUBaseText.gameObject:SetActiveEx(false)
		ClientTextUtils.setText(subtitleUSDFText, pg.getLocalizationText(data.args.subTitle))
	else
		subtitleUSDFText.gameObject:SetActiveEx(false)
		txtLevelUBaseText.gameObject:SetActiveEx(true)
	end

	if data.args and data.args.warningColor then
		areaTipsUComponent:TryChangePage("color", 1)
	else
		areaTipsUComponent:TryChangePage("color", 0)
	end

	local args = data.args

	pg.game.audio:triggerEvent("SFX_UI_POI_DiscoverArea")

	if data.isFirst then
		root:InvokeCallback(CS.XGUI.EInvokeTime.Custom5)
	else
		root:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end

	if pg.me.level + ClientConst.MAP_AREA_DANGER_LEVEL <= data.minLv then
		root:TryChangePage("BattleWarning", 2)
	elseif pg.me.level + ClientConst.MAP_AREA_WARNING_LEVEL <= data.minLv then
		root:TryChangePage("BattleWarning", 1)
	else
		root:TryChangePage("BattleWarning", 0)
	end

	ClientTextUtils.setText(txtTitleUSDFText, pg.getLocalizationText(args.title))
	ClientTextUtils.setText(txtLevelUBaseText, string.format("%s %s %d~%d", pg.getGameString("RECOMMEND"), pg.getGameString("SORT_TYPE_5"), data.minLv, data.maxLv))

	iconAreaUImage.url = args.POIIcon
	vXIconAreaUImage.url = args.POIIcon

	if args.POIMusic then
		pg.game.audio:playEvent(args.POIMusic)
	end
end

function POIPopAreaItem:onSceneUnload()
	self:clearAllData()
end

function POIPopAreaItem:GMPushData(data)
	data.duration = 5
	data.minLv = 1
	data.maxLv = 100
	data.args = {
		POIIcon = "$UI_Icon_POI_Decrypt_TimeLimited.png",
		subTitle = "子Title",
		title = "区域POI"
	}
end

return POIPopAreaItem
