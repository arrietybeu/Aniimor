-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientVisibleComponent.lua

local Class = require("Core.Framework.Class")
local Bitset = require("Common.Bitset")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local EventConst = require("Const.EventConst")
local ClientConst = require("Const.ClientConst")
local GlobalData = require("Core.Client.GlobalData")
local Const = require("Common.Const.Const")
local ClientUtils = require("Utils.ClientUtils")
local AiConst = require("Common.Const.AiConst")
local Utils = require("Common.Utils.Utils")
local ClientVisibleComponent = Class.Component("ClientVisibleComponent")

function ClientVisibleComponent:ctor()
	self.visible = true
	self.active = true
	self.enableCollide = true
	self.enableTrigger = nil
	self.modelActiveKeys = {}
	self.modelVisibleKeys = {}
	self.modelCollideKeys = {}
	self.modelTriggerKeys = {}
end

function ClientVisibleComponent:EVENT_PostInitialized()
	self:refreshBaseVisible()
	self:startHideShowTimeCheck()

	if self.refreshModelVisibleMark then
		self:refreshModelVisible()
	end

	if self.refreshColliderMark then
		self:refreshCollider()
	end
end

function ClientVisibleComponent:on_isHideNpc_changed(ov, nv)
	self:refreshServerVisible()
end

function ClientVisibleComponent:on_authorAway_changed(ov, nv)
	self:refreshAuthorAwayVisible()
end

function ClientVisibleComponent:refreshAuthorAwayVisible()
	local cfg = self.getConfigData and self:getConfigData()
	local invisible = self.authorAway and cfg and cfg.authorAwayInvisible

	self:setActive(ClientConst.MODEL_VISIBLE_KEY.AUTHOR_AWAY, not invisible)
end

function ClientVisibleComponent:setVisible(key, visible, enableCollide, enableTrigger)
	local changed = false

	if visible or visible == nil then
		if Bitset.clrBit(self.modelVisibleKeys, key) then
			changed = true
		end
	elseif Bitset.setBit(self.modelVisibleKeys, key) then
		changed = true
	end

	if enableCollide or enableCollide == nil then
		if Bitset.clrBit(self.modelCollideKeys, key) then
			changed = true
		end
	elseif Bitset.setBit(self.modelCollideKeys, key) then
		changed = true
	end

	if enableTrigger then
		if Bitset.setBit(self.modelTriggerKeys, key) then
			changed = true
		end
	elseif Bitset.clrBit(self.modelTriggerKeys, key) then
		changed = true
	end

	if changed then
		self:refreshModelVisible()
		self:refreshCollider()
	end
end

function ClientVisibleComponent:setActive(key, visible)
	local changed = false

	if visible or visible == nil then
		changed = Bitset.clrBit(self.modelActiveKeys, key)
	else
		changed = Bitset.setBit(self.modelActiveKeys, key)
	end

	if changed then
		self:refreshActive()
	end
end

function ClientVisibleComponent:setModelVisible(key, visible)
	local changed = false

	if visible or visible == nil then
		changed = Bitset.clrBit(self.modelVisibleKeys, key)
	else
		changed = Bitset.setBit(self.modelVisibleKeys, key)
	end

	if changed then
		self:refreshModelVisible()
	end
end

function ClientVisibleComponent:setCollideEnable(key, enableCollide)
	local changed = false

	if enableCollide or enableCollide == nil then
		changed = Bitset.clrBit(self.modelCollideKeys, key)
	else
		changed = Bitset.setBit(self.modelCollideKeys, key)
	end

	if changed then
		self:refreshCollider()
	end
end

function ClientVisibleComponent:setTriggerEnable(key, enableTrigger)
	local changed = false

	if enableTrigger then
		changed = Bitset.setBit(self.modelTriggerKeys, key)
	else
		changed = Bitset.clrBit(self.modelTriggerKeys, key)
	end

	if changed then
		self:refreshCollider()
	end
end

