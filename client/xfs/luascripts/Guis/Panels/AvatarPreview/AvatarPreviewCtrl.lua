-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarPreview\\AvatarPreviewCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local PlayableConst = require("Common.Const.PlayableConst")
local UICtrl = require("Guis.UICtrl")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AppearanceData = require("Data.appearance_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local Const = require("Common.Const.Const")
local AvatarPreviewCtrl = Class.LightClass("AvatarPreviewCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

AvatarPreviewCtrl.messages = {}

function AvatarPreviewCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.entityId = info.presetKey
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
end

function AvatarPreviewCtrl:addListener()
	function self.view.backUButton.luaClick()
		self:closePanel()
	end

	function self.view.tabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local nameUText = objectReference:GetRefValue("nameUText")

		ClientTextUtils.setText(nameUText, data.text)
	end

	function self.view.tabUList.luaClick(button, data)
		self.view.rootUComponent:TryChangePage("Preview", data.pageIdx)

		local presetData = self.avatarScene:getPresetData()

		if data.pageIdx == 0 then
			ClientTextUtils.setText(self.view.titleShadowUSDFText, pg.getGameString("APPEARANCE_CLOTHES"))

			local suitList = self.model:getSuitList(presetData.body)

			self.view.selectUList:SetList(suitList)

			local suitId = self.avatarScene:getCurSuitId(self.entityId)

			for index, suitInfo in ipairs(suitList) do
				if suitInfo.suitId == suitId then
					local res, tabBtn = self.view.selectUList:TryGetChildAt(index - 1)

					if res then
						tabBtn:OnClickSimulate()
					end

					break
				end
			end
		elseif data.pageIdx == 1 then
			ClientTextUtils.setText(self.view.titleShadowUSDFText, pg.getGameString("CREATE_PLAYER_ANIMATION"))

			local actionList = self.model:getAnimationList(presetData.body)

			self.view.actionUList:SetList(actionList)

			local res, tabBtn = self.view.actionUList:TryGetChildAt(0)

			if res then
				tabBtn:OnClickSimulate()
			end
		end
	end

	function self.view.selectUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		if data.icon then
			iconUImage.url = data.icon

			button:TryChangePage("State", "Normal")
		else
			button:TryChangePage("State", "Null")
		end
	end

	function self.view.selectUList.luaClick(button, data)
		if not data.suitId then
			self:unEquipSuit()
		else
			self:equipSuit(data.suitId)
		end

		if data.name then
			self.view.informationUWidget:SetActiveFastest(true)
			ClientTextUtils.setText(self.view.infoNameUText, pg.getLocalizationText(data.name))
		else
			self.view.informationUWidget:SetActiveFastest(false)
		end
	end

	function self.view.actionUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		if data.icon then
			iconUImage.url = data.icon

			button:TryChangePage("State", "Normal")
		else
			button:TryChangePage("State", "Null")
		end
	end

	function self.view.actionUList.luaClick(button, data)
		if self.view.actionUList.selectedItem == data then
			return
		end

		self.view.informationUWidget:SetActiveFastest(false)

		if not data.state then
			self:stopAnimation()
		else
			self:playAnimation(data.state)
		end

		if data.name then
			self.view.informationUWidget:SetActiveFastest(true)
			ClientTextUtils.setText(self.view.infoNameUText, pg.getLocalizationText(data.name))
		else
			self.view.informationUWidget:SetActiveFastest(false)
		end
	end

	function self.view.nextUButton.luaClick()
		self:closePanel()
	end

	if not pg.me then
		self.view.backgroundSelectorUSelector:SetActiveFastest(false)
	else
		AvatarUtils.renderBackGroundSwitchSelector(self.view.backgroundSelectorUSelector, true)
	end
end

function AvatarPreviewCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.avatarScene = nil
end

function AvatarPreviewCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.avatarScene:addCameraZoomKeyBinding(self.view.gameObject)
end

function AvatarPreviewCtrl:onShow()
	self:refreshPage()
	self.avatarScene:setAvatarCameraModeFar()
end

function AvatarPreviewCtrl:onHide()
	return
end

function AvatarPreviewCtrl:onVisibleChange(visible)
	if visible then
		self.avatarScene:registerGesture(self.uid, {
			maskRayBoxTrans = self.view.maskRayBoxTrans
		})
	else
		self.avatarScene:unRegisterGesture(self.uid)
	end
end

function AvatarPreviewCtrl:closePanel()
	local presetData = self.avatarScene:getPresetData()
	local suitId = presetData.defaultSuit
	local params = {
		entityId = self.entityId
	}

	for _, clothesId in ipairs(AppearanceSuitData[suitId].appearanceList) do
		table.insert(params, {
			isApply = true,
			clothesId = clothesId
		})
	end

	self.avatarScene:changeClothes(params)
	self:stopAnimation()
	self:dismiss()
end

function AvatarPreviewCtrl:refreshPage()
	local tabList = self.model:getTabList()

	self.view.tabUList:SetList(tabList)

	local res, btn = self.view.tabUList:TryGetChildAt(0)

	if res then
		btn:OnClickSimulate()
	end
end

function AvatarPreviewCtrl:unEquipSuit()
	local entity = self.avatarScene:getEntity(self.entityId)
	local params = {}

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId = self.avatarScene:getCurClothesId(self.entityId, partId)

		if clothesId then
			table.insert(params, {
				isApply = false,
				clothesId = clothesId
			})

			entity.curShow.customShow[partId] = 0
		end
	end

	params.entityId = self.entityId

	self.avatarScene:changeClothes(params)
end

function AvatarPreviewCtrl:equipSuit(suitId)
	local entity = self.avatarScene:getEntity(self.entityId)
	local params = {}

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId = self.avatarScene:getCurClothesId(self.entityId, partId)

		if clothesId then
			table.insert(params, {
				isApply = false,
				clothesId = clothesId
			})

			entity.curShow.customShow[partId] = 0
		end
	end

	local suitData = AppearanceSuitData[suitId] or {}

	for _, clothesId in ipairs(suitData.appearanceList) do
		table.insert(params, {
			isApply = true,
			clothesId = clothesId
		})

		local partId = AppearanceData[clothesId].partId

		entity.curShow.customShow[partId] = clothesId
	end

	params.entityId = self.entityId

	self.avatarScene:changeClothes(params)
end

function AvatarPreviewCtrl:playAnimation(state)
	local entity = self.avatarScene:getEntity(self.entityId)

	entity:playAnimation(PlayableConst[state], true, nil, nil, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
end

function AvatarPreviewCtrl:stopAnimation()
	local entity = self.avatarScene:getEntity(self.entityId)
	local curState = entity:getCurrentPlayableState(PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

	if curState and curState.Key ~= PlayableConst.Show_Idle then
		curState:Stop()
	end
end

return AvatarPreviewCtrl
