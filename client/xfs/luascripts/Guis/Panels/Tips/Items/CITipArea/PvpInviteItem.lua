-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\CITipArea\\PvpInviteItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local GmToolUtils = require("Utils.GmToolUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PvpInviteItem = Class.LightClass("PvpInviteItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function PvpInviteItem:onInit()
	self:setMaxLimit(1)

	self.scrollList = self.uWidget

	function self.scrollList.luaRenderItem(item, data)
		self:RenderItem(item, data)
	end
end

function PvpInviteItem:pushData(data)
	self:enqueue(data)
end

function PvpInviteItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function PvpInviteItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	self:addRunItem(data)
	self.scrollList:PushRenderItem(data)
end

function PvpInviteItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function PvpInviteItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.secondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function PvpInviteItem:recycleToast(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.User2)
end

function PvpInviteItem:RenderItem(item, data)
	self:refreshItem(item, data)
	item:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonTapMiddle")
end

function PvpInviteItem:refreshItem(item, data)
	local oc = item:GetComponent("ObjectReference")
	local btnAccept = oc:GetRefValue("btnAccept")
	local btnRefuse = oc:GetRefValue("btnRefuse")
	local progress = oc:GetRefValue("progress")
	local txtContent = oc:GetRefValue("txtContent")
	local txtInvited = oc:GetRefValue("txtInvited")
	local pInfo = pg.game.chat:getPlayerInfo(data.uid)

	if pInfo then
		ClientTextUtils.setText(txtContent, string.format(pg.getGameString("PVP_COVENANT_TO_YOU"), LuaUIUtils.getPlayerDisplayName(data.uid, pInfo.playerName, true)))
	end

	data.tickLength = data.endTime - Time.secondCache
	data.tickTimer = self:startTimer(function()
		progress.value = (data.endTime - Time.secondCache) / data.tickLength
	end, 0.02, true)

	function btnAccept.luaClick()
		pg.me:acceptInvitePvpBattle(data.uid, true)
		self:recycleToast(data)
		pg.game.audio:triggerEvent("ui_sfx_button")
	end

	function btnRefuse.luaClick()
		pg.me:acceptInvitePvpBattle(data.uid, false)
		self:recycleToast(data)
		pg.game.audio:triggerEvent("ui_sfx_button")
	end
end

function PvpInviteItem:GMPushData(data)
	data.endTime = Time.secondCache + 5
end

function PvpInviteItem:getRecycleTarget(data)
	return self:getListRecycleTarget(data)
end

function PvpInviteItem:onRecycleCleanup(data, target, reason)
	self:cleanupRecycleList(data, target, reason)
end

return PvpInviteItem
