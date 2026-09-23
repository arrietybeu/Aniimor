-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TextLink\\TextLinkCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local MessageName = require("Const.MessageName")
local TextLinkCtrl = Class.LightClass("TextLinkCtrl", UICtrl)

TextLinkCtrl.messages = {
	[MessageName.UI_ON_OPEN] = {
		"onOtherUIOpen",
		true
	}
}

function TextLinkCtrl:checkInfoValid(info)
	return type(info) == "table" and type(info.textList) == "table" and #info.textList > 0
end

function TextLinkCtrl:onOtherUIOpen(uid)
	if not uid or uid == self.uid or not self:checkUIOpen() then
		return
	end

	local ctrl = self.adapter:tryGetCtrlByUid(uid)

	if ctrl and ctrl.uiConfig and ctrl.uiConfig.keepTextLinkOnOpen then
		return
	end

	self:closeImmediately()
end

function TextLinkCtrl:onCreate(info)
	self._linkExecuting = false
	self._linkNavigationFrameId = nil

	UICtrl.onCreate(self, info)

	local textList = info and info.textList

	if type(textList) ~= "table" or #textList == 0 then
		self:dismiss()

		return
	end

	self.view.listUList:SetList(textList)
	self:_scheduleLinkNavigation()
end

function TextLinkCtrl:_scheduleLinkNavigation()
	if self._linkNavigationFrameId then
		TimerManager.delFrameCb(self._linkNavigationFrameId)
	end

	self._linkNavigationFrameId = self:startFrameTimer(function()
		self._linkNavigationFrameId = nil

		local navMgr = pg.global.navMgr
		local root = self.view and self.view.widget and self.view.widget.transform

		if navMgr and root and not IsNil(root) then
			navMgr:BeginTextLinkPanelNavigation(root)
			self:_startLinkArrowRefresh()
		end
	end, 1)
end

function TextLinkCtrl:_executeHyperlink(data, action, content, contentRect)
	if type(action) ~= "string" or action == "" then
		return
	end

	local snapshotItem = data and data.snapshotItem
	local canInvokeSource = snapshotItem and snapshotItem:CanInvokeSource()
	local sourceEffect = canInvokeSource and snapshotItem:ResolveSourceEffect(action) or nil
	local invokeSource = sourceEffect == LuaUIUtils.HYPERLINK_EFFECT.TOOLTIP or sourceEffect == LuaUIUtils.HYPERLINK_EFFECT.OTHER
	local effect = invokeSource and sourceEffect or LuaUIUtils.resolveHyperTextEffect(action)

	if effect == nil then
		if not canInvokeSource then
			return
		end

		invokeSource = true
		effect = LuaUIUtils.HYPERLINK_EFFECT.OTHER
	end

	if effect == LuaUIUtils.HYPERLINK_EFFECT.TOOLTIP then
		if invokeSource then
			snapshotItem:TryInvokeSource(action, content, contentRect)
		else
			LuaUIUtils.clickHyperText(action, content, contentRect)
		end

		return
	end

	if self._linkExecuting then
		return
	end

	self._linkExecuting = true

	local savedSnapshotItem = snapshotItem
	local savedAction = action
	local savedContent = content
	local savedInvokeSource = invokeSource

	self:closeImmediately()

	if savedInvokeSource then
		savedSnapshotItem:TryInvokeSource(savedAction, savedContent, nil)
	else
		LuaUIUtils.clickHyperText(savedAction, savedContent, nil)
	end
end

function TextLinkCtrl._getTopLineLinkCenter(textInfo, linkInfo)
	local lineNumber
	local minX = math.huge
	local maxX = -math.huge
	local maxTopY = -math.huge

	for offset = 0, linkInfo.linkTextLength - 1 do
		local characterInfo = textInfo.characterInfo[linkInfo.linkTextfirstCharacterIndex + offset]

		if characterInfo and characterInfo.isVisible then
			if lineNumber == nil then
				lineNumber = characterInfo.lineNumber
			elseif characterInfo.lineNumber ~= lineNumber then
				break
			end

			minX = math.min(minX, characterInfo.bottomLeft.x)
			maxX = math.max(maxX, characterInfo.topRight.x)
			maxTopY = math.max(maxTopY, characterInfo.topRight.y)
		end
	end

	if minX == math.huge then
		return nil, nil
	end

	return (minX + maxX) * 0.5, maxTopY
