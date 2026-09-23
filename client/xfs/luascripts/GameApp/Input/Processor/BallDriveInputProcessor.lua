-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Input\\Processor\\BallDriveInputProcessor.lua

local ClientConst = require("Const.ClientConst")
local EventConst = require("Const.EventConst")
local HotkeyConst = require("Const.HotkeyConst")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local Class = require("Core.Framework.Class")
local BaseInputProcessor = require("GameApp.Input.Processor.BaseInputProcessor")
local ConflictTypes = require("Common.ConflictTypes")
local Timer = require("Core.Timer.Timer")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local BallDriveInputProcessor = Class.LightClass("BallDriveInputProcessor", BaseInputProcessor)

function BallDriveInputProcessor:onInit()
	BaseInputProcessor.onInit(self)
end

return BallDriveInputProcessor
