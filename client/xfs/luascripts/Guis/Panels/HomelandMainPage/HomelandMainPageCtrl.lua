-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandMainPage\\HomelandMainPageCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandMainPageCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomelandMainPageCtrl = Class.LightClass("HomelandMainPageCtrl", UICtrl)
local CallbackHandler = require("Core.Common.CallbackHandler")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local HomelandConfigData = require("Data.homeland_config_data")
local TimerManager = require("Core.Timer.TimerManager")

HomelandMainPageCtrl.messages = {
	[MessageName.HOMECAR_VISITORS_INFO] = {
		"refreshVisitor",
		true
	},
	[MessageName.HOME_CAR_UPGRADE_STATE_CHANGED] = {
		"onHomeCarUpgradeStateChanged",
		true
	}
}

function HomelandMainPageCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.view.btnCardUButton:SetActive(false)

	self.carScene = self.uiScene
	self.homeCarBaseInfo = HomeLandUtils.getHomeCarInfo()
	self.visitorsList = {}
	self.view.btnLiveUButton.interactable = false

	self:refreshMainPageInfo()
	self:refreshHomeCarInfo()

	function self.view.btnLiveUButton.luaRenderTooltip(btn, tipPanel)
		local objectReference = tipPanel:GetComponent("ObjectReference")
		local txtNumTotalUSDFText = objectReference:GetRefValue("txtNumTotalUSDFText")
		local listAttriUList = objectReference:GetRefValue("listAttriUList")
		local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

		ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("HOMELAND_COMPOSE_LIVE_VALUE"))

		local total = self.petComfortVale + self.furnitureComfortValue

		ClientTextUtils.setText(txtNumTotalUSDFText, total)

		function listAttriUList.luaRenderItem(button, index, data)
			if data.tIndex == 0 then
				local objectReference = button:GetComponent("ObjectReference")
				local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
				local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")

				if data.desc then
					ClientTextUtils.setText(txtNameUSDFText, data.desc)
				end

				if data.num then
					ClientTextUtils.setText(txtNumUSDFText, data.num)
				else
					ClientTextUtils.setText(txtNumUSDFText, "")
				end
			end
		end

		local listData = {
			{
				tIndex = 0,
				desc = pg.getGameString("FURNITURE_COMFORT"),
				num = self.furnitureComfortValue
			},
			{
				tIndex = 0,
				desc = pg.getGameString("PET_COMFORT"),
				num = self.petComfortVale
			}
		}

		listAttriUList:SetList(listData)
	end
end

function HomelandMainPageCtrl:onHomeCarUpgradeStateChanged()
	local oldLevel = self.homeCarBaseInfo.level
	local oldModelLevel = self.homeCarBaseInfo.modelLevel

	self.homeCarBaseInfo = HomeLandUtils.getHomeCarInfo()

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR_UPGRADE)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR)

	if not self:checkUIVisible() then
		return
	end

	self.carScene:refreshHomeCar(self.homeCarBaseInfo)

	if oldLevel ~= self.homeCarBaseInfo.level then
		ClientTextUtils.setText(self.view.textUSDFText, self.homeCarBaseInfo.level)
		self:refreshPetInfo()
		pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOMECAR_COMPONENT_UPGRADE)
	end

	if oldModelLevel ~= self.homeCarBaseInfo.modelLevel then
		self.carScene:switchCamera(UIConst.HOMECAR_MODE_IDX.MAINPAGE, self.homeCarBaseInfo.modelLevel)
	end
end

function HomelandMainPageCtrl:refreshMainPageInfo()
	ClientTextUtils.setText(self.view.textHomeNameUSDFText, self.homeCarBaseInfo.name)
	ClientTextUtils.setText(self.view.txtCampIDUSDFText, pg.me.curCampDisplayCode)
	ClientTextUtils.setText(self.view.textUSDFText, self.homeCarBaseInfo.level)
	pg.me:queryCampCarSyncInfo(nil, function(data)
		ClientTextUtils.setText(self.view.textNumGoodUSDFText, data.likeCnt)

		self.view.btnLiveUButton.interactable = true
		self.petComfortVale = data.petComfortValue or 0
		self.furnitureComfortValue = data.furnitureComfortValue or 0
		self.liuliPetComfortValue = data.liuliPetComfortValue or 0

		ClientTextUtils.setText(self.view.txtNumLiveUSDFText, self.petComfortVale + self.furnitureComfortValue + self.liuliPetComfortValue)
	end)
	pg.me:queryHomelandSyncInfo(nil, function(visitorInfo)
		local queryList = {}

		if visitorInfo.visitors then
			for i = 1, 3 do
				local uid = visitorInfo.visitors[i]

				if uid then
					local playerInfo = pg.game.chat:getPlayerInfo(uid)

					if not playerInfo then
						table.insert(queryList, uid)
					end
				end
			end
		end

		if #queryList > 0 then
			pg.me:queryPlayerInfoList(queryList, pg.game.chat.queryPlayerInfoType.ShowVisitorInfo, true)
		end

		self.visitorsList = visitorInfo.visitors

		self:refreshVisitor()
	end)
	self:refreshPetInfo()
