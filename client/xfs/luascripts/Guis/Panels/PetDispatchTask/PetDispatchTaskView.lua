-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetDispatchTask\\PetDispatchTaskView.lua

local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIView = require("Guis.UIView")
local PetDispatchTaskView = Class.LightClass("PetDispatchTaskView", UIView)

function PetDispatchTaskView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnClose = objectReference:GetRefValue("btnClose")
	self.txtBlockName = objectReference:GetRefValue("txtBlockName")
	self.textDescription = objectReference:GetRefValue("textDescription")
	self.countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	self.btnDark = objectReference:GetRefValue("btnDark")
	self.bgUImage = objectReference:GetRefValue("bgUImage")
	self.txtBtn = objectReference:GetRefValue("txtBtn")
	self.btnBlueUButton = objectReference:GetRefValue("btnBlueUButton")
	self.txtbtnBlue = objectReference:GetRefValue("txtbtnBlue")
	self.txtCountDoum = objectReference:GetRefValue("txtCountDoum")
	self.txtDispatch = objectReference:GetRefValue("txtDispatch")
	self.txtDispatchTips = objectReference:GetRefValue("txtDispatchTips")
	self.btnRules = objectReference:GetRefValue("btnRules")
	self.listLeaderUList = objectReference:GetRefValue("listLeaderUList")
	self.listMemberUList = objectReference:GetRefValue("listMemberUList")
	self.txtReward = objectReference:GetRefValue("txtReward")
	self.txtTitleGet = objectReference:GetRefValue("txtTitleGet")
	self.clueItems = {}

	for i = 1, 3 do
		self.clueItems[i] = objectReference:GetRefValue("clueItem" .. i)
	end

	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.rewardUComponent = objectReference:GetRefValue("rewardUComponent")
	self.btnChoose = objectReference:GetRefValue("btnChoose")
	self.txtbtnChoose = objectReference:GetRefValue("txtbtnChoose")
	self.txtTitlePossibly = objectReference:GetRefValue("txtTitlePossibly")
	self.listPossiblyUList = objectReference:GetRefValue("listPossiblyUList")
	self.btnInfoPossibly = objectReference:GetRefValue("btnInfoPossibly")
	self.timeReduceUWidget = objectReference:GetRefValue("timeReduceUWidget")
	self.txttime = objectReference:GetRefValue("txttime")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
end

function PetDispatchTaskView:initView()
	ClientTextUtils.setText(self.txtDispatch, pg.getGameString("DISPATCH_TASK_PET_TITLE"))
	ClientTextUtils.setText(self.txtDispatchTips, pg.getGameString("DISPATCH_PET_NUM_LIMIT"))
	ClientTextUtils.setText(self.txtReward, pg.getGameString("DISPATCH_TASK_CLUE_TIP_TITLE"))
	ClientTextUtils.setText(self.txtTitleGet, pg.getGameString("DISPATCH_TASK_REWARD_TITLE"))
	ClientTextUtils.setText(self.txtbtnChoose, pg.getGameString("DISPATCH_TASK_CLICK_SELECT"))
	ClientTextUtils.setText(self.txtTitlePossibly, pg.getGameString("DISPATCH_TASK_ADVENTURE_TITLE"))
end

return PetDispatchTaskView
