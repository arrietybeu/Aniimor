-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashSearch\\CashSearchModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ShopmallTabGroupData = require("Data.shopmall_tab_group_data")
local ShopConstantData = require("Data.shopmall_constant_data")
local CashSearchModel = Class.LightClass("CashSearchModel", UIModel)
local SEARCH_LIMIT = tonumber(ShopConstantData.search_limit and ShopConstantData.search_limit.number) or 10
local STORAGE_KEY = "cashSearch"
local SEPARATOR = ","
local FIELD_SEPARATOR = "|"

function CashSearchModel:setTabId(tabId)
	self._tabId = tabId
end

function CashSearchModel:getTabId()
	return self._tabId
end

function CashSearchModel:setDisplayGender(gender)
	self._displayGender = gender
end

function CashSearchModel:getItemTIndex(groupId)
	return groupId == 101 and 1 or 2
end

function CashSearchModel:search(keyword)
	self._keyword = keyword

	if not keyword or keyword == "" then
		return {}
	end

	local results = ClientCashShopUtils.searchCommodityByName(self._tabId, keyword)

	if self._displayGender then
		local filtered = {}

		for _, item in ipairs(results) do
			if ClientCashShopUtils.isItemMatchGender(item.itemId, self._displayGender) then
				filtered[#filtered + 1] = item
			end
		end

		results = filtered
	end

	if #results == 0 then
		return {}
	end

	local groups = {}
	local groupOrder = {}

	for _, item in ipairs(results) do
		local gid = item.tabGroupId

		if not groups[gid] then
			groups[gid] = {}
			groupOrder[#groupOrder + 1] = gid
		end

		groups[gid][#groups[gid] + 1] = item
	end

	table.sort(groupOrder, function(a, b)
		local cfgA = ShopmallTabGroupData[a]
		local cfgB = ShopmallTabGroupData[b]

		return (cfgA and cfgA.sort or 0) < (cfgB and cfgB.sort or 0)
	end)

	local COMMODITY_STATE = ClientCashShopUtils.COMMODITY_STATE
	local listData = {}

	for _, gid in ipairs(groupOrder) do
		local groupCfg = ShopmallTabGroupData[gid]
		local tabName = groupCfg and groupCfg.tabName or ""
		local groupItems = groups[gid]

		table.sort(groupItems, function(a, b)
			local sa = ClientCashShopUtils.getCommodityState(a)
			local sb = ClientCashShopUtils.getCommodityState(b)
			local aBack = sa == COMMODITY_STATE.POSSESS or sa == COMMODITY_STATE.SOLDOUT
			local bBack = sb == COMMODITY_STATE.POSSESS or sb == COMMODITY_STATE.SOLDOUT

			if aBack ~= bBack then
				return not aBack
			end

			return (a.sort or 0) < (b.sort or 0)
		end)

		local itemTIndex = self:getItemTIndex(gid)

		listData[#listData + 1] = {
			tIndex = 0,
			tabName = tabName
		}

		for _, item in ipairs(groupItems) do
			item.tIndex = itemTIndex
			listData[#listData + 1] = item
		end
	end

	return listData
end

function CashSearchModel:getKeyword()
	return self._keyword or ""
end

function CashSearchModel:getSearchHistoryList()
	local records = self:_loadHistory()

	table.sort(records, function(a, b)
		return a.timestamp > b.timestamp
	end)

	local listData = {}

	for _, r in ipairs(records) do
		listData[#listData + 1] = {
			tIndex = 3,
			keyword = r.keyword,
			timestamp = r.timestamp
		}
	end

	return listData
end

function CashSearchModel:addSearchHistory(keyword)
	if not keyword or keyword == "" then
		return
	end

	local records = self:_loadHistory()

	for i = #records, 1, -1 do
		if records[i].keyword == keyword then
			table.remove(records, i)
		end
	end

	table.insert(records, 1, {
		keyword = keyword,
		timestamp = os.time()
	})

	while #records > SEARCH_LIMIT do
		records[#records] = nil
	end

	self:_saveHistory(records)
end

function CashSearchModel:clearSearchHistory()
	self:_saveHistory({})
end

function CashSearchModel:_loadHistory()
	local raw = pg.game.setting:getString(STORAGE_KEY, "")

	if raw == "" then
		return {}
	end

	local records = {}

	for entry in string.gmatch(raw, "[^" .. SEPARATOR .. "]+") do
		local keyword, ts = string.match(entry, "^(.+)" .. FIELD_SEPARATOR .. "(%d+)$")

		if keyword and ts then
			records[#records + 1] = {
				keyword = keyword,
				timestamp = tonumber(ts)
			}
		end
	end

	return records
end

function CashSearchModel:_saveHistory(records)
	local parts = {}

	for _, r in ipairs(records) do
		parts[#parts + 1] = r.keyword .. FIELD_SEPARATOR .. tostring(r.timestamp)
	end

	pg.game.setting:setString(STORAGE_KEY, table.concat(parts, SEPARATOR))
end

return CashSearchModel
