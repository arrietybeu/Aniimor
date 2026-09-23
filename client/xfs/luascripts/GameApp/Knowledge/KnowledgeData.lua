-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Knowledge\\KnowledgeData.lua

local KnowledgeData = {}
local KnowledgeItemData = {}

KnowledgeItemData.__index = KnowledgeItemData

function KnowledgeItemData.new(pageId, knowledgeId, data)
	return setmetatable({
		pageId = pageId,
		knowledgeId = knowledgeId,
		data = data
	}, KnowledgeItemData)
end

local KnowledgeCatalogData = {}

KnowledgeCatalogData.__index = KnowledgeCatalogData

function KnowledgeCatalogData.new(title)
	return setmetatable({
		title = title or "",
		dataList = {}
	}, KnowledgeCatalogData)
end

function KnowledgeCatalogData:updateValue(knowledgeItemData)
	local isUpdated = false

	for index, knowledgeItem in ipairs(self.dataList) do
		if knowledgeItem.knowledgeId == knowledgeItemData.knowledgeId then
			self.dataList[index] = knowledgeItemData
			isUpdated = true

			break
		end
	end

	if not isUpdated then
		table.insert(self.dataList, knowledgeItemData)
	end

	table.sort(self.dataList, function(a, b)
		if a.pageId == b.pageId then
			return a.knowledgeId < b.knowledgeId
		end

		return a.pageId < b.pageId
	end)
end

local KnowledgeSubTypeData = {}

KnowledgeSubTypeData.__index = KnowledgeSubTypeData

function KnowledgeSubTypeData.new(title, sort)
	return setmetatable({
		title = title or "",
		sort = sort or 0,
		dataDict = {}
	}, KnowledgeSubTypeData)
end

function KnowledgeSubTypeData:updateValue(listId, catalogTitle, knowledgeItemData)
	local catalog = self.dataDict[listId]

	if catalog == nil then
		catalog = KnowledgeCatalogData.new(catalogTitle)
		self.dataDict[listId] = catalog
	elseif catalogTitle ~= nil then
		catalog.title = catalogTitle
	end

	catalog:updateValue(knowledgeItemData)
end

local KnowledgeMainTypeData = {}

KnowledgeMainTypeData.__index = KnowledgeMainTypeData

function KnowledgeMainTypeData.new(title, maxNum)
	return setmetatable({
		num = 0,
		title = title or "",
		maxNum = maxNum or 0,
		dataDict = {},
		_knowledgeIdSet = {}
	}, KnowledgeMainTypeData)
end

function KnowledgeMainTypeData:updateValue(categoryId, categoryTitle, categorySort, listId, catalogTitle, knowledgeItemData)
	if not self._knowledgeIdSet[knowledgeItemData.knowledgeId] then
		self._knowledgeIdSet[knowledgeItemData.knowledgeId] = true
		self.num = self.num + 1
	end

	local category = self.dataDict[categoryId]

	if category == nil then
		category = KnowledgeSubTypeData.new(categoryTitle, categorySort)
		self.dataDict[categoryId] = category
	else
		category.title = categoryTitle
		category.sort = categorySort
	end

	category:updateValue(listId, catalogTitle, knowledgeItemData)
end

KnowledgeData.KnowledgeMainTypeData = KnowledgeMainTypeData
KnowledgeData.KnowledgeSubTypeData = KnowledgeSubTypeData
KnowledgeData.KnowledgeCatalogData = KnowledgeCatalogData
KnowledgeData.KnowledgeItemData = KnowledgeItemData

return KnowledgeData
