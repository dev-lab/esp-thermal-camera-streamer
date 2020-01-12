local z = ...

return function(c,p,u)
	package.loaded[z] = nil
	z = nil
	if u > 1 then
		require("rs")(c, 401)
		return
	end
	collectgarbage()
	local f = p.file
	local b = ""
	if not f then return b end
	node.output(function(s) b = b + s end, 0)
	node.input(f)
	tmr.alarm(4,2000,0,function()
		node.ouput(nil)
		require("rs")(c, 200, b)
	end)
end