function ClientVisibleComponent:innerQueryModelVisible()
	if Bitset.any(self.modelVisibleKeys) then
		return false
	end

	return true
end

function ClientVisibleComponent:innerQueryModelActive()
	if Bitset.any(self.modelActiveKeys) then
		return false
	end

	return true
end

function ClientVisibleComponent:innerQueryColliderEnable()
	if Bitset.any(self.modelCollideKeys) then
		return false
	end

	return true
end

function ClientVisibleComponent:innerQueryTriggerEnable()
	if Bitset.any(self.modelTriggerKeys) then
		return false
	end

	return true
end

function ClientVisibleComponent:checkNeedPauseAI()
	if Utils.isBotPlayer(self) and pg.space and (pg.space:isNpcDuel() or pg.space:isBossRushEnv()) then
		return false
	end

	return true
end

function ClientVisibleComponent:refreshActive()
	if self.eModel == nil then
		return
	end

	local active = self:innerQueryModelActive()
	local activeChanged = self.active ~= active

	if activeChanged then
		self.active = active
	end

	if self.refreshTopLogoAliveGate then
		self:refreshTopLogoAliveGate()
	end

	if self.refreshTopLogoVisibleGate then
		self:refreshTopLogoVisibleGate()
	end

	if activeChanged then
		if self.active then
			self.eModel:SetActive(active)

			if self.onActiveChange then
				self:onActiveChange(active)
			end

			if self.resumeBt and self:checkNeedPauseAI() then
				self:resumeBt(AiConst.PauseBtReason.ClientModelActive)
			end

			self:refreshCollider()
			self:refreshModelVisible()
		else
			self:refreshCollider()
			self:refreshModelVisible()
			self.eModel:SetActive(active)

			if self.onActiveChange then
				self:onActiveChange(active)
			end

			if self.pauseBt and self:checkNeedPauseAI() then
				self:pauseBt(AiConst.PauseBtReason.ClientModelActive)
			end
		end
	end
end

function ClientVisibleComponent:refreshModelVisible()
	if self.eModel == nil then
		self.refreshModelVisibleMark = true

		return
	end

	self.refreshModelVisibleMark = nil

	local visible = self.active and self:innerQueryModelVisible()
	local visibleChanged = self.visible ~= visible

	if visibleChanged then
		self.visible = visible
	end

	if self.refreshTopLogoVisibleGate then
		self:refreshTopLogoVisibleGate()
	end

	if visibleChanged then
		self.eModel:SetModelVisible(visible)

		if self.onModelVisibleChange then
			self:onModelVisibleChange(visible)
		end
	end
end

function ClientVisibleComponent:refreshCollider(force)
	if self.eModel == nil then
		self.refreshColliderMark = true

		return
	end

	self.refreshColliderMark = nil

	local enableCollide = self:innerQueryColliderEnable()
	local enableTrigger = self:innerQueryTriggerEnable()

	if force or self.enableCollide ~= enableCollide or self.enableTrigger ~= enableTrigger then
		self.enableCollide = enableCollide
		self.enableTrigger = enableTrigger

		self.eModel:SetColliderEnable(enableCollide, enableTrigger)

		if self.setIsKinematic then
			self:setIsKinematic(not self.enableCollide, ClientConst.IsKinematicKey.Visible)
		end
	end
end

function ClientVisibleComponent:setVisibleInLevelMode(visible)
	self:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.LEVEL_BLUEPRINT, visible)
	self:setCollideEnable(ClientConst.MODEL_VISIBLE_KEY.LEVEL_BLUEPRINT, visible)
end

function ClientVisibleComponent:setChildVisible(childName, visible)
	if not self.eModel then
		return
	end

	local child = self.eModel.transform:FindRecursive(childName)

	if IsNil(child) then
		return
	end

	child.gameObject:SetActiveEx(visible)
end

function ClientVisibleComponent:refreshBaseVisible()
	self:refreshServerVisible()
	self:refreshEntityBaseVisible()
	self:refreshGhostEyeVisible()
	self:refreshClientSetVisible()
	self:refreshAuthorAwayVisible()
	self:refreshHideShowTimeVisible()
