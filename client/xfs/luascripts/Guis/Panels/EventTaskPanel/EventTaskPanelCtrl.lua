-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventTaskPanel\\EventTaskPanelCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("EventTaskPanelCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RedDotConst = require("Const.RedDotConst")
local EventTaskPanelCtrl = Class.LightClass("EventTaskPanelCtrl", UICtrl)

EventTaskPanelCtrl.messages = {
	[MessageName.EVENT_CUR_PAGE_REFRESH] = {
		"onActDataRefresh",
		true
	},
	[MessageName.EVENT_TASK_STATE_CHANGE] = {
		"onActDataRefresh",
		true
	}
}

function EventTaskPanelCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	info = info or {}

	self.model:setEventIds(info.eventIds)

	self._receiveTaskFunc = info.receiveTaskFunc

	ClientTextUtils.setText(self.view.txtTltleUBaseText, info.title or "")
	self:bindCloseButton(self.view.btnCloseUButton)
	self:refreshList()
end

function EventTaskPanelCtrl:addListener()
	function self.view.taskListUList.luaRenderItem(button, index, data)
		self:_renderItem(button, data)
	end

	if self.view.btnCloseAllUButton then
		function self.view.btnCloseAllUButton.luaClick()
			self:dismiss()
		end
	end

	if self.view.btnCloseUButton then
		function self.view.btnCloseUButton.luaClick()
			self:dismiss()
		end
	end
end

function EventTaskPanelCtrl:onActDataRefresh()
	self:refreshList()
end

function EventTaskPanelCtrl:refreshList()
	local list = self.model:getTaskList()

	self.view.taskListUList:SetList(list)
end

function EventTaskPanelCtrl:_renderItem(button, data)
	if not data or not data.cfg then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local rewardList = objectReference:GetRefValue("rewardList")
	local descUText = objectReference:GetRefValue("descUText")
	local btnRoot = objectReference:GetRefValue("btnRoot")
	local btnGetUButton = objectReference:GetRefValue("btnGetUButton")
	local btnGoUButton = objectReference:GetRefValue("btnGoUButton")
	local btnGoObjRef = btnGoUButton:GetComponent("ObjectReference")
	local btnGoTxt = btnGoObjRef and btnGoObjRef:GetRefValue("txtNameUText")
	local btnFinishUWidget = objectReference:GetRefValue("btnFinishUWidget")
	local finishTxt = objectReference:GetRefValue("finishTxt")

	function rewardList.luaRenderItem(rewardBtn, rewardIndex, rewardData)
		rewardData.rayCastParent = self.view.btnCloseAllUButton
		rewardData.addSibling = 1
		rewardData.checkTouchBegin = false

		LuaUIUtils.renderRewardItem(rewardBtn, rewardData)
	end

	local rewards = LuaUIUtils.getRewardItemByDropId(data.cfg.award, data.state == ActivityConst.TaskState.Received, data.state == ActivityConst.TaskState.Finihed_CanRecv)

	rewardList:SetList(rewards)
	ClientTextUtils.setText(descUText, pg.getFormatText(pg.getLocalizationText(data.cfg.taskDes), data.progress or 0, data.target or 0))

	local state = 0

	if data.state == ActivityConst.TaskState.Finihed_CanRecv and self._receiveTaskFunc then
		state = 1

		function btnGetUButton.luaClick()
			self._receiveTaskFunc(data.eventId, data.taskId)
		end
	elseif data.state == ActivityConst.TaskState.UnFinished then
		state = 0

		function btnGoUButton.luaClick()
			local eventId = data.cfg.event

			if eventId then
				pg.me:doEvent(eventId)
				self:dismiss()
			end
		end
	else
		state = 2
	end

	btnRoot:TryChangePage("Status", state)
	pg.global.setRedDot(string.format(RedDotConst.RedDotPath.EVENT_LEYLINE_UP_TASKITEM, data.taskId), btnGetUButton, state == 1, RedDotConst.RedDotStyle.REWARD)

	if btnGoTxt then
		ClientTextUtils.setText(btnGoTxt, pg.getGameString("BUTTON_NAME_1"))
	end

	local btnGetObjRef = btnGetUButton:GetComponent("ObjectReference")
	local btnGetTxt = btnGetObjRef and btnGetObjRef:GetRefValue("txtNameUText")

	if btnGetTxt then
		ClientTextUtils.setText(btnGetTxt, pg.getGameString("BUTTON_NAME_2"))
	end

	if finishTxt then
		ClientTextUtils.setText(finishTxt, pg.getGameString("ECOLOGICAL_RESARCH_FINISH"))
	end
end

function EventTaskPanelCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

return EventTaskPanelCtrl
