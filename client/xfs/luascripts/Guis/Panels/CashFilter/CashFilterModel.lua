-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashFilter\\CashFilterModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ShopmallTabGroupData = require("Data.shopmall_tab_group_data")
local ShopmallFilterData = require("Data.shopmall_filter_data")
local ShopConstantData = require("Data.shopmall_constant_data")
local CashFilterModel = Class.LightClass("CashFilterModel", UIModel)

local function getConfigValue(data, key)
	if key == nil then
		return nil
	end

	return data[key] or data[tostring(key)]
end

local function normalizeFilterType(value)
	return tonumber(value) or value
end

local function getSequenceValue(list, index)
	if list == nil or index == nil then
		return nil
	end

	return list[index] or list[tostring(index)]
end

local function getSequenceEntries(list)
	local entries = {}

	if not list then
		return entries
	end

	for index, value in pairs(list) do
		local numericIndex = tonumber(index)

		if numericIndex then
			entries[#entries + 1] = {
				index = numericIndex,
				value = value
			}
		end
	end

	table.sort(entries, function(a, b)
		return a.index < b.index
	end)

	return entries
end

function CashFilterModel:setGroupId(groupId)
	self._groupId = groupId
	self._filterGroups = {}
	self._filterGroupMap = {}
	self._selections = {}
	self._sortKey = nil
	self._sortAscending = true

	local groupCfg = getConfigValue(ShopmallTabGroupData, groupId)

	if not groupCfg or not groupCfg.searchListId then
		return
	end

	for _, entry in ipairs(getSequenceEntries(groupCfg.searchListId)) do
		local filterId = entry.value
		local filterCfg = getConfigValue(ShopmallFilterData, filterId)

		if filterCfg then
			local group = {
				filterId = filterId,
				type = normalizeFilterType(filterCfg.type),
				name = filterCfg.name,
				list = filterCfg.list
			}

			self._filterGroups[#self._filterGroups + 1] = group
			self._filterGroupMap[filterId] = group
		end
	end
end

function CashFilterModel:buildListData()
	local listData = {}

	for _, group in ipairs(self._filterGroups) do
		local groupType = normalizeFilterType(group.type)

		listData[#listData + 1] = {
			tIndex = 0,
			name = group.name
		}

		if groupType == 1 then
			local options = {}

			for i, entry in ipairs(getSequenceEntries(group.list)) do
				local key = entry.value
				local constCfg = getConfigValue(ShopConstantData, key)

				options[i] = {
					text = constCfg and constCfg.number or key,
					key = key
				}
			end

			listData[#listData + 1] = {
				tIndex = 2,
				filterId = group.filterId,
				filterType = groupType,
				options = options
			}

			if not self._sortKey and #options > 0 then
				self._sortKey = options[1].key
			end
		else
			for i, itemEntry in ipairs(getSequenceEntries(group.list)) do
				local item = itemEntry.value
				local entry = {
					tIndex = 1,
					filterId = group.filterId,
					filterType = groupType,
					itemIndex = i
				}

				if groupType == 2 then
					entry.currencyId = item[1] or item["1"]
					entry.amount = item[2] or item["2"]
				else
					local constCfg = getConfigValue(ShopConstantData, item)

					entry.key = item
					entry.text = constCfg and constCfg.number or tostring(item)
				end

				listData[#listData + 1] = entry
			end
		end
	end

	return listData
end

function CashFilterModel:setSortKey(key)
	self._sortKey = key
end

function CashFilterModel:toggleSortOrder()
	self._sortAscending = not self._sortAscending
end

function CashFilterModel:setSortAscending(value)
	self._sortAscending = value
end

function CashFilterModel:isSortAscending()
	return self._sortAscending
end

local function buildSelectionMap(indices)
	if not indices then
		return nil
	end

	local selections = {}

	for _, index in ipairs(indices) do
		local numericIndex = tonumber(index) or index

		selections[numericIndex] = true
	end

	return next(selections) and selections or nil
end

local function getSortedSelectedIndices(selections)
	if not selections then
		return nil
	end

	local indices = {}

	for index, selected in pairs(selections) do
		if selected then
			indices[#indices + 1] = tonumber(index) or index
		end
	end

	table.sort(indices)

	return #indices > 0 and indices or nil
end

function CashFilterModel:setFilterSelections(filterId, indices)
	self._selections[filterId] = buildSelectionMap(indices)
end

function CashFilterModel:getFilterSelections(filterId)
	return getSortedSelectedIndices(self._selections[filterId])
end

function CashFilterModel:isFilterItemSelected(filterId, index)
	local selections = self._selections[filterId]

	return selections ~= nil and selections[index] == true
end

function CashFilterModel:toggleFilterSelection(filterId, index)
	local group = self._filterGroupMap and self._filterGroupMap[filterId]

	if not group or normalizeFilterType(group.type) == 1 then
		return
	end

	local selections = self._selections[filterId] or {}

	if selections[index] then
		selections[index] = nil
	else
		local key = getSequenceValue(group.list, index)

		if key == "search_all" then
			selections = {
				[index] = true
			}
		else
			selections[index] = true

			if group.list then
				for _, itemEntry in ipairs(getSequenceEntries(group.list)) do
					local i = itemEntry.index
					local item = itemEntry.value

					if item == "search_all" then
						selections[i] = nil
					end
				end
			end
		end
	end

	self._selections[filterId] = next(selections) and selections or nil
end

function CashFilterModel:restoreState(state)
	if not state then
		return
	end

	if state.sortKey then
		self._sortKey = state.sortKey
	end

	if state.sortAscending ~= nil then
		self._sortAscending = state.sortAscending
	end

	if state.filters then
		for _, filter in ipairs(state.filters) do
			if filter.filterId then
				if filter.selectedIndices then
					self:setFilterSelections(filter.filterId, filter.selectedIndices)
				elseif filter.selectedIndex then
					self:setFilterSelections(filter.filterId, {
						filter.selectedIndex
					})
				else
					self._selections[filter.filterId] = nil
				end
			end
		end
	end
end

function CashFilterModel:getSortKeyIndex()
	for _, group in ipairs(self._filterGroups) do
		if normalizeFilterType(group.type) == 1 then
			for i, entry in ipairs(getSequenceEntries(group.list)) do
				local key = entry.value

				if key == self._sortKey then
					return i - 1
				end
			end
		end
	end

	return 0
end

function CashFilterModel:resetSelections()
	self._sortAscending = true
	self._sortKey = nil
	self._selections = {}

	for _, group in ipairs(self._filterGroups) do
		if normalizeFilterType(group.type) == 1 then
			local firstEntry = getSequenceEntries(group.list)[1]

			if firstEntry then
				self._sortKey = firstEntry.value
			end
		end
	end
end

function CashFilterModel:isFiltering()
	for _, group in ipairs(self._filterGroups) do
		local groupType = normalizeFilterType(group.type)

		if groupType == 1 then
			local firstEntry = getSequenceEntries(group.list)[1]
			local defaultSortKey = firstEntry and firstEntry.value or nil

			if self._sortKey ~= defaultSortKey or not self._sortAscending then
				return true
			end
		else
			local selectedIndices = self:getFilterSelections(group.filterId)

			if groupType == 2 then
				if selectedIndices then
					return true
				end
			elseif selectedIndices then
				for _, index in ipairs(selectedIndices) do
					if getSequenceValue(group.list, index) ~= "search_all" then
						return true
					end
				end
			end
		end
	end

	return false
end

function CashFilterModel:getFilterState()
	local state = {
		sortKey = self._sortKey,
		sortAscending = self._sortAscending,
		filters = {}
	}

	for _, group in ipairs(self._filterGroups) do
		local groupType = normalizeFilterType(group.type)

		if groupType ~= 1 then
			local selectedIndices = self:getFilterSelections(group.filterId)
			local selectedItems

			if selectedIndices then
				selectedItems = {}

				for _, index in ipairs(selectedIndices) do
					selectedItems[#selectedItems + 1] = getSequenceValue(group.list, index)
				end
			end

			state.filters[#state.filters + 1] = {
				filterId = group.filterId,
				type = groupType,
				selectedIndex = selectedIndices and selectedIndices[1] or nil,
				selectedItem = selectedItems and selectedItems[1] or nil,
				selectedIndices = selectedIndices,
				selectedItems = selectedItems
			}
		end
	end

	return state
end

return CashFilterModel
