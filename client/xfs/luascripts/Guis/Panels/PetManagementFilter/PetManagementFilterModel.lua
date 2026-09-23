-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagementFilter\\PetManagementFilterModel.lua

local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local AddressDataConst = require("Const.AddressDataConst")
local UIConst = require("Const.UIConst")
local ElementNameToId = require("Data.element_name_to_id")
local ElementPropData = require("Data.element_prop_data")
local HomeAbilityData = require("Data.home_ability_data")
local PetManagementFilterModel = Class.LightClass("PetManagementFilterModel", UIModel)
local PetFormTypeData = require("Data.pet_form_type_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local GlobalData = require("Core.Client.GlobalData")
local PetConfigData = require("Data.pet_config_data")
local s_sessionCache = {}

local function getUserKey()
	local name = GlobalData.UserName or ""
	local serverId = tostring(GlobalData.ServerId or 0)

	return name .. "_" .. serverId
end

function PetManagementFilterModel.saveSessionState(filterType, filter, sortId, isDescending)
	local userKey = getUserKey()

	if not s_sessionCache[userKey] then
		s_sessionCache[userKey] = {}
	end

	s_sessionCache[userKey][filterType] = {
		filter = Utils.deepCopyTable(filter),
		sortId = sortId or 0,
		isDescending = isDescending ~= false
	}
end

function PetManagementFilterModel.loadSessionState(filterType)
	local userKey = getUserKey()
	local userCache = s_sessionCache[userKey]

	if userCache then
		return userCache[filterType]
	end

	return nil
end

function PetManagementFilterModel.clearSessionCache()
	local userKey = getUserKey()

	s_sessionCache[userKey] = nil
end

function PetManagementFilterModel:ctor()
	PetManagementFilterModel.super.ctor(self)

	self.m_filterInfos = nil
end

function PetManagementFilterModel:setInfo(info)
	if info then
		self._minPriceLimit = info.minPriceLimit or 1
		self._maxPriceLimit = info.maxPriceLimit or 1000000
	end
end

function PetManagementFilterModel:getAllElementsInfo(filter)
	filter = filter or UIConst.PET_SLOT_DISPLAY_TYPE.Normal

	local data = {}

	if filter == UIConst.PET_SLOT_DISPLAY_TYPE.Normal or filter == UIConst.PET_SLOT_DISPLAY_TYPE.TradeMarketPet or filter == UIConst.PET_SLOT_DISPLAY_TYPE.TradeMarketPetOverview then
		for k, v in pairs(ElementNameToId) do
			if k ~= "null" and ElementPropData[v] and ElementPropData[v].isShow == 1 then
				local d = {}

				d.name = k
				d.icon = AddressDataConst["FILTER_ELEMENT_" .. v]
				d.order = v
				data[#data + 1] = d
			end
		end
	else
		for id, cfg in pairs(HomeAbilityData) do
			local item = {}

			item.order = id
			item.id = id
			item.icon = cfg.icon
			item.iconColor = cfg.iconColor
			data[#data + 1] = item
		end
	end

	table.sort(data, function(a, b)
		return a.order < b.order
	end)

	return data
end

function PetManagementFilterModel:getAllSortsInfo(inVitality, filter)
	if filter == UIConst.PET_SLOT_DISPLAY_TYPE.TradeMarketPet then
		return {
			{
				idx = 1,
				name = pg.getGameString("FILTER_PRICE")
			},
			{
				idx = 2,
				name = pg.getGameString("TRADE_FOLLOW_NUM")
			},
			{
				idx = 3,
				name = pg.getGameString("FILTER_RARITY")
			},
			{
				idx = 4,
				name = pg.getGameString("SORT_TYPE_2")
			},
			{
				idx = 5,
				name = pg.getGameString("LEVEL")
			},
			{
				idx = 6,
				name = pg.getGameString("FILTER_TALENT")
			},
			{
				idx = 7,
				name = pg.getGameString("FILTER_FEATURE")
			}
		}
	end

	local sortInfos = {}

	for i = 1, 7 do
		local sortInfo = {}

		sortInfo.idx = i
		sortInfo.name = pg.getGameString("SORT_TYPE_" .. i)
		sortInfos[#sortInfos + 1] = sortInfo
	end

	sortInfos[#sortInfos + 1] = {
		idx = 9,
		name = pg.getGameString("PET_FAMILY")
	}
	sortInfos[#sortInfos + 1] = {
		idx = 10,
		name = pg.getGameString("FILTER_ROLE")
	}

	if inVitality then
		sortInfos[#sortInfos + 1] = {
			idx = 8,
			name = pg.getGameString("SORT_TYPE_" .. 10)
		}
	end

	return sortInfos
end

function PetManagementFilterModel:getAllFiltersInfo(filter, forceUpdate)
	filter = filter or UIConst.PET_SLOT_DISPLAY_TYPE.Normal

	local status

	if filter == UIConst.PET_SLOT_DISPLAY_TYPE.Normal then
		status = {
			tIndex = 1,
			btnGroups = {
				{
					key = "isNotInBattle",
					name = pg.getGameString("FILTER_BATTLE1"),
					icon = AddressDataConst.FILTER_STATE_NOT_IN_BATTLE
				},
				{
					key = "isInBattle",
					name = pg.getGameString("FILTER_BATTLE2"),
					icon = AddressDataConst.FILTER_STATE_IN_BATTLE
				},
				{
					key = "isInExplore",
					name = pg.getGameString("FILTER_EXPLORE"),
					icon = AddressDataConst.FILTER_STATE_IN_EXPLORE
				}
			}
		}
	elseif filter == UIConst.PET_SLOT_DISPLAY_TYPE.Homeland then
		status = {
			tIndex = 1,
			btnGroups = {
				{
					key = "isNotInBattle",
					name = pg.getGameString("FILTER_BATTLE1"),
					icon = AddressDataConst.FILTER_STATE_NOT_IN_BATTLE
				},
				{
					key = "isInBattle",
					name = pg.getGameString("FILTER_BATTLE2"),
					icon = AddressDataConst.FILTER_STATE_IN_BATTLE
				},
				{
					key = "isInExplore",
					name = pg.getGameString("FILTER_EXPLORE"),
					icon = AddressDataConst.FILTER_STATE_IN_EXPLORE
				}
			}
		}
	end

	if not self.m_filterInfos or forceUpdate then
		local energyNameL18nKey = UIConst.PET_FUNCTION_TEXT_MAP.ENERGY
		local energyNameKey = energyNameL18nKey and PetConfigData[energyNameL18nKey] or ""
		local energyName = pg.getLocalizationText(energyNameKey)

		self.m_filterInfos = {}

		if filter == UIConst.PET_SLOT_DISPLAY_TYPE.TradeMarketPetOverview then
			table.insert(self.m_filterInfos, {
				tIndex = 0,
				title = pg.getGameString("FILTER_ELEMENT")
			})
			table.insert(self.m_filterInfos, {
				tIndex = 2,
				elementGroups = self:getAllElementsInfo(filter)
			})
			table.insert(self.m_filterInfos, {
				tIndex = 0,
				title = pg.getGameString("FILTER_ROLE")
			})
			table.insert(self.m_filterInfos, {
				tIndex = 1,
				btnGroups = {
					{
						key = "isDPS",
						name = pg.getGameString("FILTER_DPS"),
						icon = AddressDataConst.FILTER_ROLE_DPS
					},
					{
						key = "isSup",
						name = pg.getGameString("FILTER_SUP"),
						icon = AddressDataConst.FILTER_ROLE_SUP
					},
					{
						key = "isHeal",
						name = pg.getGameString("FILTER_HEAL"),
						icon = AddressDataConst.FILTER_ROLE_HEAL
					},
					{
						key = "isBreak",
						name = pg.getGameString("ATTRIBUTE_NAT"),
						icon = AddressDataConst.FILTER_ROLE_BREAK
					},
					{
						key = "isEnergy",
						name = energyName,
						icon = AddressDataConst.FILTER_ROLE_ENERGY
					}
				}
			})
			table.insert(self.m_filterInfos, {
				tIndex = 0,
				title = pg.getGameString("PET_FORM_NAME")
			})
			table.insert(self.m_filterInfos, self:getFormFilterInfo())

			return self.m_filterInfos
		end

		if filter == UIConst.PET_SLOT_DISPLAY_TYPE.TradeMarketPet then
			table.insert(self.m_filterInfos, {
				tIndex = 0,
				title = pg.getGameString("FILTER_FOLLOW")
			})
			table.insert(self.m_filterInfos, {
				tIndex = 1,
				btnGroups = {
					{
						key = "isFollow",
						name = pg.getGameString("FILTER_FOLLOW1"),
						icon = AddressDataConst.FILTER_STATE_NOT_IN_BATTLE
					},
					{
						key = "isNotFollow",
						name = pg.getGameString("FILTER_FOLLOW2"),
						icon = AddressDataConst.FILTER_STATE_IN_BATTLE
					}
				}
			})
			table.insert(self.m_filterInfos, {
				tIndex = 0,
				title = pg.getGameString("FILTER_PRICE")
			})
			table.insert(self.m_filterInfos, {
				tIndex = 4,
				minPriceLimit = self._minPriceLimit,
				maxPriceLimit = self._maxPriceLimit
			})
		end

		table.insert(self.m_filterInfos, {
			tIndex = 0,
			title = pg.getGameString("FILTER_RARITY")
		})
		table.insert(self.m_filterInfos, {
			tIndex = 1,
			btnGroups = {
				[4] = {
					key = "isNormal",
					name = pg.getGameString("FILTER_NORMAL"),
					icon = AddressDataConst.FILTER_RARITY1
				},
				{
					key = "isShiny",
					name = pg.getGameString("FILTER_SHINY"),
					icon = AddressDataConst.FILTER_RARITY2
				},
				[3] = {
					key = "isBoss",
					name = pg.getGameString("FILTER_BOSS"),
					icon = AddressDataConst.FILTER_RARITY3
				},
				{
					key = "isRainbow",
					name = pg.getGameString("FILTER_RAINBOW"),
					icon = AddressDataConst.FILTER_RARITY5
				},
				[5] = {
					key = "isDark",
					name = pg.getGameString("FILTER_DARK"),
					icon = AddressDataConst.FILTER_RARITY6
				}
			}
		})
		table.insert(self.m_filterInfos, {
			tIndex = 0,
			title = pg.getGameString("FILTER_ELEMENT")
		})
		table.insert(self.m_filterInfos, {
			tIndex = filter == UIConst.PET_SLOT_DISPLAY_TYPE.Homeland and 3 or 2,
			elementGroups = self:getAllElementsInfo(filter)
		})
		table.insert(self.m_filterInfos, {
			tIndex = 0,
			title = pg.getGameString("FILTER_TALENT")
		})
		table.insert(self.m_filterInfos, {
			tIndex = 2,
			elementGroups = {
				[4] = {
					key = "isRating1",
					name = pg.getGameString("INTERFACE_DISPLAY_RATING_1"),
					icon = AddressDataConst.FILTER_RATING1
				},
				[3] = {
					key = "isRating2",
					name = pg.getGameString("INTERFACE_DISPLAY_RATING_2"),
					icon = AddressDataConst.FILTER_RATING2
				},
				[2] = {
					key = "isRating3",
					name = pg.getGameString("INTERFACE_DISPLAY_RATING_3"),
					icon = AddressDataConst.FILTER_RATING3
				},
				{
					key = "isRating4",
					name = pg.getGameString("INTERFACE_DISPLAY_RATING_4"),
					icon = AddressDataConst.FILTER_RATING4
				}
			}
		})
		table.insert(self.m_filterInfos, {
			tIndex = 0,
			title = pg.getGameString("FILTER_ROLE")
		})
		table.insert(self.m_filterInfos, {
			tIndex = 1,
			btnGroups = {
				{
					key = "isDPS",
					name = pg.getGameString("FILTER_DPS"),
					icon = AddressDataConst.FILTER_ROLE_DPS
				},
				{
					key = "isSup",
					name = pg.getGameString("FILTER_SUP"),
					icon = AddressDataConst.FILTER_ROLE_SUP
				},
				{
					key = "isHeal",
					name = pg.getGameString("FILTER_HEAL"),
					icon = AddressDataConst.FILTER_ROLE_HEAL
				},
				{
					key = "isBreak",
					name = pg.getGameString("ATTRIBUTE_NAT"),
					icon = AddressDataConst.FILTER_ROLE_BREAK
				},
				{
					key = "isEnergy",
					name = energyName,
					icon = AddressDataConst.FILTER_ROLE_ENERGY
				}
			}
		})

		if filter ~= UIConst.PET_SLOT_DISPLAY_TYPE.TradeMarketPet then
			table.insert(self.m_filterInfos, {
				tIndex = 0,
				title = pg.getGameString("FILTER_FAVORITE")
			})
			table.insert(self.m_filterInfos, self:getFavoriteTypeFilterInfo())
			table.insert(self.m_filterInfos, {
				tIndex = 0,
				title = pg.getGameString("FILTER_STATUS")
			})
			table.insert(self.m_filterInfos, status)
		end

		table.insert(self.m_filterInfos, {
			tIndex = 0,
			title = pg.getGameString("PET_FORM_NAME")
		})
		table.insert(self.m_filterInfos, self:getFormFilterInfo())
	end

	return self.m_filterInfos
end

function PetManagementFilterModel:getFavoriteTypeFilterInfo()
	local PetHandbookConfigData = require("Data.pet_handbook_config_data")
	local ret = {
		tIndex = 2,
		elementGroups = {}
	}

	for i = 1, PetHandbookConfigData.favoriteTypeMax - 1 do
		ret.elementGroups[i] = {
			size = 120,
			key = "isFavoriteType" .. i,
			icon = AddressDataConst["FAVORITE_STAR_ICON_" .. i]
		}
	end

	return ret
end

function PetManagementFilterModel:getFormFilterInfo()
	local ret = {
		tIndex = 1,
		btnGroups = {}
	}
	local sortsMap = {}

	for formTypeId, formType in pairs(PetFormTypeData) do
		if not formType.belong then
			table.insert(sortsMap, {
				sort = formType.sort or formTypeId,
				formTypeId = formTypeId
			})
		end
	end

	table.sort(sortsMap, function(a, b)
		return a.sort < b.sort
	end)

	for _, sortInfo in ipairs(sortsMap) do
		local formTypeId = sortInfo.formTypeId
		local formType = PetFormTypeData[formTypeId]

		table.insert(ret.btnGroups, {
			name = ClientTextUtils.getLocalizationText(formType.name),
			key = "isForm" .. tostring(formTypeId),
			icon = formType.iconSmall
		})
	end

	return ret
end

return PetManagementFilterModel
