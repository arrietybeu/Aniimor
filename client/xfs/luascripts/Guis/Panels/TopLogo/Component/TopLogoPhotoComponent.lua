-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoPhotoComponent.lua

local Class = require("Core.Framework.Class")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SysConfigData = require("Data.sys_config_data")
local TopLogoPhotoComponent = Class.LightClass("TopLogoPhotoComponent", TopLogoItemComponent)

function TopLogoPhotoComponent:ctor(refUContainer, topLogoItem)
	TopLogoPhotoComponent.super.ctor(self, refUContainer, topLogoItem)
end

function TopLogoPhotoComponent:onCtor()
	self.m_pendingPhotoRefresh = false
	self.m_photoAppliedState = nil

	self:refreshVisible()
end

function TopLogoPhotoComponent:shouldBeActive()
	if self.m_pendingPhotoRefresh then
		return true
	end

	return self.commandVisible == true
end

function TopLogoPhotoComponent:resetRender()
	self.photoVisible = nil
	self.m_photoAppliedState = nil

	if self.m_cbCachePhotoInfo then
		self.m_cbCachePhotoInfo = nil
	end

	self.objectReference = nil
	self.identificationUComponent = nil
	self.ligatureUWidget = nil
	self.ligatureBubbleUWidget = nil
	self.petNameUText = nil
	self.photoRecognizeUWidget = nil
	self.recognizeNameUText = nil

	TopLogoPhotoComponent.super.resetRender(self)
end

function TopLogoPhotoComponent:onDestroy()
	if self.entity then
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_PHOTO, self.onPhotoExpectationMsg)
	end

	self.m_pendingPhotoRefresh = false

	TopLogoPhotoComponent.super.onDestroy(self)

	self.m_cbCachePhotoInfo = nil
	self.m_loadedPhotoCallBack = nil
end

function TopLogoPhotoComponent:initUI()
	self:refreshPhotoInfo()
end

function TopLogoPhotoComponent:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.ligatureBubbleUWidget = self.objectReference:GetRefValue("ligatureBubbleUWidget")
	self.ligatureUWidget = self.objectReference:GetRefValue("ligatureUWidget")
	self.photoRecognizeUWidget = self.objectReference:GetRefValue("photoRecognizeUWidget")
	self.recognizeNameUText = self.objectReference:GetRefValue("recognizeNameUText")
	self.identificationUComponent = self.objectReference:GetRefValue("identificationUComponent")
	self.petNameUText = self.objectReference:GetRefValue("petNameUText")
end

function TopLogoPhotoComponent:checkFinalVisible()
	if not TopLogoPhotoComponent.super.checkFinalVisible(self) then
		return false
	end

	if not self.commandVisible then
		return false
	end

	return true
end

function TopLogoPhotoComponent:m_buildPhotoState(visible)
	return {
		uiType = self.uiType,
		visible = visible,
		content = self.content,
		state = self.state
	}
end

function TopLogoPhotoComponent:m_isSamePhotoState(left, right)
	if left == nil or right == nil then
		return left == right
	end

	return left.uiType == right.uiType and left.visible == right.visible and left.content == right.content and left.state == right.state
end

function TopLogoPhotoComponent:m_markPhotoStateApplied(photoState)
	if photoState == nil then
		self.m_photoAppliedState = nil
		self.photoVisible = nil

		return
	end

	self.m_photoAppliedState = {
		uiType = photoState.uiType,
		visible = photoState.visible,
		content = photoState.content,
		state = photoState.state
	}
	self.photoVisible = photoState.visible
end

function TopLogoPhotoComponent:m_setCombatVisibleForPhoto(visible)
	local topLogoItem = self.topLogoItem
	local combatComp = topLogoItem and topLogoItem.components and topLogoItem.components[UIConst.TOPLOGO_COMPONENT.COMBAT]

	if combatComp then
		combatComp:setVisible(visible, UIConst.TOPLOGO_VISIBLE_KEY.PHOTO)
	end
end

function TopLogoPhotoComponent:m_applyPhotoBusinessState(uiType, visible)
	if uiType == UIConst.PHOTO_TYPE.DESC or uiType == UIConst.PHOTO_TYPE.IDENTIFY then
		self:m_setCombatVisibleForPhoto(not visible)
	elseif uiType == UIConst.PHOTO_TYPE.HIDDEN then
		self:m_setCombatVisibleForPhoto(true)
	end
end

