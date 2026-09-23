-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetPropUseResult\\PetPropUseResultCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetPropUseResultCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetPropUseResultCtrl = Class.LightClass("PetPropUseResultCtrl", UICtrl)
local ItemConst = require("Common.Const.ItemConst")
local PetManagementUtils = require("Utils.PetManagementUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")

PetPropUseResultCtrl.messages = {}

function PetPropUseResultCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petData = nil
	self.changeList = nil
	self.sType = nil
	self.isClosing = nil
	self.titleStrKey = nil
end

function PetPropUseResultCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:dismiss()
	end
end

function PetPropUseResultCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetPropUseResultCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:initData(info)
	self:initUI()

	if self.openFunc then
		self.openFunc()
	end
end

function PetPropUseResultCtrl:onShow()
	return
end

function PetPropUseResultCtrl:onHide()
	return
end

function PetPropUseResultCtrl:initData(info)
	self.petData = info.petData
	self.changeList = info.changeList
	self.sType = info.sType
	self.isClosing = false
	self.openFunc = info and info.openFunc
	self.titleStrKey = info and info.titleStrKey
end

function PetPropUseResultCtrl:initUI()
	local isCharacterRandom = self.sType == ItemConst.USEITEM_TYPE_PET_CHARACTER_RANDOM
	local isPropertyEnhance = self.sType == ItemConst.USEITEM_TYPE_PROPERTY_ENHANCE
	local isChangePetSizeType = self.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_SIZE_TYPE
	local pageType

	if isCharacterRandom then
		pageType = 0

		local btns = {
			self.view.btnFeatures1,
			self.view.btnFeatures2
		}
		local txtNames = {
			self.view.txtFeaturesName1,
			self.view.txtFeaturesName2
		}

		for k, featureInfo in ipairs(self.changeList) do
			PetManagementUtils.renderPetFeature(btns[k], featureInfo)
			ClientTextUtils.setText(txtNames[k], pg.getLocalizationText(featureInfo.name))
		end
	elseif isPropertyEnhance or isChangePetSizeType then
		pageType = 1

		if isChangePetSizeType then
			function self.view.listAttri.luaRenderItem(button, index, data)
				self:refreshChangePetSizeTypeItem(button, index, data)
			end
		else
			function self.view.listAttri.luaRenderItem(button, index, data)
				self:refreshImproveItem(button, index, data)
			end
		end

		self.view.listAttri:SetList(self.changeList or {})
	end

	self.view.rootUComponent:TryChangePage("Type", pageType)

	self.view.imgPet.url = LuaUIUtils.getPetIcon(self.petData.iconName, LuaUIUtils.PET_ICON)

	ClientTextUtils.setText(self.view.txtLevel, self.petData.level)
	ClientTextUtils.setText(self.view.txtName, self.petData.name)

	if self.titleStrKey then
		local titleTs = self.view.rootUComponent.transform:Find("Widget/Popup/LevelUp/TxtTitle")

		if NotNil(titleTs) then
			local titleUSDFTxt = titleTs:GetComponent("USDFText")

			if NotNil(titleUSDFTxt) then
				ClientTextUtils.setText(titleUSDFTxt, pg.getGameString(self.titleStrKey))
			end
		end
	end
end

function PetPropUseResultCtrl:refreshImproveItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtName = objectReference:GetRefValue("txtName")
	local txtNumBefore = objectReference:GetRefValue("txtNumBefore")
	local txtNumAfter = objectReference:GetRefValue("txtNumAfter")
	local trainBeforeUComponent = objectReference:GetRefValue("trainBeforeUComponent")
	local trainAfterUComponent = objectReference:GetRefValue("trainAfterUComponent")
	local after = data.before + data.add

	ClientTextUtils.setText(txtName, data.name)
	ClientTextUtils.setText(txtNumBefore, data.beforeBaseLv)
	ClientTextUtils.setText(txtNumAfter, data.beforeBaseLv + data.add)

	local beforeBtnState = 0
	local afterBtnState = 0

	afterBtnState = 1

	trainBeforeUComponent:TryChangePage("State", beforeBtnState)
	trainAfterUComponent:TryChangePage("State", afterBtnState)
end

function PetPropUseResultCtrl:refreshChangePetSizeTypeItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local txtBeforeUSDFText = objectReference:GetRefValue("txtBeforeUSDFText")
	local txtAfterUSDFText = objectReference:GetRefValue("txtAfterUSDFText")

	ClientTextUtils.setText(txtTitleUSDFText, data.title)
	ClientTextUtils.setText(txtBeforeUSDFText, data.before)
	ClientTextUtils.setText(txtAfterUSDFText, data.after)
end

return PetPropUseResultCtrl
