-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoNpcComponent.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local Utils = require("Common.Utils.Utils")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local TopLogoConst = require("Const.TopLogoConst")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local SysConfigData = require("Data.sys_config_data")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TopLogoNpcComponent = Class.LightClass("TopLogoNpcComponent", TopLogoItemComponent)
local UBASE_TEXT_TYPE
local WHITE_COLOR = Color(1, 1, 1, 1)
local CAREER_YELLOW_COLOR = Color(1, 0.9764706, 0.33333334, 1)

local function getCareerTextColor(isMasterName)
	return isMasterName and WHITE_COLOR or CAREER_YELLOW_COLOR
end

function TopLogoNpcComponent:ctor(refUContainer, topLogoItem)
	TopLogoNpcComponent.super.ctor(self, refUContainer, topLogoItem)
	self:refreshNpcInfo()
end

function TopLogoNpcComponent:refreshNpcInfo()
	local canSpecialStateRecover = self.entity.canSpecialStateRecover
	local npcInfo = {}

	if self._isPuppet or self._isVirtualPuppet then
		npcInfo = Utils.getNpcInfoData(self.entity.templateId) or {}
	else
		npcInfo = self.entity:getConfigData()
	end

	self.configData = self.entity:getConfigData()
	self.name = canSpecialStateRecover and self.entity:getName() or npcInfo.name
	self.careerIcon = canSpecialStateRecover and self.entity:getCareerIcon() or npcInfo.icon

	if self._isStaticNpcWithNpcTopLogo and not self.name and self.entity.getAttachEntityName then
		self.name = self.entity:getAttachEntityName()
	end

	if canSpecialStateRecover then
		self.careerName = self.entity:getCareerName() or npcInfo.careerName
		self.m_careerNameIsMasterName = false
	elseif self.entity.getSubName then
		self.careerName = self.entity:getSubName()
		self.m_careerNameIsMasterName = false
	elseif self.configData and self.configData.masterName then
		self.careerName = self.configData.masterName
		self.m_careerNameIsMasterName = true
	else
		self.careerName = npcInfo.careerName
		self.m_careerNameIsMasterName = false
	end

	local isFallbackNpc = self._isStaticNpcWithNpcTopLogo and (self._isPuppet or self._isVirtualPuppet)

	if isFallbackNpc then
		local masterName = self.configData.masterName

		if masterName then
			self.careerName = masterName
			self.m_careerNameIsMasterName = true
		elseif self.entity.getMasterName then
			self.careerName = self.entity:getMasterName()
			self.m_careerNameIsMasterName = true
		end
	end

	local forceHide = self.configData.extraNameControl and self.configData.extraNameControl == 2 or false
	local forceShow = self.configData.extraNameControl and self.configData.extraNameControl == 1 or false

	self.m_validIcon = self.careerIcon ~= nil and not self.isShowQuest
	self.m_validName = self.name ~= nil and (forceShow or not forceHide)
	self.m_validCareer = self.careerName ~= nil
end

function TopLogoNpcComponent:shouldBeActive()
	if not self.isNpcInfoVisible then
		return false
	end

	if not self.m_validName and not self.m_validCareer and not self.m_validIcon then
		return false
	end

	local state = self:m_getCurrentNpcUIState()
	local showIcon = state ~= UIConst.TOPLOGO_NPC_STATE.HIDE and self.m_validIcon

	if showIcon then
		return true
	end

	local showCareerOrName = state == UIConst.TOPLOGO_NPC_STATE.CLOSE and (self.m_validCareer or self.m_validName)

	if showCareerOrName then
		return true
	end

	if Utils.isInteractNpc(self.entity) and self.entity:checkNpcInteractState() then
		return true
	end

	return false
end

function TopLogoNpcComponent:resetRender()
	self:m_clearPendingNpcEnterTransition()

	self.lastUpdateState = nil
	self.state = nil
	self.objectReference = nil
	self.rootUComponent = nil
	self.npcInfoUWidget = nil
	self.iconUImage = nil
	self.careerUText = nil
	self.nameUText = nil
	self.m_careerTextGroup = nil
	self.m_appliedCareerColorIsMaster = nil

	TopLogoNpcComponent.super.resetRender(self)
	self:markDirty(EventConst.NPC_SPECIAL_STATE_UPDATE)
end

