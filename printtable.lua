function PrintTable(tbl, pad)
	local pad = pad or 0
	local function indentPrint(msg, msg2)
		local tab = ""
		for i = 0, pad do
			tab = tab .. "\t"
		end
		if msg2 then
			print(tab, msg, msg2)
		else
			print(tab, msg)
		end
	end

	indentPrint(tbl)
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			PrintTable(v, pad+1)
		else
			indentPrint(k, v)
		end
	end
end
