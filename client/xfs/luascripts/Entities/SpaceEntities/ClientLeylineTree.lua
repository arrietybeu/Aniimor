-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientLeylineTree.lua

local class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local AddressDataConst = require("Const.AddressDataConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientConst = require("Const.ClientConst")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local LeylineTreeData = require("Data.leylinetree_data")
local SceneLeylineTreeTemplateData = require("Data.scene_leylineTree_template_data")
local MapAreaConfigData = require("Data.map_area_config_data")
local SysConfigData = require("Data.sys_config_data")
local UIConst = require("Const.UIConst")
local PuppetData = require("Data.puppet_data")
local Bitset = require("Common.Bitset")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local ClientLeylineTree = class.Class("ClientLeylineTree", ClientModelEntity)
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientNpcInteractComponent = require("Entities.SpaceEntities.CommonComponent.ClientNpcInteractComponent")
local ClientSpecialStateRecoverComponent = require("Entities.SpaceEntities.CommonComponent.ClientSpecialStateRecoverComponent")
local Components = {
	ClientAoiComponent,
	ClientModelComponent,
	ClientAuthorityComponent,
	ClientSpecialStateRecoverComponent,
	ClientNpcInteractComponent
}
local EventConst = require("Const.EventConst")

ClientLeylineTree.SHADOW_MISC = {
	[200011] = {
		SHADOW_BOUNDS_CENTER_OFFSET = {
			-1228.2,
			132.9,
			915.5
		},
		SHADOW_BOUNDS_SIZE = {
			57.61152,
			96.51003,
			68.67215
		}
	}
}

class.AddComponents(ClientLeylineTree, Components)

function ClientLeylineTree:ctor(entityId)
	ClientLeylineTree.super.ctor(self, entityId)

	self.pos1 = Vector3(-1235.489990234375, 103.30000305175781, 917.1900024414062)
	self.pos2 = Vector3(-1224.27001953125, 166.6300048828125, 893.5)
	self.rot1 = Quaternion.New(0, -0.7777629494667053, 0, 0.6285577416419983)
	self.rot2 = Quaternion.New(0.06244966760277748, -0.03216313198208881, -0.05291251838207245, 0.9961254596710205)
	self.scale1 = Vector3(2, 2, 2)
	self.inited = false
end

function ClientLeylineTree:init(bdict)
	ClientLeylineTree.super.init(self, bdict)

	self.templateId = bdict.templateId

	local maxLevel = #LeylineTreeData[bdict.templateId]

	self.maxLevel = maxLevel
	self.entityCanMove = false

	return true
end

function ClientLeylineTree:onEnterSpace()
	pg.space:addLeylineTreeMap(self.id, self.templateId)

	function self.onMapAreaUnlockEvent(areaName)
		self:onMapAreaEvent(areaName)
	end

	pg.global.eventEmitter:addEventListener(EventConst.ON_MAP_AREA_UNLOCK, self.onMapAreaUnlockEvent)
end

function ClientLeylineTree:refreshAppearance()
	ClientLeylineTree.super.refreshAppearance(self)
	self:createLeylineTreeModel()
end

function ClientLeylineTree:_beginShadowPartLoad()
	self._shadowPartLoadsPending = (self._shadowPartLoadsPending or 0) + 1
end

function ClientLeylineTree:_onShadowPartLoaded()
	if self._shadowPartLoadsPending then
		self._shadowPartLoadsPending = self._shadowPartLoadsPending - 1

		if self._shadowPartLoadsPending > 0 then
			return
		end

		self._shadowPartLoadsPending = nil
	end

	self:refreshShadowBounds()
end

function ClientLeylineTree:calcWorldBounds()
	if not ClientLeylineTree.SHADOW_MISC[self.templateId] then
		return Vector3.constZero, Vector3.constZero
	end

	local center = Vector3(ClientLeylineTree.SHADOW_MISC[self.templateId].SHADOW_BOUNDS_CENTER_OFFSET[1], ClientLeylineTree.SHADOW_MISC[self.templateId].SHADOW_BOUNDS_CENTER_OFFSET[2], ClientLeylineTree.SHADOW_MISC[self.templateId].SHADOW_BOUNDS_CENTER_OFFSET[3])
	local size = Vector3(ClientLeylineTree.SHADOW_MISC[self.templateId].SHADOW_BOUNDS_SIZE[1], ClientLeylineTree.SHADOW_MISC[self.templateId].SHADOW_BOUNDS_SIZE[2], ClientLeylineTree.SHADOW_MISC[self.templateId].SHADOW_BOUNDS_SIZE[3])

	return center, size
end

function ClientLeylineTree:refreshShadowBounds()
	local center, size = self:calcWorldBounds()

	pg.global.gameMgr:RefreshShadowInBounds(center.x, center.y, center.z, size.x, size.y, size.z)
end

function ClientLeylineTree:createLeylineTreeModel()
	if not self.eModel then
		return
	end

	if self.inited then
		return
	end

	self:setModelLayer(ClientConst.LayerDefine.LAYER_ENTITY)

	local info = {
		prefabResID = PuppetData[self.templateId].prefabResID
	}
	local modelView = self.eModel.modelModelView
	local eModel = self.eModel

	self._shadowPartLoadsPending = nil

	self:_beginShadowPartLoad()

	self.treeBaseLoader = ResLoader.new()

	self.treeBaseLoader:load(AddressDataConst.LEYLINETREE_BASE_MODEL, function(treeBaseGameObject)
		eModel:AttachGameObjectToPositionAgentEx(treeBaseGameObject, self.pos1.x, self.pos1.y, self.pos1.z, self.rot1.x, self.rot1.y, self.rot1.z, self.rot1.w)
		self:_onShadowPartLoaded()
	end)

	if self.level < 0 then
		self:_beginShadowPartLoad()

		self.treeFlowerLoader = ResLoader.new()

		self.treeFlowerLoader:load(AddressDataConst.LEYLINETREE_SUB_MODEL, function(treeFlowerGameObject)
			eModel:AttachGameObjectToPositionAgentEx(treeFlowerGameObject, self.pos2.x, self.pos2.y, self.pos2.z, self.rot2.x, self.rot2.y, self.rot2.z, self.rot2.w, self.scale1.x, self.scale1.y, self.scale1.z, true)
			self:_onShadowPartLoaded()
		end)
	end

	self:_beginShadowPartLoad()

	function modelView.luaOnModelRefreshFinshed()
		self.gameObject = self.eModel.modelSkeletonView.skeletonRoot.gameObject
		self.animator = self.gameObject.transform:GetChild(0):GetComponent("Animator")
		self.objectReference = self.gameObject:GetComponent("ObjectReference")

		local beforeVfx = self.objectReference:GetRefValue("beforeVfx")
		local afterVfx = self.objectReference:GetRefValue("afterVfx")

		if self.level > -1 then
			self.animator:Play("openIdle")
			beforeVfx.gameObject:SetActiveEx(false)
			afterVfx.gameObject:SetActiveEx(true)
		else
			self.animator:Play("idle")
			beforeVfx.gameObject:SetActiveEx(true)
			afterVfx.gameObject:SetActiveEx(false)
		end

		local createPlentyCount = pg.me.leylineTreeInfoMap[self.templateId].createPlentyCount
		local aniMgr = self.gameObject:GetComponent("LeylineTreeAnimationManager")

		if createPlentyCount ~= -1 then
			aniMgr.curStage = 1

			self:playStageAnimation(1)
		else
			aniMgr.curStage = 2

			self:playStageAnimation(2)
		end

		if self.level >= 0 and self.level < SysConfigData.LEYLINETREE_CREATEPLENTY_LEVEL then
			self:phaseEff(2)
		elseif self.level >= SysConfigData.LEYLINETREE_CREATEPLENTY_LEVEL and self.level < self.maxLevel then
			self:phaseEff(3)
		elseif self.level >= self.maxLevel then
			self:phaseEff(4)
		end

		self:_onShadowPartLoaded()
	end

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, info)
	modelView:RefreshModels()
	self.eModel:SetModelVisible(true)

	self.inited = true