function TopLogoNpcComponent:onDestroy()
	self:m_clearPendingNpcEnterTransition()

	if self.entity then
		self.entity.eventEmitter:removeEventListener(EventConst.NPC_SPECIAL_STATE_UPDATE, self.topLogoNpcInfoUpdate)
	end

	TopLogoNpcComponent.super.onDestroy(self)

	self.isShowQuest = nil
	self.m_loadedNpcInfoCallBack = nil
	self.m_careerTextGroup = nil
	self.m_careerNameIsMasterName = nil
	self.m_appliedCareerColorIsMaster = nil
end

function TopLogoNpcComponent:m_setGoActive(go, active)
	if go then
		go:SetActiveEx(active)
	end
end

function TopLogoNpcComponent:m_setNpcWidgetVisible(widget, visible, force)
	if widget and NotNil(widget) then
		if visible then
			widget:ProgressActive(true, force)
			widget:ProgressScale(true, force, true)
		else
			widget:ProgressScale(false, force)
			widget:ProgressActive(false, force)
		end
	end
end

function TopLogoNpcComponent:m_getCurrentNpcUIState()
	local distance = self.topLogoItem and self.topLogoItem.distance

	if distance then
		self.state = self:getNpcInfoState(distance)
	end

	return self.state or UIConst.TOPLOGO_NPC_STATE.HIDE
end

function TopLogoNpcComponent:m_hasVisibleNpcWidgetByState(state)
	if state == UIConst.TOPLOGO_NPC_STATE.HIDE then
		return false
	end

	if self.m_validIcon then
		return true
	end

	return state == UIConst.TOPLOGO_NPC_STATE.CLOSE and (self.m_validCareer or self.m_validName)
end

function TopLogoNpcComponent:m_clearPendingNpcEnterTransition()
	self.m_pendingNpcEnterTransition = nil

	if self.m_pendingNpcEnterTransitionFrameId then
		TimerManager.delFrameCb(self.m_pendingNpcEnterTransitionFrameId)

		self.m_pendingNpcEnterTransitionFrameId = nil
	end
end

function TopLogoNpcComponent:m_tryDeferPendingNpcEnterTransition()
	if not self.m_pendingNpcEnterTransition then
		return false
	end

	local state = self:m_getCurrentNpcUIState()

	if not self:m_hasVisibleNpcWidgetByState(state) then
		return true
	end

	if self.m_pendingNpcEnterTransitionFrameId then
		return true
	end

	self.m_pendingNpcEnterTransitionFrameId = TimerManager.addNextFrameCb(function()
		self.m_pendingNpcEnterTransitionFrameId = nil

		if not self.m_pendingNpcEnterTransition then
			return
		end

		if not self:checkContainerLoaded() or not self:checkFinalVisible() then
			self.lastUpdateState = nil

			return
		end

		local currentState = self:m_getCurrentNpcUIState()

		if not self:m_hasVisibleNpcWidgetByState(currentState) then
			self.lastUpdateState = currentState

			return
		end

		self.m_pendingNpcEnterTransition = nil

		self:m_refreshNpcUIByState(false)

		self.lastUpdateState = currentState
	end)

	return true
end

function TopLogoNpcComponent:m_refreshNpcUIByStateWithPending(force)
	if not force and self:m_tryDeferPendingNpcEnterTransition() then
		return
	end

	self:m_refreshNpcUIByState(force)
end

function TopLogoNpcComponent:m_refreshNpcUIByState(force)
	if not self:checkContainerLoaded() then
		return
	end

	local state = self:m_getCurrentNpcUIState()
	local showIcon = state ~= UIConst.TOPLOGO_NPC_STATE.HIDE and self.m_validIcon
	local showCareer = state == UIConst.TOPLOGO_NPC_STATE.CLOSE and self.m_validCareer
	local showName = state == UIConst.TOPLOGO_NPC_STATE.CLOSE and self.m_validName

	self:m_setNpcWidgetVisible(self.iconUImage, showIcon, force)
	self:m_setNpcWidgetVisible(self.careerUText, showCareer, force)
	self:m_setNpcWidgetVisible(self.nameUText, showName, force)
end

