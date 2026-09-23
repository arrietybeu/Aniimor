-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\NpcInteract\\SandboxInteract.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local InteractionConst = require("Common.Const.InteractionConst")
local InteractData = require("Data.interact_data")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local logger = LoggerManager.getLogger("ClientNpcInteractComponent")
local SandboxInteract = {}

function SandboxInteract:onEnter()
	if ToBool(self.sandboxCustomInteractionData) then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER_MULTI_INTERACT, self.sandboxCustomInteractionData)
	end
end

function SandboxInteract:onLeave()
	if ToBool(self.sandboxCustomInteractionData) then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER_MULTI_INTERACT, self.sandboxCustomInteractionData)
	end
end

function SandboxInteract:contributeDist()
	local interactiveDist = 0

	if self.customInteractIds then
		for _, interactId in pairs(self.customInteractIds) do
			local interactData = InteractData[interactId] or {}

			interactiveDist = math.max(interactiveDist, interactData.interactiveDist or 0, interactData.interactiveIconDist or 0)
		end
	end

	return interactiveDist
end

function SandboxInteract:addCustomInteraction(interactId, interactConfigId, handlePetEthnicGroup, callback, sandBoxId, doOnce, overrideNpcTemplateId)
	if doOnce and pg.me.sandboxData[sandBoxId] and pg.me.sandboxData[sandBoxId].onceInteractList[interactId] ~= nil then
		return
	end

	if not self.customInteractIds then
		self.customInteractIds = {}
	end

	self.customInteractIds[interactId] = interactConfigId

	for idx = #self.sandboxCustomInteractionData, 1, -1 do
		if self.sandboxCustomInteractionData[idx].customInteractId == interactId then
			table.remove(self.sandboxCustomInteractionData, idx)
		end
	end

	if overrideNpcTemplateId <= 0 then
		overrideNpcTemplateId = nil
	end

	table.insert(self.sandboxCustomInteractionData, {
		checkEntity = true,
		globalId = self:getGlobalId(),
		overrideType = InteractionConst.INTERACTION_TYPE_SANDBOX_ENT_FUNC,
		actionPrototypeId = interactConfigId,
		customInteractId = interactId,
		interactFunc = function()
			pg.me:serverMsg("RPC_CS_InteractNpcSandboxCustomEvent", interactId, sandBoxId, doOnce)
			callback(self:getGlobalId())

			if doOnce then
				SandboxInteract.removeCustomInteraction(self, interactId)
			end
		end,
		handlePetEthnicGroup = handlePetEthnicGroup,
		overrideNpcTemplateId = overrideNpcTemplateId
	})
	self:refreshInteractTrigger()
	facade:sendMsgToSystem(MessageName.REFRESH_INTERACT_SIGN_DYNAMIC, {
		ent = self
	})
end

function SandboxInteract:removeCustomInteraction(interactId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("@hyj removeCustomInteractionFKey", interactId, self.staticId)
	end

	if self.customInteractIds then
		self.customInteractIds[interactId] = nil
	end

	facade:sendMsgToSystem(MessageName.REFRESH_INTERACT_SIGN_DYNAMIC, {
		ent = self
	})

	local playerInTrigger = self.playerInTrigger

	if playerInTrigger then
		self:onLeaveInteractTrigger()
	end

	for idx = #self.sandboxCustomInteractionData, 1, -1 do
		if self.sandboxCustomInteractionData[idx].customInteractId == interactId then
			table.remove(self.sandboxCustomInteractionData, idx)
		end
	end

	if playerInTrigger then
		self:onEnterInteractTrigger()
	end
end

function SandboxInteract:enableInteractCallFriend(interactId, enable, distance, callback, sandBoxId, doOnce)
	if enable and doOnce and pg.me.sandboxData[sandBoxId] and pg.me.sandboxData[sandBoxId].onceInteractList[interactId] ~= nil then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("@hyj addCustomInteractionCallFriend", interactId, self.staticId)
	end

	if enable then
		self.canInteractCallFriend = {
			interactId = interactId,
			distance = distance,
			callback = callback,
			sandBoxId = sandBoxId,
			doOnce = doOnce
		}
	else
		self.canInteractCallFriend = nil
	end

	self:serverMsg("RPC_CS_EnableInteractCallFriend", enable, distance or 0)
end

function SandboxInteract:enableListenBallHitEvent(interactId, enable, callback, sandBoxId, doOnce)
	if enable and doOnce and pg.me.sandboxData[sandBoxId] and pg.me.sandboxData[sandBoxId].onceInteractList[interactId] ~= nil then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("@hyj addCustomInteractionBallHit", interactId, self.staticId)
	end

	if enable then
		self.listenBallHitInteractEvent = {
			interactId = interactId,
			callback = callback,
			sandBoxId = sandBoxId,
			doOnce = doOnce
		}
	else
		self.listenBallHitInteractEvent = nil
	end
end

function SandboxInteract:enableShowVlogTopLogo(interactId, enable, callback, sandBoxId, doOnce, distanceShow, distanceInter, showStyle)
	if enable and doOnce and pg.me.sandboxData[sandBoxId] and pg.me.sandboxData[sandBoxId].onceInteractList[interactId] ~= nil then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("@hyj addCustomInteractionShowVlogTopLogo", interactId, self.staticId, self.actorId)
	end

	local function callbackFunc()
		pg.me:serverMsg("RPC_CS_InteractNpcSandboxCustomEvent", interactId, sandBoxId, doOnce)
		callback()
		SandboxInteract.enableShowVlogTopLogo(self, interactId, false)
	end

	self.topLogoData = self.topLogoData or {}
	self.topLogoData.vlogInfo = {
		enable = enable,
		callBack = callbackFunc,
		distanceShow = distanceShow,
		distanceInter = distanceInter,
		showStyle = showStyle
	}

	local vlogComp

	if enable then
		vlogComp = self.ensureToplogoComponent and self:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.VLOG)
	else
		vlogComp = self.peekToplogoComponent and self:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.VLOG)
	end

	if vlogComp then
		if enable then
			vlogComp:setTopLogoVlogEnable(true, callbackFunc, distanceShow, distanceInter, showStyle)
		else
			vlogComp:setTopLogoVlogEnable(false)
		end
	end
end

return SandboxInteract
