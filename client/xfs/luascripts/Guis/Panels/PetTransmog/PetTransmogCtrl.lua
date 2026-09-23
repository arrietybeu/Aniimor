-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmog\\PetTransmogCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local PetTransmogModel = require("Guis.Panels.PetTransmog.PetTransmogModel")
local PetTransmogMainInfoComponent = require("Guis.Panels.PetTransmog.Component.PetTransmogMainInfoComponent")
local PetTransmogSchemeListComponent = require("Guis.Panels.PetTransmog.Component.PetTransmogSchemeListComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local CommonSwitch = require("Common.CommonSwitch")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local SLOT_TYPE_MAX = Const.PetTransmogSlotType.Max
local FIRST_GUIDE_GROUP = 800
local PetTransmogCtrl = Class.LightClass("PetTransmogCtrl", UICtrl)

PetTransmogCtrl.messages = {
	[MessageName.PET_TRANSMOG_SCHEME_APPLIED] = {
		"onSchemeApplied",
		true
	},
	[MessageName.PET_TRANSMOG_SCHEME_LIST_CHANGED] = {
		"onSchemeListChanged",
		true
	},
	[MessageName.PET_TRANSMOG_ROLLED] = {
		"onTransmogRolled",
		true
	},
	[MessageName.PET_TRANSMOG_ROLL_FINISHED] = {
		"onRollFinished",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onMoneyChanged",
		true
	},
	[MessageName.COMMON_SWITCH_STATE_CHANGED] = {
		"onCommonSwitchStateChanged",
		true
	}
}

function PetTransmogCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.model:setPetId(info and info.curPetId or nil)

	self.petTransmogScene = pg.game.uiScene:getScene(UISceneConst.PET_TRANSMOG_SCENE)

	self:initUI()

	self.mainInfoComponent = PetTransmogMainInfoComponent.new(self)
	self.schemeListComponent = PetTransmogSchemeListComponent.new(self)
	self.needDestroyDownloadSprite = {}
	self.snapshotRequestId = 0
	self.photoCache = {}
	self.itemPhotoTokens = {}
end

function PetTransmogCtrl:addListener()
	if self.view.btnBack then
		self.view.btnBack:SetGamepadAction("Raw/GamepadButtonEast")

		function self.view.btnBack.luaClick()
			self:onBtnBack()
		end
	end

	if self.view.btnClose then
		self.view.btnClose:SetGamepadAction("Raw/GamepadButtonEast")

		function self.view.btnClose.luaClick()
			self:onBtnBack()
		end
	end

	if self.view.btnHideUI then
		function self.view.btnHideUI.luaClick()
			self:onBtnHideUI()
		end
	end

	if self.view.btnPreview then
		function self.view.btnPreview.luaClick()
			self:onBtnPreview()
		end
	end

	if self.view.btnVideo then
		function self.view.btnVideo.luaClick()
			self:onBtnVideo()
		end
	end

	if self.view.btnPlanChange then
		function self.view.btnPlanChange.luaClick()
			self:onBtnPlanChange()
		end
	end

	if self.view.btnInfo then
		function self.view.btnInfo.luaClick()
			pg.global.ui.tips:openEventRuleDesc(pg.getGameString("PETTRANSMOGRIFY_RULE_TEXT"), "PETTRANSMOGRIFY_TITLE")
		end
	end

	if self.view.listTabUList then
		function self.view.listTabUList.luaRenderItem(button, index, data)
			local objectReference = button:GetComponent("ObjectReference")
			local name = objectReference:GetRefValue("txtNameUBaseText")

			ClientTextUtils.setText(name, data.name)
		end

		function self.view.listTabUList.luaClick(button, data)
			self.model:setCurrentTab(data.tab)
			self.schemeListComponent:selectFirstScheme()
		end
	end
end

function PetTransmogCtrl:initUI()
	self.model:setSelected(nil, nil)
	self.model:setUIState(PetTransmogModel.UI_STATE.NORMAL)
	self.model:setBaptizeState(PetTransmogModel.BAPTIZE_STATE.IDLE)
	self.model:setCurrentTab(PetTransmogModel.PLAN_TAB.CUSTOM)

	if self.view.listTabUList then
		self.view.listTabUList:SetList({
			{
				selected = true,
				tIndex = 0,
				tab = PetTransmogModel.PLAN_TAB.CUSTOM,
				name = pg.getGameString("PETTRANSMOGRIFY_CUSTOM")
			},
			{
				tIndex = 2,
				tab = PetTransmogModel.PLAN_TAB.PREVIEW,
				name = pg.getGameString("PETTRANSMOGRIFY_PREVIEW")
			}
		})
	end
end

function PetTransmogCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if self.petTransmogScene and self.petTransmogScene.addGamepadRotationBinding then
		self.petTransmogScene:addGamepadRotationBinding(self.view.gameObject)
	end

	if info and info.petId then
		self.model:setPetId(info.petId)
	end

	self:syncLockedHolesFromScheme()
end

function PetTransmogCtrl:onShow()
	self:refreshAll()

	if self.uiScene then
		self.uiScene:onInitCamera()
	end

	self:addNavFocusListener(function()
		self:refreshConsoleBarState()
	end, "PetTransmogCtrl")
	self:tryShowFirstGuide()
end

function PetTransmogCtrl:tryShowFirstGuide()
	local key = ClientConst.PrefKey.PetTransmogFirstGuide .. pg.me.uid

	if not pg.global.prefsCacheUtils:getBool(key, true) then
		return
	end

	pg.global.prefsCacheUtils:setBool(key, false)
	pg.global.ui:open(UIConst.UI_ID_FUNC_MENU_UNLOCK, {
		helpId = FIRST_GUIDE_GROUP
	})
end

function PetTransmogCtrl:onHide()
	return
end

function PetTransmogCtrl:onDestroy()
	self.model:clearLockedHoles()

	for _, sprite in ipairs(self.needDestroyDownloadSprite or EMPTY_TABLE) do
		pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
	end

	self.needDestroyDownloadSprite = nil
	self.photoCache = nil
	self.itemPhotoTokens = nil

	UICtrl.onDestroy(self)
end

function PetTransmogCtrl:refreshConsoleBarState()
	self:refreshPetRoundConsoleBar()
	self:refreshRuleTipsConsoleBar()
end

function PetTransmogCtrl:refreshPetRoundConsoleBar()
	local mgr = pg.global.navMgr

	if mgr then
		local groupName = mgr.CurrentFocusedGroupName
		local isSelectLock = false
		local isSelectUnLock = false
		local isSelect = false

		if groupName == "PetRound" then
			isSelectLock = false
			isSelectUnLock = true
			isSelect = true

			local focusedItem = mgr.CurrentFocusedUContent

			if NotNil(focusedItem) then
				local petId = self.model:getPetId()
				local unlockedList = PetTransmogUtils.getUnlockedHoles(petId)
				local canLock = (unlockedList and #unlockedList or 0) >= 2

				if canLock then
					local pComp = focusedItem.parentComponent

					for i = 1, SLOT_TYPE_MAX do
						local star = self.view.stars[i]

						if star and star == pComp then
							local realUnlocked = PetTransmogUtils.isHoleUnlocked(petId, i)

							if realUnlocked and i ~= Const.PetTransmogSlotType.Flash then
								local isLocked = self.model:isHoleLocked(i) and 1 or 0

								isSelectLock = isLocked == 0
								isSelectUnLock = isLocked ~= 0
							end

							break
						end
					end
				end
			end
		end

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("PetBaptize_isSelectLock", isSelectLock)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("PetBaptize_isSelectUnLock", isSelectUnLock)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("PetBaptize_isSelect", isSelect)
	end
end

function PetTransmogCtrl:refreshRuleTipsConsoleBar()
	local state = self.model:getUIState()
	local isTipsShow = false

	if state == PetTransmogModel.UI_STATE.HIDDEN then
		isTipsShow = false
	elseif state == PetTransmogModel.UI_STATE.PLAN then
		isTipsShow = true
	elseif state == PetTransmogModel.UI_STATE.NORMAL then
		isTipsShow = true
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("PetBaptize_RuleTips", isTipsShow)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("PetBaptize_CameraMove", true)
end

function PetTransmogCtrl:snapShot(callback)
	self.snapshotRequestId = self.snapshotRequestId + 1

	local capturedRid = self.snapshotRequestId

	self.uiScene:snapShot(function(imageKey)
		if not self.needDestroyDownloadSprite then
			return
		end

		if self.snapshotRequestId ~= capturedRid then
			return
		end

		if callback then
			callback(imageKey)
		end
	end)
end

function PetTransmogCtrl:previewTransmogScheme(scheme, onReady)
	if not self.uiScene then
		if onReady then
			onReady(false)
		end

		return
	end

	local petId = self.model:getPetId()
	local pet = petId and pg.me.pets[petId] or nil

	if not pet then
		if onReady then
			onReady(false)
		end

		return
	end

	if self.uiScene.showPetWithTransmogScheme then
		self.uiScene:showPetWithTransmogScheme(pet.templateId, scheme, pet, nil, onReady)
	else
		self.uiScene:showPet(petId)

		if onReady then
			onReady(true)
		end
	end
end

function PetTransmogCtrl:getCurrentSource()
	if self.model:getCurrentTab() == PetTransmogModel.PLAN_TAB.PREVIEW then
		return PetTransmogModel.SCHEME_SOURCE.PREVIEW
	end

	return PetTransmogModel.SCHEME_SOURCE.CUSTOM
end

function PetTransmogCtrl:getCurrentSchemes()
	if self.model:getCurrentTab() == PetTransmogModel.PLAN_TAB.PREVIEW then
		return self.model:getPreviewSchemes()
	end

	return self.model:getCustomSchemes()
end

function PetTransmogCtrl:buildUnlockedSet(petId)
	local set = {}
	local list = PetTransmogUtils.getUnlockedHoles(petId)

	if list then
		for _, v in ipairs(list) do
			set[v] = true
		end
	end

	return set
end

function PetTransmogCtrl:buildHoleData(scheme)
	local petId = self.model:getPetId()
	local count = SLOT_TYPE_MAX
	local result = {}
	local holeIds = scheme and scheme.holeIds or nil

	for i = 1, count do
		local slotId = holeIds and holeIds[i] or nil
		local cfg = PetTransmogUtils.getSlotConfig(slotId)

		result[i] = {
			index = i,
			slotId = slotId,
			isEmpty = not slotId or slotId == 0,
			quality = cfg and cfg.quality or 0,
			name = PetTransmogUtils.getSlotName(petId, scheme, i),
			typename = cfg and cfg.typename or PetTransmogUtils.getHoleName(petId, i)
		}
	end

	return result
end

function PetTransmogCtrl:refreshAll()
	self:refreshBaptizeState()

	if self.view.rootUComponent then
		self.view.rootUComponent:TryChangePage("UIState", self.model:getUIState())
	end

	self.mainInfoComponent:refreshMainInfo()
	self.mainInfoComponent:refreshCurrency()

	local petId = self.model:getPetId()

	self:previewTransmogScheme(PetTransmogUtils.getCurrentScheme(petId))
end

function PetTransmogCtrl:changeUIState(state)
	self.model:setUIState(state)

	if state == PetTransmogModel.UI_STATE.NORMAL then
		self.mainInfoComponent:refreshMainInfo()

		local petId = self.model:getPetId()

		self:previewTransmogScheme(PetTransmogUtils.getCurrentScheme(petId))
	elseif state == PetTransmogModel.UI_STATE.PLAN then
		self.schemeListComponent:selectFirstScheme()
	end

	if self.view.rootUComponent then
		self.view.rootUComponent:TryChangePage("UIState", state)
	end

	self:refreshRuleTipsConsoleBar()
end

function PetTransmogCtrl:refreshBaptizeState()
	if self.view.rootUComponent then
		self.view.rootUComponent:TryChangePage("BaptizeState", self.model:getBaptizeState())
	end
end

function PetTransmogCtrl:onBtnPlanChange()
	self:changeUIState(PetTransmogModel.UI_STATE.PLAN)
end

function PetTransmogCtrl:onBtnHideUI()
	self:changeUIState(PetTransmogModel.UI_STATE.HIDDEN)
end

function PetTransmogCtrl:onBtnBack()
	local state = self.model:getUIState()

	if state == PetTransmogModel.UI_STATE.HIDDEN then
		self:changeUIState(PetTransmogModel.UI_STATE.PLAN)
	elseif state == PetTransmogModel.UI_STATE.PLAN then
		self:changeUIState(PetTransmogModel.UI_STATE.NORMAL)
	elseif state == PetTransmogModel.UI_STATE.NORMAL then
		self:dismiss()
	end
end

function PetTransmogCtrl:onBtnPreview()
	self:dismiss()
	pg.global.ui.petManagement:dismiss()
	pg.global.ui.funcMenu:closeUI()
end

function PetTransmogCtrl:onBtnVideo()
	if not CommonSwitch.Pet_Transmog_Video then
		return
	end

	local videoUrl = PetTransmogUtils.getPreviewSchemeVideoPath(self.model:getSelectedScheme())

	if string.isNilOrEmpty(videoUrl) then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_PET_TRANSMOG_VIDEO, {
		petId = self.model:getPetId(),
		videoUrl = videoUrl
	})
end

function PetTransmogCtrl:onCommonSwitchStateChanged()
	if self.schemeListComponent then
		self.schemeListComponent:refreshPlanPartInfo()
	end
end

function PetTransmogCtrl:onSchemeApplied()
	self:_invalidatePhotoCache()
	self:syncLockedHolesFromScheme()
	self:changeUIState(PetTransmogModel.UI_STATE.NORMAL)
end

function PetTransmogCtrl:syncLockedHolesFromScheme()
	local scheme = PetTransmogUtils.getCurrentScheme(self.model:getPetId())

	self.model:setLockedHolesFromSet(PetTransmogUtils.getSchemeLockedSet(scheme))

	if self.mainInfoComponent then
		self.mainInfoComponent:refreshStarsLock()
	end
end

function PetTransmogCtrl:onSchemeListChanged()
	self:_invalidatePhotoCache()

	if self.model:getUIState() == PetTransmogModel.UI_STATE.PLAN then
		self.schemeListComponent:selectFirstScheme()
	end
end

function PetTransmogCtrl:_invalidatePhotoCache()
	self.photoCache = {}
end

function PetTransmogCtrl:onTransmogRolled()
	self.mainInfoComponent:onTransmogRolled()
end

function PetTransmogCtrl:onRollFinished(msg)
	self.mainInfoComponent:onRollFinished(msg)
end

function PetTransmogCtrl:onMoneyChanged(data)
	self.mainInfoComponent:refreshCurrency()
	self.mainInfoComponent:refreshCostInfo()
end

return PetTransmogCtrl
