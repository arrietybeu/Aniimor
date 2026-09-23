-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\CITipArea\\NpcCallItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local SysConfigData = require("Data.sys_config_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local NpcCallItem = Class.LightClass("NpcCallItem", BaseQueueItem)

function NpcCallItem:onInit()
	self:setMaxLimit(1)
end

function NpcCallItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function NpcCallItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() or pg.global.ui:isFullScreenVisible() then
		return
	end

	local data = self:dequeue()

	function data.closeFunc()
		self:removeItem(data)
	end

	data.endTime = Time.realSecondCache + (SysConfigData.NPC_CALL_CLOSE_TIME or 15) + 1

	self:addRunItem(data)
	pg.global.ui:open(UIConst.UI_ID_NPC_CALL_MULTIPLE, data)
end

function NpcCallItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	pg.global.ui:close(UIConst.UI_ID_NPC_CALL_MULTIPLE)
	self:removeItem(data)
end

function NpcCallItem:onClearRunningList()
	local data = self:firstRunItem()

	if not data then
		return
	end

	pg.global.ui:close(UIConst.UI_ID_NPC_CALL_MULTIPLE)
	self:removeItem(data)
end

return NpcCallItem
