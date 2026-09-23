-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PlayerEnhanceScene.lua

local ClientConst = require("Const.ClientConst")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local PlayerEnhanceScene = Class.LightClass("PlayerEnhanceScene", UISceneBase)

PlayerEnhanceScene.SCENE_MODE = {
	MAIN = 0,
	EQUIP_EXPLORE = 2,
	EQUIP_COMBATS = 1
}

function PlayerEnhanceScene:onStart()
	local root = self.scene.transform:Find("Global")

	self.objectReference = root:GetComponent("ObjectReference")
	self.EntranceLoopPlayableDirector = self.objectReference:GetRefValue("EntranceLoopPlayableDirector")
	self.CombatLoopPlayableDirector = self.objectReference:GetRefValue("CombatLoopPlayableDirector")
	self.ExploreLoopPlayableDirector = self.objectReference:GetRefValue("ExploreLoopPlayableDirector")
	self.EntranceToExplorePlayableDirector = self.objectReference:GetRefValue("EntranceToExplorePlayableDirector")
	self.EntranceToCombatPlayableDirector = self.objectReference:GetRefValue("EntranceToCombatPlayableDirector")
	self.ExploreToEntrancePlayableDirector = self.objectReference:GetRefValue("ExploreToEntrancePlayableDirector")
	self.CombatToEntrancePlayableDirector = self.objectReference:GetRefValue("CombatToEntrancePlayableDirector")
	self.ExploreToCombatPlayableDirector = self.objectReference:GetRefValue("ExploreToCombatPlayableDirector")
	self.CombatToExplorePlayableDirector = self.objectReference:GetRefValue("CombatToExplorePlayableDirector")
	self.MenuCharIdleToEntrancePlayableDirector = self.objectReference:GetRefValue("MenuCharIdleToEntrancePlayableDirector")
	self.girlTransformRoot = self.objectReference:GetRefValue("girlTransformRoot")
	self.pTLAvatarGirlUIEmblemShowPlayableDirector = self.objectReference:GetRefValue("pTLAvatarGirlUIEmblemShowPlayableDirector")
	self.GIRL_TIMELINE_MAP = {
		self.EntranceLoopPlayableDirector,
		self.CombatLoopPlayableDirector,
		self.ExploreLoopPlayableDirector,
		self.EntranceToCombatPlayableDirector,
		self.EntranceToExplorePlayableDirector,
		self.CombatToEntrancePlayableDirector,
		self.ExploreToEntrancePlayableDirector,
		self.CombatToExplorePlayableDirector,
		self.ExploreToCombatPlayableDirector,
		self.MenuCharIdleToEntrancePlayableDirector,
		self.pTLAvatarGirlUIEmblemShowPlayableDirector
	}
	self.loadTimeout = 2
	self.operationTmMap = self.GIRL_TIMELINE_MAP
	self.modelRoot = self.girlTransformRoot

	self:createPlayer()
end

function PlayerEnhanceScene:initDefaultSceneMode(firstEnter)
	self.firstEnter = firstEnter
	self.operationTmMap = self.GIRL_TIMELINE_MAP
	self.modelRoot = self.girlTransformRoot
	self.mode = self.SCENE_MODE.MAIN
end

function PlayerEnhanceScene:createPlayer()
	local entity = self:copyMainPlayer(87728445)

	entity.eModel:SetFacialStubEnabled(Const.COMPONENT_IDX_PLAYABLE, false)
	entity.eModel:SetTransformParent(self.modelRoot, false)
	entity.eModel:SetTransformLocalPosition()
	entity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
end

function PlayerEnhanceScene:onAllEntityLoaded()
	local entity = self:getEntity(pg.me.uid)

	entity:disableDefaultLookAtComp(true)
	entity:enableLookAtCameraCenter(false)

	for _, v in pairs(self.GIRL_TIMELINE_MAP) do
		v:CheckGroupTrackCondition()
		v.gameObject:SetActiveEx(false)
	end

	self.entityLoaded = true

	if self.needPlayEnterTimeline then
		self.needPlayEnterTimeline = nil

		self:_playEnterTimelineInner(self.afterEnterCallback)

		self.afterEnterCallback = nil
	end
