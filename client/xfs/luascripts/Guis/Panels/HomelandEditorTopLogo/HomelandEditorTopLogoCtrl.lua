-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandEditorTopLogo\\HomelandEditorTopLogoCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local TopLogoHelper = require("Guis.Panels.TopLogo.TopLogoHelper")
local AddressDataConst = require("Const.AddressDataConst")
local TopLogoHomeEditor = require("Guis.Panels.TopLogo.Node.TopLogoHomeEditor")
local HomelandEditorTopLogoCtrl = Class.LightClass("HomelandEditorTopLogoCtrl", UICtrl)
local PreloadTopLogoResIds = {
	AddressDataConst.HOME_EDITOR_TOPLOGO_RESID
}

function HomelandEditorTopLogoCtrl:ctor()
	UICtrl.ctor(self)

	self.topLogoDict = {}
	self.topLogoHelper = TopLogoHelper.new(self)
end

function HomelandEditorTopLogoCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.topLogoRoot = self.view.transform:Find("TopLogoRoot"):GetComponent("TopLogoRoot")

	pg.global.uiMgr:SetTopLogoRoot(self.topLogoRoot)
	self.topLogoHelper:init(self.view, self.topLogoRoot, {
		preloadTopLogoResIds = PreloadTopLogoResIds
	})
	self:initOrnamentTopLogos()

	if self.topLogoTimer then
		self:killTimer(self.topLogoTimer)
	end

	self.topLogoTimer = self:startTimer(function()
		self:updateOrnamentTopLogo()
	end, 0.2, true)
end

function HomelandEditorTopLogoCtrl:onDestroy()
	if self.topLogoTimer then
		self:killTimer(self.topLogoTimer)

		self.topLogoTimer = nil
	end

	for _, topLogoInfo in pairs(self.topLogoDict) do
		topLogoInfo.ent:destroyHomeEditorTopLogoItem()
	end

	self.topLogoHelper:destroy()
end

function HomelandEditorTopLogoCtrl:initOrnamentTopLogos()
	for _, entity in pairs(pg.game.home.homeEntities) do
		if entity.createHomeEditorTopLogoItem then
			entity:createHomeEditorTopLogoItem()
		end
	end

	for _, entity in pairs(pg.game.home.virtualHomeEntities) do
		if entity.createHomeEditorTopLogoItem then
			entity:createHomeEditorTopLogoItem()
		end
	end
end

function HomelandEditorTopLogoCtrl:createTopLogoItem(ornamentId, ornamentEnt)
	if not ornamentId or ornamentId == 0 then
		return nil
	end

	local homeEditorTopLogoItem = TopLogoHomeEditor.new(ornamentEnt, self.topLogoHelper)

	self:registerOrnament(ornamentEnt.ornamentId, ornamentEnt, homeEditorTopLogoItem)

	return homeEditorTopLogoItem
end

function HomelandEditorTopLogoCtrl:destroyTopLogoItem(ornamentId)
	if not ornamentId or ornamentId == 0 then
		return
	end

	local topLogoInfo = self.topLogoDict[ornamentId]

	if not topLogoInfo then
		return
	end

	self:unregisterOrnament(ornamentId)

	local homeEditorTopLogoItem = topLogoInfo.topLogoItem

	homeEditorTopLogoItem:destroy()
end

function HomelandEditorTopLogoCtrl:registerOrnament(ornamentId, ent, topLogoItem)
	self.topLogoDict[ornamentId] = {
		ent = ent,
		topLogoItem = topLogoItem
	}
end

function HomelandEditorTopLogoCtrl:unregisterOrnament(ornamentId)
	self.topLogoDict[ornamentId] = nil
end

function HomelandEditorTopLogoCtrl:onEditModeChanged()
	for _, topLogoInfo in pairs(self.topLogoDict) do
		topLogoInfo.ent:forceRefreshHomeEditorTopLogo()
	end
end

function HomelandEditorTopLogoCtrl:updateOrnamentTopLogo()
	if not self:checkUIVisible() then
		return
	end

	if not pg.game.home.editor.isInBuildMode then
		return
	end

	local cameraPos = pg.game.home.editor.rootCameraMode.editorCamera:getPosition()
	local range = 15

	for _, topLogoInfo in pairs(self.topLogoDict) do
		topLogoInfo.ent:updateHomeEditorTopLogo(cameraPos, range)
	end
end

return HomelandEditorTopLogoCtrl
