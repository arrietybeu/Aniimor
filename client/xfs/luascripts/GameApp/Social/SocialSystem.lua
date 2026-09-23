-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Social\\SocialSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local MessageName = require("Const.MessageName")
local InteractGestureComponent = require("GameApp.Social.Component.InteractGestureComponent")
local ItemUseComponent = require("GameApp.Social.Component.ItemUseComponent")
local FluteComponent = require("GameApp.Social.Component.FluteComponent")
local PetSocialBehaviorComponent = require("GameApp.Social.Component.PetSocialBehaviorComponent")
local TimerManager = require("Core.Timer.TimerManager")
local SceneAreaData = require("Common.Data.Scene.501.scene_area_data")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local UIToFuncMenuData = require("Data.ui_to_func_menu_data")
local SocialConst = require("Common.Const.SocialConst")
local SocialSystem = Class.LightClass("SocialSystem", SystemBase)

function SocialSystem:onCtor()
	SystemBase.onCtor(self)

	self.interactGestureComponent = InteractGestureComponent.new()
	self.itemUseComponent = ItemUseComponent.new()
	self.fluteComponent = FluteComponent.new()
	self.petSocialBehaviorComponent = PetSocialBehaviorComponent.new()

	self.petSocialBehaviorComponent:resetData()

	self._inPetInteractMode = false
	self._inCafeGathering = false
	self._multiPetFollowPresentationTimerId = nil
	self._multiPetFollowPresentationCamera = nil

	self:registerMultiPetFollowPresentationTick()
end

function SocialSystem:registerMultiPetFollowPresentationTick()
	if self._multiPetFollowPresentationTimerId then
		return
	end

	local camera = pg.game and pg.game.camera

	if not camera then
		return
	end

	self._multiPetFollowPresentationCamera = camera
	self._multiPetFollowPresentationTimerId = camera:addLateUpdateTimer(function()
		local component = self.interactGestureComponent

		if component then
			component:tickMultiPetFollowPresentation()
		end
	end)
end

function SocialSystem:unregisterMultiPetFollowPresentationTick()
	local timerId = self._multiPetFollowPresentationTimerId
	local camera = self._multiPetFollowPresentationCamera

	if timerId and camera then
		camera:removeLateUpdateTimer(timerId)
	end

	self._multiPetFollowPresentationTimerId = nil
	self._multiPetFollowPresentationCamera = nil
end

function SocialSystem:onPlayerInit(player)
	SystemBase.onPlayerInit(self)
	self:registerMultiPetFollowPresentationTick()
	self.interactGestureComponent:resetData()

	if self.petSocialBehaviorComponent ~= nil then
		self.petSocialBehaviorComponent:resetData()
	end

	self._inPetInteractMode = false
	self._inCafeGathering = false
	self._initCafeCheckDone = false

	if self._initCafeCheckTimer ~= nil then
		TimerManager.removeTimer(self._initCafeCheckTimer)

		self._initCafeCheckTimer = nil
	end

	self._initCafeCheckTimer = TimerManager.addTimer(SocialConst.CAFE_INIT_AREA_CHECK_DELAY_SEC, function()
		self._initCafeCheckTimer = nil

		self:_checkInitialCafeArea()
	end)
end

function SocialSystem:onSceneLoaded(sceneId, sceneName)
	self.fluteComponent:resetAllState()
end

function SocialSystem:onSceneUnloaded(sceneId, sceneName)
	self.fluteComponent:resetAllState()
end

function SocialSystem:onDestroy()
	self:unregisterMultiPetFollowPresentationTick()
	SystemBase.onDestroy(self)

	if self._initCafeCheckTimer ~= nil then
		TimerManager.removeTimer(self._initCafeCheckTimer)

		self._initCafeCheckTimer = nil
	end

	if self.interactGestureComponent then
		self.interactGestureComponent:destroy()
	end

	if self.itemUseComponent then
		self.itemUseComponent:destroy()
	end

	if self.petSocialBehaviorComponent ~= nil then
		self.petSocialBehaviorComponent:destroy()
	end
end

function SocialSystem:onPetInteractAction(sourcePlayerEntId, behaviorType, memberPetIds)
	if self.petSocialBehaviorComponent ~= nil then
		self.petSocialBehaviorComponent:onPetInteractAction(sourcePlayerEntId, behaviorType, memberPetIds)
	end
end

function SocialSystem:onCafePetCoinDrop(coinNum)
	if self.petSocialBehaviorComponent ~= nil then
		self.petSocialBehaviorComponent:onCafePetCoinDrop(coinNum)
	end
end

function SocialSystem:onCafePetIvUpNotice(noticeId, noticeArgs)
	if self.petSocialBehaviorComponent ~= nil then
		self.petSocialBehaviorComponent:onCafePetIvUpNotice(noticeId, noticeArgs)
	end
end