function TopLogoNpcComponent:initUI()
	self:m_clearPendingNpcEnterTransition()
	self:m_setNpcWidgetVisible(self.iconUImage, false, true)
	self:m_setNpcWidgetVisible(self.careerUText, false, true)
	self:m_setNpcWidgetVisible(self.nameUText, false, true)

	self.m_pendingNpcEnterTransition = true

	self:markDirty(EventConst.NPC_SPECIAL_STATE_UPDATE)
end

function TopLogoNpcComponent:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.npcInfoUWidget = self.objectReference:GetRefValue("npcInfoUWidget")
	self.iconUImage = self.objectReference:GetRefValue("iconUImage")
	self.careerUText = self.objectReference:GetRefValue("careerUText")
	self.nameUText = self.objectReference:GetRefValue("nameUText")

	if self.m_cacheCareerTextGroup then
		self:m_cacheCareerTextGroup()
	end

	if self.m_resetRootTransforms then
		self:m_resetRootTransforms()
	end

	if self.m_lastShowQuest ~= nil then
		self:refreshIconByQuest(self.m_lastShowQuest)
	end
end

function TopLogoNpcComponent:addEntityListener()
	function self.topLogoNpcInfoUpdate()
		if self:checkVisibleAndMarkDirty(EventConst.NPC_SPECIAL_STATE_UPDATE) then
			self:refreshNpcTitle()
			self:m_refreshNpcUIByStateWithPending(false)
		end
	end

	if self.entity then
		self.entity.eventEmitter:addEventListener(EventConst.NPC_SPECIAL_STATE_UPDATE, self.topLogoNpcInfoUpdate)
	end
end

function TopLogoNpcComponent:checkTopLogoCompUpdate()
	if self.topLogoItem.distance > SysConfigData.NPC_TOPLOGO_DISTANCE then
		return false
	end

	return TopLogoNpcComponent.super.checkTopLogoCompUpdate(self)
end

function TopLogoNpcComponent:innerGetVisible()
	if not TopLogoNpcComponent.super.innerGetVisible(self) then
		return false
	end

	if not self.isNpcInfoVisible then
		return false
	end

	if self.entity.hideTitleAndEffs and self.entity:hideTitleAndEffs() then
		return false
	end

	if self.topLogoItem.distance > SysConfigData.NPC_TOPLOGO_DISTANCE then
		return false
	end

	local canInteract = Utils.isInteractNpc(self.entity) and self.entity:checkNpcInteractState()

	if not canInteract then
		return false
	end

	return self.m_validIcon or self.m_validCareer or self.m_validName
end

function TopLogoNpcComponent:onTopLogoCompUpdate()
	self.state = self:getNpcInfoState(self.topLogoItem.distance)
end

function TopLogoNpcComponent:refreshTopLogoInfo()
	if self:checkFinalVisible() then
		if self:checkContainerLoaded() then
			self:m_refreshTplNpcUI()
		else
			if not self.m_loadedNpcInfoCallBack then
				function self.m_loadedNpcInfoCallBack(isSuccess)
					if isSuccess then
						self:m_refreshTplNpcUI()
					end
				end
			end

			self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedNpcInfoCallBack, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
		end
	end
end

function TopLogoNpcComponent:m_refreshTplNpcUI()
	if not self:checkContainerLoaded() then
		return
	end

	local titleDirty = self:checkAndResetDirty(EventConst.NPC_SPECIAL_STATE_UPDATE)

	if titleDirty then
		self:refreshNpcTitle()
	end

	local currentState = self:m_getCurrentNpcUIState()

	if titleDirty or self.lastUpdateState ~= currentState then
		self:m_refreshNpcUIByStateWithPending(false)

		self.lastUpdateState = currentState
	end
end

function TopLogoNpcComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	TopLogoNpcComponent.super.onLanguageChanged(self)
	self:refreshNpcTitle()
end

function TopLogoNpcComponent:refreshNpcTitle(isOnlySetText)
	if not self:checkContainerLoaded() then
		return
	end

	if not isOnlySetText then
		self:refreshNpcInfo()
		self:setNameColor()

		self.iconUImage.url = self.careerIcon
	end

	local selfNameL18n = pg.getLocalizationText(self.name or "")

	if not UNITY_EDITOR and pg.game.setting:getShowDebugText() then
		local actorIdSuffix = string.format("_%d", self.entity.actorId or 0)

		selfNameL18n = ClientTextUtils.concatByLanguage(selfNameL18n, actorIdSuffix)
	end

	local careerNameL18n = pg.getLocalizationText(self.careerName or "")

	ClientTextUtils.setText(self.nameUText, selfNameL18n)
	ClientTextUtils.setText(self.careerUText, careerNameL18n)

	if self.m_refreshCareerTextColor then
		self:m_refreshCareerTextColor()
	end
