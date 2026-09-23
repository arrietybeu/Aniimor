-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\Context\\NoBallContext.lua

local Class = require("Core.Framework.Class")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local EventConst = require("Const.EventConst")
local NoBallContext = Class.LightClass("NoBallContext")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClientUtils = require("Utils.ClientUtils")

function NoBallContext:ctor(player)
	self.player = player
end

function NoBallContext:enter(fromContext)
	if self.player.enterCaptureModeFromPet then
		self.player.enterCaptureModeFromPet = false
	end

	local notifyUI = not fromContext or fromContext.className ~= self.className

	self:enableCatchMode(false, nil, nil, notifyUI)
end

function NoBallContext:enableCatchMode(isEnable, isThrowItemMode, isBossCatch, notifyUI)
	pg.game.input:setEnableViewControlGyro(isEnable)
	pg.game.input:enableSkillInput(not isEnable)
	pg.game.camera.playerCameraMode:enableCatch(isEnable)

	if not isBossCatch and notifyUI ~= false then
		pg.global.eventEmitter:emit(EventConst.CATCH_MODE_CHANGE_UI, isEnable, isThrowItemMode, isBossCatch)
		facade:sendMsgToUI(MessageName.CATCH_MODE_CHANGE_UI, isEnable)
	end

	if isEnable then
		AIControllerUtils.sendAIEvent(self.player:getCurPetEntity(), "Msg_MasterCatchMode")
	end
end

function NoBallContext:throw()
	return
end

function NoBallContext:switch()
	return
end

function NoBallContext:throwBreak()
	return
end

function NoBallContext:throwEnd()
	return
end

function NoBallContext:exit()
	if ClientUtils.isInDouYinOfflineScene() then
		local itemId = pg.global.ui.hudV2:getCurSelectPropId()

		if not itemId then
			return false
		end

		self.player:enterOfflineCapture(itemId)

		return true
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_AVATAR_LOADING) then
		return false
	end

	if pg.me and pg.me.isInFishingCapture and pg.me:isInFishingCapture() then
		return false
	end

	local itemId = ClientCaptureUtils.getEnterCatchModeItemId()
	local hasBallOk = ClientCaptureUtils.hasBall(true, itemId)
	local canEnterOk = self.player:checkEnterCatchMode(true)

	if not hasBallOk or not canEnterOk then
		return false
	end

	if CharacterStateConst.isMidTransitionState(self.player:getLogicState()) then
		return false
	end

	if not self:checkCatchRogue() then
		return false
	end

	self.player:switchContext(ClientCaptureUtils.getThrowContext(self.player, itemId))

	if ClientCaptureUtils.isPaidBall(itemId) and not ClientCaptureUtils.hasUsableNormalBall() then
		pg.global.showBubbleMessageRaw(pg.getGameString("CATCH_AUTO_SELECT_PAID_BALL"))
	end

	return true
end

function NoBallContext:checkCatchRogue()
	if Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
		local itemId = pg.global.ui.hudV2:getCurSelectPropId()

		if not itemId then
			return false
		end

		return pg.me.catchRogueInfo:canFireBall(pg.me, itemId)
	else
		return true
	end
end

function NoBallContext:destroy()
	return
end

return NoBallContext
