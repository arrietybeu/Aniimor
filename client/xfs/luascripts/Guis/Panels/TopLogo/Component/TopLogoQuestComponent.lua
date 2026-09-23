-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoQuestComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("TopLogoQuestComponent")
local Class = require("Core.Framework.Class")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local SysConfigData = require("Data.sys_config_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local QuestConst = require("Common.Const.QuestConst")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local Utils = require("Common.Utils.Utils")
local OpenCacheDebugName = TopLogoConst.OpenCacheDebugName
local TopLogoQuestComponent = Class.LightClass("TopLogoQuestComponent", TopLogoItemComponent)
local QUESTINFO_KEY2INDEX_MAP = {
	canShow = 1,
	visible = 7,
	questState = 6,
	showNumMax = 5,
	questType = 4,
	content = 3,
	questId = 2,
	interactId = TopLogoConst.QUEST_INFO_INTERACT_ID_INDEX
}

function TopLogoQuestComponent:ctor(refUContainer, topLogoItem)
	TopLogoQuestComponent.super.ctor(self, refUContainer, topLogoItem)

	self.m_cacheQuestInfo = nil
	self.m_cbCacheQuestInfo = nil
	self.m_loadedQuestCallBack = nil

	self:onTopLogoCompUpdate()
end

function TopLogoQuestComponent:onCtor()
	self.m_pendingQuestRefresh = false

	if self.entity and self.entity.topLogoQuestDirtyFlag then
		self.m_pendingQuestRefresh = true
	end

	self:refreshVisible()
end

function TopLogoQuestComponent:hasQuestData()
	return self.entity and self.entity.hasTopLogoQuestData and self.entity:hasTopLogoQuestData()
end

function TopLogoQuestComponent:shouldBeActive()
	if self.m_pendingQuestRefresh then
		return true
	end

	if self.showQuestInfo == true then
		return true
	end

	return self:hasQuestData()
end

function TopLogoQuestComponent:resetRender()
	self.questVisible = nil

	if self.showQuestInfo or self:hasQuestData() then
		self.m_pendingQuestRefresh = true
	end

	self:m_releaseQuestTipCount()

	self.showQuestInfo = nil
	self.m_cbCacheQuestInfo = nil
	self.objectReference = nil
	self.panelUComponent = nil
	self.iconUImage = nil
	self.arrowRectTransform = nil

	TopLogoQuestComponent.super.resetRender(self)
end

function TopLogoQuestComponent:onDestroy()
	self.m_cacheQuestInfo = nil
	self.m_cbCacheQuestInfo = nil
	self.m_loadedQuestCallBack = nil
	self.m_pendingQuestRefresh = false

	if self.entity then
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_QUEST, self.onQuestMsg)
	end

	self:m_releaseQuestTipCount()
	TopLogoQuestComponent.super.onDestroy(self)
end

function TopLogoQuestComponent:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.arrowRectTransform = self.objectReference:GetRefValue("arrowRectTransform")
	self.panelUComponent = self.objectReference:GetRefValue("panelUComponent")
	self.iconUImage = self.objectReference:GetRefValue("iconUImage")

	if OpenCacheDebugName then
		local questId = self.m_cacheQuestInfo and self.m_cacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.questId] or 0
		local entityId = self.entity and self.entity.actorId or 0

		self.refUContainer.content.name = string.format("TopLogo_Quest_%s_%s", entityId, questId)
	end
end

function TopLogoQuestComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	TopLogoQuestComponent.super.onLanguageChanged(self)
end

function TopLogoQuestComponent:addEntityListener()
	function self.onQuestMsg(msgData)
		self.entity.topLogoQuestDirtyFlag = true
		self.m_pendingQuestRefresh = true

		if msgData and msgData.canShow == false then
			self:setQuestTipInfo(false, nil, nil)

			self.questVisible = nil
		end

		self:notifyActiveStateChanged(true)

		if self.topLogoItem:isTopLogoPrefabReady() then
			self.m_pendingQuestRefresh = false
		end

		self:onTopLogoCompUpdate()
	end

	if self.entity then
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_QUEST, self.onQuestMsg)
	end
end

function TopLogoQuestComponent:refreshTopLogoInfo(callFromUpdate)
	if self.m_pendingQuestRefresh then
		self.m_pendingQuestRefresh = false

		self:onTopLogoCompUpdate()

		return
	end
end

function TopLogoQuestComponent:initUI()
	LuaUIUtils.setUIViewVisible(self.panelUComponent, false)
	self:setQuestTipInfo(false, nil, nil)
end

function TopLogoQuestComponent:checkFinalVisible()
	if not TopLogoQuestComponent.super.innerGetVisible(self) then
		return false
	end

	if self.topLogoItem.distance > SysConfigData.SHOW_QUEST_MARK_DISTANCE then
		return false
	end

	return true
end

