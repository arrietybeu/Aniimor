-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoVlogComponent.lua

local Class = require("Core.Framework.Class")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local InteractionConst = require("Common.Const.InteractionConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local SysConfigData = require("Data.sys_config_data")
local TopLogoVlogComponent = Class.LightClass("TopLogoVlogComponent", TopLogoItemComponent)

function TopLogoVlogComponent:ctor(refUContainer, topLogoItem)
	TopLogoVlogComponent.super.ctor(self, refUContainer, topLogoItem)

	self.isReset = false
end

function TopLogoVlogComponent:onCtor()
	self.m_pendingVlogRefresh = false

	self:refreshVisible()
end

function TopLogoVlogComponent:resetRender()
	self.preState = nil
	self.state = nil
	self.isReset = false
	self.isVlogInfoVisible = nil
	self._lastVlogVisible = nil
	self.objectReference = nil
	self.rootComponent = nil
	self.btnVlogUButton = nil
	self.keyHotKeyContent = nil
	self.progressPressUProgressUContainer = nil

	TopLogoVlogComponent.super.resetRender(self)
end

function TopLogoVlogComponent:onDestroy()
	if self.entity then
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_VLOG, self.topLogoVlogInfoUpdate)
	end

	self.m_pendingVlogRefresh = false

	TopLogoVlogComponent.super.onDestroy(self)
end

function TopLogoVlogComponent:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.rootComponent = self.objectReference:GetRefValue("rootComponent")
	self.btnVlogUButton = self.objectReference:GetRefValue("btnVlogUButton")
	self.keyHotKeyContent = self.objectReference:GetRefValue("keyHotKeyContent")
	self.progressPressUProgressUContainer = self.objectReference:GetRefValue("progressPressContainerUContainer")
end

function TopLogoVlogComponent:initUI()
	return
end

function TopLogoVlogComponent:shouldBeActive()
	if not self._isPuppet and not self._isVirtualPuppet then
		return false
	end

	local info = self.entity.topLogoData and self.entity.topLogoData.vlogInfo

	return info ~= nil and info.enable == true
end

function TopLogoVlogComponent:setTopLogoVlogEnable(enable, callBack, distanceShow, distanceInter, showStyle)
	local prevEnable = self.enable

	if self.enable ~= enable then
		self.enable = enable
	end

	if enable then
		self.callBack = callBack
		self.distanceShow = distanceShow or 15
		self.distanceInter = distanceInter or 10
		self.showStyle = showStyle or 0
		self.isReset = false
	end

	if prevEnable ~= self.enable then
		self:onTopLogoCompUpdate()
		self:notifyActiveStateChanged(self:shouldBeActive())
	end
end

function TopLogoVlogComponent:onClickTopLogoVlogBtn(arg)
	return
end

function TopLogoVlogComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	TopLogoVlogComponent.super.onLanguageChanged(self)
end

function TopLogoVlogComponent:addEntityListener()
	function self.topLogoVlogInfoUpdate()
		if self:checkVisibleAndMarkDirty(EventConst.TOPLOGO_VLOG) then
			self:refreshVisible()
		end

		self.m_pendingVlogRefresh = true

		self:notifyActiveStateChanged(self:shouldBeActive())

		if self.topLogoItem:isTopLogoPrefabReady() then
			self.m_pendingVlogRefresh = false
		end
	end

	if self.entity then
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_VLOG, self.topLogoVlogInfoUpdate)
	end
end

function TopLogoVlogComponent:checkTopLogoCompUpdate()
	return TopLogoVlogComponent.super.checkTopLogoCompUpdate(self)
end

function TopLogoVlogComponent:innerGetVisible()
	if not TopLogoVlogComponent.super.innerGetVisible(self) then
		return false
	end

	if not self.isVlogInfoVisible then
		return false
	end

	if not self._isPuppet and not self._isVirtualPuppet then
		return false
	end

	if not self.enable then
		return false
	end

	return true
end

