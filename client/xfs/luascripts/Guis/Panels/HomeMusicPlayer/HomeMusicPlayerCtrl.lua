-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeMusicPlayer\\HomeMusicPlayerCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local MessageName = require("Const.MessageName")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local LoggerManager = require("Core.Log.LoggerManager")
local RedDotConst = require("Const.RedDotConst")
local HomeMusicPlayerCtrl = Class.LightClass("HomeMusicPlayerCtrl", UICtrl)
local logger = LoggerManager.getLogger("HomeMusicPlayerCtrl")

HomeMusicPlayerCtrl.SHOWCASE_FOV = 48
HomeMusicPlayerCtrl.SHOWCASE_VERTICAL_COVERAGE = 0.53
HomeMusicPlayerCtrl.SHOWCASE_PITCH = 12
HomeMusicPlayerCtrl.SHOWCASE_YAW = 26
HomeMusicPlayerCtrl.SHOWCASE_HORIZONTAL_OFFSET_RATIO = 0.12
HomeMusicPlayerCtrl.SHOWCASE_VERTICAL_OFFSET_RATIO = 0.02
HomeMusicPlayerCtrl.SHOWCASE_BLEND_TIME = 0.8
HomeMusicPlayerCtrl.messages = {
	[MessageName.HOMELAND_BGM_CHANGED] = {
		"onHomelandBgmChanged",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onItemCountChanged",
		true
	},
	[MessageName.HOMELAND_ITEM_MAP_CHANGED] = {
		"onItemCountChanged",
		true
	},
	[MessageName.HOMELAND_PETS_CHANGE] = {
		"onHomelandPetsChanged",
		true
	}
}

function HomeMusicPlayerCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.ornamentId = nil
	self.playingBgmItemId = Const.HOMELAND_BGM_ITEM_ID_SCENE_DEFAULT
	self.setBgmRequestSerial = 0
	self.latestRequestedBgmItemId = Const.HOMELAND_BGM_ITEM_ID_SCENE_DEFAULT
	self._focusEnabled = false
	self._hiddenHomePetIds = {}
end

function HomeMusicPlayerCtrl:addListener()
	UICtrl.addListener(self)

	local view = self.view

	if view.listMusicPlayerUList then
		view.listMusicPlayerUList.luaRenderItem = CallbackHandler(self, "renderMusicItem")
		view.listMusicPlayerUList.luaClick = CallbackHandler(self, "onClickMusicItem")
	end

	if view.btnBackUButton then
		view.btnBackUButton.luaClick = CallbackHandler(self, "onClickClose")
	end

	self:bindCloseButton(view.btnBackUButton)

	if view.btnInfoUButton then
		LuaUIUtils.bindCommonTipInfo(view.btnInfoUButton, pg.getGameString("HOME_BGM_TIPS"))
	end
end

function HomeMusicPlayerCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.setBgmRequestSerial = self.setBgmRequestSerial + 1
	info = info or {}
	self.ornamentId = info.ornamentId
	self.playingBgmItemId = pg.space:getSelectedBgmItemId()
	self.latestRequestedBgmItemId = self.playingBgmItemId

	self.model:beginViewSession()
	self.model:buildDisplayList(self.playingBgmItemId, pg.space:getDefaultBgmConfigId())
	self:refreshDisplayList()
	self:focusFurniture()
end

function HomeMusicPlayerCtrl:onDestroy()
	self.setBgmRequestSerial = self.setBgmRequestSerial + 1
	self.latestRequestedBgmItemId = nil

	self.model:markAllMusicViewed()

	if self._focusEnabled and pg.game and pg.game.camera then
		pg.game.camera:enableFocusTarget(false)

		self._focusEnabled = false
	end

	if self._showcaseActorsHidden and pg.me then
		pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.HOME_MUSIC_PLAYER, true)
		pg.me:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.HOME_MUSIC_PLAYER, true)

		for petId in pairs(self._hiddenHomePetIds) do
			local pet = pg.getEntity(petId)

			if pet then
				pet:setVisible(ClientConst.MODEL_VISIBLE_KEY.HOME_MUSIC_PLAYER, true)
			end
		end

		table.clear(self._hiddenHomePetIds)

		self._showcaseActorsHidden = false
	end

	UICtrl.onDestroy(self)
end

