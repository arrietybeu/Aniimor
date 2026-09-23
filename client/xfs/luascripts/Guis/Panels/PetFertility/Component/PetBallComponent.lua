-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertility\\Component\\PetBallComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local PetConfigData = require("Data.pet_config_data")
local PetData = require("Data.pet_data")
local UIConst = require("Const.UIConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PetLevelData = require("Data.pet_level_data")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ItemData = require("Data.item_data")
local PetBallComponent = Class.LightClass("PetBallComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetRenameValidator = require("Utils.PetRenameValidator")
local NoticeDef = require("Common.NoticeDef")

function PetBallComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.breedInfoUButton = self.objectReference:GetRefValue("breedInfoUButton")
	self.ballInfoUButton = self.objectReference:GetRefValue("ballInfoUButton")
	self.hatchInfoUButton = self.objectReference:GetRefValue("hatchInfoUButton")
	self.root = self.objectReference:GetRefValue("root")
	self.mainUComponent = self.objectReference:GetRefValue("mainUComponent")
	self.mainPagePetExpUSlider = self.objectReference:GetRefValue("mainPagePetExpUSlider")
	self.mainImgPetUImage = self.objectReference:GetRefValue("mainImgPetUImage")
	self.mainNameUSDFText = self.objectReference:GetRefValue("mainNameUSDFText")
	self.mainNumCPUSDFText = self.objectReference:GetRefValue("mainNumCPUSDFText")
	self.mainNumLvUSDFText = self.objectReference:GetRefValue("mainNumLvUSDFText")
	self.mainPetBallTextUSDFText = self.objectReference:GetRefValue("mainPetBallTextUSDFText")
	self.ballDetailUComponent = self.objectReference:GetRefValue("ballDetailUComponent")
	self.buttonMenuUButton = self.objectReference:GetRefValue("buttonMenuUButton")
	self.buttonEyeUButton = self.objectReference:GetRefValue("buttonEyeUButton")
	self.btnBallAddUButton = self.objectReference:GetRefValue("btnBallAddUButton")
	self.innerImgPetUImage = self.objectReference:GetRefValue("innerImgPetUImage")
	self.innerPetExpUSlider = self.objectReference:GetRefValue("innerPetExpUSlider")
	self.innerPetNameUSDFText = self.objectReference:GetRefValue("innerPetNameUSDFText")
	self.innerNumCPUSDFText = self.objectReference:GetRefValue("innerNumCPUSDFText")
	self.innerNumLvUSDFText = self.objectReference:GetRefValue("innerNumLvUSDFText")
	self.innerPetElementUList = self.objectReference:GetRefValue("innerPetElementUList")
	self.petBallSwitchPointListUList = self.objectReference:GetRefValue("petBallSwitchPointListUList")
	self.petBallEnterBtnConfirmUButton = self.objectReference:GetRefValue("petBallEnterBtnConfirmUButton")
	self.petListUList = self.objectReference:GetRefValue("petListUList")
	self.petInfoUComponent = self.objectReference:GetRefValue("petInfoUComponent")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.btnDelUButton = self.objectReference:GetRefValue("btnDelUButton")
	self.switchBtnUButton = self.objectReference:GetRefValue("switchBtnUButton")
	self.selectorUSelector = self.objectReference:GetRefValue("selectorUSelector")
	self.btnLeftUButton = self.objectReference:GetRefValue("btnLeftUButton")
	self.btnRightUButton = self.objectReference:GetRefValue("btnRightUButton")
	self.btnCleanFilterUButton = self.objectReference:GetRefValue("btnCleanFilterUButton")
	self.btnFilter1UButton = self.objectReference:GetRefValue("btnFilter1UButton")
	self.btnFilter2UButton = self.objectReference:GetRefValue("btnFilter2UButton")
	self.btnFeedUButton = self.objectReference:GetRefValue("btnFeedUButton")
	self.feedBarUComponent = self.objectReference:GetRefValue("feedBarUComponent")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.iconUImage = self.objectReference:GetRefValue("iconUImage")
	self.feedTimeCountDown = self.objectReference:GetRefValue("feedTimeCountDown")
	self.petBallPreviewScene = pg.game.uiScene:getScene(UISceneConst.PET_BALL_PREVIEW_SCENE)

	self:init()
end

function PetBallComponent:initView()
	function self.breedInfoUButton.luaClick()
		self:onBreedBallClick()
	end

	function self.ballInfoUButton.luaClick()
		self:onPetBallClick()
	end

	function self.hatchInfoUButton.luaClick()
		self:onHatchBallClick()
	end

	function self.buttonMenuUButton.luaClick()
		self:onMenuBtnClick()
	end

	function self.buttonEyeUButton.luaClick()
		return
	end

	function self.btnBallAddUButton.luaClick()
		self:onAddPetClick()
	end

	function self.petBallEnterBtnConfirmUButton.luaClick()
		self.model:setCurPetBallIndex(self.menuPreviewBallIndex)
		self:backToPage1()
		self:refreshCurrentBallPetInfo()
		self:refreshFeedState()
	end

	function self.btnConfirmUButton.luaClick()
		self:onConfirmPetBallPetClick()
	end

	function self.btnDelUButton.luaClick()
		self:onAddPetClick()
	end

	function self.switchBtnUButton.luaClick()
		self:onAddPetClick()
	end

	function self.btnLeftUButton.luaClick()
		self:switchBoxPage(false)
	end

	function self.btnRightUButton.luaClick()
		self:switchBoxPage(true)
	end

	function self.btnFilter1UButton.luaClick()
		self:openFilterPanel()
	end

	function self.btnFilter2UButton.luaClick()
		self:openFilterPanel()
	end

	function self.btnCleanFilterUButton.luaClick()
		self:endFilter()
	end

	function self.btnFeedUButton.luaClick()
		self:onFeedClick()
	end

	function self.btnCancelUButton.luaClick()
		pg.global.showConfirmMsgRaw(nil, pg.getGameString("CANCLE_FEEDING_SECOND_CONFIRMATION"), function()
			local key = self.model:getCurrentPetBallId()

			pg.me:serverMsg("RPC_CS_PetBallclearExpAction", key, function()
				self:refreshFeedState()
			end)
		end)
	end

	self:initPetBallViewScrollEvent()
end

function PetBallComponent:init()
	self.FIXED_CAMERA_POSITION = Vector3(0, 9999.3, 195.8)
	self.FIXED_MAIN_PET_BALL_POSITION = Vector3(0, 10000, 117.1)
	self.FIXED_CAMERA_SCALE_DIRECTION = (self.FIXED_MAIN_PET_BALL_POSITION - self.FIXED_CAMERA_POSITION).normalized
	self.FIXED_CAMERA_SCALE_DIRECTION_MAX_DISTANCE = Vector3.Distance(self.FIXED_MAIN_PET_BALL_POSITION, self.FIXED_CAMERA_POSITION)

	self.model:refreshPetBallInfoData()
	self:refreshCurrentBallPetInfo()
	self:refreshFeedState()
	self.petBallSwitchPointListUList:SetList(self.model:getPetBallCountDotListData())
end

function PetBallComponent:initPetBallViewScrollEvent()
	local petBallViewScroll = KeyBindingPro.GetOrAddKeyBindingByName(self.ballDetailUComponent.gameObject, "petBallViewScroll")

	petBallViewScroll.isVirtual = true
	petBallViewScroll.actionPath = "Hud/PetBallScroll"

	function petBallViewScroll.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:scalePetBallCamera(inputInfo.valueVec2.y)
		end
	end
end

function PetBallComponent:refreshFeedState()
	local expActionStatus = self.model:getCurPetBallExpActionStatus()

	self.feedBarUComponent:TryChangePage("FeedState", expActionStatus ~= Const.PET_BALL.EXP_STATUS_INIT and 1 or 0)

	if expActionStatus == Const.PET_BALL.EXP_STATUS_START then
		local remainTime, totalTime = self.model:getTotalTimeByExpActionList()

		self.feedTimeCountDown:Play(remainTime, totalTime)

		local expActionList = self.model:getCurPetBallExpActionList()
		local itemId = expActionList[1].itemId
		local data = ItemData[itemId]

		self.iconUImage.url = LuaUIUtils.getIconByIconId(data.icon)
	else
		self.feedTimeCountDown:Stop()
	end
end

function PetBallComponent:refreshCurrentBallPetInfo()
	local currentBallContainsPet = self.model:isBallContainsPet(self.model:getCurPetBallIndex())

	self.mainUComponent:TryChangePage("ContainsPet", currentBallContainsPet and 1 or 0)

	if currentBallContainsPet then
		self.ballDetailUComponent:TryChangePage("BallState", 0)

		local petInfo = self.model:getPetBallPetInfo(self.model:getCurPetBallIndex())
		local maxExp = PetLevelData[petInfo.level + 1] ~= nil and PetLevelData[petInfo.level + 1].needExp or 0

		self.mainPagePetExpUSlider.value = maxExp == 0 and 1 or petInfo.exp / maxExp

		self.mainImgPetUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(petInfo.iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender), function()
			return
		end)
		ClientTextUtils.setText(self.mainNameUSDFText, pg.getLocalizationText(petInfo.name))
		ClientTextUtils.setText(self.mainNumCPUSDFText, string.format("%s %s", pg.getGameString("CP"), petInfo.cp))
		ClientTextUtils.setText(self.mainNumLvUSDFText, string.format("%s %s", pg.getGameString("LEVEL"), petInfo.level))
		self.innerImgPetUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(petInfo.iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender), function()
			return
		end)

		self.innerPetExpUSlider.value = maxExp == 0 and 1 or petInfo.exp / maxExp

		ClientTextUtils.setText(self.innerPetNameUSDFText, pg.getLocalizationText(petInfo.name))
		ClientTextUtils.setText(self.innerNumCPUSDFText, string.format("%s %s", pg.getGameString("CP"), petInfo.cp))
		ClientTextUtils.setText(self.innerNumLvUSDFText, string.format("%s %s", pg.getGameString("LEVEL"), petInfo.level))

		function self.innerPetElementUList.luaRenderItem(button, _, data1)
			LuaUIUtils.setElementButtonNew(button, data1.element)
		end

		self.innerPetElementUList:SetList(petInfo.elementNames)
		self.ctrl.petBallEntityComponent:onMainBallPetEntChanged(petInfo.id)
	else
		self.ballDetailUComponent:TryChangePage("BallState", 1)
		self.ctrl.petBallEntityComponent:hideAllPetEnt()
	end
