-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\ArkPropshop.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local ArkPropshop = Class.LightClass("ArkPropshop", LevelItem)
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local SandboxConst = require("Common.Const.SandboxConst")
local ClientUtils = require("Utils.ClientUtils")
local PetData = require("Data.pet_data")
local ArkGameStrengthData = require("Data.ark_game_strength_data")
local CommonExchangeData = require("Data.common_exchange_data")
local CallbackHandler = require("Core.Common.CallbackHandler")
local AiConst = require("Common.Const.AiConst")

function ArkPropshop:ctor(sandbox, spawnInfo, syncInfo)
	ArkPropshop.super.ctor(self, sandbox, spawnInfo, syncInfo)

	self.sysName = "ArkPropshop"
	self.exchangeNum = 300
	self.maxStage = 3
end

function ArkPropshop:onSandboxReady()
	ArkPropshop.super.onSandboxReady(self)

	self.arkPropshop = self.shell.gameObject:GetComponent("ArkPropshop")
end

function ArkPropshop:toggle(isOn)
	local petInfo = ClientUtils.getCurrentPetInfo()

	if petInfo and petInfo.templateId and petInfo.templateId > 0 then
		local petData = PetData[petInfo.templateId]

		self.prefabResID = petData.prefabResID
		self.stage = petData.stage

		if self.stage > self.maxStage then
			self.stage = self.maxStage
		end

		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("ARK_PROPSHOP_CONSUME"), function()
			local curPet = pg.me:getCurPetEntity()

			if curPet then
				curPet:pauseBt(AiConst.PauseBtReason.ArkPropshop)
			end

			local exchangeId = self.stage + self.exchangeNum

			pg.me:serverMsg("RPC_CS_StartCommonExchange", exchangeId, CallbackHandler(self, "onStartExchangeCallback"))
		end, nil)
	else
		pg.global.ui.tips:showTextTip(pg.getGameString("ARK_PROPSHOP_NEED_A_PET"))
	end
end

function ArkPropshop:onStartExchangeCallback(result, orderId, rewardIndex)
	if result then
		self.orderId = orderId
		self.rewardIndex = rewardIndex

		local levelIndex = rewardIndex

		pg.global.ui.interact:hide()

		pg.me.inPeep = true

		self.arkPropshop:PlayTimeline(self.prefabResID, levelIndex)
		self:addTimer(10, function()
			if self and pg.me and not pg.me.inPeep then
				pg.global.ui.interact:show()

				pg.me.inPeep = false

				local curPet = pg.me:getCurPetEntity()

				if curPet then
					curPet:resumeBt(AiConst.PauseBtReason.ArkPropshop)
				end
			end
		end)
	else
		local curPet = pg.me:getCurPetEntity()

		if curPet then
			curPet:resumeBt(AiConst.PauseBtReason.ArkPropshop)
		end
	end
end

function ArkPropshop:onTimelineFinish()
	local strengthData = ArkGameStrengthData[self.stage]
	local finishFx = strengthData.finishEffect[self.rewardIndex]

	if finishFx and finishFx ~= "" then
		self.arkPropshop:PlayFinishFx(strengthData.finishEffect[self.rewardIndex])
		pg.game.audio:triggerEvent(strengthData.finishSFX[self.rewardIndex])
	end

	self:addTimer(self.arkPropshop.finishFxDelay, function()
		self.arkPropshop:StopTimeline()

		local curPet = pg.me:getCurPetEntity()

		if curPet then
			curPet:resumeBt(AiConst.PauseBtReason.ArkPropshop)
		end

		pg.global.ui.interact:show()

		pg.me.inPeep = false

		local dialogueId = ArkGameStrengthData[self.stage].finishDialogueGraph[self.rewardIndex]

		if dialogueId and dialogueId ~= 0 then
			pg.game.dialogue:playDialogueGraph(dialogueId, function()
				pg.me:serverMsg("RPC_CS_FinishCommonExchange", self.orderId, CallbackHandler(self, "onFinishExchangeCallback"))
			end)
		end
	end)
end

function ArkPropshop:onFinishExchangeCallback(result)
	if result then
		-- block empty
	end
end

function ArkPropshop:destroy()
	pg.global.ui.interact:show()

	pg.me.inPeep = false

	local curPet = pg.me:getCurPetEntity()

	if curPet then
		curPet:resumeBt(AiConst.PauseBtReason.ArkPropshop)
	end

	ArkPropshop.super.destroy(self)
end

return ArkPropshop
