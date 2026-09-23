-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\CTipArea\\ExplorePetReplaceItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local GmToolUtils = require("Utils.GmToolUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local HotkeyConst = require("Const.HotkeyConst")
local PetData = require("Data.pet_data")
local AbilityConst = require("Common.Const.AbilityConst")
local Utils = require("Common.Utils.Utils")
local ExplorePetReplaceItem = Class.LightClass("ExplorePetReplaceItem", BaseQueueItem)
local Const = require("Common.Const.Const")
local MAX_EXPLORE_PETS_COUNT = 3
local REPLACE_ACTION_PATH = "Hud/ReplaceExplorePet"
local CLOSE_ACTION_PATH = "Hud/ItemClose"

function ExplorePetReplaceItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function ExplorePetReplaceItem:pushData(data)
	self:enqueue(data)
end

function ExplorePetReplaceItem:GMPushData(data)
	local selectedPet

	for _, petInfo in pairs(pg.me and pg.me:getPets() or {}) do
		local petData = PetData[petInfo.templateId]

		if petData and ((petData.canClimb or 0) > 0 or (petData.canFly or 0) > 0 or (petData.canSwim or 0) > 0) and (not selectedPet or petInfo.id < selectedPet.id) then
			selectedPet = petInfo
		end
	end

	data.petId = selectedPet and selectedPet.id
	data.higherClimb = false
	data.higherGlide = false
	data.higherSwim = false

	if not selectedPet then
		return
	end

	local petData = PetData[selectedPet.templateId]

	data.higherClimb = (petData.canClimb or 0) > 0
	data.higherGlide = not data.higherClimb and (petData.canFly or 0) > 0
	data.higherSwim = not data.higherClimb and not data.higherGlide and (petData.canSwim or 0) > 0
end

function ExplorePetReplaceItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function ExplorePetReplaceItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	while not self:isQueueEmpty() do
		local data = self:dequeue()

		if pg.me and pg.me:getPetInfo(data.petId) then
			data.endTime = Time.realSecondCache + (data.duration or 5)
			data.destroyed = nil

			self:addRunItem(data)
			self:initUContainer(data)

			return
		end
	end

	self:refreshRunState()
end

function ExplorePetReplaceItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function ExplorePetReplaceItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function ExplorePetReplaceItem:recycleToast(data, force, animKey)
	self:requestRecycle(data, force, animKey or CS.XGUI.EInvokeTime.User2)
end

function ExplorePetReplaceItem:initUContainer(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function(item)
			if IsNil(item) or self.uContainer.content ~= item then
				return
			end

			self:renderItem(item, data)
		end))
	else
		self:renderItem(self.uContainer.content, data)
	end
end

function ExplorePetReplaceItem:renderItem(item, data)
	if data.destroyed or data.removing or self.runList[1] ~= data then
		return
	end

	local petInfo = pg.me and pg.me:getPetInfo(data.petId)

	if not petInfo then
		data.petMissing = true

		self:recycleToast(data, true)

		return
	end

	self.whichType = nil
	self.petId = nil
	self.mute = nil
	self.objectReference = item:GetComponent("ObjectReference")
	self.root = self.objectReference:GetRefValue("root")

	self:clearHotKeyBindByPath(item.gameObject, REPLACE_ACTION_PATH)

	self.petAbilityAssembleAnimation = self.objectReference:GetRefValue("petAbilityAssembleAnimation")
	self.imgPetUImage = self.objectReference:GetRefValue("imgPetUImage")
	self.txtTipsUSDFText = self.objectReference:GetRefValue("txtTipsUSDFText")
	self.abilityListUList = self.objectReference:GetRefValue("abilityListUList")
	self.petHeadUButton = self.objectReference:GetRefValue("petHeadUButton")
	self.listKeyUList = self.objectReference:GetRefValue("listKeyUList")

	local function replacePet()
		self:doReplace()
		self:recycleToast(data, false, CS.XGUI.EInvokeTime.User3)
		pg.game.audio:triggerEvent("ui_sfx_button")
	end

	local function closeToast()
		self:recycleToast(data, false, CS.XGUI.EInvokeTime.User2)
		pg.game.audio:triggerEvent("ui_sfx_button")
	end

	self.root.luaClick = replacePet

	local showKeyList = not pg.global.ui:runPlatformByMobile()

	self.listKeyUList:SetActiveFastest(showKeyList)

	if showKeyList then
		local keyData = {
			{
				path = REPLACE_ACTION_PATH,
				hotKeyObject = item.gameObject,
				longPressFunc = replacePet,
				label = pg.getGameString("AUTO_REPLACE")
			}
		}

		self.listKeyUList.luaRenderItem = self:guardRunCallback(data, function(button, _, keyInfo)
			local objectReference = button.transform:GetComponent("ObjectReference")
			local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
			local btnTipsUText = objectReference:GetRefValue("btnTipsUText")

			keyHotKeyContent:SetHotKeyPaths(keyInfo.path)
			ClientTextUtils.setText(btnTipsUText, keyInfo.label)
			self:bindHotKeyItemLongPress(objectReference, keyInfo)
		end, item)

		self.listKeyUList:SetList(keyData)
	end

	self:bindHotKeyPerform(CLOSE_ACTION_PATH, closeToast, item.gameObject)

	data.startTime = Time.realSecondCache

	self:refreshItemView(data, petInfo)
	item:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonMiddle")
