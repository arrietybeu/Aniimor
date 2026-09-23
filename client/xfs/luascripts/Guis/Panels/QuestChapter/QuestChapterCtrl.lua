-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestChapter\\QuestChapterCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local QuestChapterCtrl = Class.LightClass("QuestChapterCtrl", UICtrl)
local logger = LoggerManager.getLogger("QuestChapterCtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local QuestConst = require("Common.Const.QuestConst")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local QuestCatalogConfig = require("Data.quest_catalog")
local AddressDataConst = require("Const.AddressDataConst")
local showType = 0
local EMO_LIST = {}
local Y_ANGLE_OFFSET = -46.232
local ANI_TIME = 6.5
local CHAPTER_APPEAR_ANI = "VX_Pb_Quest_ChapterAppearPanel_ChapterAppear"
local COMPLETE_APPEAR_ANI = "VX_Pb_Quest_ChapterAppearPanel_SectionAppear"

function QuestChapterCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	if AddressDataConst and AddressDataConst.CURTAIN_EMO then
		for key, value in ipairs(AddressDataConst.CURTAIN_EMO) do
			if type(value) == "string" or type(value) == "number" then
				EMO_LIST[#EMO_LIST + 1] = value
			end
		end
	end
end

function QuestChapterCtrl:addListener()
	return
end

function QuestChapterCtrl:onShow()
	return
end

function QuestChapterCtrl:onOpen(info)
	showType = info.type and info.type or 0

	if self.closeCountDownTimer then
		self:killTimer(self.closeCountDownTimer)
	end

	self.closeCountDownTimer = self:startTimer(function()
		self:dismiss()

		if info.closeFunc then
			info:closeFunc()
		end
	end, ANI_TIME + 1)

	self.view.rootCom:TryChangePage("Type", 0)

	if info and #info > 5 and info[6] then
		self.isUIModel = true

		self.view.rootCom:TryChangePage("Type", 1)
		self.view:getChapterObjects(self.view.chapterRoot)
		self:showPanel(info)
	elseif IsNil(self.UIRoot) then
		pg.global.resMgr:GetInstanceFromCacheByLua(AddressDataConst.UI_3D_CHAPTER_APPEAR_ROOT, function(uiRoot, userData)
			if IsNil(uiRoot) then
				return
			end

			self.UIRoot = uiRoot
			uiRoot.transform.position = Vector3(0, 0, 0)

			local objectReference = uiRoot:GetComponent("ObjectReference")

			self.msgPanel = objectReference:GetRefValue("msgPanel")
			self.chapterRoot = objectReference:GetRefValue("chapterRoot")

			self.view:getChapterObjects(self.chapterRoot)
			self.chapterRoot.transform:SetParent(self.msgPanel)

			self.chapterRoot.transform.localPosition = Vector3.zero

			local scale = info and #info > 4 and info[5] ~= Vector3.zero and info[5] or Vector3(1, 1, 1)

			self.chapterRoot.transform.localScale = scale

			local rotAdjust = info and #info > 3 and info[4] or Vector3(0, 0, 0)
			local rot = pg.me:getRotation():ToEulerAngles()

			if rot then
				self.chapterRoot.transform.position = self:setUIPosition(info)
				self.chapterRoot.transform.localEulerAngles = rot + Vector3(0, Y_ANGLE_OFFSET, 0) + Vector3(rotAdjust[1], rotAdjust[2], rotAdjust[3])
			end

			self:showPanel(info)
		end)
	end
end

function QuestChapterCtrl:setUIPosition(info)
	if not pg.me then
		return
	end

	local playerPos = pg.me:getPosition()
	local direction = playerPos.forward

	if info and #info > 5 and info[6] then
		self.isUIModel = true
	end

	local distance = info and #info > 1 and info[2] ~= 0 and info[2] or 0
	local distanceOffset = direction * distance
	local uiOffset = info and #info > 2 and info[3] ~= 0 and info[3] or Vector3(0, 0, 0)
	local uiPosition = playerPos + uiOffset + distanceOffset

	return uiPosition
end

function QuestChapterCtrl:showPanel(info)
	local questId = info.questId or info[1]
	local chapterId = info.chapterId or info[8]

	info.isChapterCurtain = chapterId ~= nil and chapterId > 0 and true or false

	local sectionType = info.sectionType or info[7]

	if questId ~= nil and questId > 0 or chapterId ~= nil and chapterId > 0 then
		info.type = sectionType and 1 or 0

		if info.isChapterCurtain and chapterId then
			info.chapterId = chapterId
		elseif questId and questId > 0 then
			info.questId = questId

			local questChapter = QuestUtils.getMainQuestChapterConfig(questId)

			if questChapter ~= nil then
				info.chapterTypeId = questChapter.chapterTypeId
				info.chapterId = questChapter.chapterId
				info.sectionId = questChapter.sectionId
			end
		end
	end

	showType = info.type and info.type or 0

	local ret, page = self.view.mainCom:TryGetCurrentPage("State")

	if page == showType then
		self.view.mainCom:TryChangePage("State", self:getState(showType))
	end

	self.view.mainCom:TryChangePage("State", self:getState(showType))
	self.view.chapterAppearUWidget:SetActive(showType == 0)
	self.view.sectionCompleteUWidget:SetActive(showType == 1)

	if showType == 0 then
		if self.isUIModel then
			self.view.chapterAppearUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
		else
			self.view.chapterAppearUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end

		if info.isChapterCurtain then
			self:refreshChapterCurtainOpenPanel(info)
		else
			self:refreshChapterOpenPanel(info)
		end
	else
		if self.isUIModel then
			self.view.sectionCompleteUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom4)
		else
			self.view.sectionCompleteUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom3)
		end

		if info.isChapterCurtain then
			self:refreshChapterCurtainCompletePanel(info)
		else
			self:refreshChapterCompletePanel(info)
		end
	end