end

function TextLinkCtrl:_offsetFocusedLinkArrow(button)
	if not pg.game.input:isUsingGamepad() or IsNil(button) then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference and objectReference:GetRefValue("txtNameUSDFText")
	local textTransform = txtNameUSDFText and txtNameUSDFText.transform
	local textPlus = textTransform and textTransform:GetComponent(typeof(CS.XGUI.SRenderer.TextPlus))

	if IsNil(textPlus) then
		return
	end

	local triangleTransform = button.transform:Find("UI_Com_SelectedState_Arrow/SelectedState/Triangle")
	local arrowTransform = triangleTransform and triangleTransform:Find("Arrow")

	if IsNil(triangleTransform) or IsNil(arrowTransform) or IsNil(triangleTransform.parent) then
		return
	end

	textPlus:ForceMeshUpdate()

	local textInfo = textPlus.textInfo

	if textInfo == nil or textInfo.linkCount == nil or textInfo.linkCount <= 0 then
		return
	end

	local focusedLinkIndex = 0
	local decoratedText = txtNameUSDFText.text or ""
	local decorationIndex = string.find(decoratedText, "UI_Img_TextLink_Deco_L", 1, true)

	if decorationIndex then
		local prefix = string.sub(decoratedText, 1, decorationIndex)
		local _, linkCountBeforeDecoration = string.gsub(prefix, "<link", "")

		focusedLinkIndex = linkCountBeforeDecoration
	end

	focusedLinkIndex = math.max(0, math.min(focusedLinkIndex, textInfo.linkCount - 1))

	local linkInfo = textInfo.linkInfo[focusedLinkIndex]

	if linkInfo == nil then
		return
	end

	local linkCenterX, linkTopY = TextLinkCtrl._getTopLineLinkCenter(textInfo, linkInfo)

	if linkCenterX == nil then
		return
	end

	local linkTop = Vector3(linkCenterX, linkTopY, 0)
	local worldLinkTop = textPlus.transform:TransformPoint(linkTop)
	local triangleParentRect = triangleTransform.parent:GetComponent("RectTransform")

	if IsNil(triangleParentRect) then
		return
	end

	local targetLocalPosition = triangleParentRect:InverseTransformPoint(worldLinkTop)
	local triangleRect = triangleTransform:GetComponent("RectTransform")
	local arrowRect = arrowTransform:GetComponent("RectTransform")

	if IsNil(triangleRect) or IsNil(arrowRect) then
		return
	end

	local triangleAnchorY = ((triangleRect.anchorMin.y + triangleRect.anchorMax.y) * 0.5 - triangleParentRect.pivot.y) * triangleParentRect.rect.height
	local arrowAnchorY = ((arrowRect.anchorMin.y + arrowRect.anchorMax.y) * 0.5 - triangleRect.pivot.y) * triangleRect.rect.height
	local arrowPositionY = targetLocalPosition.y - triangleAnchorY - arrowAnchorY + arrowRect.rect.height * arrowRect.pivot.y

	triangleTransform.anchoredPosition = Vector2(targetLocalPosition.x, arrowPositionY)
end

function TextLinkCtrl:_stopLinkArrowRefresh()
	if self._linkArrowRefreshFrameId then
		TimerManager.delFrameCb(self._linkArrowRefreshFrameId)

		self._linkArrowRefreshFrameId = nil
	end

	self._linkArrowButton = nil
	self._linkGamepadActive = false
end

function TextLinkCtrl:_focusTextLinkPanel(root, navMgr)
	if not pg.game.input:isUsingGamepad() or IsNil(root) or navMgr == nil then
		return
	end

	local buttons = root:GetComponentsInChildren(typeof(CS.XGUI.UButton), false)

	if buttons == nil then
		return
	end

	for index = 0, buttons.Length - 1 do
		local button = buttons[index]
		local objectReference = button:GetComponent("ObjectReference")
		local text = objectReference and objectReference:GetRefValue("txtNameUSDFText")

		if text and text.enabledHyperlink and button.gameObject.activeInHierarchy then
			local focused = navMgr:FocusItem(button)

			focused = focused or navMgr:FocusItemInThis(button)

			if focused then
				self._linkArrowButton = button
			end

			return
		end
	end
