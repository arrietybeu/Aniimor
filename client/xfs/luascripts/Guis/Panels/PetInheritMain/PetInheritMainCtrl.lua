-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetInheritMain\\PetInheritMainCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetInheritMainCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetInheritMainCtrl = Class.LightClass("PetInheritMainCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetConfigData = require("Data.pet_config_data")
local PetResonaceStarComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetResonaceStarComponent")
local PetCardCarryInfoComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetCardCarryInfoComponent")
local UIConst = require("Const.UIConst")
local PetData = require("Data.pet_data")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetLevelData = require("Data.pet_level_data")
local NoticeDef = require("Common.NoticeDef")
local INHERIT_POS = {
	RIGHT = 2,
	LEFT = 1
}
local STAR_PART_STATE = {
	UNLIGHT = 0,
	LIGHT = 1
}
local string_format = string.format

PetInheritMainCtrl.messages = {
	[MessageName.PET_INHERIT_CHANGE] = {
		"onPetInheritChange",
		true
	},
	[MessageName.PET_CARRY_LOCK_CHANGE] = {
		"onPetCarryLockChange",
		true
	}
}

function PetInheritMainCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetInheritMainCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:m_onClickConfirm()
	end

	self.view.btnRulesUButton.enabledTooltip = false

	function self.view.btnRulesUButton.luaClick()
		self:m_onClickRules()
	end

	function self.view.btnChooseUButton.luaClick()
		self:m_onClickChoose()
	end

	self:bindHotKeyPerform("Common/Cancel", self.view.btnBackUButton.luaClick, self.view.btnBackUButton.gameObject)
end

function PetInheritMainCtrl:onDestroy()
	self:m_clearCarryInfoComps()
	UICtrl.onDestroy(self)

	self.petId = nil
	self.petInfo = nil
	self.rightPetId = nil
	self.rightPetInfo = nil
end

function PetInheritMainCtrl:onVisibleChange(visible)
	if visible then
		if NotNil(self.uiScene) then
			self.uiScene:resumeRenderTexture()
		end

		self:refreshAll()
	end

	PetInheritMainCtrl.super.onVisibleChange(self, visible)
end

function PetInheritMainCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.petId = pg.game.petManage:getInheritSourcePetId()

	if not self.petId then
		self:close()

		return
	end

	ClientTextUtils.setText(self.view.btnConfirmTxtNameUSDFText, pg.getGameString("ENSURE"))
	ClientTextUtils.setText(self.view.titleTMPUSDFText, pg.getGameString("PET_INHERIT_MAIN_TITLE"))
	ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("PET_INHERIT_MAIN_TIPS"))
	ClientTextUtils.setText(self.view.chooseTxtNameUSDFText, pg.getGameString("PET_INHERIT_CHOOSE_TIP"))
	ClientTextUtils.setText(self.view.txtBroadcastUSDFText, pg.getGameString("PET_MANAGEMENT_AUTO_FILTER"))

	self.petInfo = pg.me:getPetInfo(self.petId)
	self.rightPetId = info.rightPetId or pg.game.petManage:getInheritTargetPetId()
	self.rightPetInfo = self.rightPetId and pg.me:getPetInfo(self.rightPetId) or {}

	self:m_clearCarryInfoComps()
	self:refreshAll()
end

function PetInheritMainCtrl:onShow()
	return
end

function PetInheritMainCtrl:onHide()
	return
end

function PetInheritMainCtrl:refreshAll()
	self:showLeftPet()
	self:showRightPet()
end

function PetInheritMainCtrl:m_onClickRules()
	if PetConfigData.PET_INHERIT_TIP_INFO_ID then
		pg.global.ui.tips:openCommonPopUpTipById(PetConfigData.PET_INHERIT_TIP_INFO_ID)
	end
end

function PetInheritMainCtrl:m_onClickChoose()
	if NotNil(self.uiScene) then
		self.uiScene:pauseRenderTexture()
	end

	pg.global.ui:open(UIConst.UI_ID_PET_INHERITANCE_CHOOSE, {
		leftPetId = self.petId,
		rightPetId = self.rightPetId
	}, nil, nil, {
		textureWidth = 1080,
		textureHeight = 1080,
		uiId = UIConst.UI_ID_PET_INHERITANCE_CHOOSE
	})
end

function PetInheritMainCtrl:showLeftPet()
	self:m_customRefreshPetInfo(self.view.petInfoLeftUComponent, INHERIT_POS.LEFT)
	self:m_showLeftPetModel()
	self:m_customRefreshGenderInfo(INHERIT_POS.LEFT)
end

function PetInheritMainCtrl:m_showLeftPetModel()
	if not self.uiScene then
		return
	end

	local leftPetInfo = self.petInfo

	self.uiScene:setLeftModel(leftPetInfo.templateId, self.view.imgPetLeftURawImage, leftPetInfo.label, self.petId, leftPetInfo)
end

