-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\VitalityContestComponent.lua

local Class = require("Core.Framework.Class")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local EnergyMatchThemeData = require("Data.energy_match_theme_data")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local VitalityContestComponent = Class.LightClass("VitalityContestComponent", EventContainerComponent)

VitalityContestComponent.TAG_BONUS_TYPE = "vitality"
VitalityContestComponent.SCENE_NAME = UISceneConst.VITALITY_SCENE

function VitalityContestComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.rootWidget = objectReference:GetRefValue("rootWidget")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.curProgressUBaseText = objectReference:GetRefValue("curProgressUBaseText")
	self.btnJoinUButton = objectReference:GetRefValue("btnJoinUButton")
	self.btnAgainUButton = objectReference:GetRefValue("btnAgainUButton")
	self.txtRefreshUBaseText = objectReference:GetRefValue("txtRefreshUBaseText")
	self.textNameUBaseText = objectReference:GetRefValue("textNameUBaseText")
	self.listTagUList = objectReference:GetRefValue("listTagUList")
	self.finalScoreText = objectReference:GetRefValue("finalScoreText")
	self.processText = objectReference:GetRefValue("processText")
	self.adaptationUWidget = objectReference:GetRefValue("adaptationUWidget")
	self.middleUWidget = objectReference:GetRefValue("middleUWidget")
	self.eventTitleUContainer = objectReference:GetRefValue("eventTitleUContainer")
end

function VitalityContestComponent:onBeforeRefreshPage()
	EventContainerComponent.onBeforeRefreshPage(self)

	self.attrBonusType = self.TAG_BONUS_TYPE
end

function VitalityContestComponent:getThemeData()
	return EnergyMatchThemeData[self.phase] and EnergyMatchThemeData[self.phase][self.themeId] or {}
end

function VitalityContestComponent:getUISceneOwnerKey()
	return self.ctrl and self.ctrl.module or self.SCENE_NAME
end

function VitalityContestComponent:destroyUIScene()
	if self.uiScene then
		if not string.isNilOrEmpty(self.curPetId) then
			local pInfo = pg.me:getPetInfo(self.curPetId)

			if pInfo then
				self.uiScene:destroyPet(pInfo.templateId)
			end
		end

		local ownerKey = self:getUISceneOwnerKey()

		self.uiScene:removeUICtrlKey(ownerKey)

		if pg.game.uiScene:getScene(self.SCENE_NAME) == self.uiScene then
			pg.game.uiScene:switchOutScene(self.SCENE_NAME, self.uiScene:checkHasUICtrlBind(), nil, ownerKey)
		else
			self.uiScene:destroy()
		end
	end

	self.uiScene = nil
	self.curPetId = nil
	self.pendingShowLoadedScene = nil
end

function VitalityContestComponent:checkCanShowUIScene()
	return not self.isDestroyed and self.ctrl and self.ctrl:checkUIVisible() and self.enterStage ~= EventContainerComponent.EnterStage.Exited and self.enterStage ~= EventContainerComponent.EnterStage.Destroyed
end

function VitalityContestComponent:hasUISceneOwner(ownerKey)
	for _, sceneInfo in ipairs(pg.game.uiScene.uiSceneStack) do
		if sceneInfo.name == self.SCENE_NAME and sceneInfo.ownerKey == ownerKey then
			return true
		end
	end

	return false
end

function VitalityContestComponent:setUISceneVisible(visible)
	if not self.uiScene then
		return
	end

	local ownerKey = self:getUISceneOwnerKey()

	self.uiScene:onCtrlVisibleChange(ownerKey, visible)

	if not self.uiScene:checkLoaded() then
		return
	end

	if visible then
		pg.game.uiScene:switchToScene(self.SCENE_NAME, nil, nil, nil, ownerKey)
		self.uiScene:setActive(true)
	else
		if self:hasUISceneOwner(ownerKey) then
			pg.game.uiScene:switchOutScene(self.SCENE_NAME, true, nil, ownerKey)
		end

		if pg.game.uiScene:getScene(self.SCENE_NAME) ~= self.uiScene then
			self.uiScene:setActive(false)
		end
	end
end

function VitalityContestComponent:onVisibleChange(visible)
	if not visible then
		self:setUISceneVisible(false)

		return
	end

	if not self:checkCanShowUIScene() or not self.uiScene or not self.uiScene:checkLoaded() then
		return
	end

	if self.pendingShowLoadedScene then
		self:showLoadedScene()
	else
		self:setUISceneVisible(true)
	end