end

function HomelandMainPageCtrl:refreshPetInfo()
	local levelIndex = HomelandConfigData.homeCarPetRewardLevel or 6
	local carLevel = self.homeCarBaseInfo.level
	local rewardsReceived = pg.me.homeUpgradeRewardsReceived or {}

	self.view.btnPetUButton:SetActive(true)

	local canGet = false

	if carLevel < levelIndex then
		ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("HOME_MAINPAGE_AWARD_SHOW_TIPS"))
	elseif rewardsReceived[levelIndex] then
		self.view.btnPetUButton:SetActive(false)
	else
		canGet = true

		ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("HOMECAR_PET_REWARD_CANGET"))
	end

	pg.global.setRedDot(RedDotConst.RedDotPath.FUNC_MENU_HOMECARPETREWARD, self.view.btnPetUButton, canGet, RedDotConst.RedDotStyle.REWARD)
end

function HomelandMainPageCtrl:refreshVisitor()
	self.visitorsInfo = self:getVisitorsInfo(self.visitorsList)

	self.view.listPlayerUList:SetList(self.visitorsInfo)
	self.view.uIPbHomeCampingCarMainUWidget:TryChangePage("VisitorState", #self.visitorsInfo > 0 and 0 or 1)
end

function HomelandMainPageCtrl:getVisitorsInfo(visitors)
	local visitorsInfo = {}

	if visitors then
		for _, uid in ipairs(visitors) do
			local playerInfo = pg.game.chat:getPlayerInfo(uid)

			if playerInfo then
				table.insert(visitorsInfo, {
					uid = uid,
					avatarIconId = playerInfo.headIcon,
					avatarFrameIconId = playerInfo.headFrame
				})

				if #visitorsInfo >= 3 then
					break
				end
			end
		end
	end

	return visitorsInfo
end

function HomelandMainPageCtrl:addListener()
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("HOMCAR_MAINPAGE"))
	ClientTextUtils.setText(self.view.textGoodUSDFText, pg.getGameString("HOMCAR_LIKE_NUMBER") .. ": ")
	ClientTextUtils.setText(self.view.textVisitUSDFText, pg.getGameString("HOMCAR_RECENT_VISITOR") .. ": ")
	ClientTextUtils.setText(self.view.textNoneUSDFText, pg.getGameString("HOMCAR_NO_VISITOR"))
	ClientTextUtils.setText(self.view.txtCarUSDFText, pg.getGameString("HOMCAR_CUSTOMIZATION"))
	ClientTextUtils.setText(self.view.txtShopUSDFText, pg.getGameString("HOMCAR_FURNITURE_STORE"))
	ClientTextUtils.setText(self.view.txtCardNumUSDFText, pg.getGameString("HOMCAR_POSTCARD"))
	ClientTextUtils.setText(self.view.txtCampNameUSDFText, pg.getGameString("HOMCAR_GOTO_CAMPSITE"))
	ClientTextUtils.setText(self.view.txtHomeNameUSDFText, pg.getGameString("GO_HOMELAND"))
	ClientTextUtils.setText(self.view.txtUpgradeUSDFText, pg.getGameString("HOMCAR_EXPANSION"))
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("HOMCAR_COMPONENT_UPGRADE"))

	function self.view.listPlayerUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderPlayerAvatar(button, {
			avatarIconId = data.avatarIconId,
			avatarFrameIconId = data.avatarFrameIconId
		})

		function button.luaClick()
			local param = {
				openType = ClientConst.PlayerInfoOpenType.Chat,
				playerId = data.uid,
				openSource = pg.game.chat.AddFriendSource.PlayerCard
			}

			LuaUIUtils.openInfoPlayerCard(param)
		end
	end

	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnEditUButton.luaClick()
		local defaultName = pg.getFormatText(pg.getGameString("HOMELANE_NAME"), pg.me.playerName)

		pg.global.ui.tips:showCommonInput(pg.getGameString("HOMCAR_CHANGE_NAME"), function(newName)
			local finalName = newName

			if newName == nil or newName == "" then
				finalName = defaultName
			end

			self.model:changeHomelandName(finalName, function()
				if not IsNil(self.view.textHomeNameUSDFText) then
					self.homeCarBaseInfo.name = finalName

					ClientTextUtils.setText(self.view.textHomeNameUSDFText, self.homeCarBaseInfo.name)
				end
			end)
		end, nil, {
			errorHide = true,
			characterLimit = 20,
			text = self.homeCarBaseInfo.name
		})
	end

	function self.view.btnUpGradeUButton.luaClick()
		pg.global.ui.homeCarLevelUp:open({
			homeMainPage = self
		}, nil, nil, {
			ignoreResetUICamera = true
		})
	end

	function self.view.btnLevelupUButton.luaClick()
		pg.global.ui.homeCarLevelUpComp:open({
			homeMainPage = self
		}, nil, nil, {
			ignoreResetUICamera = true
		})
	end

	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR_UPGRADE, self.view.btnUpGradeUButton, function()
		return pg.global.ui.homeCarLevelUp.model:redDot_GetUpgradeState()
	end)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HOMECAR_COMPONENT_UPGRADE, self.view.btnLevelupUButton, function()
		return pg.global.ui.homeCarLevelUpComp.model:redDot_GetUpgradeState()
	end)

	function self.view.btnCarDIYUButton.luaClick()
		pg.global.ui.homeCarModify:open({
			isModify = true,
			homeMainPage = self,
			basicInfo = self.homeCarBaseInfo
		}, nil, nil, {
			ignoreResetUICamera = true
		})
	end

	function self.view.btnShopUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_HOMELAND_FURNITURE_STORE, {
			isCarGroupMode = not Utils.isHomeland(pg.space and pg.space.spaceType)
		})
	end

	function self.view.btnCardUButton.luaClick()
		return
	end

	function self.view.btnGotoCampUButton.luaClick()
		pg.me:serverMsg("RPC_CS_ReqEnterSelfHomeCamp", CallbackHandler(self, "onEnterHomeCamp"))
		self:close()
	end

	function self.view.btnGotoHomeUButton.luaClick()
		self.view.vXClickLizUWidget:SetActive(false)
		self.view.vXClickLizUWidget:SetActive(true)

		if self.gotoHomeDelayTimer then
			TimerManager.removeTimer(self.gotoHomeDelayTimer)

			self.gotoHomeDelayTimer = nil
		end

		self.gotoHomeDelayTimer = TimerManager.addTimer(0.4, function()
			self.gotoHomeDelayTimer = nil

			if self:checkUIShow() then
				self.view.vXClickLizUWidget:SetActive(false)
				pg.global.showConfirmMsgRaw(pg.getGameString("GO_HOMELAND"), pg.getGameString("GO_HOMELAND_DESC"), function()
					pg.me:serverMsg("RPC_CS_ReqEnterSelfHomeland", CallbackHandler(self, "onEnterHomeland"))
					self:close()
				end)
			end
		end)
	end

	function self.view.btnPetUButton.luaClick()
		pg.global.ui.homeCarLevelUp:open({
			openReward = true,
			homeMainPage = self
		}, nil, nil, {
			ignoreResetUICamera = true
		})
	end