end

function PetBallComponent:onBreedBallClick()
	self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.FocusFY, nil, nil, nil, nil)
end

function PetBallComponent:onPetBallClick()
	self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.FocusGJ, nil, nil, nil, nil)
	self.root:TryChangePage("BallState", 1)
end

function PetBallComponent:onHatchBallClick()
	self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.FocusFH, nil, nil, nil, nil)
	self.ctrl:openHatchPanel()
end

function PetBallComponent:onMenuBtnClick()
	local petBallCount = self.model:getPetBallCount()

	if petBallCount <= 1 then
		self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.UnFold1, nil, nil, nil, nil)
	elseif petBallCount >= 4 then
		self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.UnFold4, nil, nil, nil, nil)
	else
		self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX[string.format("UnFold%s", petBallCount)], nil, nil, nil, nil)
	end

	self.root:TryChangePage("BallState", 2)
	self.ctrl.petBallEntityComponent:showAroundPetEnts(self.model:getCurPetBallIndex())

	self.menuPreviewBallIndex = self.model:getCurPetBallIndex()

	self:onPreviewBallIndexChanged()
end

function PetBallComponent:onFeedClick()
	self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.FocusGJLeft, nil)
	self.root:TryChangePage("BallState", 4)
	self.ctrl.petFeedComponent:openPetFeedPanel()
