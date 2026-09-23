-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetInheritChoose\\PetInheritChooseCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetInheritChooseCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetInheritChooseCtrl = Class.LightClass("PetInheritChooseCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local SysConfigData = require("Data.sys_config_data")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local NoticeDef = require("Common.NoticeDef")
local PetConfigData = require("Data.pet_config_data")
local GlobalData = require("Core.Client.GlobalData")
local TimerManager = require("Core.Timer.TimerManager")
local s_intelligentFilterStateCache = {}

local function getIntelligentFilterUserKey()
	local name = GlobalData.UserName or ""
	local serverId = tostring(GlobalData.ServerId or 0)

	return name .. "_" .. serverId
end

PetInheritChooseCtrl.messages = {}

function PetInheritChooseCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	ClientTextUtils.setText(self.view.titleTMPUSDFText, pg.getGameString("PET_INHERIT_CHOOSE_TITLE"))
	ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("PET_INHERIT_MAIN_TIPS"))
end

function PetInheritChooseCtrl:afterInit()
	PetManagementUtils.initMsg(self)
end

function PetInheritChooseCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnRulesUButton.luaClick()
		self:m_onClickRules()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:m_onClickConfirm()
	end

	self:setupAutoFilterBtn()
end

function PetInheritChooseCtrl:onDestroy()
	UICtrl.onDestroy(self)

	PetManagementDataHelper.intelligentFilterPredicate = nil
	PetManagementDataHelper.excludePetIds = nil

	PetManagementUtils.destroyTemplate()
end

function PetInheritChooseCtrl:setupAutoFilterBtn()
	local container = self.view.autoFilterBtnUContainer

	if not container then
		return
	end

	local function bindAutoFilterBtn(content)
		if not content then
			return
		end

		self.autoFilterBtn = content

		local objectReference = content:GetComponent("ObjectReference")

		self.autoFilterTipUBaseText = objectReference:GetRefValue("autoFilterTipUBaseText")

		function content.luaClick()
			self:toggleIntelligentFilter()
		end

		self:_refreshAutoFilterBtnState()
	end

	container:LoadDefaultUrlManually(function(content)
		bindAutoFilterBtn(content)
	end)
end

function PetInheritChooseCtrl:toggleIntelligentFilter()
	if self.intelligentFilterOn then
		self:_clearIntelligentFilter()
		PetManagementUtils._endFilter()
	else
		if not self:_applyIntelligentFilter() then
			return
		end

		PetManagementUtils._startFilter(true)
	end

	s_intelligentFilterStateCache[getIntelligentFilterUserKey()] = self.intelligentFilterOn == true

	self:_refreshAutoFilterBtnState()
end

function PetInheritChooseCtrl:_applyIntelligentFilter()
	local sourcePet = self.sourcePetId and pg.me:getPetInfo(self.sourcePetId)

	if not sourcePet then
		return false
	end

	if not PetManagementDataHelper.filter then
		PetManagementDataHelper.setFilter({})
	end

	function PetManagementDataHelper.intelligentFilterPredicate(pet)
		local canInherit = pg.game.petManage:checkInheritTargetPetLegal(pg.me, self.sourcePetId, pet.id)

		if not canInherit then
			return false
		end

		local sourcePetInfo = pg.me:getPetInfo(self.sourcePetId)
		local targetPetInfo = pg.me:getPetInfo(pet.id)
		local setting = PetConfigData.inheritanceSetting or {}
		local needResult = Utils.needPetInheritanceTransfer(sourcePetInfo, targetPetInfo, setting)

		if not needResult then
			return false
		end

		return true
	end

	self.intelligentFilterOn = true

	return true
end

function PetInheritChooseCtrl:_clearIntelligentFilter()
	PetManagementDataHelper.intelligentFilterPredicate = nil
	self.intelligentFilterOn = false
end

function PetInheritChooseCtrl:_refreshAutoFilterBtnState()
	local container = self.view.autoFilterBtnUContainer
	local content = container and container.content or nil

	if not content then
		return
	end

	local objectReference = content:GetComponent("ObjectReference")
	local tipText = objectReference and objectReference:GetRefValue("autoFilterTipUBaseText") or nil

	if self.autoFilterBtn ~= content then
		self.autoFilterBtn = content
		self.autoFilterTipUBaseText = tipText

		function content.luaClick()
			self:toggleIntelligentFilter()
		end
	end

	local desiredSelected = self.intelligentFilterOn == true

	pcall(function()
		content.isSelected = desiredSelected
	end)
	TimerManager.addNextFrameCb(function()
		local c = self.view and self.view.autoFilterBtnUContainer and self.view.autoFilterBtnUContainer.content

		if c then
			pcall(function()
				c.isSelected = self.intelligentFilterOn == true
			end)
		end
	end)

	if tipText then
		local key = self.intelligentFilterOn and "PET_MANAGEMENT_AUTO_FILTER_ON" or "PET_MANAGEMENT_AUTO_FILTER_OFF"

		pcall(function()
			ClientTextUtils.setText(tipText, pg.getGameString(key))
		end)
	end
end

function PetInheritChooseCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.info = info
	self.selectedPetIndex = 10000
	self.sourcePetId = info.leftPetId or 0
	self.selectedPetId = info.rightPetId or 0
	self.forbidSelectState = {}

	self:initUI()

	local cached = s_intelligentFilterStateCache[getIntelligentFilterUserKey()]
	local shouldEnable = cached == nil or cached == true

	if shouldEnable and self:_applyIntelligentFilter() then
		PetManagementUtils._startFilter(true)
	end

	self:_refreshAutoFilterBtnState()