end

function ExplorePetReplaceItem:doReplace()
	if self.mute then
		return
	end

	if not self.whichType then
		return
	end

	if self.whichType == "CLIMB" then
		self:modifyExplorePrepareFormation(1, self.petId)
	elseif self.whichType == "GLIDE" then
		self:modifyExplorePrepareFormation(2, self.petId)
	elseif self.whichType == "SWIM" then
		self:modifyExplorePrepareFormation(3, self.petId)
	end

	self.mute = true

	if self.repDuration then
		self:killTimer(self.repDuration)

		self.repDuration = nil
	end

	pg.global.showBubbleMessageRaw(pg.getGameString("REPLACE_EXPLORE_SUCCESS"))
end

function ExplorePetReplaceItem:modifyExplorePrepareFormation(index, newId)
	local player = pg.me

	if player:isInCombat() then
		pg.global.showBubbleMessageRaw(pg.getGameString("IN_COMBAT_SWITCH_PET_TIP"))

		return
	end

	if player.inExploreState then
		pg.global.showBubbleMessageRaw(pg.getGameString("IN_EXPLORE_SWITCH_PET_TIP"))

		return
	end

	local petIds = self:getPetExploreGroupPetsInModel()

	petIds[index] = newId

	pg.me:serverMsg("RPC_CS_ModifyPrepareFormation", 1, petIds, false)
end

