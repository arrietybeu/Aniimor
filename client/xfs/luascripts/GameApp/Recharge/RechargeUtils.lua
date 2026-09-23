-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Recharge\\RechargeUtils.lua

local RechargeConst = require("GameApp.Recharge.RechargeConst")
local StringEx = require("Core.Framework.String")
local csSDKManager = CS.FunPlus.WorldX.SDK.SDKManager
local RechargeData = require("Data.shopmall_recharge_data")
local UIConst = require("Const.UIConst")
local logger = require("Core.Log.LoggerManager").getLogger("RechargeCtrl")
local ItemConst = require("Common.Const.ItemConst")
local CommonSwitch = require("Common.CommonSwitch")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ShopConstantData = require("Data.shopmall_constant_data")
local Utils = require("Common.Utils.Utils")
local RechargeUtils = {}

function RechargeUtils.setupMoneyList(moneyListUButton)
	if not moneyListUButton then
		return
	end

	local objectReference = moneyListUButton:GetComponent("ObjectReference")
	local btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	local txtBtnSwitch = objectReference:GetRefValue("txtBtnSwitch")
	local infoBtn1 = objectReference:GetRefValue("infoBtn1")
	local infoBtn2 = objectReference:GetRefValue("infoBtn2")
	local txtInfoBtn1 = objectReference:GetRefValue("txtInfoBtn1")
	local txtInfoBtn2 = objectReference:GetRefValue("txtInfoBtn2")
	local txtNameBlueUSDFText1 = objectReference:GetRefValue("txtNameBlueUSDFText1")
	local txtNameBlueUSDFText2 = objectReference:GetRefValue("txtNameBlueUSDFText2")
	local recharge = pg.game and pg.game.recharge
	local showDirectPurchase = recharge and recharge:isDirectBuySwitchAvailable() and (UNITY_EDITOR or pg.global.ui:runPlatformByMobile())
	local directPurchaseSwitchTarget

	moneyListUButton:TryChangePage("switch", showDirectPurchase and 1 or 0)

	if showDirectPurchase and btnSwitchUButton then
		directPurchaseSwitchTarget = btnSwitchUButton

		local selected = recharge and recharge:isUseFunStore() or false

		btnSwitchUButton.luaSelectChanged = nil

		if btnSwitchUButton.isSelected ~= selected then
			btnSwitchUButton.isSelected = selected
		end

		if txtBtnSwitch then
			ClientTextUtils.setText(txtBtnSwitch, pg.getGameString("Office_pay_switch"))
		end

		function btnSwitchUButton.luaSelectChanged(isSelected)
			local selected = recharge and recharge:setUseFunStore(isSelected) or false

			if btnSwitchUButton.isSelected ~= selected then
				btnSwitchUButton.isSelected = selected
			end

			ClientTextUtils.setText(txtBtnSwitch, pg.getGameString("Office_pay_switch"))
		end
	end

	local isJapan = pg.global.sdkManager:isClientIPCountry("JP")

	moneyListUButton:TryChangePage("Info", isJapan and 1 or 0)

	if infoBtn1 and not infoBtn1.luaClick then
		function infoBtn1.luaClick()
			RechargeUtils.openJapanLegalInfo("third_party_address_jp_about")
		end
	end

	if infoBtn2 and not infoBtn2.luaClick then
		function infoBtn2.luaClick()
			RechargeUtils.openJapanLegalInfo("third_party_address_jp_fund")
		end
	end

	if infoBtn2 then
		infoBtn2.gameObject:SetActiveEx(isJapan and CommonSwitch.JP_FUND_LEGAL_INFO == true)
	end

	if txtInfoBtn1 then
		ClientTextUtils.setText(txtInfoBtn1, "特定商取引法")
	end

	if txtInfoBtn2 then
		ClientTextUtils.setText(txtInfoBtn2, "資金決済法")
	end

	if txtNameBlueUSDFText1 then
		local addressConfig = ShopConstantData.third_party_address_jp_about
		local address = addressConfig and addressConfig.number
		local text = "特定商取引法"

		if address then
			text = string.format("<link=\"web_%s\"><color=#ffffff><u>%s</u></color></link>", address, text)
		end

		txtNameBlueUSDFText1.enabledHyperlink = address ~= nil

		if txtNameBlueUSDFText1.enabledHyperlink and not txtNameBlueUSDFText1.luaOnHyperlinkClick then
			function txtNameBlueUSDFText1.luaOnHyperlinkClick()
				RechargeUtils.openJapanLegalInfo("third_party_address_jp_about")
			end
		end

		ClientTextUtils.setText(txtNameBlueUSDFText1, text)
	end

	if txtNameBlueUSDFText2 then
		local addressConfig = ShopConstantData.third_party_address_jp_fund
		local address = addressConfig and addressConfig.number
		local text = "資金決済法"

		if address then
			text = string.format("<link=\"web_%s\"><color=#ffffff><u>%s</u></color></link>", address, text)
		end

		txtNameBlueUSDFText2.enabledHyperlink = address ~= nil

		if txtNameBlueUSDFText2.enabledHyperlink and not txtNameBlueUSDFText2.luaOnHyperlinkClick then
			function txtNameBlueUSDFText2.luaOnHyperlinkClick()
				RechargeUtils.openJapanLegalInfo("third_party_address_jp_fund")
			end
		end

		ClientTextUtils.setText(txtNameBlueUSDFText2, text)
	end

	return directPurchaseSwitchTarget
