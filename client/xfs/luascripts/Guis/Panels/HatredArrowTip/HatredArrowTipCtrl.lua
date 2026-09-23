-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HatredArrowTip\\HatredArrowTipCtrl.lua

local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SysConfigData = require("Data.sys_config_data")
local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local UICtrl = require("Guis.UICtrl")
local QuestArrowTipComponent = require("Guis.Panels.HatredArrowTip.Component.QuestArrowTipComponent")
local MapMarkTipComponent = require("Guis.Panels.HatredArrowTip.Component.MapMarkTipComponent")
local NormalTrackComponent = require("Guis.Panels.HatredArrowTip.Component.NormalTrackComponent")
local HornInviteComponent = require("Guis.Panels.HatredArrowTip.Component.HornInviteComponent")
local FluteInviteComponent = require("Guis.Panels.HatredArrowTip.Component.FluteInviteComponent")
local HatredArrowTipCtrl = Class.LightClass("HatredArrowTipCtrl", UICtrl)

HatredArrowTipCtrl.TRACK_DISPLAY_STATE = {
	VISIBLE = 1,
	HIDDEN = 0
}
HatredArrowTipCtrl.TRACK_PRIORITY = {
	MAP_MARK = 100,
	QUEST = 300,
	NORMAL_TRACK = 200
}
HatredArrowTipCtrl.SAME_TRACK_TARGET_SQR_DISTANCE = 0.001

local ToBool = ToBool
local Quaternion = Quaternion
local Vector3 = Vector3
local Vector2 = Vector2

HatredArrowTipCtrl.messages = {
	[MessageName.QUEST_ON_STATE_CHANGE] = {
		"onQuestStateChange",
		true
	},
	[MessageName.QUEST_ON_OBJECTIVE_FINISHED] = {
		"onQuestObjectiveFinished",
		true
	},
	[MessageName.QUEST_ON_TAB_SWITCH] = {
		"onQuestTabSwitch",
		true
	},
	[MessageName.QUEST_ON_TRACE_CHANGE] = {
		"onQuestTraceChange",
		true
	},
	[MessageName.QUEST_ON_RUN_STATE_CHANGE] = {
		"onQuestRunStateChange",
		true
	},
	[MessageName.TEAM_MARK_CHANGE] = {
		"onTeamMarkChange",
		true
	},
	[MessageName.TEAM_MARK_TRACK_CHANGE] = {
		"onTeamMarkTrackChange",
		true
	},
	[MessageName.SCENE_MARK_DATA_ALLY_CHANGED] = {
		"onAllyChanged",
		true
	},
	[MessageName.SCENE_LOADED] = {
		"onSceneLoaded",
		true
	},
	[MessageName.UI_TRACK_SINGLE_ENT] = {
		"trackSingleEnt",
		true
	},
	[MessageName.UI_TRACK_HORN_INVITER] = {
		"trackHornInviter",
		true
	},
	[MessageName.UI_TRACK_FLUTE_INVITER] = {
		"trackFluteInviter",
		true
	},
	[MessageName.BOSS_TITLE_SHOWN_MESSAGE] = {
		"onBossTitleVisibleChanged",
		true
	},
	[MessageName.DUNGEON_TEAMMATEVIEW_CHANGE] = {
		"onTeammateViewChange",
		true
	},
	[MessageName.ON_DYNAMIC_MARK_STATUS_CHANGED] = {
		"onDynamicMarkStatusChanged",
		true
	},
	[MessageName.CUSTOM_MARK_ICON_CHANGED] = {
		"onCustomMarkIconChanged",
		true
	},
	[MessageName.NPC_DUEL_STATE_CHANGED] = {
		"onNpcDuelStateChanged",
		true
	},
	[MessageName.ON_MAP_MARK_BIND_ENTITY] = {
		"onMapMarkBindEntity",
		true
	},
	[MessageName.ON_MAP_MARK_UNBIND_ENTITY] = {
		"onMapMarkUnbindEntity",
		true
	},
	[MessageName.PLAYER_DESTROY] = {
		"onPlayerDestroyed",
		true
	}
}

function HatredArrowTipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.width = self.view.arrowRegionRectTransform.sizeDelta.x or 3600
	self.height = self.view.arrowRegionRectTransform.sizeDelta.y or 2000

	local widthRatio = self.width / 3840
	local heightRatio = self.height / 2160

	self.ratioX = widthRatio * 0.5
	self.ratioY = heightRatio * 0.5
	self.questArrowComponent = QuestArrowTipComponent.new(self, self.view.transform)
	self.mapMarkTipComponent = MapMarkTipComponent.new(self, self.view.transform)
	self.normalTrack = NormalTrackComponent.new(self)
	self.hornInvite = HornInviteComponent.new(self, self.view.runAcrossRectTransform)
	self.fluteInvite = FluteInviteComponent.new(self, self.view.runAcrossRectTransform)
	self.maxArrowNum = SysConfigData.maxHatredArrowNum or 3
	self.dangerList = {}
	self.hatredInfoEntryList = {}

	for i = 1, self.maxArrowNum do
		self.hatredInfoEntryList[i] = {}
	end

	function self._lateUpdateFunc()
		self:updateDangerArrowPosition()
	end

	self.lastArrowCnt = 0

	for i = 1, self.maxArrowNum do
		self:loadDangerRes()
	end

	LuaUIUtils.setUIViewVisible(self.view.dangerRectTransform, false)

	local player = pg.pawn
	local behatredMap = player and player:getBehatredMap()

	if behatredMap ~= nil and table.getCount(behatredMap) > 0 then
		self:enableDangerTips(true)
	end
end

function HatredArrowTipCtrl:addListener()
	return
end

function HatredArrowTipCtrl:onShow()
	return
end

function HatredArrowTipCtrl:onPlayerDestroyed()
	if self.mapMarkTipComponent then
		self.mapMarkTipComponent:clearPlayerReferences()
	end
end

function HatredArrowTipCtrl:dismiss()
	self:clearDangerTimer()
	UICtrl.dismiss(self)
end

function HatredArrowTipCtrl:onDestroy()
	self:clearDangerTimer()
	self:destroyAllDangerInstances()

	for i = 1, self.maxArrowNum do
		self.hatredInfoEntryList[i] = nil
	end

	self.hatredInfoEntryList = nil

	UICtrl.onDestroy(self)

	self.normalTrack = nil
	self.questArrowComponent = nil
	self.mapMarkTipComponent = nil
	self.hornInvite = nil
	self.fluteInvite = nil
	self._lateUpdateFunc = nil
end

function HatredArrowTipCtrl:clearDangerTimer()
	if self.dangerTimer then
		pg.game.camera:removeLateUpdateTimer(self.dangerTimer)

		self.dangerTimer = nil
	end
end

function HatredArrowTipCtrl:startDangerTimer()
	self:clearDangerTimer()

	self.dangerTimer = pg.game.camera:addLateUpdateTimer(self._lateUpdateFunc)
end

function HatredArrowTipCtrl:loadDangerRes()
	if IsNil(self.view.dangerTransform.gameObject) then
		return
	end

	pg.global.resMgr:ResInstantiateAsync(self.view.dangerTransform.gameObject, function(gameObj, userData)
		if IsNil(gameObj) then
			return
		end

		if not self.dangerList then
			pg.global.resMgr:ResDestroyObject(gameObj)

			return
		end

		local arrow = {}

		arrow.obj = gameObj

		local objectReference = gameObj.transform:GetComponent("ObjectReference")

		arrow.uComp = objectReference:GetRefValue("dangerUComponent")
		arrow.imgArrowTrans = objectReference:GetRefValue("imgArrowRectTransform")
		arrow.arrowTrans = objectReference:GetRefValue("dangerRectTransform")

		self:hideDangerTip(arrow)
		table.insert(self.dangerList, arrow)
	end, self.view.transform.position, Quaternion.identity, self.view.markerListTransformLayer100.transform)
end

function HatredArrowTipCtrl:updateDangerArrowPosition()
	local num = self:getTopKCloestBehatredTargets()

	self:prepareDangerArrows(num or 0)

	if ToBool(num) then
		local player = pg.me
		local lockedActorId = player and player.lockedActorId or 0
		local hatredInfoList = self.hatredInfoEntryList

		for i = 1, num do
			local target = hatredInfoList[i].ent
			local arrow = self.dangerList[i]

			if arrow ~= nil then
				if lockedActorId == target.actorId then
					arrow.uComp:TryChangePage("ArrowState", 1)
				else
					arrow.uComp:TryChangePage("ArrowState", 0)
				end

				if Utils.isBoss(target) then
					arrow.uComp:TryChangePage("IconType", 1)
				else
					arrow.uComp:TryChangePage("IconType", 0)
				end

				LuaUIUtils.setArrowTipRtPosAndRot(arrow.arrowTrans, arrow.imgArrowTrans, target:getPosition(), self.ratioX, self.ratioY, -90)
			end
		end
	end
end

function HatredArrowTipCtrl:prepareDangerArrows(curArrowCnt)
	if curArrowCnt < self.lastArrowCnt then
		local delta = self.lastArrowCnt - curArrowCnt
		local startIndex = self.lastArrowCnt - delta + 1

		for i = startIndex, self.maxArrowNum do
			self:hideDangerTip(self.dangerList[i])
		end
	end

	self.lastArrowCnt = curArrowCnt