end

function TextLinkCtrl:_refreshLinkArrow()
	if not pg.game.input:isUsingGamepad() or not self.view or not self.view.widget then
		return
	end

	local root = self.view.widget.transform

	if IsNil(root) then
		return
	end

	local buttons = root:GetComponentsInChildren(typeof(CS.XGUI.UButton), false)

	if buttons == nil then
		return
	end

	local focusedButton = self._linkArrowButton

	for index = 0, buttons.Length - 1 do
		local button = buttons[index]
		local objectReference = button:GetComponent("ObjectReference")
		local text = objectReference and objectReference:GetRefValue("txtNameUSDFText")

		if text and string.find(text.text or "", "UI_Img_TextLink_Deco_L", 1, true) then
			focusedButton = button

			break
		end
	end

	if focusedButton and focusedButton ~= self._linkArrowButton then
		local navMgr = pg.global.navMgr

		if navMgr then
			local focused = navMgr:FocusItem(focusedButton)

			focused = focused or navMgr:FocusItemInThis(focusedButton)

			if focused then
				self._linkArrowButton = focusedButton
			end
		end
	end

	if focusedButton then
		self:_offsetFocusedLinkArrow(focusedButton)
	end
end

function TextLinkCtrl:_startLinkArrowRefresh()
	self:_stopLinkArrowRefresh()

	self._linkArrowRefreshFrameId = TimerManager.addRepeatNextFrameCb(function()
		if not self.view or not self:checkUIOpen() then
			self:_stopLinkArrowRefresh()

			return
		end

		if not pg.game.input:isUsingGamepad() then
			self._linkGamepadActive = false

			return
		end

		if not self._linkGamepadActive then
			local navMgr = pg.global.navMgr
			local root = self.view.widget and self.view.widget.transform

			if navMgr and root and not IsNil(root) then
				navMgr:BeginTextLinkPanelNavigation(root)
				self:_focusTextLinkPanel(root, navMgr)

				self._linkGamepadActive = self._linkArrowButton ~= nil
			end
		end

		self:_refreshLinkArrow()
	end)
end

function TextLinkCtrl:addListener()
	UICtrl.addListener(self)

	function self.view.listUList.luaFinishRender()
		self:_scheduleLinkNavigation()
	end

	function self.view.listUList.luaRenderItem(button, _, data)
		button.luaRenderTooltip = nil

		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference and objectReference:GetRefValue("txtNameUSDFText")

		if txtNameUSDFText then
			txtNameUSDFText.enabledHyperlink = true
			txtNameUSDFText.luaResolveHyperlinkEffect = nil

			function txtNameUSDFText.luaOnHyperlinkClick(action, content, contentRect)
				self:_executeHyperlink(data, action, content, contentRect)
			end

			ClientTextUtils.setText(txtNameUSDFText, data and data.text or "")
		end
	end

	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("CONSOLE_BAR_TERM_DEFINITION"))

	local txtTipsTransform = self.view.transform:Find("SafeBoxMobile/Windows/Tips/TxtTips")
	local txtTips = txtTipsTransform and txtTipsTransform:GetComponent("USDFText")

	if txtTips then
		ClientTextUtils.setText(txtTips, pg.getGameString("CONSOLE_BAR_VIEW_TEXT_DETAILS"))
	end
end

function TextLinkCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function TextLinkCtrl:onDestroy()
	self:_stopLinkArrowRefresh()

	if self._linkNavigationFrameId then
		TimerManager.delFrameCb(self._linkNavigationFrameId)

		self._linkNavigationFrameId = nil
	end

	if pg.global.navMgr then
		pg.global.navMgr:EndTextLinkPanelNavigation()
	end

	self._openInfo = nil
	self._linkExecuting = false

	UICtrl.onDestroy(self)
end

return TextLinkCtrl