end

function ClientLeylineTree:clearAllPhase()
	for i = 1, 4 do
		local phaseName = "treePhase" .. i .. "Loader"

		if self[phaseName] then
			self[phaseName]:destroy()

			self[phaseName] = nil
		end
	end
end

function ClientLeylineTree:destroy()
	ClientLeylineTree.super.destroy(self)
	pg.space:removeLeylineTreeMap(self.templateId)
	pg.global.eventEmitter:removeEventListener(EventConst.ON_MAP_AREA_UNLOCK, self.onMapAreaUnlockEvent)

	if self.treeBaseLoader then
		self.treeBaseLoader:destroy()

		self.treeBaseLoader = nil
	end

	if self.treeFlowerLoader then
		self.treeFlowerLoader:destroy()

		self.treeFlowerLoader = nil
	end

	self:clearAllPhase()

	self._shadowPartLoadsPending = nil
	self.animator = nil
	self.objectReference = nil
	self.gameObject = nil
end

function ClientLeylineTree:preDestroy()
	local modelView = self.eModel and self.eModel.modelModelView

	if modelView then
		modelView.luaOnModelRefreshFinshed = nil
	end

	ClientLeylineTree.super.preDestroy(self)
end

function ClientLeylineTree:playStageAnimation(stage, quickParticleLifeTime, shrinkParticleDelayTime, shrinkParticleLifeTime, lightBallShowDelay, stage3FinishCb)
	if not self.gameObject then
		return
	end

	local aniMgr = self.gameObject:GetComponent("LeylineTreeAnimationManager")

	if quickParticleLifeTime and shrinkParticleDelayTime and shrinkParticleLifeTime and stage3FinishCb then
		aniMgr:PlayStageAnimation(stage, quickParticleLifeTime, shrinkParticleDelayTime, shrinkParticleLifeTime, lightBallShowDelay, stage3FinishCb)
	else
		aniMgr:PlayStageAnimation(stage)
	end
