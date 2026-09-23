-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\CTipArea\\MultiPetObtainsItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local GmToolUtils = require("Utils.GmToolUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local PetFormTypeData = require("Data.pet_form_type_data")
local MultiPetObtainsItem = Class.LightClass("MultiPetObtainsItem", BaseQueueItem)
local Const = require("Common.Const.Const")
local PetData = require("Data.pet_data")
local SysConfigData = require("Data.sys_config_data")
local MULTI_SHOW_TIME = 10
local SPECIAL_CODE_PAGES = {
	[LuaUIUtils.SP_CODE.SP_ATTR] = 0,
	[LuaUIUtils.SP_CODE.SP_FEATURE] = 1,
	[LuaUIUtils.SP_CODE.SP_SKILL] = 2
}

function MultiPetObtainsItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function MultiPetObtainsItem:setMobileQAreaVisible(visible)
	if visible then
		if not self.isMobileQAreaHidden then
			return
		end
	elseif not pg.global.ui:runPlatformByMobile() then
		return
	end

	local tipsCtrl = pg.global.ui.tips

	if tipsCtrl and tipsCtrl.setQAreaVisible then
		tipsCtrl:setQAreaVisible(visible)

		self.isMobileQAreaHidden = not visible
	end
end

function MultiPetObtainsItem:playAnimation(animName, callback)
	if IsNil(self.animMul) then
		if callback then
			callback()
		end

		return
	end

	local clip = self.animMul:GetClip(animName)

	if IsNil(clip) then
		if callback then
			callback()
		end

		return
	end

	self.animMul:Play(animName)

	if callback then
		self.animTimer = self:startTimer(function()
			self.animTimer = nil

			callback()
		end, clip.length)
	end
end

function MultiPetObtainsItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function MultiPetObtainsItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or MULTI_SHOW_TIME)

	self:addRunItem(data)
	self:setMobileQAreaVisible(false)
	self:initUContainer(data)
end

function MultiPetObtainsItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function MultiPetObtainsItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function MultiPetObtainsItem:recycleToast(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.User2)
end

function MultiPetObtainsItem:initUContainer(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function(loadedItem)
			if IsNil(loadedItem) or self.uContainer.content ~= loadedItem then
				return
			end

			self:renderItem(loadedItem, data)
		end))
	else
		self:renderItem(self.uContainer.content, data)
	end
end

function MultiPetObtainsItem:renderItem(item, data)
	local objectReference = item:GetComponent("ObjectReference")

	self.multiList = objectReference:GetRefValue("multiList")
	self.multCount = objectReference:GetRefValue("multCount")
	self.animMul = objectReference:GetRefValue("animMul")
	self.specialityUList = objectReference:GetRefValue("specialityUList")
	self.root = objectReference:GetRefValue("root")
	self.listKeyUList = objectReference:GetRefValue("listKeyUList")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("BIG_WHITE_BALL_CATCH"))

	self.specialityUList.luaRenderItem = self:guardRunCallback(data, function(button, index, data)
		self:renderPetTypeCountInfo(button, index, data)
	end, item)
	self.multiList.luaRenderItem = self:guardRunCallback(data, function(button, index, data)
		self:instantiateMultiItem(button, data)
	end, item)
	self.listKeyUList.luaRenderItem = self:guardRunCallback(data, function(button, index, data)
		self:renderKeyItem(button, index, data)
	end, item)

	self:refreshMultiView(data)
	item:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	pg.game.audio:playEvent("SFX_UI_HudTipGetPetMulti")
end

function MultiPetObtainsItem:openLastPetManagement(data)
	local petInfos = data and data.newPets or {}
	local lastPetInfo = petInfos[#petInfos]

	if not lastPetInfo or not lastPetInfo.id then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT, {
		petId = lastPetInfo.id
	})
	self:recycleToast(data)
	pg.game.audio:triggerEvent("ui_sfx_button")
end