function HomeMusicPlayerCtrl:focusFurniture()
	if not self.ornamentId or not pg.game or not pg.game.home or not pg.game.camera then
		return
	end

	local targetEntity = pg.game.home:getHomeEntity(self.ornamentId)

	if not targetEntity or not targetEntity.eModel or not targetEntity.getPositionAgentPosition or not targetEntity.getRotation then
		return
	end

	local furnitureHeight = tonumber(targetEntity.eModel:GetMeshSize(Const.COMPONENT_IDX_ITEM, 1)) or 0

	if furnitureHeight <= 0 and targetEntity.getBoundHeight then
		furnitureHeight = tonumber(targetEntity:getBoundHeight()) or 0
	end

	if furnitureHeight <= 0 then
		return
	end

	local furniturePosition = targetEntity:getPositionAgentPosition()
	local furnitureForward = targetEntity:getRotation():Forward()

	furnitureForward.y = 0

	if Vector3.SqrMagnitude(furnitureForward) <= 0.0001 then
		return
	end

	furnitureForward:Normalize()

	local furnitureRight = targetEntity:getRotation() * Vector3.right

	furnitureRight.y = 0

	if Vector3.SqrMagnitude(furnitureRight) <= 0.0001 then
		return
	end

	furnitureRight:Normalize()

	local furnitureCenter = furniturePosition + Vector3.up * (furnitureHeight * 0.5)
	local halfFovRadian = math.rad(HomeMusicPlayerCtrl.SHOWCASE_FOV * 0.5)
	local cameraDistance = furnitureHeight * 0.5 / (math.tan(halfFovRadian) * HomeMusicPlayerCtrl.SHOWCASE_VERTICAL_COVERAGE)
	local pitchRadian = math.rad(HomeMusicPlayerCtrl.SHOWCASE_PITCH)
	local yawRadian = math.rad(HomeMusicPlayerCtrl.SHOWCASE_YAW)
	local cameraDirection = furnitureForward * math.cos(yawRadian) - furnitureRight * math.sin(yawRadian)
	local cameraPosition = furnitureCenter + cameraDirection * (cameraDistance * math.cos(pitchRadian)) + Vector3.up * (cameraDistance * math.sin(pitchRadian))
	local baseRotation = Quaternion.LookRotation(furnitureCenter - cameraPosition, Vector3.up)
	local cameraRight = baseRotation * Vector3.right
	local lookAtPosition = furnitureCenter + cameraRight * (cameraDistance * HomeMusicPlayerCtrl.SHOWCASE_HORIZONTAL_OFFSET_RATIO) + Vector3.up * (cameraDistance * HomeMusicPlayerCtrl.SHOWCASE_VERTICAL_OFFSET_RATIO)
	local cameraRotation = Quaternion.LookRotation(lookAtPosition - cameraPosition, Vector3.up)

	pg.me:setVisible(ClientConst.MODEL_VISIBLE_KEY.HOME_MUSIC_PLAYER, false)
	pg.me:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.HOME_MUSIC_PLAYER, false)

	self._showcaseActorsHidden = true

	self:onHomelandPetsChanged()
	pg.game.camera:enableFocusTarget(true, {
		homeMusicPlayer = targetEntity
	}, {
		position = cameraPosition,
		rotation = cameraRotation,
		fov = HomeMusicPlayerCtrl.SHOWCASE_FOV,
		blendTime = HomeMusicPlayerCtrl.SHOWCASE_BLEND_TIME
	})

	self._focusEnabled = true
end

function HomeMusicPlayerCtrl:onHomelandPetsChanged()
	if not self._showcaseActorsHidden or not pg.space or not pg.space.pets then
		return
	end

	for petId in pairs(pg.space.pets) do
		local pet = pg.getEntity(petId)

		if pet then
			pet:setVisible(ClientConst.MODEL_VISIBLE_KEY.HOME_MUSIC_PLAYER, false)

			self._hiddenHomePetIds[petId] = true
		end
	end
end

function HomeMusicPlayerCtrl:refreshDisplayList()
	local list = self.view.listMusicPlayerUList

	if not list then
		return
	end

	list:SetList(self.model:getDisplayList())
	self:syncPlayingSelection()
end

function HomeMusicPlayerCtrl:syncPlayingSelection(bgmItemId)
	local list = self.view.listMusicPlayerUList

	bgmItemId = tonumber(bgmItemId)

	if bgmItemId == nil then
		bgmItemId = self.playingBgmItemId
	end

	local playingIndex = self.model:getDisplayIndexByBgmItemId(bgmItemId)

	if playingIndex ~= nil then
		list:SelectItem(playingIndex, false)
	else
		list:DeselectAll(false)
	end
