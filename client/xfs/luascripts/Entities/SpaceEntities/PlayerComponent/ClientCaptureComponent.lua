-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientCaptureComponent.lua

local class = require("Core.Framework.Class")
local InputCommand = require("GameApp.Input.InputCommand")
local QuickCatchContext = require("GameApp.Capture.Context.QuickCatchContext")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local InputBuffer = require("GameApp.Input.InputBuffer")
local NoBallContext = require("GameApp.Capture.Context.NoBallContext")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClientConst = require("Const.ClientConst")
local AbilityConst = require("Common.Const.AbilityConst")
local voxelUtils = require("Common.Utils.VoxelUtils")
local ClientUtils = require("Utils.ClientUtils")
local castItemData = require("Data.cast_item_data")
local EModelUtils = require("Entities.Utils.EModelUtils")
local ItemEffectData = require("Data.item_effect_data")
local PetData = require("Data.pet_data")
local GlobalData = require("Core.Client.GlobalData")
local messageName = require("Const.MessageName")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ClientSwitch = require("Common.ClientSwitch")
local PROXY_KEY = {
	CatchBall = true,
	BigBall = true,
	BallBase = true
}
local ClientCaptureComponent = class.Component("ClientCaptureComponent")

function ClientCaptureComponent:ctor()
	self._captureBallEnts = {}
end

function ClientCaptureComponent:RPC_SC_SyncCaptureHoldBall(envId, itemId)
	return self:SyncCaptureHoldBall(envId, itemId)
end

function ClientCaptureComponent:SyncCaptureHoldBall(ballUid, itemId, isMain, isFake)
	local curEnt = pg.getEntityByGlobalId(ballUid)

	if curEnt then
		if isMain then
			self:_registerCaptureBall(curEnt)
		end

		return curEnt
	end

	local castItemId = Utils.itemId2CastItemId(itemId)
	local ballData = castItemData[castItemId]
	local valid, bonePos, boneRot = self.eModel.skeletonView:TryGetBonePosRot(ballData.bone)

	bonePos = valid and bonePos or self:getPosition()
	boneRot = valid and boneRot or self:getRotation()

	local proxy = ballData.proxy

	if not isMain then
		proxy = "BallBase"
	elseif isFake then
		proxy = "CatchBallFake"
	end

	local envEntity = ClientUtils.createClientEntity("Client" .. proxy, ballUid, {
		itemId = itemId,
		ballUid = ballUid,
		authorityId = self.id,
		position = bonePos,
		rotation = boneRot
	})

	if isFake and envEntity and envEntity.eModel then
		EModelUtils.setAgentPositionAndRotation(envEntity, bonePos, boneRot, true)
	end

	if isMain then
		self:_registerCaptureBall(envEntity)
	end

	return envEntity
end

function ClientCaptureComponent:_registerCaptureBall(ballEnt)
	if not ballEnt then
		return
	end

	self._captureBallEnts = self._captureBallEnts or {}
	self._captureBallEnts[ballEnt] = true
end

function ClientCaptureComponent:onCaptureBallDestroyed(ballEnt)
	if self._captureBallEnts then
		self._captureBallEnts[ballEnt] = nil
	end
end

function ClientCaptureComponent:_clearCaptureBallsOnLeave(reason)
	local captureBallEnts = self._captureBallEnts

	self._captureBallEnts = {}

	if not captureBallEnts then
		return
	end

	local clearCount = 0

	for ballEnt in pairs(captureBallEnts) do
		if ballEnt and not ballEnt.destroyed then
			clearCount = clearCount + 1

			if ballEnt.clientDestroy and not ballEnt.clientDestroyed then
				local success, err = xpcall(ballEnt.clientDestroy, debug.traceback, ballEnt)

				if not success then
					self.logger:error("@capture clientDestroy on leave failed, reason=%s, ballUid=%s, err=%s", reason, tostring(ballEnt.ballUid), tostring(err))
				end
			end

			ClientUtils.safeDestroy(ballEnt)
		end
	end

	if clearCount > 0 then
		self.logger:warn("@capture clear residual balls on leave, reason=%s, count=%d", reason, clearCount)
	end
end

function ClientCaptureComponent:EVENT_LeaveScene()
	self:_clearCaptureBallsOnLeave("leave_scene")
end

function ClientCaptureComponent:onLeaveSpace()
	self:_clearCaptureBallsOnLeave("leave_space")
end

function ClientCaptureComponent:RPC_SC_SyncCaptureClearBall(ballUid)
	self:SyncCaptureClearBall(ballUid)
end

function ClientCaptureComponent:SyncCaptureClearBall(ballUid)
	local curEnt = pg.getEntityByGlobalId(ballUid)

	if curEnt then
		ClientUtils.safeDestroy(curEnt)
	end
end

function ClientCaptureComponent:RPC_SC_OnFireBall(sessionId, ballUid, ballDict)
	local ballEnt = pg.getEntityByGlobalId(ballUid)

	if ballEnt then
		local bpx, bpy, bpz = ballEnt.eModel:GetPositionAgentPosEx()
		local brx, bry, brz, brw = ballEnt.eModel:GetPositionAgentRotationEx()

		ballDict.position = Vector3.New(bpx, bpy, bpz)
		ballDict.rotation = Quaternion(brx, bry, brz, brw)
		ballDict.captureSessionId = sessionId
		ballEnt.clenUsrType = nil
		ballEnt.authorityId = nil
		ballEnt.actorId = nil

		ClientUtils.replaceClientEntity(ballEnt, ballDict.id, ballDict)

		if ballEnt.aoi and ballEnt.isMainAuthority then
			ballEnt:onAoiCreated()
		end

		appFacade.entityManager:ResetEModel(ballEnt.eModel, ballEnt.id, ballEnt.actorId or 0, ballEnt:getShowName())

		if not ballEnt.isMainAuthority then
			ballEnt:onLuaFire()
		end
	end
end

function ClientCaptureComponent:RPC_SC_SyncCatchBallDestroyed(ballUid)
	local ballEnt = pg.getEntityByGlobalId(ballUid)

	if ballEnt then
		ClientUtils.safeDestroy(ballEnt)
	end
end

function ClientCaptureComponent:on_quickCaptureItemId_change(oldVal, newVal, itemId)
	facade:sendMsgToUI(messageName.CAPTURE_LOGIN_ITEM_CHANGE, {
		itemId = itemId
	})
end

function ClientCaptureComponent:on_debugCatchInfos_itemInserted(index, newVal)
	local catchInfoPairs = {}

	for index, pairStr in ipairs(self.debugCatchInfos) do
		table.insert(catchInfoPairs, Utils.decodeFromStr(pairStr))
	end

	table.sort(catchInfoPairs, function(a, b)
		return a[1] < b[1]
	end)

	self.serverCatchInfos = catchInfoPairs

	local pair = Utils.decodeFromStr(newVal)
	local catchKey = pair and pair[1] or "?"

	self.logger:debug("on_debugCatchInfos_itemInserted index=%d, key=%s", index, tostring(catchKey))
end

function ClientCaptureComponent:destroy()
	self:_clearCaptureBallsOnLeave("destroy")

	self._captureBallEnts = nil
end

return ClientCaptureComponent
