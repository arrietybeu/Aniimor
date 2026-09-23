-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientSpecialStateRecoverComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local EventConst = require("Const.EventConst")
local PlayableConst = require("Common.Const.PlayableConst")
local NpcFuncData = require("Data.npc_func_data")
local NpcSpecialStateData = require("Data.npc_special_state_data")
local Class = require("Core.Framework.Class")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local ParmonBehaviorGroupData = require("Data.parmon_behavior_group_data")
local ClientSpecialStateRecoverComponent = Class.Component("ClientSpecialStateRecoverComponent")

function ClientSpecialStateRecoverComponent:ctor()
	self.canSpecialStateRecover = true
end

function ClientSpecialStateRecoverComponent:init()
	self:setSpecialState()
end

function ClientSpecialStateRecoverComponent:start()
	self:specialStateUpdate(true)

	function self.specialStateUpdateListener(staticId)
		self:onSpecialStateUpdate(staticId)
	end

	pg.global.eventEmitter:addEventListener(EventConst.NPC_SPECIAL_STATE_UPDATE, self.specialStateUpdateListener)
end

function ClientSpecialStateRecoverComponent:EVENT_onModelLoaded()
	return
end

function ClientSpecialStateRecoverComponent:destroy()
	pg.global.eventEmitter:removeEventListener(EventConst.NPC_SPECIAL_STATE_UPDATE, self.specialStateUpdateListener)

	self.specialStateUpdateListener = nil
end

function ClientSpecialStateRecoverComponent:onSpecialStateUpdate(staticId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("specialContentDict>>>>>update", staticId)
	end

	if staticId and staticId == self.staticId then
		self:specialStateUpdate()
	end
end

function ClientSpecialStateRecoverComponent:setSpecialState()
	local spStateData = self:getSpecialState()

	if spStateData then
		self.spPlayableState = spStateData.state
		self.spTrapEventId = spStateData.trapEventId
		self.newBehavGroupId = spStateData.behavGroupId
		self.spEffs = spStateData.effs
		self.spActionPrototypeIds = spStateData.actionPrototypeIds
		self.spInteractLocalOffset = spStateData.interactLocalOffset
		self.spPrefabResID = spStateData.prefabResID
		self.spAnimController = spStateData.animController
	else
		self.spPlayableState = nil
		self.spTrapEventId = nil
		self.spEffs = nil
		self.spActionPrototypeIds = nil
		self.spPrefabResID = nil
		self.spAnimController = nil
	end
end

function ClientSpecialStateRecoverComponent:specialStateUpdate(isStart)
	self:setSpecialState()

	if self.newBehavGroupId then
		local behavGroupData = ParmonBehaviorGroupData[self.newBehavGroupId]
		local behavTable = behavGroupData.allBehavTable

		for _, eventName in ipairs(behavTable) do
			AIControllerUtils.sendAIEvent(self, eventName, nil)
		end
	end

	self.eventEmitter:emit(EventConst.NPC_SPECIAL_STATE_UPDATE)
	self:playSpInteractChange()
	self:playMasterSpecialState()
	self:playStateEffs()
	self:playInitSpPlayable()

	if not isStart then
		self:playPrefabResOrAnimationCtrlChange()
	end
end

function ClientSpecialStateRecoverComponent:setTeleportFlowerAni()
	local specialStateId = self:getSpecialStateId()

	if specialStateId ~= 100 then
		return
	end

	if not self.eModel then
		return
	end

	local animatorTransform = self.eModel.transform:Find("PlayerBody/ModelRoot/Skeleton/EPrefab_LVCOT_TeleportFlower_01")

	if not animatorTransform then
		self.tickCount = 0
		self._tickTimer = self:addRepeatTimer(1, function()
			self.tickCount = self.tickCount + 1

			if self.tickCount >= 60 then
				self:removeTimer(self._tickTimer)

				return
			end

			local animatorTransform = self.eModel.transform:Find("PlayerBody/ModelRoot/Skeleton/EPrefab_LVCOT_TeleportFlower_01")

			if not animatorTransform then
				return
			end

			animatorTransform.gameObject:GetComponent("Animator"):SetBool("Opened", true)
			self:removeTimer(self._tickTimer)
		end)

		return
	end

	animatorTransform.gameObject:GetComponent("Animator"):SetBool("Opened", true)
end

function ClientSpecialStateRecoverComponent:playStateEffs()
	local effs = self.spEffs or self.effs

	if effs == self.curEffs then
		return
	end

	self.curEffs = effs

	if self.refreshAttachEffects then
		self:refreshAttachEffects()
	end
end

function ClientSpecialStateRecoverComponent:playSpPlayable()
	if self.playAnimation then
		local animKey = self.spPlayableState or PlayableConst.Idle

		self:playAnimation(animKey)
	end
end

function ClientSpecialStateRecoverComponent:playInitSpPlayable()
	if not self.playAnimation then
		return
	end

	if self.spPlayableState then
		self:playAnimation(self.spPlayableState)

		return
	end
end

function ClientSpecialStateRecoverComponent:playMasterSpecialState()
	if self.onMasterSpecialStateUpdate then
		self:onMasterSpecialStateUpdate()
	end
end

function ClientSpecialStateRecoverComponent:playSpInteractChange()
	if self.refreshInteractTrigger then
		self:refreshInteractTrigger()
	end
end

function ClientSpecialStateRecoverComponent:playPrefabResOrAnimationCtrlChange()
	if self.refreshAppearance then
		self:refreshAppearance()
	end
end

function ClientSpecialStateRecoverComponent:getName()
	local spData = self:getSpecialState()

	if spData and spData.name and spData.name ~= "" then
		return spData.name
	end

	local configData = self:getConfigData() or {}

	return configData.name
end

function ClientSpecialStateRecoverComponent:getCareerName()
	local spData = self:getSpecialState()

	if spData and spData.funcRep then
		return spData.funcRep
	end

	local funcData = NpcFuncData[self.templateId] or {}
	local ret = funcData.funcRep

	if not ret and self.getCareerNameFromEnt then
		ret = self:getCareerNameFromEnt()
	end

	return ret
end

function ClientSpecialStateRecoverComponent:getCareerIcon()
	local spData = self:getSpecialState()

	if spData and spData.icon then
		return spData.icon
	end

	local funcData = NpcFuncData[self.templateId] or {}

	return funcData.icon
end

function ClientSpecialStateRecoverComponent:getSpecialStateOwnerPlayer()
	if self.className == "ClientLeylineFlower" and pg.me and pg.me.isUsingSpaceOwnerMap and pg.me:isUsingSpaceOwnerMap() then
		local leader = pg.me:getTeamLeaderPlayer()

		if leader and leader.specialContentDict then
			return leader
		end
	end

	return pg.me
end

function ClientSpecialStateRecoverComponent:getSpecialStateId()
	local player = self:getSpecialStateOwnerPlayer()

	if player and player.specialContentDict then
		local spId = player.specialContentDict[self.staticId]

		return spId or 0
	end

	return 0
end

function ClientSpecialStateRecoverComponent:getSpecialState()
	local player = self:getSpecialStateOwnerPlayer()

	if player and player.specialContentDict then
		local spId = player.specialContentDict[self.staticId]

		if spId then
			return NpcSpecialStateData[spId]
		end
	end
end

return ClientSpecialStateRecoverComponent
