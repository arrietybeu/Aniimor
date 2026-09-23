-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Avatar\\Component\\HairComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local lume = require("Core.Common.lume")
local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local GlobalData = require("Core.Client.GlobalData")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local AvatarHairResIdToReaction = require("Data.Avatar.avatar_hair_resId_to_reaction")
local AppearancePointEnum = require("Data.appearance_point_enum")
local ItemData = require("Data.item_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HairComponent = Class.LightClass("HairComponent", UIComponent)
local avatarMgr = pg.global.avatarMgr
local avatarHair = pg.global.avatarMgr.avatarHair
local GameConst = CS.FunPlus.WorldX.Const.GameConst

function HairComponent:findObjects()
	return
end

function HairComponent:initView()
	self.presetKey = self.ctrl.presetKey
	self.avatarScene = self.ctrl.avatarScene
	self.originConfig = {}
	self.sortedGroup = {}
	self.isEditingSkeleton = false

	self:sortConfig()
end

function HairComponent:addListener()
	function self.view.operationUList.luaRenderItem(button, index, data)
		local isWhole = self.selectedGroupKey == self.model.HAIR_PART.WHOLE

		if data.tIndex == 0 then
			if isWhole and data.opName == AvatarUtils.OP_NAME.reflectance then
				local curValue = avatarHair:GetReflectance(data.opName)

				AvatarUtils.renderSlider(button, data, curValue, function(value)
					avatarHair:EditSuit(value)
					self.ctrl.bubbleComponent:setNormalValue(value, data.displayName)
					self.ctrl.bubbleComponent:show()
				end, function()
					avatarHair:FinishEditSuit()
					self.ctrl.bubbleComponent:hide()
				end, function()
					avatarHair:StartEditSuit(data.opName)
				end)
			end
		elseif data.tIndex == 2 then
			local colorSet = isWhole and avatarHair:GetWholeColorValue(data.opName) or avatarHair:GetPartColorValue(self.selectedGroupKey, data.opName)

			AvatarUtils.renderColor(button, {
				color = colorSet.color,
				displayName = data.displayName
			}, function()
				self.selectedColorOpName = data.opName

				self:openColorPicker(colorSet.color, self.model.COLOR_TYPE.PURE_COLOR)
			end)
		elseif data.tIndex == 3 then
			local colorSet = isWhole and avatarHair:GetWholeColorValue(data.opName) or avatarHair:GetPartColorValue(self.selectedGroupKey, data.opName)
			local sliderValue = colorSet:GetSliderValue()

			AvatarUtils.renderMultiColor(button, data, colorSet.color, colorSet.rootColor, sliderValue, colorSet.isEnabled, function()
				self.selectedColorOpName = data.opName

				self:tryShowAlert(function()
					avatarHair:AddPartColorCommand(self.selectedGroupKey, isWhole)

					if isWhole then
						local enable = not avatarHair:GetWholeColorValue(data.opName).isEnabled

						avatarHair:SwitchWholeMultiColor(data.opName, enable)
					else
						local enable = not avatarHair:GetPartColorValue(self.selectedGroupKey, data.opName).isEnabled

						avatarHair:SwitchPartMultiColor(self.selectedGroupKey, data.opName, enable)
					end

					avatarHair:UpdatePartColorCommand(self.selectedGroupKey, isWhole)
					self.ctrl:refreshButtonState()
				end, function()
					avatarHair:RemovePartColorCommand()
					self.view.operationUList:RefreshList()
				end)
			end, function()
				self.selectedColorOpName = data.opName

				self:openColorPicker(colorSet.color, self.model.COLOR_TYPE.GRADIENT_COLOR)
			end, function()
				self.selectedColorOpName = data.opName

				self:openColorPicker(colorSet.rootColor, self.model.COLOR_TYPE.GRADIENT_ROOT_COLOR)
			end, function(value)
				self.selectedColorOpName = data.opName

				self:onLowerValueChanged(value)
				avatarHair:UpdatePartColorCommand(self.selectedGroupKey, isWhole)
				self:saveColor()
				self.ctrl:refreshButtonState()
			end, function(value)
				self.selectedColorOpName = data.opName

				self:onUpperValueChanged(value)
				avatarHair:UpdatePartColorCommand(self.selectedGroupKey, isWhole)
				self:saveColor()
				self.ctrl:refreshButtonState()
			end, function()
				avatarHair:AddPartColorCommand(self.selectedGroupKey, isWhole)
			end, function()
				self:tryShowAlert(function()
					return
				end, function()
					avatarHair:RemovePartColorCommand()
					self.view.operationUList:RefreshList()
				end)
			end)
		end
	end

	function self.view.hairSelectUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		button:TryChangePage("State", data.state)

		iconUImage.url = data.icon
	end

	function self.view.hairSelectUList.luaClick(button, data)
		local entity = self.avatarScene:getCurEntity()
		local isWhole = self.selectedGroupKey == self.model.HAIR_PART.WHOLE

		if isWhole then
			local curAssetId = avatarHair:GetAssetId()

			if data.assetId ~= avatarHair:GetAssetId() then
				local param = {
					entityId = self.presetKey
				}
				local fusionData = pg.game.avatar:getFusionData()
				local fusionHairPresetKey = fusionData and fusionData.pickedHairPreset
				local fusionHairAssetId = fusionHairPresetKey and AvatarUtils.getPartAssetIdByPreset(fusionHairPresetKey, "hair")
				local isFusionPresetHair = fusionHairAssetId == data.assetId
				local originAssetId = AvatarUtils.getCurrentPartAssetId(self.avatarScene, self.presetKey, "hair")
				local usePresetModelRes = data.assetId == originAssetId and curAssetId == data.assetId

				for partId = GameConst.PART_HAIR_FRINGE, GameConst.PART_HAIR_PLAIT do
					if isFusionPresetHair then
						local hairResInfo = AvatarUtils.getModelResPart(nil, fusionHairPresetKey, partId)
						local resId = hairResInfo.resId

						if resId ~= "" then
							table.insert(param, {
								isApply = true,
								resId = resId,
								partId = partId
							})
							pg.game.avatar:updateHairSelection(partId, hairResInfo.configId, "hairSelect")
							AppearanceEffectUtils.setAppearance(entity, partId, hairResInfo.configId)
						else
							local curResId = entity.eModel.modelModelView.modelInfo.partModelInfo:GetPartResId(partId)

							table.insert(param, {
								isApply = false,
								resId = curResId
							})
							pg.game.avatar:updateHairSelection(partId, nil, "hairSelect")
							AppearanceEffectUtils.setAppearance(entity, partId, nil)
						end
					elseif usePresetModelRes then
						local hairResInfo = AvatarUtils.getModelResPart(entity, self.presetKey, partId)
						local resId = hairResInfo.resId

						if resId ~= "" then
							table.insert(param, {
								isApply = true,
								resId = resId,
								partId = partId
							})
							pg.game.avatar:updateHairSelection(partId, hairResInfo.configId, "hairSelect")
							AppearanceEffectUtils.setAppearance(entity, partId, hairResInfo.configId)
						else
							local curResId = entity.eModel.modelModelView.modelInfo.partModelInfo:GetPartResId(partId)

							table.insert(param, {
								isApply = false,
								resId = curResId
							})
							pg.game.avatar:updateHairSelection(partId, nil, "hairSelect")
							AppearanceEffectUtils.setAppearance(entity, partId, nil)
						end
					else
						local hairPartList = self.model:getHairPartList(self.presetKey, data.assetId, partId)

						if #hairPartList > 1 then
							local hairPart = hairPartList[2] or {}

							table.insert(param, {
								isApply = true,
								resId = hairPart.res,
								partId = partId
							})
							pg.game.avatar:updateHairSelection(partId, hairPart.id, "hairSelect")
							AppearanceEffectUtils.setAppearance(entity, partId, hairPart.id)
						else
							local resId = entity.eModel.modelModelView.modelInfo.partModelInfo:GetPartResId(partId)

							table.insert(param, {
								isApply = false,
								resId = resId
							})
							pg.game.avatar:updateHairSelection(partId, nil, "hairSelect")
							AppearanceEffectUtils.setAppearance(entity, partId, nil)
						end
					end
				end

				if avatarMgr.globalStack then
					avatarMgr.globalStack:Clear()
				end

				avatarHair:OnHairSuitChanged(param, data.assetId)
				self.ctrl:refreshButtonState()

				if isFusionPresetHair then
					avatarHair:ManualChangeToPresetHair(fusionHairPresetKey, data.assetId)
					entity:refreshAppearanceAttachEffects()
				else
					self.avatarScene:changeHair(param)
					avatarHair:InitColors()
				end

				self:sortConfig(data.id)
				self:refreshSecondSortList()
			end
		elseif self.selectedResId ~= data.res then
			local param = {
				entityId = self.presetKey
			}

			if data.res ~= "" then
				table.insert(param, {
					isApply = true,
					resId = data.res,
					partId = data.partId
				})
				pg.game.avatar:updateHairSelection(data.partId, data.id, "hairSelect")
				AppearanceEffectUtils.setAppearance(entity, data.partId, data.id)
			else
				local res = entity.eModel.modelModelView.modelInfo.partModelInfo:GetPartResId(data.partId)

				table.insert(param, {
					isApply = false,
					resId = res
				})
				pg.game.avatar:updateHairSelection(data.partId, nil, "hairSelect")
				AppearanceEffectUtils.setAppearance(entity, data.partId, nil)
			end

			avatarHair:OnHairPartChanged(self.selectedResId, data.res, data.partId)

			self.selectedResId = data.res
			self.selectedReactionKey = AvatarHairResIdToReaction[self.selectedResId]

			self.ctrl:refreshButtonState()
			self.avatarScene:changeHair(param)

			if self.selectedHairOp == AvatarUtils.HAIR_DESIGN_TYPE.COLOR then
				avatarHair:InitColors()
				self:refreshColorList(self.selectedGroupKey)
			end
		end
	end

	function self.view.rootBoneUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local nameUText = objectReference:GetRefValue("nameUText")

		ClientTextUtils.setText(nameUText, index)
	end

	function self.view.rootBoneUList.luaClick(button, data)
		local boneOpList = {}

		for _, operation in ipairs(data.operations) do
			table.insert(boneOpList, {
				tIndex = 0,
				bone = data.bone,
				operation = operation
			})
		end

		if not Utils.tableIsEmptyOrNil(data.subHair) then
			table.insert(boneOpList, {
				tIndex = 1,
				subHair = data.subHair
			})
		end

		self.view.boneOpUList:SetList(boneOpList)
	end

	function self.view.boneOpUList.luaRenderItem(rootBtn, rootIdx, data)
		if data.tIndex == 0 then
			AvatarUtils.renderOperationCollection(rootBtn, data.operation, function(btn, idx, subData)
				if subData.tIndex == 0 then
					local curValue = avatarHair:GetReactionDataValue(self.selectedReactionKey, data.bone, subData.opName)

					AvatarUtils.renderSlider(btn, subData, curValue, function(value)
						avatarHair:EditReactionData(self.selectedReactionKey, data.bone, subData.opName, value)
						self.ctrl.bubbleComponent:setNormalValue(value, subData.displayName)
						self.ctrl.bubbleComponent:show()
					end, function()
						avatarHair:FinishEditReactionData(self.selectedReactionKey)
						self.ctrl.bubbleComponent:hide()
						self.ctrl:refreshButtonState()
					end, function()
						avatarHair:StartEditReactionData(self.selectedReactionKey)
					end)
				end
			end)
		elseif data.tIndex == 1 then
			local objectReference = rootBtn:GetComponent("ObjectReference")
			local titleUText = objectReference:GetRefValue("titleUText")
			local childBoneUList = objectReference:GetRefValue("childBoneUList")
			local operationUList = objectReference:GetRefValue("operationUList")

			ClientTextUtils.setText(titleUText, pg.getGameString("CREATE_PLAYER_HAIR_BONE"))

			function childBoneUList.luaRenderItem(childBtn, childIdx, childData)
				local objRef = childBtn:GetComponent("ObjectReference")
				local nameUText = objRef:GetRefValue("nameUText")

				ClientTextUtils.setText(nameUText, childIdx)
			end

			function childBoneUList.luaClick(button, childBoneData)
				function operationUList.luaRenderItem(opBtn, opIdx, opData)
					AvatarUtils.renderOperationCollection(opBtn, opData, function(btn, idx, subData)
						if subData.tIndex == 0 then
							local curValue = avatarHair:GetReactionDataValue(self.selectedReactionKey, childBoneData.bone, subData.opName)

							AvatarUtils.renderSlider(btn, subData, curValue, function(value)
								avatarHair:EditReactionData(self.selectedReactionKey, childBoneData.bone, subData.opName, value)
								self.ctrl.bubbleComponent:setNormalValue(value, subData.displayName)
								self.ctrl.bubbleComponent:show()
							end, function()
								avatarHair:FinishEditReactionData(self.selectedReactionKey)
								self.ctrl:refreshButtonState()
								self.ctrl.bubbleComponent:hide()
							end, function()
								avatarHair:StartEditReactionData(self.selectedReactionKey)
							end)
						end
					end)
				end

				operationUList:SetList(childBoneData.operations)
			end

			childBoneUList:SetList(data.subHair)

			local res, btn = childBoneUList:TryGetChildAt(0)

			if res then
				btn:OnClickSimulate()
			end

			childBoneUList:GoToIndex(0)
		end
	end
end

function HairComponent:onDestroy()
	self.avatarScene = nil
end

function HairComponent:tryShowAlert(okCb, cancelCb)
	local isWhole = self.selectedGroupKey == self.model.HAIR_PART.WHOLE
	local prefsKey = "hairEditWarn" .. GlobalData.UserName
	local lastTime = pg.global.prefsCacheUtils:getString(prefsKey)
	local curTime = LuaUIUtils.timeStampToUtcString(Time.secondCache)
	local showAlert = AvatarUtils.checkIsShowAlert(lastTime, curTime)

	if isWhole and showAlert then
		local title = pg.getGameString("RELEASE_WARN")
		local desc = pg.getGameString("CREATE_PLAYER_HAIR_WARN")

		pg.global.showConfirmMsgRaw(title, desc, function()
			if okCb then
				okCb()
			end
		end, nil, function()
			if cancelCb then
				cancelCb()
			end
		end, nil, nil, {
			hint = true,
			hintCb = function(isSelected)
				if isSelected then
					pg.global.prefsCacheUtils:setString(prefsKey, LuaUIUtils.timeStampToUtcString(Time.secondCache))
				end
			end
		})
	elseif okCb then
		okCb()
	end
end

function HairComponent:openColorPicker(color, type)
	local isWhole = self.selectedGroupKey == self.model.HAIR_PART.WHOLE

	self._pendingColorPickerRefresh = true

	avatarHair:AddPartColorCommand(self.selectedGroupKey, isWhole)
	pg.global.ui.colorPicker:open({
		color = color,
		colorValueChangedCb = function(_, colorCode)
			self:onColorPickerValueChanged(colorCode, type)
		end,
		cancelCb = function()
			pg.global.avatarMgr.avatarHair:RevertColorByReactionData()
			avatarHair:RemovePartColorCommand()

			self._pendingColorPickerRefresh = false
		end,
		confirmCb = function()
			self:tryShowAlert(function()
				self:confirmColor()
				avatarHair:UpdatePartColorCommand(self.selectedGroupKey, isWhole)

				self._pendingColorPickerRefresh = false

				self.ctrl:refreshButtonState()
			end, function()
				avatarHair:RemovePartColorCommand()

				self._pendingColorPickerRefresh = false

				self.ctrl:refreshButtonState()
			end)
		end,
		closeCb = function()
			self.ctrl:refreshButtonState()
		end,
		colorAreas = AvatarUtils.getColorAreas(AvatarUtils.COLOR_PANEL.HAIR_COLOR)
	})
end

function HairComponent:onColorPickerValueChanged(colorCode, type)
	local isWhole = self.selectedGroupKey == self.model.HAIR_PART.WHOLE
	local r, g, b, a = lume.color(colorCode)
	local newColor = Color(r, g, b, a)

	if isWhole then
		local colorSet = avatarHair:GetWholeColorValue(self.selectedColorOpName)

		if type == self.model.COLOR_TYPE.PURE_COLOR then
			avatarHair:PreviewWholeColorChange(newColor)
		elseif type == self.model.COLOR_TYPE.GRADIENT_COLOR then
			avatarHair:PreviewWholeColorChange(self.selectedColorOpName, newColor, colorSet.rootColor)
		elseif type == self.model.COLOR_TYPE.GRADIENT_ROOT_COLOR then
			avatarHair:PreviewWholeColorChange(self.selectedColorOpName, colorSet.color, newColor)
		end
	else
		local colorSet = avatarHair:GetPartColorValue(self.selectedGroupKey, self.selectedColorOpName)

		if type == self.model.COLOR_TYPE.PURE_COLOR then
			avatarHair:PreviewPartColorChange(self.selectedGroupKey, self.selectedReactionKey, newColor)
		elseif type == self.model.COLOR_TYPE.GRADIENT_COLOR then
			avatarHair:PreviewPartColorChange(self.selectedGroupKey, self.selectedReactionKey, self.selectedColorOpName, newColor, colorSet.rootColor)
		elseif type == self.model.COLOR_TYPE.GRADIENT_ROOT_COLOR then
			avatarHair:PreviewPartColorChange(self.selectedGroupKey, self.selectedReactionKey, self.selectedColorOpName, colorSet.color, newColor)
		end
	end
end

function HairComponent:onLowerValueChanged(sliderVal)
	local isWhole = self.selectedGroupKey == self.model.HAIR_PART.WHOLE

	if isWhole then
		local colorSet = avatarHair:GetWholeColorValue(self.selectedColorOpName)
		local sliderValue = colorSet:GetSliderValue()
		local newGradientValue = Vector2(sliderVal, sliderValue[2])

		avatarHair:PreviewWholeColorChange(self.selectedColorOpName, newGradientValue)
	else
		local colorSet = avatarHair:GetPartColorValue(self.selectedGroupKey, self.selectedColorOpName)
		local sliderValue = colorSet:GetSliderValue()
		local newGradientValue = Vector2(sliderVal, sliderValue[2])

		avatarHair:PreviewPartColorChange(self.selectedGroupKey, self.selectedReactionKey, self.selectedColorOpName, newGradientValue)
	end
end

function HairComponent:onUpperValueChanged(sliderVal)
	local isWhole = self.selectedGroupKey == self.model.HAIR_PART.WHOLE

	if isWhole then
		local colorSet = avatarHair:GetWholeColorValue(self.selectedColorOpName)
		local sliderValue = colorSet:GetSliderValue()
		local newGradientValue = Vector2(sliderValue[1], sliderVal)

		avatarHair:PreviewWholeColorChange(self.selectedColorOpName, newGradientValue)
	else
		local colorSet = avatarHair:GetPartColorValue(self.selectedGroupKey, self.selectedColorOpName)
		local sliderValue = colorSet:GetSliderValue()
		local newGradientValue = Vector2(sliderValue[1], sliderVal)

		avatarHair:PreviewPartColorChange(self.selectedGroupKey, self.selectedReactionKey, self.selectedColorOpName, newGradientValue)
	end
end

function HairComponent:saveColor()
	local isWhole = self.selectedGroupKey == self.model.HAIR_PART.WHOLE

	if isWhole then
		avatarHair:SaveWholeColor()
	else
		avatarHair:SavePartColor(self.selectedGroupKey)
	end
end

function HairComponent:confirmColor()
	self:saveColor()
	avatarHair:ApplyColor()
	self:refreshColorList(self.selectedGroupKey)
end

function HairComponent:sortConfig(hairId)
	if hairId == -1 then
		self.originConfig = {}
		self.sortedGroup = {}

		return
	end

	if pg.me then
		hairId = hairId or LuaUIUtils.tryGetEntityHairSuitId(pg.me)
	end

	local hairPresetKey
	local hairSuitData = AvatarHairSuitData[hairId] or {}

	if pg.me then
		hairPresetKey = hairSuitData.assetId
	else
		hairPresetKey = hairId and hairSuitData.assetId or AvatarUtils.getCurrentPartAssetId(self.avatarScene, self.presetKey, "hair")
	end

	if hairPresetKey then
		local AvatarHairData = require(string.format("Data.Avatar.hair.hair_%s_data", hairPresetKey))

		self.originConfig = {}

		if AvatarHairData then
			self.originConfig = Utils.deepCopyTable(AvatarHairData)
		end

		self.sortedGroup = AvatarUtils.getSortedGroup(self.originConfig)
	end
end

function HairComponent:onEnterPage()
	AvatarUtils.cancelHairTie()
	self.view.btnHairTieUButton.gameObject:SetActiveEx(false)

	if AvatarUtils.hairAssetIdRecord and AvatarUtils.hairAssetIdRecord ~= -1 then
		-- block empty
	end

	self:addListener()

	local firstSortList = self.model:getHairFirstSortList()

	ClientTextUtils.setText(self.view.titleShadowUSDFText, pg.getGameString("CREATE_PLAYER_HAIR"))
	self.view.firstSortUList:SetList(firstSortList)

	local res, btn = self.view.firstSortUList:TryGetChildAt(0)

	if res then
		btn:OnClickSimulate()
	end

	self.view.firstSortUList:GoToIndex(0, true)
	self.avatarScene:setAvatarCameraModeCloseHead()
	self:refreshComponent()
end

function HairComponent:onExitPage()
	self.view.btnHairTieUButton.gameObject:SetActiveEx(true)

	if self.isEditingSkeleton then
		self:exitEditSkeleton()
	end
end

function HairComponent:enterEditSkeleton()
	local entity = self.avatarScene:getCurEntity()

	if not entity or not entity.eModel then
		return
	end

	local eModel = entity.eModel

	if IsNil(eModel.modelModelView) or IsNil(eModel.modelRoot) then
		return
	end

	eModel.modelModelView:CloseBoneSpring(eModel.modelRoot)

	local playableState = entity:getCurrentPlayableState(PlayableConst.AnimationLayer.HUMAN_LAYER_BASE)

	if playableState then
		playableState:SetSpeed(0)
	end

	self.isEditingSkeleton = true
end

function HairComponent:exitEditSkeleton()
	local entity = self.avatarScene:getCurEntity()

	if not entity or not entity.eModel then
		self.isEditingSkeleton = false

		return
	end

	local eModel = entity.eModel

	if IsNil(eModel.modelModelView) or IsNil(eModel.modelRoot) then
		self.isEditingSkeleton = false

		return
	end

	eModel.modelModelView:OpenBoneSpring(eModel.modelRoot)

	local playableState = entity:getCurrentPlayableState(PlayableConst.AnimationLayer.HUMAN_LAYER_BASE)

	if playableState then
		playableState:SetSpeed(1)
	end

	self.isEditingSkeleton = false
end

function HairComponent:onFirstSortSelected(hairOp)
	self.selectedHairOp = hairOp

	local secondSortList = self.model:getHairSecondList(self.originConfig, hairOp)

	if hairOp == AvatarUtils.HAIR_DESIGN_TYPE.PRESET then
		self.view.rootUComponent:TryChangePage("Info", "Hair")
		self:exitEditSkeleton()
	elseif hairOp == AvatarUtils.HAIR_DESIGN_TYPE.COLOR then
		self.view.rootUComponent:TryChangePage("Info", "Normal")
		self:exitEditSkeleton()
	elseif hairOp == AvatarUtils.HAIR_DESIGN_TYPE.SETTING then
		self.view.rootUComponent:TryChangePage("Info", "HairSkeleton")
		self:enterEditSkeleton()
	end

	self.view.secondSortUList:SetList(secondSortList)

	local isFound = false
	local idx = 0

	for index, data in ipairs(secondSortList) do
		if self.selectedGroupKey == data.key then
			isFound = true
			idx = index - 1

			break
		end
	end

	local res, btn = self.view.secondSortUList:TryGetChildAt(idx)

	if res then
		btn:OnClickSimulate()
	end

	self.view.secondSortUList:GoToIndex(0)
end

function HairComponent:refreshSecondSortList()
	local secondSortList = Utils.deepCopyTable(self.sortedGroup)
	local wholeItem = {
		state = 1,
		key = self.model.HAIR_PART.WHOLE,
		displayName = pg.getGameString("CREATE_PLAYER_HAIR_WHOLE")
	}

	table.insert(secondSortList, 1, wholeItem)
	self.view.secondSortUList:SetList(secondSortList)

	local isFound = false

	for index, data in ipairs(secondSortList) do
		if self.selectedGroupKey == data.key then
			isFound = true

			local res, btn = self.view.secondSortUList:TryGetChildAt(index - 1)

			if res then
				btn:OnClickSimulate()
			end

			self.view.secondSortUList:GoToIndex(index - 1, true)

			break
		end
	end

	if not isFound then
		local res, btn = self.view.secondSortUList:TryGetChildAt(0)

		if res then
			btn:OnClickSimulate()
		end
	end
end

function HairComponent:onSecondSortSelected(hairOp, groupKey)
	self.selectedGroupKey = groupKey

	local partId = tonumber(self.selectedGroupKey)
	local entity = self.avatarScene:getCurEntity()

	self.selectedResId = entity.eModel.modelModelView.modelInfo.partModelInfo:GetPartResId(partId)
	self.selectedReactionKey = AvatarHairResIdToReaction[self.selectedResId]

	if hairOp == AvatarUtils.HAIR_DESIGN_TYPE.PRESET then
		self:refreshHairList(groupKey)
	elseif hairOp == AvatarUtils.HAIR_DESIGN_TYPE.COLOR then
		avatarHair:InitColors()
		self:refreshColorList(groupKey)
		self:highLightPart()
	elseif hairOp == AvatarUtils.HAIR_DESIGN_TYPE.SETTING then
		self:refreshOperationList(groupKey)
	end
end

function HairComponent:refreshHairList(groupKey)
	local isWhole = self.selectedGroupKey == self.model.HAIR_PART.WHOLE
	local partAssetId = avatarHair:GetAssetId()

	if isWhole then
		local hairList = self.model:getHairSuitList(self.presetKey)

		self.view.hairSelectUList:SetList(hairList)

		if partAssetId < 0 then
			self.view.hairSelectUList:SelectItem(0)
			self.view.hairSelectUList:GoToIndex(0, true)
		else
			for index, hairInfo in ipairs(hairList) do
				if hairInfo.assetId == partAssetId then
					self.view.hairSelectUList:SelectItem(index - 1)
					self.view.hairSelectUList:GoToIndex(index - 1, true)

					break
				end
			end
		end
	else
		local partId = self.originConfig[groupKey].partId
		local hairList = self.model:getHairPartList(self.presetKey, partAssetId, partId)

		self.view.hairSelectUList:SetList(hairList)

		for index, hairInfo in ipairs(hairList) do
			if self.selectedResId == hairInfo.res then
				self.view.hairSelectUList:SelectItem(index - 1)
				self.view.hairSelectUList:GoToIndex(index - 1, true)

				break
			end
		end
	end
end

function HairComponent:refreshColorList(groupKey)
	local isWhole = self.selectedGroupKey == self.model.HAIR_PART.WHOLE

	if isWhole then
		local entity = self.avatarScene:getCurEntity()
		local partModelInfo = entity.eModel.modelModelView.modelInfo.partModelInfo
		local colorList = self.model:getHairSuitColorList(self.originConfig, partModelInfo)

		self.view.operationUList:SetList(colorList)
	else
		local colorList = self.model:getHairPartColorList(self.originConfig, groupKey, self.selectedReactionKey)

		self.view.operationUList:SetList(colorList)
	end
end

function HairComponent:highLightPart()
	local isWhole = self.selectedGroupKey == self.model.HAIR_PART.WHOLE

	if isWhole then
		return
	end

	local maxFactor = 1

	avatarHair:HighLightHairPart(self.selectedReactionKey, maxFactor, 1.2)
end

function HairComponent:refreshOperationList(groupKey)
	local reaction = self.model:getHairReaction(self.originConfig, groupKey, self.selectedReactionKey) or {}
	local rootBones = reaction.bones

	if rootBones then
		self.view.rootBoneUList:SetList(rootBones)

		local res, btn = self.view.rootBoneUList:TryGetChildAt(0)

		if res then
			btn:OnClickSimulate()
		else
			self.view.boneOpUList:SetList({})
		end

		self.view.rootBoneUList:GoToIndex(0, true)
	else
		self.view.rootBoneUList:SetList({})
		self.view.boneOpUList:SetList({})
	end
end

function HairComponent:onFirstDesignSelected(data)
	ClientTextUtils.setText(self.view.titleShadowUSDFText, data.displayName)

	local designList = self.model:getHairFirstDesignList()

	for _, designInfo in ipairs(designList) do
		if designInfo.key == data.key then
			self.view.rootUComponent:TryChangePage("Info", designInfo.state)
		end
	end

	if data.key == AvatarUtils.HAIR_DESIGN_TYPE.SETTING then
		self:enterEditSkeleton()
	else
		self:exitEditSkeleton()
	end

	local secondDesignList = self.model:getHairSecondDesignList(self.originConfig, data.key)

	self.view.secondDesignUList:SetList(secondDesignList)

	local res, btn = self.view.secondDesignUList:TryGetChildAt(0)

	if res then
		btn:OnClickSimulate()
	end
end

function HairComponent:onSecondDesignSelected(hairOp, groupKey)
	self:onSecondSortSelected(hairOp, groupKey)
end

function HairComponent:hairPresetLog(notifyToSave)
	local hairCustomData = {}

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local hairCustomDataStr = avatarMgr:GetHairCustomDataString(partId)

		hairCustomData[partId] = {
			configId = self.avatarScene:getCurHairPartId(self.presetKey, partId),
			hairInfo = compressToStr(hairCustomDataStr)
		}
	end

	print(string.format("[hqx] hair custom data log %s : %s", notifyToSave and "notifyToSave" or "", inspect(hairCustomData)))
end

function HairComponent:saveHairPreset()
	local hairSuitId = self.avatarScene:getCurHairSuitId(self.presetKey)

	if not hairSuitId then
		return
	end

	local usedNum, unlockNum, allNum = AvatarUtils.getHairPresetNumInfo(hairSuitId)
	local targetIndex = usedNum < unlockNum and usedNum + 1 or nil

	self.avatarScene:setCurEntityRot(0, 0.5)
	self.avatarScene:setAvatarCameraModeCloseHead()
	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.PRESET_SNAPSHOT)
	pg.game.input:setEnabledViewCtrl(false, ClientConst.ViewControl.PRESET_SNAPSHOT)
	self:hairPresetLog()
	TimerManager.addTimer(self.avatarScene.cameraDuration, function()
		local sizeDelta = Vector2.New(Screen.height, Screen.height)
		local position = Vector2.New(Screen.width / 2 - sizeDelta.x / 2, Screen.height / 2 - sizeDelta.y / 2)

		Utils.captureAndCheckPhoto(Const.PhotoCheckScene.Share, function(_, _, success, imageKey)
			pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.PRESET_SNAPSHOT)
			pg.game.input:setEnabledViewCtrl(true, ClientConst.ViewControl.PRESET_SNAPSHOT)

			if not success then
				return
			end

			pg.global.ui:open(UIConst.UI_ID_WORKSHOP_SAVE_PRESET, {
				title = pg.getGameString("SAVE_PRESET"),
				partName = ItemData[hairSuitId].itemName,
				usedNum = usedNum,
				unlockNum = unlockNum,
				allNum = allNum,
				confirmCallback = function(presetName)
					self:hairPresetLog(true)

					if targetIndex then
						self:savePresetCallback(targetIndex, presetName, imageKey)
					else
						pg.global.ui:open(UIConst.UI_ID_WORKSHOP_COVER_PRESET, {
							title = pg.getGameString("APPEARANCE_PRESET"),
							configId = hairSuitId,
							designType = AvatarUtils.DESIGN_TYPE.HAIR,
							coverCallback = function(index)
								self:savePresetCallback(index, presetName, imageKey)
							end
						})
					end
				end
			})
		end, position, sizeDelta, 3, false, true)
	end)
