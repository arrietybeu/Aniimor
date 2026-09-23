-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientAreaHandlerComponent.lua

local CommonConst = require("Common.Const.Const")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local LuaCondition = require("Common.Utils.LuaCondition")
local MessageName = require("Const.MessageName")
local Time = require("Core.Common.Time")
local VolumeEffectConst = require("Const.VolumeEffectConst")
local Utils = require("Common.Utils.Utils")
local ClientAreaHandlerComponent = Class.Component("ClientAreaHandlerComponent")
local StateCommand = {
	Clear = 3,
	Remove = 2,
	Add = 1
}

function ClientAreaHandlerComponent:start()
	return
end

function ClientAreaHandlerComponent:EVENT_AddEComponent()
	self.areas = {}
	self.area2LogicCache = {}
	self.areaStateMap = {}

	self:addEModelComponent(CommonConst.COMPONENT_AREA_HANDLER)
end

function ClientAreaHandlerComponent:getAreaLogic(id)
	if self.area2LogicCache[id] then
		return self.area2LogicCache[id]
	end

	local areaData = self.space and self.space:getAreaData(id)

	if areaData == nil then
		return
	end

	for inx, logic in ipairs(areaData.logics) do
		if LuaCondition.checkCondition(self, logic.condition) then
			self.area2LogicCache[id] = logic

			return logic
		end
	end

	if pg.game.seamless:seam_sys_isSeamlessType(areaData.areaLoadType) or pg.game.seamless:seam_sys_isMappingRegionType(areaData.areaLoadType) then
		return {}
	end
end

function ClientAreaHandlerComponent:shouldCheckInControl(id)
	local logic = self:getAreaLogic(id)

	if logic and logic.checkEntityInControl then
		return true
	end

	return false
end