function MultiPetObtainsItem:getPetTypeCountInfo(data)
	local ret = {}
	local petInfos = data and data.newPets or {}
	local bossCount = 0
	local miniCount = 0
	local darkCount = 0
	local normalShinyCount = 0
	local whiteShinyCount = 0
	local blackShinyCount = 0
	local formInfoMap = {}
	local formInfoList = {}
	local rainbowFormInfoList = {}

	for _, info in ipairs(petInfos) do
		local petInfo = info.id and pg.me:getPetInfo(info.id)
		local label = info.label or petInfo and petInfo.label or 0
		local templateId = info.templateId or petInfo and petInfo.templateId
		local shinyStyle = info.shinyStyle or petInfo and petInfo.shinyStyle or 0
		local bodySizeType = info.bodySizeType

		if bodySizeType == nil and petInfo then
			bodySizeType = petInfo.bodySizeType
		end

		local isBoss = Utils.isLabelElite(label) or Utils.isLabelBoss(label) or info.isBoss
		local isMini = bodySizeType == Const.PET_BODY_SIZE_TYPE.MINI or info.isMini
		local isDark = Utils.isLabelDark(label) or data.isDark

		if isMini then
			miniCount = miniCount + 1
		elseif isBoss then
			bossCount = bossCount + 1
		end

		if isDark then
			darkCount = darkCount + 1
		end

		if templateId then
			local formId = Utils.getPetFormIdByTemplateId(templateId)

			if formId and formId ~= 0 then
				local formCfg = PetFormTypeData[formId]
				local formQuality = formCfg and formCfg.formQuality or 3

				if formCfg and formQuality >= 3 then
					local formCountInfo = formInfoMap[formId]

					if not formCountInfo then
						formCountInfo = {
							count = 0,
							state = 1,
							formId = formId,
							templateId = templateId
						}
						formInfoMap[formId] = formCountInfo

						if Utils.isRainbowTypeByTemplateId(templateId) or Utils.isBlackRainbowTypeByTemplateId(templateId) then
							rainbowFormInfoList[#rainbowFormInfoList + 1] = formCountInfo
						else
							formInfoList[#formInfoList + 1] = formCountInfo
						end
					end

					formCountInfo.count = formCountInfo.count + 1
				end
			end
		end

		if Utils.isLabelShiny(label) then
			if shinyStyle == Const.PET_SHINY_STYLE.WHITE then
				whiteShinyCount = whiteShinyCount + 1
			elseif shinyStyle == Const.PET_SHINY_STYLE.BLACK then
				blackShinyCount = blackShinyCount + 1
			else
				normalShinyCount = normalShinyCount + 1
			end
		end
	end

	if bossCount > 0 then
		ret[#ret + 1] = {
			state = 3,
			typeIndex = 0,
			count = bossCount
		}
	end

	if miniCount > 0 then
		ret[#ret + 1] = {
			state = 3,
			typeIndex = 1,
			count = miniCount
		}
	end

	if darkCount > 0 then
		ret[#ret + 1] = {
			state = 4,
			typeIndex = 0,
			count = darkCount
		}
	end

	table.sort(formInfoList, function(a, b)
		return a.formId < b.formId
	end)

	for _, info in ipairs(formInfoList) do
		ret[#ret + 1] = info
	end

	table.sort(rainbowFormInfoList, function(a, b)
		return a.formId < b.formId
	end)

	for _, info in ipairs(rainbowFormInfoList) do
		ret[#ret + 1] = info
	end

	if normalShinyCount > 0 then
		ret[#ret + 1] = {
			state = 2,
			typeIndex = 0,
			count = normalShinyCount
		}
	end

	if whiteShinyCount > 0 then
		ret[#ret + 1] = {
			state = 2,
			typeIndex = 2,
			count = whiteShinyCount
		}
	end

	if blackShinyCount > 0 then
		ret[#ret + 1] = {
			state = 2,
			typeIndex = 1,
			count = blackShinyCount
		}
	end

	return ret
end

function MultiPetObtainsItem:renderPetTypeCountInfo(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local formNewUButton = objectReference:GetRefValue("formNewUButton")
	local flashUButton = objectReference:GetRefValue("flashUButton")
	local bossUButton = objectReference:GetRefValue("bossUButton")
	local umbralUButton = objectReference:GetRefValue("umbralUButton")

	button:TryChangePage("State", data.state)

	if data.state == 3 then
		bossUButton:TryChangePage("Type", data.typeIndex)
		bossUButton:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	elseif data.state == 2 then
		flashUButton:TryChangePage("Type", data.typeIndex)
		flashUButton:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	elseif data.state == 1 then
		LuaUIUtils.renderFormItem(formNewUButton, data.templateId)
		formNewUButton:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	elseif data.state == 4 then
		umbralUButton:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end

	ClientTextUtils.setText(txtNameUText, "x", data.count)
end

function MultiPetObtainsItem:renderKeyItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
	local btnTipsUText = objectReference:GetRefValue("btnTipsUText")

	keyHotKeyContent:SetHotKeyPaths(data.actionKey)
	ClientTextUtils.setText(btnTipsUText, data.label)
	self:bindHotKeyItemLongPress(objectReference, data)
end

function MultiPetObtainsItem:instantiateMultiItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local specialityUButton = objectReference:GetRefValue("specialityUButton")
	local txtLevelUText = objectReference:GetRefValue("txtLevelUText")
	local umbralUContainer = objectReference:GetRefValue("umbralUContainer")
	local petInfo = data.id and pg.me:getPetInfo(data.id)
	local label = data.label or petInfo and petInfo.label or 0
	local shinyStyle = data.shinyStyle or petInfo and petInfo.shinyStyle or 0
	local bodySizeType = data.bodySizeType

	if bodySizeType == nil and petInfo then
		bodySizeType = petInfo.bodySizeType
	end

	button:TryChangePage("isBoss", 0)

	local isDark = Utils.isLabelDark(label) or data.isDark

	if isDark then
		umbralUContainer:SetActive(true)
		umbralUContainer:LoadDefaultUrlManually()
	else
		umbralUContainer:SetActive(false)
	end

	local isShiny = Utils.isLabelShiny(label) or data.isRare

	LuaUIUtils.renderPetHeadFlashBgAndFrame(objectReference, isShiny, shinyStyle)

	local specialCode, _ = LuaUIUtils.getPetSpecialAttr(data.id)

	if specialCode then
		specialityUButton:SetActiveFastest(true)
		specialityUButton:TryChangePage("Speciity", SPECIAL_CODE_PAGES[specialCode])
	else
		specialityUButton:SetActiveFastest(false)
	end

	ClientTextUtils.setText(txtLevelUText, data.lv)

	iconUImage.url = LuaUIUtils.getPetIcon(data.headIconName, LuaUIUtils.PET_ICON, label, data.gender)
end

function MultiPetObtainsItem:refreshMultiView(data)
	local petInfos = data.newPets
	local content = self.uContainer.content
	local petCount = #petInfos

	ClientTextUtils.setText(self.multCount, string.format("x%s", petCount))
	pg.game.audio:triggerEvent("ui_hud_catch_multi_showl")

	local isMobile = pg.global.ui:runPlatformByMobile()
	local canShowKeyList = not isMobile
	local canOpenPetManagement = canShowKeyList and LuaUIUtils.checkFuncUnlock(Const.FUNCTION_IDS.PETENTRY)

	self.root.luaClick = nil

	self:clearHotKeyBindByPath(content.gameObject, "Hud/GetSinglePet")
	self.listKeyUList:SetActiveFastest(canShowKeyList)

	if canShowKeyList then
		local keyListData = {
			{
				actionKey = "Hud/ItemClose",
				label = pg.getGameString("CLOSE")
			}
		}

		if canOpenPetManagement then
			keyListData[#keyListData + 1] = {
				actionKey = "Hud/GetSinglePet",
				hotKeyObject = content.gameObject,
				longPressFunc = function()
					if self.root.luaClick then
						self.root.luaClick()
					end
				end,
				label = pg.getGameString("CONSOLE_BAR_VIEW")
			}
		end

		self.listKeyUList:SetList(keyListData)
		LuaUIUtils.bindHotKey(content.gameObject, "Hud/ItemClose", function()
			self:recycleToast(data)
		end, nil, 100)
	end

	if canOpenPetManagement then
		function self.root.luaClick()
			self:openLastPetManagement(data)
		end
	end

	local typeCountInfo = self:getPetTypeCountInfo(data)

	if #typeCountInfo > 0 then
		content:TryChangePage("Speciality", 0)
	else
		content:TryChangePage("Speciality", 1)
	end

	self.specialityUList:SetList(typeCountInfo)

	if #typeCountInfo > 0 then
		if not data._multiPetRumblePlayed then
			data._multiPetRumblePlayed = true

			pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonMiddle")
		end

		self:startTimer(function()
			pg.game.audio:triggerEvent("SFX_UI_GetSinglePet_GetPet_Multi_Special")
		end, 1)
	end

	self.multiList:SetList(petInfos)
end

function MultiPetObtainsItem:playMultiAnim(step)
	if #self.multiAnimStack == 0 then
		return
	end

	local item = table.remove(self.multiAnimStack, 1)
	local data = item.data
	local anim = item.anim
	local panelUWidget = item.panelUWidget

	data.inst = self.multi

	if panelUWidget then
		panelUWidget.renderOpacity = 1
	end

	if anim then
		anim:Stop()
		anim:Play("VX_Node_GetPet_Multi_In")
	end

	if data.isRare or data.isBoss then
		pg.game.audio:triggerEvent("ui_hud_catch_multi_rare")
	else
		pg.game.audio:triggerEvent("ui_hud_catch_multi_normal")
	end

	local delay = (data.isRare or data.isBoss) and SysConfigData.GROUPCAPNOTIFACATION_TIME_SPECIAL or SysConfigData.GROUPCAPNOTIFACATION_TIME_NORMAL
end

function MultiPetObtainsItem:GMPushData(data)
	local petCandidates = {}

	for _, petInfo in pairs(pg.me and pg.me.pets or {}) do
		if petInfo and PetData[petInfo.templateId] then
			petCandidates[#petCandidates + 1] = petInfo
		end
	end

	local newPets = {}

	if #petCandidates > 0 then
		local availablePets = {}
		local petCount = math.random(3, 6)

		for i = 1, petCount do
			if #availablePets == 0 then
				for index, petInfo in ipairs(petCandidates) do
					availablePets[index] = petInfo
				end
			end

			local randomIndex = math.random(1, #availablePets)
			local petInfo = table.remove(availablePets, randomIndex)
			local petData = PetData[petInfo.templateId]
			local label = petInfo.label

			newPets[i] = {
				elementTypes = petData.elementType,
				gender = petInfo.gender,
				headIconName = petData.iconName,
				iconName = petData.iconName,
				id = petInfo.id,
				isBoss = Utils.isLabelElite(label),
				isDark = Utils.isLabelDark(label),
				isRare = Utils.isLabelShiny(label),
				isVariant = Utils.isLabelVariant(label),
				label = label,
				lv = petInfo.level,
				name = petData.name,
				templateId = petInfo.templateId,
				bodySizeType = petInfo.bodySizeType,
				shinyStyle = petInfo.shinyStyle
			}
		end
	end

	data.newPets = newPets
end

function MultiPetObtainsItem:onRecycleStarted(data, target)
	if self.animTimer then
		self:killTimer(self.animTimer)

		self.animTimer = nil
	end
end

function MultiPetObtainsItem:onRecycleFinished(data, reason)
	if self:isQueueEmpty() and not self:isRunning() then
		self:setMobileQAreaVisible(true)
	end
end

return MultiPetObtainsItem