end

function RechargeUtils.openJapanLegalInfo(addressKey)
	local addressConfig = ShopConstantData[addressKey]
	local address = addressConfig and addressConfig.number

	if not address then
		return
	end

	pg.global.sdkManager:openUrl("RechargeUtils", "ShopConstantData." .. addressKey, address)
end

function RechargeUtils.getSDKProductInfo(productId)
	local products = UNITY_EDITOR and RechargeUtils.getTestSDKProducts() or csSDKManager:GetPayProductsTable()

	if not products then
		return nil
	end

	for _, info in ipairs(products) do
		if info.product_id and info.product_id == productId then
			return info
		end
	end

	return nil
end

function RechargeUtils.getAllSDKProducts()
	local result = {}
	local products = UNITY_EDITOR and RechargeUtils.getTestSDKProducts() or csSDKManager:GetPayProductsTable()

	if not products then
		return result
	end

	for _, info in ipairs(products) do
		if info.product_id then
			result[info.product_id] = info
		end
	end

	return result
end

function RechargeUtils.getProductPayInfo(productId)
	local cfg = RechargeUtils.getProductConfigInfo(productId)
	local sdkInfo = RechargeUtils.getSDKProductInfo(productId)

	return {
		productId = productId,
		productName = cfg and pg.getLocalizationText(cfg.name) or "",
		productDesc = cfg and pg.getLocalizationText(cfg.des) or "",
		iconUrl = cfg and cfg.url or "",
		sdkInfo = sdkInfo
	}
end

local productConfigCache = {}

function RechargeUtils.getProductConfigInfo(productId)
	if productConfigCache[productId] then
		return productConfigCache[productId].data, productConfigCache[productId].key
	end

	for key, data in pairs(RechargeData) do
		if data.product_id == productId then
			productConfigCache[productId] = {
				data = data,
				key = key
			}

			return data, key
		end
	end
end

function RechargeUtils.isEmptyStore()
	local allsdkProducts = UNITY_EDITOR and RechargeUtils.getTestSDKProducts() or csSDKManager:GetPayProductsTable()

	for k, v in pairs(allsdkProducts) do
		return false
	end

	return true
end

function RechargeUtils.getAllProductRechargeDisplayInfo()
	local allsdkProducts = UNITY_EDITOR and RechargeUtils.getTestSDKProducts() or csSDKManager:GetPayProductsTable()

	logger:info("RechargeUtils getAllProductRechargeDisplayInfo = %s", inspect(allsdkProducts))

	local products = {}

	for _, info in pairs(allsdkProducts) do
		local cfg, id = RechargeUtils.getProductConfigInfo(info.product_id)

		if cfg then
			local isHide = cfg.isHide and cfg.isHide == 1
			local isFirst = not pg.me.PcFirstPayPassed or not pg.me.PcFirstPayPassed[id]

			if cfg.type == RechargeConst.RECHARGE_TYPE.RECHARGE and not isHide then
				local data = {
					productId = info.product_id,
					packageId = id,
					cfgInfo = cfg,
					sdkInfo = info,
					isFirst = isFirst
				}

				table.insert(products, data)
			end
		end
	end

	table.sort(products, function(a, b)
		return a.cfgInfo.sort < b.cfgInfo.sort
	end)

	return products
end

