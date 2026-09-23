-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketSellPet\\Component\\TradeMarketSellPetDetailComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetManagementUtils = require("Utils.PetManagementUtils")
local AddressDataConst = require("Const.AddressDataConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local TradeMarketSellPetDetailComponent = Class.LightClass("TradeMarketSellPetDetailComponent", UIComponent)

function TradeMarketSellPetDetailComponent:onCtor()
	self._visible = true
end

function TradeMarketSellPetDetailComponent:findObjects()
	self.petInfoPanelTransform = self.view.petInfoPanelObjectReference.transform
end

function TradeMarketSellPetDetailComponent:initView()
	self.petData = {
		isEmpty = true
	}

	self:initPetPreviewUIScene()
	self:restorePetInfoTemplate()
end

function TradeMarketSellPetDetailComponent:initPetPreviewUIScene()
	self.petPreviewUISceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE
	self.petPreviewUIScene = pg.game.uiScene:getScene(self.petPreviewUISceneName)

	if not self.petPreviewUIScene then
		self.petPreviewUIScene = pg.game.uiScene:getUISceneInst(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab)
	end

	self.petPreviewUIScene:bindUICtrlKey(self.ctrl.module)

	if self.petPreviewUIScene:checkLoaded() then
		return
	end

	if not self.petPreviewUIScene:checkLoadStateIsNone() then
		self:waitPetPreviewUISceneLoaded()

		return
	end

	local loadingScene = self.petPreviewUIScene

	self.petPreviewUIScene:startLoad(function(succeed)
		if not succeed or not self.ctrl or self.petPreviewUIScene ~= loadingScene then
			return
		end

		self:onPetPreviewUISceneLoaded()
	end)
end

function TradeMarketSellPetDetailComponent:waitPetPreviewUISceneLoaded()
	if self.waitPetPreviewUISceneFrameId then
		self:killFrameTimer(self.waitPetPreviewUISceneFrameId)
	end

	self.waitPetPreviewUISceneFrameId = self:startFrameTimer(function()
		self.waitPetPreviewUISceneFrameId = nil

		if not self.ctrl or not self.petPreviewUIScene then
			return
		end

		if not self.petPreviewUIScene:checkLoaded() then
			self:waitPetPreviewUISceneLoaded()

			return
		end

		self:onPetPreviewUISceneLoaded()
	end, 1)
end

function TradeMarketSellPetDetailComponent:onPetPreviewUISceneLoaded()
	if not self:isPetPreviewUISceneReady() or not PetManagementUtils.isContextOwner(self) then
		return
	end

	self:restorePetInfoTemplate()
	self:scheduleActivatePetPreviewUIScene()
end

function TradeMarketSellPetDetailComponent:isPetPreviewUISceneReady()
	return self.petPreviewUIScene and self.petPreviewUIScene:checkLoaded() and self.petPreviewUIScene.scene and not IsNil(self.petPreviewUIScene.scene)
end

function TradeMarketSellPetDetailComponent:scheduleActivatePetPreviewUIScene()
	if self.activatePetPreviewUISceneFrameId then
		self:killFrameTimer(self.activatePetPreviewUISceneFrameId)
	end

	self.activatePetPreviewUISceneFrameId = self:startFrameTimer(function()
		self.activatePetPreviewUISceneFrameId = nil

		if self.ctrl then
			self:activatePetPreviewUIScene()
		end
	end, 1)
end

function TradeMarketSellPetDetailComponent:activatePetPreviewUIScene()
	if not self:isPetPreviewUISceneReady() then
		return
	end

	pg.game.uiScene:switchToScene(self.petPreviewUISceneName, true, true, true, self.ctrl.module)
	self.petPreviewUIScene:setLocalEnv()
end

function TradeMarketSellPetDetailComponent:destroyPetPreviewUIScene()
	if not self.petPreviewUIScene then
		return
	end

	self.petPreviewUIScene:removeUICtrlKey(self.ctrl.module)
	pg.game.uiScene:switchOutScene(self.petPreviewUISceneName, self.petPreviewUIScene:checkHasUICtrlBind(), nil, self.ctrl.module)

	self.petPreviewUIScene = nil
	self.petPreviewUISceneName = nil
end

function TradeMarketSellPetDetailComponent:initPetInfoTemplate()
	PetManagementUtils.initSimpleInfoTemplate(self.petInfoPanelTransform, {
		defaultSelectTabIndex = 0,
		uiScene = self.petPreviewUIScene,
		owner = self,
		contextRestoreCb = function()
			self:restorePetInfoTemplate()
		end,
		extraLogic = function()
			if PetManagementUtils.btnRenameUButton then
				PetManagementUtils.btnRenameUButton.gameObject:SetActiveEx(false)
			end

			if PetManagementUtils.btnFavoriteUButton then
				PetManagementUtils.btnFavoriteUButton.gameObject:SetActiveEx(false)
			end

			if PetManagementUtils.btnSkillPresetsUButton then
				PetManagementUtils.btnSkillPresetsUButton.gameObject:SetActiveEx(false)
			end

			if PetManagementUtils.btnPetManualUButton then
				PetManagementUtils.btnPetManualUButton.gameObject:SetActiveEx(false)
			end

			if PetManagementUtils.skillBtn then
				PetManagementUtils.skillBtn.interactable = true
			end
		end
	})
end

function TradeMarketSellPetDetailComponent:restorePetInfoTemplate()
	self:initPetInfoTemplate()
	PetManagementUtils.showPetInfo(self.petData)
end

function TradeMarketSellPetDetailComponent:refreshPetInfoDetail(data)
	self.petData = data or {
		isEmpty = true
	}

	if not PetManagementUtils.isContextOwner(self) then
		self:initPetInfoTemplate()
	end

	PetManagementUtils.showPetInfo(self.petData)
end

function TradeMarketSellPetDetailComponent:onShow()
	self:scheduleActivatePetPreviewUIScene()

	if not PetManagementUtils.isContextOwner(self) then
		self:restorePetInfoTemplate()
	end
end

function TradeMarketSellPetDetailComponent:onDestroy()
	if self.waitPetPreviewUISceneFrameId then
		self:killFrameTimer(self.waitPetPreviewUISceneFrameId)

		self.waitPetPreviewUISceneFrameId = nil
	end

	if self.activatePetPreviewUISceneFrameId then
		self:killFrameTimer(self.activatePetPreviewUISceneFrameId)

		self.activatePetPreviewUISceneFrameId = nil
	end

	PetManagementUtils.destroyTemplate(self)
	self:destroyPetPreviewUIScene()
	UIComponent.onDestroy(self)
end

return TradeMarketSellPetDetailComponent