end

function ClientLeylineTree:getConfigData()
	return PuppetData[self.templateId] or {}
end

function ClientLeylineTree:on_level_changed(oldv, newv)
	if not self.gameObject then
		return
	end

	if oldv == -1 and newv == 0 then
		self:refreshShadowBounds()
		self:playUnlockDialogueGraph(function()
			if self.animator then
				self.animator:Play("open")
			end

			if self.objectReference then
				local beforeVfx = self.objectReference:GetRefValue("beforeVfx")
				local afterVfx = self.objectReference:GetRefValue("afterVfx")

				beforeVfx.gameObject:SetActiveEx(false)
				afterVfx.gameObject:SetActiveEx(true)
			end

			if self.treeFlowerLoader then
				self.treeFlowerLoader:destroy()

				self.treeFlowerLoader = nil
			end
		end)
	elseif newv == SysConfigData.LEYLINETREE_CREATEPLENTY_LEVEL then
		self:phaseEff(3)
	elseif newv == self.maxLevel then
		self:phaseEff(4)
	end
end

function ClientLeylineTree:phaseEff(index)
	self:clearAllPhase()

	local phaseName = "treePhase" .. index .. "Loader"

	self[phaseName] = ResLoader.new()

	local eModel = self.eModel

	self:_beginShadowPartLoad()
	self[phaseName]:load(AddressDataConst["LEYLINETREE_EFF_" .. index], function(go)
		eModel:AttachGameObjectToPositionAgentEx(go, self.pos2.x, self.pos2.y, self.pos2.z, self.rot2.x, self.rot2.y, self.rot2.z, self.rot2.w)
		self:_onShadowPartLoaded()
	end)
end

function ClientLeylineTree:phaseLevelUp()
	if self.phaseLevelUpLoader then
		self.phaseLevelUpLoader:destroy()

		self.treeFlowerLoader = nil
	end

	self.phaseLevelUpLoader = ResLoader.new()

	local eModel = self.eModel

	self:_beginShadowPartLoad()
	self.phaseLevelUpLoader:load(AddressDataConst.LEYLINETREE_EFF_LEVEL_UP, function(go)
		eModel:AttachGameObjectToPositionAgentEx(go, self.pos2.x, self.pos2.y, self.pos2.z, self.rot2.x, self.rot2.y, self.rot2.z, self.rot2.w)
		self:_onShadowPartLoaded()
	end)
end

function ClientLeylineTree:playUnlockDialogueGraph(cb)
	if self.ownerId ~= pg.me.id then
		return
	end

	self:phaseEff(2)
	self:onPopupToastTips()

	local dialogueGraphId
	local largeAreaIdData = SceneLeylineTreeTemplateData[self.templateId]

	if largeAreaIdData then
		local largeAreaId = largeAreaIdData.areaId
		local dialogueGraphData = MapAreaConfigData[largeAreaId]

		if dialogueGraphData then
			dialogueGraphId = dialogueGraphData.dialogueGraph
		end
	end

	if dialogueGraphId then
		pg.game.dialogue:playDialogueGraph(dialogueGraphId, function()
			if cb then
				cb()
			end

			self:onEventTrigger()
		end)
	end
end

function ClientLeylineTree:onEventTrigger()
	local markInfo = pg.game.map:getMarkInfo(pg.me.curTreeMarkId)

	if markInfo and markInfo.largeAreaId then
		pg.game.map.curUnlockedLargeAreaId = markInfo.largeAreaId
	end

	pg.global.ui:open(UIConst.UI_ID_MAP, {
		isUnlockArea = true,
		onMarkLoaded = function(spawnerId, spawnerTable)
			if spawnerId == pg.me.curTreeMarkId then
				pg.me.curTreeMarkId = nil

				pg.global.ui.map:addActivatedVX(spawnerId, true, true)
			end
		end
	}, function()
		return
	end)
end

function ClientLeylineTree:onPopupToastTips()
	if not self.stack then
		return
	end

	while #self.stack > 0 do
		local unlockInfo = table.remove(self.stack, 1)

		pg.global.ui.tips:mapAreaUnlockTip(unlockInfo)
	end
end

function ClientLeylineTree:onMapAreaEvent(areaName)
	local unlockInfo = {
		unlockName = areaName or ""
	}

	self.stack = self.stack or {}

	table.insert(self.stack, unlockInfo)
end

function ClientLeylineTree:queryModelVisible()
	if Bitset.any(ClientConst.PUPPET_VISIBLE_FLAG) then
		return true, false
	end

	return ClientLeylineTree.super.queryModelVisible(self)
end

return ClientLeylineTree
