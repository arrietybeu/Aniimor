-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\PhotoFuncPlayerPoseUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoFuncPlayerPoseUIComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PhotoFuncPlayerPoseUIComponent = Class.LightClass("PhotoFuncPlayerPoseUIComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local Time = require("Core.Common.Time")
local PlayableConst = require("Common.Const.PlayableConst")
local AppearanceAction = require("Data.appearance_action_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local PhotographyAssetRedDotUtils = require("Utils.PhotographyAssetRedDotUtils")
local RedDotConst = require("Const.RedDotConst")
local defaultAnim = PlayableConst.Idle

function PhotoFuncPlayerPoseUIComponent:getPlayerAnimLayer()
	return PlayableConst.AnimationLayer.HUMAN_LAYER_BASE
end

function PhotoFuncPlayerPoseUIComponent:shouldResetPlayerAnimOnDestroy()
	return true
end

function PhotoFuncPlayerPoseUIComponent:getTargetPlayerEntity()
	return self.ctrl:getSelfEntity()
end

function PhotoFuncPlayerPoseUIComponent:refreshTargetPlayerBodyType()
	local targetEntity = self:getTargetPlayerEntity()
	local presetKey = targetEntity and pg.game.avatar:getPresetKey(targetEntity)

	if not presetKey and targetEntity then
		presetKey = targetEntity.avatarPresetKey
	end

	local avatarPresetData = presetKey and pg.game.avatar:getAvatarPresetData(presetKey)

	self.bodyType = avatarPresetData and avatarPresetData.body
end

function PhotoFuncPlayerPoseUIComponent:onPlayerDynamicPoseStateChanged(state)
	return
end

PhotoFuncPlayerPoseUIComponent.CameraPoseType = {
	Static = 1,
	Dynamic = 2
}
PhotoFuncPlayerPoseUIComponent.CameraPoseTabs = {
	{
		label = "PHOTO_POSE_STATIC",
		id = PhotoFuncPlayerPoseUIComponent.CameraPoseType.Static
	},
	{
		label = "PHOTO_POSE_DYNAMIC",
		id = PhotoFuncPlayerPoseUIComponent.CameraPoseType.Dynamic
	}
}

function PhotoFuncPlayerPoseUIComponent:onCtor(info)
	if not info then
		return
	end

	self.preset = info.preset
end

function PhotoFuncPlayerPoseUIComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.selectedPetUWidget = self.objectReference:GetRefValue("selectedPetUWidget")
	self.tabUWidget = self.objectReference:GetRefValue("tabUWidget")
	self.listTabUList = self.objectReference:GetRefValue("listTabUList")
	self.listPoseUList = self.objectReference:GetRefValue("listPoseUList")
	self.focalLengthSliderUWidget = self.objectReference:GetRefValue("focalLengthSliderUWidget")
	self.btnPlayOrStopUButton = self.objectReference:GetRefValue("btnPlayOrStopUButton")
	self.dynamicPoseUSlider = self.objectReference:GetRefValue("dynamicPoseUSlider")
end

function PhotoFuncPlayerPoseUIComponent:initView()
	self:initPhotoAction()

	self.frameUpdateTimer = self:startTimer(function()
		self:frameUpdate()
	end, 0.033, true)
end

function PhotoFuncPlayerPoseUIComponent:onDestroy()
	UIComponent.onDestroy(self)

	if self.curPlayPlayerPoseAni then
		local selfEntity = self:getTargetPlayerEntity()

		if selfEntity and self:shouldResetPlayerAnimOnDestroy() then
			selfEntity:playAnimation(defaultAnim, nil, nil, nil, self:getPlayerAnimLayer())
		end

		self.curPlayPlayerPoseAni = nil
		self.curPlayPlayerPoseId = nil
	end
end

function PhotoFuncPlayerPoseUIComponent:initPhotoAction()
	self.changePoseTime = 0
	self.changeDynamicPoseInterval = 100
	self.curPoseType = self.CameraPoseType.Static

	self:refreshTargetPlayerBodyType()

	function self.listTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(txtNameUBaseText, pg.getGameString(data.label))

		local subTabPath = PhotographyAssetRedDotUtils.getSubTabPath(PhotographyAssetRedDotUtils.AssetType.PlayerPose, data.id)

		pg.global.setPreViewRedDot(subTabPath, button, function()
			return PhotographyAssetRedDotUtils.getRedDotStyle(PhotographyAssetRedDotUtils.AssetType.PlayerPose, data.id)
		end)

		function button.luaSelectChanged(isSelected)
			if not isSelected then
				return
			end

			self.curPoseType = data.id

			self:refreshPoseFunc(data.id)
		end

		PhotographyStudioUtils.bindTabEnterFirstItem(button, self.listPoseUList)
	end

	function self.listPoseUList.luaRenderItem(button, index, data)
		if data.empty then
			local itemPath = PhotographyAssetRedDotUtils.getItemPath(PhotographyAssetRedDotUtils.AssetType.PlayerPose, self.poseTypeId, "empty")

			pg.global.setRedDot(itemPath, button, false, RedDotConst.RedDotStyle.NEW)

			local objectReference = button:GetComponent("ObjectReference")
			local iconUImage = objectReference:GetRefValue("iconUImage")

			iconUImage.url = nil

			button:TryChangePage("Lock", 0)

			button.interactable = false

			return
		end

		button.interactable = true

		if not data.id then
			local itemPath = PhotographyAssetRedDotUtils.getItemPath(PhotographyAssetRedDotUtils.AssetType.PlayerPose, self.poseTypeId, "none")

			pg.global.setRedDot(itemPath, button, false, RedDotConst.RedDotStyle.NEW)
			button:TryChangePage("Lock", 0)

			button.visualInteractable = true
			button.skipInListSwitch = false

			return
		end

		data.unlock = PhotographyAssetRedDotUtils.isAssetUnlocked(PhotographyAssetRedDotUtils.AssetType.PlayerPose, data.id)
		data.showRedDot = PhotographyAssetRedDotUtils.isAssetNew(PhotographyAssetRedDotUtils.AssetType.PlayerPose, data.id)

		local itemPath = PhotographyAssetRedDotUtils.getItemPath(PhotographyAssetRedDotUtils.AssetType.PlayerPose, data.params.photo, data.id)

		pg.global.setRedDot(itemPath, button, data.showRedDot, RedDotConst.RedDotStyle.NEW)
		button:TryChangePage("Lock", data.unlock and 0 or 1)

		button.visualInteractable = data.unlock
		button.skipInListSwitch = not data.unlock

		if data.params.icon then
			local objectReference = button:GetComponent("ObjectReference")
			local iconUImage = objectReference:GetRefValue("iconUImage")

			iconUImage.url = data.params.icon
		end

		if self.poseTypeId == self.CameraPoseType.Dynamic and data.selected then
			self.focalLengthSliderUWidget:SetActive(true)

			if self.curPlayerDynamicPoseState then
				self.curDynamicPoseState = self.curPlayerDynamicPoseState
				self.curPlayPoseEnt = self:getTargetPlayerEntity()
				self.curPlayPoseAni = self.curPlayPlayerPoseAni

				self:setDynamicPoseUSliderMaxValue(self.curDynamicPoseState.Length)
			end
		end
	end

	function self.listPoseUList.luaClick(button, data)
		if data.id and not PhotographyAssetRedDotUtils.isAssetUnlocked(PhotographyAssetRedDotUtils.AssetType.PlayerPose, data.id) then
			PhotographyStudioUtils.showLockedAssetTip(data.id, button)

			return
		end

		self.preset = nil

		local ent = self:getTargetPlayerEntity()
		local config = data.params

		self:clearCurPlayingPlayerAni()

		self.curPlayPlayerPoseId = data.id

		if self.ctrl.recordHistoryStep then
			ent.studioPlayerPoseId = data.id
		end

		self:playActionInner(config, ent)
		self:recordPlayingAni()

		if config and config.name then
			self.ctrl:showParamTip(1, pg.getGameString("PHOTO_PLAYER_POSE"), pg.getLocalizationText(config.name))
		end

		if self.ctrl.recordHistoryStep then
			self.ctrl:recordHistoryStep("player_pose")
		end

		if data.id then
			PhotographyAssetRedDotUtils.markAssetViewed(PhotographyAssetRedDotUtils.AssetType.PlayerPose, data.id)
			self.listPoseUList:RefreshList()
			self.ctrl:onPhotoAssetViewed(PhotographyAssetRedDotUtils.AssetType.PlayerPose, data.params.photo)
		end
	end

	function self.dynamicPoseUSlider.luaValueChanged(newValue)
		if self.curDynamicPoseState then
			if self.changePoseTime > 0 and self.changePoseTime + self.changeDynamicPoseInterval > Time.realSecondCache * 1000 then
				return
			end

			self.changePoseTime = Time.realSecondCache * 1000
			self.curDynamicPoseState = self.curPlayPoseEnt:playRawAnimation(self.curPlayPoseAni, 0, newValue, 1, nil, self:getPlayerAnimLayer())

			if self.sliderDragging or not self.autoPlayDynamicPose then
				self.curDynamicPoseState:SetSpeed(0)
			end

			self:onPlayerDynamicPoseStateChanged(self.curDynamicPoseState)
		end

		if self.ctrl:checkTimePause() then
			local ent = self:getTargetPlayerEntity()

			if ent then
				ent:setPhotoTimePauseAnimPlaying(false)
			end
		end
	end

	function self.dynamicPoseUSlider.luaWidgetBeginDrag()
		self.sliderDragging = true

		if self.curDynamicPoseState then
			self.curDynamicPoseState:SetSpeed(0)
		end

		if self.ctrl:checkTimePause() then
			local ent = self:getTargetPlayerEntity()

			if ent then
				ent:setPhotoTimePauseAnimPlaying(false)
			end
		end
	end

	function self.dynamicPoseUSlider.luaWidgetEndDrag()
		self.sliderDragging = false

		if not self.autoPlayDynamicPose then
			return
		end

		self.btnPlayOrStopUButton:TryChangePage("IsPlay", 1)

		if self.curDynamicPoseState then
			self.curDynamicPoseState:SetSpeed(1)
		end

		if self.ctrl:checkTimePause() then
			local ent = self:getTargetPlayerEntity()

			if ent then
				ent:setPhotoTimePauseAnimPlaying(true)
			end
		end

		if self.ctrl:checkTimePause() then
			local ent = self:getTargetPlayerEntity()

			if ent then
				ent:setPhotoTimePauseAnimPlaying(false)
			end
		end
	end

	function self.btnPlayOrStopUButton.luaClick()
		self.autoPlayDynamicPose = not self.autoPlayDynamicPose
		self.resumeDynamicPoseAfterTimePause = false

		self.btnPlayOrStopUButton:TryChangePage("IsPlay", self.autoPlayDynamicPose and 1 or 0)

		if self.curDynamicPoseState then
			self.curDynamicPoseState:SetSpeed(self.autoPlayDynamicPose and 1 or 0)
		end

		if self.ctrl:checkTimePause() then
			local ent = self:getTargetPlayerEntity()

			if ent then
				ent:setPhotoTimePauseAnimPlaying(self.autoPlayDynamicPose)
			end
		end
	end

	if self.preset then
		self:applyPreset(self.preset)
	end
end

function PhotoFuncPlayerPoseUIComponent:getAvailablePoseTabs()
	local actionData = self:getPhotoActionData(AppearanceAction, self.curPlayPlayerPoseId)
	local poseTabs = {}

	for _, tabData in ipairs(self.CameraPoseTabs) do
		local poseList = actionData[tabData.id]

		if poseList and #poseList > 0 then
			poseTabs[#poseTabs + 1] = tabData
		end
	end

	return poseTabs
end

function PhotoFuncPlayerPoseUIComponent:refreshPoseTabs()
	local poseTabs = self:getAvailablePoseTabs()

	self.listTabUList:SetList(poseTabs)
	self.listTabUList:DeselectAll()

	if #poseTabs > 0 then
		local currentPoseConfig = self.curPlayPlayerPoseId and AppearanceAction[self.curPlayPlayerPoseId]
		local preferredPoseType = currentPoseConfig and currentPoseConfig.photo or self.curPoseType
		local selectedIndex = 0

		for index, tabData in ipairs(poseTabs) do
			if tabData.id == preferredPoseType then
				selectedIndex = index - 1

				break
			end
		end

		self.listTabUList:SelectItem(selectedIndex)
	else
		self.curPoseType = nil
		self.poseTypeId = nil

		self.listPoseUList:SetList({})
	end

	self.tabUWidget:SetActive(#poseTabs > 1)
end

function PhotoFuncPlayerPoseUIComponent:refreshUI()
	if not self.haveRefreshed then
		self:refreshPoseTabs()

		self.haveRefreshed = true
	end

	if self.preset and self.preset.playerPoseId and self.curPoseType then
		self:refreshPoseFunc(self.curPoseType)
	end
end

function PhotoFuncPlayerPoseUIComponent:applyPreset(preset)
	if preset.playerPoseId then
		local config = AppearanceAction[preset.playerPoseId]

		self.curPlayPlayerPoseId = preset.playerPoseId
		self.curPlayPlayerPoseAni = self:playActionInner(config, self:getTargetPlayerEntity())
	end
end

function PhotoFuncPlayerPoseUIComponent:saveToPreset(preset)
	preset.playerPoseId = self.curPlayPlayerPoseId
end

function PhotoFuncPlayerPoseUIComponent:frameUpdate()
	if self.autoPlayDynamicPose and self.curDynamicPoseState and not self.sliderDragging then
		if not self.curDynamicPoseState.IsPlaying then
			self.curDynamicPoseState = self.curPlayPoseEnt:playRawAnimation(self.curPlayPoseAni, nil, 0, 1, nil, self:getPlayerAnimLayer())

			self.curDynamicPoseState:SetLogicLoop(true)

			self.curPlayerDynamicPoseState = self.curDynamicPoseState

			self:onPlayerDynamicPoseStateChanged(self.curDynamicPoseState)
			self.dynamicPoseUSlider:SetValueWithoutCallback(0)
		else
			self.dynamicPoseUSlider:SetValueWithoutCallback(self.curDynamicPoseState.Time % self.curDynamicPoseState.Length)
		end
	end
end

function PhotoFuncPlayerPoseUIComponent:pausePhotoSubject(resumeDynamicPose)
	if resumeDynamicPose == nil then
		resumeDynamicPose = self.autoPlayDynamicPose and self.currentPoseIsDynamic and self.curDynamicPoseState ~= nil
	end

	self.resumeDynamicPoseAfterTimePause = resumeDynamicPose == true
	self.autoPlayDynamicPose = false

	self.btnPlayOrStopUButton:TryChangePage("IsPlay", 0)

	if self.curDynamicPoseState then
		self.curDynamicPoseState:SetSpeed(0)
	end

	local ent = self:getTargetPlayerEntity()

	if ent then
		ent:setPhotoTimePauseAnimPlaying(false)
	end
end

function PhotoFuncPlayerPoseUIComponent:resumePhotoSubject()
	local ent = self:getTargetPlayerEntity()

	if ent then
		ent:setPhotoTimePauseAnimPlaying(nil)
	end

	if self.resumeDynamicPoseAfterTimePause and self.currentPoseIsDynamic and self.curDynamicPoseState then
		self.autoPlayDynamicPose = true

		self.curDynamicPoseState:SetSpeed(1)
		self.btnPlayOrStopUButton:TryChangePage("IsPlay", 1)
	end

	self.resumeDynamicPoseAfterTimePause = false
end

function PhotoFuncPlayerPoseUIComponent:clearCurPlayingPlayerAni()
	if not self.curPlayPlayerPoseAni then
		return
	end

	local selfEntity = self:getTargetPlayerEntity()

	if selfEntity then
		selfEntity:stopLayerAnimation(PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
		selfEntity:playAnimation(defaultAnim, nil, nil, nil, self:getPlayerAnimLayer())
	end

	if self.curPlayerDynamicPoseState then
		self.curPlayerDynamicPoseState:SetLogicLoop(false)
	end

	self.curPlayPlayerPoseAni = nil

	if self.curDynamicPoseState == self.curPlayerDynamicPoseState then
		self.curDynamicPoseState = nil
		self.curPlayPoseEnt = nil
	end

	self.curPlayerDynamicPoseState = nil
	self.currentPoseIsDynamic = false

	self.focalLengthSliderUWidget:SetActive(false)
end

function PhotoFuncPlayerPoseUIComponent:playActionInner(config, ent)
	if not config then
		return
	end

	local aniLoop
	local res = config.res1

	if res and #res > 0 then
		aniLoop = #res == 3 and res[2] or res[1]
	end

	if config.photo == self.CameraPoseType.Dynamic then
		aniLoop = aniLoop or config.resLoop and PlayableConst[config.resLoop] or PlayableConst[config.res]

		self:playDynamicAnim(ent, aniLoop)

		self.curAnimName = config.res

		self.ctrl:tryTriggerAllPetsAction()

		return aniLoop
	elseif config.photo == self.CameraPoseType.Static then
		local ani = PlayableConst[config.res]

		self:playStaticAnim(ent, ani, aniLoop)

		self.curAnimName = config.res

		self.ctrl:tryTriggerAllPetsAction()

		local res = aniLoop or ani

		return res
	end
end

function PhotoFuncPlayerPoseUIComponent:playStaticAnim(ent, ani, aniLoop)
	local curAni = aniLoop or ani

	if not ent or not curAni then
		return
	end

	self.focalLengthSliderUWidget:SetActive(false)

	local state = ent:playAnimation(curAni, true, nil, true, self:getPlayerAnimLayer())

	if not state then
		return
	end

	self.curPlayPoseAni = curAni
	self.curPlayPlayerPoseAni = self.curPlayPoseAni
	self.currentPoseIsDynamic = false
	self.resumeDynamicPoseAfterTimePause = false

	if self.ctrl:checkTimePause() then
		ent:setPhotoTimePauseAnimPlaying(false)
	end
end

function PhotoFuncPlayerPoseUIComponent:playDynamicAnim(ent, ani)
	if not ent or not ani then
		return
	end

	self.curPlayPoseEnt = ent
	self.curDynamicPoseState = ent:playRawAnimation(ani, nil, 0, 1, nil, self:getPlayerAnimLayer())

	if not self.curDynamicPoseState then
		return
	end

	self.curDynamicPoseState:SetLogicLoop(true)
	self:onPlayerDynamicPoseStateChanged(self.curDynamicPoseState)

	self.currentPoseIsDynamic = true
	self.curPlayPoseAni = ani

	self:setDynamicPoseUSliderMaxValue(self.curDynamicPoseState.Length)
	self.dynamicPoseUSlider:SetValueWithoutCallback(0)

	if self.ctrl:checkTimePause() then
		self:pausePhotoSubject(true)
	else
		self.resumeDynamicPoseAfterTimePause = false
		self.autoPlayDynamicPose = true

		self.btnPlayOrStopUButton:TryChangePage("IsPlay", 1)
	end

	self.focalLengthSliderUWidget:SetActive(true)
end

function PhotoFuncPlayerPoseUIComponent:setDynamicPoseUSliderMaxValue(length)
	self.dynamicPoseUSlider.enableValueChangedCallback = false
	self.dynamicPoseUSlider.maxValue = length
	self.dynamicPoseUSlider.enableValueChangedCallback = true
end

function PhotoFuncPlayerPoseUIComponent:recordPlayingAni()
	self.curPlayPlayerPoseAni = self.curPlayPoseAni

	if self.poseTypeId == self.CameraPoseType.Dynamic then
		self.curPlayerDynamicPoseState = self.curDynamicPoseState
	end
end

function PhotoFuncPlayerPoseUIComponent:refreshPoseFunc(typeId)
	self.poseTypeId = typeId

	local dataList = self:getCurShowPoseData(typeId)

	table.insert(dataList, 1, {
		tIndex = 1,
		selected = self.curPlayPlayerPoseId == nil
	})

	local offset = 7 - #dataList

	for i = 1, offset do
		dataList[#dataList + 1] = {
			empty = true
		}
	end

	self.listPoseUList:SetList(dataList)
end

function PhotoFuncPlayerPoseUIComponent:getCurShowPoseData(typeId)
	local poseData = {
		{},
		{}
	}

	poseData = self:getPhotoActionData(AppearanceAction, self.curPlayPlayerPoseId)

	return poseData[typeId]
end

function PhotoFuncPlayerPoseUIComponent:getPhotoActionData(tableData, curId)
	local actionData = {
		{},
		{}
	}

	for id, value in pairs(tableData) do
		if value.photo and value.photo > 0 and table.contains(value.body, self.bodyType) then
			table.insert(actionData[value.photo], {
				id = id,
				params = value,
				selected = id == curId,
				unlock = PhotographyAssetRedDotUtils.isAssetUnlocked(PhotographyAssetRedDotUtils.AssetType.PlayerPose, id),
				showRedDot = PhotographyAssetRedDotUtils.isAssetNew(PhotographyAssetRedDotUtils.AssetType.PlayerPose, id)
			})
		end
	end

	for _, dataList in ipairs(actionData) do
		PhotographyAssetRedDotUtils.sortUnlockedFirst(dataList, PhotographyAssetRedDotUtils.AssetType.PlayerPose)
	end

	return actionData
end

function PhotoFuncPlayerPoseUIComponent:getCurAnimName()
	return self.curAnimName
end

return PhotoFuncPlayerPoseUIComponent