end

function QuestChapterCtrl:setSectionContent(contentTxt, bgWidget, descId)
	local desc = pg.getLocalizationText(descId)

	ClientTextUtils.setText(contentTxt, desc)

	if bgWidget then
		bgWidget:SetActive(desc ~= nil and desc ~= "")
	end
end

function QuestChapterCtrl:getState(showType)
	local state = 0

	if self.isUIModel then
		state = showType == 0 and 2 or 3
	else
		state = showType == 0 and 0 or 1
	end

	return state
end

function QuestChapterCtrl:refreshChapterOpenPanel(arg)
	self:setIsModel(false)
	pg.game.audio:triggerEvent("SFX_UI_MissionComplete")

	local chapterTypeId = arg.chapterTypeId
	local chapterId = arg.chapterId
	local sectionId = arg.sectionId
	local chapterConfig = self.model:getChapterInfo(chapterId)

	if chapterConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("找不到对应的章节信息", chapterTypeId, chapterId)
		end

		return
	end

	local sectionConfig = self.model:getSectionInfo(chapterId, sectionId)

	if sectionConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("找不到对应的幕信息", chapterTypeId, chapterId, sectionId)
		end

		return
	end

	local chapterStr = ""

	if chapterConfig.listId then
		local catalog = QuestCatalogConfig[chapterConfig.listId]

		if catalog then
			chapterStr = pg.getLocalizationText(catalog.mainTypeName)

			local state, _ = self:getMainTypeStateAndColor(catalog.mainType)

			self.view.mainCom:TryChangePage("Type", state)
		end
	end

	ClientTextUtils.setText(self.view.caChapterTxt, chapterStr)
	ClientTextUtils.setText(self.view.caChapterShadowTxt, chapterStr)
	ClientTextUtils.setText(self.view.caChapterNameTxt, pg.getLocalizationText(sectionConfig.sectionName))
	self:setSectionContent(self.view.caSectionContentTxt, self.view.textBgUWidget, sectionConfig.startDesc)
	self.view.mainTitleTextUBaseText:SetActive(false)
end

function QuestChapterCtrl:refreshChapterCompletePanel(arg)
	self:setIsModel(false)
	pg.game.audio:triggerEvent("SFX_UI_MissionComplete")

	local chapterTypeId = arg.chapterTypeId
	local chapterId = arg.chapterId
	local sectionId = arg.sectionId
	local chapterConfig = self.model:getChapterInfo(chapterId)

	if chapterConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("找不到对应的章节信息", chapterTypeId, chapterId)
		end

		return
	end

	local sectionConfig = self.model:getSectionInfo(chapterId, sectionId)

	if sectionConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("找不到对应的幕信息", chapterTypeId, chapterId, sectionId)
		end

		return
	end

	local chapterStr = ""

	if chapterConfig.listId then
		local catalog = QuestCatalogConfig[chapterConfig.listId]

		if catalog then
			chapterStr = pg.getLocalizationText(catalog.chapterTypeName)

			local state, color = self:getMainTypeStateAndColor(catalog.mainType)

			self.view.mainCom:TryChangePage("Type", state)
			ClientTextUtils.setText(self.view.textTimeUBaseText, QuestUtils.getTimeIcon(color))
		end
	end

	ClientTextUtils.setText(self.view.scChapterTypeNameTxt, chapterStr)
	ClientTextUtils.setText(self.view.scChapterNameShadowTxt, "")
	ClientTextUtils.setText(self.view.scSectionNameTxt, pg.getLocalizationText(sectionConfig.sectionName))
	self:setSectionContent(self.view.scSectionContentTxt, self.view.completeTextBgUWidget, sectionConfig.endDesc)

	self.view.expressionUImage.url = EMO_LIST[sectionConfig.emoDesc]
