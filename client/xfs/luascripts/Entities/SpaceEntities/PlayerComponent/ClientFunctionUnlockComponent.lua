-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientFunctionUnlockComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CommonSwitch = require("Common.CommonSwitch")
local FuncIdConfigData = require("Data.func_index_config_data")
local FunctionUnlockUIIdData = require("Data.function_unlock_ui")
local MessageName = require("Const.MessageName")
local FunctionEnum = require("Data.function_unlock_enum")
local ClientFunctionUnlockComponent = Class.Component("ClientFunctionUnlockComponent")

function ClientFunctionUnlockComponent:ctor()
	return
end

function ClientFunctionUnlockComponent:on_functionUnlocks_changed(oldv, newv)
	for name, state in pairs(newv) do
		if oldv[name] == nil or oldv[name] ~= newv[name] then
			if state == Const.FUNCTION_UNLOCK_STATE.LOCK then
				facade:sendMsgToUI(MessageName.ON_SYSTEM_FUNCTION_LOCKED, name)
			elseif state == Const.FUNCTION_UNLOCK_STATE.UNLOCK then
				facade:sendMsgToUI(MessageName.ON_SYSTEM_FUNCTION_UNLOCKED, name)
			elseif state == Const.FUNCTION_UNLOCK_STATE.SHIELDED then
				facade:sendMsgToUI(MessageName.ON_SYSTEM_FUNCTION_SHIELDED, name)
			end
		end
	end

	local oldChatState = oldv[Const.FUNCTION_NAME.CHAT]
	local newChatState = newv[Const.FUNCTION_NAME.CHAT]

	if oldChatState ~= nil and oldChatState ~= Const.FUNCTION_UNLOCK_STATE.UNLOCK and newChatState == Const.FUNCTION_UNLOCK_STATE.UNLOCK and pg.game and pg.game.chat then
		pg.game.chat:tryInitChatData()
	end

	local _h = ClientFunctionUnlockComponent._platformHooks

	if _h and _h.on_functionUnlocks_changed then
		_h.on_functionUnlocks_changed(self, oldv, newv)
	end

	local discordHooks = ClientFunctionUnlockComponent._discordHooks

	if discordHooks and discordHooks.onFunctionUnlocksChanged then
		discordHooks.onFunctionUnlocksChanged(self, oldv, newv)
	end
end

function ClientFunctionUnlockComponent:on_banNpcFuncInfo_changed(oldv, newv)
	facade:SendMessageCommand(MessageName.ON_NPC_SPECIAL_INTERACTION_REFRESH, {})
end

function ClientFunctionUnlockComponent:initFunctionLockState()
	for name, data in pairs(FuncIdConfigData) do
		if FuncIdConfigData[name].initState ~= nil and FuncIdConfigData[name].initState == Const.FUNCTION_UNLOCK_STATE.LOCK and (self.functionUnlocks[name] == nil or self.functionUnlocks[name] == Const.FUNCTION_UNLOCK_STATE.LOCK) then
			facade:sendMsgToUI(MessageName.ON_SYSTEM_FUNCTION_LOCKED, name)
		end
	end
end

function ClientFunctionUnlockComponent:checkBanNpcFunc(funcMenuId, funcId)
	if self.banNpcFuncInfo[funcMenuId] and self.banNpcFuncInfo[funcMenuId][funcId] ~= nil then
		return self.banNpcFuncInfo[funcMenuId][funcId]
	end

	return false
end

function ClientFunctionUnlockComponent:checkFunctionUnlock(funcName)
	if not LuaUIUtils.checkFuncUnlockForREVIEW(funcName) then
		return false
	end

	if self.functionUnlocks[funcName] == nil then
		if FuncIdConfigData[funcName] ~= nil and FuncIdConfigData[funcName].initState ~= nil then
			if FuncIdConfigData[funcName].initState == Const.FUNCTION_UNLOCK_STATE.LOCK then
				return false
			else
				return true
			end
		else
			return true
		end
	elseif self.functionUnlocks[funcName] == Const.FUNCTION_UNLOCK_STATE.LOCK then
		return false
	else
		return true
	end
end

function ClientFunctionUnlockComponent:checkFunctionShielded(funcName)
	if self.functionUnlocks[funcName] == nil then
		if FuncIdConfigData[funcName] ~= nil and FuncIdConfigData[funcName].initState ~= nil then
			return FuncIdConfigData[funcName].initState == Const.FUNCTION_UNLOCK_STATE.SHIELDED
		else
			return false
		end
	else
		return self.functionUnlocks[funcName] == Const.FUNCTION_UNLOCK_STATE.SHIELDED
	end
end

function ClientFunctionUnlockComponent:checkFunctionUnlockByUIId(uiId)
	local funcName = FunctionUnlockUIIdData[uiId]

	if self.functionUnlocks[funcName] == nil then
		if FuncIdConfigData[funcName] ~= nil and FuncIdConfigData[funcName].initState ~= nil then
			if FuncIdConfigData[funcName].initState == Const.FUNCTION_UNLOCK_STATE.LOCK then
				return false
			else
				return true
			end
		else
			return true
		end
	elseif self.functionUnlocks[funcName] == Const.FUNCTION_UNLOCK_STATE.LOCK then
		return false
	else
		return true
	end
end

function ClientFunctionUnlockComponent:isFunctionAndSwitchEnable(name, needNotify)
	if not FunctionEnum[name] and CommonSwitch[name] == nil then
		self.logger:error("function name not exist", self:repr(), name)

		return false
	end

	if CommonSwitch[name] == false then
		if needNotify then
			pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTIONAL_MAINTENANCE"))
		end

		return false
	end

	if self.functionUnlocks[name] and self.functionUnlocks[name] <= Const.FUNCTION_UNLOCK_STATE.LOCK then
		if needNotify then
			pg.global.ui.tips:showTextTip(pg.getLocalizationText(FunctionEnum[name] and FuncIdConfigData[name].unlockDesc))
		end

		return false
	end

	return true
end

return ClientFunctionUnlockComponent
