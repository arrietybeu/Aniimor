-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Setting\\SettingModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ClientUtils = require("Utils.ClientUtils")
local Lume = require("Core.Common.lume")
local SettingTypeData = require("Data.setting_type_data")
local SettingFuncListData = require("Data.setting_func_list_data")
local VideoSettingData = require("Data.video_setting_data")
local ClientConst = require("Const.ClientConst")
local SDKLoginConfig = require("SDK.SDKLoginConfig")
local SettingModel = Class.LightClass("SettingModel", UIModel)
local PackDownloadGroup = require("Data.pack_download_group")
local PackDownloadItem = require("Data.pack_download_item")
local SettingSubToMainData = require("Data.setting_sub_to_condition_map")
local Utils = require("Common.Utils.Utils")
local CommonSwitch = require("Common.CommonSwitch")

SettingModel.testData = {
	{
		label = "游戏设置",
		tab = "game",
		items = {
			{
				tIndex = 0,
				cate = "ui",
				label = "界面设置",
				tab = "game",
				settingList = {
					{
						label = "界面帮助说明",
						tIndex = 2,
						info = {
							funcType = "showUI",
							funcParam = "help"
						}
					},
					{
						label = "显示罗盘",
						tIndex = 2,
						info = {
							funcType = "showUI",
							funcParam = "compass"
						}
					}
				}
			},
			{
				tIndex = 0,
				cate = "function",
				label = "功能设置",
				tab = "game",
				settingList = {
					{
						label = "攻击时自动锁定目标",
						tIndex = 2,
						info = {
							funcType = "autoLock"
						}
					}
				}
			}
		}
	},
	{
		label = "显示设置",
		tab = "video",
		items = {
			{
				tIndex = 0,
				cate = "video",
				label = "显示设置",
				tab = "video",
				settingList = {
					{
						label = "亮度",
						tIndex = 7,
						info = {
							buttonFunc = {
								"setLightLv"
							},
							widgetTxt = {
								1
							}
						}
					}
				}
			}
		}
	},
	{
		label = "音频",
		tab = "audio",
		items = {
			{
				tIndex = 0,
				cate = "mainVol",
				label = "主音量",
				tab = "audio",
				settingList = {
					{
						label = "主音量",
						tIndex = 6,
						info = {
							funcType = "mainVol",
							widgetParam = {
								0,
								100
							}
						}
					}
				}
			},
			{
				tIndex = 0,
				cate = "volBalance",
				label = "音量平衡",
				tab = "audio",
				settingList = {
					{
						label = "音乐",
						tIndex = 6,
						info = {
							funcType = "musicVol",
							widgetParam = {
								0,
								100
							}
						}
					},
					{
						label = "音效",
						tIndex = 6,
						info = {
							funcType = "soundVol",
							widgetParam = {
								0,
								100
							}
						}
					},
					{
						label = "语音",
						tIndex = 6,
						info = {
							funcType = "voiceVol",
							widgetParam = {
								0,
								100
							}
						}
					}
				}
			}
		}
	},
	{
		label = "语言",
		tab = "language",
		items = {
			{
				tIndex = 0,
				cate = "language",
				label = "语言",
				tab = "language",
				settingList = {
					{
						label = "选择语言",
						tIndex = 4,
						info = {
							funcType = "language",
							widgetDefaultValue = "zh_CN",
							widgetParam = {
								"zh_CN",
								"en"
							},
							widgetTxt = {
								5,
								6
							}
						}
					}
				}
			}
		}
	}
}

function SettingModel:addTestData()
	self.settingData[#self.settingData + 1] = {
		label = "按键设置",
		tab = "key",
		items = {
			{
				tIndex = 0,
				cate = "keyReplace",
				label = "按键替换",
				tab = "key",
				settingList = {
					{
						tIndex = 6,
						info = {
							funcType = "rumbleRatio",
							widgetParam = {
								0,
								4
							}
						}
					},
					{
						tIndex = 6,
						info = {
							funcType = "gyroscopeRatio",
							widgetParam = {
								0,
								4
							}
						}
					}
				}
			}
		}
	}
end

SettingModel.PlatformType = {
	Mobile = 1,
	PC = 2
}
SettingModel.OPEN_SOURCE = {
	Login = 1
}
SettingModel.keyReplaceIndex = 4

function SettingModel:setOpenSource(openInfo)
	local source = openInfo and openInfo.openSource or nil

	self.openSource = source
end

function SettingModel:clearSettingData()
	self.settingData = nil
end

