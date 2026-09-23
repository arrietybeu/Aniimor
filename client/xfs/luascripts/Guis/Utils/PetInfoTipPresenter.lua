-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Utils\\PetInfoTipPresenter.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AddressDataConst = require("Const.AddressDataConst")
local NpcDuelStartPetDetail = require("Guis.Panels.NpcDuelStart.NpcDuelStartPetDetail")
local PetInfoTipPresenter = Class.LightClass("PetInfoTipPresenter", Class)

function PetInfoTipPresenter:ctor(module, onPetPreviewTipsOpenChanged, uiSceneOptions)
	self.module = module
	self.onPetPreviewTipsOpenChanged = onPetPreviewTipsOpenChanged

	local uiSceneId = uiSceneOptions and uiSceneOptions.uiSceneId

	self.petPreviewUISceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE .. (uiSceneId or "")
	self.petPreviewUISceneParams = uiSceneId and {
		uiId = uiSceneId
	} or nil
	self.petPreviewUIScenePositionY = uiSceneOptions and uiSceneOptions.positionY
	self.petPreviewTipsOpenCount = 0
	self.recordCurPetPropData = {}
	self.destroyed = false
end

function PetInfoTipPresenter:ensurePetInfoDefaults(petInfo)
	if not petInfo then
		return nil
	end

	petInfo.pageIndex = petInfo.pageIndex or 0
	petInfo.ratingString = petInfo.ratingString or "INTERFACE_DISPLAY_RATING_1"
	petInfo.controlFeatureId = petInfo.controlFeatureId or 0
	petInfo.breedTalent = petInfo.breedTalent or {}
	petInfo.bookNum = petInfo.bookNum or 0
	petInfo.time = petInfo.time or 0

	return petInfo
end

function PetInfoTipPresenter:bind(button, getPetInfoFunc, options)
	if IsNil(button) then
		return
	end

	options = options or {}
	button.enabledTooltip = true
	button.tooltipTemplateUrl = options.tooltipTemplateUrl or "$UI_Pop_PetInfo_Tips.prefab"

	if options.hierarchy ~= nil then
		button.PopupTool.hierarchy = options.hierarchy
	end

	if options.popupDirection then
		button:SetPopupDirection(options.popupDirection)
	end

	if options.horizontalAlignment then
		button:SetHorizontalAlignment(options.horizontalAlignment)
	end

	if options.verticalAlignment then
		button:SetVerticalAlignment(options.verticalAlignment)
	end

	function button.luaRenderTooltip(btn, popup)
		if self.destroyed or not getPetInfoFunc then
			return
		end

		local petInfo = self:ensurePetInfoDefaults(getPetInfoFunc())

		if not petInfo then
			return
		end

		if options.renderPetInfo then
			options.renderPetInfo(popup, petInfo, btn)

			return
		end

		NpcDuelStartPetDetail.new(popup, petInfo, self, btn)
	end

	function button.luaTooltipPopup(_, flag)
		if not self.destroyed then
			self:setPetPreviewTipsOpen(ToBool(flag))
		end
	end
end

function PetInfoTipPresenter:unbind(button)
	if IsNil(button) then
		return
	end

	button.enabledTooltip = false
	button.luaRenderTooltip = nil
	button.luaTooltipPopup = nil
end

function PetInfoTipPresenter:setPetPreviewTipsOpen(open)
	local count = self.petPreviewTipsOpenCount or 0

	count = open and count + 1 or count - 1

	self:setPetPreviewTipsOpenCount(count)
end

function PetInfoTipPresenter:setPetPreviewTipsOpenCount(count)
	local wasOpen = self.petPreviewTipsOpenCount > 0

	self.petPreviewTipsOpenCount = math.max(count, 0)

	self:syncPetPreviewCameraState()

	local isOpen = self.petPreviewTipsOpenCount > 0

	if wasOpen ~= isOpen and self.onPetPreviewTipsOpenChanged then
		self.onPetPreviewTipsOpenChanged(isOpen)
	end