end

function VitalityContestComponent:openPetChoice()
	pg.global.ui:open(UIConst.UI_ID_PETEVENT_PETCHOICE, {
		eventId = self.eventId
	})
	self:destroyUIScene()
end

function VitalityContestComponent:addListener()
	function self.btnJoinUButton.luaClick()
		pg.me:setRedDotRecord(Const.CLIENT_KEY.EVENT_VITALITY_JOIN_RED_DOT, tostring(self.phase), false)
		pg.global.setRedDot(string.format(RedDotConst.RedDotPath.EVENT_VITALITY_JOIN_FIRST, self.phase), self.btnJoinUButton, false, RedDotConst.RedDotStyle.POINT)
		self:openPetChoice()
	end

	function self.btnAgainUButton.luaClick()
		self:openPetChoice()
	end

	function self.listRewardUList.luaRenderItem(button, index, data)
		if data.state == ClientConst.RewardState.ReadyToClaim then
			function data.extraFunc()
				self:onRewardClick(data)
			end
		end

		self.view:onRenderRewardItem(button, index, data)

		local txtName = button:Find("Text"):GetComponent("USDFText")

		ClientTextUtils.setText(txtName, pg.getGameString("VITALITY_SCORE_" .. data.index))

		local treePath = string.format(RedDotConst.RedDotPath.EVENT_VITALITY_REWARD_ITEM, data.index)
		local rewardIndex = index + 1
		local showRedDot = ClientActivityUtils.redDotReward_CheckVitalityRewardItem(self.phase, self.themeId, rewardIndex)

		pg.global.setRedDot(treePath, button, showRedDot, RedDotConst.RedDotStyle.REWARD)
	end
end

function VitalityContestComponent:onExitPage()
	self:destroyUIScene()
	EventContainerComponent.onExitPage(self)
end

function VitalityContestComponent:refreshPage()
	local phase = ActivityUtils.getNewEnergyTheme(pg.me)
	local themeId = ActivityUtils.getEnergyThemeId(pg.me)

	self.phase = phase
	self.themeId = themeId

	local themeData = self:getThemeData()

	self.bgNo = themeData.bgNo

	self:startTimer(function()
		ClientTextUtils.setText(self.textNameUBaseText, pg.getLocalizationText(themeData.taskName))
	end, 0.1)
	ClientTextUtils.setText(self.finalScoreText, pg.me.energyMatchPetScore or 0)

	local maxScore = pg.me.energyMatchJoinSum and pg.me.energyMatchJoinSum[themeId] or 0

	ClientTextUtils.setText(self.processText, maxScore)

	local rewardData = self.model:getVitalityContestRewardData(phase, themeId, maxScore)

	self.listRewardUList:SetList(rewardData)
	self:initTag(themeData)

	local isJoinRedDotNew = pg.me:getRedDotRecord(Const.CLIENT_KEY.EVENT_VITALITY_JOIN_RED_DOT, tostring(phase), true)
	local joinRedDotPath = string.format(RedDotConst.RedDotPath.EVENT_VITALITY_JOIN_FIRST, phase)

	pg.global.setRedDot(joinRedDotPath, self.btnJoinUButton, isJoinRedDotNew, RedDotConst.RedDotStyle.POINT)
	self:setEventTitle(self.eventTitleUContainer, ActivityUtils.refreshEnergyMatchExpireTime(self.phase, self.themeId, pg.me))
	self:refreshUIScene()
	self.rootWidget:TryChangePage("style", themeData.uiTheme)
	self:refreshCommonNodeRedDot()
end

function VitalityContestComponent:setFallbackContentVisible(visible)
	self.adaptationUWidget.gameObject:SetActiveEx(visible)
	self.middleUWidget.gameObject:SetActiveEx(visible)
end

function VitalityContestComponent:showLoadedScene()
	if not self:checkCanShowUIScene() then
		self.pendingShowLoadedScene = true

		self:setUISceneVisible(false)

		return
	end

	self.pendingShowLoadedScene = nil

	self:setUISceneVisible(true)
	self.uiScene:setVitalityBg(self.bgNo or 1)

	local showPetId = pg.me.energyMatchPetId

	self:showPetModel(showPetId, function()
		if self.isDestroyed or not self.uiScene or self.curPetId ~= showPetId then
			return
		end

		self:wearTryAccess()
	end)
end

