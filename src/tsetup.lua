local z = ...

return function(c,p,u)
	package.loaded[z] = nil
	z = nil
	if u > 1 then
		require("rs")(c, 401)
		return
	end
	require("thermo")("S", function()
		require("rs")(c, 200, "Turn-off and then turn-on the power to complete setup.")
	end)
end
