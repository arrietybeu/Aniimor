-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\CallbackHandler.lua

local function CallbackHandler(obj, methodName, ...)
	local args
	local n0 = select("#", ...)

	if n0 ~= 0 then
		args = {
			...
		}
	end

	return function(...)
		assert(obj ~= nil and obj[methodName] ~= nil)

		if obj ~= nil then
			local method = obj[methodName]

			if method ~= nil then
				local n1 = select("#", ...)

				if n0 + n1 == 0 then
					return method(obj)
				elseif n0 == 0 then
					return method(obj, ...)
				elseif n1 == 0 then
					return method(obj, unpack(args, 1, n0))
				else
					for i = 1, n1 do
						args[i + n0] = select(i, ...)
					end

					return method(obj, unpack(args, 1, n0 + n1))
				end
			end
		end
	end
end

return CallbackHandler
