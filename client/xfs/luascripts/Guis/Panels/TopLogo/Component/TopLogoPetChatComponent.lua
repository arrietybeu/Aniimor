-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoPetChatComponent.lua

local Class = require("Core.Framework.Class")
local PetChatData = require("Data.pet_chat_data")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TopLogoPetChatComponent = Class.LightClass("TopLogoPetChatComponent", TopLogoItemComponent)
local SysConfigData = require("Data.sys_config_data")
local UIUtils = UIUtils

function TopLogoPetChatComponent:ctor(refUContainer, topLogoItem)
	TopLogoPetChatComponent.super.ctor(self, refUContainer, topLogoItem)
end

function TopLogoPetChatComponent:onCtor()
	self.m_pendingPetChatId = nil

	self:refreshVisible()
end

function TopLogoPetChatComponent:shouldBeActive()
	if self.m_pendingPetChatId or self.m_cbCachePetChatInfo then
		return true
	end

	return self.petChatEnabled == true
end

function TopLogoPetChatComponent:onDestroy()
	if self.petChatTimer then
		self:killTimer(self.petChatTimer)

		self.petChatTimer = nil
	end

	self.m_pendingPetChatId = nil

	TopLogoPetChatComponent.super.onDestroy(self)

	self.m_cbCachePetChatInfo = nil
	self.m_loadedPetChatCallBack = nil
end

function TopLogoPetChatComponent:resetRender()
	if self.petChatTimer then
		self:killTimer(self.petChatTimer)

		self.petChatTimer = nil
	end

	self.petChatEnabled = false
	self.objectReference = nil
	self.petChatUComponent = nil
	self.contentUText = nil
	self.petChatAnimation = nil

	TopLogoPetChatComponent.super.resetRender(self)
end

function TopLogoPetChatComponent:initUI()
	return
end

function TopLogoPetChatComponent:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.petChatUComponent = self.objectReference:GetRefValue("petChatUComponent")
	self.petChatAnimation = self.objectReference:GetRefValue("petChatAnimation")
	self.contentUText = self.objectReference:GetRefValue("contentUText")
end

function TopLogoPetChatComponent:addListener()
	return
end

function TopLogoPetChatComponent:showPetChatInfo(id)
	local chance = PetChatData[id].DialogueRate
	local duration = PetChatData[id].Duration

	if chance > math.random() then
		self.m_pendingPetChatId = id

		self:notifyActiveStateChanged(true)

		if not self.topLogoItem:isTopLogoPrefabReady() then
			return false, duration
		end

		self.m_pendingPetChatId = nil

		if self:checkContainerLoaded() then
			self:m_showPetChatInfo(false, id, duration)

			return true, duration
		end

		self.m_cbCachePetChatInfo = {
			id = id,
			duration = duration
		}

		if not self.m_loadedPetChatCallBack then
			function self.m_loadedPetChatCallBack(isSuccess)
				local cacheInfo = self.m_cbCachePetChatInfo

				self.m_cbCachePetChatInfo = nil

				if isSuccess and cacheInfo then
					self:m_showPetChatInfo(true, cacheInfo.id, cacheInfo.duration)
				end

				self:notifyActiveStateChanged(self:shouldBeActive())
			end
		end

		self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedPetChatCallBack, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)

		return false, duration
	end

	if self:checkContainerLoaded() then
		self:hidePetChatInfo()
	end

	return false, duration
end

function TopLogoPetChatComponent:m_showPetChatInfo(isAsync, id, duration)
	self:refreshPetChatInfo(true, PetChatData[id])

	if pg.global.ui.petChat ~= nil then
		pg.global.ui.petChat:refreshContent(PetChatData[id])
	end

	if self.petChatTimer then
		self:killTimer(self.petChatTimer)
	end

	self.petChatTimer = self:startTimer(function()
		self:hidePetChatInfo()

		if pg.global.ui.petChat ~= nil then
			pg.global.ui.petChat:closeText()
		end
	end, duration)
end

function TopLogoPetChatComponent:hidePetChatInfo()
	self.m_pendingPetChatId = nil
	self.m_cbCachePetChatInfo = nil

	self:refreshPetChatInfo(false)

	if pg.global.ui.petChat ~= nil then
		pg.global.ui.petChat:closeText()
	end

	self:notifyActiveStateChanged(self:shouldBeActive())
end

function TopLogoPetChatComponent:refreshTopLogoInfo(callFromUpdate)
	if self.m_pendingPetChatId then
		local id = self.m_pendingPetChatId

		self.m_pendingPetChatId = nil

		self:showPetChatInfo(id)
	end
end

function TopLogoPetChatComponent:checkTopLogoCompUpdate()
	return false
end

function TopLogoPetChatComponent:setPetChatVisible(visible)
	if self:checkContainerLoaded() then
		LuaUIUtils.setUIViewVisible(self.petChatUComponent, visible)
	end
end

function TopLogoPetChatComponent:refreshPetChatInfo(visible, content)
	if visible and content ~= nil then
		self.petChatEnabled = true

		self:setPetChatVisible(true)
		ClientTextUtils.setText(self.contentUText, content.DialogueText)
		UIUtils.PlayAnimation(self.petChatAnimation, "VX_PetChatTop_In_New", function()
			self.petChatAnimation:Play("VX_PetChatTop_Loop_New")
			ClientTextUtils.setText(self.contentUText, content.DialogueText)
		end)
	else
		if not self.petChatEnabled then
			return
		end

		self.petChatEnabled = false

		UIUtils.PlayAnimation(self.petChatAnimation, "VX_PetChatTop_Out_New", function()
			self:setPetChatVisible(false)
			ClientTextUtils.setText(self.contentUText, "")
		end)
	end
end

function TopLogoPetChatComponent:getInitMaxDistance()
	return SysConfigData.NPC_TOPLOGO_DISTANCE
end

return TopLogoPetChatComponent
