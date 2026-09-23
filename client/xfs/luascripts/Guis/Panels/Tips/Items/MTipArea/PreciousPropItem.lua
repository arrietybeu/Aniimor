-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\MTipArea\\PreciousPropItem.lua

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
local PreciousPropItem = Class.LightClass("PreciousPropItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function PreciousPropItem:onInit()
	self:setMaxLimit(1)

	self.waitCount = 0
end

function PreciousPropItem:pushData(data)
	local contains = false

	for _, v in ipairs(self.dataQueue) do
		if v.id == data.id then
			v.magnification = v.magnification + 1
			contains = true

			break
		end
	end

	if not contains then
		data.magnification = 1

		self:enqueue(data)
	end

	self:checkTipState(data)
end

function PreciousPropItem:postPushData(params)
	self.waitCount = params.waitCount
	self.finishedCallback = params.allFinishedCallback
end

function PreciousPropItem:onUpdate()
	self:tryPopupItem()
end

function PreciousPropItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	self:addRunItem(data)
	pg.global.ui:open(UIConst.UI_ID_PIECES_ITEM_PANEL, data, nil, function()
		self:closePanel(data)
	end)
	self:checkTipState()
end

function PreciousPropItem:closePanel(data)
	self:removeItem(data)

	self.waitCount = self.waitCount - 1

	if self.waitCount <= 0 and self.finishedCallback ~= nil then
		self.finishedCallback()

		self.finishedCallback = nil
	end

	self:checkTipState()
end

function PreciousPropItem:checkTipState()
	if self:isWaitingOrRunning() then
		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.PiecesItem, {
			[UIConst.UI_ID_PIECES_ITEM_PANEL] = true,
			[UIConst.UI_ID_TIPS] = true,
			[UIConst.UI_ID_PET_EVOLVE_PET_SHOW] = true
		})
	else
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.PiecesItem)
	end
end

return PreciousPropItem
