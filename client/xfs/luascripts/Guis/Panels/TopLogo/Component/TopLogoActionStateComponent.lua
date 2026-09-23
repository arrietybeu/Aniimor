-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoActionStateComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("TopLogoActionStateComponent")
local Class = require("Core.Framework.Class")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local TopLogoActionStateComponent = Class.LightClass("TopLogoActionStateComponent", TopLogoItemComponent)
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local TopLogoConst = require("Const.TopLogoConst")
local AddressDataConst = require("Const.AddressDataConst")
local SysConfigData = require("Data.sys_config_data")
local AppearanceAction = require("Data.appearance_action_data")
local ACTION_STATE_RECTSIZE = Vector2.New(200, 200)

function TopLogoActionStateComponent.resolveStateFromEntity(entity)
	if not entity then
		return Const.PlayerActionState.None, 0
	end

	local owner = entity.master or entity.getMasterEntity and entity:getMasterEntity() or entity
	local target = owner

	if owner.isControllingPet and owner:isControllingPet() then
		target = owner:getCurPetEntity()
	end

	if target ~= entity then
		return Const.PlayerActionState.None, 0
	end

	local multiInteractAction = owner.multiInteractAction
	local multiInteractActionId = multiInteractAction and multiInteractAction.creatorId == owner.uid and multiInteractAction.actionId or 0

	return owner.actionState or Const.PlayerActionState.None, multiInteractActionId
end

function TopLogoActionStateComponent:ctor(refUContainer, topLogoItem)
	TopLogoActionStateComponent.super.ctor(self, refUContainer, topLogoItem)

	self.actionState, self.multiInteractActionId = TopLogoActionStateComponent.resolveStateFromEntity(self.entity)
	self.m_innerRefreshVisible = nil

	self:m_tryInitActionState()
end

function TopLogoActionStateComponent:onCtor()
	self.m_pendingActionState = false

	self:refreshVisible()
end

function TopLogoActionStateComponent:isMainEntity()
	if not pg.me or not self.entity then
		return false
	end

	local uid = self.entity.master and self.entity.master.uid or self.entity.uid

	return uid == pg.me.uid
end

function TopLogoActionStateComponent.isPlayerActionState(actionState)
	for _, state in pairs(Const.PlayerActionState) do
		if actionState == state then
			return true
		end
	end

	return false
end

function TopLogoActionStateComponent:isEmotionActionState(actionState)
	if actionState == nil or TopLogoActionStateComponent.isPlayerActionState(actionState) then
		return false
	end

	local actionData = AppearanceAction[actionState]

	return actionData ~= nil and not string.isNilOrEmpty(actionData.emojPrefab)
end

function TopLogoActionStateComponent:hasDisplayActionState()
	if self:isMainEntity() then
		return self:isEmotionActionState(self.actionState)
	end

	return self.actionState ~= nil and self.actionState ~= Const.PlayerActionState.None
end

function TopLogoActionStateComponent:hasDisplayMultiInteractAction()
	if self:isMainEntity() or not self.multiInteractActionId or self.multiInteractActionId <= 0 then
		return false
	end

	local actionData = AppearanceAction[self.multiInteractActionId]

	return actionData ~= nil and not string.isNilOrEmpty(actionData.icon)
end

function TopLogoActionStateComponent:hasDisplayState()
	if self.actionState ~= nil and self.actionState ~= Const.PlayerActionState.None then
		return self:hasDisplayActionState()
	end

	return self:hasDisplayMultiInteractAction()
end

function TopLogoActionStateComponent:getActionStateUrl()
	if self.actionState ~= nil and self.actionState ~= Const.PlayerActionState.None then
		if self:isMainEntity() and TopLogoActionStateComponent.isPlayerActionState(self.actionState) then
			return "", false
		end

		local url = AddressDataConst.PLAYER_ACTION_STATE_URL[self.actionState]

		if url then
			return url, false
		end

		local actionData = AppearanceAction[self.actionState]

		url = actionData and actionData.emojPrefab or ""

		return url, not string.isNilOrEmpty(url)
	end

	if not self:hasDisplayMultiInteractAction() then
		return "", false
	end

	local actionData = AppearanceAction[self.multiInteractActionId]

	return AddressDataConst.TOPLOGO_COMP_RES_ICON_WITH_BG, false, actionData.icon
end

function TopLogoActionStateComponent:clearActionStateContent()
	if NotNil(self.actionStateUContainer) then
		self.actionStateUContainer:DestroyContent()
	end

	local content = NotNil(self.refUContainer) and self.refUContainer.content

	if content then
		content:SetSizeDelta(Vector2.zero)
	end
end

function TopLogoActionStateComponent:shouldBeActive()
	if self.m_pendingActionState == true then
		return true
	end

	return self:hasDisplayState()
end

