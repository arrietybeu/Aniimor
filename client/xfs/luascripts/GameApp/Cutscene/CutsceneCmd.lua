-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Cutscene\\CutsceneCmd.lua

local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local TimelineDataInfo = require("Data.timeline_info_data")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local CutsceneCmd = Class.LightClass("CutsceneCmd")

function CutsceneCmd:ctor(id, name, resId, position, rotation, extraData)
	self.id = id
	self.name = name
	self.defaultResId = resId
	self.resId = self:getCurPlatformResId(self.defaultResId)
	self.playState = ClientConst.CUTSCENE_STATE_NONE
	self.endCallback = nil
	self.bindSlots = {}
	self.virtualEntities = {}
	self.extraData = extraData or {}
	self.position = position or Vector3.zero
	self.rotation = rotation or Quaternion.identity
	self.cutscene = pg.global.cutsceneMgr:CreateCutscene(self.name, self.resId, self, self.position, self.rotation, extraData and extraData.isSetActiveNoRebind or false)

	local applySoundListener = true

	if self.extraData.applySoundListener ~= nil then
		applySoundListener = self.extraData.applySoundListener
	end

	self.cutscene:SetApplySoundListener(applySoundListener)

	local info = TimelineDataInfo[self.defaultResId]

	if info ~= nil then
		self.isDialogueCutscene = true

		if info.updateShadow == 1 then
			self.cutscene.enableUpdateShadow = true
		end

		if info.disableShadow == 1 then
			self.cutscene.isDisableShadow = true
		end
	end
end

function CutsceneCmd:canBeInterrupted()
	if self.extraData.dontDestroy == true then
		return false
	end

	return self.isDialogueCutscene == true and self.playState == ClientConst.CUTSCENE_STATE_PLAY
end

function CutsceneCmd:getCurPlatformResId(defaultResId)
	local info = TimelineDataInfo[defaultResId]

	if info == nil then
		return defaultResId
	end

	local curPlatform = ClientUtils.getAdaptionPlatform()

	if curPlatform == UIConst.PLATFORM.Mobile then
		return info.mobileResId or defaultResId
	end

	return defaultResId
end

function CutsceneCmd:destroy()
	if self.playState == ClientConst.CUTSCENE_STATE_DESTROY then
		return
	end

	if self.playState ~= ClientConst.CUTSCENE_STATE_STOP then
		self:onTimelineEnd()
	end

	self.playState = ClientConst.CUTSCENE_STATE_DESTROY

	pg.global.cutsceneMgr:DestroyCutscene(self.cutscene)
	self:destroyAllVirtualEntities()
	pg.game.cutscene:destroyCutscene(self)

	self.cutscene = nil
	self.bindSlots = {}
	self.endCallback = nil
end

function CutsceneCmd:setBindSlot(slotKey, ent)
	self.bindSlots[slotKey] = ent
end

function CutsceneCmd:getBindSlot(slotKey)
	local var = self.bindSlots[slotKey]

	return var
end

function CutsceneCmd:createVirtualEntity(refVirtualEntity)
	local virtualEnt = ClientSimpleVirtualEntity.new()

	virtualEnt.isCutsceneVirtualEntity = true

	local initInfo = {
		isIgnoreEffectLod = true,
		gender = self.extraData and self.extraData.gender or nil
	}

	virtualEnt:init(initInfo)
	virtualEnt:postInit(initInfo)
	virtualEnt:start()
	virtualEnt:setModelLayer(ClientConst.LayerDefine.LAYER_CUTSCENE)

	if refVirtualEntity and refVirtualEntity.parentTransform then
		virtualEnt.eModel:SetTransformParent(refVirtualEntity.parentTransform)
	else
		virtualEnt.eModel:SetTransformParent(self.cutscene.rootObject.transform)
	end

	virtualEnt:setDisableEffectLod(true)
	virtualEnt:setLodTickEnable(Const.LOD_TICK_KEY.VIRTUAL_ENT, false)
	virtualEnt:setRendererLod(0)
	virtualEnt.eModel:SetTransformLocalPosition()
	table.insert(self.virtualEntities, virtualEnt)

	return virtualEnt
end

function CutsceneCmd:destroyVirtualEntity(virtualEntity)
	for i, virtualEnt in ipairs(self.virtualEntities) do
		if virtualEnt == virtualEntity then
			ClientUtils.safeDestroy(virtualEnt)
			table.remove(self.virtualEntities, i)

			break
		end
	end
end

function CutsceneCmd:destroyAllVirtualEntities()
	for i, virtualEnt in ipairs(self.virtualEntities) do
		ClientUtils.safeDestroy(virtualEnt)
	end

	self.virtualEntities = {}
