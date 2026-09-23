-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ShopPoster\\ShopPosterCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Const = require("Common.Const.Const")
local CameraConst = require("GameApp.Camera.CameraConst")
local UIConst = require("Const.UIConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local PlayableConst = require("Common.Const.PlayableConst")
local ShopPosterCtrl = Class.LightClass("ShopPosterCtrl", UICtrl)

ShopPosterCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function ShopPosterCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.scrolling = nil
	self.posterStaticId = info.posterStaticId

	self:showPictures(info.imgUrls)
	self:Init()
	self:initGesture()
end

function ShopPosterCtrl:onShow()
	return
end

function ShopPosterCtrl:onHide()
	return
end

function ShopPosterCtrl:onDestroy()
	self:destroy()
	UICtrl.onDestroy(self)
end

function ShopPosterCtrl:Init()
	local nearHeight, _ = pg.pawn:getCameraHeightInfo()
	local pivotOffset = Vector3(0, nearHeight, 0)
	local angle = pg.game.camera.playerCameraMode:getCameraDirToPlayerDirAngle()
	local cameraPos = angle > 90 and pg.global.cameraMgr.vcManager:GetShopPosterFrontPos() or pg.global.cameraMgr.vcManager:GetShopPosterBackPos()
	local cameraRot = angle > 90 and pg.global.cameraMgr.vcManager:GetShopPosterFrontRot() or pg.global.cameraMgr.vcManager:GetShopPosterBackRot()
	local fov = angle > 90 and pg.global.cameraMgr.vcManager:GetShopPosterFrontFov() or pg.global.cameraMgr.vcManager:GetShopPosterBackFov()

	pg.game.camera:cameraBlendToFixedWithTargetByActorId(cameraPos, cameraRot, fov, pg.me.actorId, 0.5, function()
		if angle > 90 then
			pg.me.eModel.modelModelView:SetLightIntensity(1)
		end
	end, {
		inheritDir = false,
		pivotOffset = pivotOffset
	})
	self:tryPlayPlayerAni()

	if pg.me:MAGNESIS_READY_ST() or pg.me:MAGNESIS_ST() then
		pg.me:magnesisCancel()
	end

	self.controlPet = pg.me:isControllingPet()

	if self.controlPet then
		pg.me:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.ShopPoster)
		self:tryPlayPlayerAni()
	end

	function self.scrollEnd()
		if self.curPage == 0 then
			self.curPage = self.imgUrlsCount / 2
		elseif self.curPage == self.imgUrlsCount - 1 then
			self.curPage = self.curPage - self.imgUrlsCount / 2
		end

		self.view.imgList:GoToIndex(self.curPage, true)

		self.scrolling = false
	end

	self.view.imgList:RegisterToScrollEndEvent(self.scrollEnd)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.FuncMenu, true)
end

function ShopPosterCtrl:tryPlayPlayerAni()
	if not pg.me:FALL_ST() and not pg.me:ABILITY_ST() and not pg.me:CLIMB_ST() then
		-- block empty
	end
end

function ShopPosterCtrl:destroy()
	pg.game.camera:cancelBlendToFixedWithTarget(0.5)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.FuncMenu, false)

	if self.controlPet then
		pg.me:requestSwitchToPet(Const.CLIENT_SWITCH_REASON.ShopPoster)
	end

	self:destroyGesture()
	self.view.imgList:UnRegisterToScrollEndEvent(self.scrollEnd)
	pg.me:stopAnimation(PlayableConst.Show_Pose03_Loop)

	if pg.game.shop.interactShopPosterEvent then
		pg.game.shop.interactShopPosterEvent[self.posterStaticId](true, self.posterStaticId)
	end

	self.posterStaticId = nil
end

