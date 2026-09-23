-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BlackScreen\\BlackScreenCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("BlackScreenCtrl")
local DialogueConst = require("Const.DialogueConst")
local Class = require("Core.Framework.Class")
local ScreenCtrlBase = require("Guis.Panels.BlackScreen.ScreenCtrlBase")
local BlackScreenCtrl = Class.LightClass("BlackScreenCtrl", ScreenCtrlBase)

function BlackScreenCtrl:init()
	ScreenCtrlBase.init(self)

	self.SCREEN_IN_ANI = "VX_Pb_BlackScreen_In"
	self.SCREEN_IN_ANI_TIME = 0.5
	self.SCREEN_OUT_ANI = "VX_Pb_BlackScreen_Out"
	self.SCREEN_OUT_ANI_TIME = 0.5
	self.curChatType = DialogueConst.ChatType.BLACK_SCREEN
end

return BlackScreenCtrl
