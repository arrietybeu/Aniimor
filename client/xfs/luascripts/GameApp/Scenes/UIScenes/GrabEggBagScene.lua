-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\GrabEggBagScene.lua

local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local ItemConst = require("Common.Const.ItemConst")
local PlayableConst = require("Common.Const.PlayableConst")
local Const = require("Common.Const.Const")
local GrabEggBagScene = Class.LightClass("GrabEggBagScene", UISceneBase)

function GrabEggBagScene:onCtor()
	return
end

function GrabEggBagScene:onStart(param)
	local root = self.scene.transform:Find("Global")
	local objectReference = root:GetComponent("ObjectReference")

	self.girlTransform = objectReference:GetRefValue("girlTransform")
	self.boyTransform = objectReference:GetRefValue("boyTransform")
	self.camera = objectReference:GetRefValue("camera")

	pg.global.cameraMgr:SetUISceneCamera(self.camera)

	local configData = pg.me:getConfigData()
	local gender = pg.me.gender or configData.gender

	self.isBoy = gender == 1
end

function GrabEggBagScene:onDestroy()
	local entity = pg.game.grabEgg:getVirtualPlayerEntity()

	if entity then
		entity.eModel:SetTransformParent(nil, false)
		entity.eModel:SetTransformPosition(0, -1000, 0)
		entity:setActive(ClientConst.MODEL_VISIBLE_KEY.DEFAULT, false)
	end
end

function GrabEggBagScene:createPlayer(isBoy)
	local entity = pg.game.grabEgg:getVirtualPlayerEntity() or self:copyMainPlayer()

	entity.eModel:SetFacialStubEnabled(Const.COMPONENT_IDX_PLAYABLE, false)

	local parentTransform = isBoy and self.boyTransform or self.girlTransform

	entity.eModel:SetTransformParent(parentTransform, false)
	entity.eModel:SetTransformLocalPosition()

	local localRotation = Quaternion.Euler(0, isBoy and -17.72 or -87.81, 0)

	entity.eModel:SetTransformLocalRotation(localRotation.x, localRotation.y, localRotation.z, localRotation.w)

	local pos = Vector3(entity.eModel:GetTransformPosition()) + self:calcScreenAdaptOffset(parentTransform)

	entity.eModel:SetTransformPosition(pos.x, pos.y, pos.z)
	entity.eModel:SetTransformLocalScale()
	entity:stopAllAnimation()
	entity:playAnimation(PlayableConst.Pose_Bag_Idle)
	entity:setActive(ClientConst.MODEL_VISIBLE_KEY.DEFAULT, true)
end

local STANDARD_ASPECT = 1.7777777777777777

function GrabEggBagScene:calcScreenAdaptOffset(parentTransform)
	local currentAspect = Screen.width / Screen.height

	if math.abs(currentAspect - STANDARD_ASPECT) < 0.01 then
		return Vector3.zero
	end

	local modelWorldPos = parentTransform.position
	local viewportPos = UIUtils.GetPositionViewportPoint(modelWorldPos)
	local targetViewportX = viewportPos.x * STANDARD_ASPECT / currentAspect
	local targetWorldPos = UIUtils.GetViewportWorldPosition(Vector3.New(targetViewportX, viewportPos.y, viewportPos.z))

	return targetWorldPos - modelWorldPos
end

return GrabEggBagScene