end

function CutsceneCmd:createRefVirtualEntity(refVirtualEntity)
	local bindKey = refVirtualEntity.slotKey or 0
	local bindParam = refVirtualEntity.slotParam or 0
	local isAsync = refVirtualEntity.isAsyncCreate

	isAsync = true

	local virtualEntity = self:createVirtualEntity(refVirtualEntity)

	refVirtualEntity.luaVirtualEntity = virtualEntity
	refVirtualEntity.virtualEntity = virtualEntity.eModel

	local bindCallback = self.extraData.bindCallback
	local isLoadSync = false

	if bindCallback then
		isLoadSync = bindCallback(self, virtualEntity, bindKey, bindParam, isAsync)
	end

	if not isLoadSync or virtualEntity.isModelLoaded then
		refVirtualEntity:OnVirtualEntityPrepared()
	else
		function virtualEntity.cutsceneLoadCallback(virtualEnt)
			refVirtualEntity:OnVirtualEntityPrepared()
		end
	end
end

function CutsceneCmd:createTrackRefVirtualEntity(virtualEntityData)
	local bindEntity = self.extraData.bindEntity
	local bindSlotKey = self.extraData.bindSlotKey
	local canBindExternalEntity = bindEntity and NotNil(bindEntity.eModel) and (bindSlotKey == nil or bindSlotKey == virtualEntityData.slotKey) and (bindSlotKey ~= nil or not self.hasBoundExternalEntity)

	if canBindExternalEntity then
		self.hasBoundExternalEntity = true

		self:setBindSlot(virtualEntityData.slotKey, bindEntity.eModel)

		local eModel = bindEntity.eModel
		local modelView = eModel.modelView

		if NotNil(modelView) and modelView:IsAnimatorRead() then
			virtualEntityData.OnVirtualEntityPrepared()
		else
			bindEntity.onAnimatorReadyExtraCallback = bindEntity.onAnimatorReadyExtraCallback or {}

			table.insert(bindEntity.onAnimatorReadyExtraCallback, function()
				if not self:isDestroyed() and virtualEntityData.OnVirtualEntityPrepared then
					virtualEntityData.OnVirtualEntityPrepared()
				end
			end)
		end

		return eModel
	end

	local virtualEntity = self:createTargetVirtualEntity(virtualEntityData)

	return virtualEntity and virtualEntity.eModel
end

function CutsceneCmd:createPlayerMirrorEntity(refVirtualEntity)
	local virtualData = {
		syncLoad = true,
		copyEntity = pg.me,
		position = refVirtualEntity.position,
		rotation = refVirtualEntity.rotation
	}
	local mirrorEnt = ClientVirtualEntityUtils.copySimpleVirtualPlayerFrom(virtualData)

	if mirrorEnt then
		mirrorEnt.eModel:SetTransformParent(refVirtualEntity.rootObject or self.cutscene.cutsceneRoot.transform)
		mirrorEnt.eModel:SetTransformLocalPosition()
		mirrorEnt.eModel:SetTransformLocalRotation(0, 0, 0, 1)
		mirrorEnt.eModel:SetTransformLocalScale()
		table.insert(self.virtualEntities, mirrorEnt)
	end

	return mirrorEnt
end

function CutsceneCmd:createTargetVirtualEntity(virtualEntityData)
	local virtualEntity

	if virtualEntityData.entityType == "PlayerMirror" or virtualEntityData.entityType == "VirtualMainPlayer" then
		virtualEntity = self:createPlayerMirrorEntity(virtualEntityData)
	elseif virtualEntityData.entityType == "NPC" or virtualEntityData.entityType == "VirtualPuppet" then
		virtualEntity = self:createNpcVirtualEntity(virtualEntityData)
	elseif virtualEntityData.entityType == "PlayerPet" or virtualEntityData.entityType == "VirtualMainPlayerPet" then
		virtualEntity = self:createPlayerPetVirtualEntity(virtualEntityData)
	end

	if virtualEntity ~= nil then
		virtualEntity:setLodTickEnable(Const.LOD_TICK_KEY.VIRTUAL_ENT, false)
		virtualEntity:setRendererLod(0)
		virtualEntity:setDisableEffectLod(true)
		self:setBindSlot(virtualEntityData.slotKey, virtualEntity.eModel)

		if NotNil(virtualEntity.eModel.modelView) and not virtualEntity.eModel.modelView:IsAnimatorRead() then
			function virtualEntity.onAnimatorReadyCallback()
				if virtualEntityData.OnVirtualEntityPrepared then
					virtualEntityData.OnVirtualEntityPrepared()
				end
			end
		elseif virtualEntityData.OnVirtualEntityPrepared then
			virtualEntityData.OnVirtualEntityPrepared()
		end
	elseif virtualEntityData.OnVirtualEntityPrepared then
		virtualEntityData.OnVirtualEntityPrepared()
	end

	return virtualEntity
