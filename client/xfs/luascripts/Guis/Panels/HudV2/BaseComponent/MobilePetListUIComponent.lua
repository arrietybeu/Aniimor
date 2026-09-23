-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\MobilePetListUIComponent.lua

local PetListUIComponent = require("Guis.Panels.HudV2.BaseComponent.PetListUIComponent")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local MobilePetListUIComponent = Class.LightClass("MobilePetListUIComponent", PetListUIComponent)
local INVALID_ITEM = -1

function MobilePetListUIComponent:findObjects()
	PetListUIComponent.findObjects(self)

	self.mobileQuickSwitchUButton = self.objectReference:GetRefValue("mobileQuickSwitchUButton")
end

function MobilePetListUIComponent:initView()
	self.registerNonAoiEvent = false

	PetListUIComponent.initView(self)
end

function MobilePetListUIComponent:refreshPetBtnState(petIdx)
	if petIdx <= 0 then
		return
	end

	local btnRefInfo = self.petBtnRefList[petIdx]
	local button = btnRefInfo.button

	if not button then
		return
	end

	if SampleUtils.sampleOn() then
		SampleUtils.beginSample("MobilePetListUIComponent.refreshPetBtnState")
	end

	local data = self.petInfoList[petIdx]
	local valid = data.index ~= INVALID_ITEM

	self:refreshPetBtnVisible(button, data, valid)
	PetListUIComponent.refreshPetBtnState(self, petIdx, true)

	if SampleUtils.sampleOn() then
		SampleUtils.endSample()
	end
end

function MobilePetListUIComponent:refreshPetBtnVisible(button, data, valid)
	local needRefreshVisible = data.btnValidDirty
	local mobileLogicVisible = true
	local player = pg.me
	local curPlayerSpace = player and player.space
	local isSupportMode = Utils.isSpaceSpecialBattleMode(curPlayerSpace)

	if isSupportMode then
		mobileLogicVisible = data.index ~= 1
	else
		mobileLogicVisible = data.index ~= self.curSelectedPetIndex
	end

	if needRefreshVisible then
		button:SetActiveByOutOfView(valid and mobileLogicVisible)

		data.mobileLogicVisible = mobileLogicVisible
	elseif mobileLogicVisible ~= data.mobileLogicVisible then
		data.mobileLogicVisible = mobileLogicVisible

		if valid then
			button:SetActiveByOutOfView(mobileLogicVisible)
		end
	end
end

function MobilePetListUIComponent:refreshPetListOnCombatPetChange(curIndex)
	if curIndex <= 0 then
		return
	end

	if curIndex ~= self.curSelectedPetIndex then
		local lastIndex = self.curSelectedPetIndex

		self.curSelectedPetIndex = curIndex

		self:refreshPetBtnState(lastIndex)
		self:refreshPetBtnState(curIndex)
	end
end

function MobilePetListUIComponent:refreshQuickSwitchPetTeamVisible(formCntDirty)
	local visible = self:getQuickSwitchPetTeamVisible(formCntDirty)

	if visible ~= self.showQuickSwitchPetTeam then
		self.showQuickSwitchPetTeam = visible

		LuaUIUtils.setUIViewVisible(self.mobileQuickSwitchUButton, visible)
	end
end

function MobilePetListUIComponent:initQuickSwitchPetTeamView()
	self:refreshQuickSwitchPetTeamVisible(true)

	function self.mobileQuickSwitchUButton.luaClick()
		if self.mobileQuickSelectPanelOpened then
			return
		end

		self:openQuickSwitchPetTeamPanel()

		self.mobileQuickSelectPanelOpened = true

		if not self.registerNonAoiEvent then
			self.panelTeamComponent:EnableListenNonAOI(function()
				if self.mobileQuickSelectPanelOpened then
					self:onTriggerCloseQuickSwitchPanel(false)
				end
			end)

			self.registerNonAoiEvent = true
		end

		LuaUIUtils.setUIViewVisible(self.mobileQuickSwitchUButton, false)

		self.showQuickSwitchPetTeam = false
	end

	if self.quickSwitchPetTeamUList ~= nil then
		self:setQuickSwitchPetTeamList()
	end
end

function MobilePetListUIComponent:setQuickSwitchPetTeamList()
	function self.quickSwitchPetTeamUList.luaRenderItem(button, index, data)
		self:setupPetTeamEntry(button, index, data)
	end

	function self.quickSwitchPetTeamUList.luaSelectedChanged(uList)
		self.quickSwitchPetTeamUList:RefreshList()
	end

	function self.quickSwitchPetTeamUList.luaClick(button, data)
		self.curQuickSwitchSelectIndex = data.index - 1

		self.quickSwitchPetTeamUList:SelectItem(data.index)
		self.quickSwitchPetTeamUList:GoToIndex(data.index)
		self:onTriggerCloseQuickSwitchPanel(true)
	end
end

function MobilePetListUIComponent:onTriggerCloseQuickSwitchPanel(isSelect)
	PetListUIComponent.onTriggerCloseQuickSwitchPanel(self, isSelect)

	self.mobileQuickSelectPanelOpened = false

	self:refreshQuickSwitchPetTeamVisible()
end

function MobilePetListUIComponent:playShowAnim()
	if self.showAnim then
		self.showAnim:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function MobilePetListUIComponent:playHideAnim()
	if self.showAnim then
		self.showAnim:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

return MobilePetListUIComponent
