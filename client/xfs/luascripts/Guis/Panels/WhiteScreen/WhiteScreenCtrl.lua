-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WhiteScreen\\WhiteScreenCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("WhiteScreenCtrl")
local Class = require("Core.Framework.Class")
local DialogueConst = require("Const.DialogueConst")
local ScreenCtrlBase = require("Guis.Panels.BlackScreen.ScreenCtrlBase")
local WhiteScreenCtrl = Class.LightClass("WhiteScreenCtrl", ScreenCtrlBase)

function WhiteScreenCtrl:init()
	ScreenCtrlBase.init(self)

	self.SCREEN_IN_ANI = "VX_Pb_WhiteScreen_In"
	self.SCREEN_IN_ANI_TIME = 0.5
	self.SCREEN_OUT_ANI = "VX_Pb_WhiteScreen_Out"
	self.SCREEN_OUT_ANI_TIME = 0.5
	self.curChatType = DialogueConst.ChatType.WHITE_SCREEN
end

return WhiteScreenCtrl
