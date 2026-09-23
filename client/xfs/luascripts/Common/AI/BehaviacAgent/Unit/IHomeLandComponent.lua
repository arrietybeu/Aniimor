-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IHomeLandComponent.lua

local class = require("Core.Framework.Class")
local enums = require("Common.AI.Behaviac.Enums")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local EBTStatus = enums.EBTStatus
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AIBaseMethodUtils = require("Common.AI.BehaviacAgent.Unit.AIBaseMethodUtils")
local IHomeLandComponent = class.Component("IHomeLandComponent")

function IHomeLandComponent:finishHomeLandOperation()
	HomeLandUtils.deAllocateHomePetWork(self.ent)

	return EBTStatus.BT_SUCCESS
end

function IHomeLandComponent:switchToHomeWorkNow(targetPos, targetYaw)
	Vector3.enableCreateFromCache()
	self.ent:forceSetPosRot(targetPos, Quaternion.Euler(0, targetYaw, 0))
	Vector3.disableCreateFromCache()
	AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.HOMEWORK)

	return EBTStatus.BT_SUCCESS
end

function IHomeLandComponent:tryHomeLeisureMount(vehicleActorId, seatIndex, revision)
	HomeLandUtils.tryMountHomeLeisureRide(self.ent, vehicleActorId, seatIndex, revision)

	return EBTStatus.BT_SUCCESS
end

return IHomeLandComponent
