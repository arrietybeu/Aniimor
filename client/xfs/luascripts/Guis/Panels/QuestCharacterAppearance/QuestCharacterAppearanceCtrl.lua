-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestCharacterAppearance\\QuestCharacterAppearanceCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local TimeUtils = require("Common.Utils.TimeUtils")
local QuestCharacterAppearanceCtrl = Class.LightClass("QuestCharacterAppearanceCtrl", UICtrl)
local QUEST_NAME_IN_ANI = "VX_Pb_NameIn_In"
local QUEST_NAME_OUT_ANI = "VX_Pb_NameIn_Out"
local QUEST_NAME_IN2_ANI = "VX_Pb_NameIn_In2"
local QUEST_NAME_OUT2_ANI = "VX_Pb_NameIn_Out2"
local HORIZONTAL_BOUNDARY_PADDING = 20
local AUTO_CLOSE_TIME = 10
local TEXT_BOUNDS_MAX_VALID_X = 100000

local function getRootCanvasRt()
	local canvasRoot = pg.global.uiMgr.uiRootCanvasRt

	if IsNil(canvasRoot) then
		return nil
	end

	return canvasRoot:GetComponent("RectTransform")
end

local function getTextHorizontalBounds(text, relativeTo)
	if not text or not relativeTo or not text.gameObject.activeInHierarchy or text.text == "" then
		return nil, nil
	end

	local textTransform = text.transform
	local textPlus = textTransform:GetComponent(typeof(CS.XGUI.SRenderer.TextPlus))

	if IsNil(textPlus) then
		return nil, nil
	end

	textPlus:ForceMeshUpdate()

	local textInfo = textPlus.textInfo

	if not textInfo or not textInfo.characterInfo or textInfo.characterCount <= 0 then
		return nil, nil
	end

	local textMaxX

	for i = 0, textInfo.characterCount - 1 do
		local charInfo = textInfo.characterInfo[i]

		if charInfo and charInfo.isVisible then
			local charMaxX = charInfo.topRight.x

			textMaxX = textMaxX and math.max(textMaxX, charMaxX) or charMaxX
		end
	end

	if not textMaxX or textMaxX ~= textMaxX or math.abs(textMaxX) > TEXT_BOUNDS_MAX_VALID_X then
		return nil, nil
	end

	local textRect = textTransform:GetComponent("RectTransform").rect
	local leftWorld = textTransform:TransformPoint(Vector3.New(textRect.xMin, 0, 0))
	local rightWorld = textTransform:TransformPoint(Vector3.New(textMaxX, 0, 0))
	local left = relativeTo:InverseTransformPoint(leftWorld).x
	local right = relativeTo:InverseTransformPoint(rightWorld).x

	return left, math.max(left, right)
end

local function setRectWidth(rectTransform, width)
	local sizeDelta = rectTransform.sizeDelta

	rectTransform.sizeDelta = Vector2.New(sizeDelta.x + width - rectTransform.rect.width, sizeDelta.y)
end

function QuestCharacterAppearanceCtrl:clampTextToHorizontalBoundary(skipTextBounds)
	if not self.view or IsNil(self.view.panelTransform) then
		return
	end

	local boundaryRt = IS_MOBILE and self.view.safeBoxMobileTransform or getRootCanvasRt()

	if IsNil(boundaryRt) then
		return
	end

	CS.XGUI.LayoutMgr.ForceRebuildLayoutImmediate(self.view.panelTransform)

	local minX, maxX

	if not skipTextBounds then
		local texts = {
			self.view.textNameUBaseText,
			self.view.textTitleUBaseText
		}

		for _, text in ipairs(texts) do
			local left, right = getTextHorizontalBounds(text, boundaryRt)

			if left then
				minX = minX and math.min(minX, left) or left
				maxX = maxX and math.max(maxX, right) or right
			end
		end
	end

	local panelRt = self.view.panelTransform.transform:GetComponent("RectTransform")

	if NotNil(panelRt) then
		local panelRect = panelRt.rect
		local panelLeftWorld = panelRt:TransformPoint(Vector3.New(panelRect.xMin, 0, 0))
		local panelLeft = boundaryRt:InverseTransformPoint(panelLeftWorld).x

		minX = minX and math.min(minX, panelLeft) or panelLeft
	end

	if not minX and not maxX then
		return
	end

	local boundaryRect = boundaryRt.rect
	local leftLimit = boundaryRect.xMin + HORIZONTAL_BOUNDARY_PADDING
	local rightLimit = boundaryRect.xMax - HORIZONTAL_BOUNDARY_PADDING
	local deltaX = 0

	if maxX and rightLimit < maxX then
		deltaX = rightLimit - maxX

		if minX and leftLimit > minX + deltaX then
			deltaX = leftLimit - minX
		end
	elseif minX and minX < leftLimit then
		deltaX = leftLimit - minX
	end

	if deltaX == 0 then
		return
	end

	local panelTransform = self.view.panelTransform.transform
	local parentTransform = panelTransform.parent
	local originWorld = boundaryRt:TransformPoint(Vector3.New(0, 0, 0))
	local shiftedWorld = boundaryRt:TransformPoint(Vector3.New(deltaX, 0, 0))
	local localDeltaX

	if parentTransform then
		localDeltaX = parentTransform:InverseTransformPoint(shiftedWorld).x - parentTransform:InverseTransformPoint(originWorld).x
	else
		localDeltaX = shiftedWorld.x - originWorld.x
	end

	if localDeltaX == 0 then
		return
	end

	local localPosition = panelTransform.localPosition

	panelTransform.localPosition = Vector3.New(localPosition.x + localDeltaX, localPosition.y, localPosition.z)
end

