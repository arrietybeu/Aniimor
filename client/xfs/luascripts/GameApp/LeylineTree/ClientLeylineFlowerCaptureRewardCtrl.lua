-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\LeylineTree\\ClientLeylineFlowerCaptureRewardCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local EffectConst = require("Const.EffectConst")
local SysConfigData = require("Data.sys_config_data")
local LeylineFlowerUtils = require("Common.Utils.LeylineFlowerUtils")
local Vector3 = Vector3
local logger = LoggerManager.getLogger("LeylineFlowerCaptureReward", "LeylineTree", LoggerConst.ERROR)
local TRAIL_EFFECT = "Eff_SceneObject_LootBox_Trail02_Rainbow_01"
local ABSORB_EFFECT = "Eff_SceneObject_LootBoxAbsorb_Rainbow_01"
local FLOWER_CAPTURE_TARGET_BONE = "Bone_06"
local TransformBezierMotorType = CS.FunPlus.WorldX.GameApp.Effect.TransformBezierMotor
local ClientLeylineFlowerCaptureRewardCtrl = {}
local Ctrl = ClientLeylineFlowerCaptureRewardCtrl

local function _getFlowerCenterTransform(flowerEntity)
	local eModel = flowerEntity and flowerEntity.eModel
	local skeletonView = eModel and eModel.skeletonView

	if IsNil(skeletonView) then
		return nil
	end

	local flowerCenter = skeletonView:GetBone(FLOWER_CAPTURE_TARGET_BONE)

	return NotNil(flowerCenter) and flowerCenter or nil
end

local function _toVector3(trans, defaultX, defaultY, defaultZ)
	trans = trans or {}

	return Vector3(trans[1] or defaultX, trans[2] or defaultY, trans[3] or defaultZ)
end

function Ctrl._loadConfig()
	return {
		absorbDurationMin = SysConfigData.chestRewardAttractAbsorbDurationMin or 0.5,
		absorbDurationMax = SysConfigData.chestRewardAttractAbsorbDurationMax or 0.8,
		absorbStartUp = SysConfigData.chestRewardAttractAbsorbStartUp or 0.8,
		absorbEndUp = SysConfigData.chestRewardAttractAbsorbEndUp or 0.4,
		absorbSideRandom = SysConfigData.chestRewardAttractAbsorbSideRandom or 0.25,
		absorbSound = SysConfigData.chestRewardAttractAbsorbSound or "SFX_UI_Reward_Pickup_Default",
		circularTrans = _toVector3(SysConfigData.leyLineCatchCircularTrans, -0.5, 0.06, 0),
		boomTrans = _toVector3(SysConfigData.leyLineCatchBoomTrans, -0.5, 0.06, 0)
	}
end

function Ctrl._getScaleByStage(petStage)
	if petStage and petStage >= 3 then
		return 8
	end

	return 3
end

local function _rollDuration(minDur, maxDur)
	if maxDur <= minDur then
		return minDur
	end

	return minDur + math.random() * (maxDur - minDur)
end

function Ctrl.playCaptureBall(petPos, flowerEntity, petStage)
	if not petPos or not flowerEntity then
		return
	end

	local flowerCenter = _getFlowerCenterTransform(flowerEntity)

	if IsNil(flowerCenter) then
		return
	end

	local cfg = Ctrl._loadConfig()
	local scale = Ctrl._getScaleByStage(petStage)
	local duration = _rollDuration(cfg.absorbDurationMin, cfg.absorbDurationMax)
	local extraInfo = {
		position = petPos,
		rotation = Vector3.zero,
		followType = EffectConst.FollowType.Global,
		mountType = EffectConst.MountType.Motor,
		endCallback = function()
			Ctrl._onAbsorbDone(flowerEntity, scale, cfg)
		end,
		loadCallback = function(effectItem)
			if not effectItem or not effectItem.effectObj then
				return
			end

			local motor = effectItem.effectObj:GetComponent(typeof(TransformBezierMotorType))

			if motor then
				motor.duration = duration
				motor.startTangentUp = cfg.absorbStartUp
				motor.endTangentUp = cfg.absorbEndUp
				motor.sideRandom = cfg.absorbSideRandom
			end

			effectItem.effectObj.transform.localScale = Vector3(scale, scale, scale)
		end,
		scale = scale
	}

	extraInfo.targetTrans = flowerCenter
	extraInfo.targetTransOffset = cfg.circularTrans

	pg.game.effect:playEffect(0, TRAIL_EFFECT, extraInfo)
	logger:info("playCaptureBall: started, petStage=%s, scale=%.1f, duration=%.2f", petStage or 0, scale, duration)
end

function Ctrl._onAbsorbDone(flowerEntity, scale, cfg)
	local flowerCenter = _getFlowerCenterTransform(flowerEntity)

	if IsNil(flowerCenter) then
		return
	end

	local absorbPos = flowerCenter.position + flowerCenter.rotation * cfg.boomTrans

	if ABSORB_EFFECT and ABSORB_EFFECT ~= "" then
		local absorbExtraInfo = {
			position = absorbPos,
			rotation = Vector3.zero,
			followType = EffectConst.FollowType.Global,
			mountType = EffectConst.MountType.World,
			scale = scale
		}

		pg.game.effect:playEffect(0, ABSORB_EFFECT, absorbExtraInfo)
		logger:info("_onAbsorbDone: played absorb effect=%s at pos=%s, scale=%.1f", ABSORB_EFFECT, tostring(absorbPos), scale)
	end

	if pg.game and pg.game.audio and cfg.absorbSound and cfg.absorbSound ~= "" then
		pg.game.audio:playEvent(cfg.absorbSound)
	end
end

function Ctrl.cleanupAll()
	return
end

return ClientLeylineFlowerCaptureRewardCtrl