end

function HairComponent:savePresetCallback(targetIndex, newName, imageKey)
	local hairCustomData = {}

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local hairCustomDataStr = avatarMgr:GetHairCustomDataString(partId)

		hairCustomData[partId] = {
			configId = self.avatarScene:getCurHairPartId(self.presetKey, partId),
			hairInfo = compressToStr(hairCustomDataStr)
		}
	end

	local hairSuitId = self.avatarScene:getCurHairSuitId(self.presetKey)

	pg.me.delayRecordHairInfo = nil

	pg.me:serverMsg("RPC_CS_SaveHairCustom", hairSuitId, targetIndex, hairCustomData, newName, imageKey or "")
	pg.me:serverMsg("RPC_CS_SetHairCustom", hairSuitId, targetIndex, function(res)
		if not res then
			return
		end

		pg.me:refreshAppearance()

		if self.avatarScene and self.avatarScene.recordInitialAvatarConfig then
			self.avatarScene:recordInitialAvatarConfig()

			self.avatarScene.hasPendingHairDesignChange = false
			self.avatarScene.pendingHairDesignHairId = hairSuitId
		end

		pg.global.ui:close(UIConst.UI_ID_WORKSHOP_COVER_PRESET)
		pg.global.ui:close(UIConst.UI_ID_WORKSHOP_SAVE_PRESET)
		pg.global.ui:close(UIConst.UI_ID_WORKSHOP_COSTUME_STAIN)
		pg.global.ui:close(UIConst.UI_ID_WORKSHOP_DESIGN)
		facade:sendMsgToUI(MessageName.ON_PRESET_SAVE, {
			tabName = "APPEARANCE_HAIR"
		})
		pg.global.ui:close(UIConst.UI_ID_AVATAR)
	end)