end

function PetInheritChooseCtrl:onShow()
	return
end

function PetInheritChooseCtrl:onHide()
	return
end

function PetInheritChooseCtrl:onVisibleChange(visible)
	if self.uiScene then
		self.uiScene:setModelVisible(visible)
	end

	if visible and self.uiScene then
		self.uiScene:playPetIdle()
	end
end

function PetInheritChooseCtrl:_resetInheritSelectionState()
	self.selectedPetIndex = 10000
	self.selectedPetId = 0
	self.forbidSelectState = {}
end

function PetInheritChooseCtrl:_setRightPanelVisible(visible)
	if self.view.imgPetURawImage then
		self.view.imgPetURawImage:SetActive(visible)
	end

	if self.view.petInfoPanelTransform and self.view.petInfoPanelTransform.gameObject then
		self.view.petInfoPanelTransform.gameObject:SetActiveEx(visible)
	end
end

function PetInheritChooseCtrl:_onListRenderFinished()
	local hasCandidate = self.selectedPetIndex < 10000

	if hasCandidate then
		PetManagementUtils.setSelectedPet(self.selectedPetIndex)

		if self.uiScene then
			self.uiScene:previewPet(self.selectedPetId)
			self.uiScene:setRawImageProRef(self.view.imgPetURawImage)
		end

		self:_setRightPanelVisible(true)
	else
		self:_setRightPanelVisible(false)
	end
end

function PetInheritChooseCtrl:initUI()
	self.view.imgPetURawImage:SetActive(false)

	local function onListRenderFinished()
		self:_onListRenderFinished()
	end

	PetManagementUtils.onNormalListRenderFinished = onListRenderFinished

	if PetManagementUtils.setOnFilterListRenderFinishedCb then
		PetManagementUtils.setOnFilterListRenderFinishedCb(onListRenderFinished)
	else
		PetManagementUtils.onFilterListRenderFinished = onListRenderFinished
	end

	PetManagementUtils.setListButtonDelegateTable({
		luaPress = function(button, index, data)
			if self.forbidSelectState[data.id] then
				local tip = ""
				local reason = self.forbidSelectState[data.id]

				if reason == Const.ErrInheritPetType.EPRR_PET_IN_TEAM then
					tip = pg.getGameString("EPRR_PET_IN_TEAM")
				elseif reason == Const.ErrInheritPetType.EPRR_PET_TYPE_FORBID then
					tip = pg.getGameString("EPAR_PET_TYPE_INHERIT_FORBID")
				elseif reason == Const.ErrInheritPetType.EPRR_PET_SAME then
					tip = pg.getGameString("EPAR_PET_TYPE_INHERIT_SAME_PET")
				elseif reason == Const.EPRR_PET_IN_DISPATCH then
					tip = pg.getGameString("DISPATCH_TASK_FORBIDDEN")
				end

				local param = {
					autoHor = true,
					targetRect = button,
					desc = tip
				}

				pg.global.showBubbleMessageRaw(tip)

				return false
			end

			self.selectedPetId = data.id

			self.uiScene:previewPet(data.id)
		end,
		renderExtraLogic = function(button, index, data)
			if index == 0 then
				self:_resetInheritSelectionState()
			end

			if data.isEmpty then
				return
			end

			local canInherit, errType = pg.game.petManage:checkInheritTargetPetLegal(pg.me, self.sourcePetId, data.id)

			if not canInherit then
				button:TryChangePage("state", 1)

				self.forbidSelectState[data.id] = errType
			elseif index < self.selectedPetIndex then
				self.selectedPetIndex = index
				self.selectedPetId = data.id
			end
		end
	})

	local ctrlConfig = {
		isForbidUBtnDrag = true,
		isForbidRatioToolTip = true,
		isForbidFavoriteBtn = true
	}

	PetManagementUtils.initTemplate(self.view.petInfoPanelTransform, self.view.petListTransform, {
		uiScene = self.uiScene,
		ctrlConfig = ctrlConfig
	})

	if PetManagementUtils.btnCleanFilterUButton then
		function PetManagementUtils.btnCleanFilterUButton.luaClick()
			self:_clearIntelligentFilter()

			s_intelligentFilterStateCache[getIntelligentFilterUserKey()] = false

			PetManagementUtils._endFilter()
			self:_refreshAutoFilterBtnState()
		end
	end
end

function PetInheritChooseCtrl:m_onClickRules()
	function self.view.btnRulesUButton.luaRenderTooltip(_, component)
		local objectReference = component:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("PET_INHERIT_MAIN_RULES"))
	end
end

function PetInheritChooseCtrl:m_onClickConfirm()
	if self.selectedPetId and self.selectedPetId ~= 0 then
		pg.game.petManage:setInheritTargetPetId(self.selectedPetId)
		pg.global.ui:open(UIConst.UI_ID_PET_INHERITANCE_MAIN, {
			rightPetId = self.selectedPetId
		})
		self:close()
	else
		pg.global.showBubbleMessageById(NoticeDef.PET_INHERIT_CHOOSE_CONFIRM_TIP)
	end
end

return PetInheritChooseCtrl