end

function ClientVisibleComponent:onEnterSpace()
	self:refreshClientSetVisible()
end

function ClientVisibleComponent:EVENT_RefreshVisible()
	self:refreshBaseVisible()
end

function ClientVisibleComponent:refreshEntityBaseVisible()
	if self.queryModelVisible then
		local active, visible, enableCollide, enableTrigger = self:queryModelVisible()

		self:setActive(ClientConst.MODEL_VISIBLE_KEY.BASE_VISIBLE, active)
		self:setVisible(ClientConst.MODEL_VISIBLE_KEY.BASE_VISIBLE, visible, enableCollide, enableTrigger)
	end
end

function ClientVisibleComponent:refreshServerVisible()
	if ClientUtils.checkIsHideEntity(self) then
		self:setActive(ClientConst.MODEL_VISIBLE_KEY.SEVER_VISIBLE, false)
	else
		self:setActive(ClientConst.MODEL_VISIBLE_KEY.SEVER_VISIBLE, true)
	end
end

function ClientVisibleComponent:getGhostEyeVisible()
	if self.isGhost then
		local player = GlobalData.Player

		if player.ghostEyeState ~= Const.GHOST_EYE_STATE_OFF then
			return false
		end
	end

	return true
end

function ClientVisibleComponent:refreshGhostEyeVisible()
	if not self.isGhost then
		return
	end

	local ghostEyeVisible = self:getGhostEyeVisible()

	self:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.GHOST_EYE, ghostEyeVisible)
	self:setCollideEnable(ClientConst.MODEL_VISIBLE_KEY.GHOST_EYE, ghostEyeVisible)
end

function ClientVisibleComponent:getClientSetVisible()
	if self.space and self.staticId and self.staticId ~= 0 then
		return self.space:getClientEntVisible(self.staticId)
	end

	return true, true
end

function ClientVisibleComponent:refreshClientSetVisible()
	local visible, enableCollide = self:getClientSetVisible()

	self:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.CLIENT_SET, visible)
	self:setCollideEnable(ClientConst.MODEL_VISIBLE_KEY.CLIENT_SET, enableCollide)
end

function ClientVisibleComponent:refreshHideShowTimeVisible()
	self:setActive(ClientConst.MODEL_VISIBLE_KEY.NPC_HIDE_SHOW_TIME, ClientUtils.checkNpcVisibleByHideShowTime(self.staticId))
end

function ClientVisibleComponent:startHideShowTimeCheck()
	if self.hideShowTimeTimer then
		return
	end

	if not ClientUtils.hasNpcHideShowTimeConfig(self.staticId) then
		return
	end

	self.hideShowTimeTimer = self:addRepeatTimer(ClientConst.NPC_HIDE_SHOW_TIME_CHECK_INTERVAL, function()
		self:refreshHideShowTimeVisible()
	end)
end

function ClientVisibleComponent:dumpActiveKeys()
	return Bitset.dump(self.modelActiveKeys, ClientConst.MODEL_VISIBLE_KEY)
end

function ClientVisibleComponent:dumpVisibleKeys()
	return Bitset.dump(self.modelVisibleKeys, ClientConst.MODEL_VISIBLE_KEY)
end

function ClientVisibleComponent:dumpCollideKeys()
	return Bitset.dump(self.modelCollideKeys, ClientConst.MODEL_VISIBLE_KEY)
end

function ClientVisibleComponent:dumpTriggerKeys()
	return Bitset.dump(self.modelTriggerKeys, ClientConst.MODEL_VISIBLE_KEY)
end

function ClientVisibleComponent:testVisible()
	self.eModel:SetModelVisible(false)

	self.eModel.modelView.modelInfo.physiqueModelInfo.modelPathID = "$P_Item_Temple_TempleEntrance_Pass_Idle.prefab"

	self.eModel.modelView:RefreshModels()
end

return ClientVisibleComponent
