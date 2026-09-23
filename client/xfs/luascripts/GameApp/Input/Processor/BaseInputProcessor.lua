-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Input\\Processor\\BaseInputProcessor.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local Class = require("Core.Framework.Class")
local BaseInputProcessor = Class.LightClass("BaseInputProcessor")

function BaseInputProcessor:ctor(path)
	self.isEnabled = true
	self.path = path
	self.triggerActions = {}
end

function BaseInputProcessor:onInit()
	return
end

function BaseInputProcessor:enableInputMap(mapName, enabled)
	self.isEnabled = enabled

	self:onEnableInputMap(mapName, enabled)
end

function BaseInputProcessor:setEnabled(enabled)
	pg.game.input:setInputMapEnabled(self.path, enabled, HotkeyConst.INPUT_BLOCK_FLAG.Default)
end

function BaseInputProcessor:onEnableInputMap(mapName, enabled)
	return
end

function BaseInputProcessor:handleActionTriggered(inputInfo)
	local actionName = inputInfo.actionName
	local phase

	if inputInfo:CheckBlocked() then
		if not self.triggerActions[actionName] then
			return true
		else
			phase = "Canceled"
			inputInfo.phase = phase
		end
	end

	phase = phase or inputInfo.phase

	if phase == "Performed" then
		self.triggerActions[actionName] = true
	elseif phase == "Canceled" then
		self.triggerActions[actionName] = nil
	end

	local func = self[string.format("handle%sAction", actionName)]

	if func ~= nil then
		return func(self, inputInfo)
	end

	return true
end

function BaseInputProcessor:onBlockByUI(isBlock)
	return
end

return BaseInputProcessor
