-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\MarkShare\\Helper\\MarkShareSystemAvatarHelper.lua

local ClientUtils = require("Utils.ClientUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientSimpleVirtualPlayer = require("Entities.ClientSimpleVirtualPlayer")
local ClientSimpleVirtualNpc = require("Entities.ClientSimpleVirtualNpc")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local PuppetData = require("Data.puppet_data")
local Lume = require("Core.Common.lume")
local AddressDataConst = require("Const.AddressDataConst")
local InfoStampAnimationConfigData = require("Data.info_stamp_animation_config_data")
local EModelUtils = require("Entities.Utils.EModelUtils")
local TimerManager = require("Core.Timer.TimerManager")
local MarkShareSystemAvatarHelper = Class.LiteClass("MarkShareSystemAvatarHelper")

MarkShareSystemAvatarHelper.DESTROY_TIMEOUT = 1.5

function MarkShareSystemAvatarHelper:ctor()
	self.markEntityPool = {}
end

function MarkShareSystemAvatarHelper:playEffect(entity, appear, cb)
	local shaderView = entity.eModel.modelShaderView
	local playerHeight = entity:getHeight()
	local dissolveStartPosition = Vector3(0, playerHeight, 0)
	local border = playerHeight
	local startValue = playerHeight
	local endValue = 0

	if not appear then
		startValue = 0
		endValue = playerHeight
	end

	local duration = 1

	shaderView:TweenSwitchDissolveEffectAlter(appear and "MessageHoloAppear" or "MessageHoloDisappear", dissolveStartPosition, AddressDataConst.MI_Eff_Avatar_Message_Holographic, true, startValue, endValue, duration, appear and -border or border, cb)
end

function MarkShareSystemAvatarHelper:createPlayerAvatar(uid, successCallback, failedCallback, parentTransform)
	ServiceUtils.userDataGetAttribute(uid, {
		"avatarConfig",
		"curShow",
		"avatarPresetKey"
	}, CallbackHandler(self, "_getAvatarCb", {
		successCallback = successCallback,
		failedCallback = failedCallback,
		parentTransform = parentTransform,
		entityPool = self.markEntityPool
	}), pg.me.uid)
end

function MarkShareSystemAvatarHelper:_getAvatarCb(param, result, resp)
	if param.entityPool ~= self.markEntityPool then
		return
	end

	if result.status then
		local entity = ClientVirtualEntityUtils.createVirtualPlayer(resp.AttributesMap.avatarConfig, resp.AttributesMap.curShow, resp.AttributesMap.avatarPresetKey)

		table.insert(self.markEntityPool, entity)

		if param.parentTransform then
			entity.eModel:SetTransformParent(param.parentTransform)
			entity.eModel:SetTransformLocalPosition()
		end

		function entity.modelPartModelAllLoaded()
			self:onAvatarModelLoaded(entity, param.entityPool)
		end

		if param.successCallback then
			param.successCallback(entity)
		end
	elseif param.failedCallback then
		param.failedCallback()
	end
end

function MarkShareSystemAvatarHelper:createMainPlayerAvatar(successCallback, failedCallback, parentTransform)
	if pg.me then
		local entity = ClientSimpleVirtualPlayer.new()
		local initInfo = {
			copyEntity = pg.me
		}

		entity:init(initInfo)
		entity:postInit(initInfo)
		entity:start()
		table.insert(self.markEntityPool, entity)

		local entityPool = self.markEntityPool

		if parentTransform then
			entity.eModel:SetTransformParent(parentTransform)
			entity.eModel:SetTransformLocalPosition()
		end

		function entity.modelPartModelAllLoaded()
			self:onAvatarModelLoaded(entity, entityPool)
		end

		if successCallback then
			successCallback(entity)
		end
	elseif failedCallback then
		failedCallback()
	end
end

function MarkShareSystemAvatarHelper:createNpcAvatar(templateId, successCallback, failedCallback, parentTransform)
	local puppetData = PuppetData[templateId] or {}

	if puppetData.prefabResID or puppetData.appearanceResID then
		local entity = ClientSimpleVirtualNpc.new()
		local initInfo = {
			templateId = templateId
		}

		entity:init(initInfo)
		entity:postInit(initInfo)
		entity:start()
		table.insert(self.markEntityPool, entity)

		local entityPool = self.markEntityPool

		if parentTransform then
			entity.eModel:SetTransformParent(parentTransform)
			entity.eModel:SetTransformLocalPosition()
		end

		function entity.modelLoadedCallback()
			self:onAvatarModelLoaded(entity, entityPool)
		end

		if successCallback then
			successCallback(entity)
		end
	elseif failedCallback then
		failedCallback()
	end
end

function MarkShareSystemAvatarHelper:onAvatarModelLoaded(entity, entityPool)
	if entityPool ~= self.markEntityPool or entity.destroyed or entity._isDestroyingEntity then
		return
	end

	entity.markShareModelLoaded = true

	self:playEffect(entity, true)
end

function MarkShareSystemAvatarHelper:destroy(cb)
	local entityPool = self.markEntityPool

	self.markEntityPool = {}

	local count = Lume.count(entityPool)

	if count <= 0 then
		if cb then
			cb()
		end

		return
	end

	local batch = {
		entities = entityPool,
		remaining = count,
		callback = cb
	}

	batch.timer = TimerManager.addTimer(self.DESTROY_TIMEOUT, function()
		batch.timer = nil

		for key, entity in pairs(batch.entities) do
			self:finishAvatarDestroy(batch, key, entity)
		end
	end)

	for key, entity in pairs(entityPool) do
		entity.modelPartModelAllLoaded = nil
		entity.modelLoadedCallback = nil

		if not entity.markShareModelLoaded or entity.destroyed or entity._isDestroyingEntity then
			self:finishAvatarDestroy(batch, key, entity)
		else
			local ok = ClientUtils.tryWithLogErrorEx(self.playEffect, self, entity, false, function()
				self:finishAvatarDestroy(batch, key, entity)
			end)

			if not ok then
				self:finishAvatarDestroy(batch, key, entity)
			end
		end
	end
end

function MarkShareSystemAvatarHelper:finishAvatarDestroy(batch, key, entity)
	if batch.entities[key] ~= entity then
		return
	end

	batch.entities[key] = nil

	ClientUtils.safeDestroy(entity, true)

	batch.remaining = batch.remaining - 1

	if batch.remaining == 0 then
		if batch.timer then
			TimerManager.removeTimer(batch.timer)

			batch.timer = nil
		end

		local cb = batch.callback

		batch.callback = nil

		if cb then
			cb()
		end
	end
end

function MarkShareSystemAvatarHelper:animationTool(ent, aniIndex, isView, firstCreate)
	if aniIndex == -1 then
		ent.eModel:SetModelVisible(false)

		return
	else
		ent.eModel:SetModelVisible(true)
	end

	local aniData = InfoStampAnimationConfigData[aniIndex][1]

	if not isView then
		local cameraTransEulerAnglesX, cameraTransEulerAnglesY, cameraTransEulerAnglesZ = pg.global.cameraMgr:GetWorldCameraRotEulerAnglesEx()
		local modelRot = Quaternion.Euler(cameraTransEulerAnglesX, cameraTransEulerAnglesY + 180 + (aniData.rotationY or 0), cameraTransEulerAnglesZ)

		EModelUtils.setAgentRotation(ent, modelRot, true)

		pg.global.ui.markShareEdit.modelRot = modelRot
	end

	if not firstCreate then
		ent:stopAllAnimation()
	end

	local startAni = PlayableConst[aniData.animationStart]
	local loopAni = PlayableConst[aniData.animationLoop]
	local endAni = PlayableConst[aniData.animationEnd]

	startAni = startAni or loopAni
	endAni = endAni or loopAni

	local loopTime = aniData.loopTime

	ent:playCfgAnimation({
		startAni,
		loopAni,
		endAni,
		{
			loopTime < 0,
			loopTime
		}
	})
end

return MarkShareSystemAvatarHelper