function TopLogoQuestComponent:innerGetVisible()
	if not TopLogoQuestComponent.super.innerGetVisible(self) then
		return false
	end

	if self.topLogoItem.distance > SysConfigData.SHOW_QUEST_MARK_DISTANCE then
		return false
	end

	local questArrowComponent = pg.global.ui.hatredArrowTip.questArrowComponent

	if questArrowComponent then
		Vector3.enableCreateFromCache()

		local pos = self.entity:getPosition()
		local topLogoHeight = self.entity.topLogoData and self.entity.topLogoData.heightToRoot or 0
		local inRegion = questArrowComponent:checkPosInScreenGuidanceRegionXYZ(pos[1], pos[2] + topLogoHeight, pos[3])

		Vector3.disableCreateFromCache()

		if not inRegion then
			return false
		end
	end

	return true
end

function TopLogoQuestComponent:checkTopLogoCompUpdate()
	if self.topLogoItem.distance > SysConfigData.SHOW_QUEST_MARK_DISTANCE then
		return false
	end

	return TopLogoQuestComponent.super.checkTopLogoCompUpdate(self)
end

function TopLogoQuestComponent:onTopLogoCompUpdateChanged(canUpdate)
	if not canUpdate then
		self:onTopLogoCompUpdate()
	end
end

function TopLogoQuestComponent:onTopLogoCompUpdate()
	local visible = self:checkFinalVisible()

	self.m_cacheQuestInfo = self.entity:getTopLogoQuestInfo(self.topLogoItem.distance)

	local canShow = self.m_cacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.canShow] or false
	local showNumMax = self.m_cacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.showNumMax] or nil

	visible = canShow and visible

	if visible then
		local questId = self.m_cacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.questId]

		if questId and questId > 0 then
			local pageType = QuestUtils.getPageType(questId)

			if pageType ~= QuestConst.QUEST_HUD_PAGE_TYPE.EMPTY then
				visible = QuestUtils.getCurSelPage() == pageType
			end
		end
	end

	if visible then
		local questType = self.m_cacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.questType]

		if questType and questType.styleType == QuestConst.QUEST_SHOW_TYPE.OTHER_STYLE then
			local npcComp = self.entity:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.NPC)

			if npcComp and npcComp.careerIcon and npcComp.isNpcInfoVisible then
				visible = false
			end
		end
	end

	if visible then
		local questId = self.m_cacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.questId]

		if questId and questId > 0 then
			visible = QuestUtils.canShowQuestTracking(questId)
		end
	end

	if visible and not self:checkQuestTipCount(showNumMax, visible, self:m_isChatInfo()) then
		visible = false
	end

	if not visible then
		self:m_releaseQuestTipCount()
	end

	self.m_cacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.visible] = visible

	if self:checkContainerLoaded() then
		self:updateQuestUI(visible)
	else
		self:loadAndUpdateQuestUI(visible)
	end
end

function TopLogoQuestComponent:updateQuestUI(visible)
	if self.questVisible ~= visible then
		self:setQuestTipInfo(visible, self.m_cacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.content], self.m_cacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.questType], self.m_cacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.questState])

		self.questVisible = visible
	end
end

function TopLogoQuestComponent:loadAndUpdateQuestUI(visible)
	self.m_cbCacheQuestInfo = Utils.deepCopyTable(self.m_cacheQuestInfo)

	if not self.m_loadedQuestCallBack then
		function self.m_loadedQuestCallBack(isSuccess)
			if isSuccess and self.m_cbCacheQuestInfo then
				local preLoadedVisible = self.m_cbCacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.visible]

				if preLoadedVisible ~= nil and self.questVisible ~= preLoadedVisible then
					self:setQuestTipInfo(self.m_cbCacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.visible], self.m_cbCacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.content], self.m_cbCacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.questType], self.m_cbCacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.questState])
				end
			end

			self.m_cbCacheQuestInfo = nil
		end
	end

	if visible then
		self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedQuestCallBack, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
	end
end

function TopLogoQuestComponent:setQuestTipInfo(isShow, content, taskType, questState)
	if self.showQuestInfo == isShow then
		return
	end

	self:setQuestPanel(isShow, content, taskType, questState)

	self.showQuestInfo = isShow

	self:notifyActiveStateChanged(self:shouldBeActive())
end

function TopLogoQuestComponent:setQuestPanel(isShow, content, taskType, questState)
	local manualStyleType = taskType and taskType.styleType == QuestConst.QUEST_SHOW_TYPE.MANUAL_STYLE
	local shouldHideNpcIcon = isShow and manualStyleType

	self.entity:executeTopLogoComponentMethod(UIConst.TOPLOGO_COMPONENT.NPC, "refreshIconByQuest", shouldHideNpcIcon)

	if not self:checkContainerLoaded() then
		return
	end

	if not isShow then
		self.panelUComponent:ProgressActive(false)

		return
	end

	if taskType == nil or taskType.styleType == nil then
		return
	end

	self.panelUComponent:ProgressActive(true)

	if manualStyleType then
		self.panelUComponent:TryChangePage("OtherTask", 0)
		self.panelUComponent:TryChangePage("TaskType", taskType.taskType)
	else
		self.panelUComponent:TryChangePage("OtherTask", 1)

		self.iconUImage = self.objectReference:GetRefValue("iconUImage")

		if self.iconUImage then
			local iconUrl = taskType.deliverIcon

			if iconUrl and iconUrl:match("^%$(.+)%.png$") then
				local iconName = iconUrl:match("^%$(.+)%.png$")

				iconUrl = string.format("%s[%s]", iconUrl, iconName)
			end

			self.iconUImage.url = iconUrl
		end
	end