function QuestCharacterAppearanceCtrl:alignPanelLeftToText()
	if not self.view or IsNil(self.view.panelTransform) then
		return
	end

	if self.panelHorizontalBoundsAdjusted then
		return
	end

	local panelRt = self.view.panelTransform.transform:GetComponent("RectTransform")

	if IsNil(panelRt) or IsNil(panelRt.parent) then
		return
	end

	local textLeft
	local texts = {
		self.view.textNameUBaseText,
		self.view.textTitleUBaseText
	}

	for _, text in ipairs(texts) do
		local left = getTextHorizontalBounds(text, panelRt)

		if left then
			textLeft = textLeft and math.min(textLeft, left) or left
		end
	end

	if not textLeft then
		return
	end

	local panelRect = panelRt.rect

	if textLeft < panelRect.xMin then
		textLeft = panelRect.xMin
	end

	local targetWidth = panelRect.xMax - textLeft

	if targetWidth <= 0 then
		return
	end

	if self.panelOriginalWidth == nil then
		self.panelOriginalWidth = panelRect.width
	end

	local targetPivotX = textLeft + targetWidth * panelRt.pivot.x
	local targetPivotWorld = panelRt:TransformPoint(Vector3.New(targetPivotX, 0, 0))
	local targetPivotInParent = panelRt.parent:InverseTransformPoint(targetPivotWorld)
	local localPosition = panelRt.localPosition

	setRectWidth(panelRt, targetWidth)

	panelRt.localPosition = Vector3.New(targetPivotInParent.x, localPosition.y, localPosition.z)
	self.panelHorizontalBoundsAdjusted = true
end

function QuestCharacterAppearanceCtrl:resetPanelHorizontalBounds()
	self.panelHorizontalBoundsAdjusted = nil

	if not self.panelOriginalWidth or not self.view or IsNil(self.view.panelTransform) then
		return
	end

	local panelRt = self.view.panelTransform.transform:GetComponent("RectTransform")

	if NotNil(panelRt) then
		setRectWidth(panelRt, self.panelOriginalWidth)
	end
end

function QuestCharacterAppearanceCtrl:applyInfo(info)
	if not info then
		return
	end

	self.name = info.name or ""
	self.title = info.title or ""
	self.level = info.level or ""
	self.style = info.style or 0
	self.posConfig = info.pos
end

function QuestCharacterAppearanceCtrl:getPanelLocalPosition()
	local posConfig = self.posConfig

	if not posConfig then
		return Vector3(0, 0, 0)
	end

	local x = posConfig[1] or 0
	local y = posConfig[2] or 0
	local z = posConfig[3] or 0
	local canvasRt = getRootCanvasRt()

	if IsNil(canvasRt) then
		return Vector3(x, y, z)
	end

	local refW, refH = 1920, 1080
	local canvasScaler = canvasRt:GetComponent("CanvasScaler")

	if NotNil(canvasScaler) then
		refW = canvasScaler.referenceResolution.x
		refH = canvasScaler.referenceResolution.y
	end

	local canvasW = canvasRt.sizeDelta.x
	local canvasH = canvasRt.sizeDelta.y

	if refW <= 0 or refH <= 0 or canvasW <= 0 or canvasH <= 0 then
		return Vector3(x, y, z)
	end

	return Vector3(x / refW * canvasW, y / refH * canvasH, z)
end

function QuestCharacterAppearanceCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.name = ""
	self.title = ""
	self.level = ""
	self.style = 0
	self.posConfig = nil
	self.panelOriginalWidth = nil
	self.panelHorizontalBoundsAdjusted = nil

	self:applyInfo(info)
end

function QuestCharacterAppearanceCtrl:addListener()
	return
end

function QuestCharacterAppearanceCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:showPanel(info)
end

function QuestCharacterAppearanceCtrl:showPanel(info)
	self:applyInfo(info)
	self:clearUpdateTimer()

	self.updateTimer = self:startTimer(function()
		local aniName = self.style == 0 and QUEST_NAME_OUT_ANI or QUEST_NAME_OUT2_ANI

		UIUtils.PlayAnimation(self.view.rootAnimation, aniName, function()
			self:clearUpdateTimer()
			self:closeImmediately()
		end)
	end, AUTO_CLOSE_TIME, false)

	self:resetPanelHorizontalBounds()

	self.view.panelTransform.transform.localPosition = self:getPanelLocalPosition()

	ClientTextUtils.setText(self.view.textNameUBaseText, pg.getGameString(self.name))
	ClientTextUtils.setText(self.view.textTitleUBaseText, pg.getGameString(self.title))
	self.view.rootUComponent:TryChangePage("Personage", self.style == 0 and 0 or 1)
	self.view.rootUComponent:TryChangePage("Title", 0)

	if self.level ~= nil and self.level ~= "" then
		self.view.rootUComponent:TryChangePage("Title", 1)
		ClientTextUtils.setText(self.view.textLevelUBaseText, pg.getGameString(self.level))
	end

	self:clampTextToHorizontalBoundary(true)

	local aniName = self.style == 0 and QUEST_NAME_IN_ANI or QUEST_NAME_IN2_ANI

	UIUtils.PlayAnimation(self.view.rootAnimation, aniName, function()
		self:alignPanelLeftToText()
		self:clampTextToHorizontalBoundary()
	end)
end

function QuestCharacterAppearanceCtrl:clearUpdateTimer()
	if self.updateTimer then
		self:killTimer(self.updateTimer)

		self.updateTimer = nil
	end
end

function QuestCharacterAppearanceCtrl:onDestroy()
	self:clearUpdateTimer()
	UICtrl.onDestroy(self)
end

function QuestCharacterAppearanceCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return QuestCharacterAppearanceCtrl
