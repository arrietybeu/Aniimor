-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MakeSkill\\MakeSkillCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MakeSkillCtrl = Class.LightClass("MakeSkillCtrl", UICtrl)
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")

MakeSkillCtrl.messages = {}

function MakeSkillCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	function self.view.btnClose.luaClick()
		pg.global.ui:close(UIConst.UI_ID_MAKE_SKILL)
	end

	function self.view.btnCancel.luaClick()
		pg.global.ui:close(UIConst.UI_ID_MAKE_SKILL)
	end

	function self.view.btnConfirm.luaClick()
		return
	end

	function self.view.btnMin.luaClick()
		return
	end

	function self.view.btnMax.luaClick()
		return
	end

	function self.view.btnAdd.luaClick()
		return
	end

	function self.view.btnSub.luaClick()
		return
	end
end

function MakeSkillCtrl:checkCanOpen(_, info)
	if info == nil then
		return false
	end

	self.id = info.id
	self.tp = info.tp

	return true
end

function MakeSkillCtrl:onShow()
	self.data = self.model:getSkillData(self.id, self.tp)

	self:refreshView()
end

function MakeSkillCtrl:refreshView()
	local data = self.data

	ClientTextUtils.setText(self.view.iName, pg.getLocalizationText(data.name))

	self.view.iIcon.url = data.icon
	self.view.iBG.url = LuaUIUtils.getSkillElementIcon(data.eType)

	ClientTextUtils.setText(self.view.tName, data.tpName)
	self.view.iElement:TryChangePage("type", data.eType)

	function self.view.iPList.luaRenderItem(b, _, d)
		local ipName = b:Find("TxtName"):GetComponent("USDFText")

		ClientTextUtils.setText(ipName, d.number)
		b:TryChangePage("type", d.style)
	end

	self.view.iPList:SetList(data.numberList)

	function self.view.iFList.luaRenderItem(b, _, d)
		local ifName = b:Find("TxtName"):GetComponent("USDFText")

		ClientTextUtils.setText(ifName, pg.getLocalizationText(d.tagName))
	end

	self.view.iFList:SetList(data.tagList)
end

return MakeSkillCtrl
