-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueID\\DialogueIDCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CommonSkipCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UICtrl = require("Guis.UICtrl")
local DialogueIDCtrl = Class.LightClass("DialogueIDCtrl", UICtrl)

DialogueIDCtrl.messages = {
	[MessageName.DIALOGUE_GRAPH_ON_START] = {
		"onDialogueGraphListChange",
		true
	},
	[MessageName.DIALOGUE_GRAPH_ON_END] = {
		"onDialogueGraphListChange",
		true
	}
}

function DialogueIDCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function DialogueIDCtrl:onShow()
	UICtrl.onShow(self)
	self:refreshDialogueIDInfo()
end

function DialogueIDCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function DialogueIDCtrl:onDialogueGraphListChange()
	self:refreshDialogueIDInfo()
end

function DialogueIDCtrl:refreshDialogueIDInfo()
	local ids = {}
	local dialogueRunningList = pg.game.dialogue.dialogueRunningList

	for key, _ in pairs(dialogueRunningList) do
		table.insert(ids, key)
	end

	ClientTextUtils.setText(self.view.idText, string.format("DialogueGraph-%s", table.concat(ids, "-")))
end

return DialogueIDCtrl