function TopLogoActionStateComponent:destroy()
	self.m_pendingActionState = false

	TopLogoActionStateComponent.super.destroy(self)

	self.m_innerRefreshVisible = nil
	self.onSetActionState = nil
end

function TopLogoActionStateComponent:m_tryInitActionState()
	if self.onSetActionState and (self.actionState > Const.PlayerActionState.None or self.multiInteractActionId > 0) then
		self:setDisplayState(TopLogoActionStateComponent.resolveStateFromEntity(self.entity))
	end
end

function TopLogoActionStateComponent:restoreStateFromEntity()
	local actionState, multiInteractActionId = TopLogoActionStateComponent.resolveStateFromEntity(self.entity)

	if self.onSetActionState and (self.actionState ~= actionState or self.multiInteractActionId ~= multiInteractActionId or actionState ~= Const.PlayerActionState.None or multiInteractActionId > 0) then
		self:setDisplayState(actionState, multiInteractActionId)
	end
end

function TopLogoActionStateComponent:resetRender()
	self.m_pendingActionState = self:hasDisplayState()
	self.m_innerRefreshVisible = nil
	self.actionStateUContainer = nil

	TopLogoActionStateComponent.super.resetRender(self)
end

function TopLogoActionStateComponent:findObjects()
	local objectReference = self.refUContainer.content:GetComponent("ObjectReference")

	self.actionStateUContainer = objectReference:GetRefValue("actionStateUContainer")
end

function TopLogoActionStateComponent:addEntityListener()
	function self.onSetActionState(actionState)
		self:setActionState(actionState)
	end

	if self.entity ~= nil and self.entity.eventEmitter ~= nil then
		self.entity.eventEmitter:addEventListener(EventConst.PLAYER_ACTION_STATE_CHANGED, self.onSetActionState)
	end
end

function TopLogoActionStateComponent:setActionState(actionState)
	if actionState == nil then
		return
	end

	self:setDisplayState(actionState, self.multiInteractActionId)
end

function TopLogoActionStateComponent:setMultiInteractAction(multiInteractAction)
	local owner = self.entity.master or self.entity.getMasterEntity and self.entity:getMasterEntity() or self.entity
	local multiInteractActionId = multiInteractAction and multiInteractAction.creatorId == owner.uid and multiInteractAction.actionId or 0

	self:setDisplayState(self.actionState, multiInteractActionId)
end

function TopLogoActionStateComponent:setDisplayState(actionState, multiInteractActionId)
	self.actionState = actionState
	self.multiInteractActionId = multiInteractActionId or 0

	self:notifyMaxDistanceChanged()

	self.m_pendingActionState = self:hasDisplayState()

	self:notifyActiveStateChanged(self:shouldBeActive())

	if not self.topLogoItem:isTopLogoPrefabReady() then
		return
	end

	self.m_pendingActionState = false

	if not self.m_innerRefreshVisible then
		function self.m_innerRefreshVisible(loadState)
			if not loadState then
				return
			end

			local content = NotNil(self.refUContainer) and self.refUContainer.content
			local url, isEmotionActionState, multiInteractActionIcon = self:getActionStateUrl()

			if NotNil(self.actionStateUContainer) then
				if string.isNilOrEmpty(url) then
					self.actionStateUContainer:DestroyContent()
				else
					self.actionStateUContainer:SetUrlWithCallback(url, function(widget)
						if isEmotionActionState then
							widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
						elseif not string.isNilOrEmpty(multiInteractActionIcon) then
							local objectReference = widget:GetComponent("ObjectReference")
							local icon = objectReference:GetRefValue("uINodeIconUImage")

							icon.preserveAspect = false
							icon.url = multiInteractActionIcon
						end
					end)
				end
			end

			if content then
				if string.isNilOrEmpty(url) then
					content:SetSizeDelta(Vector2.zero)
				else
					content:SetSizeDelta(ACTION_STATE_RECTSIZE)
				end
			end
		end
	end

	if not self:hasDisplayState() then
		self:clearActionStateContent()

		return
	end

	self:checkAndLoadUContainerUrlSupportAsync(self.m_innerRefreshVisible, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
end

function TopLogoActionStateComponent:refreshTopLogoInfo(callFromUpdate)
	if self.m_pendingActionState == true then
		self.m_pendingActionState = false

		self:setDisplayState(self.actionState, self.multiInteractActionId)
	end
end

function TopLogoActionStateComponent:onDestroy()
	if self.entity ~= nil and self.entity.eventEmitter ~= nil then
		self.entity.eventEmitter:removeEventListener(EventConst.PLAYER_ACTION_STATE_CHANGED, self.onSetActionState)
	end

	TopLogoActionStateComponent.super.onDestroy(self)
end

function TopLogoActionStateComponent:getInitMaxDistance()
	if self:hasDisplayState() then
		return UIConst.TopLogoEnterRange
	end

	return SysConfigData.NPC_TOPLOGO_DISTANCE
end

return TopLogoActionStateComponent
