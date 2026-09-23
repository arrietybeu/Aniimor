-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SpaceFollowMember\\SpaceFollowMemberCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local SpaceFollowMemberCtrl = Class.LightClass("SpaceFollowMemberCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local FriendshipLevelData = require("Data.friendship_level_data")
local UIConst = require("Const.UIConst")

SpaceFollowMemberCtrl.messages = {
	[MessageName.SPACE_FOLLOW_UPDATE] = {
		"refreshSpaceFollowMembers",
		true
	}
}

function SpaceFollowMemberCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.spaceFollowMembers = info.spaceFollowMembers
	self.selectedBtn = nil
	self.selectedUid = nil
	self.petId = info.petId
	self.timeLeft = info.timeLeft
	self.view.btnConfirmUButton.interactable = false

	self:refreshFollowerList()
	self:refreshTimeText()
end

function SpaceFollowMemberCtrl:addListener()
	function self.view.btnCancelUButton.luaClick()
		self:close()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onConfirm()
	end

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.listFollowerUList.luaRenderItem(button, index, data)
		self:onRenderFollowerItem(button, index, data)
	end
end

function SpaceFollowMemberCtrl:refreshSpaceFollowMembers(followInfo)
	self.spaceFollowMembers = pg.game.chat:getGivePetEligibleFollowerUids(self.petId)

	self:refreshFollowerList()
end

function SpaceFollowMemberCtrl:refreshFollowerList()
	local data = {}

	if self.spaceFollowMembers and next(self.spaceFollowMembers) then
		for _, uid in ipairs(self.spaceFollowMembers) do
			table.insert(data, {
				playerId = uid
			})
		end
	end

	self.view.listFollowerUList:SetList(data)
end

function SpaceFollowMemberCtrl:onRenderFollowerItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local avatarUButton = objectReference:GetRefValue("avatarUButton")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local intimateUImage = objectReference:GetRefValue("intimateUImage")
	local btnSelectUButton = objectReference:GetRefValue("btnSelectUButton")

	pg.me:queryPlayerInfo(data.playerId, nil, true, function(playerData)
		LuaUIUtils.renderPlayerAvatarButton(avatarUButton, {
			playerId = data.playerId,
			playerInfo = playerData
		})
		ClientTextUtils.setText(txtNameUSDFText, playerData.playerName)

		local friendShipLevel = pg.game.chat:getFriendship(data.playerId)
		local hasFriendship = friendShipLevel and FriendshipLevelData[friendShipLevel]

		intimateUImage:SetActive(hasFriendship)

		if hasFriendship then
			local friendshipIcon = FriendshipLevelData[friendShipLevel].levelIcon

			intimateUImage.url = friendshipIcon
		end
	end)

	function btnSelectUButton.luaClick()
		btnSelectUButton.isSelected = not btnSelectUButton.isSelected
		self.view.btnConfirmUButton.interactable = true

		if self.selectedBtn then
			self.selectedBtn.isSelected = false
		end

		self.selectedBtn = btnSelectUButton
		self.selectedUid = data.playerId
	end

	button.luaClick = btnSelectUButton.luaClick()
end

function SpaceFollowMemberCtrl:refreshTimeText()
	ClientTextUtils.setText(self.view.textTimeUSDFText, pg.getFormatText(pg.getGameString("SPACE_FOLLOW_GIVE_PET_TIME"), LuaUIUtils.getCountDownString(self.timeLeft, UIConst.TimeType.Short, true)))

	self.timeCountTimer = self:startTimer(function()
		self.timeLeft = self.timeLeft - 1

		ClientTextUtils.setText(self.view.textTimeUSDFText, pg.getFormatText(pg.getGameString("SPACE_FOLLOW_GIVE_PET_TIME"), LuaUIUtils.getCountDownString(self.timeLeft, UIConst.TimeType.Short, true)))

		if self.timeLeft <= 0 then
			self:killTimer(self.timeCountTimer)

			self.timeCountTimer = nil
		end
	end, 1, true)
end

function SpaceFollowMemberCtrl:onClose()
	if self.timeCountTimer <= 0 then
		self:killTimer(self.timeCountTimer)

		self.timeCountTimer = nil
	end

	self.selectedBtn = nil
end

function SpaceFollowMemberCtrl:onConfirm()
	if self.selectedUid then
		pg.global.ui:open(UIConst.UI_ID_SPACE_FOLLOW_GIVE_CONFIRM, {
			petId = self.petId,
			playerId = self.selectedUid,
			timeLeft = self.timeLeft
		})
	end
end

function SpaceFollowMemberCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return SpaceFollowMemberCtrl