function ExplorePetReplaceItem:getPetExploreGroupPetsInModel()
	local groupInfo = pg.me.prepareFormationList[1] or {}
	local petIds = groupInfo.exploreFormation or {}

	petIds = petIds:getRawTable()

	local ret = {}

	if #petIds <= 0 then
		for i = 1, MAX_EXPLORE_PETS_COUNT do
			ret[#ret + 1] = ""
		end
	else
		for _, petId in pairs(petIds) do
			ret[#ret + 1] = petId
		end
	end

	return ret
end

function ExplorePetReplaceItem:refreshItemView(info, petInfo)
	petInfo = petInfo:getRawTable()

	local pData = PetData[petInfo.templateId]

	pg.game.audio:playPetEmotionSound(petInfo.templateId, "Happy")

	self.imgPetUImage.url = LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender)

	local petHeadObjectReference = self.petHeadUButton:GetComponent("ObjectReference")

	LuaUIUtils.renderPetHeadFlashBgAndFrame(petHeadObjectReference, Utils.isLabelShiny(petInfo.label), petInfo.shinyStyle or 0)

	petInfo.exploreSkillsLevel = {
		canClimb = pData.canClimb ~= nil and pData.canClimb or nil,
		canFly = pData.canFly ~= nil and pData.canFly or nil,
		canSwim = pData.canSwim ~= nil and pData.canSwim or nil
	}
	petInfo.climbLevel = petInfo.exploreSkillsLevel.canClimb or 0
	petInfo.flyLevel = petInfo.exploreSkillsLevel.canFly or 0
	petInfo.swimLevel = petInfo.exploreSkillsLevel.canSwim or 0

	local str
	local index = 0

	if info.higherClimb then
		str = "CLIMB"
		index = 0
	elseif not info.higherClimb and info.higherGlide then
		str = "GLIDE"
		index = 1
	elseif not info.higherClimb and not info.higherGlide then
		str = "SWIM"
		index = 2
	end

	self.whichType = str
	self.petId = info.petId

	ClientTextUtils.setText(self.txtTipsUSDFText, string.format(pg.getGameString("REPLACE_EXPLORE"), pg.getGameString(str)))
	self:renderExploreSkillPoints(self.abilityListUList, index, petInfo)
end

function ExplorePetReplaceItem:renderExploreSkillPoints(abilityListUList, index, data)
	local tempExploreLevelData = {}

	function abilityListUList.luaRenderItem(button1, _, data1)
		local objectReference2 = button1:GetComponent("ObjectReference")
		local levelUList = objectReference2:GetRefValue("levelUList")

		function levelUList.luaRenderItem(button2, _, data2)
			button2:TryChangePage("Have", data2.have)
		end

		button1:TryChangePage("PetChar", data1.type)
		button1:TryChangePage("quality", data1.quality - 1)
		button1:TryChangePage("Equip", data1.equip)
		levelUList:SetList(data1.pointNum)
	end

	local climbPointNum = {}
	local glidePointNum = {}
	local swimPointNum = {}

	for i = 1, 3 do
		climbPointNum[i] = i <= data.climbLevel and {
			have = 1
		} or {
			have = 0
		}
		glidePointNum[i] = i <= data.flyLevel and {
			have = 1
		} or {
			have = 0
		}
		swimPointNum[i] = i <= data.swimLevel and {
			have = 1
		} or {
			have = 0
		}
	end

	if index + 1 == AbilityConst.SPECIFIC_ABILITY_INDEX_CLIMB and data.climbLevel ~= 0 then
		tempExploreLevelData[#tempExploreLevelData + 1] = {
			type = 1,
			equip = 1,
			quality = data.climbLevel,
			pointNum = climbPointNum
		}

		if data.flyLevel ~= 0 then
			tempExploreLevelData[#tempExploreLevelData + 1] = {
				type = 2,
				equip = 0,
				quality = data.flyLevel,
				pointNum = glidePointNum
			}
		end

		if data.swimLevel ~= 0 then
			tempExploreLevelData[#tempExploreLevelData + 1] = {
				type = 3,
				equip = 0,
				quality = data.swimLevel,
				pointNum = swimPointNum
			}
		end
	elseif index + 1 == AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE and data.flyLevel ~= 0 then
		tempExploreLevelData[#tempExploreLevelData + 1] = {
			type = 2,
			equip = 1,
			quality = data.flyLevel,
			pointNum = glidePointNum
		}

		if data.climbLevel ~= 0 then
			tempExploreLevelData[#tempExploreLevelData + 1] = {
				type = 1,
				equip = 0,
				quality = data.climbLevel,
				pointNum = climbPointNum
			}
		end

		if data.swimLevel ~= 0 then
			tempExploreLevelData[#tempExploreLevelData + 1] = {
				type = 3,
				equip = 0,
				quality = data.swimLevel,
				pointNum = swimPointNum
			}
		end
	elseif index + 1 == AbilityConst.SPECIFIC_ABILITY_INDEX_SWIM and data.swimLevel ~= 0 then
		tempExploreLevelData[#tempExploreLevelData + 1] = {
			type = 3,
			equip = 1,
			quality = data.swimLevel,
			pointNum = swimPointNum
		}

		if data.climbLevel ~= 0 then
			tempExploreLevelData[#tempExploreLevelData + 1] = {
				type = 1,
				equip = 0,
				quality = data.climbLevel,
				pointNum = climbPointNum
			}
		end

		if data.flyLevel ~= 0 then
			tempExploreLevelData[#tempExploreLevelData + 1] = {
				type = 2,
				equip = 0,
				quality = data.flyLevel,
				pointNum = glidePointNum
			}
		end
	end

	abilityListUList:SetList(tempExploreLevelData)
end

function ExplorePetReplaceItem:onRecycleCleanup(data, target, reason)
	data.destroyed = true

	self:cleanupRecycleContainer(target, reason, data.petMissing)
end

return ExplorePetReplaceItem