end

function TopLogoNpcComponent:setNameColor()
	if Utils.isEnemy(self.entity, pg.me) then
		self.rootUComponent:TryChangePage("NameChar", "Enemy")
	else
		self.rootUComponent:TryChangePage("NameChar", "NPC")
	end
end

function TopLogoNpcComponent:m_cacheCareerTextGroup()
	self.m_careerTextGroup = nil
	self.m_appliedCareerColorIsMaster = nil

	if not self.careerUText or IsNil(self.careerUText) then
		return
	end

	if not UBASE_TEXT_TYPE then
		UBASE_TEXT_TYPE = typeof(CS.XGUI.UBaseText)
	end

	local texts = self.careerUText.transform:GetComponentsInChildren(UBASE_TEXT_TYPE, true)

	if not texts then
		return
	end

	local group = {}

	for i = 1, texts.Length do
		local uText = texts[i - 1]

		if NotNil(uText) then
			group[#group + 1] = uText
		end
	end

	if #group > 0 then
		self.m_careerTextGroup = group
	end
end

function TopLogoNpcComponent:m_refreshCareerTextColor()
	local group = self.m_careerTextGroup

	if not group then
		return
	end

	local isMasterName = self.m_careerNameIsMasterName == true

	if self.m_appliedCareerColorIsMaster == isMasterName then
		return
	end

	local color = getCareerTextColor(isMasterName)

	for i = 1, #group do
		local uText = group[i]

		if NotNil(uText) then
			uText.color = color
		end
	end

	self.m_appliedCareerColorIsMaster = isMasterName
end

function TopLogoNpcComponent:setVisibleNpcInfo(isVisible)
	if self.isNpcInfoVisible == isVisible then
		return
	end

	self.isNpcInfoVisible = isVisible

	self:refreshVisible()
	self:notifyMaxDistanceChanged()
	self:notifyActiveStateChanged(self:shouldBeActive())
end

function TopLogoNpcComponent:getNpcInfoState(distance)
	if distance > SysConfigData.NPC_TOPLOGO_DISTANCE then
		return UIConst.TOPLOGO_NPC_STATE.HIDE
	elseif distance > SysConfigData.NPC_NAME_DISTANCE then
		return UIConst.TOPLOGO_NPC_STATE.FAR
	else
		return UIConst.TOPLOGO_NPC_STATE.CLOSE
	end
end

function TopLogoNpcComponent:refreshIconByQuest(isShowQuest)
	self.isShowQuest = isShowQuest

	if self.iconUImage and NotNil(self.iconUImage) then
		self:refreshNpcTitle()
		self:m_refreshNpcUIByStateWithPending(false)

		self.m_lastShowQuest = nil
	else
		self.m_lastShowQuest = isShowQuest
	end
end

function TopLogoNpcComponent:m_resetRootTransforms()
	if self.refUContainer and NotNil(self.refUContainer) and self.refUContainer.content and NotNil(self.refUContainer.content) then
		local content = self.refUContainer.content
		local contentT = content.transform or content

		if contentT and NotNil(contentT) then
			if contentT.anchoredPosition ~= nil then
				contentT.anchoredPosition = Vector3.zero
			end

			if contentT.SetLocalScaleEx then
				contentT:SetLocalScaleEx(1, 1, 1)
			end
		end
	end

	if self.rootUComponent and NotNil(self.rootUComponent) then
		local rootT = self.rootUComponent.transform

		if rootT and NotNil(rootT) then
			rootT:SetLocalScaleEx(1, 1, 1)
		end
	end
end

function TopLogoNpcComponent:onTopLogoCompVisibleChanged(visible)
	if visible and self.m_resetRootTransforms then
		self:m_resetRootTransforms()
	end

	TopLogoNpcComponent.super.onTopLogoCompVisibleChanged(self, visible)
end

function TopLogoNpcComponent:getInitMaxDistance()
	return SysConfigData.NPC_TOPLOGO_DISTANCE
end

return TopLogoNpcComponent