function TopLogoPhotoComponent:addEntityListener()
	function self.onPhotoExpectationMsg(uiType, isVisible, content, state)
		self.uiType = uiType
		self.commandVisible = isVisible
		self.content = content
		self.state = state

		local visible = self.commandVisible

		self:m_applyPhotoBusinessState(uiType, visible)

		if visible then
			self.m_pendingPhotoRefresh = true

			self:notifyActiveStateChanged(true)

			if not self.topLogoItem:isTopLogoPrefabReady() then
				return
			end

			self.m_pendingPhotoRefresh = false
		else
			self.m_pendingPhotoRefresh = false

			self:notifyActiveStateChanged(false)
		end

		self:m_tryApplyPhotoState(visible)
	end

	if self.entity then
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_PHOTO, self.onPhotoExpectationMsg)
	end
end

function TopLogoPhotoComponent:m_tryApplyPhotoState(visible)
	local photoState = self:m_buildPhotoState(visible)

	if self:checkContainerLoaded() then
		if not self:m_isSamePhotoState(self.m_photoAppliedState, photoState) then
			self:refreshPhotoInfo()
			self:m_markPhotoStateApplied(photoState)
		end
	else
		self.m_cbCachePhotoInfo = photoState

		if not self.m_loadedPhotoCallBack then
			function self.m_loadedPhotoCallBack(isSuccess)
				local cachedPhotoInfo = self.m_cbCachePhotoInfo

				if isSuccess and cachedPhotoInfo and not self:m_isSamePhotoState(self.m_photoAppliedState, cachedPhotoInfo) then
					self:refreshPhotoInfo()
					self:m_markPhotoStateApplied(cachedPhotoInfo)
				end

				self.m_cbCachePhotoInfo = nil
			end
		end

		if visible then
			self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedPhotoCallBack, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
		end
	end
end

function TopLogoPhotoComponent:refreshTopLogoInfo(callFromUpdate)
	if self.m_pendingPhotoRefresh then
		self.m_pendingPhotoRefresh = false

		self:m_tryApplyPhotoState(self:checkFinalVisible())

		return
	end
end

function TopLogoPhotoComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	TopLogoPhotoComponent.super.onLanguageChanged(self)
	self:refreshPhotoInfo()
end

function TopLogoPhotoComponent:refreshPhotoInfo()
	if not self:checkContainerLoaded() then
		return
	end

	if self.uiType == UIConst.PHOTO_TYPE.BUBBLE then
		self:refreshPhotoExpectation(self.commandVisible)
	elseif self.uiType == UIConst.PHOTO_TYPE.TIP then
		self:refreshPhotoExpectationTip(self.commandVisible)
	elseif self.uiType == UIConst.PHOTO_TYPE.DESC then
		self.topLogoItem:refreshPhotoDesc(self.commandVisible, self.content)
	elseif self.uiType == UIConst.PHOTO_TYPE.IDENTIFY then
		self.topLogoItem:refreshPhotoIdentify(self.commandVisible, self.content, self.state)
	elseif self.uiType == UIConst.PHOTO_TYPE.HIDDEN then
		self:refreshPhotoExpectation(false)
		self:refreshPhotoExpectationTip(false)
		self:refreshPhotoRecognize(false, "")
		self:refreshPhotoIdentify(false, "", 0)
	else
		self.ligatureBubbleUWidget:SetActive(false)
		self.ligatureUWidget:SetActive(false)
		self.photoRecognizeUWidget:SetActive(false)
		self.identificationUComponent:SetActive(false)
	end
end

function TopLogoPhotoComponent:refreshPhotoExpectation(visible)
	if self:checkContainerLoaded() then
		self.ligatureBubbleUWidget:SetActive(visible)
	end
end

function TopLogoPhotoComponent:refreshPhotoExpectationTip(visible)
	if self:checkContainerLoaded() then
		self.ligatureUWidget:SetActive(visible)
	end
end

function TopLogoPhotoComponent:refreshPhotoRecognize(visible, name, iconActive)
	if self:checkContainerLoaded() then
		if visible == true then
			self.photoRecognizeUWidget:SetActive(true)
			ClientTextUtils.setText(self.recognizeNameUText, pg.getLocalizationText(name or "EntityName"))
		else
			self.photoRecognizeUWidget:SetActive(false)
		end
	end
end

function TopLogoPhotoComponent:refreshPhotoIdentify(visible, name, state)
	if self:checkContainerLoaded() then
		if visible == true then
			self.identificationUComponent:SetActive(true)
			ClientTextUtils.setText(self.petNameUText, pg.getLocalizationText(name or "EntityName"))
			self.identificationUComponent:TryChangePage("State", state)
		else
			self.identificationUComponent:SetActive(false)
		end
	end
end

function TopLogoPhotoComponent:getInitMaxDistance()
	return SysConfigData.NPC_TOPLOGO_DISTANCE
end

return TopLogoPhotoComponent
