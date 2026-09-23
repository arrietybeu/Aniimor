-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SpaceFollowGiveConfirm\\SpaceFollowGiveConfirmCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local SpaceFollowGiveConfirmCtrl = Class.LightClass("SpaceFollowGiveConfirmCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local UIConst = require("Const.UIConst")

function SpaceFollowGiveConfirmCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petId = info.petId
	self.playerId = info.playerId
	self.timeLeft = info.timeLeft

	self:refreshTextDetail()
end

function SpaceFollowGiveConfirmCtrl:addListener()
	function self.view.btnConfirmUButton.luaClick()
		self:onConfirm()
	end

	function self.view.btnCancelUButton.luaClick()
		self:close()
	end
end

function SpaceFollowGiveConfirmCtrl:refreshTextDetail()
	local petName = PetManagementDataHelper.getPetName(self.petId)
	local playerInfo = pg.game.chat:getPlayerInfo(self.playerId)
	local playerName = playerInfo.playerName
	local _h = SpaceFollowGiveConfirmCtrl._platformHooks

	playerName = _h and _h.refreshTextDetailName and _h.refreshTextDetailName(self, playerInfo, playerName) or playerName

	ClientTextUtils.setText(self.view.textDetailUSDFText, pg.getFormatText(pg.getGameString("SPACE_FOLLOW_GIVE_PET_DES"), petName, playerName))
	ClientTextUtils.setText(self.view.txtTimeUSDFText, pg.getFormatText(pg.getGameString("SPACE_FOLLOW_GIVE_PET_TIME"), LuaUIUtils.getCountDownString(self.timeLeft, UIConst.TimeType.Short, true)))

	self.timeCountTimer = self:startTimer(function()
		self.timeLeft = self.timeLeft - 1

		ClientTextUtils.setText(self.view.txtTimeUSDFText, pg.getFormatText(pg.getGameString("SPACE_FOLLOW_GIVE_PET_TIME"), LuaUIUtils.getCountDownString(self.timeLeft, UIConst.TimeType.Short, true)))

		if self.timeLeft <= 0 then
			self:killTimer(self.timeCountTimer)

			self.timeCountTimer = nil
		end
	end, 1, true)
end

function SpaceFollowGiveConfirmCtrl:onConfirm()
	pg.me:givePetToSpaceFollower(self.petId, self.playerId)

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_SPACE_FOLLOW_MEMBER) then
		pg.global.ui:close(UIConst.UI_ID_SPACE_FOLLOW_MEMBER)
	end

	self:close()
end

function SpaceFollowGiveConfirmCtrl:onClose()
	if self.timeCountTimer then
		self:killTimer(self.timeCountTimer)

		self.timeCountTimer = nil
	end
end

function SpaceFollowGiveConfirmCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return SpaceFollowGiveConfirmCtrl
