-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Utils\\AvatarUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local lume = require("Core.Common.lume")
local GlobalData = require("Core.Client.GlobalData")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local AppearanceIcon = require("Data.appearance_icon")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local json = require("json")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local UIConst = require("Const.UIConst")
local SysConfigData = require("Data.sys_config_data")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local AppearanceSuitData = require("Data.appearance_suit_data")
local ClientUtils = require("Utils.ClientUtils")
local PetJewelryOssCache = require("Utils.PetJewelryOssCache")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AppearanceCustomOne = require("CustomTypes.AppearanceCustomOne")
local AppearanceCustomData = require("Data.appearance_custom_data")
local AppearanceData = require("Data.appearance_data")
local AppearancePointData = require("Data.appearance_point_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local DesignWorkShopConsumeData = require("Data.design_workshop_consume_data")
local AppearanceBackGroundData = require("Data.appearance_background_data")
local AppearanceVariableData = require("Data.appearance_variable_data")
local AddressDataConst = require("Const.AddressDataConst")
local ItemData = require("Data.item_data")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local Const = require("Common.Const.Const")
local NpcAvatarData = require("Data.npc_avatar_data")
local PlayableConst = require("Common.Const.PlayableConst")
local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
local AvatarPresetDetailData = require("Data.Avatar.avatar_preset_detail_data")
local AvatarModelResData = require("Data.Avatar.avatar_model_res_data")
local AppearanceData = require("Data.appearance_data")
local FileUtil = CS.FunPlus.WorldX.Utils.FileUtil
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local autoSavePath = Application.persistentDataPath
local avatarMgr = pg.global.avatarMgr
local avatarHair = pg.global.avatarMgr.avatarHair
local STUDIO_DEFAULT_COVER_URL = AppearanceVariableData.STUDIO_DEFAULT_IMAGE
local AvatarUtils = {}

AvatarUtils.REFRESH_PERIOD = {
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	10,
	11,
	12,
	13,
	14,
	15
}
AvatarUtils.APPEARANCE_ICON_ID = {
	HAIRCUT = 3,
	DYE = 2,
	HAIR = 1
}

function AvatarUtils.normalizeValue(minValue, maxValue, curValue)
	return (curValue - minValue) / (maxValue - minValue)
end

function AvatarUtils.denormalizeValue(minValue, maxValue, normalizedValue)
	return normalizedValue * (maxValue - minValue) + minValue
end

function AvatarUtils.refreshMakeUpInPeriod(player)
	for _, time in ipairs(AvatarUtils.REFRESH_PERIOD) do
		TimerManager.addTimer(time, function()
			ClientModelUtils.refreshAvatarMakeup(player)
		end)
	end
end

function AvatarUtils.generatePetJewelrySlider(modelHeight, petScale, sliderScale, petSizeLevel)
	local sliderInfo = {}

	modelHeight = (modelHeight or 1) * 1.2
	sliderScale = sliderScale or 1

	local halfHeight = modelHeight / 2
	local halfOffset = halfHeight * sliderScale
	local defaultY = 1

	if modelHeight < defaultY then
		defaultY = modelHeight
	end

	sliderInfo.petScale = petScale or 1

	local defaultPos = Vector3.New(halfHeight, defaultY, 0)
	local petSizeScale = PetConfigData.PET_JEWELRY_DEFAULT_SCALE[petSizeLevel] or 1
	local defaultScl = petSizeScale / sliderInfo.petScale

	sliderInfo.defaultAccessScale = defaultScl
	sliderInfo.defaultPos = defaultPos
	sliderInfo.minOffset = Vector3.New(halfOffset, -modelHeight / 3, -halfOffset)
	sliderInfo.maxOffset = Vector3.New(-halfOffset, modelHeight * 1.5, halfOffset)
	sliderInfo.minScale = 0.25
	sliderInfo.maxScale = 3

	local posMapLength = 2000

	sliderInfo.mapPosLength = posMapLength
	sliderInfo.mapRotLength = 180

	local mapPosX = AvatarUtils.parseSliderMapValue(-halfOffset, halfOffset, -posMapLength, posMapLength, defaultPos.x)
	local mapSclA = AvatarUtils.parseSliderMapValue(-halfOffset, halfOffset, -posMapLength, posMapLength, defaultScl)

	sliderInfo.defaultMapPos = Vector3.New(mapPosX, mapPosX, 0)
	sliderInfo.defaultMapRot = Vector3.New(0, 0, 0)
	sliderInfo.defaultMapScl = mapSclA

	return sliderInfo
end

function AvatarUtils.refreshPetJewelrySliderDepthRange(sliderInfo, minDepth, maxDepth)
	if not sliderInfo or not sliderInfo.minOffset or not sliderInfo.maxOffset or minDepth == nil or maxDepth == nil or maxDepth <= minDepth then
		return
	end

	local depthCenter = (minDepth + maxDepth) * 0.5
	local depthHalfOffset = (maxDepth - minDepth) * 0.75
	local rangeMin = math.min(sliderInfo.minOffset.z, depthCenter - depthHalfOffset)
	local rangeMax = math.max(sliderInfo.maxOffset.z, depthCenter + depthHalfOffset)

	sliderInfo.minOffset = Vector3.New(sliderInfo.minOffset.x, sliderInfo.minOffset.y, rangeMin)
	sliderInfo.maxOffset = Vector3.New(sliderInfo.maxOffset.x, sliderInfo.maxOffset.y, rangeMax)
end

function AvatarUtils.syncPetAttachFromOperation(modelView, instanceId, operationData)
	modelView:AdjustAccessLocalTransform(instanceId, operationData)

	local lPos = modelView:GetAttachLocalPosition(instanceId)
	local lRot = modelView:GetAttachLocalEulerRotation(instanceId)
	local scale = modelView:GetAttachLocalScale(instanceId)

	modelView.modelInfo:AddAttachInfo(operationData.resId, instanceId, operationData.attachBone, lPos, lRot, Vector3.New(scale, scale, scale), false)
end

function AvatarUtils.restorePetAttachBoneLocal(modelView, instanceId, cache)
	return modelView:TryApplyAttachBoneLocalTransform(instanceId, cache.attachBone, cache.localPosition, cache.localRotation, cache.localScale)
end

function AvatarUtils.capturePetAttachBoneLocal(modelView, instanceId, attachBone, resId)
	local success, currentBone, localPosition, localRotation, localScale = modelView:TryGetAttachBoneLocalTransform(instanceId)

	if success then
		return {
			localPosition = localPosition,
			localRotation = localRotation,
			localScale = localScale,
			attachBone = currentBone,
			resId = resId
		}
	end

	return {
		localPosition = modelView:GetAttachLocalPosition(instanceId),
		localRotation = modelView:GetAttachLocalEulerRotation(instanceId),
		localScale = modelView:GetAttachLocalScale(instanceId),
		attachBone = attachBone,
		resId = resId
	}
end

function AvatarUtils.loadPetOperationFromAttach(modelView, instanceId, attachInfo, sliderInfo)
	local success, boneName, localPosition, localRotation, localScale = modelView:TryGetAttachBoneLocalTransform(instanceId)

	if success then
		local converted, rootPosition, rootRotation, rootScale = modelView:TryConvertAttachBoneLocalToRoot(boneName, localPosition, localRotation, localScale)

		if converted then
			return {
				curOffset = rootPosition,
				curRotate = rootRotation,
				curScale = rootScale,
				attachBone = attachInfo.attachHp or attachInfo.attachBone or boneName,
				resId = attachInfo.resId
			}
		end
	end

	return {
		curOffset = modelView:GetRelativelyPosition(instanceId),
		curRotate = modelView:GetRelativelyRotation(instanceId),
		curScale = modelView:GetRelativelyScale(instanceId),
		attachBone = attachInfo.attachHp or attachInfo.attachBone,
		resId = attachInfo.resId
	}
end

function AvatarUtils.parseSliderMapValue(oldMin, oldMax, newMin, newMax, cur, reverse)
	if reverse then
		return (oldMax - oldMin) * (cur - newMin) / (newMax - newMin) + oldMin
	else
		return (newMax - newMin) * (cur - oldMin) / (oldMax - oldMin) + newMin
	end
end

function AvatarUtils.getSortedGroup(originConfig)
	local sortedGroup = {}

	for groupKey, groupData in pairs(originConfig) do
		local avatarIcon = AppearanceIcon[groupData.displayName] or {}

		table.insert(sortedGroup, {
			order = groupData.order,
			key = groupKey,
			displayName = groupData.displayName,
			icon = avatarIcon.icon,
			partId = groupData.partId
		})
	end

	sortedGroup = lume.sort(sortedGroup, "order")

	return sortedGroup
end

function AvatarUtils.getSortedKind(originConfig)
	local sortedKind = {}

	for groupKey, groupData in pairs(originConfig) do
		sortedKind[groupKey] = {}

		for kindKey, kindData in pairs(groupData.kindList) do
			table.insert(sortedKind[groupKey], {
				order = kindData.order,
				key = kindKey,
				displayName = kindData.displayName,
				highLightName = kindData.highLightName
			})
		end

		sortedKind[groupKey] = lume.sort(sortedKind[groupKey], "order")
	end

	return sortedKind
end

function AvatarUtils.renderOperationCollection(button, data, subUListRenderItemFuc, clear)
	local objectReference = button:GetComponent("ObjectReference")
	local titleUText = objectReference:GetRefValue("titleUText")
	local contentUList = objectReference:GetRefValue("contentUList")

	if clear then
		ClientTextUtils.setText(titleUText, "")
		contentUList:SetList({})

		return
	end

	ClientTextUtils.setText(titleUText, pg.getLocalizationText(data.displayName))

	if data.isLock then
		button:TryChangePage("Locked", 1)

		local btnLockedUButton = objectReference:GetRefValue("btnLockedUButton")

		function btnLockedUButton.luaClick()
			if data.unlockClicked then
				data.unlockClicked()
			end
		end

		local iconGoldUImage = objectReference:GetRefValue("iconGoldUImage")
		local txtQuantityTextPlus = objectReference:GetRefValue("txtQuantityTextPlus")

		iconGoldUImage.url = LuaUIUtils.getIconByItemId(data.costData[1][1])

		ClientTextUtils.setText(txtQuantityTextPlus, data.costData[1][2])
	elseif data.playUnlock then
		button:TryChangePage("Locked", 2)
	else
		button:TryChangePage("Locked", 0)
	end

	function contentUList.luaRenderItem(contentButton, contentIndex, contentData)
		subUListRenderItemFuc(contentButton, contentIndex, contentData, data.displayName)
	end

	contentUList:SetList(data.subOps)
end

function AvatarUtils.renderSlider(button, data, value, luaValueChanged, luaRelease, luaPress, kindDisplayName, stepRatio)
	local objectReference = button:GetComponent("ObjectReference")
	local nameUText = objectReference:GetRefValue("nameUText")
	local sliderUSlider = objectReference:GetRefValue("sliderUSlider")
	local rootUComponent = objectReference:GetRefValue("rootUComponent")

	if data.displayName or kindDisplayName then
		ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.displayName or kindDisplayName))
		rootUComponent:TryChangePage("title", "show")
	else
		rootUComponent:TryChangePage("title", "hide")
	end

	sliderUSlider.enableValueChangedCallback = false

	function sliderUSlider.luaValueChanged(v)
		if luaValueChanged then
			luaValueChanged(v)
		end
	end

	function sliderUSlider.luaPress()
		if luaPress then
			luaPress()
		end
	end

	function sliderUSlider.luaRelease()
		if luaRelease then
			luaRelease()
		end
	end

	sliderUSlider.maxValue = data.maxValue or 100
	sliderUSlider.minValue = data.minValue or -100
	sliderUSlider.value = value
	sliderUSlider.enableValueChangedCallback = true

	if stepRatio then
		local btnAddUButton = objectReference:GetRefValue("btnAddUButton")
		local btnMinusUButton = objectReference:GetRefValue("btnMinusUButton")
		local stepValue = (sliderUSlider.maxValue - sliderUSlider.minValue) * stepRatio

		local function changeSliderValue(delta)
			local oldValue = sliderUSlider.value
			local newValue = math.max(sliderUSlider.minValue, math.min(sliderUSlider.maxValue, oldValue + delta))

			if newValue == oldValue then
				return
			end

			if luaPress then
				luaPress()
			end

			sliderUSlider.value = newValue

			if luaRelease then
				luaRelease()
			end
		end

		function btnAddUButton.luaClick()
			changeSliderValue(stepValue)
		end

		function btnMinusUButton.luaClick()
			changeSliderValue(-stepValue)
		end
	end