function PetInheritMainCtrl:showRightPet()
	if not self.rightPetId then
		if self.m_rightPetCarryInfoComp then
			self.m_rightPetCarryInfoComp:updateAndRefresh(nil)
		end

		self.view.rootUComponent:TryChangePage("State", 0)

		local objectReference = self.view.petInfoRightUComponent:GetComponent("ObjectReference")
		local emptyTxtNameUSDFText = objectReference:GetRefValue("emptyTxtNameUSDFText")

		ClientTextUtils.setText(emptyTxtNameUSDFText, pg.getGameString("PET_INHERIT_CHOOSE_TIP"))

		local iconUImage = objectReference:GetRefValue("iconUImage")

		iconUImage:SetActive(false)
		self.view.imgPetRightURawImage:SetActive(false)

		return
	end

	self.view.rootUComponent:TryChangePage("State", 1)
	self:m_customRefreshPetInfo(self.view.petInfoRightUComponent, INHERIT_POS.RIGHT)
	self:m_showRightPetModel()
	self:m_customRefreshGenderInfo(INHERIT_POS.RIGHT)
end

function PetInheritMainCtrl:m_showRightPetModel()
	if not self.uiScene then
		return
	end

	self.uiScene:setRightModel(self.rightPetInfo.templateId or 0, self.view.imgPetRightURawImage, self.rightPetInfo.label or 0, self.rightPetId, self.rightPetInfo)
end

function PetInheritMainCtrl:m_customRefreshPetInfo(petInfoUComp, pos)
	local petInfo = self.petInfo
	local petId = self.petId

	if pos == INHERIT_POS.RIGHT then
		petInfo = self.rightPetInfo
		petId = self.rightPetId
	end

	local templateId = petInfo.templateId or 0
	local objectReference = petInfoUComp:GetComponent("ObjectReference")
	local propertyUWidget = objectReference:GetRefValue("propertyUWidget")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtLvUSDFText = objectReference:GetRefValue("txtLvUSDFText")
	local starUContainer = objectReference:GetRefValue("starUContainer")
	local carryInfoUComponent = objectReference:GetRefValue("carryItemUComponent")
	local petType = PetData[templateId].functionId

	iconUImage.url = PetConfigData.petFunctionIcon[petType] or ""

	iconUImage:SetActive(false)
	ClientTextUtils.setText(txtLvUSDFText, "Lv." .. (petInfo.level or 0))
	self:m_refreshStarUpContainer(petId, starUContainer, false, pos)
	self:m_refreshCarryInfo(petId, carryInfoUComponent, pos)
	self:m_refreshPetRadarAttrs(pos, propertyUWidget, petInfoUComp)
end

function PetInheritMainCtrl:m_refreshPetRadarAttrs(pos, propertyUWidget, petInfoUComp)
	local petInfo = self.petInfo

	if pos == INHERIT_POS.RIGHT then
		petInfo = self.rightPetInfo
	end

	if not petInfo or petInfo.isCatchReporting and petInfo:isCatchReporting() then
		petInfoUComp:TryChangePage("NotVerified", 1)
	else
		petInfoUComp:TryChangePage("NotVerified", 0)

		local extraInfo = {
			isHideVx = true
		}

		PetManagementUtils.renderPetAttribute(petInfo, propertyUWidget, nil, nil, extraInfo)
	end
end

function PetInheritMainCtrl:m_refreshStarUpContainer(petId, starUContainer, forbidToolTip, pos)
	if petId and starUContainer then
		local curResonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)
		local stage = curResonanceInfo.resonanceStage or 0
		local level = curResonanceInfo.resonanceLevel or 0
		local curStageStarUrl = PetManagementUtils.getStarItemUrl(stage, true)

		starUContainer:SetUrlWithCallback(curStageStarUrl, function()
			local starUCont = starUContainer.content
			local m_starComp = PetResonaceStarComponent.new(starUCont)
			local popupDirection

			if pos == INHERIT_POS.RIGHT then
				popupDirection = 32
			end

			if m_starComp then
				m_starComp:updateAndRefresh(petId, {
					stage = stage,
					lv = level,
					pos = UIConst.STARCOMP_POS.PETINFO
				}, forbidToolTip, popupDirection)
			end
		end)
	end
end

function PetInheritMainCtrl:m_refreshCarryInfo(petId, carryInfoUComponent, pos)
	if not carryInfoUComponent then
		return
	end

	local petCarryComp = pos == INHERIT_POS.LEFT and self.m_leftPetCarryInfoComp or self.m_rightPetCarryInfoComp

	if not petCarryComp then
		petCarryComp = PetCardCarryInfoComponent.new(carryInfoUComponent)

		if pos == INHERIT_POS.LEFT then
			self.m_leftPetCarryInfoComp = petCarryComp
		else
			self.m_rightPetCarryInfoComp = petCarryComp
		end
	end

	petCarryComp:updateAndRefresh(petId, {
		popupDirection = pos == INHERIT_POS.RIGHT and 32 or nil
	})
end

function PetInheritMainCtrl:onPetCarryLockChange(retInfo)
	if self.m_leftPetCarryInfoComp then
		self.m_leftPetCarryInfoComp:refreshCarryItemTooltip()
	end

	if self.m_rightPetCarryInfoComp then
		self.m_rightPetCarryInfoComp:refreshCarryItemTooltip()
	end