function RechargeUtils.openQuickPay(args)
	if not CommonSwitch.ShopMall_Recharge then
		local NoticeDef = require("Common.NoticeDef")

		pg.global.showBubbleMessage(NoticeDef.HOME_REDEEM_LACK)

		return
	end

	if not args then
		return
	end

	local itemId = args.itemId
	local itemNum = args.itemNum
	local needCount = args.needCount
	local currencyID = args.currencyID

	if not itemId or not itemNum or not needCount or not currencyID then
		return
	end

	local hadCount = pg.me:getItemCountById(ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND)

	if currencyID == ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND then
		hadCount = hadCount + pg.me:getItemCountById(ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND)
	end

	if needCount <= hadCount then
		return
	end

	local notEnoughCount = needCount - hadCount
	local payInfo = RechargeUtils.getNeedPayInfo(currencyID, notEnoughCount)

	if not payInfo then
		return
	end

	local shopInfo = {
		itemId = itemId,
		itemNum = itemNum,
		needBuyCnt = notEnoughCount,
		needCurrencyID = currencyID,
		displayGender = args.displayGender
	}

	pg.global.ui:open(UIConst.UI_ID_QUICK_PAYMENT, {
		productInfo = payInfo,
		shopItemInfo = shopInfo,
		categoryType = args.categoryType,
		buyCallBack = args.buyCallBack
	})
end

function RechargeUtils.getNeedPayInfo(currencyID, notEnoughCount)
	local allsdkProducts = RechargeUtils.getAllProductRechargeDisplayInfo()

	table.sort(allsdkProducts, function(a, b)
		return a.cfgInfo.sort < b.cfgInfo.sort
	end)

	local maxNumInfo, maxNum

	for _, info in ipairs(allsdkProducts) do
		local cfg = info.cfgInfo

		if cfg then
			local currendNum = 0

			currendNum = currendNum + cfg.getCurrency[2]

			if cfg.firstTmieGift[1] == currencyID and info.isFirst then
				currendNum = currendNum + cfg.firstTmieGift[2]
			end

			currendNum = currendNum + cfg.extraGift[2]

			if notEnoughCount <= currendNum then
				return info
			end

			if not maxNum or maxNum < currendNum then
				maxNum = currendNum
				maxNumInfo = info
			end
		end
	end

	return maxNumInfo
end

function RechargeUtils.getProductsInfo(rechargeType, gearType)
	rechargeType = rechargeType or RechargeConst.RECHARGE_TYPE.MONTHCAR

	local allsdkProducts = UNITY_EDITOR and RechargeUtils.getTestSDKProducts() or csSDKManager:GetPayProductsTable()

	if not allsdkProducts then
		return nil
	end

	for _, info in pairs(allsdkProducts) do
		local cfg, id = RechargeUtils.getProductConfigInfo(info.product_id)

		if cfg and cfg.type == rechargeType and (gearType == nil or gearType == cfg.sort) then
			local data = {
				productId = info.product_id,
				packageId = id,
				cfgInfo = cfg,
				sdkInfo = info
			}

			return data
		end
	end
end

function RechargeUtils.getProductsPrice(data)
	if not data then
		return ""
	end

	if data.cfgInfo and data.cfgInfo.text then
		return pg.getLocalizationText(data.cfgInfo.text)
	end

	local sdkInfo = data.sdkInfo

	if not sdkInfo then
		return ""
	end

	local hooks = RechargeUtils._platformHooks

	if hooks and hooks.getProductsPrice then
		local hookPrice = hooks.getProductsPrice(data)

		if hookPrice then
			return hookPrice
		end
	end

	if not Utils.isOverseas() then
		if _G_IsDebugMode then
			return pg.getFormatText("{0}元", tonumber(sdkInfo.amount))
		else
			return pg.getFormatText("￥{0}", tonumber(sdkInfo.amount))
		end
	end

	if sdkInfo.currency and sdkInfo.amount then
		return pg.getFormatText("{0}{1}", sdkInfo.currency, tonumber(sdkInfo.amount))
	end

	return sdkInfo.price or ""
end

function RechargeUtils.openThirdPartyPay()
	local addressKey

	if pg.global.sdkManager:isPkgChannel(RechargeConst.RUSSIAN_THIRD_PARTY_PAY_CHANNELS) then
		addressKey = _G_IsDebugMode and "third_party_address_test_ru" or "third_party_address_ru"
	elseif ClientConfigAppCountry == "cn" then
		addressKey = _G_IsDebugMode and "third_party_address_test" or "third_party_address"
	else
		addressKey = _G_IsDebugMode and "third_party_address_test_global" or "third_party_address_global"
	end

	local addressConfig = ShopConstantData[addressKey]
	local addr = addressConfig and addressConfig.number

	if not addr then
		return
	end

	local sessionKey = pg.global.sdkManager:getSessionKey()

	if sessionKey and sessionKey ~= "" then
		local sep = string.find(addr, "?", 1, true) and "&" or "/?"

		addr = addr .. sep .. "session_key=" .. StringEx.urlencode(sessionKey)
	end

	local utmCampaign = pg.global.platform:isMobile() and "mobile_game" or "pc_game"
	local sep = string.find(addr, "?", 1, true) and "&" or "/?"

	addr = addr .. sep .. "uid=" .. StringEx.urlencode(pg.me.uid) .. "&pkg_channel=" .. StringEx.urlencode(pg.global.sdkManager:getPkgChannel()) .. "&utm_campaign=" .. StringEx.urlencode(utmCampaign)

	if _G_IsDebugMode then
		local _, dirKey = ClientUtils.getDirConf()

		if dirKey then
			local sep = string.find(addr, "?", 1, true) and "&" or "/?"

			addr = addr .. sep .. "gameServerEnv=" .. StringEx.urlencode(dirKey)
		end
	end

	pg.global.sdkManager:openUrl("RechargeUtils", "ShopConstantData." .. addressKey, addr)
