-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\BallEntities\\ClientMagicBall.lua

local class = require("Core.Framework.Class")
local SysConfigData = require("Data.sys_config_data")
local AttributeConst = require("Common.Const.AttributeConst")
local ClientCatchBall = require("Entities.SpaceEntities.BallEntities.ClientCatchBall")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local CaptureWizard = require("GameApp.Capture.CaptureWizard")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local catch_config_data = require("Data.catch_config_data")
local CallbackHandler = require("Core.Common.CallbackHandler")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local NoticeDef = require("Common.NoticeDef")
local Const = require("Common.Const.Const")
local ClientMagicBall = class.Class("ClientMagicBall", ClientCatchBall)

return ClientMagicBall
