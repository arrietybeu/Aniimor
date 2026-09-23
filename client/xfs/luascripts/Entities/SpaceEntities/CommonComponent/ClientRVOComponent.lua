-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientRVOComponent.lua

local CommonConst = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local EnvObjData = require("Data.envobj_data")
local AiConst = require("Common.Const.AiConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local RigidbodyData = require("Data.rigidbody_data")
local ClientRVOComponent = Class.Component("ClientRVOComponent")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local BOSS_RUSH_CHAIN_LOCK_BUFF_ID = 4003045

function ClientRVOComponent:ctor()
	return
end

function ClientRVOComponent:EVENT_AddEComponent()
	if self.eModel == nil then
		return
	end

	self:addEModelComponent(CommonConst.COMPONENT_RVO)
end

function ClientRVOComponent:onEnterCombat()
	self:setCombatRVOSetting()
end

function ClientRVOComponent:onLeaveCombat()
	self:setDefaultRVOSetting()
end

function ClientRVOComponent:addBuffEvent(buffTemplateId)
	if buffTemplateId ~= BOSS_RUSH_CHAIN_LOCK_BUFF_ID then
		return
	end

	if Utils.isBotPet(self) then
		if self.eModel == nil then
			return
		end

		local radius = self.eModel.radius + 0.2
		local weight = 0
		local maxRVONeighbors = pg.me.space:isRogueEnv() and 12 or 8

		AutoPathFindUtils.stopAutoPathFind(self)
		AIControllerUtils.SetDynamicRVO(self, radius, weight, 0.5, maxRVONeighbors)
	end
end

function ClientRVOComponent:removeBuffEvent(buffTemplateId)
	if buffTemplateId ~= BOSS_RUSH_CHAIN_LOCK_BUFF_ID then
		return
	end

	if Utils.isBotPet(self) then
		if self.eModel == nil then
			return
		end

		local radius = self.eModel.radius + 0.2
		local weight = self:getConfigData().rvoWeight or 0.5
		local maxRVONeighbors = pg.me.space:isRogueEnv() and 12 or 8

		AIControllerUtils.SetDynamicRVO(self, radius, weight, 0.5, maxRVONeighbors)
	end
end

function ClientRVOComponent:onEnterSpace()
	if self:getConfigData().IgnoreCollision == 1 then
		AIControllerUtils.setEnableRVO(self, false, AiConst.RVODisableControlType.NoCollision)
	end

	if self.isInCombat and self:isInCombat() then
		self:setCombatRVOSetting()
	else
		self:setDefaultRVOSetting()
	end

	if Utils.isHomePet(self) or Utils.isPuppet(self) or Utils.isPlayer(self) or Utils.isPet(self) or Utils.isBotPlayer(self) then
		self:enableRVO()
	end
end

function ClientRVOComponent:EVENT_onModelLoaded()
	if Utils.isEnvObj(self) then
		if self:getConfigData().enableRVO == AiConst.EnvObjRVOType.EnableStaticRVO then
			AIControllerUtils.initStaticRVO(self)
		elseif self:getConfigData().enableRVO == AiConst.EnvObjRVOType.EnableDynamicRVO then
			self:enableRVO()
		end
	end
end

function ClientRVOComponent:EVENT_BeControlled()
	self:setPlayerRVOSetting()
end

function ClientRVOComponent:EVENT_LoseControlled()
	self:setPetRVOSetting()
end

function ClientRVOComponent:onPetUnSummon()
	AIControllerUtils.setEnableRVO(self, false, AiConst.RVODisableControlType.BeUnSummoned)
end

function ClientRVOComponent:onPetSummon()
	AIControllerUtils.setEnableRVO(self, true, AiConst.RVODisableControlType.BeUnSummoned)
end

function ClientRVOComponent:EVENT_BeStick()
	AIControllerUtils.setEnableRVO(self, false, AiConst.RVODisableControlType.BeStick)
end

function ClientRVOComponent:EVENT_BeUnStick()
	AIControllerUtils.setEnableRVO(self, true, AiConst.RVODisableControlType.BeStick)
end

function ClientRVOComponent:EVENT_OnEntityBeAttached()
	AIControllerUtils.setEnableRVO(self, false, AiConst.RVODisableControlType.BeStick)
end

function ClientRVOComponent:EVENT_OnEntityBeDetached()
	AIControllerUtils.setEnableRVO(self, true, AiConst.RVODisableControlType.BeStick)
end

function ClientRVOComponent:EVENT_OnModelVisibleChange(visible)
	if visible then
		AIControllerUtils.setEnableRVO(self, true, AiConst.RVODisableControlType.Visible)
	else
		AIControllerUtils.setEnableRVO(self, false, AiConst.RVODisableControlType.Visible)
	end
end

function ClientRVOComponent:EVENT_onControlPlayerSwitchToPet()
	AIControllerUtils.setEnableRVO(self, false, AiConst.RVODisableControlType.ControlPlayerSwitchToPet)
end

function ClientRVOComponent:EVENT_onControlPetSwitchToPlayer()
	AIControllerUtils.setEnableRVO(self, true, AiConst.RVODisableControlType.ControlPlayerSwitchToPet)
end

function ClientRVOComponent:EVENT_OnAuthorityChanged()
	if Utils.isHomePet(self) then
		self:setHomePetRVOSetting()
	end
end

function ClientRVOComponent:onHomelandAIPlanChanged()
	if Utils.isHomePet(self) then
		self:setHomePetRVOSetting()
	end
end

function ClientRVOComponent:setDefaultRVOSetting()
	if Utils.isPlayer(self) then
		self:setPlayerRVOSetting()
	elseif Utils.isPet(self) then
		if self:checkPetInControl() then
			self:setPlayerRVOSetting()
		else
			self:setPetRVOSetting()
		end
	elseif Utils.isHomePet(self) then
		self:setHomePetRVOSetting()
	elseif Utils.isSimpleMoveNpc(self) then
		self:setSimpleMoveNpcRVOSetting()
	elseif Utils.isPuppet(self) or Utils.isBotPlayer(self) then
		self:setPuppetRVOSetting()
	elseif Utils.isEnvObj(self) then
		self:setEnvObjRVOSetting()
	end
end

function ClientRVOComponent:setCombatRVOSetting()
	if self.eModel == nil then
		return
	end

	local radius = self.eModel.radius + 0.2
	local weight = self:getConfigData().rvoWeight or 0.5
	local timeHorizon = 0.1
	local isCurrentBossRushBoss = self.space and self.space:isBossRushEnv() and Utils.isSemanticallyBoss(self)

	if Utils.isPlayer(self) or Utils.isPet(self, true) or isCurrentBossRushBoss then
		weight = 0
	end

	if Utils.isBotPet(self) then
		timeHorizon = 0.5
	end

	local maxRVONeighbors = pg.me.space:isRogueEnv() and 12 or 8

	AIControllerUtils.SetDynamicRVO(self, radius, weight, timeHorizon, maxRVONeighbors)
end

function ClientRVOComponent:setPlayerRVOSetting()
	if self.eModel == nil then
		return
	end

	AIControllerUtils.SetDynamicRVO(self, self.eModel.radius, 0, 0.5, 0)
end

function ClientRVOComponent:setPetRVOSetting()
	if self.eModel == nil then
		return
	end

	AIControllerUtils.SetDynamicRVO(self, self.eModel.radius, 0.8, 0.1, 8)
end

function ClientRVOComponent:setPuppetRVOSetting()
	if self.eModel == nil then
		return
	end

	local isCurrentBossRushBoss = self.space and self.space:isBossRushEnv() and Utils.isSemanticallyBoss(self)
	local weight = isCurrentBossRushBoss and 0 or 0.8

	AIControllerUtils.SetDynamicRVO(self, self.eModel.radius, weight, 1, 8)
end

function ClientRVOComponent:setSimpleMoveNpcRVOSetting()
	if self.eModel == nil then
		return
	end

	local rigidbodyId = self:getConfigData().rigidbody
	local rigidbodyData = rigidbodyId and RigidbodyData[rigidbodyId]
	local radius = rigidbodyData and rigidbodyData.radius or 0.5

	AIControllerUtils.SetDynamicRVO(self, radius, 0.8, 1, 8)
end

function ClientRVOComponent:setEnvObjRVOSetting()
	if self.eModel == nil or self.bodySize == nil then
		return
	end

	AIControllerUtils.SetDynamicRVO(self, self.bodySize, 0, 1, 0)
end

function ClientRVOComponent:setHomePetRVOSetting()
	if self.eModel == nil then
		return
	end

	local isDemoMode = self.space ~= nil and self.space.demoMode == true

	if HomeLandUtils.hasEventData(self) then
		AIControllerUtils.setEnableRVO(self, false, AiConst.RVODisableControlType.HomePetEvent)
	else
		AIControllerUtils.setEnableRVO(self, true, AiConst.RVODisableControlType.HomePetEvent)

		local radius = self.eModel.radius * 0.5
		local ok, GmToolUtils = pcall(require, "Utils.GmToolUtils")

		if ok and GmToolUtils and GmToolUtils.homePetLargeAvoidanceOn == true then
			radius = self.eModel.radius
		end

		if HomeLandUtils.hasAllocationInfo(self) then
			if HomeLandUtils.checkOperIdIsMoving(self.allocationInfo.opId) then
				AIControllerUtils.setEnableRVO(self, false, AiConst.RVODisableControlType.HomePetEvent)
			else
				AIControllerUtils.SetDynamicRVO(self, radius, isDemoMode and 0.8 or 0, 1, 4)
			end
		else
			AIControllerUtils.SetDynamicRVO(self, radius, 0.8, 1, 4)
		end
	end
end

function ClientRVOComponent:enableRVO()
	AIControllerUtils.setEnableRVO(self, true, AiConst.RVODisableControlType.Disable)
end

return ClientRVOComponent