end

function PlayerEnhanceScene:playEnterTimeline(afterEnterCallback)
	if not self.entityLoaded then
		self.needPlayEnterTimeline = true
		self.afterEnterCallback = afterEnterCallback

		return
	end

	self:_playEnterTimelineInner(afterEnterCallback)
end

function PlayerEnhanceScene:_playEnterTimelineInner(afterEnterCallback)
	if self.operationTmMap == nil then
		if afterEnterCallback then
			afterEnterCallback()
		end

		return
	end

	local oneTimeline = self.firstEnter and self.operationTmMap[11] or self.operationTmMap[10]
	local oneTime = self:playTimeLine(oneTimeline, self.operationTmMap[1])

	if afterEnterCallback then
		self:startTimer(afterEnterCallback, oneTime * 0.5 + 0.7)
	end
end

function PlayerEnhanceScene:switch2_MAIN_Mode()
	local curTm
	local nextTm = self.operationTmMap[1]

	if self.mode == self.SCENE_MODE.MAIN then
		return
	elseif self.mode == self.SCENE_MODE.EQUIP_COMBATS then
		curTm = self.operationTmMap[6]
	elseif self.mode == self.SCENE_MODE.EQUIP_EXPLORE then
		curTm = self.operationTmMap[7]
	else
		curTm = self.operationTmMap[10]
	end

	self:playTimeLine(curTm, nextTm)

	self.mode = self.SCENE_MODE.MAIN
end

function PlayerEnhanceScene:switch2_EQUIP_COMBATS_Mode()
	local curTm
	local nextTm = self.operationTmMap[2]

	if self.mode == self.SCENE_MODE.EQUIP_COMBATS then
		return
	elseif self.mode == self.SCENE_MODE.MAIN then
		curTm = self.operationTmMap[4]
	elseif self.mode == self.SCENE_MODE.EQUIP_EXPLORE then
		curTm = self.operationTmMap[9]
	end

	self:playTimeLine(curTm, nextTm)

	self.mode = self.SCENE_MODE.EQUIP_COMBATS
end

function PlayerEnhanceScene:switch2_EQUIP_EXPLORE_Mode()
	local curTm
	local nextTm = self.operationTmMap[3]

	if self.mode == self.SCENE_MODE.EQUIP_EXPLORE then
		return
	elseif self.mode == self.SCENE_MODE.EQUIP_COMBATS then
		curTm = self.operationTmMap[8]
	elseif self.mode == self.SCENE_MODE.MAIN then
		curTm = self.operationTmMap[5]
	end

	self:playTimeLine(curTm, nextTm)

	self.mode = self.SCENE_MODE.EQUIP_EXPLORE
end

function PlayerEnhanceScene:playTimeLine(tm1, tm2)
	tm1.gameObject:SetActiveEx(true)
	tm1:Play()

	if self.curTm then
		self.curTm.gameObject:SetActiveEx(false)
	end

	self.curTm = tm1

	if self.curTimer then
		self:killTimer(self.curTimer)
	end

	local fadeTime = tm1.playableAsset.duration / Time.timeScale

	self.curTimer = self:startTimer(function()
		tm1:Stop()
		tm1.gameObject:SetActiveEx(false)
		tm2.gameObject:SetActiveEx(true)
		tm2:Play()

		self.curTm = tm2
	end, fadeTime)

	return fadeTime
end

function PlayerEnhanceScene:setPlayerActive(active)
	if IsNil(self.scene) then
		return
	end

	self.modelRoot.gameObject:SetActiveEx(active)
end

function PlayerEnhanceScene:refreshModelView()
	self:removeEntity(pg.me.uid)
	self:createPlayer()
end

function PlayerEnhanceScene:onDestroy()
	self.playerEnt = nil
	self.GIRL_TIMELINE_MAP = nil
	self.BOY_TIMELINE_MAP = nil
	self.entityLoaded = nil
	self.needPlayEnterTimeline = nil

	pg.global.cameraMgr.vcManager:RemoveSubCameraGroup(self.name)
end

return PlayerEnhanceScene
