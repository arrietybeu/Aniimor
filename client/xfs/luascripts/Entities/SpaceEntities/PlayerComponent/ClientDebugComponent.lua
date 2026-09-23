-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientDebugComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local TimerManager = require("Core.Timer.TimerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local Switch = require("Core.Common.Switch")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local CallbackHandler = require("Core.Common.CallbackHandler")
local AbilityDebugTool = require("Common.Ability.AbilityDebugTool")
local ConditionUtils = require("Common.AICt.ConditionUtils")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local AttributeConst = require("Common.Const.AttributeConst")
local AbilityConst = require("Common.Const.AbilityConst")
local ActionTimelineParams = require("Common.Ability.Timeline.ActionTimelineParams")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local ResPointTemplateData = require("Common.Data.ResPoint.resource_point_temp_data")
local Json = require("Lib.json")
local GmToolUtils = require("Utils.GmToolUtils")
local ImpulseData = require("Data.impulse_data")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local EffectData = require("Data.effect_data")
local EventBus = require("Common.Ability.Buff.EventBus")
local lume = require("Core.Common.lume")
local UIConst = require("Const.UIConst")
local showGrabEggDangerDebugText = false

local function debugInsertLine(t, ...)
	local num = select("#", ...)

	for i = 1, num do
		local v = select(i, ...)

		if v ~= nil then
			table.insert(t, tostring(v))
		end
	end

	table.insert(t, "\n")
end

local function appendGrabEggDangerDebugText(entity, debugText)
	if Utils.isWildPuppet(entity) then
		local configData = entity.getConfigData and entity:getConfigData()
		local baseDangerValue = configData and configData.dangerousValue or 0
		local extraDangerValue = entity.actorCombatAttribute and entity.actorCombatAttribute:getRawAttribValue(AttributeConst.rob_egg_danger_add_v) or 0

		if extraDangerValue ~= 0 then
			debugInsertLine(debugText, "dangerousValue: ", baseDangerValue, "+", extraDangerValue)
		else
			debugInsertLine(debugText, "dangerousValue: ", baseDangerValue)
		end
	elseif pg.pawn == entity then
		local dangerEntity = entity

		if Utils.isPet(entity) then
			dangerEntity = pg.me
		end

		debugInsertLine(debugText, "grabEggDangerValue:", dangerEntity.grabEggDangerValue or 0)

		local dangerStage = dangerEntity.grabEggDangerStage or 0
		local dangerStageInfo = dangerEntity.grabEggDangerStages and dangerEntity.grabEggDangerStages[dangerStage]

		debugInsertLine(debugText, "grabEggDangerBgm:", dangerStageInfo and dangerStageInfo.bgm or "")
	end
end

local ClientDebugComponent = Class.Component("ClientDebugComponent")

function ClientDebugComponent:ctor()
	self.showLineDefine = true
	self.parseDepth = 1
	self.extraDebugInfo = {}
end

function ClientDebugComponent:start()
	if not self.eModel then
		return
	end

	self:refreshDebugTick()

	if self.gmMode == Const.OBSERVE_MODE then
		self:postComponentMethod("onEnterGmObserveMode")

		if self == pg.me and ToBool(self._gmObserveTargetUid) then
			self:attachGmObserveTarget(self._gmObserveTargetUid)
		end
	end
end

function ClientDebugComponent:refreshDebugTick()
	if not _G_IsDebugMode then
		return
	end

	local enableTick = pg.game.setting:getShowDebugText()

	if enableTick then
		if not self.debugTimer then
			self:addEModelComponent(Const.COMPONENT_INDEX_MONO_DEBUG)

			self.debugTimer = self:addRepeatTimer(0.05, CallbackHandler(self, "debugUpdate"))
		end
	elseif self.debugTimer then
		self:removeTimer(self.debugTimer)

		self.debugTimer = nil

		self:delEModelComponent(Const.COMPONENT_INDEX_MONO_DEBUG)
	end
end

function ClientDebugComponent:destroy()
	if self.debugTimer then
		self:removeTimer(self.debugTimer)

		self.debugTimer = nil
	end

	if self.attachObserveTimer then
		TimerManager.removeTimer(self.attachObserveTimer)

		self.attachObserveTimer = nil
	end
end

function ClientDebugComponent:debugUpdate()
	self:refreshDebugInfo()
end

function ClientDebugComponent:refreshDebugInfo()
	if not self:hasEModelComponent(Const.COMPONENT_INDEX_MONO_DEBUG) then
		return
	end

	local debugText = ""

	if self.eModel:CheckShow(Const.COMPONENT_INDEX_MONO_DEBUG) then
		debugText = debugText .. (self:getBaseDebugText() or "")
	end

	self.eModel.debugText = debugText
end

function ClientDebugComponent:RpcSC(methodName, param)
	if _G_IsDebugMode then
		local RpcMethod = require("Core.Common.RpcMethod")
		local CoreConst = require("Core.Common.Const")
		local method = self[methodName]

		if method == nil or not class.isInstanceOf(method, RpcMethod) then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("RpcMethodS no rpc method %s", methodName)
			end

			return
		end

		method(CoreConst.ACCESSOR_SERVER, self, unpack(param))
	end
end

function ClientDebugComponent:getECSDebugInfo()
	local debugInfo = ""
	local strList = {}

	if self.materialParts then
		for index, material in pairs(self.materialParts) do
			if material.ecsEnt == nil then
				table.insert(strList, string.format("part %s nil", tostring(index)))
			else
				table.insert(strList, string.format("part %s %s", tostring(index), material.ecsEnt:getAllCompDesc()))
			end
		end
	end

	debugInfo = strList[1]

	for i = 2, #strList do
		debugInfo = debugInfo .. "\n" .. strList[i]
	end

	return debugInfo
end

function ClientDebugComponent:getBaseDebugText()
	local debugText = {}
	local setting = pg.game.setting

	if setting:getShowDebugTextSimple() then
		if self.actorId and self.actorId ~= 0 then
			debugInsertLine(debugText, "actorId:", self.actorId)
		end

		if ToBool(self.templateId) then
			debugInsertLine(debugText, "templateId:", self.templateId)
		end

		if Utils.isPet(self) and ToBool(self.id) then
			debugInsertLine(debugText, "petId:", self.id)
		end

		if self.isInCombat then
			debugInsertLine(debugText, "isInCombat:", self:isInCombat())
		end
	else
		debugInsertLine(debugText, self.className, self.templateId or "")
		debugInsertLine(debugText, "entId:", self.id)
		debugInsertLine(debugText, "globalId:", self:getGlobalId())

		if self.uid then
			if self.isMainPlayer and self:isFromCopy() then
				debugInsertLine(debugText, "uid:", self:getCopyPlayerUid())
			else
				debugInsertLine(debugText, "uid:", self.uid)
			end

			local pos = self:getPosition()

			if pos ~= nil then
				if self.space and self.space.spaceKey then
					debugInsertLine(debugText, string.format("pos:%.2f, %.2f, %.2f | %s", pos.x, pos.y, pos.z, self.space.spaceKey))
				else
					debugInsertLine(debugText, string.format("pos:%.2f, %.2f, %.2f", pos.x, pos.y, pos.z))
				end
			end
		end

		if self.actorId and self.actorId ~= 0 then
			local gmMode = ""

			if self.gmMode and self.gmMode == 1 then
				gmMode = " | gmMode"
			end

			debugInsertLine(debugText, "actorId:", self.actorId, gmMode)

			if self.isInCombat then
				debugInsertLine(debugText, "isInCombat:", self:isInCombat())
			end

			if self.lockedActorId and self.lockedActorId ~= 0 then
				local lockedEntity = pg.getEntityByActorId(self.lockedActorId)
				local dis = 0

				if lockedEntity then
					dis = Vector3.Distance(self:getPosition(), lockedEntity:getPosition())
				end

				debugInsertLine(debugText, "lockedActorId:", self.lockedActorId or 0, "(", self.lockedPartId, ")", string.format("%.1f m", dis))

				local actorEntity = pg.getEntityByActorId(self.actorId)

				if actorEntity and lockedEntity then
					local actorPosition = actorEntity:getPosition()
					local lockedPosition = lockedEntity:getPosition()

					if actorPosition and lockedPosition then
						local distance = Vector3.Distance(actorPosition, lockedPosition)

						debugInsertLine(debugText, "distance:", distance)
					end
				end
			end
		end

		if self.staticId and self.staticId ~= 0 then
			debugInsertLine(debugText, "staticId:", self.staticId)
		end

		if self.authorityId and self.authorityId ~= "" then
			debugInsertLine(debugText, "authorityId:", self.authorityId)
		end

		if self.playerGame and self.playerGame ~= "" then
			debugInsertLine(debugText, "game:", self.playerGame)
		end

		if self.isBTPaused then
			if self.agent then
				table.insert(debugText, self:isBTPaused() == false and "AI: Running" or "AI: Paused")
			else
				table.insert(debugText, "AI: Detached")
			end

			if self.getAIPlanDebugInfo then
				table.insert(debugText, self:getAIPlanDebugInfo())
			end

			if self.agent then
				table.insert(debugText, "AIState:" .. self.agent:getDebugInfo())
			end

			debugInsertLine(debugText)
		end

		if self.materialParts then
			for index, material in pairs(self.materialParts) do
				if material.ecsEnt == nil then
					debugInsertLine(debugText, "ECS:", "part", index, "nil")
				else
					debugInsertLine(debugText, "ECS:", "part", index, material.ecsEnt:getAllCompDesc())
				end
			end
		end

		if self.getVelocity then
			local velocity = self:getVelocity()

			if velocity ~= nil then
				local speedHor = Vector3(velocity.x, 0, velocity.z)

				table.insert(debugText, "Speed:" .. string.format("%.3f", speedHor.magnitude))
				table.insert(debugText, string.format("|%.3f", velocity.y))
				table.insert(debugText, string.format("|%.3f", self:getPosition().y))
				debugInsertLine(debugText)
			end
		end

		if GmToolUtils and GmToolUtils.gmCatchDebugInfo and Utils.isPuppet(self) and pg.global.ui.hudV2 and CatchProbContext.clientGet(self).canCatch then
			local itemId

			itemId = pg.global.ui.hudV2:getCurSelectPropId()

			local context = CatchProbContext.clientGet(self, itemId)

			debugInsertLine(debugText, context:dump())
		end

		local ccInfo = self.eModel:GetControllerDebugInfo()

		if ccInfo then
			debugInsertLine(debugText, self.eModel:GetControllerDebugInfo())
		end

		if Utils.isPuppet(self) and pg.me and self.staticId and self.staticId ~= 0 then
			debugInsertLine(debugText, "specialState:", pg.me.specialContentDict[self.staticId] or "null")
		end

		if pg.me and pg.me.id ~= self.id and self.getPosition then
			debugInsertLine(debugText, "playerDistance", string.format("%.2f", self:getPlayerDistance()))
		end
	end

	if pg.pawn and pg.pawn.id == self.id then
		debugInsertLine(debugText, self:getSandboxDebugInfo())
	end

	table.clear(self.extraDebugInfo)
	self:postComponentMethod("EVENT_OnAddExtraDebugInfo", self.extraDebugInfo)

	for _, extraInfo in ipairs(self.extraDebugInfo) do
		debugInsertLine(debugText, extraInfo)
	end

	if showGrabEggDangerDebugText then
		appendGrabEggDangerDebugText(self, debugText)
	end

	return table.concat(debugText, "")
end

function ClientDebugComponent:getSandboxDebugInfo()
	if pg.global.ui.racingDungeon:checkUIVisible() and pg.global.ui.racingDungeon.refRacingPlay then
		if not pg.global.ui.racingDungeon.refRacingPlay:isPlaying() then
			return
		end

		local valid, sampleTime, samplePercent = pg.global.ui.racingDungeon.refRacingPlay:getRacingSampleInfo()
		local playTime = pg.global.ui.racingDungeon.refRacingPlay:getPlayTime()

		if not valid then
			return nil
		end

		local score, scorePercent = pg.global.ui.racingDungeon.refRacingPlay:calcScoreAndRatio(sampleTime, samplePercent)

		if not score then
			return "racingTime:" .. string.format("%.1f", playTime - sampleTime) .. "(" .. string.format("%.2f", samplePercent) .. ")"
		end

		local scoreText = "A"

		if score == 0 then
			scoreText = "S"
		elseif score == 2 then
			scoreText = "B"
		end

		return "racingTime:" .. string.format("%.1f", playTime - sampleTime) .. "(" .. string.format("%.2f", samplePercent) .. ")" .. scoreText .. "(" .. string.format("%.2f", scorePercent) .. ")"
	end

	return nil
end

function ClientDebugComponent:globalDrawHitBox(bIsDraw)
	Switch.EnableDrawHitBox = bIsDraw
end

function ClientDebugComponent:globalDrawRbCollider(bIsDraw)
	Switch.EnableDrawRbCollider = bIsDraw
end

function ClientDebugComponent:globalDrawRbCatchCollider(bIsDraw)
	Switch.EnableDrawRbCatchCollider = bIsDraw
end

function ClientDebugComponent:globalDrawSpeedLine(bIsDraw)
	Switch.EnableDrawSpeedCurve = bIsDraw
end

function ClientDebugComponent:globalRuntimeDebugSkill(bIsDebug, abilityId)
	if not bIsDebug then
		self:cancelAbility()
	end

	Switch.EnableRuntimeDebug = bIsDebug
	self.debugAbilityId = abilityId
	self.debugCoroutine = nil

	AbilityDebugTool.switchDebugMode(self.actorId, abilityId, bIsDebug)
end

function ClientDebugComponent:resumeDebugCoroutine()
	local status, ret = AbilityDebugTool.resumeAbilityCastCoroutine()

	if status then
		return
	end

	if AbilityDebugTool.checkProjectileDebugCoroutineSuspended() then
		AbilityDebugTool.resumeProjectileDebugCoroutine()
	end

	if not AbilityDebugTool.mainDebugCoroutine then
		return
	end

	if AbilityDebugTool.ret and AbilityDebugTool.checkMainDebugCoroutineSuspended() then
		if type(AbilityDebugTool.resumeFunction) == "function" and AbilityDebugTool.checkInnerDebugCoroutineSuspended() then
			local status, result = AbilityDebugTool.resumeInnerCoroutine()

			if status then
				if AbilityDebugTool.checkInnerDebugCoroutineSuspended() then
					return
				end
			elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error(result)
			end
		end

		AbilityDebugTool.resumeMainDebugCoroutine()
	end
end

function ClientDebugComponent:setRacialProperty(actorId, racialData)
	local entity = pg.global.actorMgr.getEntity(actorId)

	if entity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("entity is not exist with id: %s", actorId)
		end

		return
	end

	if entity.actorType ~= Const.ACTOR_TYPE_PET and entity.actorType ~= Const.ACTOR_TYPE_PUPPET then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("[CallGM] setRacialProperty", inspect(racialData))
	end

	self:doGmCmd("setSpeciesPoint", actorId, racialData.Hp, racialData.Atk, racialData.Def, racialData.BpAtk, racialData.DefMag, racialData.AtkMag)
end

function ClientDebugComponent:gm_setPosition(actorId, position)
	local entity = pg.global.actorMgr.getEntity(actorId)

	if entity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("entity is not exist with id: %s", actorId)
		end

		return
	end

	if entity.actorType ~= Const.ACTOR_TYPE_PLAYER then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("[CallGM] setPosition")
	end

	self:doGmCmd("gotoByPos", position.x, position.y, position.z)
end

function ClientDebugComponent:gm_setAiState(actorId, state)
	local entity = pg.global.actorMgr.getEntity(actorId)

	if entity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("entity is not exist with id: %s", actorId)
		end

		return
	end

	if entity.actorType ~= Const.ACTOR_TYPE_PET and entity.actorType ~= Const.ACTOR_TYPE_PUPPET then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("[CallGM] setAiState")
	end

	if state == true then
		entity:resumeBtGM()
	else
		entity:pauseBtGM()
	end
end

function ClientDebugComponent:addBuff(actorId, id, duration)
	local entity = pg.global.actorMgr.getEntity(actorId)

	if entity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("entity is not exist with id: %s", actorId)
		end

		return
	end

	if entity.actorType ~= Const.ACTOR_TYPE_PLAYER and entity.actorType ~= Const.ACTOR_TYPE_PET and entity.actorType ~= Const.ACTOR_TYPE_PUPPET then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("[CallGM] addBuff actorId:%s - buffId:%s", actorId, id)
	end

	self:doGmCmd("addBuff", actorId, id, duration)
end

function ClientDebugComponent:removeBuff(actorId, id)
	local entity = pg.global.actorMgr.getEntity(actorId)

	if entity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("entity is not exist with id: %s", actorId)
		end

		return
	end

	if entity.actorType ~= Const.ACTOR_TYPE_PLAYER and entity.actorType ~= Const.ACTOR_TYPE_PET and entity.actorType ~= Const.ACTOR_TYPE_PUPPET then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("[CallGM] delBuff actorId:%s - buffId:%s", actorId, id)
	end

	self:doGmCmd("delBuff", actorId, id)
end

function ClientDebugComponent:addAbility(actorId, id)
	local entity = pg.global.actorMgr.getEntity(actorId)

	if entity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("entity is not exist with id: %s", actorId)
		end

		return
	end

	if entity.actorType ~= Const.ACTOR_TYPE_PLAYER and entity.actorType ~= Const.ACTOR_TYPE_PET and entity.actorType ~= Const.ACTOR_TYPE_PUPPET then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("[CallGM] addAbility actorId:%s - abilityId:%s", actorId, id)
	end

	self:doGmCmd("addSkillNoLimit", actorId, id)
end

function ClientDebugComponent:removeAbility(actorId, id)
	local entity = pg.global.actorMgr.getEntity(actorId)

	if entity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("entity is not exist with id: %s", actorId)
		end

		return
	end

	if entity.actorType ~= Const.ACTOR_TYPE_PLAYER and entity.actorType ~= Const.ACTOR_TYPE_PET and entity.actorType ~= Const.ACTOR_TYPE_PUPPET then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("[CallGM] removeAbility actorId:%s - abilityId:%s", actorId, id)
	end

	self:doGmCmd("delSkill", actorId, id)
end

function ClientDebugComponent:showPuppetSpecies(actorId, action)
	local entity = pg.global.actorMgr.getEntity(actorId)

	if entity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("entity is not exist with id: %s", actorId)
		end

		return
	end

	if entity.actorType ~= Const.ACTOR_TYPE_PUPPET then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("[CallGM] showAttribute")
	end

	self.puppetSpeciesCb = action

	self:doGmCmd("showAttribute", actorId)
end

function ClientDebugComponent:executeDebugInfo(actorId, expression)
	self.codeLine = 0

	if expression == nil then
		return self:toJson(_G)
	end

	local preExpression = expression

	expression = string.gsub(expression, "%s", "")

	local curTb = _G

	if #expression >= 4 and string.sub(expression, 1, 4) == "self" then
		expression = string.sub(expression, 5)
		curTb = pg.global.actorMgr.getEntity(actorId)
	end

	if #expression > 0 then
		curTb = self:parseExpressionSymbol(curTb, expression)
	end

	if type(curTb) == "table" then
		return self:toJson(curTb)
	else
		self.codeLine = self.codeLine + 1

		return string.format("\n%d\t%s = %s", self.codeLine, preExpression, tostring(curTb))
	end
end

function ClientDebugComponent:parseExpressionSymbol(curTb, expression)
	local index = 1
	local crashIndex = 1
	local maxIndex = #expression
	local nameTb = {}
	local curSymbol, preSymbol, keyName

	local function parseAheadVariable(pre, isFunc)
		if curSymbol then
			preSymbol = curSymbol
		end

		curSymbol = pre

		if #nameTb == 0 then
			return
		end

		keyName = table.concat(nameTb)
		nameTb = {}
		expression = string.sub(expression, index)
		index = 1

		if not isFunc then
			curTb = curTb[keyName]
		else
			local func = curTb[keyName]

			return func
		end
	end

	while #expression > 0 and index <= #expression and crashIndex <= maxIndex do
		local byte = string.byte(expression, index)
		local char = string.char(byte)

		if char == "[" then
			parseAheadVariable(char)

			local endIds = string.find(expression, "]")
			local match = string.sub(expression, 1, endIds)
			local sIds = string.match(match, "%['(.-)'%]")

			if sIds then
				curTb = curTb[sIds]
			else
				local nIds = string.match(match, "%[(%d+)%]")

				curTb = curTb[tonumber(nIds)]
			end

			expression = string.sub(expression, endIds + 1)
		elseif char == "(" then
			local func = parseAheadVariable(char, true)
			local endIds = string.find(expression, ")")
			local realArgs = {}

			if endIds > index + 1 then
				local match = string.sub(expression, 2, endIds - 1)
				local args = string.split(match, ",")

				for i, v in ipairs(args) do
					if string.match(v, "'") then
						realArgs[i] = string.gsub(v, "'", "")
					elseif string.match(v, "\"") then
						realArgs[i] = string.gsub(v, "\"", "")
					elseif v == "false" then
						realArgs[i] = false
					elseif v == "true" then
						realArgs[i] = true
					elseif string.startsWith(v, "{") then
						local tb = Json.decode(v)

						realArgs[i] = tb
					else
						realArgs[i] = tonumber(v)
					end
				end
			end

			if func then
				local success, result

				if preSymbol == ":" then
					success, result = pcall(func, curTb, table.unpack(realArgs))
				else
					success, result = pcall(func, table.unpack(realArgs))
				end

				if success then
					curTb = result
				else
					curTb = string.format("call function failure with error %s", result)

					break
				end
			end

			expression = string.sub(expression, endIds + 1)
		elseif char == ":" then
			parseAheadVariable(char)

			expression = string.sub(expression, 2)
		elseif char == "." then
			parseAheadVariable(char)

			expression = string.sub(expression, 2)
		else
			index = index + 1

			table.insert(nameTb, char)
		end

		if curTb == nil then
			curTb = string.format("error -> field [%s] is nil.", keyName)

			break
		end

		crashIndex = crashIndex + 1
	end

	parseAheadVariable()

	return curTb
end

function ClientDebugComponent:toJson(tbl)
	local depth = 0
	local codeArray = {}

	self:toJsonInternal(tbl, codeArray, depth)

	local str = table.concat(codeArray)

	return string.gsub(str, "[^\x01-\x7F]", "?")
end

function ClientDebugComponent:toJsonInternal(tbl, codeArray, depth)
	depth = depth + 1

	table.insert(codeArray, self:additionCodeLine(depth) .. " {")

	for k, v in pairs(tbl) do
		local key = type(k) == "number" and string.format("[%d]", k) or tostring(k)
		local value

		if type(v) == "table" then
			if depth < self.parseDepth then
				table.insert(codeArray, string.format("\n%s\t%s = \n", self:additionCodeLine(depth), key))
				self:toJsonInternal(v, codeArray, depth)
			else
				value = "{...}"
			end
		elseif type(v) == "string" then
			value = v
		else
			value = tostring(v)
		end

		if value then
			table.insert(codeArray, string.format("\n%s\t%s = %s", self:additionCodeLine(depth), key, value))
		end
	end

	table.insert(codeArray, "\n" .. self:additionCodeLine(depth) .. " }")
end

function ClientDebugComponent:additionCodeLine(depth)
	local tab = string.rep("\t", depth - 1)

	if self.showLineDefine == false then
		return string.format("%s", tab)
	end

	local curLine = self.codeLine

	self.codeLine = self.codeLine + 1

	return string.format("%d%s", curLine, tab)
end

function ClientDebugComponent:setParseDepth(depth)
	self.parseDepth = depth or 1
end

function ClientDebugComponent:drawCodeLine(draw)
	self.showLineDefine = draw
end

function ClientDebugComponent:switchAICtrSimpleDebugMode(open, actorId)
	ConditionUtils.switchSimpleDebugMode(open, actorId)
end

function ClientDebugComponent:getAIStackInfo()
	return ConditionUtils.getAIStackInfo()
end

function ClientDebugComponent:switchAICtrBreakDebugMode(graphId, open)
	ConditionUtils.switchAICtrBreakDebugMode(graphId, open)
end

function ClientDebugComponent:bindToCSharpGraphFunc(graphId, startGraphAction, executeNodeAction, endGraphAction)
	ConditionUtils.bindToCSharpGraphFunc(graphId, startGraphAction, executeNodeAction, endGraphAction)
end

function ClientDebugComponent:getEntities()
	local actorIds = {}
	local allEntity = pg.global.entityMgr.getAllEntities()

	for _, entity in pairs(allEntity) do
		if entity.AIPlan ~= nil then
			actorIds[#actorIds + 1] = entity.actorId
		end
	end

	return actorIds
end

function ClientDebugComponent:getEntityCTRGraphList(actorId)
	local entity = pg.global.actorMgr.getEntity(tonumber(actorId))

	if entity.AIPlan == nil then
		return {}
	end

	return entity:getDebugRegisteredGraphs()
end

function ClientDebugComponent:debugSetHpCurMax(cur, max)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("debugSetHpCurMax", self.actorId, cur, max)
	end

	pg.me:doGmCmd("setAttribute", self.actorId, AttributeConst.ID2NAME[AttributeConst.hp_max_cur], max)
	pg.me:doGmCmd("setAttribute", self.actorId, AttributeConst.ID2NAME[AttributeConst.hp_cur], cur)
end

function ClientDebugComponent:getResPointInfo()
	local res = {}

	if self.resPoints == nil then
		return res
	end

	for _, v in pairs(self.resPoints) do
		local cData = ResPointTemplateData[v.templateId]

		res[v.templateId] = cData and cData.name or "not exist"
	end

	return res
end

function ClientDebugComponent:debugCastAbility(abilityId, targetActorId, partId)
	if self.gmMode ~= 1 then
		pg.me:doGmCmd("setEntityGmMode", self.actorId, 1)
	end

	TimerManager.addNextFrameCb(function()
		local targetEntity = pg.getEntityByActorId(targetActorId)

		if not targetEntity then
			self:clientCastAbilityNoTarget(abilityId, nil, {
				partId = partId
			})
		else
			self:clientCastAbilityOnTarget(abilityId, targetActorId, nil, {
				partId = partId
			})
		end
	end)
end

function ClientDebugComponent:getCachaValListenObserver()
	if self.debugCacheValObserver == nil then
		self.debugCacheValObserver = EventBus.EventObserver()
	end

	return self.debugCacheValObserver
end

function ClientDebugComponent:insertNewEntityCacheValChangeInfo(key)
	if self.debugListenEntityCacheValChangeInfo == nil then
		self.debugListenEntityCacheValChangeInfo = {}
	end

	self.debugListenEntityCacheValChangeInfo[key] = AbilityDebugTool.getCacheValElementDesc(self, key)
end

function ClientDebugComponent:addDebugListenEntityCacheVal(key)
	local observer = self:getCachaValListenObserver()

	if self.debugListenEntityCacheValMap == nil then
		self.debugListenEntityCacheValMap = {}
	end

	if self.subject and not observer:isListening(self.subject, AbilityConst.COMBAT_EVENT_ON_CACHE_VAL_CHANGE) then
		observer:listen(self.subject, AbilityConst.COMBAT_EVENT_ON_CACHE_VAL_CHANGE, function(key)
			if self.debugListenEntityCacheValMap[key] then
				self:insertNewEntityCacheValChangeInfo(key)
			end
		end)
	end

	self.debugListenEntityCacheValMap[key] = true

	return AbilityDebugTool.getCacheValElementDesc(self, key)
end

function ClientDebugComponent:removeDebugListenEntityCacheVal(key)
	if self.debugListenEntityCacheValMap and self.debugListenEntityCacheValMap[key] then
		self.debugListenEntityCacheValMap[key] = nil
	end

	if self.debugListenEntityCacheValChangeInfo and self.debugListenEntityCacheValChangeInfo[key] then
		self.debugListenEntityCacheValChangeInfo[key] = nil
	end

	if not ToBool(self.debugListenEntityCacheValMap) then
		if self.subject then
			local observer = self:getCachaValListenObserver()

			observer:unlisten(self.subject, AbilityConst.COMBAT_EVENT_ON_CACHE_VAL_CHANGE)
		end

		lume.clear(self.debugListenEntityCacheValChangeInfo)
	end
end

function ClientDebugComponent:getEntityCacheValChangeList()
	if ToBool(self.debugListenEntityCacheValChangeInfo) then
		local ret = Utils.deepCopyTable(self.debugListenEntityCacheValChangeInfo)

		lume.clear(self.debugListenEntityCacheValChangeInfo)

		return ret
	end

	return nil
end

function ClientDebugComponent:insertNewServerCacheValChangeInfo(key)
	if self.debugListenServerCacheValChangeInfo == nil then
		self.debugListenServerCacheValChangeInfo = {}
	end

	self.debugListenServerCacheValChangeInfo[key] = AbilityDebugTool.getCacheValElementDesc(self, key, true)
end

function ClientDebugComponent:addDebugListenServerCacheVal(key)
	local observer = self:getCachaValListenObserver()

	if self.debugListenServerCacheValMap == nil then
		self.debugListenServerCacheValMap = {}
	end

	if self.subject and not observer:isListening(self.subject, AbilityConst.COMBAT_EVENT_ON_SERVER_CACHE_VAL_CHANGE) then
		observer:listen(self.subject, AbilityConst.COMBAT_EVENT_ON_SERVER_CACHE_VAL_CHANGE, function(key)
			if self.debugListenServerCacheValMap[key] then
				self:insertNewServerCacheValChangeInfo(key)
			end
		end)
	end

	self.debugListenServerCacheValMap[key] = true

	return AbilityDebugTool.getCacheValElementDesc(self, key, true)
end

function ClientDebugComponent:removeDebugListenServerCacheVal(key)
	if self.debugListenServerCacheValMap and self.debugListenServerCacheValMap[key] then
		self.debugListenServerCacheValMap[key] = nil
	end

	if self.debugListenServerCacheValChangeInfo and self.debugListenServerCacheValChangeInfo[key] then
		self.debugListenServerCacheValChangeInfo[key] = nil
	end

	if not ToBool(self.debugListenServerCacheValMap) then
		if self.subject then
			local observer = self:getCachaValListenObserver()

			observer:unlisten(self.subject, AbilityConst.COMBAT_EVENT_ON_SERVER_CACHE_VAL_CHANGE)
		end

		lume.clear(self.debugListenServerCacheValChangeInfo)
	end
end

function ClientDebugComponent:getServerCacheValChangeList()
	if ToBool(self.debugListenServerCacheValChangeInfo) then
		local ret = Utils.deepCopyTable(self.debugListenServerCacheValChangeInfo)

		lume.clear(self.debugListenServerCacheValChangeInfo)

		return ret
	end

	return nil
end

function ClientDebugComponent:refreshGmStatus()
	local UIConst = require("Const.UIConst")

	pg.game.input:refreshTempInput()

	local enableGm = Utils.enableClientUseGm(pg.me)

	if pg.global.ui:checkUIShow(UIConst.UI_ID_HUD_V2) then
		pg.global.ui.hudV2:changeGmBtnVisible(enableGm)
	end

	if not enableGm then
		GmToolUtils.clearGmList()
	end
end

function ClientDebugComponent:RPC_SC_OpenClientGmPanel()
	pg.global.ui.config:open()
	self:refreshGmStatus()
end

function ClientDebugComponent:RPC_SC_CloseClientGmPanel()
	pg.global.ui.config:close()
	self:refreshGmStatus()
end

function ClientDebugComponent:RPC_SC_EnableCombatLogger(enable)
	Switch.CombatDebug = enable
end

function ClientDebugComponent:RPC_SC_BlockOtherPlayerAudio(enable)
	pg.game.audio:setBlockOtherPlayerAudio(enable)
end

function ClientDebugComponent:RPC_SC_DebugGrabEggDangerEntityInfo(enable)
	showGrabEggDangerDebugText = ToBool(enable)
end

function ClientDebugComponent:RPC_SC_DisableWeightPush(disable)
	CS.FunPlus.WorldX.Entities.Components.MotionComponent.enableWeightPush = not disable
end

function ClientDebugComponent:RPC_SC_DebugShowEntHates(actorId)
	local targetEnt = pg.getEntityByActorId(actorId)

	if targetEnt and targetEnt.getGMHatredInfo then
		local info = targetEnt:getGMHatredInfo()

		pg.game.chat:recvSystemNotice(info)
		print(info)
	end
end

function ClientDebugComponent:debugHitTimeline(impulseId)
	local impulseData = ImpulseData[impulseId]

	if not impulseData then
		return
	end

	local impulseType = impulseData.impulseType
	local timelineName = self:inBreak() and AbilityConst.ATTACK_BREAK_FORCE_TO_TIMELINE_NAME[impulseType] or AbilityConst.ATTACK_FORCE_TO_TIMELINE_NAME[impulseType]
	local dir

	if self == pg.pawn then
		dir = Quaternion.MulVec3(self:getRotation(), Vector3.forward)
	else
		dir = pg.pawn:getPosition() - self:getPosition()
		dir.y = 0

		Vector3.SetNormalize(dir)
	end

	local rot = Quaternion.LookRotation(dir, Vector3.up)
	local finalHitTimelineId = AbilitySettingGlobalConstData[timelineName]

	dir = Quaternion.MulVec3(rot, Vector3(0, 0, -1))

	local attackForceType = impulseType
	local hitActionTimelineParam = ActionTimelineParams.HitActionTimelineParam()

	hitActionTimelineParam.combatContextId = self:genCombatContextId()

	hitActionTimelineParam:init(impulseId, dir, attackForceType, self)
	self.actorTimeline:setTimeline(finalHitTimelineId, 1, hitActionTimelineParam)

	return finalHitTimelineId
end

function ClientDebugComponent:debugGetImpulseDataList()
	local list = {}

	for key, info in pairs(ImpulseData) do
		table.insert(list, {
			key,
			info.name
		})
	end

	table.sort(list, function(a, b)
		return a[1] < b[1]
	end)

	return list
end

function ClientDebugComponent:debugGetImpulseName(impulseId)
	return (ImpulseData[impulseId] or EMPTY_TABLE).name
end

function ClientDebugComponent:debugGetBuffName(buffId)
	return ClientAbilityUtils.getBuffName(buffId)
end

function ClientDebugComponent:debugGetEffectNameList()
	local ret = {}

	for key, info in pairs(EffectData) do
		ret[key] = info
	end

	return ret
end

function ClientDebugComponent:debugPlayEffect(effectName, duration, forceLodLevel)
	if self.playEffect then
		self:playEffect(effectName, {
			duration = duration or 1,
			forceLodLevel = forceLodLevel
		})
		self:serverMsg("RPC_CS_SyncDebugPlayEffect", effectName, duration or 1, forceLodLevel or -1)
	end

	return true
end

function ClientDebugComponent:debugRemoveEffect(effectName)
	if self.stopEffect then
		self:stopEffect(effectName)
	end

	return true
end

function ClientDebugComponent:onEnterGmObserveMode()
	self.logger:info("onEnterGmObserveMode", self.id)
	self:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.GM_OBSERVER_MODE, false)
	self:setCollideEnable(ClientConst.MODEL_VISIBLE_KEY.GM_OBSERVER_MODE, false)

	if self == pg.me then
		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.GM_OBSERVE)
	end
