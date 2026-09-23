-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetUpSkillSuc\\PetUpSkillSucCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetUpSkillSucCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetUpSkillSucCtrl = Class.LightClass("PetUpSkillSucCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local UIConst = require("Const.UIConst")
local sucTitleKey1 = "PETSKILL_UPLV_SUCCEED"
local sucTitleKey2 = "CARRY_CERT_ENHANCE_SUC"

PetUpSkillSucCtrl.messages = {}

function PetUpSkillSucCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petInfo = info.petInfo
	self.skillInfo = info.skillInfo
end

function PetUpSkillSucCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:closePanel()
	end
end

function PetUpSkillSucCtrl:onDestroy()
	UICtrl.onDestroy(self)
	pg.global.ui:close(UIConst.UI_ID_PET_MANAGEMENT_UPSKILL)
end

function PetUpSkillSucCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.petInfo = info.petInfo
	self.skillInfoData = info.skillInfoData

	if pg.game.setting:getShowDebugId() then
		local debugStr = string.format("%s_%s", self.skillInfoData.abilityId, AbilityUtils.getAbilityParamId(self.skillInfoData.abilityId))
		local title = pg.getGameString(sucTitleKey2) .. debugStr

		ClientTextUtils.setText(self.view.txtTitleUBaseText, title)
	else
		ClientTextUtils.setText(self.view.txtTitleUBaseText, pg.getGameString(sucTitleKey2))
	end

	LuaUIUtils.renderSkillHeadComp(self.view.petSkillUButton, self.skillInfoData, self.petInfo, false, nil, nil, true)
end

function PetUpSkillSucCtrl:onShow()
	return
end

function PetUpSkillSucCtrl:onHide()
	return
end

return PetUpSkillSucCtrl
