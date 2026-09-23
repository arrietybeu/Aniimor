-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MobileOperate\\MobileOperateCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("MobileOperateCtrl")
local MessageName = require("Const.MessageName")
local MoveJoyStickUIComponent = require("Guis.Panels.MobileOperate.Component.MoveJoyStickUIComponent")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local lshift = bit.lshift
local bor = bit.bor
local Utils = require("Common.Utils.Utils")
local MobileOperateCtrl = Class.LightClass("MobileOperateCtrl", UICtrl)

MobileOperateCtrl.messages = {
	[MessageName.MAGNESIS_MODE_CHANGE] = {
		"onMagnesisModeChange",
		true
	},
	[MessageName.DUNGEON_TEAMMATEVIEW_CHANGE] = {
		"onTeammateViewChange",
		true
	}
}

function MobileOperateCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.moveJoyStick = MoveJoyStickUIComponent.new(self, self.view.transform)
end

function MobileOperateCtrl:addListener()
	self.view.clickObject:SetCameraWorldCamera()

	self.view.clickObject.layerMask = bor(lshift(1, ClientConst.LayerDefine.LAYER_PLAYER), lshift(1, ClientConst.LayerDefine.LAYER_ENTITY))

	function self.view.clickObject.luaClick(go, ent, dist)
		if not go then
			return
		end

		local entActorId = -1
		local name = go.name == "PlayerBody" and go.transform.parent.gameObject.name or go.name

		if go.layer == ClientConst.LayerDefine.LAYER_PLAYER then
			if string.sub(name, 1, 13) == "ClientPlayer-" then
				self.playerId = string.sub(name, 14, 29)

				local entity = pg.getEntity(self.playerId)

				if not pg.global.ui:checkUIOpen(UIConst.UI_ID_INTERACT_GESTURE) then
					local param = {
						openType = ClientConst.PlayerInfoOpenType.MobFaceToFace,
						playerId = entity.uid,
						openSource = pg.game.chat.AddFriendSource.FaceToFace
					}

					LuaUIUtils.openInfoPlayerCard(param)
				end

				if entity then
					entity:ensureAndExecuteTplComMethod(UIConst.TOPLOGO_COMPONENT.SOCIAL, "refreshSelectFrame", {
						show = true
					})
					pg.game.social:muteInteractGestureFunc(true)
				end
			end
		elseif go.layer == ClientConst.LayerDefine.LAYER_ENTITY and string.sub(name, 1, 13) == "ClientPuppet-" then
			local entId = string.sub(name, 14, 29)
			local entity = pg.getEntity(entId)

			entActorId = entity.actorId

			pg.game.controller.lockHelper:tryManualForceLockTarget(dist, entActorId, 0)
		end
	end
end

function MobileOperateCtrl:onTeammateViewChange()
	if pg.me.inTeammateView then
		self.view.safeMobileBoxUWidget.gameObject:SetActiveEx(false)
	else
		self.view.safeMobileBoxUWidget.gameObject:SetActiveEx(true)
	end
end

function MobileOperateCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function MobileOperateCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function MobileOperateCtrl:onShow()
	return
end

function MobileOperateCtrl:onHide()
	return
end

function MobileOperateCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function MobileOperateCtrl:onMagnesisModeChange(enable)
	if self.moveJoystick then
		self.moveJoystick:changeMagnesisGestureBehavior(enable)
	end
end

function MobileOperateCtrl:onVisibleChange(visible)
	if visible and self.moveJoystick then
		self.moveJoystick:initGesture()
	end
end

return MobileOperateCtrl