end

function PetBallComponent:onPetFeedBack()
	self:refreshFeedState()
end

function PetBallComponent:backToSelectPage(whichPanel)
	if whichPanel == "ball" then
		self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.FocusGJReverse, nil, nil, nil, nil)
	elseif whichPanel == "breed" then
		self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.FocusFYReverse, nil, nil, nil, nil)
	else
		self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.FocusFHReverse, nil, nil, nil, nil)
	end

	self.root:TryChangePage("BallState", 0)
	self.view.root:TryChangePage("TabState", 0)
end

function PetBallComponent:backToPage1()
	local petBallCount = self.model:getPetBallCount()

	if self.menuPreviewBallIndex ~= self.model:getCurPetBallIndex() then
		if petBallCount >= 4 then
			self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.Slide4Chaos, self.model.TIMELINE_INDEX.Fold4, nil, nil, nil)
		else
			self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX[string.format("Slide%sChaos", petBallCount)], self.model.TIMELINE_INDEX[string.format("Fold%s", petBallCount)], nil, nil, nil)
		end
	elseif petBallCount <= 1 then
		self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.Fold1, nil, nil, nil, nil)
	elseif petBallCount >= 4 then
		self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.Fold4, nil, nil, nil, nil)
	else
		self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX[string.format("Fold%s", petBallCount)], nil, nil, nil, nil)
	end

	self.ctrl.petBallEntityComponent:showAroundPetEnts(self.model:getCurPetBallIndex())
	self.root:TryChangePage("BallState", 1)

	self.menuPreviewBallIndex = self.model:getCurPetBallIndex()

	self:onPreviewBallIndexChanged()
end

function PetBallComponent:managementBackToPreviewPage()
	self.root:TryChangePage("BallState", 1)
	self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.FocusGJRightReverse, nil, nil, nil, nil)
end

function PetBallComponent:destroy()
	self.currentPetId = nil
end

function PetBallComponent:switchPetBalls(isNxt)
	local petBallCount = self.model:getPetBallCount()

	if petBallCount <= 1 then
		return
	end

	if isNxt then
		if petBallCount < self.menuPreviewBallIndex + 1 then
			self.menuPreviewBallIndex = 1
		else
			self.menuPreviewBallIndex = self.menuPreviewBallIndex + 1
		end

		if petBallCount >= 4 then
			self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.SlideLeft4Plus, nil, nil, nil, nil)
		else
			self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX[string.format("SlideLeft%s", petBallCount)], nil, nil, nil, nil)
		end
	else
		if self.menuPreviewBallIndex - 1 < 1 then
			self.menuPreviewBallIndex = petBallCount
		else
			self.menuPreviewBallIndex = self.menuPreviewBallIndex - 1
		end

		if petBallCount >= 4 then
			self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.SlideRight4Plus, nil, nil, nil, nil)
		else
			self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX[string.format("SlideRight%s", petBallCount)], nil, nil, nil, nil)
		end
	end

	self.ctrl.petBallEntityComponent:showAroundPetEnts(self.menuPreviewBallIndex)
	self:onPreviewBallIndexChanged()
end

function PetBallComponent:rotatePetBall(gesture)
	local speed = -gesture.deltaPosition.x * 0.2

	self.petBallPreviewScene.camera.transform:RotateAround(self.petBallPreviewScene.petBallOnhookSceneTransform.position, self.petBallPreviewScene.petBallOnhookSceneTransform.up, -speed)
end

function PetBallComponent:scalePetBallCamera(val, isGesture)
	local speed

	if isGesture then
		speed = val < 0 and 2 or -2
	else
		speed = val < 0 and 10 or -10
	end

	local axis = self.FIXED_CAMERA_SCALE_DIRECTION
	local maxDistance = self.FIXED_CAMERA_SCALE_DIRECTION_MAX_DISTANCE
	local minDistance = 8.5
	local direction = axis * speed
	local finalPosition = UIUtils.GetTransformDirectionFinalGlobalPosition(self.petBallPreviewScene.camera.transform, direction)
	local distance = Vector3.Distance(finalPosition, self.FIXED_MAIN_PET_BALL_POSITION)

	if distance < minDistance or maxDistance < distance then
		return
	end

	self.petBallPreviewScene.camera.transform.position = finalPosition
end

function PetBallComponent:onPreviewBallIndexChanged()
	local btns = self.petBallSwitchPointListUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		btns[i]:TryChangePage("select", 0)
	end

	btns[self.menuPreviewBallIndex - 1]:TryChangePage("select", 1)
end