end

function HomeMusicPlayerCtrl:renderMusicItem(button, index, data)
	local nameText = self.view:getMusicNameText(button)

	ClientTextUtils.setText(nameText, pg.getLocalizationText(data.name))
	pg.global.setRedDot(data.newRedDotPath, button, data.isNew, RedDotConst.RedDotStyle.NEW)
	button:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, nil, CallbackHandler(self, "onGamepadSelectMusic", button, data))
	button:SetHotkeyActiveOnlyInCurrentItem(true)
end

function HomeMusicPlayerCtrl:onClickMusicItem(button, data)
	self:selectMusic(data, button)
end

function HomeMusicPlayerCtrl:onGamepadSelectMusic(button, data)
	self:selectMusic(data, button)

	return false
end

function HomeMusicPlayerCtrl:clearMusicNewRedDot(data, button)
	if not data or not data.isNew then
		return
	end

	pg.me:setRedDotRecord(Const.CLIENT_KEY.HOMELAND_MUSIC_PLAYER_RED_DOT, data.newRedDotPath, false)

	data.isNew = false

	if button then
		pg.global.setRedDot(data.newRedDotPath, button, false, RedDotConst.RedDotStyle.NEW)
	end
end

function HomeMusicPlayerCtrl:selectMusic(data, button)
	if not data then
		return
	end

	if data.bgmItemId ~= self.playingBgmItemId then
		local playingIndex = self.model:getDisplayIndexByBgmItemId(self.playingBgmItemId)

		if playingIndex ~= nil then
			local playingData = self.model:getDisplayList()[playingIndex + 1]
			local _, playingButton = self.view.listMusicPlayerUList:TryGetChildAt(playingIndex)

			self:clearMusicNewRedDot(playingData, playingButton)
		end
	end

	self:clearMusicNewRedDot(data, button)

	if data.bgmItemId == self.latestRequestedBgmItemId then
		return
	end

	self.latestRequestedBgmItemId = data.bgmItemId
	self.setBgmRequestSerial = self.setBgmRequestSerial + 1

	local requestSerial = self.setBgmRequestSerial

	pg.space:setHomelandBgm(data.bgmItemId, CallbackHandler(self, "onSetHomelandBgmCallback", requestSerial))
end

function HomeMusicPlayerCtrl:onSetHomelandBgmCallback(requestSerial, code, currentBgmItemId)
	if requestSerial ~= self.setBgmRequestSerial or not self:checkUIOpen() then
		return
	end

	local codes = Const.HOMELAND_ORNAMENT_OP_RETURN_CODE

	if code == codes.SUCCESS then
		return
	end

	self.latestRequestedBgmItemId = tonumber(currentBgmItemId) or Const.HOMELAND_BGM_ITEM_ID_SCENE_DEFAULT

	self:syncPlayingSelection(self.latestRequestedBgmItemId)

	if code == codes.ERROR_ITEM_NOT_ENOUGH then
		pg.global.showBubbleMessage(NoticeDef.ITEM_COUNT_LACK)
	else
		pg.global.showBubbleMessage(NoticeDef.ERROR_SERVICE_CALLBACK)
	end

	logger:error("set homeland BGM failed, code=%s, currentBgmItemId=%s", tostring(code), tostring(currentBgmItemId))
end

function HomeMusicPlayerCtrl:onItemCountChanged(message)
	if not message then
		return
	end

	local changedItemId = tonumber(message.itemId or message.genId)

	if not self.model.isMusicUnlockItemId(changedItemId) then
		return
	end

	local space = pg.me and pg.me.space

	if not space or not space:isHomeland() or not space:isSelfHomeland(pg.me) then
		return
	end

	self.model:buildDisplayList(self.playingBgmItemId, space:getDefaultBgmConfigId())
	self:refreshDisplayList()
end

function HomeMusicPlayerCtrl:onHomelandBgmChanged(bgmItemId)
	self.playingBgmItemId = bgmItemId

	self.model:setPlayingBgmItemId(self.playingBgmItemId)
	self:syncPlayingSelection()
end

function HomeMusicPlayerCtrl:onClickClose()
	self:close()
end

return HomeMusicPlayerCtrl
