-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ItemViewer\\ItemViewerCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ItemViewerCtrl = Class.LightClass("ItemViewerCtrl", UICtrl)
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

ItemViewerCtrl.messages = {}

function ItemViewerCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initializeManagedBlur()
	pg.game.uiScene:switchToScene(UISceneConst.ITEM_VIEWER_SCENE, nil, nil, nil, self.module)

	self.itemViewerScene = pg.game.uiScene:getScene(UISceneConst.ITEM_VIEWER_SCENE)
end

function ItemViewerCtrl:getManagedBlurEffect()
	return self.view and self.view.bgBlurUIBlurEffect
end

function ItemViewerCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:onBtnSkip()
	end

	function self.view.btnFinish.luaClick()
		self:onBtnSkip()
	end

	function self.view.dotList.luaSelectedChanged(uList)
		self:onDotSelectChanged()
	end

	function self.view.btnPre.luaClick()
		self:onBtnPreItem()
	end

	function self.view.btnNext.luaClick()
		self:onBtnNxtItem()
	end

	function self.view.btnSwitch.luaClick()
		self:onBtnSwitchImage()
	end

	local exitBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnClose.gameObject, "closeBind")

	exitBinding.actionPath = "Common/Cancel"
	exitBinding.isVirtual = true

	function exitBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:onBtnSkip()
		end
	end
end

function ItemViewerCtrl:onDestroy()
	pg.game.uiScene:switchOutScene(UISceneConst.ITEM_VIEWER_SCENE, true, nil, self.module)
	UICtrl.onDestroy(self)
end

function ItemViewerCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	pg.me:serverMsg("RPC_CS_OnShowContent", info)
end

function ItemViewerCtrl:checkCanOpen(showNotice, info)
	if info == nil or table.nums(info) == 0 then
		return false
	end

	local dataList = self.model:parseItemDataList(info)

	if #dataList == 0 then
		pg.global.showBubbleMessageRaw(pg.getGameString("ITEM_NO_CONTENT"), 3)

		return false
	end

	self.dataList = dataList

	return true
end

function ItemViewerCtrl:onDotSelectChanged()
	local dotButtons = self.view.dotList:GetAllButtons()

	for i = 0, dotButtons.Length - 1 do
		local dotBtn = dotButtons[i]
		local data = dotBtn.dataFromUList

		dotBtn:TryChangePage("State", data.selected and 1 or 0)
	end
end

function ItemViewerCtrl:onShow()
	self.itemViewerScene:setRawImage(self.view.modelRawImage, 1580, 1580)
	self.view.dotList:SetList(self.dataList)

	self.curSelectIndex = 1

	self:refreshItemView()
end

function ItemViewerCtrl:refreshItemView()
	local min = 1
	local max = #self.dataList

	if min > self.curSelectIndex then
		self.curSelectIndex = min
	end

	if max < self.curSelectIndex then
		self.curSelectIndex = max
	end

	self.view.dotList:SelectItem(self.curSelectIndex - 1)

	local itemData = self.dataList[self.curSelectIndex]

	self.view.rootComponent:TryChangePage("showLast", self.curSelectIndex == max and itemData.showPagePoint <= 0 and 1 or 0)

	if string.isNilOrEmpty(itemData.tip) then
		self.view.rootComponent:TryChangePage("Tips", 0)
	else
		self.view.rootComponent:TryChangePage("Tips", 1)
		ClientTextUtils.setText(self.view.txtTips, itemData.tip)
	end

	self.view.rootComponent:TryChangePage("Type", itemData.mode)

	if itemData.mode ~= self.model.VIEWER_MODE.MODE1 then
		self.view.imgBg:SetActive(false)
		self.itemViewerScene:hideCurModel()
		pg.game.uiScene:setMainSceneActive(true)
	end

	if itemData.mode == self.model.VIEWER_MODE.MODE1 then
		self.view.imgBg:SetActive(true)
		self.itemViewerScene:showModel(itemData)
		pg.game.uiScene:setMainSceneActive(true)
	elseif itemData.mode == self.model.VIEWER_MODE.MODE2 then
		if itemData.pictureFront and itemData.pictureBack then
			self.view.rootComponent:TryChangePage("HaveSwitch", 1)
		else
			self.view.rootComponent:TryChangePage("HaveSwitch", 0)
		end

		self.view.imgPic.url = itemData.pictureFront

		local rot = itemData.pictureRotationInit

		if rot and #rot >= 3 then
			self.view.picRect.localRotation = Quaternion.Euler(rot[1], rot[2], rot[3])
		else
			self.view.picRect.localRotation = Quaternion.Euler(0, 0, 0)
		end
	elseif itemData.mode == self.model.VIEWER_MODE.MODE3 then
		self.view.container.url = itemData.contentResId

		self:SetModel3ExitBtn()
	elseif itemData.mode == self.model.VIEWER_MODE.MODE4 then
		ClientTextUtils.setText(self.view.txtTitle, itemData.title)
		ClientTextUtils.setText(self.view.txtScroll.content, itemData.content)
	elseif itemData.mode == self.model.VIEWER_MODE.MODE5 then
		self:setModel5Info(itemData)
	end

	self.view.rootComponent:TryChangePage("showPre", min < self.curSelectIndex and 1 or 0)
	self.view.rootComponent:TryChangePage("showNxt", max > self.curSelectIndex and 1 or 0)
	self.view.dotList:SetActive(itemData.showPagePoint <= 0)