end

function AvatarUtils.renderSlider2D(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local nameUText = objectReference:GetRefValue("nameUText")
	local sliderU2DSlider = objectReference:GetRefValue("sliderU2DSlider")
	local numXUText = objectReference:GetRefValue("numXUText")
	local numYUText = objectReference:GetRefValue("numYUText")

	ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.displayName))
end

function AvatarUtils.renderColor(button, data, onClickCallback)
	local objectReference = button:GetComponent("ObjectReference")
	local colorUImage = objectReference:GetRefValue("colorUImage")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local inputFieldUInputField = objectReference:GetRefValue("inputFieldUInputField")
	local rootUButton = objectReference:GetRefValue("rootUButton")
	local titleUSDFText = objectReference:GetRefValue("titleUSDFText")

	function rootUButton.luaClick()
		onClickCallback()
	end

	if data.color then
		ClientTextUtils.setText(txtNameUText, lume.hexColorCode(data.color))

		colorUImage.color = data.color
	end

	if data.displayName then
		rootUButton:TryChangePage("HaveTitle", "Yes")
		ClientTextUtils.setText(titleUSDFText, pg.getLocalizationText(data.displayName))
	else
		rootUButton:TryChangePage("HaveTitle", "No")
	end
end

function AvatarUtils.renderMultiColor(button, data, color, rootColor, value, isEnable, switchCb, colorClickCb, rootColorClickCb, lowerValChangedCb, upperValChangedCb, luaPress, luaRelease)
	local objectReference = button:GetComponent("ObjectReference")
	local rootUComponent = objectReference:GetRefValue("rootUComponent")
	local titleUText = objectReference:GetRefValue("titleUText")
	local switchUButton = objectReference:GetRefValue("switchUButton")
	local leftColorUButton = objectReference:GetRefValue("leftColorUButton")
	local leftColorUImage = objectReference:GetRefValue("leftColorUImage")
	local rightColorUButton = objectReference:GetRefValue("rightColorUButton")
	local rightColorUImage = objectReference:GetRefValue("rightColorUImage")
	local rangeUDoubleSlider = objectReference:GetRefValue("rangeUDoubleSlider")

	rootUComponent:TryChangePage("IsExpend", isEnable and "Expend" or "Normal")
	ClientTextUtils.setText(titleUText, data.displayName and pg.getLocalizationText(data.displayName) or "")

	function switchUButton.luaClick()
		if switchCb then
			switchCb()
		end
	end

	function leftColorUButton.luaClick()
		if colorClickCb then
			colorClickCb()
		end
	end

	if color then
		leftColorUImage.color = color
	end

	function rightColorUButton.luaClick()
		if rootColorClickCb then
			rootColorClickCb()
		end
	end

	if rootColor then
		rightColorUImage.color = rootColor
	end

	function rangeUDoubleSlider.luaPress()
		if luaPress then
			luaPress()
		end
	end

	function rangeUDoubleSlider.luaRelease()
		if luaRelease then
			luaRelease()
		end
	end

	function rangeUDoubleSlider.luaLowerValueChanged(v)
		if lowerValChangedCb then
			lowerValChangedCb(v)
		end
	end

	function rangeUDoubleSlider.luaUpperValueChanged(v)
		if upperValChangedCb then
			upperValChangedCb(v)
		end
	end

	rangeUDoubleSlider.enableValueChangedCallback = false
	rangeUDoubleSlider.lowerValue = value.x
	rangeUDoubleSlider.upperValue = value.y
	rangeUDoubleSlider.enableValueChangedCallback = true

	local minValue = data.minValue or -100
	local maxValue = data.maxValue or 100

	rangeUDoubleSlider.minValue = minValue
	rangeUDoubleSlider.maxValue = maxValue
	rangeUDoubleSlider.space = 0.1 * (maxValue - minValue)
	rangeUDoubleSlider.stepSize = 1
end