end

function PetInheritMainCtrl:m_clearCarryInfoComps()
	if self.m_leftPetCarryInfoComp then
		self.m_leftPetCarryInfoComp:onDestroy()

		self.m_leftPetCarryInfoComp = nil
	end

	if self.m_rightPetCarryInfoComp then
		self.m_rightPetCarryInfoComp:onDestroy()

		self.m_rightPetCarryInfoComp = nil
	end
end

function PetInheritMainCtrl:m_customRefreshGenderInfo(pos)
	local bottomUWidget = pos == INHERIT_POS.LEFT and self.view.leftBottomUWidget or self.view.rightBottomUWidget
	local petInfo = self.petInfo

	if pos == INHERIT_POS.RIGHT then
		petInfo = self.rightPetInfo
	end

	if not petInfo then
		return
	end

	self:m_refreshPetGenderInfo(pos, bottomUWidget, PetManagementUtils.generateBaseData(pg.me, petInfo), petInfo)
end

function PetInheritMainCtrl:m_refreshPetGenderInfo(pos, widget, info, petInfo)
	local objectReference = widget:GetComponent("ObjectReference")
	local petNameUBaseText = objectReference:GetRefValue("petNameUBaseText")
	local elementUList = objectReference:GetRefValue("elementUList")
	local numCPUBaseText = objectReference:GetRefValue("numCPUBaseText")
	local petNameUComponent = objectReference:GetRefValue("petNameUComponent")
	local txtNameChangeUBaseText = objectReference:GetRefValue("txtNameChangeUBaseText")
	local nameCoverUBaseText = objectReference:GetRefValue("nameCoverUBaseText")
	local txtStateUSDFText = objectReference:GetRefValue("txtStateUSDFText")
	local iconGenderUImage = objectReference:GetRefValue("iconGenderUImage")
	local lineUWidget = objectReference:GetRefValue("lineUWidget")
	local btnChangeUButton = objectReference:GetRefValue("btnChangeUButton")
	local listTagUList = objectReference:GetRefValue("listTagUList")
	local stateNameKey = pos == INHERIT_POS.LEFT and "PET_INHERIT_LEFT_STATENAME" or "PET_INHERIT_RIGHT_STATENAME"

	ClientTextUtils.setText(txtStateUSDFText, pg.getGameString(stateNameKey) or "")

	function elementUList.luaRenderItem(button, index, data)
		LuaUIUtils.setElementButtonNew(button, data.element, true, info.templateId)
	end

	petNameUComponent:SetActive(true)

	iconGenderUImage.url = info.genderIcon

	ClientTextUtils.setText(petNameUBaseText, info.petName)
	ClientTextUtils.setText(txtNameChangeUBaseText, info.petName)
	ClientTextUtils.setText(nameCoverUBaseText, info.petName)
	ClientTextUtils.setText(numCPUBaseText, info.petCp)

	local maxExp = PetLevelData[info.petLevel + 1] ~= nil and PetLevelData[info.petLevel + 1].needExp or 0
	local pData = PetData[info.templateId]
	local _, elementNames = LuaUIUtils.getElementInfo(pData.elementType)

	elementUList:SetList(elementNames)
	lineUWidget:SetActive(elementNames and #elementNames > 0)

	function btnChangeUButton.luaClick()
		if pos == INHERIT_POS.LEFT then
			pg.game.petManage:resetInheritDataModel()
			self:close()
			pg.global.ui:close(UIConst.UI_ID_PET_INHERITANCE_CHOOSE)
		else
			self:m_onClickChoose()
		end
	end

	function listTagUList.luaRenderItem(button, idx, tagData)
		LuaUIUtils.renderPetTagList(button, tagData)
		LuaUIUtils.setPetTagLabelToolTip(button, LuaUIUtils.getPetTagInfo(petInfo.templateId, tagData.label, tagData.bodySizeType, tagData.shinyStyle))
	end

	local tagData = LuaUIUtils.getPetTagList(petInfo)

	listTagUList:SetList(tagData)
end

function PetInheritMainCtrl:m_onClickConfirm()
	if not self.rightPetId then
		pg.global.showBubbleMessageById(NoticeDef.PET_INHERIT_CHOOSE_CONFIRM_TIP)

		return
	end

	local costItems = LuaUIUtils.parseCostDataToIpairs(PetConfigData.inheritanceConsumption or {})
	local hasCost = costItems and next(costItems)
	local costNum = hasCost and costItems[1] and costItems[1][2] or 0
	local fStr = pg.getGameString("PET_INHERIT_FINAL_CONFIRM_TITLE")

	if hasCost then
		pg.global.showCommonTipUse(pg.getGameString("RELEASE_WARN"), string_format(fStr, costNum), costItems, function()
			pg.game.petManage:trySendRpcInheritPetPropLevel(self.petId, self.rightPetId)
		end, nil, nil, 4, {
			resetBlur = true
		})
	else
		pg.game.petManage:trySendRpcInheritPetPropLevel(self.petId, self.rightPetId)
	end
end

function PetInheritMainCtrl:onPetInheritChange(info)
	return
end

return PetInheritMainCtrl