function PetBallComponent:onAddPetClick()
	self.subObjectReference = self.petInfoUComponent.transform:GetComponent("ObjectReference")
	self.petNameUText = self.subObjectReference:GetRefValue("petNameUText")
	self.petElementUList = self.subObjectReference:GetRefValue("petElementUList")
	self.numCPUText = self.subObjectReference:GetRefValue("numCPUText")
	self.btnFavoriteUButton = self.subObjectReference:GetRefValue("btnFavoriteUButton")
	self.btnRenameUButton = self.subObjectReference:GetRefValue("btnRenameUButton")
	self.numLevelUText = self.subObjectReference:GetRefValue("numLevelUText")
	self.expSlider = self.subObjectReference:GetRefValue("expSlider")
	self.featureUWidget = self.subObjectReference:GetRefValue("featureUWidget")
	self.featureIconUImage = self.subObjectReference:GetRefValue("featureIconUImage")
	self.featureTitle = self.subObjectReference:GetRefValue("featureTitle")
	self.featureDesc = self.subObjectReference:GetRefValue("featureDesc")
	self.panelDataUComponent = self.subObjectReference:GetRefValue("panelDataUComponent")
	self.hpTotal = self.subObjectReference:GetRefValue("hpTotal")
	self.atkTotal = self.subObjectReference:GetRefValue("atkTotal")
	self.defTotal = self.subObjectReference:GetRefValue("defTotal")
	self.regenTotal = self.subObjectReference:GetRefValue("regenTotal")
	self.defMagTotal = self.subObjectReference:GetRefValue("defMagTotal")
	self.atkMagTotal = self.subObjectReference:GetRefValue("atkMagTotal")
	self.detailUComponent = self.subObjectReference:GetRefValue("detailUComponent")
	self.hp = self.subObjectReference:GetRefValue("hp")
	self.atk = self.subObjectReference:GetRefValue("atk")
	self.def = self.subObjectReference:GetRefValue("def")
	self.regen = self.subObjectReference:GetRefValue("regen")
	self.defMag = self.subObjectReference:GetRefValue("defMag")
	self.atkMag = self.subObjectReference:GetRefValue("atkMag")
	self.hpBarStrengthen = self.subObjectReference:GetRefValue("hpBarStrengthen")
	self.hpBarTalent = self.subObjectReference:GetRefValue("hpBarTalent")
	self.hpBarSpecies = self.subObjectReference:GetRefValue("hpBarSpecies")
	self.atkBarStrengthen = self.subObjectReference:GetRefValue("atkBarStrengthen")
	self.atkBarTalent = self.subObjectReference:GetRefValue("atkBarTalent")
	self.atkBarSpecies = self.subObjectReference:GetRefValue("atkBarSpecies")
	self.defBarStrengthen = self.subObjectReference:GetRefValue("defBarStrengthen")
	self.defBarTalent = self.subObjectReference:GetRefValue("defBarTalent")
	self.defBarSpecies = self.subObjectReference:GetRefValue("defBarSpecies")
	self.regenBarStrengthen = self.subObjectReference:GetRefValue("regenBarStrengthen")
	self.regenBarTalent = self.subObjectReference:GetRefValue("regenBarTalent")
	self.regenBarSpecies = self.subObjectReference:GetRefValue("regenBarSpecies")
	self.defMagBarStrengthen = self.subObjectReference:GetRefValue("defMagBarStrengthen")
	self.defMagBarTalent = self.subObjectReference:GetRefValue("defMagBarTalent")
	self.defMagBarSpecies = self.subObjectReference:GetRefValue("defMagBarSpecies")
	self.atkMagBarStrengthen = self.subObjectReference:GetRefValue("atkMagBarStrengthen")
	self.atkMagBarTalent = self.subObjectReference:GetRefValue("atkMagBarTalent")
	self.atkMagBarSpecies = self.subObjectReference:GetRefValue("atkMagBarSpecies")
	self.v6PartMapRadarChart = self.subObjectReference:GetRefValue("v6PartMapRadarChart")

	local petInfo = self.model:getPetBallPetInfo(self.model:getCurPetBallIndex())

	self.curBoxIndex = 1
	self.curSortId = 0
	self.isDescending = true
	self.currentPetId = petInfo and petInfo.id or nil

	function self.petListUList.luaRenderItem(button, index, data)
		self:renderPetItem(button, index, data)
	end

	self:refreshPetList()
	self:refreshEnsureBtnState()
	self.root:TryChangePage("BallState", 3)
	self.petBallPreviewScene:playTimeline(self.model.TIMELINE_INDEX.FocusGJRight, nil, nil, nil, nil)
end

function PetBallComponent:refreshPetList(isFilter)
	local pets

	if isFilter then
		pets = self.model:getFilteredPetsInfo(self.curSortId, self.isDescending, 6, 24)
	else
		pets = self.model:getBoxInfoById(self.model:getBoxIdByBoxSequenceIndex(self.curBoxIndex), self.curSortId, self.isDescending)
	end

	if not pets then
		return
	end

	function self.petListUList.luaFinishRender(_)
		local btn = self:getPetButtonByPetId(self.currentPetId)

		self:refreshInfoPanelState(btn and btn.dataFromUList or nil)
	end

	self.petListUList:SetList(pets)
	self.selectorUSelector:ClosePopup()
	self:refreshBoxSelector()
end

function PetBallComponent:renderPetItem(button, index, data, cb)
	button.draggable = false

	local state = data.isEmpty and 2 or 0

	button:TryChangePage("state", state)

	button.name = data.id or "empty"

	local select = 0

	button:TryChangePage("select", select)

	if data.isEmpty then
		return
	end

	LuaUIUtils.renderPetHead(button, data)

	if data.id == self.currentPetId then
		select = 1
	end

	button:TryChangePage("select", select)

	if self.model:checkPetExistsInAnyPetBallExceptSpecificPetBall(data.id, self.model:getCurPetBallIndex()) then
		state = 1

		button:TryChangePage("state", state)
	end

	function button.luaClick()
		if self.model:checkPetExistsInAnyPetBallExceptSpecificPetBall(data.id, self.model:getCurPetBallIndex()) then
			pg.global.showBubbleMessageRaw(pg.getGameString("FERTILITY_WARN3"))

			return
		end

		self:clickPetIcon(state, select, data)
	end

	if cb then
		cb()
	end
end

function PetBallComponent:clickPetIcon(state, select, data)
	if state ~= 0 then
		return
	end

	self.currentPetId = select == 0 and data.id or nil

	self:onCurrentPetIdChanged()
end

