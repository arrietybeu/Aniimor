-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils\\UIPlayerAvatarUtils.lua

local PlayerHeadIconData = require("Data.player_head_icon_data")
local PlayerHeadFrameData = require("Data.player_head_frame_data")

return function(LuaUIUtils)
	function LuaUIUtils.renderPlayerAvatarImages(widget, data, forceVisibility)
		local objectReference = widget:GetComponent("ObjectReference")

		if not objectReference then
			return
		end

		data.avatarIconId = data.avatarIconId or data.playerInfo.headIcon
		data.avatarFrameIconId = data.avatarFrameIconId or data.playerInfo.headFrame

		local avatarUImage = objectReference:GetRefValue("avatarUImage")
		local avatarFrameUImage = objectReference:GetRefValue("avatarFrameUImage")
		local headFrameUContainer = objectReference:GetRefValue("headFramUContainer")
		local avatarIconData = PlayerHeadIconData[data.avatarIconId or 1]
		local avatarFrameData = PlayerHeadFrameData[data.avatarFrameIconId or 1]
		local showAvatar = data.showAvatar ~= false
		local showAvatarFrame = data.showAvatarFrame ~= false

		if avatarUImage then
			avatarUImage.url = avatarIconData.res

			if forceVisibility or data.showAvatar ~= nil then
				avatarUImage:SetActive(showAvatar)
			end
		end

		if avatarFrameData.isDynamic == 1 and headFrameUContainer then
			if avatarFrameUImage then
				avatarFrameUImage.url = ""

				avatarFrameUImage:SetActive(false)
			end

			headFrameUContainer:SetActive(showAvatarFrame)

			if showAvatarFrame then
				local frameUrl = avatarFrameData.res

				if not headFrameUContainer:CheckURLLoaded(frameUrl) then
					headFrameUContainer:SetUrlWithCallback(frameUrl, function(content)
						if content and not IsNil(content) and headFrameUContainer.url == frameUrl then
							content:SetActive(true)
						end
					end)
				end
			end
		else
			if headFrameUContainer then
				headFrameUContainer:DestroyContent()
				headFrameUContainer:SetActive(false)
			end

			if avatarFrameUImage then
				avatarFrameUImage.url = avatarFrameData.res

				avatarFrameUImage:SetActive(showAvatarFrame)
			end
		end
	end
end
