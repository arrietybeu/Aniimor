-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoBattleRoomComponent.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local UIConst = require("Const.UIConst")
local SysConfigData = require("Data.sys_config_data")
local TopLogoConst = require("Const.TopLogoConst")
local NpcDuelData = require("Data.npc_duel_data")
local NpcDuelIdToMarkIdsData = require("Data.npc_duel_id_to_mark_ids_data")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local EventConst = require("Const.EventConst")
local DUEL_STATUS_NOCHALLENGE = 0
local DUEL_STATUS_CHALLENGING = 1
local DUEL_STATUS_PART_PASS = 2
local DUEL_STATUS_ALL_PASS = 3
local ENABLE_BATTLE_ROOM_GUIDANCE_REGION_CHECK = true
local TopLogoBattleRoomComponent = Class.LightClass("TopLogoBattleRoomComponent", TopLogoItemComponent)

function TopLogoBattleRoomComponent:onTopLogoCompUpdate()
	self:refreshTopLogoInfo()
end

function TopLogoBattleRoomComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	TopLogoBattleRoomComponent.super.onLanguageChanged(self)
end

function TopLogoBattleRoomComponent:getInitMaxDistance()
	return SysConfigData.NPC_TOPLOGO_DISTANCE
end

function TopLogoBattleRoomComponent:getNpcDuelId()
	local configData = self.entity and self.entity.getConfigData and self.entity:getConfigData()

	return configData and configData.npcDuelId
end

function TopLogoBattleRoomComponent:shouldBeActive()
	if not self:isActive() or self:getNpcDuelId() == nil then
		return false
	end

	return self:getNpcDuelState() ~= DUEL_STATUS_NOCHALLENGE
end

function TopLogoBattleRoomComponent:innerGetVisible()
	if not TopLogoBattleRoomComponent.super.innerGetVisible(self) then
		return false
	end

	if self:getNpcDuelId() == nil then
		return false
	end

	if self:getNpcDuelState() == DUEL_STATUS_NOCHALLENGE then
		return false
	end

	local questComp = self.entity and self.entity.getToplogoComponent and self.entity:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.QUEST)

	if questComp and questComp:checkQuestWantsShow(self.topLogoItem.distance) then
		return false
	end

	if ENABLE_BATTLE_ROOM_GUIDANCE_REGION_CHECK then
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
	end

	return true
end

function TopLogoBattleRoomComponent:shouldSuppressMark()
	return self.m_battleRoomDisplayed == true
end

function TopLogoBattleRoomComponent:m_syncBattleRoomDisplayState()
	local displayed = self:checkContainerLoaded() and self:checkParentVisible() and self:checkFinalVisible() and self:checkSelfVisible()

	if self.m_battleRoomDisplayed == displayed then
		return
	end

	self.m_battleRoomDisplayed = displayed

	local entity = self.entity

	if not entity or not entity.id then
		return
	end

	pg.global.eventEmitter:emit(EventConst.TOPLOGO_BATTLE_ROOM_DISPLAY_CHANGED, entity.id, displayed)
end

function TopLogoBattleRoomComponent:m_setBattleRoomContentVisible(visible, force)
	local widget = self.rootUComponent

	if IsNil(widget) then
		return
	end

	if visible then
		widget:ProgressActive(true, force)
		widget:ProgressScale(true, force, true)
	else
		widget:ProgressScale(false, force)
		widget:ProgressActive(false, force)
	end
end

function TopLogoBattleRoomComponent:m_clearPendingBattleRoomEnterTransition()
	self.m_pendingBattleRoomEnterTransition = nil

	if self.m_pendingBattleRoomEnterTransitionFrameId then
		TimerManager.delFrameCb(self.m_pendingBattleRoomEnterTransitionFrameId)

		self.m_pendingBattleRoomEnterTransitionFrameId = nil
	end
end

function TopLogoBattleRoomComponent:m_playPendingBattleRoomEnterTransition()
	if not self.m_pendingBattleRoomEnterTransition or self.m_pendingBattleRoomEnterTransitionFrameId then
		return
	end

	self.m_pendingBattleRoomEnterTransitionFrameId = TimerManager.addNextFrameCb(function()
		self.m_pendingBattleRoomEnterTransitionFrameId = nil

		if not self.m_pendingBattleRoomEnterTransition then
			return
		end

		self.m_pendingBattleRoomEnterTransition = nil

		if self:checkContainerLoaded() and self:checkFinalVisible() then
			self:m_setBattleRoomContentVisible(true, false)
		end
	end)