function ShopPosterCtrl:addListener()
	function self.view.imgList.luaRenderItem(button, index, data)
		self:renderImgItem(button, index, data)
	end

	function self.view.listPointUList.luaRenderItem(button, index, data)
		self:renderBottomIndexItem(button, index, data)
	end

	function self.view.btnLeftUButton.luaClick()
		self:loadPage(true)
	end

	function self.view.btnRightUButton.luaClick()
		self:loadPage(false)
	end

	local switchBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "switchBind")

	switchBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftStickMove
	switchBind.isVirtual = true
	switchBind.priority = 10000

	function switchBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			local newDirection = inputInfo.valueVec2.x > 0 and 1 or -1

			if newDirection ~= self.switchDirection then
				if newDirection > 0 then
					self.view.btnRightUButton.luaClick()
				elseif newDirection < 0 then
					self.view.btnLeftUButton.luaClick()
				end
			end

			self.switchDirection = newDirection
		elseif inputInfo.phase == "Canceled" then
			self.switchDirection = 0
		end

		return true
	end

	self:bindHotKeyPerform("Raw/GamepadButtonSouth", function()
		self:close()
	end)
end

function ShopPosterCtrl:initGesture()
	fingerGestures.Active()
	fingerGestures.EnableTwist(false)
	fingerGestures.EnablePinch(true)

	function fingerGestures.luaOnSwipeEnd(gesture)
		self:loadPage(gesture.swipeVector[1] > 0)
	end
end

function ShopPosterCtrl:destroyGesture()
	fingerGestures.luaOnSwipeEnd = nil

	fingerGestures.DeActive()
end

function ShopPosterCtrl:showPictures(imgUrls)
	self.curPage = 0
	self.imgUrlsRealCount = #imgUrls
	self.imgUrlsCount = self.imgUrlsRealCount * 2

	local imgData = self.model:getGroupImgData(imgUrls)

	self.view.imgList:SetList(imgData)

	for i = 1, #imgUrls do
		self.view.imgList:AddElement(imgData[i])
	end

	self.view.listPointUList:SetList(self.model:getGroupBottomIndexData(self.imgUrlsRealCount))

	if self.imgUrlsRealCount == 1 then
		self.view.root:TryChangePage("showPre", 0)
		self.view.root:TryChangePage("showNxt", 0)
	else
		self.view.root:TryChangePage("showPre", 1)
		self.view.root:TryChangePage("showNxt", 1)
	end

	self:refreshConsoleBarState()
end

function ShopPosterCtrl:renderImgItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	local imgPosterUImage = objectReference:GetRefValue("imgPosterUImage")
	local arr = string.split(data.url, ".")
	local s = string.sub(arr[1], 2)

	imgPosterUImage.imageId = s

	function btnCloseUButton.luaClick()
		pg.global.ui:close(UIConst.UI_ID_SHOP_POSTER)
	end
end

function ShopPosterCtrl:renderBottomIndexItem(button, index, data)
	local pageIndex = self.curPage % self.imgUrlsRealCount

	button:TryChangePage("light", index == pageIndex and 1 or 0)

	function button.luaClick()
		self:goToPageByIndex(index)
	end
end

function ShopPosterCtrl:goToPageByIndex(index)
	self.curPage = index

	self.view.imgList:GoToIndex(index)

	local buttons = self.view.listPointUList:GetAllButtons()

	for i = 0, buttons.Length - 1 do
		self:renderBottomIndexItem(buttons[i], i)
	end
end

function ShopPosterCtrl:adjustBtnState()
	self.view.root:TryChangePage("showPre", 1)
	self.view.root:TryChangePage("showNxt", 1)
end

function ShopPosterCtrl:loadPage(isPrev)
	if self.scrolling then
		return
	end

	if self.imgUrlsRealCount == 1 then
		return
	end

	self.scrolling = true

	if isPrev then
		if self.curPage == 0 then
			self.curPage = self.imgUrlsCount / 2

			self.view.imgList:GoToIndex(self.curPage, true)
		end

		self:goToPageByIndex(self.curPage - 1)
	else
		self:goToPageByIndex(self.curPage + 1)
	end
end

function ShopPosterCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function ShopPosterCtrl:refreshConsoleBarState()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_Pb_Shop_Poster_Scroll", self.imgUrlsRealCount and self.imgUrlsRealCount > 1)
end

return ShopPosterCtrl
