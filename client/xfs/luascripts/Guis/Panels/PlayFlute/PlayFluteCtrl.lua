-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayFlute\\PlayFluteCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PlayFluteCtrl = Class.LightClass("PlayFluteCtrl", UICtrl)
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local ClientTextUtils = require("Utils.ClientTextUtils")

function PlayFluteCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("CHOICE_FLUTE_MUSIC"))
end

function PlayFluteCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:onClose()
	end

	self:bindHotKeyPerform("Common/ClosePanelCommon", function()
		self:onClose()
	end, self.view.btnCloseUButton.gameObject)

	function self.view.btnPinkNoteUButton.luaClick()
		self:playFlute(Const.GENDER_TYPE_FEMALE)
	end

	function self.view.btnGrayNoteUButton.luaClick()
		self:playFlute(Const.GENDER_TYPE_NONE)
	end

	function self.view.btnBlueNoteUButton.luaClick()
		self:playFlute(Const.GENDER_TYPE_MALE)
	end
end

function PlayFluteCtrl:playFlute(fluteType)
	pg.game.social:playFlute(fluteType)
	self:close()
end

function PlayFluteCtrl:onClose()
	self:close()
end

return PlayFluteCtrl
