-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearancePreview\\AppearancePreviewCtrl.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local UICtrl = require("Guis.UICtrl")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AppearancePreviewCtrl = Class.LightClass("AppearancePreviewCtrl", UICtrl)

AppearancePreviewCtrl.messages = {}

local BUTTON_CTRL = "button"
local PAGE_NORMAL = 0

local function saveButtonLayout(button)
	local rect = button.rectTransform

	return {
		anchorMin = rect.anchorMin,
		anchorMax = rect.anchorMax,
		pivot = rect.pivot,
		anchoredPosition = rect.anchoredPosition,
		sizeDelta = rect.sizeDelta,
		localScale = rect.localScale,
		localRotation = rect.localRotation
	}
end

local function restoreButtonLayout(button, parent, sibling, layout)
	button.transform:SetParent(parent, false)
	button.transform:SetSiblingIndex(sibling)

	local rect = button.rectTransform

	rect.anchorMin = layout.anchorMin
	rect.anchorMax = layout.anchorMax
	rect.pivot = layout.pivot
	rect.anchoredPosition = layout.anchoredPosition
	rect.sizeDelta = layout.sizeDelta
	rect.localScale = layout.localScale
	rect.localRotation = layout.localRotation
end

local function applyButtonPage(target, page)
	if IsNil(target) then
		return
	end

	target.disableAllTweenEffect = true

	target:TryChangePage(BUTTON_CTRL, page, true)

	target.disableAllTweenEffect = false
end

local function resetButtonState(button, parentComponent)
	if NotNil(parentComponent) then
		applyButtonPage(parentComponent, PAGE_NORMAL)
	end

	applyButtonPage(button, PAGE_NORMAL)

	button.disableAllTweenEffect = true

	button:SetSelected(false)

	button.disableAllTweenEffect = false
end

local function resolveSelectedPage(button, parentComponent)
	local ok, page = button:TryGetCurrentPage(BUTTON_CTRL)

	if ok and page ~= PAGE_NORMAL then
		return page
	end

	if NotNil(parentComponent) then
		ok, page = parentComponent:TryGetCurrentPage(BUTTON_CTRL)

		if ok and page ~= PAGE_NORMAL then
			return page
		end
	end

	return PAGE_NORMAL
end

function AppearancePreviewCtrl:onCreate(info)
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.backBtn = info.button
	self._btnParent = info.button.transform.parent
	self._btnSibling = info.button.transform:GetSiblingIndex()
	self._btnLuaClick = info.button.luaClick
	self._btnLayout = saveButtonLayout(info.button)
	self._btnParentComponent = info.button.parentComponent
	self._btnSelectedPage = resolveSelectedPage(info.button, self._btnParentComponent)

	if NotNil(self._btnParentComponent) then
		applyButtonPage(self._btnParentComponent, PAGE_NORMAL)
	end

	info.button.renderOpacity = 0

	info.button.transform:SetParent(self.view.rootUWidget.transform, true)

	info.button.disableAllTweenEffect = true

	applyButtonPage(info.button, self._btnSelectedPage)
	info.button:SetSelected(true)

	info.button.disableAllTweenEffect = false

	TimerManager.addNextFrameCb(function()
		if self.backBtn then
			self.backBtn.renderOpacity = 1
		end
	end)
	self.view.verticalUButton:SetActiveFastest(false)
	UICtrl.onCreate(self, info)
end

function AppearancePreviewCtrl:addListener()
	function self.backBtn.luaClick()
		self:closePanel()
	end

	self:bindHotKey("Raw/GamepadButtonSouth", function()
		self.backBtn.luaClick()
	end)

	function self.view.verticalUButton.luaClick()
		self.view.rootUComponent:TryChangePage("state", "Vertical")
	end

	function self.view.horizontalUButton.luaClick()
		self.view.rootUComponent:TryChangePage("state", "Horizontal")
	end
end

function AppearancePreviewCtrl:restoreBackButton()
	if not self.backBtn or not self._btnParent or not self._btnLayout then
		return
	end

	local button = self.backBtn
	local parentComponent = self._btnParentComponent
	local luaClick = self._btnLuaClick

	restoreButtonLayout(button, self._btnParent, self._btnSibling, self._btnLayout)
	resetButtonState(button, parentComponent)

	button.luaClick = luaClick

	TimerManager.addNextFrameCb(function()
		if IsNil(button) then
			return
		end

		resetButtonState(button, parentComponent)

		button.luaClick = luaClick
	end)
end

function AppearancePreviewCtrl:onDestroy()
	if self.backBtn and self._btnParent and self._btnLayout then
		self:restoreBackButton()

		self.backBtn = nil
		self._btnLayout = nil
	end

	UICtrl.onDestroy(self)
end

function AppearancePreviewCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function AppearancePreviewCtrl:onShow()
	self.avatarScene:addCameraZoomKeyBinding(self.view.gameObject)
end

function AppearancePreviewCtrl:onVisibleChange(visible)
	if visible then
		self.avatarScene:registerGesture(self.uid, {
			maskRayBoxTrans = self.view.maskRayBoxTrans
		})
	else
		self.avatarScene:unRegisterGesture(self.uid)
	end
end

return AppearancePreviewCtrl