end

function CutsceneCmd:createNpcVirtualEntity(refVirtualEntity)
	local virtualData = {
		syncLoad = true,
		templateId = refVirtualEntity.slotParam,
		position = refVirtualEntity.position,
		rotation = refVirtualEntity.rotation
	}
	local virtualEnt = ClientVirtualEntityUtils.createSimpleVirtualNpc(virtualData)

	if virtualEnt then
		virtualEnt.eModel:SetTransformParent(refVirtualEntity.rootObject or self.cutscene.cutsceneRoot.transform)
		virtualEnt.eModel:SetTransformLocalPosition()
		virtualEnt.eModel:SetTransformLocalRotation(0, 0, 0, 1)
		virtualEnt.eModel:SetTransformLocalScale()
		table.insert(self.virtualEntities, virtualEnt)
	end

	return virtualEnt
end

function CutsceneCmd:createPlayerPetVirtualEntity(refVirtualEntity)
	local myCurPet = pg.me:getCurPetEntity()

	if myCurPet == nil then
		return
	end

	local virtualEnt = ClientVirtualEntityUtils.createPetVirtualEntityWithPetId(myCurPet.id, true)

	if virtualEnt then
		virtualEnt.eModel:SetTransformParent(refVirtualEntity.rootObject or self.cutscene.cutsceneRoot.transform)
		virtualEnt.eModel:SetTransformLocalPosition()
		virtualEnt.eModel:SetTransformLocalRotation(0, 0, 0, 1)
		virtualEnt.eModel:SetTransformLocalScale()
		table.insert(self.virtualEntities, virtualEnt)
	end

	return virtualEnt
end

function CutsceneCmd:destroyRefVirtualEntity(refVirtualEntity)
	local virtualEntity = refVirtualEntity.luaVirtualEntity

	if virtualEntity then
		self:destroyVirtualEntity(virtualEntity)
	end
end

function CutsceneCmd:isDestroyed()
	return self.playState == ClientConst.CUTSCENE_STATE_DESTROY
end

function CutsceneCmd:isPlaying()
	return self.playState == ClientConst.CUTSCENE_STATE_PLAY
end

function CutsceneCmd:setKeepTrans(keepTrans)
	if self.cutscene then
		self.cutscene.keepTrans = keepTrans
	end
end

function CutsceneCmd:preload()
	if self.cutscene then
		self.cutscene:Preload()

		self.playState = ClientConst.CUTSCENE_STATE_READY
	end
end

function CutsceneCmd:preloadAsync(callback)
	if self.cutscene then
		self.cutscene:AsyncPreload(function()
			self.playState = ClientConst.CUTSCENE_STATE_READY

			if callback then
				callback()
			end
		end)
	end
end

function CutsceneCmd:preloadAndCreateIns()
	self:setKeepTrans(false)
	self:preload()
	pg.game.cutscene:onAfterPreloadUpdateCutsceneSetting(self)
end

function CutsceneCmd:getConfig()
	if self.cutscene then
		return self.cutscene.config
	end

	return nil
end

function CutsceneCmd:setEventCallback(callback)
	self.eventCallback = callback
end

function CutsceneCmd:play(endCallback)
	if not self.cutscene:IsResValid() then
		self.endCallback = endCallback

		self:onTimelineResInvalid()

		return
	end

	self.endCallback = endCallback

	local bindEntity = self.extraData.bindEntity

	if bindEntity then
		self:setRefEntityByTemplateId(self.extraData.bindTemplateId or bindEntity.templateId, bindEntity)
	end

	self.cutscene:Play()
end

function CutsceneCmd:setStopTime(stopTime, endCallback)
	self.cutscene:SetStopTime(stopTime, endCallback)
end

function CutsceneCmd:stepTo(time)
	self.cutscene:StepTo(time)
end

function CutsceneCmd:pause()
	self.cutscene:Pause()
end

function CutsceneCmd:resume()
	self.cutscene:Resume()
end

function CutsceneCmd:stop()
	if self.playState == ClientConst.CUTSCENE_STATE_PLAY then
		self.cutscene:Stop()
	else
		self:onTimelinePreEnd()
		self:onTimelineEnd()
	end
end

function CutsceneCmd:rebind(from, to, clipKey, assetKey, subAssetName, suffix, owner)
	self.cutscene:Rebind(from, to, clipKey, assetKey, subAssetName, suffix, owner)
