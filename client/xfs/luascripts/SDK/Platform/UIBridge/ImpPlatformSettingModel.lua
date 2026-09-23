-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformSettingModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local M = {}
local PLATFORM_KEEP_VIDEO_FUNC_TYPE = {
	"preset",
	"puppetCountLimit",
	"petCountLimit",
	"playerCountLimit",
	"envObjCountLimit"
}
local PLATFORM_KEEP_VIDEO_FUNC_TYPE_SET = {}

for _, funcType in ipairs(PLATFORM_KEEP_VIDEO_FUNC_TYPE) do
	PLATFORM_KEEP_VIDEO_FUNC_TYPE_SET[funcType] = true
end

local PS5_KEEP_VIDEO_FUNC_TYPE_SET = PLATFORM_KEEP_VIDEO_FUNC_TYPE_SET
local PS_HIDE_FUNC_TYPE_SET = {}

function M.isHiddenOnPS(settingItem)
	local funcType = settingItem and settingItem.info and settingItem.info.funcType

	return PS_HIDE_FUNC_TYPE_SET[funcType] == true
end

function M:handlePlatformSettingData(settingData)
	if not settingData then
		return settingData
	end

	local keepVideoFuncTypeSet
	local isPS = pg.global.platform:isPS()

	if pg.global.platform:isXbox() then
		keepVideoFuncTypeSet = PLATFORM_KEEP_VIDEO_FUNC_TYPE_SET
	elseif isPS then
		keepVideoFuncTypeSet = PS5_KEEP_VIDEO_FUNC_TYPE_SET
	else
		return
	end

	local result = {}

	for _, tabData in ipairs(settingData) do
		if isPS and tabData.tab == "account" then
			local keptItems = {}

			for _, cate in ipairs(tabData.items or EMPTY_TABLE) do
				local keptList = {}

				for _, settingItem in ipairs(cate.settingList or EMPTY_TABLE) do
					if not M.isHiddenOnPS(settingItem) then
						keptList[#keptList + 1] = settingItem
					end
				end

				if #keptList > 0 then
					local keptCate = {}

					for k, v in pairs(cate) do
						keptCate[k] = v
					end

					keptCate.settingList = keptList
					keptItems[#keptItems + 1] = keptCate
				end
			end

			if #keptItems > 0 then
				local keptTab = {}

				for k, v in pairs(tabData) do
					keptTab[k] = v
				end

				keptTab.items = keptItems
				result[#result + 1] = keptTab
			end
		elseif tabData.tab ~= "video" then
			result[#result + 1] = tabData
		else
			local keptItems = {}

			for _, cate in ipairs(tabData.items or EMPTY_TABLE) do
				local keptList = {}

				for _, settingItem in ipairs(cate.settingList or EMPTY_TABLE) do
					local funcType = settingItem.info and settingItem.info.funcType

					if keepVideoFuncTypeSet[funcType] then
						keptList[#keptList + 1] = settingItem
					end
				end

				if #keptList > 0 then
					local keptCate = {}

					for k, v in pairs(cate) do
						keptCate[k] = v
					end

					keptCate.settingList = keptList
					keptItems[#keptItems + 1] = keptCate
				end
			end

			if #keptItems > 0 then
				local keptTab = {}

				for k, v in pairs(tabData) do
					keptTab[k] = v
				end

				keptTab.items = keptItems
				result[#result + 1] = keptTab
			end
		end
	end

	return result
end

return M
