-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampDispatchRewards\\HomeCampDispatchRewardsCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomeCampDispatchRewardsCtrl = Class.LightClass("HomeCampDispatchRewardsCtrl", UICtrl)
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeCampUtils = require("Utils.HomeCampUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomeCampData = require("Data.home_camp_data")
local PetDispatchData = require("Data.pet_dispatch_data")

HomeCampDispatchRewardsCtrl.messages = {}

function HomeCampDispatchRewardsCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	function self.view.listRewardUList.luaRenderItem(button, index, data)
		self:m_renderParentItem(button, index, data)
	end
end

function HomeCampDispatchRewardsCtrl:addListener()
	UICtrl.addListener(self)

	function self.view.backGroundCloseUButton.luaClick()
		return
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onClickConfirm()
	end

	function self.view.btnAgainUButton.luaClick()
		self:onClickAgain()
	end
end

function HomeCampDispatchRewardsCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_CAMP_MANAGER) then
		pg.global.ui:close(UIConst.UI_ID_CAMP_MANAGER)
	end
end

function HomeCampDispatchRewardsCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	info = type(info) == "table" and info or {}

	self.model:setDispatchRewardsParams(info)
	self:refreshUI()
end

function HomeCampDispatchRewardsCtrl:onShow()
	return
end

function HomeCampDispatchRewardsCtrl:onHide()
	return
end

function HomeCampDispatchRewardsCtrl:refreshUI()
	local petsAndRewards = self.model:getDispatchPetsAndRewards()

	self.view.listRewardUList:SetList(petsAndRewards)
	self:refreshAreaText()
	self:refreshAgainText()
	self:refreshButtonText()
end

function HomeCampDispatchRewardsCtrl:refreshAreaText()
	local campData = HomeCampData[HomeCampUtils.getPreDispatchCampId()]

	ClientTextUtils.setText(self.view.txtAreaUSDFText, ClientTextUtils.getLocalizationText(campData and campData.name))
end

function HomeCampDispatchRewardsCtrl:refreshAgainText()
	local dispatchData = PetDispatchData[HomeCampUtils.getPreDispatchId()]

	if not dispatchData then
		ClientTextUtils.setText(self.view.againText, "")

		return
	end

	local dispatchName = ClientTextUtils.getLocalizationText(dispatchData.name)
	local dispatchDuration = LuaUIUtils.getCountDownString(dispatchData.time, UIConst.TimeType.Short, true)

	ClientTextUtils.setText(self.view.againText, string.format("%s：%s", dispatchName, dispatchDuration))
end

function HomeCampDispatchRewardsCtrl:refreshButtonText()
	self:setButtonText(self.view.btnConfirmUButton, "HOME_CAMP_CAR_PET_DISP_CONFIRM")
	self:setButtonText(self.view.btnAgainUButton, "HOME_CAMP_CAR_PET_DISP_AGAIN")
end

function HomeCampDispatchRewardsCtrl:setButtonText(button, textKey)
	if not button or IsNil(button) then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local buttonText = objectReference and objectReference:GetRefValue("txtNameUText")

	if not buttonText or IsNil(buttonText) then
		return
	end

	ClientTextUtils.setText(buttonText, pg.getGameString(textKey))
end

function HomeCampDispatchRewardsCtrl:onClickConfirm()
	self:close()
end

function HomeCampDispatchRewardsCtrl:onClickAgain()
	local carUid = pg.me and pg.me.uid
	local campCarEnt = HomeLandUtils.getCampCarEntity(carUid)

	if not campCarEnt then
		return
	end

	campCarEnt:dispatchPet(HomeCampUtils.getPreDispatchId(), HomeCampUtils.getPreDispatchCampId(), function()
		self:close()
	end)
end

function HomeCampDispatchRewardsCtrl:m_renderParentItem(button, index, data)
	if not data then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local homeManageUComponent = objectReference:GetRefValue("homeManageUComponent")

	LuaUIUtils.renderHomePetHead(homeManageUComponent, data.petInfo or {})

	local listRewardUList = objectReference:GetRefValue("listRewardUList")

	function listRewardUList.luaRenderItem(rewardButton, index, rData)
		self:m_renderRewardItem(rewardButton, index, rData)
	end

	listRewardUList:SetList(data.rewardItems or {})
end

function HomeCampDispatchRewardsCtrl:m_renderRewardItem(rewardButton, index, rData)
	if not rData then
		return
	end

	LuaUIUtils.renderRewardItem(rewardButton, rData, rData.num or 1)
end

return HomeCampDispatchRewardsCtrl