function SocialSystem:tryShowCafePetNotice(noticeId, noticeArgs)
	if self.petSocialBehaviorComponent == nil then
		return false
	end

	return self.petSocialBehaviorComponent:tryShowCafePetNotice(noticeId, noticeArgs)
end

function SocialSystem:onNotifyCafeGatheringState(state)
	local wasGathering = self._inCafeGathering

	self._inCafeGathering = state == true

	if self._inCafeGathering and not wasGathering then
		self:_onEnterCafeGathering()
	elseif not self._inCafeGathering then
		self:_onLeaveCafeGathering()
	end
end

function SocialSystem:_onEnterCafeGathering()
	return
end

function SocialSystem:_onLeaveCafeGathering()
	if self.petSocialBehaviorComponent ~= nil then
		self.petSocialBehaviorComponent:abortAllPerforms()
	end
end

function SocialSystem:onPetChangeRefresh(info)
	if info.ent and info.ent.uid == pg.me.uid and self.petSocialBehaviorComponent:isMyPetInteracting() then
		self.petSocialBehaviorComponent:abortAllPerforms()
	end
end

function SocialSystem:isInCafeGathering()
	return self._inCafeGathering == true
end

function SocialSystem:isPointInPolygon(px, pz, areaPoints)
	if type(areaPoints) ~= "table" then
		return false
	end

	local n = #areaPoints

	if n < 6 or n % 2 ~= 0 then
		return false
	end

	local count = n / 2

	if count < 3 then
		return false
	end

	local inside = false
	local j = count

	for i = 1, count do
		local xi = areaPoints[(i - 1) * 2 + 1]
		local zi = areaPoints[(i - 1) * 2 + 2]
		local xj = areaPoints[(j - 1) * 2 + 1]
		local zj = areaPoints[(j - 1) * 2 + 2]

		if pz < zi ~= (pz < zj) then
			local denom = zj - zi

			if denom ~= 0 then
				local crossX = (xj - xi) * (pz - zi) / denom + xi

				if px < crossX then
					inside = not inside
				end
			end
		end

		j = i
	end

	return inside
end

function SocialSystem:_checkInitialCafeArea()
	if self._initCafeCheckDone then
		return
	end

	self._initCafeCheckDone = true

	if pg.me == nil then
		return
	end

	if self._inCafeGathering then
		return
	end

	local space = pg.me.space

	if space == nil or space.sceneId ~= SocialConst.ARK_SCENE_ID then
		return
	end

	local pos = pg.me:getPosition()

	if pos == nil then
		return
	end

	local areaCfg = SceneAreaData[SocialConst.CAFE_AREA_ID]

	if areaCfg == nil or areaCfg.areaPoints == nil then
		return
	end

	if not self:isPointInPolygon(pos.x, pos.z, areaCfg.areaPoints) then
		return
	end

	pg.me:setInSocialArea(true, SocialConst.CAFE_AREA_ID)
end

function SocialSystem:cafeInvitePartner(targetUid)
	if pg.me == nil then
		return
	end

	if targetUid == nil then
		return
	end
end

function SocialSystem:cafeRespondPartnerInvite(targetUid, accept)
	if pg.me == nil then
		return
	end

	if targetUid == nil then
		return
	end
end

function SocialSystem:setInPetInteractMode(flag)
	self._inPetInteractMode = flag == true
end

function SocialSystem:isInPetInteractMode()
	return self._inPetInteractMode == true
end

function SocialSystem:acceptFluteNotify(uid, reqId)
	self.fluteComponent:onAcceptFluteNotify(uid, reqId)
end

function SocialSystem:onAcceptFluteNotifyReply(pos)
	self.fluteComponent:onAcceptFluteNotifyReply(pos)
end

function SocialSystem:receiveFluteNotify(uid, reqId, pos, fluteGender, playerGender)
	self.fluteComponent:onReceiveFluteNotify(uid, reqId, pos, fluteGender, playerGender)
end

function SocialSystem:replyFluteNotify(portalDistance)
	self.fluteComponent:onReplyFluteNotify(portalDistance)
end

function SocialSystem:replyFluteNotifyCallBack()
	self.fluteComponent:onReplyFluteNotifyCallBack()
end

function SocialSystem:playFlute(fluteType)
	self.fluteComponent:onPlayFlute(fluteType)
end

function SocialSystem:playFluteCallback(reqId)
	self.fluteComponent:onPlayFluteSuccess(reqId)
end

function SocialSystem:receiveFluteNotifyReply(uid, pos)
	self.fluteComponent:onReceiveFluteNotifyReply(uid, pos)
end

function SocialSystem:onFluteNotifyClosed()
	self.fluteComponent:onFluteNotifyClosed()
end

function SocialSystem:onDismountSelf()
	self.fluteComponent:onDismountSelf()
end

function SocialSystem:onStopFluteMatch()
	self.fluteComponent:onStopFluteMatchCallback()
end

function SocialSystem:useInviteItem(invIdx, genId)
	if self.itemUseComponent then
		self.itemUseComponent:useInviteItem(invIdx, genId)
	end
