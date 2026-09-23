-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Avatar\\Component\\FaceComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local FaceComponent = Class.LightClass("FaceComponent", UIComponent)
local avatarFace = pg.global.avatarMgr.avatarFace
local FACE_SERIALIZATION_SENTINEL_SLIDER_VALUE = -50
local FACE_SERIALIZATION_SENTINEL_OFFSET = 0.01

function FaceComponent:findObjects()
	return
end

function FaceComponent:initView()
	self.presetKey = self.ctrl.presetKey
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.sortedGroup = {}
	self.sortedKind = {}

	self:sortConfig()
end

function FaceComponent:addListener()
	function self.view.operationUList.luaRenderItem(button, index, data)
		if data.tIndex == 0 then
			local curValue = avatarFace:GetReactionValue(data.key)

			AvatarUtils.renderSlider(button, data, curValue, function(value)
				local editValue = value == FACE_SERIALIZATION_SENTINEL_SLIDER_VALUE and value + FACE_SERIALIZATION_SENTINEL_OFFSET or value

				avatarFace:EditReactionData(data.key, editValue)
				self.ctrl.bubbleComponent:setNormalValue(value, data.displayName)
				self.ctrl.bubbleComponent:show()
			end, function()
				avatarFace:FinishEditReactionData(data.key)
				self.ctrl:refreshButtonState()
				self.ctrl.bubbleComponent:hide()
			end, function()
				avatarFace:StartEditReactionData(data.key)
			end)
		end
	end
end

function FaceComponent:onDestroy()
	self.avatarScene = nil
	self.sortedGroup = nil
	self.sortedKind = nil
end

function FaceComponent:sortConfig()
	local facePresetKey = AvatarUtils.getCurrentPartAssetId(self.avatarScene, self.presetKey, "face")
	local AvatarFaceData = require(string.format("Data.Avatar.face.face_%s_data", facePresetKey))

	self.originConfig = Utils.deepCopyTable(AvatarFaceData)
	self.sortedGroup = AvatarUtils.getSortedGroup(self.originConfig)
	self.sortedKind = AvatarUtils.getSortedKind(self.originConfig)
end

function FaceComponent:onEnterPage()
	self:addListener()
	ClientTextUtils.setText(self.view.titleShadowUSDFText, pg.getGameString("CREATE_PLAYER_FACE"))
	self.view.rootUComponent:TryChangePage("Info", "Normal")
	self.view.firstSortUList:SetList(self.sortedGroup)

	local res, btn = self.view.firstSortUList:TryGetChildAt(0)

	if res then
		btn:OnClickSimulate()
	end

	self.view.firstSortUList:GoToIndex(0, true)
	self.avatarScene:setAvatarCameraModeCloseHead()

	local entity = self.avatarScene:getCurEntity()

	if entity and entity.eModel then
		local modelView = entity.eModel.modelModelView

		if NotNil(modelView) then
			modelView:RefreshFaceSkeletonOnly()
		end
	end
end

function FaceComponent:onExitPage()
	return
end

function FaceComponent:onFirstSortSelected(key)
	self.view.secondSortUList:SetList(self.sortedKind[key])

	local res, btn = self.view.secondSortUList:TryGetChildAt(0)

	if res then
		btn:OnClickSimulate()
	end

	self.view.secondSortUList:GoToIndex(0, true)
end

function FaceComponent:onSecondSortSelected(key1, key2)
	local reactions = self.model:getReactions(self.originConfig, key1, key2)

	self.view.operationUList:SetList(reactions)

	local kindData = self.model:getKindData(self.originConfig, key1, key2)

	self:highLight(kindData.highLightName)
end

function FaceComponent:highLight(meshName)
	local entity = self.avatarScene:getCurEntity()

	entity.eModel.shaderView:HighLight(meshName)
end

function FaceComponent:refreshComponent()
	self.view.operationUList:RefreshList()
end

return FaceComponent