function SettingModel:getSettingData(forceUpdate)
	self.settingTab2settingList = {}
	self.settingInfo2Id = {}

	local setFuncList = self:getSettingFuncListData()

	for id, settingInfo in pairs(setFuncList) do
		if settingInfo.hide == nil or settingInfo.hide == 0 then
			self.settingInfo2Id[settingInfo] = id

			local key = settingInfo.tab .. settingInfo.cate

			if self.settingTab2settingList[key] == nil then
				self.settingTab2settingList[key] = {}
			end

			local settingList = self.settingTab2settingList[key]

			settingList[#settingList + 1] = settingInfo
		end
	end

	self.settingData = {}

	local curTab = ""
	local curTabItems = {}

	curTabItems.items = {}

	local settingDataCfg = self:_getSettingTypeData()

	for _, val in ipairs(settingDataCfg) do
		local typeData = SettingTypeData[val.idx]

		if typeData.hide == nil and (ClientConfigCloudEnable ~= "true" or typeData.tab ~= "video") and ClientUtils.checkIsOpenToCurPlatform(typeData) then
			local tab = typeData.tab

			if curTab ~= "" and tab ~= curTab then
				if #curTabItems.items > 0 then
					self.settingData[#self.settingData + 1] = curTabItems
				end

				curTabItems = {
					items = {}
				}
			end

			if curTabItems.tab == nil then
				curTabItems.tab = tab

				local tabName = pg.getLocalizationText(typeData.tabName)

				if tabName ~= "" then
					curTabItems.label = tabName
				end

				curTabItems.tIndex = 0
				curTabItems.state = 0
				curTabItems.type = 2
				curTabItems.icon = typeData.icon
			end

			curTab = tab

			local subItem = {}

			subItem.tab = tab
			subItem.cate = typeData.cate
			subItem.label = pg.getLocalizationText(typeData.cateName)
			subItem.tIndex = 0
			subItem.settingList = {}

			local key = subItem.tab .. subItem.cate
			local settingListInfos = self.settingTab2settingList[key] or {}

			for _, settingInfo in ipairs(settingListInfos) do
				if self:checkSettingPlatformOpen(settingInfo) and self:checkSettingCanOpen(settingInfo) then
					local data = {
						tIndex = settingInfo.widgetType,
						label = pg.getLocalizationText(settingInfo.name),
						desc = pg.getLocalizationText(settingInfo.desc),
						info = settingInfo
					}

					self:refreshWithRelation(data)

					subItem.settingList[#subItem.settingList + 1] = data
				end
			end

			if #subItem.settingList > 0 then
				curTabItems.items[#curTabItems.items + 1] = subItem
			end
		end
	end

	if #curTabItems.items > 0 then
		self.settingData[#self.settingData + 1] = curTabItems
	end

	local videoSetting = self:addVideoSetting()

	for _, value in ipairs(self.settingData) do
		if value.tab == "video" then
			for index, setting in ipairs(videoSetting) do
				if index == 1 then
					table.insert(value.items[1].settingList, 1, setting)
				else
					table.insert(value.items[1].settingList, setting)
				end
			end
		elseif value.tab == "resource" then
			local items = self:addPackDownloadItems()

			for _, item in ipairs(items) do
				value.items[#value.items + 1] = item
			end
		end
	end

	for _, value in ipairs(self.settingData) do
		for _, setting in ipairs(value.items) do
			for i = 2, #setting.settingList do
				local value = setting.settingList[i]
				local keyOrder = value.info.order or 10000
				local j = i - 1

				while j >= 1 and keyOrder < (setting.settingList[j].info.order or 10000) do
					setting.settingList[j + 1] = setting.settingList[j]
					j = j - 1
				end

				setting.settingList[j + 1] = value
			end
		end
	end

	local infoToId = self.settingInfo2Id or {}

	for _, value in ipairs(self.settingData) do
		if value.tab == "game" or value.tab == "operate" then
			for _, setting in ipairs(value.items) do
				for i = 2, #setting.settingList do
					local v = setting.settingList[i]
					local vOrder = v.info.order or 10000
					local vId = infoToId[v.info] or math.huge
					local j = i - 1

					while j >= 1 do
						local prev = setting.settingList[j].info

						if (prev.order or 10000) == vOrder and vId < (infoToId[prev] or math.huge) then
							setting.settingList[j + 1] = setting.settingList[j]
							j = j - 1
						else
							break
						end
					end

					setting.settingList[j + 1] = v
				end
			end
		end
	end

	local _h = SettingModel._platformHooks

	if _h and _h.handlePlatformSettingData then
		self.settingData = _h.handlePlatformSettingData(self, self.settingData) or self.settingData
	end

	return self.settingData
end

function SettingModel:_getSettingTypeData()
	if self.settingTypeDataPost == nil then
		self.settingTypeDataPost = {}

		for i, val in pairs(SettingTypeData) do
			table.insert(self.settingTypeDataPost, {
				idx = i
			})
		end

		table.sort(self.settingTypeDataPost, function(a, b)
			return a.idx < b.idx
		end)
	end

	return self.settingTypeDataPost
end

function SettingModel:addPackDownloadItems()
	local itemList = {}

	for id, group in ipairs(PackDownloadGroup) do
		local item = {}

		item.tab = "resource"
		item.cate = "group" .. id
		item.label = pg.getLocalizationText(group.name)
		item.settingList = {}

		local downloadItems = {}

		for packId, packItem in pairs(PackDownloadItem) do
			if packItem.showInList and packItem.group == id then
				local downloadItem = {
					iconUrl = packItem.image,
					text = pg.getLocalizationText(packItem.name),
					packId = packId,
					order = packItem.order,
					partList = packItem.partList
				}

				downloadItems[#downloadItems + 1] = downloadItem
			end
		end

		table.sort(downloadItems, function(a, b)
			return (a.order or 0) < (b.order or 0)
		end)

		local setting = {
			tIndex = 6,
			label = pg.getLocalizationText(group.name),
			id = id,
			info = {
				funcType = "handlePackItemClick"
			},
			downloadItems = downloadItems
		}

		self:refreshWithRelation(setting)

		item.settingList[1] = setting

		if #downloadItems > 0 then
			itemList[#itemList + 1] = item
		end
	end

	return itemList
end

function SettingModel:addVideoSetting()
	local settingList = {}
	local configIds = {}

	for id in pairs(VideoSettingData) do
		configIds[#configIds + 1] = id
	end

	table.sort(configIds)

	for _, id in ipairs(configIds) do
		local config = VideoSettingData[id]
		local hideOnConsole = config.key == "videoQuality" and pg.game.setting:isConsolePlatform()

		if not hideOnConsole and config.isShow == 1 and config.valueType ~= "enum" and pg.game.setting:checkPlatform(config) and self:checkShowLogin(config) then
			local setting = {
				tIndex = 1,
				label = pg.getLocalizationText(config.name),
				info = {
					cate = "video",
					tab = "video",
					order = config.order,
					funcParam = {
						config.key
					},
					valueType = config.valueType,
					widgetParam = config.widgetParam,
					widgetTxt = config.widgetTxt
				}
			}

			if config.valueType == "bool" then
				setting.tIndex = 1
				setting.info.funcType = "commonVideoSettingBool"
				setting.info.widgetParam = {
					0,
					1
				}
			elseif config.valueType == "int" then
				setting.tIndex = 2
				setting.info.funcType = "commonVideoSettingInt"
			elseif config.valueType == "float" then
				setting.tIndex = 2
				setting.info.funcType = "commonVideoSettingFloat"
			elseif config.valueType == "enum" then
				setting.tIndex = 1
				setting.info.funcType = "commonVideoSettingEnum"
			end

			if config.showType then
				setting.tIndex = config.showType
			end

			if config.funcType then
				setting.info.funcType = config.funcType
			end

			if config.key == "videoQuality" then
				setting.tIndex = 1
				setting.info.funcType = "setVideoQuality"
			end

			self:refreshWithRelation(setting)
			table.insert(settingList, setting)
		end
	end

	return settingList
end

function SettingModel:getSettingInfosByFuncType(funcType)
	if not self.funcType2SettingInfos then
		self.funcType2SettingInfos = {}

		for _, settingInfo in pairs(SettingFuncListData) do
			if settingInfo.funcType then
				local settingInfos = self.funcType2SettingInfos[settingInfo.funcType]

				if not settingInfos then
					settingInfos = {}
					self.funcType2SettingInfos[settingInfo.funcType] = settingInfos
				end

				settingInfos[#settingInfos + 1] = settingInfo
			end
		end

		self.funcType2SettingInfos.setVideoQuality = {
			{
				cate = "video",
				tab = "video"
			}
		}
	end

	return self.funcType2SettingInfos[funcType]
end

function SettingModel:isSameSettingCate(settingInfo1, settingInfo2)
	if not settingInfo1 or not settingInfo2 then
		return false
	end

	return settingInfo1.tab == settingInfo2.tab and settingInfo1.cate == settingInfo2.cate
end

function SettingModel:hasSameCateSettingInfo(settingInfo, settingInfos)
	if not settingInfos then
		return false
	end

	for _, item in ipairs(settingInfos) do
		if self:isSameSettingCate(settingInfo, item) then
			return true
		end
	end

	return false
end

function SettingModel:refreshWithRelation(data)
	local settingInfo = data.info

	if not settingInfo or not settingInfo.funcType then
		return
	end

	local cfg = SettingSubToMainData[settingInfo.funcType]

	if not cfg then
		return
	end

	local mainKey = next(cfg)
	local mainInfos = self:getSettingInfosByFuncType(mainKey)

	if not self:hasSameCateSettingInfo(settingInfo, mainInfos) then
		return
	end

	data.isRelation = true
	data.mainFuncType = mainKey

	if data.tIndex == 1 then
		data.tIndex = 8
	elseif data.tIndex == 2 then
		data.tIndex = 7
	end
end

function SettingModel:checkShowLogin(setting)
	if self.openSource == self.OPEN_SOURCE.Login then
		return setting.showlogin == 1
	end

	return true
end

function SettingModel:checkSettingCanOpen(settingInfo)
	if settingInfo.channels and table.contains(settingInfo.channels, pg.global.sdkManager:getPkgChannel()) then
		return false
	end

	if ClientConfigAppCountry == "cn" and (settingInfo.funcType == ClientConst.SettingFuncType.Language or settingInfo.funcType == ClientConst.SettingFuncType.LanguageLogin) then
		return false
	end

	if settingInfo.funcType == "openExchangeCodeUI" and not CommonSwitch.EXCHANGE_GIFTCODE then
		return false
	end

	local isAccountBindSetting = settingInfo.funcType == ClientConst.SettingFuncType.MobileAccountBind or settingInfo.funcType == ClientConst.SettingFuncType.EmailAccountBind or settingInfo.funcType == ClientConst.SettingFuncType.SocialAccountBind

	if isAccountBindSetting and not SDKLoginConfig.isEnabled() then
		return false
	end

	if settingInfo.funcType == ClientConst.SettingFuncType.DlssState then
		return CS.FunPlus.WorldX.Setting.VideoSetting.IsDlssAvailable()
	elseif settingInfo.funcType == ClientConst.SettingFuncType.IsVietnamRealName then
		return ClientConfigGameChannelName == "vietnam" and pg.global.sdkManager:isClientIPCountry("VN")
	elseif settingInfo.funcType == ClientConst.SettingFuncType.MobileGamepadLayout then
		return pg.global.inputMgr:HasConnectedGamepadLikeDevice()
	elseif settingInfo.funcType == ClientConst.SettingFuncType.MobileAccountBind then
		return not Utils.isOverseas()
	elseif settingInfo.funcType == ClientConst.SettingFuncType.EmailAccountBind then
		return Utils.isOverseas()
	elseif settingInfo.funcType == ClientConst.SettingFuncType.SocialAccountBind then
		local socialType = settingInfo.funcParam and settingInfo.funcParam[1]

		return pg.global.sdkManager:isSocialTypeSupported(socialType)
	elseif settingInfo.funcType == ClientConst.SettingFuncType.UUNetwork then
		local UUBoosterManager = CS.FunPlus.WorldX.SDK.UU.UUBoosterManager

		return UUBoosterManager and UUBoosterManager.IsSupported and UUBoosterManager.IsSupported() == true
	end

	return true
end

function SettingModel:checkSettingPlatformOpen(settingInfo)
	if settingInfo.funcType == ClientConst.SettingFuncType.MobileGamepadLayout then
		return IS_MOBILE or ClientConfigInputPlatform == "Mobile"
	end

	return ClientUtils.checkIsOpenToCurPlatform(settingInfo)
end

function SettingModel:getSettingFuncListData()
	if self.openSource == self.OPEN_SOURCE.Login then
		local data = {}

		for _, setting in pairs(SettingFuncListData) do
			if setting.showlogin == 1 then
				if setting.funcType == "language" then
					local item = Lume.clone(setting)

					item.funcType = item.funcType .. "Login"

					table.insert(data, item)
				else
					table.insert(data, setting)
				end
			end
		end

		return data
	end

	return SettingFuncListData
end

SettingModel.showResetTab = {
	"video"
}

function SettingModel:checkShowReset(tab)
	return table.contains(self.showResetTab, tab)
end

SettingModel.haveBtnTab = {
	"video",
	"resource"
}

function SettingModel:checkHaveBtn(tab)
	return table.contains(self.haveBtnTab, tab)
end

return SettingModel
