-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandFurnitureDesign\\HomelandFurnitureDesignCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandFurnitureDesignCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local HomeBlueprintConst = require("Common.Const.HomeBlueprintConst")
local HomelandConfigData = require("Data.homeland_config_data")
local HomelandFurnitureDesignCtrl = Class.LightClass("HomelandFurnitureDesignCtrl", UICtrl)

HomelandFurnitureDesignCtrl.messages = {
	[MessageName.HOMELAND_BLUEPRINT_LIST_RESULT] = {
		"onBlueprintListResult",
		true
	},
	[MessageName.HOMELAND_BLUEPRINT_UPLOAD_RESULT] = {
		"onBlueprintListResult",
		true
	},
	[MessageName.HOMELAND_BLUEPRINT_DELETE_UPLOADED_RESULT] = {
		"onBlueprintListResult",
		true
	}
}

function HomelandFurnitureDesignCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.carGroup = info and info.carGroup
	self.chooseDesign = nil
	self.chooseCompose = nil
	self.selectData = nil
	self.homeBlueprintCoverImageKeys = {}

	self:initFurnitureDesignPageInfo()
end

function HomelandFurnitureDesignCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnImportUButton.luaClick()
		self:onImportBtnClick()
	end

	function self.view.btnViewUButton.luaClick()
		if not self.selectData then
			return
		end

		local homeIdList = {}

		for _, info in ipairs(self.selectData.ornaments) do
			table.insert(homeIdList, info.homeId)
		end

		local nameText = self.selectData.name
		local descText = self.selectData.desc

		if self.chooseDesign == UIConst.HOME_DESIGN_MODE.SYSTEMDESIGN then
			nameText = pg.getLocalizationText(self.selectData.name)
			descText = pg.getLocalizationText(self.selectData.desc)
		end

		pg.global.ui.homelandFurnitureComposeDetail:open({
			designIndex = self.chooseDesign,
			composeIndex = self.chooseCompose,
			carGroup = self.carGroup,
			detailData = {
				homeIdList = homeIdList,
				rangeSize = #(self.selectData.size or {}) > 0 and self.selectData.size or {
					0,
					0,
					0
				},
				loadValue = self.selectData.loadValue,
				comfortValue = self.selectData.comfortValue,
				code = self.selectData._id or "",
				name = nameText,
				description = descText,
				ownerName = self.selectData.ownerName,
				coverImageKeys = self.selectData.coverImageKeys,
				image = self.selectData.image
			}
		})
	end

	function self.view.btnCopyIDUButton.luaClick()
		if not self.selectData then
			return
		end

		local copyText

		if self.chooseDesign == UIConst.HOME_DESIGN_MODE.MYDESIGN then
			copyText = self.selectData._id
		elseif self.chooseDesign == UIConst.HOME_DESIGN_MODE.SHAREDESIGN then
			copyText = self.selectData.ownerName
		end

		if string.isNilOrEmpty(copyText) then
			return
		end

		UIUtils.ClipboardWriter(copyText)
		pg.global.ui.tips:showTextTip(pg.getGameString("GM_TIPS_COPY_SUCCESS"))
	end

	function self.view.selectorUSelector.luaRenderPopup(popup, uList)
		return
	end

	function self.view.selectorUSelector.luaSelectedChanged(selector)
		return
	end

	function self.view.listTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local name1 = objectReference:GetRefValue("name1")
		local name2 = objectReference:GetRefValue("name2")

		ClientTextUtils.setText(name1, data.name)
		ClientTextUtils.setText(name2, data.name)

		function button.luaClick()
			local composeIndex = self.chooseCompose or 1

			self:refreshPageInfo(data.designIndex, composeIndex)
		end
	end

	function self.view.listTabIconUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local textUBaseText = objectReference:GetRefValue("textUBaseText")

		iconUImage.url = data.icon

		ClientTextUtils.setText(textUBaseText, data.name)

		function button.luaClick()
			local designIndex = self.chooseDesign or 1

			self:refreshPageInfo(designIndex, data.composeIndex)
		end
	end

	function self.view.listDesignUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local playerUWidget = objectReference:GetRefValue("playerUWidget")
		local txtPlayerNameUSDFText = objectReference:GetRefValue("txtPlayerNameUSDFText")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local txtDisableUSDFText = objectReference:GetRefValue("txtDisableUSDFText")
		local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
		local imgPicUImage = objectReference:GetRefValue("imgPicUImage")

		playerUWidget:SetActive(self.chooseDesign == UIConst.HOME_DESIGN_MODE.SHAREDESIGN)
		ClientTextUtils.setText(txtPlayerNameUSDFText, data.ownerName or "")

		local nameText = data.name

		if self.chooseDesign == UIConst.HOME_DESIGN_MODE.SYSTEMDESIGN then
			nameText = pg.getLocalizationText(data.name)
		end

		ClientTextUtils.setText(txtNameUSDFText, nameText or "")
		ClientTextUtils.setText(txtDisableUSDFText, pg.getGameString("HOMELAND_COMPOSE_LAND_NOT_ENOUGH"))
		self.view.widget:TryChangePage("Type", self.chooseCompose - 1)

		local imageKey = data.coverImageKeys and data.coverImageKeys[1]
		local imageUrl = self.chooseDesign == UIConst.HOME_DESIGN_MODE.SYSTEMDESIGN and data.image or nil

		self.homeBlueprintCoverImageKeys[button] = imageKey
		imgPicUImage.sprite = nil
		imgPicUImage.url = nil

		if not string.isNilOrEmpty(imageUrl) then
			self.homeBlueprintCoverImageKeys[button] = nil

			button:TryChangePage("NoPic", 0)

			imgPicUImage.url = imageUrl
		elseif string.isNilOrEmpty(imageKey) then
			button:TryChangePage("NoPic", 1)
		else
			button:TryChangePage("NoPic", 0)

			imgPicUImage.url = data.coverImageKey or data.icon or ""

			pg.me:loadHomeBlueprintCoverImage(imageKey, function(sprite)
				local imageKeys = self.homeBlueprintCoverImageKeys

				if not self.view or not imageKeys or imageKeys[button] ~= imageKey or not NotNil(imgPicUImage) then
					return
				end

				imgPicUImage.url = nil
				imgPicUImage.sprite = sprite
			end)
		end

		function button.luaClick()
			self:refreshDesignDetail(data)
		end
	end

	function self.view.listDetailsUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtSizeUSDFText = objectReference:GetRefValue("txtSizeUSDFText")
		local txtSizeNumUSDFText = objectReference:GetRefValue("txtSizeNumUSDFText")

		ClientTextUtils.setText(txtSizeUSDFText, data.name)
		ClientTextUtils.setText(txtSizeNumUSDFText, data.info)
	end
