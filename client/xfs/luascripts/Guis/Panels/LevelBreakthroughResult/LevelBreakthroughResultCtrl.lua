-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LevelBreakthroughResult\\LevelBreakthroughResultCtrl.lua

local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local EventConst = require("Const.EventConst")
local LevelBreakthroughResultCtrl = Class.LightClass("LevelBreakthroughResultCtrl", UICtrl)

LevelBreakthroughResultCtrl.messages = {}

function LevelBreakthroughResultCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petId = info.petId
	self.breakLevel = info.breakLevel
end

function LevelBreakthroughResultCtrl:onShow()
	local petInfo = pg.me:getPetInfo(self.petId)
	local pData = PetData[petInfo.templateId]

	ClientTextUtils.setText(self.view.petName, PetManagementDataHelper.getPetName(self.petId))
	ClientTextUtils.setText(self.view.levelNum, petInfo.level)
	ClientTextUtils.setText(self.view.breakNum, self.breakLevel)
	self.view.imgPetUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender), function()
		return
	end)
end

function LevelBreakthroughResultCtrl:destroy()
	return
end

function LevelBreakthroughResultCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end
end

function LevelBreakthroughResultCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_LEVEL_BREAKTHROUGH_RESULT)
	pg.global.eventEmitter:emit(EventConst.ON_PET_LEVEL_UP_CLOSE_PANEL, {})
end

function LevelBreakthroughResultCtrl:onDestroy()
	self:destroy()
	UICtrl.onDestroy(self)
end

return LevelBreakthroughResultCtrl