end

function HairComponent:refreshSecondDesignList()
	if not self.ctrl.firstDesignData then
		return
	end

	local secondDesignList = self.model:getHairSecondDesignList(self.originConfig, self.ctrl.firstDesignData.key)

	self.view.secondDesignUList:SetList(secondDesignList)

	local isFound = false

	for index, data in ipairs(secondDesignList) do
		if self.selectedGroupKey == data.key then
			isFound = true

			local res, btn = self.view.secondDesignUList:TryGetChildAt(index - 1)

			if res then
				btn:OnClickSimulate()
			end

			self.view.secondDesignUList:GoToIndex(index - 1, true)

			break
		end
	end

	if not isFound then
		local res, btn = self.view.secondDesignUList:TryGetChildAt(0)

		if res then
			btn:OnClickSimulate()
		end
	end
end

function HairComponent:skipRefreshOnVisible()
	return self._pendingColorPickerRefresh == true
end

function HairComponent:refreshCurrentHairPanel()
	local hairOp

	if self.ctrl.isDesignMode then
		hairOp = self.ctrl.firstDesignData and self.ctrl.firstDesignData.key
	else
		hairOp = self.selectedHairOp
	end

	if not hairOp or not self.selectedGroupKey then
		return
	end

	if hairOp == AvatarUtils.HAIR_DESIGN_TYPE.PRESET then
		self:refreshHairList(self.selectedGroupKey)
	elseif hairOp == AvatarUtils.HAIR_DESIGN_TYPE.COLOR then
		avatarHair:InitColors()
		self:refreshColorList(self.selectedGroupKey)
		self:highLightPart()
	elseif hairOp == AvatarUtils.HAIR_DESIGN_TYPE.SETTING then
		self:refreshOperationList(self.selectedGroupKey)
	end