end

function HomelandFurnitureDesignCtrl:onImportBtnClick()
	if self.chooseDesign ~= UIConst.HOME_DESIGN_MODE.SHAREDESIGN or self.chooseCompose ~= UIConst.HOME_COMPOSE_MODE.COMBINATION then
		return
	end

	pg.global.ui.tips:showCommonInput(pg.getGameString("HOMELAND_COMPOSE_IMPORT_COMBINATION"), function(inputText)
		local code = string.trim(inputText or "")

		if string.isNilOrEmpty(code) then
			return
		end

		pg.me:saveOtherHomeBlueprint(code)
	end, nil, {
		errorHide = true,
		inputTitle = "HOMELAND_COMPOSE_INPUT_COMBINATION_CODE",
		characterLimit = HomeBlueprintConst.DEFAULT_CONFIG.blueprintCodeLength or 8
	})
end

function HomelandFurnitureDesignCtrl:initFurnitureDesignPageInfo()
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("HOMELAND_COMPOSE_DESIGN_TITLE"))
	ClientTextUtils.setText(self.view.txtAddUSDFText, pg.getGameString("HOMELAND_COMPOSE_CREATE_PLAN"))
	ClientTextUtils.setText(self.view.txtDetailUSDFText, pg.getGameString("HOMELAND_COMPOSE_VIEW_DETAIL"))

	local pageList = {}

	table.insert(pageList, {
		tIndex = 0,
		name = pg.getGameString("HOMELAND_COMPOSE_MY_DESIGN"),
		designIndex = UIConst.HOME_DESIGN_MODE.MYDESIGN
	})
	table.insert(pageList, {
		tIndex = 1,
		name = pg.getGameString("HOMELAND_COMPOSE_SYSTEM_DESIGN"),
		designIndex = UIConst.HOME_DESIGN_MODE.SYSTEMDESIGN
	})
	table.insert(pageList, {
		tIndex = 2,
		name = pg.getGameString("HOMELAND_COMPOSE_SHARE_DESIGN"),
		designIndex = UIConst.HOME_DESIGN_MODE.SHAREDESIGN
	})
	self.view.listTabUList:SetList(pageList)

	local modelList = {}

	table.insert(modelList, {
		icon = "$UI_Img_HomeDesign_TabIcon_Compose.png",
		name = pg.getGameString("HOMELAND_COMPOSE_COMBINATION"),
		composeIndex = UIConst.HOME_COMPOSE_MODE.COMBINATION
	})
	self.view.listTabIconUList:SetList(modelList)

	local designIndex = self.chooseDesign or 1
	local composeIndex = self.chooseCompose or 1
	local res1, button1 = self.view.listTabUList:TryGetChildAt(designIndex - 1)

	if res1 then
		button1.isSelected = true
	end

	local res2, button2 = self.view.listTabIconUList:TryGetChildAt(composeIndex - 1)

	if res2 then
		button2.isSelected = true
	end

	self.view.selectorUSelector:SetActive(false)
	self:refreshPageInfo(designIndex, composeIndex)
