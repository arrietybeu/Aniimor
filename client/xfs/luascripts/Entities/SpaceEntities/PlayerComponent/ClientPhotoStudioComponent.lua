-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPhotoStudioComponent.lua

local class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Utils = require("Common.Utils.Utils")
local SceneUtils = require("Common.Utils.SceneUtils")
local ClientPhotoStudioComponent = class.Component("ClientPhotoStudioComponent")
local SceneData = require("Data.scene_data")
local PhotoPrefabData = require("Data.photo_prefab_data")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local StudioSceneId = 521

function ClientPhotoStudioComponent:ctor()
	self.studioAssetsId = -1
	self.photoTimer = nil
	self.canChangeScene = false
end

function ClientPhotoStudioComponent:init(avtDict)
	return true
end

function ClientPhotoStudioComponent:destroy()
	return
end

function ClientPhotoStudioComponent:reqPhotoStudioUnlock(id)
	local function callback(flag, code)
		return
	end

	self:serverMsg("RPC_CS_ReqPhotoStudioUnlock", id, callback)
end

function ClientPhotoStudioComponent:isPhotoUnlock(id)
	if not id then
		return true
	end

	id = tonumber(id)

	return self.photoStudioUnlockMap[id] == true
end

function ClientPhotoStudioComponent:on_photoStudioUnlockMap_changed(oldVal, newVal)
	if self ~= pg.me then
		return
	end

	facade:SendMessageCommand(MessageName.PHOTO_ASSET_UNLOCK_CHANGED)
end

function ClientPhotoStudioComponent:onEnterSpace()
	if Utils.isScenePhoto() and self.space and self.space.photoWorldOwnerUid ~= self.uid then
		self:sendMainPhotoStudioMsg({
			changePrefab = true,
			uid = self.uid
		})
	end
end

function ClientPhotoStudioComponent:onLeaveSpace()
	if Utils.isScenePhoto() then
		self.studioAssetsId = nil
	end

	self.canChangeScene = false

	pg.global.ui:close(UIConst.UI_ID_PHOTO)
end

function ClientPhotoStudioComponent:getPhotoStudioAssetsId()
	return self.studioAssetsId
end

function ClientPhotoStudioComponent:notifyPhotoStudioMsg(info)
	self:serverMsg("RPC_CS_NotifyPhotoStudioMsg", info)
end

function ClientPhotoStudioComponent:RPC_SC_NotifyPhotoStudioMsg(info)
	print("sssssssssssss-RPC_SC_NotifyPhotoStudioMsg: ", inspect(info))

	if info and info.studioAssetsId then
		self:changeStudioPrefab(info.studioAssetsId, false)

		local photo = pg.global.ui.photo

		photo.model:setStudioAssetsId(info.studioAssetsId)
	end
end

function ClientPhotoStudioComponent:sendMainPhotoStudioMsg(info)
	self:serverMsg("RPC_CS_SendMainPhotoStudioMsg", info)
end

function ClientPhotoStudioComponent:RPC_SC_SendMainPhotoStudioMsg(info)
	print("sssssssssssss-RPC_SC_SendMainPhotoStudioMsg: ", inspect(info))

	if info and info.changePrefab then
		self:sendSpecifyPhotoStudioMsg({
			info.uid
		}, {
			studioAssetsId = self.studioAssetsId
		})
	end
end

function ClientPhotoStudioComponent:sendSpecifyPhotoStudioMsg(uids, info)
	self:serverMsg("RPC_CS_SendSpecifyPhotoStudioMsg", uids, info)
end

function ClientPhotoStudioComponent:RPC_SC_SendSpecifyPhotoStudioMsg(info)
	print("sssssssssssss-RPC_SC_SendSpecifyPhotoStudioMsg: ", inspect(info))

	if info and info.studioAssetsId then
		self:changeStudioPrefab(info.studioAssetsId, false, true)

		local photo = pg.global.ui.photo

		photo.model:setStudioAssetsId(info.studioAssetsId)
	end
end

