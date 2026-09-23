-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopCoverPreset\\WorkShopCoverPresetCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UICtrl = require("Guis.UICtrl")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local WorkShopCoverPresetCtrl = Class.LightClass("WorkShopCoverPresetCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

WorkShopCoverPresetCtrl.messages = {}

function WorkShopCoverPresetCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.openData = info
	self.needDestroyDownloadSprite = {}
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
end

function WorkShopCoverPresetCtrl:addListener()
	function self.view.backUButton.luaClick()
		self:closePanel()
	end

	function self.view.presetUList.luaRenderItem(button, index, data)
		AvatarUtils.renderPresetList(button, index, data, self.needDestroyDownloadSprite)
	end

	function self.view.presetUList.luaSelectedChanged(uList)
		local data = uList.selectedItem

		if not data then
			return
		end

		if data.state == AvatarUtils.PRESET_STATE.NORMAL or data.state == AvatarUtils.PRESET_STATE.EMPTY then
			self.targetIndex = data.id
		elseif data.state == AvatarUtils.PRESET_STATE.LOCKED then
			local costText = LuaUIUtils.getItemCountConsumeShowText(data.costItemId, data.costNum, true)

			pg.global.ui.commonUseConfirm:open({
				type = 4,
				title = pg.getGameString("UNLOCK_TITLE"),
				tipTop = string.format(pg.getGameString("HOME_BUY_DESC"), costText),
				data = {
					{
						data.costItemId,
						data.costNum
					}
				},
				confirmCb = function()
					if self.openData.designType == AvatarUtils.DESIGN_TYPE.COSTUME then
						pg.me:serverMsg("RPC_CS_UnlockClothesDesignInfo", self.openData.configId, CallbackHandler(self, "refreshPresetList"))
					elseif self.openData.designType == AvatarUtils.DESIGN_TYPE.FACE then
						-- block empty
					elseif self.openData.designType == AvatarUtils.DESIGN_TYPE.HAIR then
						pg.me:serverMsg("RPC_CS_UnlockHairCustom", self.openData.configId, CallbackHandler(self, "refreshPresetList"))
					end
				end,
				cancelCb = function()
					self.view.presetUList:SelectItem(0)
				end
			})
		end
	end

	function self.view.coverPresetUButton.luaClick()
		if not self.targetIndex then
			pg.global.showBubbleMessageRaw(pg.getGameString("COVER_PRESET_WARN"), 3)

			return
		end

		if self.openData.coverCallback then
			self.openData.coverCallback(self.targetIndex)
		end
	end
end

function WorkShopCoverPresetCtrl:onDestroy()
	for _, sprite in ipairs(self.needDestroyDownloadSprite) do
		pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
	end

	UICtrl.onDestroy(self)
end

function WorkShopCoverPresetCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshPresetList()
end

function WorkShopCoverPresetCtrl:onShow()
	self.avatarScene:registerGesture(self.uid, {
		maskRayBoxTrans = self.view.maskRayBoxTrans
	})
	self.avatarScene:addCameraZoomKeyBinding(self.view.gameObject)
end

function WorkShopCoverPresetCtrl:onHide()
	self.avatarScene:unRegisterGesture(self.uid)
end

function WorkShopCoverPresetCtrl:refreshPresetList()
	ClientTextUtils.setText(self.view.presetTitleUBaseText, pg.getGameString("APPEARANCE_PRESET_FULL"))

	local usedNum, unlockNum, allNum = 0
	local presetList = {}

	if self.openData.designType == AvatarUtils.DESIGN_TYPE.COSTUME then
		usedNum, unlockNum, allNum = AvatarUtils.getClothesPresetNumInfo(self.openData.configId)
		presetList = AvatarUtils.getClothesPresetList(self.openData.configId, false)
	elseif self.openData.designType == AvatarUtils.DESIGN_TYPE.HAIR then
		local hairSuitId = LuaUIUtils.tryGetEntityHairSuitId(self.avatarScene:getCurEntity())

		presetList = AvatarUtils.getHairPresetList(hairSuitId, false)
		usedNum, unlockNum, allNum = AvatarUtils.getHairPresetNumInfo(hairSuitId)
	elseif self.openData.designType == AvatarUtils.DESIGN_TYPE.FACE then
		-- block empty
	end

	ClientTextUtils.setText(self.view.presetNumUBaseText, unlockNum, "/", allNum)
	self.view.presetUList:SetList(presetList)
	self.view.presetUList:SelectItem(0)
end

return WorkShopCoverPresetCtrl