function PetBallComponent:switchBoxPage(isNxt)
	local maxPage = #pg.me.petBoxMap

	if isNxt then
		if maxPage < self.curBoxIndex + 1 then
			self.curBoxIndex = 1
		else
			self.curBoxIndex = self.curBoxIndex + 1
		end
	elseif self.curBoxIndex - 1 < 1 then
		self.curBoxIndex = maxPage
	else
		self.curBoxIndex = self.curBoxIndex - 1
	end

	self:refreshPetList()
end

function PetBallComponent:switchBoxToIndex(index)
	if not index then
		return
	end

	self.curBoxIndex = index

	self:refreshPetList()
end

function PetBallComponent:openFilterPanel()
	pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT_FILTER, {
		sortId = self.curSortId,
		isDescending = self.isDescending,
		filter = self.model:getFilter(),
		doFilterCallback = function(filter, sortId, isDescending)
			self.curSortId = sortId
			self.isDescending = isDescending

			self.model:setFilter(filter)

			if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_FERTILITY) then
				self:startFilter()
			end
		end
	})
end

function PetBallComponent:refreshBoxSelector()
	local boxPetMap = pg.me.petBoxMap
	local boxInfos = self.model:getBoxInfos()
	local selectBoxId = self.model:getBoxIdByBoxSequenceIndex(self.curBoxIndex)
	local objRef = self.selectorUSelector:GetComponent("ObjectReference")
	local boxName = objRef:GetRefValue("boxName")
	local txtNameUText = objRef:GetRefValue("txtNameUText")
	local customName = boxPetMap[selectBoxId].customName
	local count = boxPetMap[selectBoxId].count
	local slotCount = boxPetMap[selectBoxId].slotCount
	local boxNameContent = ""

	if customName and customName ~= "" then
		boxNameContent = string.format("%s (%s/%s)", customName, count, slotCount)
	else
		boxNameContent = string.format("%s %s (%s/%s)", pg.getGameString("DEFAULT_PET_BOX_NAME"), selectBoxId, count, slotCount)
	end

	ClientTextUtils.setText(boxName, boxNameContent)
	ClientTextUtils.setText(txtNameUText, boxNameContent)

	function self.selectorUSelector.luaRenderPopup(popup, list)
		local objectReference1 = popup:GetComponent("ObjectReference")
		local boxNameUText = objectReference1:GetRefValue("boxNameUText")

		ClientTextUtils.setText(boxNameUText, boxNameContent)

		function list.luaRenderItem(button, _, data)
			local objectReference = button:GetComponent("ObjectReference")
			local numUText = objectReference:GetRefValue("numUText")
			local nameUText = objectReference:GetRefValue("nameUText")

			button:TryChangePage("hideLockIcon", 1)
			ClientTextUtils.setText(numUText, data.countNum)

			if data.customName and data.customName ~= "" then
				ClientTextUtils.setText(nameUText, data.customName)
			else
				ClientTextUtils.setText(nameUText, string.format("%s %s", pg.getGameString("DEFAULT_PET_BOX_NAME"), data.idx))
			end

			function button.luaClick()
				self:switchBoxToIndex(self.model:getBoxSequenceIndexByBoxId(data.idx))
			end
		end

		function list.luaFinishRender(subList)
			local btns = subList:GetAllButtons()

			for i = 0, btns.Length - 1 do
				btns[i]:TryChangePage("select", btns[i].dataFromUList.idx == selectBoxId and 1 or 0)
			end
		end

		list:SetList(boxInfos)
	end

	self.selectorUSelector:SetOptions(boxInfos)
end

function PetBallComponent:startFilter()
	self:refreshPetList(true)
	self.root:TryChangePage("enableFilter", 1)
end

function PetBallComponent:endFilter()
	self.curSortId = 0
	self.isDescending = true

	self:refreshPetList()
	self.root:TryChangePage("enableFilter", 0)
end

function PetBallComponent:onCurrentPetIdChanged()
	local btns = self.petListUList:GetAllButtons()
	local selectedBtn

	for i = 0, btns.Length - 1 do
		local _, page = btns[i]:TryGetCurrentPage("select")

		if page == 1 or btns[i].name == self.currentPetId then
			self:renderPetItem(btns[i], nil, btns[i].dataFromUList, nil)
		end

		if btns[i].name == self.currentPetId then
			selectedBtn = btns[i]
		end
	end

	self:refreshInfoPanelState(selectedBtn and selectedBtn.dataFromUList or nil)
	self:refreshEnsureBtnState()
end