end

function CutsceneCmd:rebindAnimator(to)
	self.cutscene:RebindAnimator(to)
end

function CutsceneCmd:rebindAnimator(to)
	self.cutscene:RebindAnimator(to)
end

function CutsceneCmd:hideGround()
	self.cutscene:HideGround()
end

function CutsceneCmd:disableLod()
	self.cutscene:DisableLod()
end

function CutsceneCmd:setRefEntity(refKey, entity)
	self.cutscene:SetRefEntity(refKey, entity)
end

function CutsceneCmd:setRefEntityByTemplateId(templateId, entity)
	local refKey = "TemplateId_" .. tostring(templateId)

	if entity and entity.eModel then
		self.cutscene:SetRefEntity(refKey, entity.eModel)
	end
end

function CutsceneCmd:checkGroupTrackCondition()
	self.cutscene:CheckGroupTrackCondition()
end

function CutsceneCmd:evaluate(time)
	self.cutscene:Evaluate(time)
end

function CutsceneCmd:setSpeed(speed)
	self.cutscene:SetSpeed(speed)
end

function CutsceneCmd:onTimelinePlay()
	self.playState = ClientConst.CUTSCENE_STATE_PLAY

	pg.game.cutscene:onTimelinePlay(self)

	if self.extraData.startPlayCallback ~= nil then
		self.extraData.startPlayCallback(self)
	end

	if pg.me ~= nil then
		self.duration = self.cutscene.duration
		self.markStartTime = pg.me:getGameTime()

		LuaUIUtils.sendCustomLog(Const.BILogName.CUTSCENE, {
			duration = 0,
			cutscene_id = self.id,
			name = self.name,
			action = Const.BILogCutsceneAction.STRAT,
			totalDuration = self.duration
		})
	end
end

function CutsceneCmd:onTimelineStartSkip()
	if pg.me ~= nil then
		LuaUIUtils.sendCustomLog(Const.BILogName.CUTSCENE, {
			cutscene_id = self.id,
			name = self.name,
			action = Const.BILogCutsceneAction.START_SKIP,
			duration = pg.me:getGameTime() - self.markStartTime,
			totalDuration = self.duration
		})
	end
end

function CutsceneCmd:onTimelineConfirmSkip()
	if pg.me ~= nil then
		LuaUIUtils.sendCustomLog(Const.BILogName.CUTSCENE, {
			cutscene_id = self.id,
			name = self.name,
			action = Const.BILogCutsceneAction.CONFIRM_SKIP,
			duration = pg.me:getGameTime() - self.markStartTime,
			totalDuration = self.duration
		})
	end
end

function CutsceneCmd:onTimelinePreEnd()
	if self.extraData.prePlayEndCallback ~= nil then
		self.extraData.prePlayEndCallback(self)
	end
end

function CutsceneCmd:onTimelineResInvalid()
	self:onTimelinePreEnd()
	self:onTimelineEnd()
end

function CutsceneCmd:onTimelineEnd()
	self.playState = ClientConst.CUTSCENE_STATE_STOP

	pg.game.camera:tryResetWorldCameraEnable(ClientConst.CameraDisableReason.Cutscene)
	pg.game.cutscene:onTimelineEnd(self)

	if self.endCallback then
		self.endCallback(self)
	end

	if self.extraData.endCallback then
		self.extraData.endCallback(self)
	end

	if self.extraData.playEndCallback then
		self.extraData.playEndCallback(self)
	end

	if pg.me ~= nil then
		LuaUIUtils.sendCustomLog(Const.BILogName.CUTSCENE, {
			id = self.id,
			name = self.name,
			action = Const.BILogCutsceneAction.END,
			totalDuration = self.duration,
			duration = self.markStartTime and pg.me:getGameTime() - self.markStartTime or 0
		})
	end
end

function CutsceneCmd:onTimelineDestroy()
	return
end

function CutsceneCmd:OnTimelineEvent(eventParam)
	if self.eventCallback ~= nil then
		self.eventCallback(self, eventParam)
	elseif self.extraData.eventCallback then
		self.extraData.eventCallback(self, eventParam)
	end
end

function CutsceneCmd:onInvalid()
	if self.extraData.startPlayCallback then
		self.extraData.startPlayCallback(self)
	end

	if self.extraData.prePlayEndCallback then
		self.extraData.prePlayEndCallback(self)
	end

	if self.extraData.playEndCallback then
		self.extraData.playEndCallback(self)
	end

	if self.extraData.endCallback then
		self.extraData.endCallback(self)
	end
end

return CutsceneCmd