function ClientPhotoStudioComponent:changeStudioPrefab(studioAssetsId, playEffect, force)
	if not Utils.isScenePhoto() then
		return
	end

	if self.studioAssetsId == studioAssetsId and studioAssetsId ~= nil and not force then
		return
	end

	local prefabData = PhotoPrefabData[studioAssetsId]
	local prefabId = prefabData and prefabData.res

	prefabId = tonumber(prefabId)
	prefabId = prefabId or 1
	playEffect = playEffect or false

	local ins = CS.FunPlus.WorldX.RenderingScripts.Effect.SceneSwitchManager.Ins

	if ins then
		self.studioAssetsId = studioAssetsId

		if not self.canChangeScene then
			return
		end

		local sceneLevelId = prefabId

		ins:ChangeSceneLevelId(sceneLevelId, self:getPosition(), playEffect)

		if sceneLevelId == 0 then
			pg.game.weather:setTodTime(Const.TOD_TIME_KEY.PHOTO, true, 17, 12, 1)
		elseif sceneLevelId == 1 then
			pg.game.weather:setTodTime(Const.TOD_TIME_KEY.PHOTO, true, 4, 30, 1)
		end

		if playEffect then
			pg.game.audio:playEvent("SFX_UI_Rouge_LoadScene")
		end

		local sceneConfig = {}

		table.merge(sceneConfig, SceneData[StudioSceneId] or {})

		sceneConfig.file = SceneUtils.getSceneName(sceneConfig.file or "")

		local voxelPath = string.format("%s_Level%d", sceneConfig.file, prefabId or 0)

		pg.world.clearVoxelSpanState()
		pg.global.voxelMgr:ClearAllEffects()
		pg.game.voxel:updateVoxelPath(voxelPath)
	end
end

function ClientPhotoStudioComponent:applyPhotoStudio(targetId, info)
	self:callService("FriendService", "applyPhotoStudio", {
		self.uid,
		targetId,
		info
	}, CallbackHandler(self, "_applyPhotoStudioCallback"), {
		callerId = self.uid
	})
end

function ClientPhotoStudioComponent:_applyPhotoStudioCallback(result)
	print("sssssssssssss-_applyPhotoStudioCallback: ", inspect(result))
end

function ClientPhotoStudioComponent:acceptPhotoStudio(applyId)
	self:callService("FriendService", "acceptPhotoStudio", {
		self.uid,
		applyId
	}, CallbackHandler(self, "_acceptPhotoStudioCallback", applyId), {
		callerId = self.uid
	})
end

function ClientPhotoStudioComponent:_acceptPhotoStudioCallback(applyId, result)
	print("sssssssssssss-_acceptPhotoStudioCallback: ", applyId, inspect(result))
end

function ClientPhotoStudioComponent:refusePhotoStudio(applyId, info)
	self:callService("FriendService", "refusePhotoStudio", {
		self.uid,
		applyId,
		info
	}, CallbackHandler(self, "_refusePhotoStudioCallback", applyId), {
		callerId = self.uid
	})
end

function ClientPhotoStudioComponent:_refusePhotoStudioCallback(applyId, result)
	print("sssssssssssss-_refusePhotoStudioCallback: ", applyId, inspect(result))
end

function ClientPhotoStudioComponent:removePhotoStudio(applyId, info)
	self:callService("FriendService", "removePhotoStudio", {
		self.uid,
		applyId,
		info
	}, CallbackHandler(self, "_removePhotoStudioCallback", applyId), {
		callerId = self.uid
	})
end

function ClientPhotoStudioComponent:_removePhotoStudioCallback(applyId, result)
	print("sssssssssssss-_removePhotoStudioCallback: ", applyId, inspect(result))
end

function ClientPhotoStudioComponent:FriendService_onPhotoStudioApply(applyId, info)
	print("sssssssssssss-onPhotoStudioApply: ", applyId, info)
end

function ClientPhotoStudioComponent:FriendService_onPhotoStudioAccept(acceptId)
	print("sssssssssssss-onPhotoStudioAccept: ", acceptId)
end

function ClientPhotoStudioComponent:FriendService_onPhotoStudioRefuse(refuseId, info)
	print("sssssssssssss-onPhotoStudioRefuse: ", refuseId, info)
end

return ClientPhotoStudioComponent