function PetBallComponent:refreshInfoPanelState(data)
	if not data then
		self.infoPanelPetId = nil

		self.petInfoUComponent.gameObject:SetActiveEx(false)

		return
	end

	self.infoPanelPetId = data.id

	self.petInfoUComponent.gameObject:SetActiveEx(true)

	if data.gender == Const.GENDER_TYPE_MALE then
		self.petInfoUComponent:TryChangePage("Gender", 0)
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		self.petInfoUComponent:TryChangePage("Gender", 1)
	else
		self.petInfoUComponent:TryChangePage("Gender", 2)
	end

	self.petInfoUComponent:TryChangePage("isFlash", data.isShiny and 1 or 0)

	function self.petElementUList.luaRenderItem(button, _, data1)
		LuaUIUtils.setElementButtonNew(button, data1.element)
	end

	self.petElementUList:SetList(data.elementNames)

	local petNameStr = pg.getLocalizationText(self.model:getPetName(data.id))

	ClientTextUtils.setText(self.petNameUText, petNameStr)
	self.btnFavoriteUButton:TryChangePage("enable", data.isFavorite and 1 or 0)
	ClientTextUtils.setText(self.numCPUText, string.format("%s %s", pg.getGameString("CP"), data.cp))
	ClientTextUtils.setText(self.numLevelUText, data.level)

	local maxExp = PetLevelData[data.level + 1] ~= nil and PetLevelData[data.level + 1].needExp or 0

	self.expSlider.value = maxExp == 0 and 1 or data.exp / maxExp

	if data.featureInfo then
		self.featureUWidget.gameObject:SetActiveEx(true)
		self.featureUWidget:TryChangePage("isS", data.featureInfo.rare or 0)
		ClientTextUtils.setText(self.featureDesc.content, pg.getLocalizationText(data.featureInfo.desc))
		ClientTextUtils.setText(self.featureTitle, pg.getLocalizationText(data.featureInfo.name))

		self.featureIconUImage.url = data.featureInfo.icon
	else
		self.featureUWidget.gameObject:SetActiveEx(false)
	end

	function self.btnFavoriteUButton.luaClick()
		PetManagementUtils.setRenderFavoriteToolTips(self.btnFavoriteUButton, self.infoPanelPetId)
	end

	function self.btnRenameUButton.luaClick()
		if not PetRenameValidator.canRenamePet() then
			pg.global.showBubbleMessage(NoticeDef.FORBID_CHANGE_PET_NAME)

			return
		end

		local title = pg.getGameString("RENAME_TIPS_PET")
		local id = data.id
		local text = self.model:getPetName(data.id)

		pg.global.ui.tips:setIsModel(true)
		pg.global.ui.tips:showCommonInput(title, function(newName)
			pg.me:serverMsg("RPC_CS_CustomPetName", id, newName)
			pg.global.ui.tips:setIsModel(false)
		end, function()
			pg.global.ui.tips:setIsModel(false)
		end, {
			characterLimit = 14,
			text = text or ""
		})
	end

	self:setTotalAttribute(data.id)
end

function PetBallComponent:refreshEnsureBtnState()
	local petInfo = self.model:getPetBallPetInfo(self.model:getCurPetBallIndex())

	if self.currentPetId and petInfo and petInfo.id ~= self.currentPetId then
		self.btnConfirmUButton.gameObject:SetActiveEx(true)
		self.btnConfirmUButton:TryChangePage("enable", 1)

		self.btnConfirmUButton.interactable = true
	elseif self.currentPetId and not petInfo then
		self.btnConfirmUButton.gameObject:SetActiveEx(true)
		self.btnConfirmUButton:TryChangePage("enable", 1)

		self.btnConfirmUButton.interactable = true
	else
		self.btnConfirmUButton.gameObject:SetActiveEx(false)
		self.btnConfirmUButton:TryChangePage("enable", 0)

		self.btnConfirmUButton.interactable = false
	end
end

function PetBallComponent:getPetButtonByPetId(petId)
	local btns = self.petListUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		if btns[i].name == petId then
			return btns[i]
		end
	end

	return nil
end

