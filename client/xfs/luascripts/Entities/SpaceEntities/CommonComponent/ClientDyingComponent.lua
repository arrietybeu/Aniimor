-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientDyingComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Utils = require("Common.Utils.Utils")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local ClientConst = require("Const.ClientConst")
local SysConfigData = require("Data.sys_config_data")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientDyingComponent = class.Component("ClientDyingComponent")

function ClientDyingComponent:ctor()
	self.disableMotionDict = {}
end

function ClientDyingComponent:destroy()
	return
end

function ClientDyingComponent:onEnterSpace()
	local isMainPlayer = self.isMainPlayer or false

	if isMainPlayer then
		self:startRecordBacktrackPosAndRot()
	end
end

function ClientDyingComponent:onLeaveSpace()
	self:clearBacktrackInfo()
end

function ClientDyingComponent:clientSwimmingDead()
	if not self.isMainPlayer and not self.isMainPet then
		return
	end

	local player = self

	if self.isMainPet then
		player = self:getMasterEntity()
	end

	if player.willDeadReason == Const.LIFE_DEAD_BY_WATER then
		return
	end

	player.willDeadReason = Const.LIFE_DEAD_BY_WATER

	player:serverMsg("RPC_CS_SpecialDamage", 0 --[[SPDMG0]], Const.LIFE_DEAD_BY_WATER)
end

function ClientDyingComponent:setWillDeadReason(reason)
	self.willDeadReason = reason
end

function ClientDyingComponent:getWillDeadReason()
	return self.willDeadReason or 0
end

function ClientDyingComponent:beDied()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientDyingComponent:beDied", self.willDeadReason)
	end

	if self.space and Utils.isRobEggSceneId(self.space.sceneId) and self:FALLEN_ST() then
		self:serverMsgNoGC("RPC_CS_SkipFallenPhase")

		return
	end

	if self.willDeadReason == Const.LIFE_DEAD_BY_WATER and not self.forceControl then
		if self.reviveInfo and ToBool(self.reviveInfo.blackScreenId) then
			pg.global.ui.blackScreen:open({
				id = self.reviveInfo.blackScreenId
			}, function()
				self:startDelayReviveTimer(Const.LIFE_DEAD_BY_WATER)
			end)
		else
			self:doRevive(Const.LIFE_DEAD_BY_WATER)

			self.reviveInfo = nil
		end
	end
end

function ClientDyingComponent:receiveFallToGroundDamage(height)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:log2Tag("Damage", string.format("@hyj onReceiveFallToGroundDamage: height = %f, dmgPercent = %f", height, Utils.calcFallToGroundDamage(height)))
	end

	if Utils.isPlayer(self) or Utils.isPlayerPet(self) then
		if self.space and self.space:checkImmuneFallDamage() then
			return
		end

		self:serverMsg("RPC_CS_SpecialDamage", 0 --[[SPDMG0]], Const.LIFE_DEAD_BY_FALL_TO_GROUND)
	end
end

function ClientDyingComponent:beDrownOnForceControl()
	local player

	if Utils.isPlayer(self) then
		player = self
	end

	if Utils.isPet(self) then
		player = self:getMasterEntity()
	end

	local curPlayerSpace = pg.me and pg.me.space
	local isDittoDungeon = curPlayerSpace and curPlayerSpace:isDittoSpace()

	if isDittoDungeon then
		local dittoSandbox = pg.me.space:getSandbox(Const.DittoDungeonSandboxId)

		if dittoSandbox and dittoSandbox.gameplay then
			dittoSandbox.gameplay:onSwimmingDie()
		end

		return
	end

	if player then
		if player.willDeadReason == Const.LIFE_DEAD_BY_WATER then
			return
		end

		player.willDeadReason = Const.LIFE_DEAD_BY_WATER
	end

	if Utils.isPlayer(self) or Utils.isPlayerPet(self) then
		self:serverMsg("RPC_CS_SpecialDamage", 0 --[[SPDMG0]], Const.LIFE_DEAD_BY_WATER)
	end
end

function ClientDyingComponent:startRecordBacktrackPosAndRot()
	self:clearBacktrackInfo()

	if self:checkCanRecordPos() then
		local succ, heightGround = PhysicsUtils.getGroundHeight(self:getPosition())

		if succ and math.abs(heightGround) < 0.02 then
			table.insert(self.backtrackQueue, {
				pos = self:getPosition():CloneFromPool(),
				rotYawEuler = self:getRotation():GetEulerAnglesY()
			})
		end
	end

	self.backTrackTimer = self:addRepeatTimer(1, function()
		if not self:checkCanRecordPos() then
			return
		end

		if #self.backtrackQueue >= 10 then
			local v = table.remove(self.backtrackQueue, 1)

			Vector3.returnToPool(v.pos)
		end

		local succ, heightGround = PhysicsUtils.getGroundHeight(self:getPosition())

		if succ and math.abs(heightGround) < 0.02 then
			table.insert(self.backtrackQueue, {
				pos = self:getPosition():CloneFromPool(),
				rotYawEuler = self:getRotation():GetEulerAnglesY()
			})
		end
	end)
end

function ClientDyingComponent:tryGetValidBacktrackData(reason, posType, pos, rot)
	if not posType then
		return false, {}, 0
	end

	if posType == Const.RESET_POS_TYPE_INCLUDE_CUR_POS and reason ~= Const.LIFE_DEAD_BY_WATER and reason ~= Const.LIFE_DEAD_BY_CLIFF then
		local succ, heightGround = PhysicsUtils.getGroundHeight(self:getPosition())

		if succ and math.abs(heightGround) < 0.02 then
			return true, self:getPosition(), self:getRotation():GetEulerAnglesY()
		end
	end

	if posType == Const.RESET_POS_TYPE_INCLUDE_CUR_POS or posType == Const.RESET_POS_TYPE_EXCLUDE_CUR_POS then
		if ToBool(self.backtrackQueue) then
			for i = #self.backtrackQueue, 1, -1 do
				local data = self.backtrackQueue[i]
				local succ, heightGround = PhysicsUtils.getGroundHeight(data.pos)

				if succ and math.abs(heightGround) < 0.02 then
					return true, data.pos, data.rotYawEuler
				end
			end
		end
	elseif posType == Const.RESET_POS_TYPE_MARK_POINT then
		return true, pos, rot and rot[2] or 0
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("@hyj ClientDyingComponent[tryGetValidBacktrackData]: not support resetPositionType", posType)
	end

	return false, {}, 0
end

function ClientDyingComponent:stopBacktrackTimer()
	if self.backTrackTimer ~= nil then
		self:removeTimer(self.backTrackTimer)

		self.backTrackTimer = nil
	end
end

function ClientDyingComponent:clearBacktrackInfo()
	local isMainPlayer = self.isMainPlayer or false

	if isMainPlayer then
		self:stopBacktrackTimer()

		if self.backtrackQueue then
			for i = 1, #self.backtrackQueue do
				local v = self.backtrackQueue[i]

				Vector3.returnToPool(v.pos)

				self.backtrackQueue[i] = nil
			end
		end

		self.backtrackQueue = {}
	end
end

function ClientDyingComponent:checkCanRecordPos()
	if self.isInAreaLimit then
		return false
	end

	if self.willDeadReason ~= nil then
		return false
	end

	if self:isDead() then
		return false
	end

	if self:isControllingPet() then
		local curPet = self:getCurPetEntity()

		if curPet and curPet:isDead() then
			return false
		end
	end

	return true
end

return ClientDyingComponent
