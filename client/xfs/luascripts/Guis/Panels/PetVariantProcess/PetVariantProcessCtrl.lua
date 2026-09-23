-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetVariantProcess\\PetVariantProcessCtrl.lua

local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local TimerManager = require("Core.Timer.TimerManager")
local PetVariantNameItem = require("Guis.Panels.PetVariantProcess.PetVariantNameItem")
local UICtrl = require("Guis.UICtrl")
local PetVariantProcessCtrl = Class.LightClass("PetVariantProcessCtrl", UICtrl)
local logger = LoggerManager.getLogger("PetVariantProcessCtrl")

function PetVariantProcessCtrl:checkInfoValid(info)
	if not info or info.isSuccess ~= true then
		logger:error("unexpected failed pet variant result, info=%s", inspect(info, {
			depth = 3
		}))

		return false
	end

	local selfPetInfo, friendPetInfo = self:_getVariantPetInfo(info)

	if not selfPetInfo or not friendPetInfo then
		logger:error("missing pet variant presentation info, socialInfo=%s", inspect(info.socialInfo, {
			depth = 3
		}))

		return false
	end

	return true
end

function PetVariantProcessCtrl:_getVariantPetInfo(info)
	local players = info.socialInfo and info.socialInfo.players

	if not players then
		return nil, nil
	end

	local selfInfo, friendInfo = Utils.unpackSocialPlayerInfo(players, info.uid)

	return selfInfo and selfInfo.petInfo, friendInfo and friendInfo.petInfo, selfInfo
end

function PetVariantProcessCtrl:addListener()
	UICtrl.addListener(self)

	function self.view.backGroundCloseUButton.luaClick()
		self:_finishAndOpenResult()
	end
end

function PetVariantProcessCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.resultOpened = false

	local selfPetInfo, friendPetInfo, selfInfo = self:_getVariantPetInfo(info)

	self.resultInfo = {
		petInfo = selfPetInfo,
		propListBeforeVariant = selfInfo.propListBeforeVariant
	}

	local centerPosition = self.uiScene:getCenterPosition()
	local outputCamera = self.uiScene:getCamera()
	local started = pg.game.petVariant:startVariant(selfPetInfo, friendPetInfo, centerPosition, outputCamera, CallbackHandler(self, "_finishAndOpenResult"))

	if not started then
		logger:error("failed to start pet variant presentation")
		self:closeImmediately()

		return
	end

	self:_createPetNameItems(outputCamera)
end

function PetVariantProcessCtrl:_finishAndOpenResult()
	if self.resultOpened then
		return
	end

	local resultInfo = self.resultInfo

	self.resultOpened = true

	pg.global.ui:open(UIConst.UI_ID_PET_VARIANT_RESULT, resultInfo, nil, function()
		self:closeImmediately()
	end)
end

function PetVariantProcessCtrl:closeImmediately()
	pg.game.petVariant:finishVariant()
	UICtrl.closeImmediately(self)
end

function PetVariantProcessCtrl:_createPetNameItems(outputCamera)
	local parent = self.view.transform

	self.petNameItems = {
		PetVariantNameItem.new(self.view, parent, outputCamera, pg.game.petVariant.selfPetEntity),
		PetVariantNameItem.new(self.view, parent, outputCamera, pg.game.petVariant.friendPetEntity)
	}
	self.petNameFrameId = TimerManager.addRepeatNextFrameCb(CallbackHandler(self, "_updatePetNameItems"))
end

function PetVariantProcessCtrl:_updatePetNameItems()
	for _, item in ipairs(self.petNameItems) do
		item:update()
	end
end

function PetVariantProcessCtrl:onDestroy()
	if self.petNameFrameId then
		TimerManager.delFrameCb(self.petNameFrameId)

		self.petNameFrameId = nil
	end

	if self.petNameItems then
		for _, item in ipairs(self.petNameItems) do
			item:destroy()
		end

		self.petNameItems = nil
	end

	self.resultInfo = nil

	UICtrl.onDestroy(self)
end

return PetVariantProcessCtrl