end

function HomelandFurnitureDesignCtrl:refreshPageInfo(designIndex, composeIndex, force)
	if not force and self.chooseDesign == designIndex and self.chooseCompose == composeIndex then
		return
	end

	local designList = self:getDesignList(designIndex, composeIndex)

	self.chooseDesign = designIndex
	self.chooseCompose = composeIndex

	self.view.widget:TryChangePage("Type", composeIndex - 1)

	local maxPage = 0

	if designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN then
		maxPage = HomelandConfigData.maxUploadBlueprintCount or 10
	elseif designIndex == UIConst.HOME_DESIGN_MODE.SHAREDESIGN then
		maxPage = HomelandConfigData.maxSavedOtherBlueprintCount or 10
	end

	ClientTextUtils.setText(self.view.txtNumUSDFText, pg.getGameString("HOMELAND_COMPOSE_COMBINATION_COUNT") .. ": " .. (designList and #designList or 0) .. "/" .. maxPage)
	self.view.txtNumUSDFText:SetActive(designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN or designIndex == UIConst.HOME_DESIGN_MODE.SHAREDESIGN)

	local importText = composeIndex == UIConst.HOME_COMPOSE_MODE.COMBINATION and pg.getGameString("HOMELAND_COMPOSE_IMPORT_COMBINATION") or pg.getGameString("HOMELAND_COMPOSE_IMPORT_PLAN")

	ClientTextUtils.setText(self.view.txtImportUSDFText, importText)

	local codeText = composeIndex == UIConst.HOME_COMPOSE_MODE.COMBINATION and pg.getGameString("HOMELAND_COMPOSE_COMBINATION_CODE") or pg.getGameString("HOMELAND_COMPOSE_PLAN_CODE")

	if designIndex == UIConst.HOME_DESIGN_MODE.SHAREDESIGN then
		codeText = pg.getGameString("HOMELAND_COMPOSE_DESIGNER")
	end

	ClientTextUtils.setText(self.view.txtCodeUSDFText, codeText .. ": ")
	self.view.btnImportUButton:SetActive(designIndex == UIConst.HOME_DESIGN_MODE.SHAREDESIGN)

	if not designList then
		return
	elseif #designList == 0 then
		self.view.widget:TryChangePage("Empty", 1)

		local emptyText = composeIndex == UIConst.HOME_COMPOSE_MODE.COMBINATION and pg.getGameString("HOMELAND_COMPOSE_EMPTY_COMBINATION") or pg.getGameString("HOMELAND_COMPOSE_EMPTY_PLAN")
		local specialEmptyText = pg.getGameString("HOMELAND_COMPOSE_EMPTY_COMBINATION_MY")

		ClientTextUtils.setText(self.view.txtEmptyUSDFText, designIndex == UIConst.HOME_DESIGN_MODE.MYDESIGN and specialEmptyText or emptyText)
		ClientTextUtils.setText(self.view.txtNullUSDFText, emptyText)

		return
	end

	self.view.widget:TryChangePage("Empty", 0)
	self.view.listDesignUList:SetList(designList)
	self:refreshDesignDetail(designList[1])
end

function HomelandFurnitureDesignCtrl:getDesignList(designIndex, composeIndex)
	local designList = pg.me:getHomeBlueprintCachedList(designIndex, composeIndex)

	return designList
end

function HomelandFurnitureDesignCtrl:onBlueprintListResult(response)
	response = response or {}

	if not response.flag then
		return
	end

	local designIndex = response.sourceType

	if designIndex == self.chooseDesign and UIConst.HOME_COMPOSE_MODE.COMBINATION == self.chooseCompose then
		self:refreshPageInfo(designIndex, UIConst.HOME_COMPOSE_MODE.COMBINATION, true)
	end
end

function HomelandFurnitureDesignCtrl:refreshDesignDetail(data)
	self.selectData = data

	self.view.btnCopyIDUButton:SetActive(self.chooseDesign == UIConst.HOME_DESIGN_MODE.MYDESIGN or self.chooseDesign == UIConst.HOME_DESIGN_MODE.SHAREDESIGN)

	local nameText = data.name
	local descText = data.desc

	if self.chooseDesign == UIConst.HOME_DESIGN_MODE.SYSTEMDESIGN then
		nameText = pg.getLocalizationText(data.name)
		descText = pg.getLocalizationText(data.desc)
	end

	ClientTextUtils.setText(self.view.txtTitleUSDFText, nameText or "")
	ClientTextUtils.setText(self.view.txtDecoUSDFText, descText or "")

	if self.chooseDesign == UIConst.HOME_DESIGN_MODE.MYDESIGN then
		ClientTextUtils.setText(self.view.txtIDUSDFText, data._id)
	elseif self.chooseDesign == UIConst.HOME_DESIGN_MODE.SHAREDESIGN then
		ClientTextUtils.setText(self.view.txtIDUSDFText, data.ownerName)
	end

	local rangeSize = data.size

	if not rangeSize or #rangeSize == 0 then
		rangeSize = {
			0,
			0,
			0
		}
	end

	local detailList = {}

	table.insert(detailList, {
		name = pg.getGameString("HOMELAND_COMPOSE_SIZE"),
		info = rangeSize[1] .. "×" .. rangeSize[2] .. "×" .. rangeSize[3]
	})
	table.insert(detailList, {
		name = pg.getGameString("HOMELAND_COMPOSE_ITEM_COUNT"),
		info = tostring(#data.ornaments)
	})
	self.view.listDetailsUList:SetList(detailList)
end

function HomelandFurnitureDesignCtrl:onDestroy()
	self.homeBlueprintCoverImageKeys = nil

	UICtrl.onDestroy(self)

	self.chooseDesign = nil
	self.chooseCompose = nil
	self.selectData = nil
end

function HomelandFurnitureDesignCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function HomelandFurnitureDesignCtrl:onShow()
	return
end

function HomelandFurnitureDesignCtrl:onHide()
	return
end

return HomelandFurnitureDesignCtrl