end

function ItemViewerCtrl:SetModel3ExitBtn()
	local itemData = self.dataList[self.curSelectIndex]

	self.view.btnClose:SetActive(itemData.useExitInPrefab <= 0)

	if itemData.useExitInPrefab and itemData.useExitInPrefab > 0 then
		local containerRef = self.view.container.content:GetComponent("ObjectReference")
		local btnClose = containerRef:GetRefValue("btnClose")

		function btnClose.luaClick()
			self:dismiss()
		end

		local exitBinding = KeyBindingPro.GetOrAddKeyBindingByName(btnClose.gameObject, "ItemViewerCtrlBg")

		exitBinding.actionPath = "Common/Cancel"
		exitBinding.isVirtual = true

		function exitBinding.luaTrigger(inputInfo)
			if inputInfo.phase == "Performed" then
				btnClose.luaClick()
			end
		end
	end
end

function ItemViewerCtrl:setModel5Info(itemData)
	ClientTextUtils.setText(self.view.mode5TitleUBaseText, itemData.mode5Title)
	ClientTextUtils.setText(self.view.mode5NameUBaseText, itemData.mode5Name)
	ClientTextUtils.setText(self.view.mode5DateUBaseText, itemData.mode5Date)

	function self.view.mode5ContentUList.luaRenderItem(button, index, data)
		if data.tIndex == 0 then
			local objectReference = button:GetComponent("ObjectReference")
			local imgPicUImage = objectReference:GetRefValue("imgPicUImage")
			local listPicMultipleUList = objectReference:GetRefValue("listPicMultipleUList")
			local txtDetailsUBaseText = objectReference:GetRefValue("txtDetailsUBaseText")
			local multiImg = #data.mode5Imgs > 1
			local haveImgInfo = data.mode5ImgInfo ~= nil

			button:TryChangePage("Type", multiImg and 1 or 0)
			button:TryChangePage("HaveDetails", haveImgInfo and 1 or 0)

			if haveImgInfo then
				ClientTextUtils.setText(txtDetailsUBaseText, data.mode5ImgInfo)
			end

			if multiImg then
				function listPicMultipleUList.luaRenderItem(button2, index2, data2)
					button2:GetChild("ImgPic"):GetComponent("UImage").url = data2.url
				end

				local imgData = {}

				for index, value in ipairs(data.mode5Imgs) do
					table.insert(imgData, {
						url = value
					})
				end

				listPicMultipleUList:SetList(imgData)
			elseif data.mode5Imgs[1] then
				imgPicUImage.url = data.mode5Imgs[1]
			end
		elseif data.tIndex == 1 then
			ClientTextUtils.setText(button:GetChild("TxtContnent"):GetComponent("UBaseText"), data.mode5TxtContent)
		end
	end

	local mode5Data = {
		{
			tIndex = 0,
			mode5Imgs = itemData.mode5Imgs,
			mode5ImgInfo = itemData.mode5ImgInfo
		},
		{
			tIndex = 1,
			mode5TxtContent = itemData.mode5TxtContent
		}
	}

	self.view.mode5ContentUList:SetList(mode5Data)
end

function ItemViewerCtrl:onBtnPreItem()
	self.curSelectIndex = self.curSelectIndex - 1

	self:refreshItemView()
end

function ItemViewerCtrl:onBtnNxtItem()
	self.curSelectIndex = self.curSelectIndex + 1

	self:refreshItemView()
end

function ItemViewerCtrl:onBtnSwitchImage()
	local itemData = self.dataList[self.curSelectIndex]

	if itemData.pictureFront ~= self.view.imgPic.url then
		self.view.imgPic.url = itemData.pictureFront
	else
		self.view.imgPic.url = itemData.pictureBack
	end
end

function ItemViewerCtrl:onBtnSkip()
	self:dismiss()
end

function ItemViewerCtrl:onHide()
	return
end

return ItemViewerCtrl