function PetBallComponent:setTotalAttribute(petId)
	local pet = pg.me:getPetInfo(petId)

	if pet == nil then
		return
	end

	local baseProperty = pet.basePropertyList
	local firstBaseProperty = baseProperty and baseProperty[Const.BASE_PROPERTY_HP_IDX]

	if not firstBaseProperty or firstBaseProperty.talentPoint == nil then
		return
	end

	local strengthenPointMax = PetConfigData.baseStrengthenMax
	local talentPointMax = 30
	local speciesPointMax = 200

	ClientTextUtils.setText(self.hpTotal, string.format("%d", baseProperty[Const.BASE_PROPERTY_HP_IDX].total))
	ClientTextUtils.setText(self.atkTotal, string.format("%d", baseProperty[Const.BASE_PROPERTY_ATK_IDX].total))
	ClientTextUtils.setText(self.defTotal, string.format("%d", baseProperty[Const.BASE_PROPERTY_DEF_IDX].total))
	ClientTextUtils.setText(self.regenTotal, string.format("%d", baseProperty[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX].total))
	ClientTextUtils.setText(self.defMagTotal, string.format("%d", baseProperty[Const.BASE_PROPERTY_DEF_MAG_IDX].total))
	ClientTextUtils.setText(self.atkMagTotal, string.format("%d", baseProperty[Const.BASE_PROPERTY_ATK_MAG_IDX].total))

	local maxValue = 250
	local hpRatio = (baseProperty[Const.BASE_PROPERTY_HP_IDX].speciesPoint + baseProperty[Const.BASE_PROPERTY_HP_IDX].talentPoint + baseProperty[Const.BASE_PROPERTY_HP_IDX].strengthenPoint) / maxValue
	local atkRatio = (baseProperty[Const.BASE_PROPERTY_ATK_IDX].speciesPoint + baseProperty[Const.BASE_PROPERTY_ATK_IDX].talentPoint + baseProperty[Const.BASE_PROPERTY_ATK_IDX].strengthenPoint) / maxValue
	local defRatio = (baseProperty[Const.BASE_PROPERTY_DEF_IDX].speciesPoint + baseProperty[Const.BASE_PROPERTY_DEF_IDX].talentPoint + baseProperty[Const.BASE_PROPERTY_DEF_IDX].strengthenPoint) / maxValue
	local regenRatio = (baseProperty[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX].speciesPoint + baseProperty[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX].talentPoint + baseProperty[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX].strengthenPoint) / maxValue
	local defMagRatio = (baseProperty[Const.BASE_PROPERTY_DEF_MAG_IDX].speciesPoint + baseProperty[Const.BASE_PROPERTY_DEF_MAG_IDX].talentPoint + baseProperty[Const.BASE_PROPERTY_DEF_MAG_IDX].strengthenPoint) / maxValue
	local atkMagRatio = (baseProperty[Const.BASE_PROPERTY_ATK_MAG_IDX].speciesPoint + baseProperty[Const.BASE_PROPERTY_ATK_MAG_IDX].talentPoint + baseProperty[Const.BASE_PROPERTY_ATK_MAG_IDX].strengthenPoint) / maxValue

	self.v6PartMapRadarChart:SetSixProps(hpRatio, atkRatio, defRatio, regenRatio, defMagRatio, atkMagRatio)
	self:ratioAttribute(pet)

	if not self.pageIdxRecorded then
		self.pageIdxRecorded = 0
	end

	function self.detailUComponent.luaTryChangePage(name, pageIdx)
		if name ~= "DataDetail" then
			return
		end

		self.pageIdxRecorded = pageIdx

		if pageIdx == 0 then
			ClientTextUtils.setText(self.hp, baseProperty[Const.BASE_PROPERTY_HP_IDX].talentPoint)
			ClientTextUtils.setText(self.atk, baseProperty[Const.BASE_PROPERTY_ATK_IDX].talentPoint)
			ClientTextUtils.setText(self.def, baseProperty[Const.BASE_PROPERTY_DEF_IDX].talentPoint)
			ClientTextUtils.setText(self.regen, baseProperty[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX].talentPoint)
			ClientTextUtils.setText(self.defMag, baseProperty[Const.BASE_PROPERTY_DEF_MAG_IDX].talentPoint)
			ClientTextUtils.setText(self.atkMag, baseProperty[Const.BASE_PROPERTY_ATK_MAG_IDX].talentPoint)

			local hpRatio = baseProperty[Const.BASE_PROPERTY_HP_IDX].talentPoint / talentPointMax

			self.hpBarTalent.transform.localScale = Vector3(hpRatio, hpRatio, hpRatio)

			local atkRatio = baseProperty[Const.BASE_PROPERTY_ATK_IDX].talentPoint / talentPointMax

			self.atkBarTalent.transform.localScale = Vector3(atkRatio, atkRatio, atkRatio)

			local defRatio = baseProperty[Const.BASE_PROPERTY_DEF_IDX].talentPoint / talentPointMax

			self.defBarTalent.transform.localScale = Vector3(defRatio, defRatio, defRatio)

			local regenRatio = baseProperty[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX].talentPoint / talentPointMax

			self.regenBarTalent.transform.localScale = Vector3(regenRatio, regenRatio, regenRatio)

			local defMagRatio = baseProperty[Const.BASE_PROPERTY_DEF_MAG_IDX].talentPoint / talentPointMax

			self.defMagBarTalent.transform.localScale = Vector3(defMagRatio, defMagRatio, defMagRatio)

			local atkMagRatio = baseProperty[Const.BASE_PROPERTY_ATK_MAG_IDX].talentPoint / talentPointMax

			self.atkMagBarTalent.transform.localScale = Vector3(atkMagRatio, atkMagRatio, atkMagRatio)
		elseif pageIdx == 1 then
			ClientTextUtils.setText(self.hp, baseProperty[Const.BASE_PROPERTY_HP_IDX].speciesPoint)
			ClientTextUtils.setText(self.atk, baseProperty[Const.BASE_PROPERTY_ATK_IDX].speciesPoint)
			ClientTextUtils.setText(self.def, baseProperty[Const.BASE_PROPERTY_DEF_IDX].speciesPoint)
			ClientTextUtils.setText(self.regen, baseProperty[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX].speciesPoint)
			ClientTextUtils.setText(self.defMag, baseProperty[Const.BASE_PROPERTY_DEF_MAG_IDX].speciesPoint)
			ClientTextUtils.setText(self.atkMag, baseProperty[Const.BASE_PROPERTY_ATK_MAG_IDX].speciesPoint)

			local hpRatio = baseProperty[Const.BASE_PROPERTY_HP_IDX].speciesPoint / speciesPointMax

			self.hpBarSpecies.transform.localScale = Vector3(hpRatio, hpRatio, hpRatio)

			local atkRatio = baseProperty[Const.BASE_PROPERTY_ATK_IDX].speciesPoint / speciesPointMax

			self.atkBarSpecies.transform.localScale = Vector3(atkRatio, atkRatio, atkRatio)

			local defRatio = baseProperty[Const.BASE_PROPERTY_DEF_IDX].speciesPoint / speciesPointMax

			self.defBarSpecies.transform.localScale = Vector3(defRatio, defRatio, defRatio)

			local regenRatio = baseProperty[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX].speciesPoint / speciesPointMax

			self.regenBarSpecies.transform.localScale = Vector3(regenRatio, regenRatio, regenRatio)

			local defMagRatio = baseProperty[Const.BASE_PROPERTY_DEF_MAG_IDX].speciesPoint / speciesPointMax

			self.defMagBarSpecies.transform.localScale = Vector3(defMagRatio, defMagRatio, defMagRatio)

			local atkMagRatio = baseProperty[Const.BASE_PROPERTY_ATK_MAG_IDX].speciesPoint / speciesPointMax

			self.atkMagBarSpecies.transform.localScale = Vector3(atkMagRatio, atkMagRatio, atkMagRatio)
		elseif pageIdx == 2 then
			ClientTextUtils.setText(self.hp, baseProperty[Const.BASE_PROPERTY_HP_IDX].strengthenPoint)
			ClientTextUtils.setText(self.atk, baseProperty[Const.BASE_PROPERTY_ATK_IDX].strengthenPoint)
			ClientTextUtils.setText(self.def, baseProperty[Const.BASE_PROPERTY_DEF_IDX].strengthenPoint)
			ClientTextUtils.setText(self.regen, baseProperty[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX].strengthenPoint)
			ClientTextUtils.setText(self.defMag, baseProperty[Const.BASE_PROPERTY_DEF_MAG_IDX].strengthenPoint)
			ClientTextUtils.setText(self.atkMag, baseProperty[Const.BASE_PROPERTY_ATK_MAG_IDX].strengthenPoint)

			local hpRatio = baseProperty[Const.BASE_PROPERTY_HP_IDX].strengthenPoint / strengthenPointMax

			self.hpBarStrengthen.transform.localScale = Vector3(hpRatio, hpRatio, hpRatio)

			local atkRatio = baseProperty[Const.BASE_PROPERTY_ATK_IDX].strengthenPoint / strengthenPointMax

			self.atkBarStrengthen.transform.localScale = Vector3(atkRatio, atkRatio, atkRatio)

			local defRatio = baseProperty[Const.BASE_PROPERTY_DEF_IDX].strengthenPoint / strengthenPointMax

			self.defBarStrengthen.transform.localScale = Vector3(defRatio, defRatio, defRatio)

			local regenRatio = baseProperty[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX].strengthenPoint / strengthenPointMax

			self.regenBarStrengthen.transform.localScale = Vector3(regenRatio, regenRatio, regenRatio)

			local defMagRatio = baseProperty[Const.BASE_PROPERTY_DEF_MAG_IDX].strengthenPoint / strengthenPointMax

			self.defMagBarStrengthen.transform.localScale = Vector3(defMagRatio, defMagRatio, defMagRatio)

			local atkMagRatio = baseProperty[Const.BASE_PROPERTY_ATK_MAG_IDX].strengthenPoint / strengthenPointMax

			self.atkMagBarStrengthen.transform.localScale = Vector3(atkMagRatio, atkMagRatio, atkMagRatio)
		end
	end

	self.detailUComponent:TryChangePage("DataDetail", self.pageIdxRecorded)
