-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\GamePlayClass\\ClientGamePlayPetChallenge.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientGamePlayEntity = require("Entities.SpaceEntities.GamePlayClass.ClientGamePlayEntity")
local SandboxConst = require("Common.Const.SandboxConst")
local ClientConst = require("Const.ClientConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local PetChallengeData = require("Data.pet_challenge_data")
local Time = require("Core.Common.Time")
local CommonSwitch = require("Common.CommonSwitch")
local RESULT = SandboxConst.PET_CHALLENGE_RESULT
local ClientGamePlayPetChallenge = class.Class("ClientGamePlayPetChallenge", ClientGamePlayEntity)
local DATA_PREFIX = "endFinishHint"

function ClientGamePlayPetChallenge:destroy()
	if clientLevelUtils.isSelfSpace() then
		pg.global.ui.tips:hideCountDown()
	end

	ClientGamePlayPetChallenge.super.destroy(self)
end

function ClientGamePlayPetChallenge:enterSpace(space)
	local sandbox = space:getSandbox(self.sandboxId)

	if sandbox then
		sandbox:addGameplay(self)
	end

	if self.actived and self.endTime and self.endTime > Time.secondCache then
		self:_showStartToast()
	end
end

function ClientGamePlayPetChallenge:interactSheep(actorId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("--------------------ClientGamePlayPetChallenge interactSheep", actorId)
	end

	self:serverMsg("RPC_CS_InteractSheep", actorId)
end

function ClientGamePlayPetChallenge:_showStartToast()
	if not clientLevelUtils.isSelfSpace() then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("--------------------_showStartToast", self.challengeId, self.endTime)
	end

	local petChallengeResData = PetChallengeData[self.challengeId]

	if not petChallengeResData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("--------------------ClientGamePlayPetChallenge _showStartToast can not find ResData!", self.challengeId)
		end

		return
	end

	local noticeStr = pg.getLocalizationText(petChallengeResData.startHint)
	local duration = self.endTime - Time.secondCache

	if not CommonSwitch.TARGET then
		pg.global.ui.tips:showCountDown(duration)
	end

	pg.global.showBubbleMessageRaw(noticeStr, petChallengeResData.startHintDuration)
end

function ClientGamePlayPetChallenge:on_result_changed(oldV, newV)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("result changed from %s to %s", oldV, newV)
	end

	if not clientLevelUtils.isSelfSpace() then
		return
	end

	facade:sendLuaEvent("SandboxPetChallengeState" .. tostring(self.sandboxId), newV)

	if newV and newV ~= RESULT.INIT then
		pg.global.ui.tips:hideCountDown()

		local petChallengeResData = PetChallengeData[self.challengeId]

		if not petChallengeResData then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("--------------------ClientGamePlayPetChallenge on_result_changed can not find ResData!", self.challengeId)
			end

			return
		end

		local isSuccess = newV == RESULT.SUCCESS
		local titleKey = isSuccess and "winTitle" or "loseTitle"
		local realTitle = pg.getLocalizationText(petChallengeResData[titleKey])
		local msg = {
			args = {
				POIIcon = "$UI_Icon_POI_Decrypt_TimeLimited.png",
				isSuccess = isSuccess,
				POIShowType = {
					1,
					0
				}
			}
		}

		if isSuccess then
			msg.args.completeTitle = realTitle
			msg.args.completeText = pg.getLocalizationText(petChallengeResData[DATA_PREFIX .. newV])
		else
			msg.args.failTitle = realTitle
			msg.args.failText = pg.getLocalizationText(petChallengeResData[DATA_PREFIX .. newV])
		end

		pg.global.ui.tips:showPoi(msg)
	end
end

function ClientGamePlayPetChallenge:RPC_SC_ActiveChallenge(active, endTime)
	if not clientLevelUtils.isSelfSpace() then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("--------------------RPC_SC_ActiveChallenge", active, endTime)
	end

	if active == true then
		self:_showStartToast()
	end
end

function ClientGamePlayPetChallenge:on_actived_changed(oldV, newV)
	if not clientLevelUtils.isSelfSpace() then
		return
	end

	facade:sendLuaEvent("SandboxPetChallengeActive" .. tostring(self.sandboxId), newV)
end

return ClientGamePlayPetChallenge
