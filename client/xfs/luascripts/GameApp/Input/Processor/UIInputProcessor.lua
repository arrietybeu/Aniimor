-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Input\\Processor\\UIInputProcessor.lua

local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local Class = require("Core.Framework.Class")
local BaseInputProcessor = require("GameApp.Input.Processor.BaseInputProcessor")
local UIInputProcessor = Class.LightClass("UIInputProcessor", BaseInputProcessor)

function UIInputProcessor:onInit()
	self:setEnabled(true)
end

return UIInputProcessor