end

function PetBallComponent:ratioAttribute(pet)
	local firstBaseProperty = pet and pet.basePropertyList and pet.basePropertyList[Const.BASE_PROPERTY_HP_IDX]

	if not firstBaseProperty or firstBaseProperty.talentPoint == nil then
		return
	end

	local coefficient = PetConfigData.fitPropEvaluateRatio or 1.2
	local stageSection = PetConfigData.PetEvaluateLevelRange or {
		0,
		0.4,
		0.7,
		0.95
	}
	local all = 180
	local templateId = pet.templateId
	local petData = PetData[templateId]
	local recommend = petData.recommend_attr
	local baseProperty = pet.basePropertyList
	local talentPointsTable = {}

	for i = 1, 6 do
		local t = baseProperty[i].talentPoint

		talentPointsTable[i] = t
	end

	for _, v in pairs(recommend) do
		talentPointsTable[v] = talentPointsTable[v] * coefficient
	end

	local talentPointSum = talentPointsTable[1] + talentPointsTable[2] + talentPointsTable[3] + talentPointsTable[4] + talentPointsTable[5] + talentPointsTable[6]
	local result = talentPointSum / all

	if result >= stageSection[1] and result < stageSection[2] then
		self.panelDataUComponent:TryChangePage("Quality", 0)
	elseif result >= stageSection[2] and result < stageSection[3] then
		self.panelDataUComponent:TryChangePage("Quality", 1)
	elseif result >= stageSection[3] and result < stageSection[4] then
		self.panelDataUComponent:TryChangePage("Quality", 2)
	elseif result >= stageSection[4] then
		self.panelDataUComponent:TryChangePage("Quality", 3)
	end
end

function PetBallComponent:onConfirmPetBallPetClick()
	if not self.currentPetId then
		return
	end

	local petInfo = self.model:getPetBallPetInfo(self.model:getCurPetBallIndex())

	if petInfo and petInfo.id == self.currentPetId then
		return
	end

	local petBallId = self.model:getCurrentPetBallId()

	if not petBallId then
		return
	end

	pg.me:serverMsg("RPC_CS_PetBallChangePet", petBallId, self.currentPetId)
end

function PetBallComponent:onDeletePetBallClick()
	local petBallId = self.model:getCurrentPetBallId()

	if not petBallId then
		return
	end

	pg.me:serverMsg("RPC_CS_PetBallChangePet", petBallId, "")
end

function PetBallComponent:onPetBallPetChanged(info)
	self.model:refreshPetBallInfoData()
	self:refreshCurrentBallPetInfo()
	self:refreshEnsureBtnState()
	self:refreshFeedState()

	if info.newValue ~= "" then
		self.view.btnBackUButton:OnClickSimulate()
	end
end

function PetBallComponent:onPetFavoriteChanged(data)
	if self.infoPanelPetId == data.id then
		self.btnFavoriteUButton:TryChangePage("enable", data.isFavorite and 1 or 0)
	end

	local btns = self.petListUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		if btns[i].dataFromUList.id == data.id then
			self:renderPetItem(btns[i], nil, data, nil)
		end
	end
end

function PetBallComponent:onPetCustomNameChanged(data)
	if self.infoPanelPetId == data.id then
		local petNameStr = pg.getLocalizationText(self.model:getPetName(data.id))

		ClientTextUtils.setText(self.petNameUText, petNameStr)
	end

	local btns = self.petListUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		if btns[i].dataFromUList.id == data.id then
			self:renderPetItem(btns[i], nil, data, nil)
		end
	end
end

function PetBallComponent:onDestroy()
	self:destroy()
	UIComponent.onDestroy(self)
end

function PetBallComponent:onPetBallExpActionStatusChanged(info)
	local curPetBallId = self.model:getCurrentPetBallId()

	if curPetBallId == info.petBallId and info.newValue ~= Const.PET_BALL.EXP_STATUS_START then
		self:refreshFeedState()
	end
end

function PetBallComponent:onPetLevelChanged(info)
	local petInfo = self.model:getPetBallPetInfo(self.model:getCurPetBallIndex())
	local curPetId = petInfo.id

	if curPetId == info.petId then
		self:refreshCurrentBallPetInfo()
	end
end

function PetBallComponent:onPetAddExp(info)
	local petInfo = self.model:getPetBallPetInfo(self.model:getCurPetBallIndex())
	local curPetId = petInfo.id

	if curPetId == info.petId then
		self:refreshCurrentBallPetInfo()
	end
end

return PetBallComponent
