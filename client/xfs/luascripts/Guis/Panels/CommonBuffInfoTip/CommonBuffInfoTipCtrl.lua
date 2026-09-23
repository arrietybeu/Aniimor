-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonBuffInfoTip\\CommonBuffInfoTipCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CommonBuffInfoTipCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local UICtrl = require("Guis.UICtrl")
local CommonBuffInfoTipCtrl = Class.LightClass("CommonBuffInfoTipCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local BuffUIUtils = require("Utils.BuffUIUtils")

CommonBuffInfoTipCtrl.messages = {
	[MessageName.BUFF_LAYER_CHANGE] = {
		"onBuffLayerChange",
		true
	}
}

function CommonBuffInfoTipCtrl:onCreate(data)
	UICtrl.onCreate(self, data)
end

function CommonBuffInfoTipCtrl:onOpen(data)
	UICtrl.onOpen(self, data)

	self.iData = data
end

function CommonBuffInfoTipCtrl:addListener()
	function self.view.rootCmp.luaCloseAction()
		self:close()
	end
end

function CommonBuffInfoTipCtrl:checkCanOpen(showNotice, data)
	if data == nil then
		return false
	end

	self.iData = data

	return true
end

function CommonBuffInfoTipCtrl:onShow()
	if self.iData == nil then
		return
	end

	self:refreshBuffInfo()

	local autoVer = self.iData.autoVer or false
	local autoHor = self.iData.autoHor or false

	self.view.rootCmp:SetAutoVertical(autoVer, autoHor)
	self.view.rootCmp:OpenPopup(self.iData.targetRect)
end

function CommonBuffInfoTipCtrl:refreshBuffInfo()
	local data = self.iData
	local templateId = data.templateId
	local petInfo = data.petInfo
	local buffInstance = data.buffInstance

	if buffInstance and buffInstance.owner and buffInstance.owner.actorId == data.ownerActorId and buffInstance.buffData and buffInstance.buffData.instanceId == data.instanceId then
		local srcPet = AbilityUtils.getPet(buffInstance:getSrcEntity())

		petInfo = srcPet and srcPet.petInfo or buffInstance.owner.petInfo or petInfo
	end

	if BuffUIUtils.checkIsElementBuff(templateId) then
		self.view.rootCmp:TryChangePage("InfoState", 2)

		local ecsContainer = self.view.ecsBuffUContainer

		if not ecsContainer:CheckURLLoaded() then
			ecsContainer:LoadDefaultUrlManually(function(content)
				BuffUIUtils.setBuffInfo(content, data)
			end)
		else
			BuffUIUtils.setBuffInfo(ecsContainer.content, data)
		end

		ClientTextUtils.setText(self.view.buffNameUText, pg.getLocalizationText(ClientAbilityUtils.getBuffName(templateId)))
		ClientTextUtils.setText(self.view.buffDetailUText, pg.getLocalizationText(ClientAbilityUtils.getBuffDesc(templateId, data.layer, data.level, petInfo)))

		return
	end

	self.view.rootCmp:TryChangePage("InfoState", 0)

	local iconContainer = self.view.skillBuffUContainer

	if not iconContainer:CheckURLLoaded() then
		iconContainer:LoadDefaultUrlManually(function(content)
			BuffUIUtils.renderBuffIcon(content, data)
		end)
	else
		BuffUIUtils.renderBuffIcon(iconContainer.content, data)
	end

	local maxLayer = AbilityUtils.getBuffMaxLayer(templateId)

	ClientTextUtils.setText(self.view.buffNumUText, maxLayer > 1 and pg.getLocalizationText(data.layer or "") or "")

	if data.tag == AbilityConst.BUFF_TAG_POSITIVE then
		self.view.rootCmp:TryChangePage("BuffType", "Up")
	elseif data.tag == AbilityConst.BUFF_TAG_NEGATIVE then
		self.view.rootCmp:TryChangePage("BuffType", "Down")
	elseif LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("@sxy refreshBuffInfo>> invalid buff tag, neither positive nor negative")
	end

	ClientTextUtils.setText(self.view.buffNameUText, pg.getLocalizationText(ClientAbilityUtils.getBuffName(templateId)))
	ClientTextUtils.setText(self.view.buffDetailUText, pg.getLocalizationText(ClientAbilityUtils.getBuffDesc(templateId, data.layer, data.level, petInfo)))
end

function CommonBuffInfoTipCtrl:onBuffLayerChange(info)
	local data = self.iData

	if data == nil then
		return
	end

	if data.instanceId == info.instanceId then
		local templateId = data.templateId

		data.layer = info.newLayer

		if BuffUIUtils.checkIsElementBuff(templateId) then
			local ecsContainer = self.view.ecsBuffUContainer

			if ecsContainer:CheckURLLoaded() then
				BuffUIUtils.refreshBuffLayer(ecsContainer.content, data)
			end
		else
			local iconContainer = self.view.skillBuffUContainer

			if iconContainer:CheckURLLoaded() then
				BuffUIUtils.refreshBuffLayer(iconContainer.content, data)
			end
		end
	end
end

return CommonBuffInfoTipCtrl