end

function HatredArrowTipCtrl:hideAllDangers()
	for _, arrow in ipairs(self.dangerList) do
		self:hideDangerTip(arrow)
	end
end

function HatredArrowTipCtrl:destroyAllDangerInstances()
	for i = #self.dangerList, 1, -1 do
		pg.global.resMgr:ResDestroyObject(self.dangerList[i].obj)

		self.dangerList[i] = nil
	end

	self.dangerList = nil
end

function HatredArrowTipCtrl:getTopKCloestBehatredTargets()
	local player = pg.pawn

	if not player then
		return nil
	end

	local hatredInfoList = self.hatredInfoEntryList

	for i = 1, self.maxArrowNum do
		hatredInfoList[i].ent = nil
	end

	local lockedActorId = pg.me.lockedActorId
	local behatredMap = player:getBehatredMap()
	local fogMaskRadius = pg.me.fogMaskRadius and pg.me.fogMaskRadius > 0 and pg.me.fogMaskRadius or 999
	local fogMaskRadiusSqr = fogMaskRadius * fogMaskRadius

	for id, _ in pairs(behatredMap) do
		local targetEnt = pg.getEntityByActorId(id)

		if targetEnt ~= nil and targetEnt.active then
			local entPos = targetEnt:getPosition()
			local distance = Utils.squareDist(player:getPosition(), entPos)

			if distance < fogMaskRadiusSqr and not self:checkTargetPosInViewport(entPos) then
				if targetEnt.actorId == lockedActorId then
					distance = -1
				end

				local insertPos = -1

				for i = 1, self.maxArrowNum do
					local info = hatredInfoList[i]

					if info.ent == nil then
						insertPos = i

						break
					elseif distance < info.dist then
						insertPos = i

						break
					end
				end

				if insertPos ~= -1 then
					for i = self.maxArrowNum - 1, insertPos, -1 do
						local nextEntry = hatredInfoList[i + 1]
						local curEntry = hatredInfoList[i]

						nextEntry.ent = curEntry.ent
						nextEntry.dist = curEntry.dist
					end

					hatredInfoList[insertPos].ent = targetEnt
					hatredInfoList[insertPos].dist = distance
				end
			end
		end
	end

	local validCnt = 0

	for i = 1, self.maxArrowNum do
		if hatredInfoList[i].ent ~= nil then
			validCnt = validCnt + 1
		end
	end

	return validCnt
end

function HatredArrowTipCtrl:checkTargetPosInViewport(pos)
	local x, y, z = pg.global.cameraMgr:GetTargetViewportPosXYZ(pos[1], pos[2], pos[3])

	if x >= 0 and x <= 1 and y >= 0 and y <= 1 and z > 0 then
		return true
	end

	return false
end

function HatredArrowTipCtrl:hideDangerTip(arrow)
	if arrow ~= nil then
		arrow.arrowTrans:SetLocalPositionEx(-9999, -9999, 0)
	end
end

function HatredArrowTipCtrl:isSameTrackTarget(posA, posB)
	return posA ~= nil and posB ~= nil and Vector3.SqrDistance(posA, posB) < self.SAME_TRACK_TARGET_SQR_DISTANCE
end

function HatredArrowTipCtrl:resolveTrackPriority(targetPos)
	if self.questArrowComponent and self.questArrowComponent:isTrackDisplayActiveAt(targetPos) then
		return self.TRACK_PRIORITY.QUEST
	end

	if self.normalTrack and self.normalTrack:isTrackDisplayActiveAt(targetPos) then
		return self.TRACK_PRIORITY.NORMAL_TRACK
	end

	return self.TRACK_PRIORITY.MAP_MARK
end

function HatredArrowTipCtrl:canShowTrack(priority, targetPos)
	return priority >= self:resolveTrackPriority(targetPos)
end

function HatredArrowTipCtrl:trackSingleEnt(info)
	if info == nil then
		return
	end

	local func = info.func
	local enable = info.enable

	if enable then
		if info.entityId ~= nil then
			self.normalTrack:setTrackTargetByEntityId(info.entityId, info.img, info.edgeOnly, info.edgeOnlyTopLogoComponent, info.sizeSmall)
		else
			self.normalTrack:setTrackTarget(func, info.img, info.edgeOnly, info.edgeOnlyTopLogoComponent, info.sizeSmall)
		end
	elseif info.entityId ~= nil then
		self.normalTrack:cancelTrackByEntityId(info.entityId)
	else
		self.normalTrack:cancelTrack(info.func)
	end