end

function ClientDebugComponent:onExitGmObserveMode()
	self.logger:info("onExitGmObserveMode", self.id)
	self:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.GM_OBSERVER_MODE, true)
	self:setCollideEnable(ClientConst.MODEL_VISIBLE_KEY.GM_OBSERVER_MODE, true)

	if self == pg.me then
		if self.attachObserveTimer then
			TimerManager.removeTimer(self.attachObserveTimer)

			self.attachObserveTimer = nil
		end

		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.GM_OBSERVE)
	end
end

function ClientDebugComponent:RPC_SC_SyncDebugPlayEffect(effectName, duration, forceLodLevel)
	if self.playEffect then
		self:playEffect(effectName, {
			duration = duration or 1,
			forceLodLevel = forceLodLevel
		})
	end
end

function ClientDebugComponent:botServerTest(count, methodName, args)
	local GlobalData = require("Core.Client.GlobalData")

	if GlobalData.Bot then
		if GlobalData.Bot.ServiceIdMap == nil then
			GlobalData.Bot.ServiceIdMap = {}
		end

		GlobalData.Bot.ServiceIdMap[methodName] = 0

		for i = 1, count do
			local serviceMarkId = string.format("BotServerTest_%s_%s_%d", GlobalData.Bot.uid, methodName, i)

			self.logger:info("BotServerTest call server method:%s, markId:%s", methodName, serviceMarkId)
			GlobalData.Bot:SetMark(methodName, serviceMarkId)
		end
	end

	self:serverMsg("RPC_CS_BotServerTest", count, methodName, args)
