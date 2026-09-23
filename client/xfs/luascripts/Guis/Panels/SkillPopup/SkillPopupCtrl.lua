-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SkillPopup\\SkillPopupCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ElementPropData = require("Data.element_prop_data")
local ElementNameToId = require("Data.element_name_to_id")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SkillPopupCtrl = Class.LightClass("SkillPopupCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

function SkillPopupCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.abilityParameters = info
end

function SkillPopupCtrl:addListener()
	return
end

function SkillPopupCtrl:onShow()
	self:showSkillInfo(self.abilityParameters)
	self.view.transform:SetSiblingIndex(-1)
end

function SkillPopupCtrl:refreshInfo(infos)
	self.abilityParameters = infos

	self:showSkillInfo(self.abilityParameters)
end

function SkillPopupCtrl:showSkillInfo(skillInfo)
	ClientTextUtils.setText(self.view.txtName, pg.getLocalizationText(skillInfo.name))
	ClientTextUtils.setText(self.view.txtType, pg.getLocalizationText(skillInfo.typeName))

	self.view.bg.url = LuaUIUtils.getSkillElementIcon(skillInfo.elementType)
	self.view.icon.url = LuaUIUtils.getSkillIcon(skillInfo.icon)

	self.view.pbElement:TryChangePage("type", ElementPropData[skillInfo.elementType].name)

	function self.view.listTag.luaRenderItem(b, i, d)
		LuaUIUtils.setElementButtonNew(b, d.elementName.name)
	end

	self.view.listTag:SetList(skillInfo.elementList)
	ClientTextUtils.setText(self.view.txtSkillInfo, pg.getLocalizationText(skillInfo.desc))
	ClientTextUtils.setText(self.view.boxSkillFeature, pg.getLocalizationText(skillInfo.tagList[1].tagName))
	ClientTextUtils.setText(self.view.power, skillInfo.numberList[1].number)
	ClientTextUtils.setText(self.view.energy, skillInfo.numberList[2].number)
	self.view.rootCmp:TryChangePage("IsRare", skillInfo.rare)
end

return SkillPopupCtrl
