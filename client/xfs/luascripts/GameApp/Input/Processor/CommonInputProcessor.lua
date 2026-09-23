-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Input\\Processor\\CommonInputProcessor.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local Class = require("Core.Framework.Class")
local BaseInputProcessor = require("GameApp.Input.Processor.BaseInputProcessor")
local MessageName = require("Const.MessageName")
local CommonInputProcessor = Class.LightClass("CommonInputProcessor", BaseInputProcessor)

function CommonInputProcessor:onInit()
	BaseInputProcessor.onInit(self)

	self.actionMapKey = HotkeyConst.INPUT_MAP_ACTION_KEY.Common
end

function CommonInputProcessor:handleInGameNavClickAction(inputInfo)
	if inputInfo.phase == "Performed" then
		self.mousePos = inputInfo.valueVec2
	elseif inputInfo.phase == "Canceled" and pg.global.inputMgr ~= nil and self.mousePos then
		pg.global.inputMgr:InGameNaviClick(self.mousePos)
	end
end

return CommonInputProcessor