function TopLogoVlogComponent:refreshTopLogoInfo(callFromUpdate)
	if self.m_pendingVlogRefresh then
		self.m_pendingVlogRefresh = false
	end

	if self:checkFinalVisible() then
		self:checkAndLoadUContainerUrlSupportAsync()
	end
end

function TopLogoVlogComponent:get2DDistance()
	if pg.me then
		local ent = self.entity

		if ent then
			local entPos = pg.me:getPosition()

			return Utils.distance2D(ent:getPosition(), entPos)
		end
	end
end

function TopLogoVlogComponent:onTopLogoCompUpdate()
	local info = self.entity.topLogoData.vlogInfo

	if info then
		self:setTopLogoVlogEnable(info.enable, info.callBack, info.distanceShow, info.distanceInter, info.showStyle)
	end

	self.state = self:getVlogInfoState(self.topLogoItem.distance)
	self.isVlogInfoVisible = self.state ~= UIConst.TOPLOGO_NPC_DIS.HIDE

	self:setVlogVisible(self.isVlogInfoVisible)
end

function TopLogoVlogComponent:setVlogVisible(visible)
	if not self.refUContainer then
		return
	end

	if self:checkContainerLoaded() then
		if self._lastVlogVisible ~= visible then
			self._lastVlogVisible = visible

			self.refUContainer:SetActive(visible)
			LuaUIUtils.setUIViewVisible(self.rootComponent, visible)
		end

		self:refreshVlog()
	end
end

function TopLogoVlogComponent:refreshVlog()
	if not self.rootComponent then
		return
	end

	self.state = self:getVlogInfoState()

	LuaUIUtils.setUIViewVisible(self.rootComponent, self.state ~= UIConst.TOPLOGO_NPC_DIS.HIDE)
	LuaUIUtils.setUIViewVisible(self.keyHotKeyContent, false)

	if self.preState == nil or self.state ~= self.preState or self.isReset then
		self.rootComponent:TryChangePage("State", 0)

		if self.state == UIConst.TOPLOGO_NPC_DIS.NEAR then
			self.rootComponent:TryChangePage("State", 1)
			self.btnVlogUButton:TryChangePage("IconType", self.showStyle or 0)

			self.isReset = false
		end

		self.preState = self.state
	end
end

function TopLogoVlogComponent:refreshVlogInteractState(flag)
	local id = self.entity and self.entity:getGlobalId()

	if id == nil then
		return
	end

	if flag then
		self.curId = id

		facade:SendMessageCommand(MessageName.ENTER_TRIGGER, {
			dist = self.distanceInter or 0,
			globalId = id,
			actionPrototypeId = InteractionConst.STYLE_CONST.VLOG_INTERACT,
			interactionType = InteractionConst.INTERACTION_TYPE_VLOG,
			interactFunc = function()
				if self.callBack then
					self.callBack()
				end
			end
		})
	else
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
			actionPrototypeId = InteractionConst.STYLE_CONST.VLOG_INTERACT,
			globalId = id,
			interactionType = InteractionConst.INTERACTION_TYPE_VLOG
		})
	end
end

function TopLogoVlogComponent:onTopLogoCompVisibleChanged(visible)
	if self:checkFinalVisible() and self.enable then
		self.isReset = visible

		self:refreshVlog()
	end
end

function TopLogoVlogComponent:getVlogInfoState()
	if not self.entity then
		return UIConst.TOPLOGO_NPC_DIS.HIDE
	end

	local distance = self:get2DDistance()

	if not self.enable then
		return UIConst.TOPLOGO_NPC_DIS.HIDE
	end

	if not distance or not self.distanceShow then
		return UIConst.TOPLOGO_NPC_DIS.HIDE
	end

	if distance > self.distanceShow then
		return UIConst.TOPLOGO_NPC_DIS.HIDE
	elseif distance < self.distanceInter then
		return UIConst.TOPLOGO_NPC_DIS.NEAR
	else
		return UIConst.TOPLOGO_NPC_DIS.FAR
	end
end

function TopLogoVlogComponent:getInitMaxDistance()
	return SysConfigData.CollectCallFriendRange
end

return TopLogoVlogComponent