end

function ClientDebugComponent:RPC_SC_BotServerTestRet(methodName, args)
	self:_botServerTestRetImp(methodName, args)
end

function ClientDebugComponent:_botServerTestRetImp(methodName, args)
	return
end

function ClientDebugComponent:RPC_SC_AttachGmObserveTarget(targetUid)
	self:attachGmObserveTarget(targetUid)
end

function ClientDebugComponent:attachGmObserveTarget(targetUid)
	self.logger:info("@gm attachGmObserveTarget ", self.actorId, self.id, targetUid)

	local targetEntity = pg.getEntityByUid(targetUid)

	if self.attachObserveTimer then
		TimerManager.removeTimer(self.attachObserveTimer)
	end

	if not targetEntity then
		self.attachObserveTimer = TimerManager.addRepeatTimer(0.1, function()
			local ent = pg.getEntityByUid(targetUid)

			if ent then
				TimerManager.removeTimer(self.attachObserveTimer)

				self.attachObserveTimer = nil
				self.eModel.followEntity = ent.eModel
				self.eModel.checkFollowVisible = false

				self.eModel:SetMotionEnable(Const.COMPONENT_MOTION, false, Const.MotionDisableReason.Authority)
			end
		end)
	else
		self.eModel.followEntity = targetEntity.eModel
		self.eModel.checkFollowVisible = false

		self.eModel:SetMotionEnable(Const.COMPONENT_MOTION, false, Const.MotionDisableReason.Authority)
	end
end

function ClientDebugComponent:RPC_SC_DetachGmObserveTarget()
	self.logger:info("@gm RPC_SC_DetachGmObserveTarget ", self.id)

	if self.attachObserveTimer then
		TimerManager.removeTimer(self.attachObserveTimer)

		self.attachObserveTimer = nil
	end

	self.eModel.followEntity = nil
end

return ClientDebugComponent
