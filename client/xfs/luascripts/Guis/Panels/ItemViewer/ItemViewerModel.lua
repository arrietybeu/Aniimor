-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ItemViewer\\ItemViewerModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ItemViewerData = require("Data.item_viewer_data")
local ItemViewerModel = Class.LightClass("ItemViewerModel", UIModel)

ItemViewerModel.VIEWER_MODE = {
	MODE3 = 2,
	MODE2 = 1,
	MODE1 = 0,
	MODE5 = 4,
	MODE4 = 3
}

function ItemViewerModel:parseItemDataList(idList)
	local res = {}

	for _, id in ipairs(idList) do
		local item = self:parseItemInfoInternal(id)

		if item then
			item.index = #res + 1
			res[item.index] = item
		end
	end

	return res
end

function ItemViewerModel:parseItemInfoInternal(id)
	local cData = ItemViewerData[id]

	if cData == nil then
		return nil
	end

	local res = {}

	res.modelResId = cData.modelRes
	res.modelScale = cData.modelScale
	res.modelRotationInit = cData.modelRotationInit
	res.rotationXLimit = cData.rotationXLimit
	res.rotationYLimit = cData.rotationYLimit
	res.rotationZLimit = cData.rotationZLimit
	res.pictureFront = cData.pictureFront
	res.pictureBack = cData.pictureBack
	res.pictureRotationInit = cData.pictureRotationInit
	res.showPagePoint = cData.showPagePoint or 0
	res.useExitInPrefab = cData.useExitInPrefab or 0
	res.contentResId = cData.contentRes
	res.title = pg.getLocalizationText(cData.title)
	res.content = pg.getLocalizationText(cData.text)
	res.tip = pg.getLocalizationText(cData.desc)
	res.mode5Title = pg.getLocalizationText(cData.heading)
	res.mode5Name = pg.getLocalizationText(cData.writer)
	res.mode5Date = pg.getLocalizationText(cData.res)
	res.mode5Imgs = cData.pictureList
	res.mode5ImgInfo = pg.getLocalizationText(cData.picDesc)
	res.mode5TxtContent = pg.getLocalizationText(cData.article)

	if cData.resType == 1 then
		res.mode = self.VIEWER_MODE.MODE1
	elseif cData.resType == 2 then
		res.mode = self.VIEWER_MODE.MODE2
	elseif cData.resType == 3 then
		res.mode = self.VIEWER_MODE.MODE3
	elseif cData.resType == 4 then
		res.mode = self.VIEWER_MODE.MODE4
	elseif cData.resType == 5 then
		res.mode = self.VIEWER_MODE.MODE5
	end

	return res
end

return ItemViewerModel