end

function PetInfoTipPresenter:ensurePetPreviewUIScene(callback)
	if self.destroyed then
		if callback then
			callback(nil)
		end

		return nil
	end

	if not self.petPreviewUIScene then
		self.petPreviewUIScene = pg.game.uiScene:getScene(self.petPreviewUISceneName)

		if not self.petPreviewUIScene then
			self.petPreviewUIScene = pg.game.uiScene:getUISceneInst(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab, nil, self.petPreviewUISceneParams)
		end

		self.petPreviewUIScene:bindUICtrlKey(self.module)
	end

	if callback then
		self.petPreviewUISceneCallbacks = self.petPreviewUISceneCallbacks or {}
		self.petPreviewUISceneCallbacks[#self.petPreviewUISceneCallbacks + 1] = callback
	end

	if self.petPreviewUIScene:checkLoaded() then
		local scene = self:isPetPreviewUISceneReady() and self.petPreviewUIScene or nil

		if scene then
			self:activatePetPreviewUIScene()
		end

		self:dispatchPetPreviewUISceneCallbacks(scene)

		return self.petPreviewUIScene
	end

	if self.inLoadPetPreviewUIScene then
		return self.petPreviewUIScene
	end

	self.inLoadPetPreviewUIScene = true

	self.petPreviewUIScene:startLoad(function(succeed)
		self.inLoadPetPreviewUIScene = false

		if self.destroyed or not succeed or not self.petPreviewUIScene then
			self:dispatchPetPreviewUISceneCallbacks(nil)

			return
		end

		local scene = self:isPetPreviewUISceneReady() and self.petPreviewUIScene or nil

		if scene then
			self:activatePetPreviewUIScene()
		end

		self:dispatchPetPreviewUISceneCallbacks(scene)
	end)

	return self.petPreviewUIScene
end

function PetInfoTipPresenter:isPetPreviewUISceneReady()
	return self.petPreviewUIScene and self.petPreviewUIScene:checkLoaded() and not IsNil(self.petPreviewUIScene.scene)
end

function PetInfoTipPresenter:activatePetPreviewUIScene()
	if not self:isPetPreviewUISceneReady() then
		return
	end

	if self.petPreviewUIScenePositionY then
		self.petPreviewUIScene.scene.transform.position = Vector3(0, self.petPreviewUIScenePositionY, 0)
	end

	pg.game.uiScene:switchToScene(self.petPreviewUISceneName, true, true, true, self.module)

	if self.petPreviewUIScene.setLocalEnv then
		self.petPreviewUIScene:setLocalEnv()
	end

	self:syncPetPreviewCameraState()
end

function PetInfoTipPresenter:syncPetPreviewCameraState()
	if not self:isPetPreviewUISceneReady() or not self.petPreviewUIScene.enableCamera then
		return
	end

	self.petPreviewUIScene:enableCamera((self.petPreviewTipsOpenCount or 0) > 0)
end

function PetInfoTipPresenter:dispatchPetPreviewUISceneCallbacks(scene)
	local callbacks = self.petPreviewUISceneCallbacks

	self.petPreviewUISceneCallbacks = nil

	for _, callback in ipairs(callbacks or EMPTY_TABLE) do
		callback(scene)
	end
end

function PetInfoTipPresenter:destroy()
	if self.destroyed then
		return
	end

	self.destroyed = true

	self:setPetPreviewTipsOpenCount(0)

	self.onPetPreviewTipsOpenChanged = nil
	self.petPreviewUISceneCallbacks = nil
	self.inLoadPetPreviewUIScene = false

	if not self.petPreviewUIScene then
		return
	end

	self.petPreviewUIScene:removeUICtrlKey(self.module)
	pg.game.uiScene:switchOutScene(self.petPreviewUISceneName, self.petPreviewUIScene:checkHasUICtrlBind(), nil, self.module)

	self.petPreviewUIScene = nil
end

return PetInfoTipPresenter
