-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\CTipArea\\PetEvolveItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetConfigData = require("Data.pet_config_data")
local PetData = require("Data.pet_data")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local Utils = require("Common.Utils.Utils")
local PetEvolveItem = Class.LightClass("PetEvolveItem", BaseQueueItem)
local Const = require("Common.Const.Const")
local CLOSE_ACTION_PATH = "Hud/ItemClose"
local EVOLVE_ACTION_PATH = "Hud/GetSinglePet"

function PetEvolveItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function PetEvolveItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function PetEvolveItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (PetConfigData.PanelEvoDuration or 3)

	self:addRunItem(data)
	self:initUContainer(data)
end

function PetEvolveItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function PetEvolveItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function PetEvolveItem:recycleToast(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.User2)
end

function PetEvolveItem:initUContainer(data)
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

function PetEvolveItem:renderItem(item, info)
	if info.canStageUp == nil then
		return
	end

	local objectReference = self.uContainer.content:GetComponent("ObjectReference")
	local petUImage = objectReference:GetRefValue("petUImage")
	local titleUText = objectReference:GetRefValue("titleUText")
	local descUText = objectReference:GetRefValue("descUText")
	local nodeAnimation = objectReference:GetRefValue("nodeAnimation")
	local nodeUComponent = objectReference:GetRefValue("nodeUComponent")
	local petHeadUButton = objectReference:GetRefValue("petHeadUButton")
	local listKeyUList = objectReference:GetRefValue("listKeyUList")
	local button = self.uContainer.content:GetComponent("UButton")

	self:clearHotKeyBindByPath(button.gameObject, EVOLVE_ACTION_PATH)

	local function startEvolve()
		self:openEvolveBranchSelect(info.petId)
		self:recycleToast(info)
		pg.game.audio:triggerEvent("ui_sfx_button")
	end

	local function closeToast()
		self:recycleToast(info)
		pg.game.audio:triggerEvent("ui_sfx_button")
	end

	button.luaClick = startEvolve

	local canStartEvolve = LuaUIUtils.checkFuncUnlock(Const.FUNCTION_IDS.PETENTRY)
	local showKeyList = not pg.global.ui:runPlatformByMobile() and canStartEvolve

	listKeyUList:SetActiveFastest(showKeyList)

	if showKeyList then
		local keyData = {
			{
				path = CLOSE_ACTION_PATH,
				label = pg.getGameString("CLOSE")
			},
			{
				path = EVOLVE_ACTION_PATH,
				hotKeyObject = button.gameObject,
				longPressFunc = startEvolve,
				label = pg.getGameString("START_EVOLVE")
			}
		}

		function listKeyUList.luaRenderItem(buttonItem, _, keyInfo)
			local keyObjectReference = buttonItem.transform:GetComponent("ObjectReference")
			local keyHotKeyContent = keyObjectReference:GetRefValue("keyHotKeyContent")
			local btnTipsUText = keyObjectReference:GetRefValue("btnTipsUText")

			keyHotKeyContent:SetHotKeyPaths(keyInfo.path)
			ClientTextUtils.setText(btnTipsUText, keyInfo.label)
			self:bindHotKeyItemLongPress(keyObjectReference, keyInfo)
		end

		listKeyUList:SetList(keyData)
	end

	local closeHotKeyBind = LuaUIUtils.bindHotKey(button.gameObject, CLOSE_ACTION_PATH, closeToast, nil, 100)

	if closeHotKeyBind then
		closeHotKeyBind.enabled = showKeyList
	end

	local petData = PetData[info.templateId] or {}
	local petInfo = pg.me and pg.me:getPetInfo(info.petId)
	local label = petInfo and petInfo.label or 0
	local gender = petInfo and petInfo.gender or nil
	local petIconUrl = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON, label, gender) or ""

	petUImage.url = petIconUrl

	local petHeadObjectReference = petHeadUButton:GetComponent("ObjectReference")
	local shinyStyle = petInfo and petInfo.shinyStyle or 0

	LuaUIUtils.renderPetHeadFlashBgAndFrame(petHeadObjectReference, Utils.isLabelShiny(label), shinyStyle)
	ClientTextUtils.setText(titleUText, pg.getLocalizationText(petData.name))
	ClientTextUtils.setText(descUText, pg.getGameString("EVOLVE_DESC"))
	nodeUComponent:TryChangePage("LevelUp", 1)
	pg.game.audio:playPetEmotionSound(info.templateId, "Happy")
	item:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonMiddle")
end

function PetEvolveItem:openEvolveBranchSelect(petId)
	if not pg.me or not pg.me:getPetInfo(petId) then
		return
	end

	if not PetResearchUtils.checkPetCanEvolve(petId) then
		return
	end

	PetResearchUtils.tryOpenPetEvolutionUI(petId)
end

return PetEvolveItem