end

function SocialSystem:onUseInviteItemResult(flag, reqRetInfo, matchUids)
	if self.itemUseComponent then
		self.itemUseComponent:onUseInviteItemResult(flag, reqRetInfo, matchUids)
	end
end

function SocialSystem:onOtherRequestEnterSpace(reqId, playerInfo)
	if self.itemUseComponent then
		self.itemUseComponent:onOtherRequestEnterSpace(reqId, playerInfo)
	end
end

function SocialSystem:onInviteReceive(inviteInfo)
	if self.itemUseComponent then
		self.itemUseComponent:onInviteReceive(inviteInfo)
	end
end

function SocialSystem:acceptInvitation()
	if self.itemUseComponent then
		self.itemUseComponent:acceptInvitation()
	end
end

function SocialSystem:ignoreInvitation()
	if self.itemUseComponent then
		self.itemUseComponent:ignoreInvitation()
	end
end

function SocialSystem:onAcceptInvitationResult(flag, pos3)
	if self.itemUseComponent then
		self.itemUseComponent:onAcceptInvitationResult(flag, pos3)
	end
end

function SocialSystem:getFacePos()
	if self.itemUseComponent then
		local res = self.itemUseComponent.facePos

		self.itemUseComponent.facePos = nil

		return res
	end
end

function SocialSystem:checkAndStopHornAnimation()
	if self.itemUseComponent then
		self.itemUseComponent:checkAndStopHornAnimation()
	end
end

function SocialSystem:testHorn(actorId, enable)
	if self.itemUseComponent then
		self.itemUseComponent:testHorn(actorId, enable)
	end
end

function SocialSystem:onAiHelperLitShow(aiId)
	if self.itemUseComponent then
		self.itemUseComponent:onAiHelperLitShow(aiId)
	end

	if self.fluteComponent then
		self.fluteComponent:onAiHelperLitShow(aiId)
	end
end

function SocialSystem:getMessageBindMap()
	return {
		[MessageName.UI_AI_HELPER_LIT_SHOW] = "onAiHelperLitShow",
		[MessageName.DISMOUNT_SELF] = "onDismountSelf",
		[MessageName.STOP_FLUTE_MATCH] = "onStopFluteMatch",
		[MessageName.UI_ON_OPEN] = "onUIOpenOrShow",
		[MessageName.UI_ON_CLOSE] = "onUICloseOrHide",
		[MessageName.UI_ON_SHOW] = "onUIOpenOrShow",
		[MessageName.UI_ON_HIDE] = "onUICloseOrHide",
		[MessageName.PET_CHANGE_REFRESH] = "onPetChangeRefresh"
	}
end

function SocialSystem:addGhost(ent)
	if self.interactGestureComponent then
		self.interactGestureComponent:addGhost(ent)
	end
end

function SocialSystem:removeGhost(ent)
	if self.interactGestureComponent then
		self.interactGestureComponent:removeGhost(ent)
	end
end

function SocialSystem:onTick()
	if self.interactGestureComponent then
		self.interactGestureComponent:tick()
	end
end

function SocialSystem:beforeAnimation()
	local component = self.interactGestureComponent

	if component then
		component:tickMultiPetFollowTransform()
	end
end

function SocialSystem:muteInteractGestureFunc(mute)
	if self.interactGestureComponent then
		self.interactGestureComponent:muteInteractGestureFunc(mute)
	end
end

function SocialSystem:isCommonSystemUI(uid)
	if uid == nil or uid == UIConst.UI_ID_FUNC_MENU then
		return false
	end

	local cfg = UIConst.UI_CONFIGS[uid] or {}

	if cfg.ignore then
		return false
	end

	local uiType = cfg.uiType or UIConst.PANEL_LAYER

	return uiType == UIConst.PANEL_LAYER or uiType == UIConst.POPUP_LAYER
end

function SocialSystem:setActionState(actionState)
	if pg.me == nil then
		return
	end

	if self.uiActionState == actionState then
		return
	end

	self.uiActionState = actionState

	pg.me:setActionState(actionState)
end

function SocialSystem:onUIOpenOrShow(uid)
	if uid == UIConst.UI_ID_FUNC_MENU then
		self:setActionState(Const.PlayerActionState.FuncMenu)

		return
	end

	if UIToFuncMenuData[uid] then
		self:setActionState(Const.PlayerActionState.CommonPanel)
	end
end

function SocialSystem:onUICloseOrHide(uid)
	if UIToFuncMenuData[uid] then
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_FUNC_MENU) then
			self:setActionState(Const.PlayerActionState.FuncMenu)
		else
			self:setActionState(Const.PlayerActionState.None)
		end

		return
	end

	if uid == UIConst.UI_ID_FUNC_MENU then
		self:setActionState(Const.PlayerActionState.None)
	end
end

function SocialSystem:getCurUIActionState()
	return self.uiActionState
end

return SocialSystem
