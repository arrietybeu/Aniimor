-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Knowledge\\KnowledgeManager.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("KnowledgeManager")
local ItemData = require("Data.item_data")
local ItemViewerData = require("Data.item_viewer_data")
local ItemEffectData = require("Data.item_effect_data")
local EventData = require("Data.sys_event_data")
local StringData = require("Data.gamestring_config_data")
local PiecesItemSpecialData = require("Data.pieces_item_special_data")
local KnowledgeTotalData = require("Data.knowledge_total_data")
local KnowledgeAssetsData = require("Data.knowledge_assets_data")
local KnowledgeIndexData = require("Data.knowledge_index_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local Utils = require("Common.Utils.Utils")
local KnowledgeData = require("GameApp.Knowledge.KnowledgeData")
local Class = require("Core.Framework.Class")
local KnowledgeManager = Class.LightClass("KnowledgeManager")
local instance
local SHOW_CONTENT_KEY = "showContent"
local MAX_READ_KNOWLEDGE_COUNT = 128
local KNOWLEDGE_CATEGORY = {
	HERO = 6,
	AUDIO = 5,
	VIDEO = 4,
	COLLECTION = 3,
	DRAWING = 2,
	BOOKS = 1
}

function KnowledgeManager:initAllData()
	local player = pg.me
	local unlockedKnowledgeMap = player and player.unlockedKnowledgeMap or {}

	self.unlockedKnowledgeIds = {}
	self.unlockedKnowledgeSet = {}
	self.readKnowledgeSet = {}
	self.pendingReadKnowledgeSet = self.pendingReadKnowledgeSet or {}
	self.knowledgeDataDict = {}
	self.knowledgeLocationMap = {}
	self.newKnowledgeCount = 0

	for knowledgeId, isRead in pairs(unlockedKnowledgeMap) do
		knowledgeId = tonumber(knowledgeId)

		if knowledgeId ~= nil then
			table.insert(self.unlockedKnowledgeIds, knowledgeId)

			self.unlockedKnowledgeSet[knowledgeId] = true

			if isRead then
				self.readKnowledgeSet[knowledgeId] = true
				self.pendingReadKnowledgeSet[knowledgeId] = nil
			end
		end
	end

	table.sort(self.unlockedKnowledgeIds)
	self:initKnowledgeData()

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("Server synchronize unlocked knowledge total-count = %d ", #self.unlockedKnowledgeIds)
		logger:info("Client initialize Knowledge Data completed, unlocked knowledge total-count: %d, new knowledge count: %d ", table.nums(self.knowledgeLocationMap), self.newKnowledgeCount)
	end
end

function KnowledgeManager.getInstance()
	if instance == nil then
		instance = KnowledgeManager.new()
	end

	return instance
end

function KnowledgeManager:acquireUIData(owner)
	self.knowledgeUIOwners = self.knowledgeUIOwners or {}

	if self.knowledgeUIOwners[owner] then
		return
	end

	local isFirstOwner = next(self.knowledgeUIOwners) == nil

	self.knowledgeUIOwners[owner] = true

	if isFirstOwner and not self:isInitialized() then
		self:initAllData()
	end
end

function KnowledgeManager:releaseUIData(owner)
	if self.knowledgeUIOwners == nil or not self.knowledgeUIOwners[owner] then
		return
	end

	self.knowledgeUIOwners[owner] = nil

	if next(self.knowledgeUIOwners) == nil then
		self:clearAllData()
	end
end

function KnowledgeManager:ensureInitialized()
	if self.knowledgeDataDict == nil then
		self:initAllData()
	end
end

function KnowledgeManager:isInitialized()
	return self.knowledgeDataDict ~= nil
end

function KnowledgeManager:getMainTypeData(mainTypeId)
	self:ensureInitialized()

	return self.knowledgeDataDict[mainTypeId]
end

function KnowledgeManager:clearAllData()
	self.unlockedKnowledgeIds = nil
	self.unlockedKnowledgeSet = nil
	self.readKnowledgeSet = nil
	self.pendingReadKnowledgeSet = nil
	self.knowledgeDataDict = nil
	self.knowledgeLocationMap = nil
	self.newKnowledgeCount = nil
	self.knowledgeUIOwners = nil
end

function KnowledgeManager:getKnowledgeLocation(knowledgeId)
	self:ensureInitialized()

	return self.knowledgeLocationMap[tonumber(knowledgeId)]
end

function KnowledgeManager:isKnowledgeIdNew(knowledgeId)
	return self.unlockedKnowledgeSet[knowledgeId] == true and self.readKnowledgeSet[knowledgeId] ~= true and self.pendingReadKnowledgeSet[knowledgeId] ~= true
end

function KnowledgeManager:isMainTypeNew(mainTypeData)
	return self:getMainTypeNewKnowledgeCount(mainTypeData) > 0
end

function KnowledgeManager:getMainTypeNewKnowledgeCount(mainTypeData)
	self:ensureInitialized()

	local count = 0

	for knowledgeId in pairs(mainTypeData._knowledgeIdSet) do
		if self:isKnowledgeIdNew(knowledgeId) then
			count = count + 1
		end
	end

	return count
end

function KnowledgeManager:isSubTypeNew(subTypeData)
	self:ensureInitialized()

	for _, catalogData in pairs(subTypeData.dataDict) do
		for _, knowledgeItemData in ipairs(catalogData.dataList) do
			if self:isKnowledgeIdNew(knowledgeItemData.knowledgeId) then
				return true
			end
		end
	end

	return false
end

function KnowledgeManager:isCatalogNew(catalogData)
	return self:getCatalogNewKnowledgeCount(catalogData) > 0
end

function KnowledgeManager:getCatalogNewKnowledgeCount(catalogData)
	self:ensureInitialized()

	local count = 0

	for _, knowledgeItemData in ipairs(catalogData.dataList) do
		if self:isKnowledgeIdNew(knowledgeItemData.knowledgeId) then
			count = count + 1
		end
	end

	return count
end

function KnowledgeManager:isKnowledgeItemNew(knowledgeItemData)
	self:ensureInitialized()

	return self:isKnowledgeIdNew(knowledgeItemData.knowledgeId)
end

function KnowledgeManager:markKnowledgeItemSeen(knowledgeItemData)
	self:readKnowledgeIds({
		knowledgeItemData.knowledgeId
	})
end

function KnowledgeManager:markCatalogKnowledgeSeen(catalogData)
	local knowledgeIds = {}

	self:appendCatalogKnowledgeIds(catalogData, knowledgeIds)
	self:readKnowledgeIds(knowledgeIds)
end

function KnowledgeManager:updateKnowledgeReadState(knowledgeId, isRead)
	if not self:isInitialized() then
		return
	end

	knowledgeId = tonumber(knowledgeId)

	if knowledgeId == nil or self.unlockedKnowledgeSet[knowledgeId] ~= true then
		return
	end

	local wasNew = self:isKnowledgeIdNew(knowledgeId)

	if isRead then
		self.readKnowledgeSet[knowledgeId] = true
	else
		self.readKnowledgeSet[knowledgeId] = nil
	end

	self.pendingReadKnowledgeSet[knowledgeId] = nil

	local isNew = self:isKnowledgeIdNew(knowledgeId)

	if self.knowledgeLocationMap[knowledgeId] ~= nil and wasNew ~= isNew then
		self.newKnowledgeCount = math.max(self.newKnowledgeCount + (isNew and 1 or -1), 0)
	end
end

function KnowledgeManager:markMainTypeKnowledgeSeen(mainTypeData)
	local knowledgeIds = {}

	for knowledgeId in pairs(mainTypeData._knowledgeIdSet) do
		table.insert(knowledgeIds, knowledgeId)
	end

	self:readKnowledgeIds(knowledgeIds)
end

function KnowledgeManager:appendCatalogKnowledgeIds(catalogData, knowledgeIds)
	for _, knowledgeItemData in ipairs(catalogData.dataList) do
		table.insert(knowledgeIds, knowledgeItemData.knowledgeId)
	end
end

function KnowledgeManager:readKnowledgeIds(knowledgeIds)
	self:ensureInitialized()

	local unreadKnowledgeIds = {}

	for _, knowledgeId in ipairs(knowledgeIds) do
		if self:isKnowledgeIdNew(knowledgeId) then
			self.pendingReadKnowledgeSet[knowledgeId] = true

			if self.knowledgeLocationMap[knowledgeId] ~= nil then
				self.newKnowledgeCount = math.max(self.newKnowledgeCount - 1, 0)
			end

			table.insert(unreadKnowledgeIds, knowledgeId)

			if #unreadKnowledgeIds == MAX_READ_KNOWLEDGE_COUNT then
				pg.me:serverMsg("RPC_CS_ReadKnowledge", unreadKnowledgeIds)

				unreadKnowledgeIds = {}
			end
		end
	end

	if #unreadKnowledgeIds > 0 then
		pg.me:serverMsg("RPC_CS_ReadKnowledge", unreadKnowledgeIds)
	end
end

function KnowledgeManager:getCategoryName(type)
	if type == KNOWLEDGE_CATEGORY.BOOKS then
		return pg.getGameString(StringData.KNOWLEDGE_ENTER_BOOK.desc)
	elseif type == KNOWLEDGE_CATEGORY.COLLECTION then
		return pg.getGameString(StringData.KNOWLEDGE_ENTER_ITEM.desc)
	elseif type == KNOWLEDGE_CATEGORY.DRAWING then
		return pg.getGameString(StringData.KNOWLEDGE_ENTER_PIC.desc)
	elseif type == KNOWLEDGE_CATEGORY.VIDEO then
		return "影像"
	elseif type == KNOWLEDGE_CATEGORY.AUDIO then
		return "音频"
	elseif type == KNOWLEDGE_CATEGORY.HERO then
		return "英杰"
	end
end

function KnowledgeManager:initKnowledgeData()
	for mainTypeId = KNOWLEDGE_CATEGORY.BOOKS, KNOWLEDGE_CATEGORY.HERO do
		self:initMainTypeData(mainTypeId, KnowledgeTotalData[mainTypeId])
	end
end

function KnowledgeManager:initMainTypeData(mainTypeId, mainTypeConfig)
	mainTypeConfig = mainTypeConfig or {}

	local mainTypeData = KnowledgeData.KnowledgeMainTypeData.new(self:getCategoryName(mainTypeId), mainTypeConfig.maxNum)

	self.knowledgeDataDict[mainTypeId] = mainTypeData

	local categoryList = {}

	for subTypeId, subTypeConfig in pairs(mainTypeConfig) do
		if type(subTypeId) == "number" then
			table.insert(categoryList, {
				subTypeId = subTypeId,
				config = subTypeConfig
			})
		end
	end

	table.sort(categoryList, function(a, b)
		local aSort = a.config.sort or 0
		local bSort = b.config.sort or 0

		if aSort == bSort then
			return a.subTypeId < b.subTypeId
		end

		return aSort < bSort
	end)

	for _, categoryInfo in ipairs(categoryList) do
		local subTypeId = categoryInfo.subTypeId
		local subTypeConfig = categoryInfo.config
		local categoryTitle = subTypeConfig.subTypeName

		for listId, catalogConfig in pairs(subTypeConfig) do
			if type(listId) == "number" then
				local catalogTitle = catalogConfig.name

				for knowledgeId, itemConfig in pairs(catalogConfig) do
					if type(knowledgeId) == "number" and self.unlockedKnowledgeSet[knowledgeId] then
						local data = self:getKnowledgeData(knowledgeId, itemConfig)

						if data ~= nil then
							local knowledgeItemData = KnowledgeData.KnowledgeItemData.new(itemConfig.pageId or 0, knowledgeId, data)

							mainTypeData:updateValue(subTypeId, categoryTitle, subTypeConfig.sort, listId, catalogTitle, knowledgeItemData)
						end
					end
				end

				local subTypeData = mainTypeData.dataDict[subTypeId]
				local catalogData = subTypeData and subTypeData.dataDict[listId]

				if catalogData ~= nil then
					for pageIndex, knowledgeItemData in ipairs(catalogData.dataList) do
						local itemKnowledgeId = knowledgeItemData.knowledgeId

						if self.knowledgeLocationMap[itemKnowledgeId] == nil then
							self.knowledgeLocationMap[itemKnowledgeId] = {
								mainTypeId = mainTypeId,
								subTypeId = subTypeId,
								listId = listId,
								pageIndex = pageIndex,
								mainTypeData = mainTypeData,
								subTypeData = subTypeData,
								catalogData = catalogData,
								knowledgeItemData = knowledgeItemData
							}

							if mainTypeData.maxNum ~= 0 and self:isKnowledgeIdNew(itemKnowledgeId) then
								self.newKnowledgeCount = self.newKnowledgeCount + 1
							end
						end
					end
				end
			end
		end
	end
end

function KnowledgeManager:getKnowledgeData(knowledgeId, totalItemConfig)
	local indexCfg = KnowledgeIndexData[knowledgeId]

	if indexCfg == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("KnowledgeIndexData is missing, knowledgeId: %d", knowledgeId)
		end

		return nil
	end

	local sourceId = indexCfg.id
	local sourceType = indexCfg.type
	local matchedKnowledgeId, data

	if sourceType == 1 then
		matchedKnowledgeId, data = self:getItemKnowledge(sourceId, totalItemConfig)
	elseif sourceType == 2 then
		matchedKnowledgeId, data = self:getViewableKnowledge(sourceId)
	elseif sourceType == 3 then
		matchedKnowledgeId, data = self:getPiecesItemSpecialData(sourceId)
	elseif sourceType == 4 then
		data = KnowledgeAssetsData[knowledgeId]

		if data == nil and LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("KnowledgeAssetsData is missing, knowledgeId: %d", knowledgeId)
		end

		return self:normalizeKnowledgeData(data, data and data.title, data and data.desc, data and data.resLink)
	else
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Unsupported knowledge index type, knowledgeId: %d, type: %s", knowledgeId, tostring(sourceType))
		end

		return nil
	end

	if matchedKnowledgeId ~= knowledgeId then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Knowledge mapping mismatch, knowledgeId: %d, sourceId: %s, matchedKnowledgeId: %s", knowledgeId, tostring(sourceId), tostring(matchedKnowledgeId))
		end

		return nil
	end

	return data
end

function KnowledgeManager:normalizeKnowledgeData(config, title, desc, icon)
	if config == nil then
		return nil
	end

	local data = Utils.deepCopyTable(config)

	data.title = title or ""
	data.desc = desc or ""
	data.icon = icon or ""

	return data
end

function KnowledgeManager:normalizeImageUrl(resource)
	if resource == nil or resource == "" then
		return ""
	end

	if string.sub(resource, 1, 1) == "$" then
		return resource
	end

	return "$" .. resource
end

function KnowledgeManager:getViewableKnowledge(id)
	local config = ItemViewerData[id]

	if config == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("ItemViewerData is missing, id: %s", tostring(id))
		end

		return nil
	end

	local knowledgeConnect = config.knowledgeConnect

	if knowledgeConnect == nil or knowledgeConnect[1] == nil or knowledgeConnect[2] == nil or knowledgeConnect[3] ~= nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Invalid ItemViewerData.knowledgeConnect, id: %s", tostring(id))
		end

		return nil
	end

	local knowledgeId = knowledgeConnect[1] or 0
	local contentType = knowledgeConnect[2] or 0

	if contentType == KNOWLEDGE_CATEGORY.BOOKS then
		return knowledgeId, self:normalizeKnowledgeData(config, config.title, config.text, nil)
	elseif contentType == KNOWLEDGE_CATEGORY.DRAWING then
		if config.pictureFront == nil and LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("ItemViewerData.pictureFront is missing, id: %s, resType: %s, contentRes: %s", tostring(id), tostring(config.resType), tostring(config.contentRes))
		end

		return knowledgeId, self:normalizeKnowledgeData(config, config.title, config.desc, self:normalizeImageUrl(config.pictureFront))
	end

	if LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("Unsupported ItemViewerData knowledge display type, id: %s, type: %s", tostring(id), tostring(contentType))
	end

	return nil
end

function KnowledgeManager:getPiecesItemSpecialData(id)
	local config = PiecesItemSpecialData[id]

	if config == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("PiecesItemSpecialData is missing, id: %s", tostring(id))
		end

		return nil
	end

	local knowledgeConnect = config.knowledgeConnect

	if knowledgeConnect == nil or knowledgeConnect[1] == nil or knowledgeConnect[2] == nil or knowledgeConnect[3] ~= nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Invalid PiecesItemSpecialData.knowledgeConnect, id: %s", tostring(id))
		end

		return nil
	end

	local knowledgeId = knowledgeConnect[1] or 0
	local contentType = knowledgeConnect[2] or 0

	if contentType ~= KNOWLEDGE_CATEGORY.BOOKS then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Unsupported PiecesItemSpecialData knowledge display type, id: %s, type: %s", tostring(id), tostring(contentType))
		end

		return nil
	end

	return knowledgeId, self:normalizeKnowledgeData(config, config.name, config.content, nil)
end

function KnowledgeManager:getItemKnowledge(itemId, totalItemConfig)
	local itemData = ItemData[itemId]

	if itemData == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("ItemData is missing, itemId: %s", tostring(itemId))
		end

		return nil
	end

	local knowledgeConnect = itemData.knowledgeConnect
	local knowledgeConnectType = type(knowledgeConnect)

	if knowledgeConnect == nil or knowledgeConnectType ~= "table" and knowledgeConnectType ~= "userdata" or knowledgeConnect[1] == nil or knowledgeConnect[3] ~= nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Invalid ItemData.knowledgeConnect, itemId: %s", tostring(itemId))
		end

		return nil
	end

	local knowledgeId = knowledgeConnect[1]
	local sourceType = knowledgeConnect[2]
	local itemEffectData = ItemEffectData[itemId]
	local ownedItems = ItemUtils.getItemsById(pg.me, itemId)
	local canView = (itemData.invId == 5 or itemData.invId == 14) and itemEffectData ~= nil and itemEffectData.reuseTimes == -1 and ownedItems ~= nil and ownedItems[1] ~= nil

	if sourceType == nil then
		return knowledgeId, {
			itemId = itemId,
			title = itemData.itemName,
			desc = totalItemConfig and totalItemConfig.desc or "",
			icon = itemData.icon,
			canView = canView
		}
	elseif sourceType == 1 then
		return knowledgeId, {
			itemId = itemId,
			title = itemData.itemName,
			desc = itemData.itemDes,
			icon = itemData.icon,
			canView = canView
		}
	elseif sourceType == 2 then
		local showIPContent = itemData.showIPContent or itemId
		local piecesItemSpecialData = PiecesItemSpecialData[showIPContent]

		if piecesItemSpecialData == nil then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("PiecesItemSpecialData is missing for item, itemId: %d", itemId)
			end

			return nil
		end

		return knowledgeId, {
			itemId = itemId,
			title = itemData.itemName,
			desc = piecesItemSpecialData.content,
			icon = itemData.icon,
			canView = canView
		}
	elseif sourceType == 3 then
		local itemEffectData = ItemEffectData[itemId]

		if itemEffectData ~= nil then
			local eventId = itemEffectData.eventId or 0
			local eventData = EventData[eventId]

			if eventData ~= nil and eventData.eventType == SHOW_CONTENT_KEY then
				local eventParam = eventData.eventParam or {}
				local contentId = eventParam[1] or 0
				local viewData = ItemViewerData[contentId]

				if viewData ~= nil then
					return knowledgeId, {
						canView = false,
						itemId = itemId,
						title = itemData.itemName,
						desc = viewData.text or viewData.desc,
						icon = itemData.icon
					}
				end
			end
		end

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Failed to resolve show-content data for item, itemId: %d", itemId)
		end

		return nil
	else
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Unsupported ItemData knowledge type, itemId: %d, type: %d", itemId, sourceType)
		end

		return nil
	end
end

return KnowledgeManager