end

function HairComponent:refreshComponent()
	local designHairId = self.ctrl.isDesignMode and self.ctrl.openData and self.ctrl.openData.hairId

	if designHairId then
		local designHairSuitInfo = AvatarHairSuitData[designHairId]
		local designHairAssetId = designHairSuitInfo and designHairSuitInfo.assetId
		local hairCustomDataAssetId = avatarHair:GetHairCustomDataAssetId()
		local isHairBindingMismatch = hairCustomDataAssetId > 0 and hairCustomDataAssetId ~= designHairAssetId

		if designHairAssetId and (avatarHair:GetAssetId() ~= designHairAssetId or isHairBindingMismatch) then
			avatarHair:OnHairSuitChanged(nil, designHairAssetId)
			avatarHair:InitColors()
		end
	end

	local partAssetId = avatarHair:GetAssetId()
	local hairList = self.model:getHairSuitList(self.presetKey)

	if partAssetId < 0 then
		self:sortConfig(-1)
	else
		for _, hairInfo in ipairs(hairList) do
			if hairInfo.assetId == partAssetId then
				self:sortConfig(hairInfo.id)

				break
			end
		end
	end

	if self.ctrl.isDesignMode then
		if self.ctrl.firstDesignData then
			self:refreshSecondDesignList()
		end
	else
		self:onFirstSortSelected(self.selectedHairOp)
		self:refreshSecondSortList()
	end

	self:refreshCurrentHairPanel()
end

return HairComponent