end

function HatredArrowTipCtrl:trackHornInviter(info)
	if not self.hornInvite or not info then
		return
	end

	local enable = info.enable

	if enable then
		self.hornInvite:trackTarget(info)
	else
		self.hornInvite:cancelTrack(info.id)
	end
end

function HatredArrowTipCtrl:trackFluteInviter(info)
	if not self.fluteInvite or not info then
		return
	end

	local enable = info.enable

	if enable then
		self.fluteInvite:trackTarget(info)
	else
		self.fluteInvite:cancelTrack(info.id)
	end
end

function HatredArrowTipCtrl:onTeammateViewChange()
	if pg.me.inTeammateView then
		for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
			if info.entityId ~= pg.me.id then
				self.mapMarkTipComponent:onAllyChanged({
					entryAdd = false,
					refEntityId = info.entityId
				})
			end
		end

		self.mapMarkTipComponent:onAllyChanged({
			entryAdd = true,
			refEntityId = pg.me.id
		})
	else
		self.mapMarkTipComponent:initAllyData()
	end
end

function HatredArrowTipCtrl:onBossTitleVisibleChanged(info)
	if not self.view then
		return
	end

	for i = 1, 6 do
		if self.view[string.format("markerListTransformLayer%s", i)] then
			self.view[string.format("markerListTransformLayer%s", i)].transform.localScale = info.visible and Vector3.zero or Vector3.one
		end
	end

	if self.view.markerListTransformLayer99 then
		self.view.markerListTransformLayer99.transform.localScale = info.visible and Vector3.zero or Vector3.one
	end
end

function HatredArrowTipCtrl:enableDangerTips(enable)
	if not self.view then
		return
	end

	if enable and not pg.game.setting:getHideAllHudArrowType() then
		self:startDangerTimer()
	else
		self:hideAllDangers()
		self:clearDangerTimer()
	end
end

function HatredArrowTipCtrl:refreshAllArrowState()
	self:enableDangerTips(false)
	self.questArrowComponent:refreshAllQuestArrowHideState()
	self.mapMarkTipComponent:refreshAllArrowHideState()
	self.normalTrack:refreshAllArrowHideState()
end

function HatredArrowTipCtrl:onQuestStateChange(data)
	self.questArrowComponent:onQuestStateChange(data)
end

function HatredArrowTipCtrl:onQuestObjectiveFinished(data)
	self.questArrowComponent:onQuestObjectiveFinished(data)
end

function HatredArrowTipCtrl:onQuestTabSwitch(data)
	self.questArrowComponent:onQuestTabSwitch(data)
end

function HatredArrowTipCtrl:onQuestTraceChange(data)
	self.questArrowComponent:onQuestTraceChange(data)
end

function HatredArrowTipCtrl:onQuestRunStateChange(data)
	self.questArrowComponent:onQuestRunStateChange(data)
end

function HatredArrowTipCtrl:onSceneLoaded()
	self.questArrowComponent:onSceneLoaded()
	self.mapMarkTipComponent:onSceneLoaded()
end

function HatredArrowTipCtrl:onAllyChanged(data)
	self.mapMarkTipComponent:onAllyChanged(data)
end

function HatredArrowTipCtrl:onTeamMarkChange()
	if self.mapMarkTipComponent then
		self.mapMarkTipComponent:onTeamMarkChange()
	end
end

function HatredArrowTipCtrl:onTeamMarkTrackChange()
	if self.mapMarkTipComponent then
		self.mapMarkTipComponent:onTeamMarkTrackChange()
	end
end

function HatredArrowTipCtrl:onDynamicMarkStatusChanged(info)
	if self.mapMarkTipComponent then
		self.mapMarkTipComponent:onDynamicMarkStatusChanged(info)
	end
end

function HatredArrowTipCtrl:onCustomMarkIconChanged(info)
	if self.mapMarkTipComponent then
		self.mapMarkTipComponent:onCustomMarkIconChanged(info)
	end
end

function HatredArrowTipCtrl:onNpcDuelStateChanged(info)
	if self.mapMarkTipComponent then
		self.mapMarkTipComponent:onDuelStateChanged(info)
	end
end

function HatredArrowTipCtrl:onMapMarkBindEntity(info)
	if self.mapMarkTipComponent then
		self.mapMarkTipComponent:onMapMarkBindEntity(info)
	end
end

function HatredArrowTipCtrl:onMapMarkUnbindEntity(info)
	if self.mapMarkTipComponent then
		self.mapMarkTipComponent:onMapMarkUnbindEntity(info)
	end
end

return HatredArrowTipCtrl