function AvatarUtils.renderSlotList(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local rootUComponent = objectReference:GetRefValue("rootUComponent")
	local slotUImage = objectReference:GetRefValue("slotUImage")
	local slotUText = objectReference:GetRefValue("slotUText")
	local costUImage = objectReference:GetRefValue("costUImage")
	local costUText = objectReference:GetRefValue("costUText")

	rootUComponent:TryChangePage("state", data.state)

	if data.state == LuaUIUtils.SLOT_STATE.LOCKED then
		iconUImage.url = nil
		slotUImage.url = data.slotIcon

		if data.unlockCost then
			costUImage.url = data.unlockCost.icon or nil

			ClientTextUtils.setText(costUText, data.unlockCost.num or "")
		else
			costUImage.url = data.costItemId and LuaUIUtils.getIconByItemId(data.costItemId) or nil

			ClientTextUtils.setText(costUText, data.costNum or "")
		end
	elseif data.state == LuaUIUtils.SLOT_STATE.HAVE then
		iconUImage.url = data.icon
		slotUImage.url = nil
		costUImage.url = nil

		rootUComponent:TryChangePage("Quality", data.quality)
	else
		iconUImage.url = nil
		slotUImage.url = data.slotIcon
		costUImage.url = nil

		ClientTextUtils.setText(slotUText, pg.getLocalizationText(data.text))
	end
end

function AvatarUtils.isDyeingEnabled(itemId)
	local appearanceData = AppearanceData[itemId] or AppearanceSuitData[itemId]

	if not appearanceData then
		return false
	end

	return appearanceData.dyeingStatus and appearanceData.dyeingStatus == 1
end

function AvatarUtils.renderOptionList(button, index, data, options)
	options = options or {}

	local inVitality = options.inVitality == true or data.inVitality == true
	local objectReference = button:GetComponent("ObjectReference")
	local rootUComponent = objectReference:GetRefValue("rootUComponent")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local imgPet = objectReference:GetRefValue("imgPet")
	local nameUText = objectReference:GetRefValue("nameUText")
	local collectUText = objectReference:GetRefValue("collectUText")
	local costUImage = objectReference:GetRefValue("costUImage")
	local costUText = objectReference:GetRefValue("costUText")
	local imgArtFontUImage = objectReference:GetRefValue("imgArtFontUImage")
	local useUWidget = objectReference:GetRefValue("useUWidget")
	local scoreUWidget = objectReference:GetRefValue("coinBoxUWidget")
	local scoreUText = objectReference:GetRefValue("NumCoin")
	local txtUse = objectReference:GetRefValue("txtUse")
	local dyeUImage = objectReference:GetRefValue("dyeUImage")

	rootUComponent:TryChangePage("Conflict", 0)
	dyeUImage.gameObject:SetActiveEx(AvatarUtils.isDyeingEnabled(data.itemId))

	if data.state == LuaUIUtils.SELECT_STATE.PET_WEAR then
		imgPet.url = data.refPetIcon
	else
		imgPet.url = nil
	end

	rootUComponent:TryChangePage("state", data.state)

	if data.state == LuaUIUtils.SELECT_STATE.TRY then
		rootUComponent:TryChangePage("state", LuaUIUtils.SELECT_STATE.HAVE)
	end

	useUWidget.gameObject:SetActiveEx(data.state == LuaUIUtils.SELECT_STATE.TRY)
	rootUComponent:TryChangePage("Quality", data.quality or 0)
	ClientTextUtils.setText(collectUText, data.claimedCount and data.allCount and string.format("%s/%s", data.claimedCount, data.allCount) or "")
	ClientTextUtils.setText(costUText, data.costNum or "")

	if data.costItemId then
		costUImage:SetActiveFastest(true)

		costUImage.url = LuaUIUtils.getIconByItemId(data.costItemId)
	else
		costUImage:SetActiveFastest(false)
	end

	iconUImage.url = data.icon

	if data.tagRateIcon then
		imgArtFontUImage.url = data.tagRateIcon
	end

	imgArtFontUImage.gameObject:SetActiveEx(data.tagRateIcon)
	nameUText.gameObject:SetActiveEx(not inVitality)

	if scoreUWidget then
		scoreUWidget.gameObject:SetActiveEx(inVitality)
	end

	if inVitality and scoreUText then
		ClientTextUtils.setText(scoreUText, data.vitalityScore or data.score or data.totalScore or data.fashion or 0)
	end

	if txtUse then
		ClientTextUtils.setText(txtUse, pg.getGameString("GLAMOUR_EVENT_TRIAL"))
	end

	ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.name))

	if data.itemId then
		local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_OPTION_LIST_ITEM, data.itemId)

		pg.global.setRedDot(treePath, button, data.showRedDot or false, RedDotConst.RedDotStyle.NEW_LEFT_EXPEND)
	elseif data.accessoryId and data.genId then
		local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_PET_OPTION_LIST_ITEM, string.format("%s_%s", data.accessoryId, data.genId))

		pg.global.setRedDot(treePath, button, data.showRedDot or false, RedDotConst.RedDotStyle.NEW_LEFT_EXPEND)
	end
end