function VitalityContestComponent:refreshUIScene()
	if string.isNilOrEmpty(pg.me.energyMatchPetId) then
		self:setFallbackContentVisible(true)

		return
	end

	self:setFallbackContentVisible(false)
	self.rootWidget:TryChangePage("Status", 1)

	if not self.uiScene then
		self.uiScene = pg.game.uiScene:getUISceneInst(self.SCENE_NAME, AddressDataConst.UI_VITALITY_CONTEST_SCENE, nil, nil, self.SCENE_NAME)

		self.uiScene:bindUICtrlKey(self:getUISceneOwnerKey())

		self.uiScene.disableBackground = true
	end

	if self.uiScene:checkLoadStateIsNone() then
		self.uiScene:startLoad(function(succeed)
			if succeed then
				self:showLoadedScene()
			else
				self:setFallbackContentVisible(true)
			end
		end)
	elseif self.uiScene:checkLoaded() then
		self:showLoadedScene()
	else
		self:setFallbackContentVisible(true)
	end
end

function VitalityContestComponent:showPetModel(showPetId, loadedCallback)
	if not string.isNilOrEmpty(self.curPetId) then
		local pInfo = pg.me:getPetInfo(self.curPetId)

		if pInfo then
			self.uiScene:destroyPet(pInfo.templateId)
		end
	end

	if string.isNilOrEmpty(showPetId) then
		return
	end

	self.curPetId = showPetId

	self.model:clearCacheData()

	local baseInfo = self.model:setPetProId(showPetId)

	if baseInfo == nil then
		return
	end

	local pInfo = pg.me:getPetInfo(showPetId)

	if not pInfo then
		return
	end

	local petHeight = pInfo.height or 1

	self.adjustHeight = petHeight * 1.2
	self.modelSliderInfo = AvatarUtils.generatePetJewelrySlider(petHeight, baseInfo.scale, 1.5, pInfo.sizeLevel)

	self.uiScene:showPetTemplate(pInfo, baseInfo.scale, baseInfo.offset, loadedCallback)
end

function VitalityContestComponent:wearTryAccess()
	local curEnt = self.uiScene:getCurEntity()

	if not curEnt then
		return
	end

	local modelView = curEnt.eModel.modelView
	local modelInfo = modelView.modelInfo
	local pInfo = pg.me:getPetInfo(self.curPetId)

	if not pInfo then
		return
	end

	local tryAccessData = {}
	local themeData = self:getThemeData()

	if pg.me.energyMatchPetAccessories then
		for _, accessoryId in pairs(pg.me.energyMatchPetAccessories) do
			if table.contains(themeData.accessoryTry or {}, accessoryId) then
				table.insert(tryAccessData, {
					accessoryId = accessoryId,
					instanceId = tostring(accessoryId)
				})
			end
		end
	end

	for _, data in pairs(tryAccessData) do
		local attachInfo = self.model:parseDefaultAccessInfo(pInfo.templateId, data.accessoryId, self.modelSliderInfo)

		attachInfo.instanceId = data.instanceId

		local scale = Vector3.New(attachInfo.scale, attachInfo.scale, attachInfo.scale)

		modelInfo:AddAttachInfo(attachInfo.resId, attachInfo.instanceId, attachInfo.attachHp, attachInfo.localPosition, attachInfo.localRotation, scale, false)
		modelView:RefreshModels()
	end
end

function VitalityContestComponent:initTag(themeData)
	local tagData = {}

	themeData = themeData or {}

	for index = 1, 3 do
		table.insert(tagData, {
			icon = themeData["bonusIcon" .. index],
			name = pg.getLocalizationText(themeData["bonusName" .. index]),
			showBG = themeData["bonusType" .. index] ~= self.attrBonusType
		})
	end

	function self.listTagUList.luaRenderItem(button, _, data)
		local txtName = button:Find("Text"):GetComponent("USDFText")

		ClientTextUtils.setText(txtName, data.name)

		local imgIcon = button:Find("Icon"):GetComponent("UImage")

		imgIcon.url = data.icon

		local bgIcon = button:Find("BgIcon"):GetComponent("UImage")

		bgIcon.gameObject:SetActiveEx(data.showBG)
	end

	self.listTagUList:SetList(tagData)
end

function VitalityContestComponent:onRewardClick(data)
	pg.me:serverActivityMsg(self.eventId, "RPC_CS_GetEnergyMatchAward", data.index)
end

function VitalityContestComponent:onDestroy()
	self:destroyUIScene()
	UIComponent.onDestroy(self)
end

return VitalityContestComponent