end

function TopLogoQuestComponent:isQuestActive()
	return self:checkParentVisible() and self:checkFinalVisible() and self.showQuestInfo and self:checkSelfVisible()
end

function TopLogoQuestComponent:shouldSuppressMark()
	if self:isQuestActive() then
		return true
	end

	if self.entity.topLogoCreated then
		local npcComp = self.entity:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.NPC)

		if npcComp and npcComp.careerIcon and npcComp.isNpcInfoVisible then
			return true
		end
	end

	return false
end

function TopLogoQuestComponent:m_isChatInfo()
	if not self.m_cacheQuestInfo then
		return false
	end

	local interactId = self.m_cacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.interactId]

	return interactId ~= nil and interactId > 0
end

function TopLogoQuestComponent:m_getTipCountMap(isChat)
	if isChat then
		if pg.me.curChatTopLogoMap == nil then
			pg.me.curChatTopLogoMap = {}
		end

		return pg.me.curChatTopLogoMap
	end

	if pg.me.curQuestTopLogoMap == nil then
		pg.me.curQuestTopLogoMap = {}
	end

	return pg.me.curQuestTopLogoMap
end

function TopLogoQuestComponent:m_releaseQuestTipCount()
	if pg.me.curQuestTopLogoMap then
		pg.me.curQuestTopLogoMap[self] = nil
	end

	if pg.me.curChatTopLogoMap then
		pg.me.curChatTopLogoMap[self] = nil
	end
end

function TopLogoQuestComponent:checkQuestTipCount(showNumMax, visible, isChat)
	local ret = true
	local curQuestTopLogo = self:m_getTipCountMap(isChat)
	local otherTopLogoMap

	if isChat then
		otherTopLogoMap = pg.me.curQuestTopLogoMap
	else
		otherTopLogoMap = pg.me.curChatTopLogoMap
	end

	if otherTopLogoMap then
		otherTopLogoMap[self] = nil
	end

	if self.showQuestInfo ~= visible and visible == false then
		curQuestTopLogo[self] = nil
	end

	if showNumMax and self.showQuestInfo ~= visible and visible == true then
		if showNumMax < table.getCount(curQuestTopLogo) + 1 then
			ret = false
			curQuestTopLogo[self] = nil
		else
			curQuestTopLogo[self] = true
		end
	end

	return ret
end

function TopLogoQuestComponent:onQuestTabSwitch(questData)
	self:onTopLogoCompUpdate()

	if questData and questData.questId and questData.questId > 0 then
		local questSimpleInfo = self.entity:getTopLogoQuestInfo(self.topLogoItem.distance, true)
		local canShow = questSimpleInfo[1] or false
		local questId = questSimpleInfo[2] or 0

		if questId and questId == questData.questId and canShow then
			local function tabSwitchFunc(isSuccess)
				if isSuccess and self.panelUComponent then
					self.panelUComponent:TryGetCurrentPage("Target")

					if LuaUIUtils.isUIViewVisible(self.panelUComponent) and not QuestUtils.isQuestIconOtherStyleType(questId) then
						self.panelUComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
					end
				end
			end

			if self:checkContainerLoaded() then
				tabSwitchFunc(true)
			else
				self:checkAndLoadUContainerUrlSupportAsync(tabSwitchFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC2)
			end
		end
	end
end

function TopLogoQuestComponent:onQuestRunStateChange(data)
	if not data or not data.questId then
		return
	end

	if self.m_cacheQuestInfo then
		local curQuestId = self.m_cacheQuestInfo[QUESTINFO_KEY2INDEX_MAP.questId]

		if curQuestId and data.questId == curQuestId then
			self:onTopLogoCompUpdate()
		end
	end
end

function TopLogoQuestComponent:getInitMaxDistance()
	return self.questVisible and SysConfigData.SHOW_QUEST_MARK_DISTANCE or 0
end

function TopLogoQuestComponent:checkQuestWantsShow(distance)
	if not self.entity then
		return false
	end

	local simpleInfo = self.entity:getTopLogoQuestInfo(distance, true)

	if not simpleInfo[1] then
		return false
	end

	local questId = simpleInfo[2]

	if questId and questId > 0 then
		local pageType = QuestUtils.getPageType(questId)

		if pageType ~= QuestConst.QUEST_HUD_PAGE_TYPE.EMPTY then
			return QuestUtils.getCurSelPage() == pageType
		end
	end

	return true
end

return TopLogoQuestComponent
