-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\Component\\WorkShopHomeComponent.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local WorkShopCostumeDesignComponent = require("Guis.Panels.WorkShopDesign.Component.WorkShopCostumeDesignComponent")
local WorkShopHairDesignComponent = require("Guis.Panels.WorkShopDesign.Component.WorkShopHairDesignComponent")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local FunctionEnum = require("Data.function_unlock_enum")
local WorkShopHomeComponent = Class.LightClass("WorkShopHomeComponent", UIComponent)

function WorkShopHomeComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.funcList = self.objectReference:GetRefValue("funcList")
	self.txtTips = self.objectReference:GetRefValue("txtTips")
end

function WorkShopHomeComponent:initView()
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
end

function WorkShopHomeComponent:onEnterPage()
	self:addListener()
	self:refreshHomePage()
end

function WorkShopHomeComponent:onLeavePage()
	self:removeListener()
end

function WorkShopHomeComponent:addListener()
	function self.funcList.luaRenderItem(button, index, data)
		local oc = button:GetComponent("ObjectReference")
		local txtTitle = oc:GetRefValue("txtTitle")
		local txtDetail = oc:GetRefValue("txtDetail")

		button:TryChangePage("Type", data.type)
		button:TryChangePage("Bg", data.bg)
		ClientTextUtils.setText(txtTitle, pg.getLocalizationText(data.name))
	end

	function self.funcList.luaClick(button, data)
		if string.isNilOrEmpty(data.funcName) or not self[data.funcName] then
			return
		end

		self[data.funcName](self, data.type)
	end
end

function WorkShopHomeComponent:removeListener()
	self.funcList.luaRenderItem = nil
	self.funcList.luaClick = nil
end

function WorkShopHomeComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function WorkShopHomeComponent:refreshHomePage()
	local funcList = {
		{
			bg = "Big",
			funcName = "func_OpenFaceDesign",
			name = pg.getGameString("APPEARANCE_FACE"),
			type = AvatarUtils.DESIGN_TYPE.FACE
		},
		{
			bg = "Small",
			funcName = "func_OpenHairDesign",
			name = pg.getGameString("APPEARANCE_HAIR"),
			type = AvatarUtils.DESIGN_TYPE.HAIR
		},
		{
			bg = "Small",
			funcName = "func_openCostumeDesign",
			name = pg.getGameString("APPEARANCE_CLOTHES"),
			type = AvatarUtils.DESIGN_TYPE.COSTUME
		}
	}

	self.funcList:SetList(funcList)
end

function WorkShopHomeComponent:func_OpenHairDesign(designType)
	if self:isHairEmpty() then
		pg.global.ui.tips:showTextTip(pg.getGameString("EMPTY_HAIR"))

		return
	end

	AvatarUtils.cancelHairTie()
	self:showCurEntity(true)
	pg.global.ui:open(UIConst.UI_ID_WORKSHOP_DESIGN, {
		type = designType,
		component = WorkShopHairDesignComponent
	}, function()
		self:showCurEntity(true)
		self.avatarScene:setAvatarCameraModeCloseHead()
	end, function()
		self:showCurEntity(false)
	end)
end

function WorkShopHomeComponent:isHairEmpty()
	local AppearancePointEnum = require("Data.appearance_point_enum")
	local entity = self.avatarScene:getCurEntity()

	if not entity or not entity.getAppearanceConfigId then
		return false
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local configId = entity:getAppearanceConfigId(partId, true)

		if configId and configId ~= 0 then
			return false
		end
	end

	return true
end

function WorkShopHomeComponent:func_OpenFaceDesign(designType)
	local info = {
		isDesignMode = true,
		avatarType = AvatarUtils.AVATAR_TYPE.FACE,
		presetKey = pg.game.avatar:getPresetKey(pg.me),
		designType = designType
	}

	pg.global.ui:open(UIConst.UI_ID_AVATAR, info, function()
		self:showCurEntity(true)
		self.avatarScene:setAvatarCameraModeCloseHead()
	end, function()
		self:showCurEntity(false)
	end)
end

function WorkShopHomeComponent:func_openCostumeDesign(designType)
	if not pg.me:checkFunctionUnlock(FunctionEnum.APPEARANCE_COSTUME_CUSTOM) then
		pg.global.showBubbleMessageRaw(LuaUIUtils.getFunctionUnlockDesc(FunctionEnum.APPEARANCE_COSTUME_CUSTOM, true), 3)

		return
	end

	self:showCurEntity(true)
	self.avatarScene:hideEntityWithId(self.ctrl.curPresetKey)
	pg.global.ui:open(UIConst.UI_ID_WORKSHOP_DESIGN, {
		type = designType,
		component = WorkShopCostumeDesignComponent
	}, function()
		self:showCurEntity(true)
	end, function()
		self:showCurEntity(false)
	end)
end

function WorkShopHomeComponent:showCurEntity(active)
	if not self.ctrl then
		return
	end

	if active then
		self.avatarScene:showAvatar(self.ctrl.curPresetKey)
		self.ctrl:delayRefreshDecal()
	else
		self.avatarScene:hideEntityWithId(self.ctrl.curPresetKey)
	end
end

return WorkShopHomeComponent