end

function TopLogoBattleRoomComponent:findObjects()
	self.rootUComponent = self.refUContainer and self.refUContainer.content
end

function TopLogoBattleRoomComponent:initUI()
	self:m_clearPendingBattleRoomEnterTransition()
	self:m_setBattleRoomContentVisible(false, true)

	self.m_pendingBattleRoomEnterTransition = true

	self:m_playPendingBattleRoomEnterTransition()
	self:refreshBattleRoomInfo()
	self:m_syncBattleRoomDisplayState()
end

function TopLogoBattleRoomComponent:onTopLogoCompVisibleChanged(visible, skipRefresh)
	if visible then
		if self.m_pendingBattleRoomEnterTransition then
			self:m_playPendingBattleRoomEnterTransition()
		else
			self:m_setBattleRoomContentVisible(true, false)
		end
	else
		self:m_clearPendingBattleRoomEnterTransition()
		self:m_setBattleRoomContentVisible(false, true)
	end

	self:m_syncBattleRoomDisplayState()
	TopLogoBattleRoomComponent.super.onTopLogoCompVisibleChanged(self, visible, skipRefresh)
end

function TopLogoBattleRoomComponent:resetRender()
	self:m_clearPendingBattleRoomEnterTransition()

	self.rootUComponent = nil
	self.lastStagePage = nil
	self.m_battleRoomDisplayed = nil

	TopLogoBattleRoomComponent.super.resetRender(self)
end

function TopLogoBattleRoomComponent:getNpcDuelState()
	local npcDuelId = self:getNpcDuelId()

	if not npcDuelId then
		return nil
	end

	local state = pg.me and pg.me.npcDuelState and pg.me.npcDuelState[npcDuelId]

	if state == nil then
		local config = NpcDuelData[npcDuelId] and NpcDuelData[npcDuelId][1]

		state = config and config.initState or DUEL_STATUS_NOCHALLENGE
	end

	return state
end

function TopLogoBattleRoomComponent:isProDuelMark()
	local npcDuelId = self:getNpcDuelId()

	if not npcDuelId then
		return false
	end

	local markIds = NpcDuelIdToMarkIdsData[npcDuelId]
	local markId = markIds and markIds[1]

	if not markId then
		return false
	end

	local spaceId = pg.space and pg.space.id

	return Utils.getMarkConfigId(markId, spaceId) == Const.NPC_DUEL_PRO
end

function TopLogoBattleRoomComponent:getStagePageByState(state)
	local isPro = self:isProDuelMark()

	if state == DUEL_STATUS_CHALLENGING or state == DUEL_STATUS_PART_PASS then
		return isPro and "Twice" or "Normal"
	elseif state == DUEL_STATUS_ALL_PASS then
		return isPro and "TwiceDone" or "NormalDone"
	end

	return "Disable"
end

function TopLogoBattleRoomComponent:refreshBattleRoomInfo()
	if not self.rootUComponent then
		return
	end

	local stagePage = self:getStagePageByState(self:getNpcDuelState())

	if self.lastStagePage == stagePage then
		return
	end

	self.lastStagePage = stagePage

	self.rootUComponent:TryChangePage("Stage", stagePage)
end

function TopLogoBattleRoomComponent:onNpcDuelStateChanged(info)
	local npcDuelId = info and info.npcDuelId

	if npcDuelId and npcDuelId ~= self:getNpcDuelId() then
		return
	end

	self:refreshVisible()
	self:notifyActiveStateChanged(self:shouldBeActive())

	if self:checkContainerLoaded() then
		self:refreshBattleRoomInfo()
	else
		self:refreshTopLogoInfo()
	end
end

function TopLogoBattleRoomComponent:refreshTopLogoInfo(callFromUpdate)
	if not self:checkFinalVisible() then
		return
	end

	if self:checkContainerLoaded() then
		self:refreshBattleRoomInfo()

		return
	end

	self:checkAndLoadUContainerUrlSupportAsync(function(isSuccess)
		if isSuccess then
			self:refreshBattleRoomInfo()
		end
	end, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
end

return TopLogoBattleRoomComponent
