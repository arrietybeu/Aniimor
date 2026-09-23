-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Avatar\\Component\\BodyComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientConst = require("Const.ClientConst")
local BodyComponent = Class.LightClass("BodyComponent", UIComponent)
local avatarBody = pg.global.avatarMgr.avatarBody

function BodyComponent:findObjects()
	return
end

function BodyComponent:initView()
	self.presetKey = self.ctrl.presetKey
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.sortedGroup = {}
	self.sortedKind = {}

	self:sortConfig()
end

function BodyComponent:addListener()
	function self.view.operationUList.luaRenderItem(button, index, data)
		if data.tIndex == 0 then
			if data.key == "body_size" then
				local entity = self.avatarScene:getCurEntity()
				local curValue = (entity:getModelScale() - 1) / 0.0003

				AvatarUtils.renderSlider(button, data, curValue, function(value)
					avatarBody:EditBodyScale(value)
					self.ctrl.bubbleComponent:setNormalValue(value, data.displayName)
					self.ctrl.bubbleComponent:show()
				end, function()
					avatarBody:FinishEditBodyScale(function()
						return
					end)
					self.ctrl:refreshButtonState()
					self.ctrl.bubbleComponent:hide()
				end, function()
					local modelScale = entity:getModelScale()

					avatarBody:StartEditBodyScale(data.key, modelScale, function(val)
						entity:setModelScale(ClientConst.MODEL_SCALE_KEY.AVATAR, val)
						avatarBody:StoreBodySize(val)
						self.avatarScene:adjustCameraConfigByBodySize()
					end)
				end)
			else
				local curValue = avatarBody:GetReactionValue(data.key)

				AvatarUtils.renderSlider(button, data, curValue, function(value)
					avatarBody:EditReactionData(data.key, value)
					self.ctrl.bubbleComponent:setNormalValue(value, data.displayName)
					self.ctrl.bubbleComponent:show()
				end, function()
					avatarBody:FinishEditReactionData(data.key)
					self.ctrl:refreshButtonState()
					self.ctrl.bubbleComponent:hide()
				end, function()
					avatarBody:StartEditReactionData(data.key)
				end)
			end
		end
	end
end

function BodyComponent:onDestroy()
	self.presetKey = nil
	self.avatarScene = nil
	self.sortedGroup = nil
	self.sortedKind = nil
end

function BodyComponent:sortConfig()
	local bodyPresetKey = AvatarUtils.getCurrentPartAssetId(self.avatarScene, self.presetKey, "body")
	local AvatarBodyData = require(string.format("Data.Avatar.body.body_%s_data", bodyPresetKey))

	self.originConfig = Utils.deepCopyTable(AvatarBodyData)
	self.sortedGroup = AvatarUtils.getSortedGroup(self.originConfig)
	self.originConfig["-1004600355"].kindList.body_size = {
		key = "body_size",
		order = -1,
		displayName = pg.getGameString("BODY_SIZE_TEXT_1"),
		reactionList = {
			{
				key = "body_size",
				operation = {
					maxValue = 100,
					tIndex = 0,
					minValue = -100,
					displayName = pg.getGameString("BODY_SIZE_TEXT_2")
				}
			}
		}
	}
	self.sortedKind = AvatarUtils.getSortedKind(self.originConfig)
end

function BodyComponent:onEnterPage()
	self:addListener()
	ClientTextUtils.setText(self.view.titleShadowUSDFText, pg.getGameString("CREATE_PLAYER_BODY"))
	self.view.rootUComponent:TryChangePage("Info", "Normal")
	self.view.firstSortUList:SetList(self.sortedGroup)

	local res, btn = self.view.firstSortUList:TryGetChildAt(0)

	if res then
		btn:OnClickSimulate()
	end

	self.view.firstSortUList:GoToIndex(0, true)
	self.avatarScene:setAvatarCameraModeFar()
end

function BodyComponent:onExitPage()
	return
end

function BodyComponent:onFirstSortSelected(key)
	self.view.secondSortUList:SetList(self.sortedKind[key])

	local res, btn = self.view.secondSortUList:TryGetChildAt(0)

	if res then
		btn:OnClickSimulate()
	end

	self.view.secondSortUList:GoToIndex(0, true)
end

function BodyComponent:onSecondSortSelected(key1, key2)
	self.view.rootUComponent:TryChangePage("info", "Body")

	local reactions = self.model:getReactions(self.originConfig, key1, key2)

	self.view.operationUList:SetList(reactions)
end

function BodyComponent:refreshComponent()
	self.view.operationUList:RefreshList()
end

return BodyComponent
