-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopDesign\\WorkShopDesignModel.lua

local Class = require("Core.Framework.Class")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local Utils = require("Common.Utils.Utils")
local UIModel = require("Guis.UIModel")
local WorkShopDesignModel = Class.LightClass("WorkShopDesignModel", UIModel)
local LuaUIUtils = require("Utils.LuaUIUtils")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local AppearanceData = require("Data.appearance_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
local ItemQuality = require("Data.item_quality")

local function isPlayerOwnAppearanceItem(itemId)
	if not itemId or not pg.me then
		return false
	end

	if pg.me.itemCountBindMap and ItemUtils.getItemCountById(pg.me, itemId, true) > 0 then
		return true
	end

	local appearanceInfo = pg.me.appearanceInfo

	if AppearanceData[itemId] then
		return appearanceInfo and appearanceInfo[itemId] ~= nil
	end

	local suitData = AppearanceSuitData[itemId]

	if suitData then
		if not appearanceInfo then
			return false
		end

		local partList = suitData.appearanceList or {}

		if #partList == 0 then
			return false
		end

		for _, partId in ipairs(partList) do
			if not appearanceInfo[partId] then
				return false
			end
		end

		return true
	end

	if AvatarHairSuitData[itemId] then
		return LuaUIUtils.isHairSuitClaimed(pg.me, itemId)
	end

	if AppearanceJewelryPetData[itemId] then
		return ItemUtils.getItemCountById(pg.me, itemId, true) > 0
	end

	return false
end

function WorkShopDesignModel:isAppearanceVisible(id)
	if ClientCashShopUtils.isAppearanceReleaseTimeOpen(id) then
		return true
	end

	return isPlayerOwnAppearanceItem(id)
end

function WorkShopDesignModel:getFilters()
	local res = {}

	table.insert(res, {
		quality = -1,
		text = pg.getGameString("ALL")
	})

	for index, info in ipairs(ItemQuality) do
		table.insert(res, {
			text = info.name,
			quality = index
		})
	end

	return res
end

function WorkShopDesignModel:getHairSuitList(bodyType, forceFirstSuitId, filterFunc)
	local function showStatusFilter(suitInfo)
		local suitData = AvatarHairSuitData[suitInfo.id] or {}
		local isVisible = false
		local partList = suitData.appearanceList or {}

		for _, cfgId in ipairs(partList) do
			local cfg = AppearanceData[cfgId] or {}
			local showStatus = cfg.showStatus or 1

			if showStatus == 1 then
				isVisible = true

				break
			elseif showStatus == 3 then
				local partInfo = LuaUIUtils.getHairPartInfo(pg.me, cfgId)

				if partInfo and partInfo.claimed then
					isVisible = true

					break
				end
			end
		end

		if not isVisible or not self:isAppearanceVisible(suitInfo.id) then
			return false
		end

		return filterFunc == nil or filterFunc(suitInfo) == true
	end

	local params = {
		bodyType = bodyType,
		orderBy = function(a, b)
			if a.equipped ~= b.equipped then
				return a.equipped
			elseif a.claimed ~= b.claimed then
				return a.claimed
			else
				return a.id < b.id
			end
		end,
		forceFirstSuitId = forceFirstSuitId,
		filterFunc = showStatusFilter
	}

	return AvatarUtils.getHairSuitList(params)
end

function WorkShopDesignModel:getCostumeTabList()
	return AvatarUtils.getClothPartList()
end

function WorkShopDesignModel:getPartCloths(clothId, bodyType, forceFirstClothesId, filterFunc)
	local function checkCanStain(clothInfo)
		return AvatarUtils.isDyeingEnabled(clothInfo.itemId)
	end

	local params = {
		slotId = clothId,
		bodyType = bodyType,
		orderBy = function(a, b)
			if a.equipped ~= b.equipped then
				return a.equipped
			elseif a.claimed ~= b.claimed then
				return a.claimed
			else
				return a.clothesId < b.clothesId
			end
		end,
		forceFirstClothesId = forceFirstClothesId,
		filterFunc = filterFunc,
		checkCanStain = checkCanStain
	}
	local res = AvatarUtils.getClothesInfoList(params)
	local filtered = {}

	for _, data in ipairs(res) do
		local cfg = AppearanceData[data.clothesId] or AppearanceData[data.itemId] or {}
		local itemId = data.clothesId or data.itemId
		local showStatus = cfg.showStatus or 1

		if showStatus ~= 2 and self:isAppearanceVisible(itemId) and (showStatus ~= 3 or data.claimed) then
			filtered[#filtered + 1] = data
		end
	end

	res = filtered

	for _, info in ipairs(res) do
		info.state = info.claimed and LuaUIUtils.SELECT_STATE.HAVE or LuaUIUtils.SELECT_STATE.LOCKED
	end

	return res
end

function WorkShopDesignModel:initAvatarSceneData()
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
end

function WorkShopDesignModel:wearClothWithId(clothId)
	local cData = AppearanceData[clothId]

	if cData == nil then
		return
	end

	local entity = self.avatarScene:getCurEntity()
	local modelView = entity.eModel.modelView
	local partModelInfo = modelView.modelInfo.partModelInfo

	partModelInfo:ModifyPartItem(cData.res, Utils.deepCopyTable(cData.points))
	AppearanceEffectUtils.setPartAppearance(entity, clothId, true)
	ClientModelUtils.refreshModels(entity, modelView)
end

function WorkShopDesignModel:applyClothPreset(slotId, clothId)
	local ent = self.avatarScene:getCurEntity()
	local unit = AvatarUtils.applyClothesPreset(ent, slotId, clothId)

	if unit == false or unit == true then
		return false
	end

	self.curUnit = {}

	local rawTable = unit:getRawTable()

	if not string.isNilOrEmpty(rawTable.stainMatMap) then
		self.curUnit.stainMatMap = string.toTable(decompressFromStr(rawTable.stainMatMap))
	else
		self.curUnit.stainMatMap = {}
	end

	if not string.isNilOrEmpty(rawTable.decalMatMap) then
		self.curUnit.decalMatMap = string.toTable(decompressFromStr(rawTable.decalMatMap))
	else
		self.curUnit.decalMatMap = {}
	end

	return true
end

function WorkShopDesignModel:isClothCanStaining(clothId)
	local cData = AppearanceData[clothId]

	if cData == nil then
		return false
	end

	local entity = self.avatarScene:getCurEntity()

	return entity.eModel.shaderView:IsClothCanStaining(cData.res)
end

return WorkShopDesignModel