function ClientAreaHandlerComponent:enterArea(id)
	local logic = self:getAreaLogic(id)

	if logic then
		self.areas[#self.areas + 1] = id

		if not Utils.isPlayer(self) or self.isMainPlayer then
			self:serverMsg("RPC_CS_UpdateAreaInfo", self.areas)
		end

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:log2Tag("LuaVerbose", "enterArea", id)
		end

		if logic.states then
			for i, state in ipairs(logic.states) do
				self:addAreaState(state, id, i)
			end
		end
	end

	if self.isMainPlayer then
		pg.game.seamless:seam_sys_enterArea(id)
	end
end

function ClientAreaHandlerComponent:exitArea(id, isClear)
	local logic = self:getAreaLogic(id)

	if logic then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:log2Tag("LuaVerbose", "exitArea", id)
		end

		if not isClear then
			RemoveTableItemNoOrder(self.areas, id, true)

			if not Utils.isPlayer(self) or self.isMainPlayer then
				self:serverMsg("RPC_CS_UpdateAreaInfo", self.areas)
			end
		end

		if logic.states then
			for i, state in ipairs(logic.states) do
				self:removeAreaState(state, id, i)
			end
		end
	end

	if self.socialAreaList ~= nil and self.socialAreaList[id] == true then
		self:setInSocialArea(false, id)
	end

	if self.isMainPlayer then
		pg.game.seamless:seam_sys_exitArea(id)
	end
end

function ClientAreaHandlerComponent:disableAreaHandler()
	for _, areaId in ipairs(self.areas) do
		self:exitArea(areaId, true)
	end

	self.areas = {}
end

local function makeSourceKey(areaId, idx)
	return areaId * 1000 + idx
end

function ClientAreaHandlerComponent:addAreaState(state, areaId, idx)
	local stateName = state[1]
	local bucket = self.areaStateMap[stateName]

	if not bucket then
		bucket = {
			sources = {},
			list = {}
		}
		self.areaStateMap[stateName] = bucket
	end

	local key = makeSourceKey(areaId, idx)

	if bucket.sources[key] then
		return
	end

	bucket.sources[key] = state
	bucket.list[#bucket.list + 1] = state

	local refreshFunc = self["refreshState_" .. stateName]

	if refreshFunc then
		refreshFunc(self, bucket.list, StateCommand.Add, state)
	end
end

function ClientAreaHandlerComponent:removeAreaState(state, areaId, idx)
	local stateName = state[1]
	local bucket = self.areaStateMap[stateName]

	if not bucket then
		return
	end

	local key = makeSourceKey(areaId, idx)

	if not bucket.sources[key] then
		return
	end

	bucket.sources[key] = nil

	RemoveTableItem(bucket.list, state)

	local refreshFunc = self["refreshState_" .. stateName]

	if refreshFunc then
		refreshFunc(self, bucket.list, StateCommand.Remove, state)
	end
end

function ClientAreaHandlerComponent:refreshState_ConflictState(states)
	local changedStateNames = {}

	for stateName in pairs(self.customCheckStates) do
		changedStateNames[stateName] = true
	end

	table.clear(self.customCheckStates)

	for _, state in ipairs(states) do
		local conflictStateName = state[2]

		self.customCheckStates[conflictStateName] = true
		changedStateNames[conflictStateName] = true
	end

	if self.updateStateCache then
		for stateName in pairs(changedStateNames) do
			self:updateStateCache(stateName)
		end
	end

	if self.isMainPlayer and pg.game and pg.game.markShare then
		pg.game.markShare:refreshInfoStampAreaForceHide()
	end
end

function ClientAreaHandlerComponent:refreshState_DisableModule(states, command, arg)
	if not self.isMainPlayer and not self.isMainPet then
		return
	end

	if command == StateCommand.Add then
		local addState = arg
		local addKey = addState[2]
		local isRepeat = false

		for _, state in ipairs(states) do
			local moduleKey = state[2]

			if state ~= addState and moduleKey == addKey then
				isRepeat = true

				break
			end
		end

		if not isRepeat then
			pg.game:setModuleEnable(self.id, addKey, false)
		end
	elseif command == StateCommand.Remove then
		local removeState = arg
		local removeKey = removeState[2]
		local isRepeat = false

		for _, state in ipairs(states) do
			local moduleKey = state[2]

			if moduleKey == removeKey then
				isRepeat = true

				break
			end
		end

		if not isRepeat then
			pg.game:setModuleEnable(self.id, removeKey, true)
		end
	elseif command == StateCommand.Clear then
		for _, state in ipairs(states) do
			pg.game:setModuleEnable(self.id, state[2], true)
		end
	end
end

function ClientAreaHandlerComponent:refreshState_ShortHole(states)
	local inShortHole = #states > 0

	self.inShortHole = inShortHole

	if self:BURROW_ST() then
		if inShortHole then
			pg.game.camera.playerCameraMode.sneakCamera:enterShortHole()
		else
			pg.game.camera.playerCameraMode.sneakCamera:leaveShortHole()
		end
	end
end

function ClientAreaHandlerComponent:refreshState_AuxEnvState(states)
	if #states > 0 then
		local environmentBus = states[1][2]

		self.auxEnvState = environmentBus
	else
		self.auxEnvState = nil
	end
end

function ClientAreaHandlerComponent:refreshState_InFog(states, command, args)
	local inFogArea = command ~= StateCommand.Clear and #states > 0

	if inFogArea and not self.inFogArea then
		if self.onAIEnterFog then
			self:onAIEnterFog()
		end
	elseif self.inFogArea and not inFogArea and self.onAIExitFog then
		self:onAIExitFog()
	end

	self.inFogArea = inFogArea

	if self.updateStateCache then
		self:updateStateCache("FOGAREA_ST")
	end

	local isControllingPet = pg.game.controller:isInControlEnt()

	if self.isMainPlayer or self.isMainPet and isControllingPet then
		local volumeEffectKey = VolumeEffectConst.FOG_CLOUD_EFFECT

		if self.inFogArea then
			pg.game.camera:addVolumeEffect(volumeEffectKey)
		else
			pg.game.camera:delVolumeEffect(volumeEffectKey)
		end
	end

	if self.isMainPlayer or self.isMainPet then
		facade:SendMessageCommand(MessageName.SPECIAL_STATE_CHANGE)
	end
end

function ClientAreaHandlerComponent:refreshState_ForceControlPet(states)
	local isForceControlPet = #states > 0

	self.isForceControlPet = isForceControlPet
end

function ClientAreaHandlerComponent:refreshState_AreaLimit(states)
	if not self.isMainPlayer then
		return
	end

	local isInAreaLimit = #states > 0

	if self.isInAreaLimit == isInAreaLimit then
		return
	end

	self.isInAreaLimit = isInAreaLimit

	if self.isInAreaLimit then
		local _, duration, title, effectId = unpack(states[1])
		local progress = {
			autoUpdate = true,
			state = 1,
			progress = 0,
			duration = duration,
			title = pg.getGameString(title),
			startTime = Time.realSecondCache
		}

		facade:SendMessageCommand(MessageName.UPDATE_PROGRESS_DISENGAGE, progress)

		self.areaLimitTimer = self:addTimer(duration, function()
			pg.pawn:checkKnockUpState()

			local isBacktrackPos, pos, rotYawEuler = self:tryGetValidBacktrackData(1, 2)

			if isBacktrackPos then
				self:serverMsg("RPC_CS_SetBacktrackPos")
			end

			self:serverMsg("RPC_CS_ResetPosByRecord", pos, rotYawEuler)
		end)
		self.areaLimitEffId = self:playEffect(effectId)

		self.eModel:TweenLocalEnvWeight(CommonConst.COMPONENT_INDEX_EFFECT, effectId, 0, 1, duration)
	else
		if self.areaLimitTimer then
			self:removeTimer(self.areaLimitTimer)

			self.areaLimitTimer = nil
		end

		facade:SendMessageCommand(MessageName.EXIT_PROGRESS_DISENGAGE, 1)

		if self.areaLimitEffId then
			self:stopEffectById(self.areaLimitEffId)

			self.areaLimitEffId = nil
		end
	end
end

function ClientAreaHandlerComponent:destroy()
	if self.areaStateMap == nil then
		return
	end

	for name, bucket in pairs(self.areaStateMap) do
		local refreshFunc = self["refreshState_" .. name]

		if #bucket.list > 0 and refreshFunc then
			refreshFunc(self, bucket.list, StateCommand.Clear)
		end
	end
end

function ClientAreaHandlerComponent:setInSocialArea(inArea, areaId)
	if self.socialAreaList == nil then
		self.socialAreaList = {}
	end

	if inArea == true then
		self.socialAreaList[areaId] = true

		if self.isMainPlayer == true and pg.me ~= nil then
			pg.me:serverMsg("RPC_CS_PlayerEnterCafeArea", areaId)
		end
	else
		self.socialAreaList[areaId] = nil

		if self.isMainPlayer == true and pg.me ~= nil then
			pg.me:serverMsg("RPC_CS_PlayerLeaveCafeArea", areaId)
		end
	end
end

return ClientAreaHandlerComponent