end

function QuestChapterCtrl:refreshChapterCurtainOpenPanel(arg)
	self:setIsModel(false)
	pg.game.audio:triggerEvent("SFX_UI_MissionComplete")

	local chapterId = arg.chapterId
	local chapterConfig = self.model:getChapterInfo(chapterId)

	if chapterConfig == nil then
		return
	end

	local chapterStr = ""

	if chapterConfig.listId then
		local catalog = QuestCatalogConfig[chapterConfig.listId]

		if catalog then
			chapterStr = pg.getLocalizationText(catalog.mainTypeName)

			local state, _ = self:getMainTypeStateAndColor(catalog.mainType)

			self.view.mainCom:TryChangePage("Type", state)
		end
	end

	ClientTextUtils.setText(self.view.caChapterTxt, chapterStr)
	ClientTextUtils.setText(self.view.caChapterShadowTxt, chapterStr)
	ClientTextUtils.setText(self.view.caChapterNameTxt, pg.getLocalizationText(chapterConfig.chapterName))
	self:setSectionContent(self.view.caSectionContentTxt, self.view.textBgUWidget, chapterConfig.chapterStartDesc)
	self.view.mainTitleTextUBaseText:SetActive(false)
end

function QuestChapterCtrl:refreshChapterCurtainCompletePanel(arg)
	self:setIsModel(false)
	pg.game.audio:triggerEvent("SFX_UI_MissionComplete")

	local chapterId = arg.chapterId
	local chapterConfig = self.model:getChapterInfo(chapterId)

	if chapterConfig == nil and (not LoggerManager.checkLogger(LoggerConst.ERROR) or true) then
		return
	end

	local chapterStr = ""

	if chapterConfig.listId then
		local catalog = QuestCatalogConfig[chapterConfig.listId]

		if catalog then
			chapterStr = pg.getLocalizationText(catalog.chapterTypeName)

			local state, color = self:getMainTypeStateAndColor(catalog.mainType)

			self.view.mainCom:TryChangePage("Type", state)
			ClientTextUtils.setText(self.view.textTimeUBaseText, QuestUtils.getTimeIcon(color))
		end
	end

	ClientTextUtils.setText(self.view.scChapterTypeNameTxt, chapterStr)
	ClientTextUtils.setText(self.view.scChapterNameShadowTxt, "")
	ClientTextUtils.setText(self.view.scSectionNameTxt, pg.getLocalizationText(chapterConfig.chapterName))
	self:setSectionContent(self.view.scSectionContentTxt, self.view.completeTextBgUWidget, chapterConfig.chapterEndDesc)

	self.view.expressionUImage.url = EMO_LIST[chapterConfig.chapterEndEmo]
end

function QuestChapterCtrl:getMainTypeStateAndColor(mainType)
	if mainType == QuestConst.MainType.Story then
		return 0, QuestConst.NUMBER_COLOR.YELLOW
	elseif mainType == QuestConst.MainType.Quest then
		return 1, QuestConst.NUMBER_COLOR.BLUE
	elseif mainType == QuestConst.MainType.Adventure then
		return 2, QuestConst.NUMBER_COLOR.GREEN
	elseif mainType == QuestConst.MainType.Clue then
		return 1, QuestConst.NUMBER_COLOR.BLUE
	end

	return 0, QuestConst.NUMBER_COLOR.YELLOW
end

function QuestChapterCtrl:onHide()
	if self.closeCountDownTimer then
		self:killTimer(self.closeCountDownTimer)
	end

	pg.global.resMgr:ResDestroyObject(self.UIRoot)
end

function QuestChapterCtrl:onDestroy()
	UICtrl.onDestroy(self)
	pg.global.resMgr:ResDestroyObject(self.UIRoot)
end

return QuestChapterCtrl