function AvatarUtils.renderPresetList(button, index, data, needDestroyDownloadSprite)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")
	local consumeUImage = objectReference:GetRefValue("consumeUImage")
	local consumeUBaseText = objectReference:GetRefValue("consumeUBaseText")

	if data.state == AvatarUtils.PRESET_STATE.NORMAL then
		if data.photoId then
			ServiceUtils.kvServiceFind(data.photoId, function(status, response)
				if status.status and response.value then
					ClientUtils.pullPicture(response.value, function(_, pic)
						if pic then
							if button.dataFromUList ~= data then
								pg.global.mobileCameraMgr:DestroySpriteTexture(pic)

								return
							end

							needDestroyDownloadSprite[#needDestroyDownloadSprite + 1] = pic
							iconUImage.sprite = pic
						else
							iconUImage.sprite = nil
							iconUImage.url = data.icon
						end
					end)
				else
					iconUImage.sprite = nil
					iconUImage.url = data.icon
				end
			end)
		elseif data.icon then
			iconUImage.url = data.icon
		end
	end

	button:TryChangePage("State", data.state)

	if type(data.name) == "number" then
		ClientTextUtils.setTextWithIdOrDefault(textUBaseText, data.name, "")
	else
		ClientTextUtils.setText(textUBaseText, data.name or "")
	end

	ClientTextUtils.setText(consumeUBaseText, data.costNum or "")

	if data.costItemId then
		consumeUImage:SetActiveFastest(true)

		consumeUImage.url = LuaUIUtils.getIconByItemId(data.costItemId)
	else
		consumeUImage:SetActiveFastest(false)
	end
end

function AvatarUtils.getClothesPresetList(clothesId, insertOrigin)
	local presetList = {}
	local cData = AppearanceData[clothesId]

	if not cData then
		return presetList
	end

	if insertOrigin then
		local originNode = {
			id = -1,
			state = AvatarUtils.PRESET_STATE.NORMAL,
			clothesId = clothesId,
			icon = cData.icon or ItemData[clothesId].icon,
			name = ItemData[clothesId].itemName,
			points = Utils.deepCopyTable(cData.points)
		}

		table.insert(presetList, originNode)
	end

	for id, info in ipairs(AppearanceCustomData) do
		if info.clothesCostType then
			local state
			local appearanceInfo = pg.me.appearanceInfo[clothesId] or {}
			local designList = appearanceInfo.designList or {}
			local custom = designList[id]

			if appearanceInfo and custom then
				state = custom.isChange and AvatarUtils.PRESET_STATE.NORMAL or AvatarUtils.PRESET_STATE.EMPTY

				local photoId = Utils.getAppearanceClothesPhotoId(pg.me.uid, clothesId, id)
				local cloth = {
					state = state,
					id = id,
					clothesId = clothesId,
					photoId = photoId,
					name = custom.name,
					points = Utils.deepCopyTable(cData.points)
				}

				table.insert(presetList, cloth)
			else
				state = AvatarUtils.PRESET_STATE.LOCKED

				table.insert(presetList, {
					state = state,
					costNum = info.clothesCostNum,
					costItemId = info.clothesCostType
				})

				break
			end
		end
	end

	return presetList
end

function AvatarUtils.getClothesPresetNumInfo(configId)
	local usedNum = 0
	local unlockNum = 0
	local allNum = 0
	local appearanceInfo = pg.me.appearanceInfo[configId] or {}
	local designList = appearanceInfo.designList or {}

	for id, info in ipairs(AppearanceCustomData) do
		if info.clothesCostType then
			allNum = allNum + 1

			if designList[id] then
				unlockNum = unlockNum + 1

				if designList[id].isChange then
					usedNum = usedNum + 1
				end
			end
		end
	end

	return usedNum, unlockNum, allNum
end

function AvatarUtils.getHairPresetList(hairSuitId, insertOrigin)
	local presetList = {}
	local cData = AvatarHairSuitData[hairSuitId]

	if not cData then
		return
	end

	local itemData = ItemData[hairSuitId] or {}
	local icon = cData.icon or itemData.icon

	if insertOrigin then
		local originNode = {
			id = -1,
			state = AvatarUtils.PRESET_STATE.NORMAL,
			icon = icon,
			name = itemData.itemName
		}

		table.insert(presetList, originNode)
	end

	local hairSuitCustom = pg.me.hairCustom[hairSuitId]

	for id, info in ipairs(AppearanceCustomData) do
		if info.hairCostType then
			local photoId = Utils.getAppearanceHairPhotoId(pg.me.uid, hairSuitId, id)

			if hairSuitCustom and hairSuitCustom[id] then
				local state = #hairSuitCustom[id].hairInfo == 0 and AvatarUtils.PRESET_STATE.EMPTY or AvatarUtils.PRESET_STATE.NORMAL

				table.insert(presetList, {
					state = state,
					id = id,
					photoId = photoId,
					icon = icon,
					name = hairSuitCustom[id].customName
				})
			elseif info.hairCostNum == 0 then
				table.insert(presetList, {
					state = AvatarUtils.PRESET_STATE.EMPTY,
					id = id
				})
			else
				table.insert(presetList, {
					state = AvatarUtils.PRESET_STATE.LOCKED,
					costNum = info.hairCostNum,
					costItemId = info.hairCostType
				})

				break
			end
		end
	end

	return presetList
end

function AvatarUtils.applyClothesPreset(entity, slotId, clothesId)
	if not entity or not entity.eModel then
		return false
	end

	local modelView = entity.eModel.modelModelView

	if not modelView.partModel:IsPartModelLoaded(slotId) then
		return false
	end

	local appUnit = pg.me.appearanceInfo[clothesId]

	if appUnit and appUnit.designIndex > 0 and #appUnit.designList > 0 then
		local unit = appUnit.designList[appUnit.designIndex]

		if unit == nil then
			return false
		end

		ClientModelUtils.applyClothStainInfo(entity, slotId, unit)

		return unit
	end

	modelView.shaderView:ApplyPreset(slotId, "Default1")

	if appUnit and #appUnit.designList > 0 then
		return appUnit.designList[1]
	end

	return false
end

function AvatarUtils.applyEquippedClothesStain(entity, applyPreview, ignorePreviewSetToZero)
	if not entity or not entity.getAppearanceConfigId then
		return
	end

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId = entity:getAppearanceConfigId(partId, applyPreview, ignorePreviewSetToZero)

		if clothesId and clothesId ~= 0 then
			AvatarUtils.applyClothesPreset(entity, partId, clothesId)
		end
	end
end

function AvatarUtils.getHairPresetNumInfo(hairSuitId)
	local usedNum = 0
	local unlockNum = 0
	local allNum = 0

	for id, info in ipairs(AppearanceCustomData) do
		if info.hairCostType then
			allNum = allNum + 1

			local hairSuit = pg.me.hairCustom[hairSuitId]

			if hairSuit and hairSuit[id] then
				unlockNum = unlockNum + 1

				if #hairSuit[id].hairInfo > 0 then
					usedNum = usedNum + 1
				end
			elseif info.hairCostNum == 0 then
				unlockNum = unlockNum + 1
			end
		end
	end

	return usedNum, unlockNum, allNum
end

function AvatarUtils.getClothPartList(customShow)
	local partList = {}
	local appearanceShow = customShow or pg.me.curShow.customShow or {}

	for slotId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId = appearanceShow[slotId]

		if clothesId then
			local showClothes = clothesId ~= 0 and LuaUIUtils.isClothesBelongToSlot(clothesId, slotId)
			local displayClothesId = showClothes and clothesId or 0
			local clothesInfo = showClothes and LuaUIUtils.getClothesInfo(pg.me, clothesId, customShow) or {}

			partList[#partList + 1] = {
				state = displayClothesId == 0 and LuaUIUtils.SLOT_STATE.EMPTY or LuaUIUtils.SLOT_STATE.HAVE,
				icon = clothesInfo.icon,
				quality = clothesInfo.quality,
				clothesId = displayClothesId,
				slotId = slotId,
				part = AppearancePointData[slotId].name,
				slotIcon = LuaUIUtils.getClothesSlotIcon(slotId),
				text = AppearancePointData[slotId].text
			}
		else
			partList[#partList + 1] = {
				state = LuaUIUtils.SLOT_STATE.LOCKED,
				costItemId = AppearancePointData[slotId].costType,
				costNum = AppearancePointData[slotId].costNum,
				slotId = slotId,
				part = AppearancePointData[slotId].name,
				slotIcon = LuaUIUtils.getClothesSlotIcon(slotId),
				text = AppearancePointData[slotId].text
			}
		end
	end

	return partList
end

function AvatarUtils.isValid(appearanceData, bodyType)
	for _, type in ipairs(appearanceData.body) do
		if type == bodyType then
			return true
		end
	end

	return false
end

function AvatarUtils.getClothesOccupyConflictItems(entity, clothesId)
	local conflictIds = {}

	if not entity or not entity.customShow or not clothesId then
		return conflictIds
	end

	local data = AppearanceData[clothesId]

	if not data or not data.points or #data.points == 0 then
		return conflictIds
	end

	local newPrimarySlot = LuaUIUtils.getClothesPrimarySlot(clothesId)

	if not newPrimarySlot then
		return conflictIds
	end

	local newPointsSet = {}

	for _, slotId in ipairs(data.points) do
		newPointsSet[slotId] = true
	end

	local added = {}

	for slotId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		if slotId ~= newPrimarySlot then
			local curId = entity.customShow[slotId]

			if curId and curId ~= 0 and curId ~= clothesId and not added[curId] and LuaUIUtils.isClothesBelongToSlot(curId, slotId) then
				local oldData = AppearanceData[curId]

				if oldData and oldData.points then
					for _, oldSlot in ipairs(oldData.points) do
						if newPointsSet[oldSlot] then
							added[curId] = true
							conflictIds[#conflictIds + 1] = curId

							break
						end
					end
				end
			end
		end
	end

	return conflictIds
end

function AvatarUtils.hasClothesOccupyConflict(entity, clothesId)
	local conflictIds = AvatarUtils.getClothesOccupyConflictItems(entity, clothesId)

	return #conflictIds > 0
end

local function showClothesOccupyConflictConfirm(newClothesId, conflictIds, doEquip, onCancel)
	local textA = LuaUIUtils.getItemShowText(newClothesId)
	local textBParts = {}

	for _, conflictId in ipairs(conflictIds) do
		textBParts[#textBParts + 1] = LuaUIUtils.getItemShowText(conflictId)
	end

	local textB = table.concat(textBParts, "")

	pg.global.showConfirmMsgRaw(pg.getGameString("APPEARANCE_CLOTHES_OCCUPY_CONFLICT_TITLE"), pg.getFormatText(pg.getGameString("APPEARANCE_CLOTHES_OCCUPY_CONFLICT_DESC"), textA, textB), doEquip, false, onCancel)
end

function AvatarUtils.tryEquipClothesWithConflictConfirm(entity, clothesId, isPreview, doEquip, onCancel)
	if isPreview then
		doEquip()

		return false
	end

	local conflictIds = AvatarUtils.getClothesOccupyConflictItems(entity, clothesId)

	if #conflictIds == 0 then
		doEquip()

		return false
	end

	showClothesOccupyConflictConfirm(clothesId, conflictIds, doEquip, onCancel)

	return true
end

function AvatarUtils.markClothesOccupyConflictFlags(entity, optionList)
	if not optionList then
		return
	end

	for _, v in pairs(optionList) do
		if v.clothesId and entity then
			v.occupyConflict = AvatarUtils.hasClothesOccupyConflict(entity, v.clothesId)
		else
			v.occupyConflict = false
		end
	end
end

function AvatarUtils.getClothesInfoList(params)
	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	local res = {}

	for id, appearanceData in pairs(AppearanceData) do
		if LuaUIUtils.isClothes(appearanceData.type) and AvatarUtils.isValid(appearanceData, params.bodyType) then
			local clothesInfo = LuaUIUtils.getClothesInfo(pg.me, id)

			if clothesInfo.partId == params.slotId and (params.checkCanStain == nil or params.checkCanStain(clothesInfo) == true) and (params.filterFunc == nil or params.filterFunc(clothesInfo) == true) then
				res[#res + 1] = clothesInfo
			end
		end
	end

	table.sort(res, function(a, b)
		return params.orderBy(a, b)
	end)

	if params.forceFirstClothesId then
		local index, info

		for i, clothesInfo in ipairs(res) do
			if clothesInfo.clothesId == params.forceFirstClothesId then
				index = i
				info = clothesInfo

				break
			end
		end

		if index then
			table.remove(res, index)
			table.insert(res, 1, info)
		end
	end

	return res
end

function AvatarUtils.getHairSuitList(params)
	local res = {}

	for id, suitData in pairs(AvatarHairSuitData) do
		if AvatarUtils.isValid(suitData, params.bodyType) then
			local suitInfo = LuaUIUtils.getHairSuitInfo(pg.me, id)

			suitInfo.state = suitInfo.claimed and LuaUIUtils.SELECT_STATE.HAVE or LuaUIUtils.SELECT_STATE.LOCKED

			if params.filterFunc == nil or params.filterFunc(suitInfo) == true then
				res[#res + 1] = suitInfo
			end
		end
	end

	table.sort(res, function(a, b)
		return params.orderBy(a, b)
	end)

	if params.forceFirstSuitId then
		local index, info

		for i, clothesInfo in ipairs(res) do
			if clothesInfo.suitId == params.forceFirstSuitId then
				index = i
				info = clothesInfo

				break
			end
		end

		if index then
			table.remove(res, index)
			table.insert(res, 1, info)
		end
	end

	return res
end

function AvatarUtils.onBagClicked(visible, partId, slotId)
	pg.me:serverMsg("RPC_CS_SetCustomNameAndBag", "curShow", 0, "", visible, function()
		local actions = {
			{
				partId = partId,
				slotId = slotId,
				visible = visible
			}
		}
		local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

		if avatarScene then
			avatarScene:refreshPartRendererVisible(pg.game.avatar:getPresetKey(pg.me), actions)
		end
	end)
end

function AvatarUtils.onHideUIClicked(button)
	pg.global.ui:open(UIConst.UI_ID_APPEARANCE_PREVIEW, {
		button = button
	})
end

function AvatarUtils.checkIsShowAlert(lastTime, curTime)
	if string.isNilOrEmpty(lastTime) then
		return true
	else
		local function parseDate(timeStr)
			if string.isNilOrEmpty(timeStr) then
				return nil
			end

			local datePart = string.match(timeStr, "^(%S+)") or timeStr
			local year, month, day = string.match(datePart, "^(%d%d%d%d)[/-](%d%d?)[/-](%d%d?)$")

			if year then
				return tonumber(year), tonumber(month), tonumber(day)
			end

			local monthAlt, dayAlt, yearAlt = string.match(datePart, "^(%d%d?)[/-](%d%d?)[/-](%d%d%d%d)$")

			if yearAlt then
				return tonumber(yearAlt), tonumber(monthAlt), tonumber(dayAlt)
			end

			return nil
		end

		local lastYear, lastMonth, lastDay = parseDate(lastTime)
		local year, month, day = parseDate(curTime)

		if not lastYear or not year then
			return true
		end

		local lastDate = lastYear * 10000 + lastMonth * 100 + lastDay
		local curDate = year * 10000 + month * 100 + day

		return lastDate < curDate
	end
end

function AvatarUtils.equipHairSuit(entityId, hairId, isPreview, callback)
	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE) or pg.game.uiScene:getScene(UISceneConst.CASH_SCENE)

	if not avatarScene then
		return
	end

	local entity = avatarScene:getCurEntity()
	local curSuitId = LuaUIUtils.tryGetEntityHairSuitId(entity)
	local curModelSuitId = avatarScene:getCurHairSuitId(entityId)

	if curSuitId == hairId and curModelSuitId == hairId then
		return
	end

	local modelInfo = entity.eModel.modelModelView.modelInfo
	local oldAssetId = modelInfo:GetOriginHairAssetId()
	local modelSuitInfo = curModelSuitId and AvatarHairSuitData[curModelSuitId] or nil
	local currentAssetId = modelSuitInfo and modelSuitInfo.assetId
	local partItems = LuaUIUtils.getAllPartInSuit(hairId, oldAssetId, currentAssetId)
	local hairSuitInfo = AvatarHairSuitData[hairId] or {}
	local newAssetId = hairSuitInfo.assetId

	if newAssetId then
		pg.global.avatarMgr.avatarHair:OnHairSuitChanged(nil, newAssetId)
	end

	if isPreview then
		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			entity:cancelCustomShowPreview(partId)

			local newConfigId = partItems[partId]

			if newConfigId and newConfigId ~= 0 then
				entity:setCustomShowPreview(newConfigId, true, partId)
			end
		end
	else
		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			entity:cancelCustomShowPreview(partId)
			entity:cancelCustomShow(partId, true)

			local newConfigId = partItems[partId]

			if newConfigId and newConfigId ~= 0 then
				entity:setCustomShow(newConfigId, true, partId)
			end
		end
	end

	local modelView = entity.eModel.modelModelView
	local partModelInfo = modelView.modelInfo.partModelInfo

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local configId = entity:getAppearanceConfigId(partId, isPreview)

		AppearanceEffectUtils.setAppearance(entity, partId, configId)

		local curResId = partModelInfo:GetPartResId(partId)

		if configId == 0 then
			if not string.isNilOrEmpty(curResId) then
				partModelInfo:RemovePartItem(curResId)
			end
		else
			local data = AppearanceData[configId]

			if data and data.res ~= curResId then
				partModelInfo:ModifyPartItem(data.res, Utils.deepCopyTable(data.points))
			end
		end
	end

	ClientModelUtils.refreshModels(entity, modelView)

	if callback then
		callback()
	end
end

function AvatarUtils.syncHairCustomShowFromCurShow(entity)
	if not entity or not entity.customShow or not entity.curShow then
		return
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		entity.customShow[partId] = entity.curShow.customShow[partId]
	end
end

function AvatarUtils.refreshHairByCustom()
	AvatarUtils.cancelHairTie()

	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	if not avatarScene then
		return
	end

	local entity = avatarScene:getCurEntity()

	AvatarUtils.syncHairCustomShowFromCurShow(entity)

	local modelView = entity.eModel.modelModelView
	local hairPart = ClientModelUtils.getModelHairParts(entity, nil, entity.customShow)

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local part = hairPart[partId]

		AppearanceEffectUtils.setAppearance(entity, partId, part and part.hairPartId)
	end

	ClientModelUtils.applyModelPart(modelView.modelInfo, hairPart)

	function entity.modelPartModelAllLoaded()
		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			ClientModelUtils.applyHairCustomData(entity, entity.curShow, partId)
		end

		entity.modelPartModelAllLoaded = nil
	end

	modelView.forceLoadPart = true

	ClientModelUtils.refreshModels(entity, modelView)

	modelView.forceLoadPart = false
end

function AvatarUtils.applyHairPresetOrRuntimeDefault(hairSuitId, callback)
	if not pg.me or not hairSuitId then
		return
	end

	pg.me.delayRecordHairInfo = nil

	local hairSuit = pg.me.hairCustom and pg.me.hairCustom[hairSuitId]

	if hairSuit and hairSuit.index ~= 0 then
		pg.me:serverMsg("RPC_CS_SetHairCustom", hairSuitId, hairSuit.index, callback)

		return
	end

	local hairCustomData = {}

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local hairCustomDataStr = avatarMgr:GetHairCustomDataString(partId, true)

		hairCustomData[partId] = compressToStr(hairCustomDataStr)
	end

	pg.me.delayRecordHairInfo = {
		index = 0,
		hairCustomData = hairCustomData
	}
end

AvatarUtils.hairTie = nil

function AvatarUtils.toggleHairTie(avatarScene, button)
	if AvatarUtils.hairTie then
		AvatarUtils.cancelHairTie()

		return
	end

	local entity = avatarScene and avatarScene:getCurEntity()

	if not entity or not entity.eModel then
		return
	end

	local modelView = entity.eModel.modelModelView
	local partModelInfo = modelView.modelInfo.partModelInfo
	local snapshot = {}

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local resId = partModelInfo:GetPartResId(partId)

		if not string.isNilOrEmpty(resId) then
			snapshot[partId] = resId

			partModelInfo:RemovePartItem(resId)
		end
	end

	AvatarUtils.hairTie = {
		entity = entity,
		snapshot = snapshot,
		button = button
	}

	if not IsNil(button) then
		button.isSelected = false
	end

	ClientModelUtils.refreshModels(entity, modelView)
end

function AvatarUtils.cancelHairTie()
	local tie = AvatarUtils.hairTie

	if not tie then
		return
	end

	AvatarUtils.hairTie = nil

	if not IsNil(tie.button) then
		tie.button.isSelected = true
	end

	local entity = tie.entity

	if not entity or not entity.eModel then
		return
	end

	local modelView = entity.eModel.modelModelView

	for partId, resId in pairs(tie.snapshot) do
		modelView.modelInfo.partModelInfo:ModifyPartItem(resId, {
			partId
		})
	end

	ClientModelUtils.refreshModels(entity, modelView)
end

function AvatarUtils.getCurCustomDataCacheVersion()
	return SysConfigData.CUSTOM_DATA_CACHE_VERSION or 0
end

local function isValidCustomDataCache(autoSaveData)
	return autoSaveData and autoSaveData.cacheVersion == AvatarUtils.getCurCustomDataCacheVersion()
end

function AvatarUtils.getSavePath()
	local name = pg.global.sdkManager:isDouyinCloudChannel() and "douyin_cloud_avatar.json" or GlobalData.UserName .. "_avatar.json"
	local path = string.format("%s/%s", autoSavePath, name)

	return path
end

function AvatarUtils.saveCustomDataToDisk(presetKey)
	if not presetKey then
		return
	end

	local ok, avatarConfigStr = pcall(AvatarUtils.getCustomDataStringForSave)

	if not ok or string.isNilOrEmpty(avatarConfigStr) then
		return
	end

	local autoSaveData = {
		cacheVersion = AvatarUtils.getCurCustomDataCacheVersion(),
		presetKey = presetKey,
		avatarConfig = compressToStr(avatarConfigStr),
		hairCustomData = {},
		hairSelection = {}
	}

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local hairOk, hairCustomDataStr = pcall(avatarMgr.GetHairCustomDataString, avatarMgr, partId)

		if hairOk then
			autoSaveData.hairCustomData[partId] = compressToStr(hairCustomDataStr)
			autoSaveData.hairSelection[partId] = pg.game.avatar.hairSelection[partId]
		end
	end

	local fusionData = pg.game.avatar:getFusionData()

	if fusionData then
		autoSaveData.fusionData = fusionData
	end

	local hairAssetId = avatarHair:GetHairCustomDataAssetId()

	autoSaveData.hairAssetId = hairAssetId

	FileUtil.WriteFile(AvatarUtils.getSavePath(), table.tostring(autoSaveData))
end

local function readValidCustomDataFromDisk()
	local cacheStr = FileUtil.ReadText(AvatarUtils.getSavePath())

	if string.isNilOrEmpty(cacheStr) then
		return nil
	end

	local result, autoSaveData = xpcall(string.toTable, debug.traceback, cacheStr)

	if not result or not isValidCustomDataCache(autoSaveData) then
		AvatarUtils.clearCustomDataFromDisk()

		return nil
	end

	return autoSaveData
end

function AvatarUtils.hasCustomDataInDisk()
	return readValidCustomDataFromDisk() or false
end

function AvatarUtils.loadCustomDataFromDisk()
	return readValidCustomDataFromDisk() or {}
end

function AvatarUtils.clearCustomDataFromDisk()
	FileUtil.WriteFile(AvatarUtils.getSavePath(), "")
end

local function restoreHairFromAutoSave(entity, autoSaveData)
	if not autoSaveData.hairSelection then
		AvatarUtils.hairAssetIdRecord = nil

		return
	end

	local modelInfo = entity.eModel.modelModelView.modelInfo
	local partModelInfo = modelInfo.partModelInfo
	local presetKey = autoSaveData.presetKey or entity.avatarPresetKey
	local param = {
		entityId = presetKey
	}

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local configId = autoSaveData.hairSelection[partId]

		AppearanceEffectUtils.setAppearance(entity, partId, configId)
		pg.game.avatar:updateHairSelection(partId, configId, "parseCustomDataFromDisk")

		local configData = AppearanceData[configId] or {}

		if configData.res then
			table.insert(param, {
				isApply = true,
				resId = configData.res,
				partId = partId
			})
		else
			local resId = partModelInfo:GetPartResId(partId)

			if not string.isNilOrEmpty(resId) then
				table.insert(param, {
					isApply = false,
					resId = resId,
					partId = partId
				})
			end
		end
	end

	local hairAssetId = autoSaveData.hairAssetId

	if not hairAssetId or hairAssetId == -1 then
		local hairSuitId = LuaUIUtils.tryGetHairSuitId(autoSaveData.hairSelection)
		local hairSuitInfo = hairSuitId and AvatarHairSuitData[hairSuitId]

		hairAssetId = hairSuitInfo and hairSuitInfo.assetId
	end

	AvatarUtils.hairAssetIdRecord = nil

	if hairAssetId and hairAssetId ~= -1 then
		avatarHair:OnHairSuitChanged(param, hairAssetId)
		avatarHair:SetAssetIdAndLoad(hairAssetId)

		AvatarUtils.hairAssetIdRecord = hairAssetId
	end

	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	if avatarScene then
		avatarScene:changeHair(param)
	else
		for _, info in ipairs(param) do
			if info.isApply then
				partModelInfo:ModifyPartItem(info.resId, {
					info.partId
				})
			else
				partModelInfo:RemovePartItem(info.resId)
			end
		end
	end
end

local PART_ASSET_ID_FIELDS = {
	makeup = "makeupPartAssetId",
	hair = "hairPartAssetId",
	body = "bodyPartAssetId",
	face = "facePartAssetId"
}
local avatarConfigParsedCache = {}
local appearanceResToConfigIdCache

local function lookupConfigIdByResId(resId)
	if string.isNilOrEmpty(resId) then
		return nil
	end

	if not appearanceResToConfigIdCache then
		appearanceResToConfigIdCache = {}

		for configId, data in pairs(AppearanceData) do
			if data.res then
				appearanceResToConfigIdCache[data.res] = configId
			end
		end
	end

	return appearanceResToConfigIdCache[resId]
end

local function normalizeModelResPartEntry(entry)
	if type(entry) ~= "table" and type(entry) ~= "userdata" then
		return {
			resId = ""
		}
	end

	local resId = entry.resId or ""
	local configId = entry.configId

	if (not configId or configId <= 0) and not string.isNilOrEmpty(resId) then
		configId = lookupConfigIdByResId(resId)
	end

	local reactionKey = entry.reactionKey

	if reactionKey and reactionKey <= 0 then
		reactionKey = nil
	end

	return {
		resId = resId,
		configId = configId,
		reactionKey = reactionKey
	}
end

local function buildModelResPartsFromJsonList(modelResParts)
	local result = {}

	if type(modelResParts) ~= "table" and type(modelResParts) ~= "userdata" then
		return result
	end

	for _, entry in ipairs(modelResParts) do
		if entry and entry.partId then
			result[entry.partId] = normalizeModelResPartEntry(entry)
		end
	end

	return result
end

local function parseAvatarConfig(avatarConfigCompressed)
	if avatarConfigParsedCache[avatarConfigCompressed] then
		return avatarConfigParsedCache[avatarConfigCompressed]
	end

	local result = {
		partAssetIds = {},
		modelResParts = {}
	}

	avatarConfigParsedCache[avatarConfigCompressed] = result

	if string.isNilOrEmpty(avatarConfigCompressed) then
		return result
	end

	local ok, configStr = pcall(decompressFromStr, avatarConfigCompressed)

	if not ok or string.isNilOrEmpty(configStr) then
		return result
	end

	local decodeOk, config = pcall(json.decode, configStr)

	if not decodeOk or type(config) ~= "table" and type(config) ~= "userdata" then
		return result
	end

	for part, field in pairs(PART_ASSET_ID_FIELDS) do
		local partAssetId = config[field]

		if partAssetId and partAssetId > 0 then
			result.partAssetIds[part] = partAssetId
		end
	end

	result.modelResParts = buildModelResPartsFromJsonList(config.modelResParts)

	return result
end

local function parsePartAssetIdsFromAvatarConfig(avatarConfigCompressed)
	return parseAvatarConfig(avatarConfigCompressed).partAssetIds
end

local function getPartAssetIdFromModelInfo(modelInfo, part)
	if part == "face" then
		return modelInfo:GetFacePartAssetId()
	elseif part == "body" then
		return modelInfo:GetBodyPartAssetId()
	elseif part == "makeup" then
		return modelInfo:GetMakeUpPartAssetId()
	elseif part == "hair" then
		return modelInfo:GetOriginHairAssetId()
	end
end

local function getRuntimeModelResPart(entity, partId)
	if not entity or not entity.eModel then
		return nil
	end

	local modelInfo = entity.eModel.modelModelView.modelInfo
	local partModelInfo = modelInfo.partModelInfo
	local resId = partModelInfo:GetPartResId(partId)

	if string.isNilOrEmpty(resId) then
		resId = ""
	end

	local configId

	if pg.game.avatar and pg.game.avatar.hairSelection then
		configId = pg.game.avatar.hairSelection[partId]
	end

	if (not configId or configId == 0) and not string.isNilOrEmpty(resId) then
		configId = lookupConfigIdByResId(resId)
	end

	if string.isNilOrEmpty(resId) and not configId then
		return nil
	end

	return normalizeModelResPartEntry({
		resId = resId,
		configId = configId
	})
end

local function getStaticModelResPart(presetKey, partId)
	local presetData = presetKey and AvatarModelResData[presetKey]

	if not presetData then
		return nil
	end

	local entry = presetData[partId]

	if not entry then
		return nil
	end

	return normalizeModelResPartEntry(entry)
end

function AvatarUtils.getModelResData(entity, presetKey)
	presetKey = presetKey or entity and entity.avatarPresetKey

	local parsedModelResParts

	if entity and not string.isNilOrEmpty(entity.avatarConfig) then
		parsedModelResParts = parseAvatarConfig(entity.avatarConfig).modelResParts

		if next(parsedModelResParts) then
			return parsedModelResParts
		end
	end

	local runtimeResult = {}
	local GameConst = CS.FunPlus.WorldX.Const.GameConst
	local hasRuntimeData = false

	if entity and entity.eModel then
		local partIds = {
			GameConst.PART_BODY,
			GameConst.PART_FACE,
			GameConst.PART_EYELASH,
			GameConst.PART_FACE_HIGH_LIGHT
		}

		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			partIds[#partIds + 1] = partId
		end

		for _, partId in ipairs(partIds) do
			local entry = getRuntimeModelResPart(entity, partId)

			if entry then
				runtimeResult[partId] = entry
				hasRuntimeData = true
			end
		end
	end

	if hasRuntimeData then
		return runtimeResult
	end

	local staticData = presetKey and AvatarModelResData[presetKey] or {}
	local staticResult = {}

	for partId, entry in pairs(staticData) do
		staticResult[partId] = normalizeModelResPartEntry(entry)
	end

	return staticResult
end

function AvatarUtils.getModelResPart(entity, presetKey, partId)
	if entity and not string.isNilOrEmpty(entity.avatarConfig) then
		local parsedModelResParts = parseAvatarConfig(entity.avatarConfig).modelResParts
		local entry = parsedModelResParts[partId]

		if entry then
			return entry
		end
	end

	local runtimeEntry = getRuntimeModelResPart(entity, partId)

	if runtimeEntry then
		return runtimeEntry
	end

	presetKey = presetKey or entity and entity.avatarPresetKey

	return getStaticModelResPart(presetKey, partId) or {
		resId = ""
	}
end

local function buildHairSelectionTable()
	local hairSelection = {}

	if pg.game.avatar and pg.game.avatar.hairSelection then
		for partId, configId in pairs(pg.game.avatar.hairSelection) do
			if configId and configId > 0 then
				hairSelection[partId] = configId
			end
		end
	end

	return hairSelection
end

function AvatarUtils.getCustomDataStringForSave()
	avatarMgr:SyncModelResHairConfigIds(buildHairSelectionTable())

	return avatarMgr:GetCustomDataString()
end

function AvatarUtils.getPartAssetId(entity, part, presetKey)
	if entity and entity.eModel then
		local partAssetId = getPartAssetIdFromModelInfo(entity.eModel.modelModelView.modelInfo, part)

		if partAssetId and partAssetId > 0 then
			return partAssetId
		end
	end

	if entity and not string.isNilOrEmpty(entity.avatarConfig) then
		local partIds = parsePartAssetIdsFromAvatarConfig(entity.avatarConfig)
		local partAssetId = partIds[part]

		if partAssetId and partAssetId > 0 then
			return partAssetId
		end
	end

	if presetKey then
		local presetDetail = AvatarPresetDetailData[presetKey]

		if presetDetail then
			return presetDetail[part]
		end
	end
end

function AvatarUtils.getPartAssetIdByPreset(presetKey, part)
	if not presetKey then
		return nil
	end

	if pg.me then
		local playerPresetKey = pg.game.avatar:getPresetKey(pg.me)

		if playerPresetKey == presetKey then
			local partAssetId = AvatarUtils.getPartAssetId(pg.me, part, presetKey)

			if partAssetId and partAssetId > 0 then
				return partAssetId
			end
		end
	end

	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	if avatarScene then
		local entity = avatarScene:getCurEntity()

		if entity and entity.avatarPresetKey == presetKey then
			local partAssetId = AvatarUtils.getPartAssetId(entity, part, presetKey)

			if partAssetId and partAssetId > 0 then
				return partAssetId
			end
		end
	end

	local presetDetail = AvatarPresetDetailData[presetKey]

	return presetDetail and presetDetail[part]
end

function AvatarUtils.getCurrentPartAssetId(avatarScene, presetKey, part)
	local entity = avatarScene and avatarScene:getCurEntity()

	return AvatarUtils.getPartAssetId(entity, part, presetKey)
end

function AvatarUtils.parseCustomDataFromDisk(entity, autoSaveData)
	if not entity then
		return
	end

	avatarMgr:SetAvatarInstance(entity.eModel)
	avatarMgr:InitAvatarPart()

	local modelView = entity.eModel.modelModelView
	local modelInfo = modelView.modelInfo

	modelInfo:ParseCustomData(decompressFromStr(autoSaveData.avatarConfig))
	modelInfo:ApplyCustomPartAssetIds()
	modelInfo:ProcessCustomData()
	restoreHairFromAutoSave(entity, autoSaveData)

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		if autoSaveData.hairCustomData and autoSaveData.hairCustomData[partId] then
			modelInfo:ParseHairCustomData(partId, decompressFromStr(autoSaveData.hairCustomData[partId]))
			modelInfo:ProcessHairCustomData(partId)
		end
	end

	avatarHair:InitColors()
	ClientModelUtils.refreshModels(entity, modelView)

	local bodySize = modelView.modelInfo:GetBodySize()

	entity:setModelScale(ClientConst.MODEL_SCALE_KEY.AVATAR, bodySize)
end

function AvatarUtils.refreshWithCustomData(modelView, playerEntity)
	if playerEntity.refreshModel then
		playerEntity:refreshModel()
	else
		ClientModelUtils.refreshModels(playerEntity, modelView)
	end
end

local function getAvatarShareService()
	return require("Guis.Utils.AvatarShareService")
end

function AvatarUtils.onUploadAvatar(avatarType)
	if avatarType == AvatarUtils.AVATAR_TYPE.HAIR then
		getAvatarShareService().exportHair()
	else
		getAvatarShareService().exportFace()
	end
end

function AvatarUtils.scanBuffer()
	getAvatarShareService().tryImportFromClipboard()
end

function AvatarUtils.saveOriginData()
	getAvatarShareService().saveOriginSnapshot()
end

function AvatarUtils.showAvatarImportConfirm(id, customDataStr)
	getAvatarShareService().previewImport(id, customDataStr)
end

function AvatarUtils.openWorkShop(avatarType, designType)
	if avatarType == AvatarUtils.AVATAR_TYPE.FACE and designType == AvatarUtils.DESIGN_TYPE.FACE then
		getAvatarShareService().openFaceWorkShop()

		return
	end

	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	if not avatarScene then
		return
	end

	local presetKey = pg.game.avatar:getPresetKey(pg.me)

	pg.global.ui:open(UIConst.UI_ID_AVATAR, {
		isDesignMode = true,
		presetKey = presetKey,
		avatarType = avatarType,
		designType = designType
	}, function()
		avatarScene:showAvatar(presetKey)
		avatarScene:setAvatarCameraModeCloseHead()
	end)
end

function AvatarUtils.getAllBackgroundData()
	return AppearanceBackGroundData
end

function AvatarUtils.getDefaultAppearanceBackgroundData()
	for bgId, bgData in pairs(AppearanceBackGroundData) do
		if bgData.initialClaim == 1 and bgData.bgPrefab == AddressDataConst.AVATAR_SCENE_BG_DEFAULT then
			return bgId, bgData
		end
	end

	return nil, nil
end

function AvatarUtils.getPhotographyStudioBackgroundRes(bgId)
	bgId = tonumber(bgId)

	local backgroundData = bgId and AppearanceBackGroundData[bgId]

	if backgroundData then
		return backgroundData.bgPrefab, bgId
	end

	return AddressDataConst.AVATAR_SCENE_BG_DEFAULT
end

function AvatarUtils.isBgUnlocked(bgId)
	if AppearanceBackGroundData[bgId] and AppearanceBackGroundData[bgId].initialClaim == 1 then
		return true
	end

	if pg.me then
		return pg.me.appearanceBackgrounds[bgId] == true
	end

	return false
end

function AvatarUtils.getCurSetBgRes(type)
	local bgId, bgData = AvatarUtils.getDefaultAppearanceBackgroundData()

	return bgData and bgData.bgPrefab or AddressDataConst.AVATAR_SCENE_BG_DEFAULT, bgId
end

function AvatarUtils.setBgRes(id)
	pg.me:serverMsg("RPC_CS_SetAppearanceBackGround", Const.APPEARANCE_BACKGROUND_TYPE.Player, id)
end

function AvatarUtils.setThemePhotographyStudioUid(studioUid)
	if not pg.me then
		return
	end

	local value = studioUid and tostring(studioUid) or ""
	local current = pg.me.themePhotographyStudioUid and tostring(pg.me.themePhotographyStudioUid) or ""

	pg.me.themePhotographyStudioUid = value

	if current ~= value then
		pg.me:serverMsg("RPC_CS_ChangeThemePhotographyStudioUid", value)
	end
end

function AvatarUtils.canUsePhotographyStudio(studioUid, info)
	if not studioUid or not pg.me then
		return false
	end

	info = info or pg.me:getStudioInfo(studioUid)

	if not info then
		return false
	end

	local selfUid = tostring(pg.me.uid)

	if tostring(info.masterUid) == selfUid then
		return true
	end

	for _, member in ipairs(info.members or EMPTY_TABLE) do
		if tostring(member.uid) == selfUid then
			return true
		end
	end

	return false
end

function AvatarUtils.renderBackGroundSwitchSelector(selector, isCreate, options)
	if options == nil then
		options = {}
	end

	function selector.luaRenderPopup(popup, list)
		local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
		local objectReference = popup:GetComponent("ObjectReference")
		local bgList = objectReference:GetRefValue("bgList")
		local studioContentLoading = {}
		local studioContentResolved = {}
		local refreshBackgroundList

		local function loadStudioCover(button, data, photoUImage, adaptationBoxUXAdaptionRect)
			local studioUid = data.studioUid
			local coverVersion = data.coverVersion

			PhotographyStudioUtils.loadPhotographyStudioCover(studioUid, coverVersion, function(sprite, success)
				if not success then
					return
				end

				local currentData = button.dataFromUList

				if currentData == data and currentData.studioUid == studioUid and currentData.coverVersion == coverVersion then
					photoUImage.url = nil
					photoUImage.sprite = sprite

					local texture = sprite.texture

					adaptationBoxUXAdaptionRect.customResolution = Vector2(texture.width, texture.height)

					adaptationBoxUXAdaptionRect:UpdateAdaptation()
				end
			end)
		end

		local function requestStudioContent(studioUid)
			if studioContentLoading[studioUid] or studioContentResolved[studioUid] then
				return
			end

			studioContentLoading[studioUid] = true

			pg.me:fetchStudioContent(studioUid, function(content, ok)
				studioContentLoading[studioUid] = nil
				studioContentResolved[studioUid] = true

				if not ok then
					return
				end

				if refreshBackgroundList then
					refreshBackgroundList()
				end
			end)
		end

		function bgList.luaRenderItem(button, _, data)
			local objectReference1 = button:GetComponent("ObjectReference")
			local photoUImage = objectReference1:GetRefValue("photoUImage")
			local nameUBaseText = objectReference1:GetRefValue("nameUBaseText")
			local adaptationBoxUXAdaptionRect = objectReference1:GetRefValue("adaptationBoxUXAdaptionRect")
			local imageUrl

			if data.isStudio then
				imageUrl = STUDIO_DEFAULT_COVER_URL
			else
				imageUrl = data.icon
			end

			photoUImage:SetUrlWithCallback(imageUrl, function()
				if button.dataFromUList == data and photoUImage.url == imageUrl then
					local texture = photoUImage.sprite.texture

					adaptationBoxUXAdaptionRect.customResolution = Vector2(texture.width, texture.height)

					adaptationBoxUXAdaptionRect:UpdateAdaptation()
				end
			end, nil, true)

			if data.isStudio then
				if data.coverVersion == nil then
					requestStudioContent(data.studioUid)
				else
					loadStudioCover(button, data, photoUImage, adaptationBoxUXAdaptionRect)
				end
			end

			local displayName = data.isStudio and data.name or pg.getGameString("APPEARANCE_DELETE_SCENE_TEXT")

			ClientTextUtils.setText(nameUBaseText, displayName or "")

			button.name = data.isStudio and "studio_" .. tostring(data.studioUid) or tostring(data.id)

			button:TryChangePage("Status", 0)

			local selectedStudioUid = options.getSelectedStudioUid and options.getSelectedStudioUid()

			if data.isStudio then
				button.isSelected = selectedStudioUid ~= nil and tostring(selectedStudioUid) == tostring(data.studioUid)
			else
				button.isSelected = selectedStudioUid == nil and avatarScene.bgId == data.id
			end

			function button.luaClick()
				if data.isStudio then
					if not options.onSelectStudio then
						return
					end

					options.onSelectStudio(data.studioUid)
				else
					if not isCreate then
						AvatarUtils.setThemePhotographyStudioUid("")

						if avatarScene.clearPhotographyStudioDisplayPreset then
							avatarScene:clearPhotographyStudioDisplayPreset()
						end
					end

					if options.onSelectBackground then
						options.onSelectBackground(data.id)
					end

					avatarScene:setBackground(data.res, data.id)

					if isCreate then
						pg.game.avatar.createPlayerSceneBgId = data.id
					else
						AvatarUtils.setBgRes(data.id)
					end
				end

				local btns = bgList:GetAllButtons()

				for i = 0, btns.Length - 1 do
					btns[i].isSelected = false
				end

				button.isSelected = true
			end
		end

		function refreshBackgroundList()
			local bgListData = {}
			local defaultBgId, defaultBgData = AvatarUtils.getDefaultAppearanceBackgroundData()

			if defaultBgData then
				bgListData[#bgListData + 1] = {
					id = defaultBgId,
					name = defaultBgData.name,
					res = defaultBgData.bgPrefab,
					icon = defaultBgData.icon
				}
			end

			local studioItems

			if options.getStudioItems then
				studioItems = options.getStudioItems()
			end

			if studioItems then
				for _, studio in ipairs(studioItems) do
					if studio.isModified then
						bgListData[#bgListData + 1] = {
							isStudio = true,
							studioUid = studio.studioUid,
							name = studio.name,
							coverVersion = studio.coverVersion
						}
					elseif studio.isModified == nil then
						requestStudioContent(studio.studioUid)
					end
				end
			end

			bgList:SetList(bgListData)
		end

		refreshBackgroundList()
	end

	selector:SetOptions()
end

function AvatarUtils.getPhotographyStudioBackgroundItems()
	local result = {}

	if not pg.me then
		return result
	end

	local studios = pg.me:getAllStudios()

	if studios == nil then
		return result
	end

	for studioUid, info in pairs(studios) do
		if tostring(info.masterUid) == tostring(pg.me.uid) then
			local cachedContent = pg.me:getCachedPhotographyStudioContent(studioUid)
			local coverVersion, isModified

			if type(cachedContent) == "table" or type(cachedContent) == "userdata" then
				coverVersion = tonumber(cachedContent.coverVersion) or 0
				isModified = (tonumber(cachedContent.version) or PhotographyStudioUtils.CONTENT_VERSION) > PhotographyStudioUtils.CONTENT_VERSION
			end

			local name = info.name

			if not name or name == "" then
				name = pg.getGameString("PHOTO_STUDIO_DEFAULT_NAME")
			end

			result[#result + 1] = {
				isMine = true,
				studioUid = studioUid,
				name = name,
				slotId = info.slotId,
				coverImageId = PhotographyStudioUtils.genPhotographyStudioCoverImageId(studioUid),
				coverVersion = coverVersion,
				isModified = isModified
			}
		end
	end

	table.sort(result, function(a, b)
		if a.isMine ~= b.isMine then
			return a.isMine
		end

		if a.isMine and a.slotId ~= b.slotId then
			return (a.slotId or math.huge) < (b.slotId or math.huge)
		end

		return tostring(a.studioUid) < tostring(b.studioUid)
	end)

	return result
end

function AvatarUtils.renderPhotographyStudioBackgroundSelector(selector, isCreate)
	AvatarUtils.renderBackGroundSwitchSelector(selector, isCreate, {
		getStudioItems = function()
			return AvatarUtils.getPhotographyStudioBackgroundItems()
		end,
		getSelectedStudioUid = function()
			local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

			return avatarScene and avatarScene:getCurrentPhotographyStudioUid()
		end,
		onSelectStudio = function(studioUid)
			local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

			if avatarScene and AvatarUtils.canUsePhotographyStudio(studioUid) then
				AvatarUtils.setThemePhotographyStudioUid(studioUid)
				avatarScene:applyPhotographyStudioDisplayPreset(studioUid)
			end
		end
	})
end

function AvatarUtils.refreshNPCModelData(configData)
	if not configData.appearanceResID then
		return false
	end

	local resId = ""

	if configData.appearanceToPrefabResID then
		resId = configData.appearanceToPrefabResID
	end

	if resId == "" then
		return false
	end

	local assetExist = pg.global.resMgr:CheckAssetExist(resId)

	return assetExist, resId
end

AvatarUtils.OP_NAME = {
	irisFocus = 20,
	pupilZoom = 19,
	irisSize = 18,
	normalStrength = 17,
	roughness = 16,
	metallic = 15,
	emissiveColor = 14,
	color2 = 13,
	scaleZ = 11,
	scaleY = 10,
	scaleX = 9,
	scale = 8,
	rotationZ = 7,
	rotationY = 6,
	rotationX = 5,
	rotation = 4,
	color = 12,
	positionY = 2,
	positionX = 1,
	position = 0,
	positionZ = 3,
	irisRotSpeed = 26,
	reflectance = 30,
	opacity = 29,
	seqRotSpeed = 28,
	seqSpeed = 27,
	emission = 25,
	gradient = 24,
	dye2 = 23,
	dye1 = 22,
	baseColor = 21
}
AvatarUtils.AVATAR_TYPE = {
	HAIR = "hair",
	CLOTHES = "clothes",
	BODY = "body",
	MAKEUP = "makeup",
	FACE = "face"
}
AvatarUtils.HAIR_DESIGN_TYPE = {
	PRESET = "preset",
	SETTING = "setting",
	COLOR = "color"
}
AvatarUtils.DESIGN_TYPE = {
	COSTUME = 3,
	HAIR = 4,
	FACE = 1
}
AvatarUtils.PRESET_STATE = {
	LOCKED = "Locked",
	NORMAL = "Normal",
	EMPTY = "Empty"
}
AvatarUtils.PROPERTY = {
	CUSTOM_HAIR = "customHair",
	REFRESH_MODELS = "refreshModels"
}
AvatarUtils.COLOR_PANEL = {
	HAIR_COLOR = 6,
	CLOTH_NORMAL_COLOR = 1,
	MAKEUP_COLOR = 7
}

function AvatarUtils.getColorAreas(colorPanelIndex)
	local data = DesignWorkShopConsumeData[colorPanelIndex]

	if not data then
		return nil
	end

	if not data.colourX or not data.colourY then
		return nil
	end

	return {
		data.colourX[1] or 0,
		data.colourX[2] or 1,
		data.colourY[1] or 0,
		data.colourY[2] or 1
	}
end

function AvatarUtils:addPresetAvatarSprite(sprite, callback)
	local picId = Utils.genPresetAvatarPicId(IDManager.genStrID(), pg.global.platform:getSdkFpId())

	ClientUtils.uploadPicture(picId, sprite, callback)
end

return AvatarUtils
