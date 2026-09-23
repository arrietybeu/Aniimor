-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetBatchSPointsRule\\PetBatchSPointsRuleCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetBatchSPointsRuleCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetBatchSPointsRuleCtrl = Class.LightClass("PetBatchSPointsRuleCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")

PetBatchSPointsRuleCtrl.messages = {}

function PetBatchSPointsRuleCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	self.petId = info.petId

	self:refreshRules()
end

function PetBatchSPointsRuleCtrl:addListener()
	return
end

function PetBatchSPointsRuleCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetBatchSPointsRuleCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PetBatchSPointsRuleCtrl:onShow()
	return
end

function PetBatchSPointsRuleCtrl:onHide()
	return
end

function PetBatchSPointsRuleCtrl:refreshRules()
	local data = self.model:getRules(self.petId)

	function self.view.listAttributeUList.luaRenderItem(button, index, data)
		self:m_refreshRuleItem(button, index, data)
	end

	self.view.listAttributeUList:SetList(data)
end

function PetBatchSPointsRuleCtrl:m_refreshRuleItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtAddUSDFText = objectReference:GetRefValue("txtAddUSDFText")
	local listValueUList = objectReference:GetRefValue("listValueUList")

	self.m_ruleBaseGainListLen = #data.baseGainList

	function listValueUList.luaRenderItem(button, index, data)
		self:m_refreshBaseGainItem(button, index, data)
	end

	listValueUList:SetList(data.baseGainList)

	iconUImage.url = data.propIcon

	ClientTextUtils.setText(txtNameUSDFText, data.propL10nName)

	if data.specialGainList and #data.specialGainList > 0 then
		local specialGain = data.specialGainList[1]
		local desc = PetManagementUtils.getPetNewPropConvertGainDesc(specialGain)

		ClientTextUtils.setText(txtAddUSDFText, desc)
	else
		ClientTextUtils.setText(txtAddUSDFText, "")
	end
end

function PetBatchSPointsRuleCtrl:m_refreshBaseGainItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtValueUSDFText = objectReference:GetRefValue("txtValueUSDFText")
	local txtLineUWidget = objectReference:GetRefValue("txtLineUWidget")
	local desc = PetManagementUtils.getPetNewPropConvertGainDesc(data)

	ClientTextUtils.setText(txtValueUSDFText, desc)
	txtLineUWidget:SetActive(index < self.m_ruleBaseGainListLen)
end

return PetBatchSPointsRuleCtrl
