-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CreatePlayerRename\\CreatePlayerRenameModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("CreatePlayerRenameModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local CreatePlayerRenameModel = Class.LightClass("CreatePlayerRenameModel", UIModel)
local PlayerRandomNameData = require("Data.player_random_name_data")
local SysConfigData = require("Data.sys_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")

function CreatePlayerRenameModel:getRandomName()
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

function CreatePlayerRenameModel:getValidName(name)
	if string.isNilOrEmpty(name) then
		return name
	end

	name = ClientTextUtils.getValidName(name, SysConfigData.playerNameMaxLen)

	return name
end

return CreatePlayerRenameModel
