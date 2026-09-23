-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Spectate\\Component\\SpectateMinMapComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local SpectateMinMapComponent = Class.LightClass("SpectateMinMapComponent", UIComponent)
local MiniMapV2UIComponent = require("Guis.Panels.HudV2.BaseComponent.MiniMapV2UIComponent")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local LuaUIUtils = require("Utils.LuaUIUtils")

SpectateMinMapComponent.messages = {
	[MessageName.SYNC_TEAM_INFO] = {
		"refreshTeamInfo",
		true
	},
	[MessageName.TEAM_ENTER_DUNGEON] = {
		"refreshTeamInfo",
		true
	},
	[MessageName.CHANGE_MAP_LAYER_DATA] = {
		"onChangeMapLayerData",
		true
	},
	[MessageName.ON_DYNAMIC_MARK_STATUS_CHANGED] = {
		"onDynamicMarkStatusChanged",
		true
	},
	[MessageName.ON_MAP_MARK_UNBIND_ENTITY] = {
		"onMapMarkUnbindEntity",
		true
	}
}

function SpectateMinMapComponent:ctor(ctrl)
	UIComponent.ctor(self, ctrl, nil, {
		needLoadRes = true
	})
	self:findObjects()
end

function SpectateMinMapComponent:findObjects()
	self.miniMapUContainer = self.view.objectReference:GetRefValue("miniMapUContainer")

	self.miniMapUContainer:LoadDefaultUrlManually(function(widget)
		if not self.view or not self.miniMapUContainer or IsNil(self.miniMapUContainer.content) then
			return
		end

		self.miniMapUContainerReference = self.miniMapUContainer.content:GetComponent("ObjectReference")
		self.miniMapUComponent = self.miniMapUContainerReference:GetRefValue("miniMapUComponent")

		self:initView()
		pg.global.ui:registerComponentMessages(self)
	end)
end

function SpectateMinMapComponent:initView()
	self.miniMapComponent = MiniMapV2UIComponent.new(self.ctrl, self.miniMapUComponent, {
		needLoadRes = false
	})

	self:disableOpenMapButtons()
	self:hidePlayerArrow()
	self:refreshTeamInfo()
	self:onRefreshGameCountDown()
end

function SpectateMinMapComponent:disableOpenMapButtons()
	local m = self.miniMapComponent

	if not m then
		return
	end

	local function noop()
		return
	end

	if m.buttonUButton then
		m.buttonUButton.luaClick = noop
	end

	if m.buttonArrowUButton then
		m.buttonArrowUButton.luaClick = noop
	end

	if m.buttonWeatherUButton then
		m.buttonWeatherUButton.luaClick = noop
	end
end

function SpectateMinMapComponent:hidePlayerArrow()
	local m = self.miniMapComponent

	if not m then
		return
	end

	m.forceHidePlayerArrow = true

	if m.playerArrowTransform then
		LuaUIUtils.setUIViewVisible(m.playerArrowTransform, false)
	end
end

function SpectateMinMapComponent:refreshTeamInfo(param)
	if self.miniMapComponent then
		self.miniMapComponent:loadMovingTargetMark()
	end
end

function SpectateMinMapComponent:onChangeMapLayerData(info)
	if self.view and self.miniMapComponent then
		self.miniMapComponent:onChangeMapLayerData()
	end
end

function SpectateMinMapComponent:onRefreshBranchLine()
	if self.miniMapComponent == nil then
		return
	end

	self.miniMapComponent:refreshBranchLine()
end

function SpectateMinMapComponent:onRefreshGameCountDown()
	if self.miniMapComponent then
		self.miniMapComponent:refreshGameCountDown()
	end
end

function SpectateMinMapComponent:onDynamicMarkStatusChanged(info)
	if self.miniMapComponent then
		self.miniMapComponent:onDynamicMarkStatusChanged(info)
	end
end

function SpectateMinMapComponent:onMapMarkUnbindEntity(info)
	if self.miniMapComponent then
		self.miniMapComponent:onMapMarkUnbindEntity(info)
	end
end

function SpectateMinMapComponent:onDestroy()
	self.miniMapComponent = nil
	self.miniMapUComponent = nil
	self.miniMapUContainer = nil
end

function SpectateMinMapComponent:openMap()
	if pg.me == nil or pg.me.space == nil then
		return
	end

	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.Map) then
		return
	end

	if pg.game.map:checkValidScene(pg.game.map:convertSceneId(pg.me.space.sceneId)) == true then
		pg.global.ui.map:open()
	end
end

return SpectateMinMapComponent