end

function RechargeUtils.getTestSDKProducts()
	local sdkProducts = {
		{
			currency_symbol = "￥",
			currency = "CNY",
			channel_product_id = "com.x.yimoo.1.1.6",
			amount = "6.00",
			description = "6个元宝(测试数据)",
			product_id = "com.x.yimoo.1.1.6",
			displayName = "6元宝(测试数据)",
			price = "CNY6.00"
		},
		{
			currency_symbol = "￥",
			currency = "CNY",
			channel_product_id = "com.x.yimoo.1.1.30",
			amount = "30.00",
			description = "30个元宝(测试数据)",
			product_id = "com.x.yimoo.1.1.30",
			displayName = "30元宝(测试数据)",
			price = "CNY30.00"
		},
		{
			currency_symbol = "￥",
			currency = "CNY",
			channel_product_id = "com.x.yimoo.1.1.98",
			amount = "98.00",
			description = "98个元宝(测试数据)",
			product_id = "com.x.yimoo.1.1.98",
			displayName = "98元宝(测试数据)",
			price = "CNY98.00"
		},
		{
			currency_symbol = "￥",
			currency = "CNY",
			channel_product_id = "com.x.yimoo.1.1.1980",
			amount = "198.00",
			description = "198个元宝(测试数据)",
			product_id = "com.x.yimoo.1.1.1980",
			displayName = "198元宝(测试数据)",
			price = "CNY198.00"
		},
		{
			currency_symbol = "￥",
			currency = "CNY",
			channel_product_id = "com.x.yimoo.1.1.3280",
			amount = "328.00",
			description = "328个元宝(测试数据)",
			product_id = "com.x.yimoo.1.1.3280",
			displayName = "328元宝(测试数据)",
			price = "CNY328.00"
		},
		{
			currency_symbol = "￥",
			currency = "CNY",
			channel_product_id = "com.x.yimoo.1.1.6480",
			amount = "648.00",
			description = "648个元宝(测试数据)",
			product_id = "com.x.yimoo.1.1.6480",
			displayName = "648元宝(测试数据)",
			price = "CNY648.00"
		},
		{
			currency_symbol = "￥",
			currency = "CNY",
			channel_product_id = "com.x.yimoo.1.2.30",
			amount = "30.00",
			description = "月卡(测试数据)",
			product_id = "com.x.yimoo.1.2.30",
			displayName = "月卡(测试数据)",
			price = "CNY30.00"
		},
		{
			currency_symbol = "￥",
			currency = "CNY",
			channel_product_id = "com.x.aniimos.gppay.30",
			amount = "30.00",
			description = "海外测试月卡(测试数据)",
			product_id = "com.x.aniimos.gppay.30",
			displayName = "海外测试月卡(测试数据)",
			price = "CNY30.00"
		},
		{
			currency_symbol = "￥",
			currency = "CNY",
			channel_product_id = "com.x.yimoo.1.3.68",
			amount = "68.00",
			description = "战令礼包(测试数据)",
			product_id = "com.x.yimoo.1.3.68",
			displayName = "战令礼包(测试数据)",
			price = "CNY68.00"
		},
		{
			currency_symbol = "￥",
			currency = "CNY",
			channel_product_id = "com.x.yimoo.1.3.128",
			amount = "128.00",
			description = "同行随从礼包(测试数据)",
			product_id = "com.x.yimoo.1.3.128",
			displayName = "同行随从礼包(测试数据)",
			price = "CNY128.00"
		},
		{
			currency_symbol = "￥",
			currency = "CNY",
			channel_product_id = "com.x.yimoo.1.3.60",
			amount = "60.00",
			description = "商品来自SDK(测试数据)",
			product_id = "com.x.yimoo.1.3.60",
			displayName = "商品来自SDK(测试数据)",
			price = "CNY60.00"
		}
	}

	return sdkProducts
end

return RechargeUtils