end

function HomelandMainPageCtrl:onEnterHomeCamp(res)
	if res then
		pg.global.ui:closeAllNormalPanel()
	end
end

function HomelandMainPageCtrl:onEnterHomeland(res)
	if res then
		pg.global.ui:closeAllNormalPanel()
	end
end

function HomelandMainPageCtrl:onDestroy()
	self.petComfortVale = nil
	self.furnitureComfortValue = nil
	self.liuliPetComfortValue = nil

	UICtrl.onDestroy(self)

	if self.gotoHomeDelayTimer then
		TimerManager.removeTimer(self.gotoHomeDelayTimer)

		self.gotoHomeDelayTimer = nil
	end
end

function HomelandMainPageCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function HomelandMainPageCtrl:onShow()
	self:setInitialFocus()
end

function HomelandMainPageCtrl:setInitialFocus()
	if not pg.game.input or not pg.game.input:isUsingGamepad() then
		return
	end

	local btn = self.view.btnCarDIYUButton

	if IsNil(btn) then
		return
	end

	if pg.global.navMgr then
		pg.global.navMgr:FocusItem(btn)
	end
end

function HomelandMainPageCtrl:onHide()
	return
end

function HomelandMainPageCtrl:refreshHomeCarInfo()
	self.homeCarBaseInfo = HomeLandUtils.getHomeCarInfo()

	self.carScene:refreshHomeCar(self.homeCarBaseInfo)
	self.carScene:showHomeCarNotObtained(false)
	self.carScene:changeHomeCarUpgradeMode(UIConst.HOMECAR_UPGRADE_TYPE.HomeCar)
	self.carScene:switchCamera(UIConst.HOMECAR_MODE_IDX.MAINPAGE, self.homeCarBaseInfo.modelLevel)
	self.carScene:changeCarRotate(true)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR_UPGRADE)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOMECAR_COMPONENT_UPGRADE)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR)
end

function HomelandMainPageCtrl:onVisibleChange(visible)
	if visible then
		self.view.uIPbHomeCampingCarMainUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
		ClientTextUtils.setText(self.view.textUSDFText, self.homeCarBaseInfo.level)
		self:refreshPetInfo()
	end
end

return HomelandMainPageCtrl
