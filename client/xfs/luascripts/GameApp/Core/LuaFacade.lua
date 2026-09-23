-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Core\\LuaFacade.lua

local Pg = require("Pg")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local LuaFacade = Class.LightClass("LuaFacade")
local SafeCallback = require("Core.Framework.SafeCallback")

function LuaFacade:ctor(...)
	self.uiMsgMap = {}
	self.uiComponentMsgMap = {}
	self.sysMsgMap = {}
	self.CsEventMap = {}
	self.RevCsEventMap = {}
end

function LuaFacade:RegisterUICommand(messageIndex)
	self.uiMsgMap[messageIndex] = true
end

function LuaFacade:RemoveUICommand(messageIndex)
	self.uiMsgMap[messageIndex] = nil
end

function LuaFacade:RegisterUIComponentCommand(messageIndex)
	self.uiComponentMsgMap[messageIndex] = true
end

function LuaFacade:RemoveUIComponentCommand(messageIndex)
	self.uiComponentMsgMap[messageIndex] = nil
end

function LuaFacade:RegisterSysCommand(messageIndex, systemName, funcName)
	local msgDict = self.sysMsgMap[messageIndex] or {}

	if msgDict[systemName] then
		return
	end

	msgDict[systemName] = funcName
	self.sysMsgMap[messageIndex] = msgDict
end

function LuaFacade:RemoveSysCommand(messageIndex, systemName)
	local msgDict = self.sysMsgMap[messageIndex]

	if msgDict and msgDict[systemName] then
		msgDict[systemName] = nil
	end
end

function LuaFacade:SendMessageCommand(messageIndex, messageBody)
	self:sendMsgToUI(messageIndex, messageBody)
	self:sendMsgToSystem(messageIndex, messageBody)
end

function LuaFacade:sendMsgToUI(messageIndex, messageBody)
	if not self.uiMsgMap[messageIndex] and not self.uiComponentMsgMap[messageIndex] then
		return
	end

	Pg.global.ui:onMessage(messageIndex, messageBody)
end

function LuaFacade:sendMsgToSystem(messageIndex, messageBody)
	local sysMsgDict = self.sysMsgMap[messageIndex]

	if not sysMsgDict then
		return
	end

	local game = Pg.game

	for systemName, funcName in raw_next, sysMsgDict do
		local system = game[systemName]

		if system then
			local func = system[funcName]

			if func then
				SafeCallback(func, system, messageBody)
			end
		end
	end
end

function LuaFacade:registerLuaEvent(eventName, handle)
	if not self.CsEventMap[eventName] then
		self.CsEventMap[eventName] = {}
	end

	self.RevCsEventMap[handle] = eventName

	table.insert(self.CsEventMap[eventName], handle)
end

function LuaFacade:unregisterLuaEvent(handle)
	local eventName = self.RevCsEventMap[handle]

	if not self.CsEventMap[eventName] then
		return
	end

	for i = 1, #self.CsEventMap[eventName] do
		if self.CsEventMap[eventName][i] == handle then
			table.remove(self.CsEventMap[eventName], i)

			break
		end
	end

	self.RevCsEventMap[handle] = nil
end

function LuaFacade:sendLuaEvent(eventName, ...)
	if not self.CsEventMap[eventName] then
		return
	end

	for i = 1, #self.CsEventMap[eventName] do
		appFacade.luaManager:OnLuaEvent(self.CsEventMap[eventName][i], ...)
	end
end

function LuaFacade:getLuaEvent(eventName, ...)
	if not self.CsEventMap[eventName] then
		return
	end

	for i = 1, #self.CsEventMap[eventName] do
		appFacade.luaManager:OnLuaEvent(self.CsEventMap[eventName][i], ...)
	end
end

return LuaFacade
