-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BadgeObtain\\BadgeObtainCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("BadgeObtainCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local BadgeUtils = require("Guis.Utils.BadgeUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PlayerBadgeData = require("Data.player_badge_data")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local BadgeUnlockShowComponent = require("Guis.Panels.BadgeUnlockShow.BadgeUnlockShowComponent")
local BadgeObtainCtrl = Class.LightClass("BadgeObtainCtrl", UICtrl)
local SWITCH_ANIM = "VX_Ani_Node_Personal_Badge_FristAcquire_Transition"
local SWITCH_OUT_ANIM = "VX_Ani_Node_Personal_Badge_FristAcquire_TransitionOut"
local THANKS_ANIM_LAYER = PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY

BadgeObtainCtrl.messages = {}

function BadgeObtainCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function BadgeObtainCtrl:addListener()
	function self.view.backGroundCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.abilityUList.luaRenderItem(button, index, data)
		BadgeUtils.renderEntry(button, index, data, true, BadgeUtils.TitleDisplayType.replaceColon)
		pg.game.audio:playEvent("SFX_UI_BadgeSystem_PrivilegeShow_pang")
	end

	function self.view.btnLookUButton.luaClick()
		self:gotoBadgeObtainDetail()
		self.view.rootAnimation:Play(SWITCH_ANIM)
		pg.game.audio:playEvent("SFX_UI_BadgeSystem_BadgeBoxCollect_01")
	end

	function self.view.conditionListUList.luaRenderItem(button, index, data)
		self:renderTextCondition(button, index, data)
		pg.game.audio:playEvent("SFX_UI_BadgeSystem_ItemComplete")
	end
end

function BadgeObtainCtrl:onDestroy()
	UICtrl.onDestroy(self)
	self:_restore()

	self.nextBadgeIds = nil
end

function BadgeObtainCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.badgeId = info.badgeId
	self.hasPlayedBadgeObtainEffect = self:canPlayBadgeObtainEffect()

	if self.hasPlayedBadgeObtainEffect and pg.me:isControllingPet() then
		pg.me:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.Default, nil, function()
			self:startTimer(function()
				self:openItemObtainFrontCamera()
			end, 0.6)
		end)
	elseif self.hasPlayedBadgeObtainEffect then
		self:openItemObtainFrontCamera()
	end

	self:refreshView()

	local cfgData = PlayerBadgeData[self.badgeId]

	self.showComponent = BadgeUnlockShowComponent.new(self, self.view.badgeFristAcquireUWidget, {
		unlockData = {
			badgeGroupId = cfgData.group
		}
	})

	self.showComponent:setClickCallback(function()
		self.view.rootAnimation:Play(SWITCH_OUT_ANIM)
	end)
end

function BadgeObtainCtrl:setShowComponentInfo(info)
	self.showComponent:setInfo(info)
end

function BadgeObtainCtrl:onShow()
	return
end

function BadgeObtainCtrl:onHide()
	return
end

function BadgeObtainCtrl:addNextBadgeId(badgeId)
	self.nextBadgeIds = self.nextBadgeIds or {}

	table.insert(self.nextBadgeIds, badgeId)
end

function BadgeObtainCtrl:refreshView()
	local cfgData = PlayerBadgeData[self.badgeId]

	self.view.rootView:TryChangePage("GetStatus", 1)
	ClientTextUtils.setText(self.view.textNameUSDFText, pg.getLocalizationText(cfgData.name))
	ClientTextUtils.setText(self.view.abilityTtileUSDFText, pg.getGameString("TITLE_PRIVILEGE"))
	ClientTextUtils.setText(self.view.btnTxtNameUText, pg.getGameString("GO_TO_PLAYER_BADGE_UI"))

	self.view.badgeIconUImage.url = cfgData.icon
	self.view.badgeIcon1UImage.url = cfgData.icon

	local quality = BadgeUtils.getBadgeQualityByBadgeId(self.badgeId)

	if quality == BadgeUtils.RainBowQuality then
		self.view.badgeIconUImage:SetMaterial(BadgeUtils.RainBowMatPath)
		self.view.fxHongUWidget:SetActive(true)
	else
		self.view.badgeIconUImage.material = ""

		self.view.fxHongUWidget:SetActive(false)
	end

	local entryData = BadgeUtils.getEntryData(cfgData)

	self.view.abilityUList:SetList(entryData)

	local conditionData = BadgeUtils.getConditionInfoOnlyNormal(cfgData)

	self.view.conditionListUList:SetList(conditionData)
end

function BadgeObtainCtrl:gotoBadgeObtainDetail()
	self.view.backGroundCloseUButton:SetActive(false)
	self:startTimer(function()
		pg.global.ui.playerEnhance:open({
			defaultTab = 1,
			defaultMode = 4,
			badgeTabIndex = self.mainType,
			badgeIdLook = self.badgeId
		}, nil, nil, nil, nil, true)
	end, 0.4)
end

