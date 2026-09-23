-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CreatePlayer\\CreatePlayerModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local CreatePlayerModel = Class.LightClass("CreatePlayerModel", UIModel)
local PlayerTagData = require("Data.player_tag_data")
local PlayerRandomNameData = require("Data.player_random_name_data")
local SysConfigData = require("Data.sys_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")

function CreatePlayerModel:ctor()
	self.tagList = {}
end

function CreatePlayerModel:getTagList()
	table.clear(self.tagList)

	for id, v in pairs(PlayerTagData) do
		self.tagList[#self.tagList + 1] = {
			select = false,
			id = id,
			name = pg.getLocalizationText(v.text)
		}
	end

	return self.tagList
end

function CreatePlayerModel:setTagSelected(id, select)
	local max = SysConfigData.playerTagsMaxCount

	if select then
		local cur = 0
		local containInSelect = false

		for _, v in ipairs(self.tagList) do
			if v.select then
				cur = cur + 1

				if v.id == id then
					containInSelect = true
				end
			end
		end

		if max <= cur and not containInSelect then
			return false
		end
	end

	for _, v in ipairs(self.tagList) do
		if v.id == id then
			v.select = select
		end
	end

	return true
end

function CreatePlayerModel:getSelectedAndMaxNum()
	local num = 0

	for _, v in ipairs(self.tagList) do
		if v.select then
			num = num + 1
		end
	end

	return num, SysConfigData.playerTagsMaxCount
end

function CreatePlayerModel:getSelectedTags()
	local res = {}

	for _, v in ipairs(self.tagList) do
		if v.select then
			res[#res + 1] = v.id
		end
	end

	return res
end

function CreatePlayerModel:checkTagNumValid()
	local num = 0

	for _, v in ipairs(self.tagList) do
		if v.select then
			num = num + 1
		end
	end

	return num >= SysConfigData.playerTagsMaxCount
end

function CreatePlayerModel:getSelectedTagsInNamePage()
	local res = {}

	for _, v in ipairs(self.tagList) do
		if v.select then
			local cData = PlayerTagData[v.id]

			if cData then
				res[#res + 1] = {
					id = v.id,
					name = pg.getLocalizationText(cData.text)
				}
			end
		end
	end

	return res
end

function CreatePlayerModel:getRandomName()
	local max = #PlayerRandomNameData
	local part1 = math.random(1, max)
	local part2 = math.random(1, max)
	local name = ""
	local cPart = PlayerRandomNameData[part1]

	if cPart then
		name = pg.getLocalizationText(cPart.part1, true)
	end

	cPart = PlayerRandomNameData[part2]

	if cPart then
		name = ClientTextUtils.concatByLanguage(name, pg.getLocalizationText(cPart.part2, true))
	end

	return name
end

function CreatePlayerModel:getValidName(name)
	if string.isNilOrEmpty(name) then
		return name
	end

	name = ClientTextUtils.getValidName(name, SysConfigData.playerNameMaxLen)

	return name
end

return CreatePlayerModel