function BadgeObtainCtrl:_closePanel()
	if self.nextBadgeIds then
		local nextBadgeId = table.remove(self.nextBadgeIds)

		if nextBadgeId then
			self.badgeId = nextBadgeId

			self:refreshView()

			return
		end
	end

	self:dismiss()
end

function BadgeObtainCtrl:_restore()
	if self.hasPlayedBadgeObtainEffect then
		pg.game.camera:closeBadgeObtainCamera(0.25)
		self:playMeThanksEndAnimation()
	end
end

function BadgeObtainCtrl:renderTextCondition(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local desc = string.format("%s [%s/%s]", pg.getLocalizationText(data.desc), data.curNum, data.needNum)

	ClientTextUtils.setText(txtNameUSDFText, desc)
end

function BadgeObtainCtrl:openItemObtainFrontCamera()
	local angle = pg.game.camera.playerCameraMode:getCameraDirToPlayerDirAngle()
	local turnAnimTime = -1

	if angle < 10 and angle > -10 then
		local cameraForward = pg.game.camera:getCameraPosition() - pg.me:getPosition()

		cameraForward.y = 0

		local targetRotation = Quaternion.LookRotation(cameraForward, Vector3.up)

		pg.me:turnToRotation(targetRotation)

		turnAnimTime = AnimationUtils.getAnimationTurnTime(pg.me, targetRotation)
		self.cameraTimer = self:startTimer(function()
			pg.game.camera:openBadgeObtainCamera()
			self:playMeThanksAnimation()
		end, turnAnimTime + 0.05)
	else
		pg.game.camera:openBadgeObtainCamera()
		self:playMeThanksAnimation()
	end

	return turnAnimTime
end

function BadgeObtainCtrl:playMeThanksAnimation()
	self.meThanksAnimationClosing = false
	self.meThanksLoopState = nil

	pg.me:stopAnimation(PlayableConst.Daily_Thanks_Start, nil, THANKS_ANIM_LAYER)
	pg.me:stopAnimation(PlayableConst.Daily_Thanks_Loop, nil, THANKS_ANIM_LAYER)
	pg.me:stopAnimation(PlayableConst.Daily_Thanks_End, nil, THANKS_ANIM_LAYER)

	local startState = pg.me:playAnimation(PlayableConst.Daily_Thanks_Start, nil, nil, nil, nil, THANKS_ANIM_LAYER)

	if not startState then
		self:playMeThanksLoopAnimation()

		return
	end

	pg.me:setAnimationSequence(startState, startState.Length - 0.2, function(stateTime)
		if stateTime > 0 and not self.meThanksAnimationClosing then
			self:playMeThanksLoopAnimation()
		end

		return true
	end)
end

function BadgeObtainCtrl:playMeThanksLoopAnimation()
	local loopState = pg.me:playAnimation(PlayableConst.Daily_Thanks_Loop, nil, nil, nil, nil, THANKS_ANIM_LAYER)

	if loopState then
		loopState:SetLogicLoop(true)

		self.meThanksLoopState = loopState
	end
end

function BadgeObtainCtrl:playMeThanksEndAnimation()
	self.meThanksAnimationClosing = true
	self.meThanksLoopState = nil

	pg.me:stopAnimation(PlayableConst.Daily_Thanks_Start, nil, THANKS_ANIM_LAYER)
	pg.me:stopAnimation(PlayableConst.Daily_Thanks_Loop, nil, THANKS_ANIM_LAYER)

	local endState = pg.me:playAnimation(PlayableConst.Daily_Thanks_End, nil, nil, nil, nil, THANKS_ANIM_LAYER)

	if endState then
		endState:AddAutoTransition(0)
	end
end

function BadgeObtainCtrl:canPlayBadgeObtainEffect()
	if not pg.me then
		return false
	end

	return not pg.me:isInAir() and not pg.me:FALL_ST() and not pg.me:CLIMB_ST() and not pg.me:SWIM_ST() and not pg.me:isInCombat() and not pg.me:ABILITY_ST() and not pg.me:HIT_ST() and not pg.me:BREAK_ST() and not pg.me:DEAD_ST() and not pg.me:FALLEN_ST() and not pg.me:NEAR_DEAD_ST() and not pg.me:INTERACT_ST() and not pg.me:MULTI_INTERACT_ST() and not pg.me:HOME_INTERACT_ST() and not pg.me:FLY_ST() and not pg.me:SKILL_GLIDING_ST() and not pg.me:SKILL_MOTION_ST() and not pg.me:LIFT_ST() and not pg.me:STUN_ST() and not pg.me:FROZEN_ST() and not pg.me:SLEEP_ST() and not pg.me:PALSY_ST() and not pg.me:KNOCK_UP_ST() and not pg.me:KNOCK_BACK_ST() and not pg.me:CONTROL_EGG_ST() and not pg.me:STORY_WALK_ST() and not pg.me:PLAY_SLOT_MACHINE_ST() and not pg.me:SPECIAL_RIDE_BOSS_ST()
end

return BadgeObtainCtrl
