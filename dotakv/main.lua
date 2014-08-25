if KV == nil then
	-- iterate_chars doc
	-- receives string to operate and a iterator func
	-- iterator is called for each character in the string (unless skip)
	-- iterator is called with current, previous and next chars, and also
	-- the remaining uniterated string
	-- iterator can return false to abort iteration, or return a number
	-- if iterator returns a number N, skips the next N chars.
	-- otherwise proceed normally
	function iterate_chars(str, iterator)
		local remaining = ""
		local jump = 0
		for i = 1, #str do
			if i > jump then
				local prev = str:sub(i-1,i-1)
				local peek = str:sub(i+1,i+1)
				local char = str:sub(i,i)
				local remain = str:sub(i, #str)
				local iterresult = iterator(char, prev, peek, remain, i)
				if type(iterresult) == "number" then
					jump = i + iterresult
				elseif iterresult == false then
					return remain
				end
			end
		end
	end

	function parse_string(str)
		local stringmode = false
		local result = ""
		local remain = iterate_chars(str, function(char, prev, peek)
			if char == "\\" then
				if peek == '"' then
					result = result .. peek
				end
			elseif char == '"' then
				if prev ~= "\\" then
					if stringmode then
						return false
					else
						stringmode = true
					end
				end
			elseif stringmode then
				result = result .. char
			end
		end)
		return {result, remain, #result+2}
	end

	local function parse_block(str)
		function parse_add_string(tbl, toparse)
			local data = parse_string(toparse)
			table.insert(tbl, data[1])
			return data[3]
		end
		local blockmode = false
		local commentmode = false
		local isKey = true
		local result = {}
		local keyslist = {}
		local valuelist = {}
		local remain = iterate_chars(str, function(char, prev, peek, remain)
			if char == "/" and prev == "/" then
				commentmode = true
			elseif commentmode and (char == "\r" or char == "\n") then
				commentmode = false
			elseif commentmode then
				print("cvomment", char)
			elseif not blockmode and char == "{" then
				blockmode = true
			elseif not char:match("%s") and char ~= "\t" then
				if blockmode then
					if char == "}" then
						blockmode = false
						return false
					elseif isKey then
						isKey = false
						return parse_add_string(keyslist, remain)
					else
						isKey = true
						if char == "{" then
							local data = parse_block(remain)
							table.insert(valuelist, data[1])
							return data[3]
						else
							return parse_add_string(valuelist, remain)
						end
					end
				end
			end
		end)
		for n, key in pairs(keyslist) do
			result[key] = valuelist[n]
		end
		return {result, remain, #str-#remain}
	end

	local function serialize_block(tbl, indent)
		local indent = indent or 0
		local indentChar = "\t"
		local indentation = ""
		for i = 0, indent-1 do
			indentation = indentation .. indentChar
		end

		local result = "{"
		for k,v in pairs(tbl) do
			result = table.concat({result, '\n', indentation, indentChar,'"', k, '" '}, "")
			if type(v) == "table" then
				result = result .. serialize_block(v, indent + 1)
			else
				result = table.concat({result, '"', tostring(v), '"'})
			end
		end
		return table.concat({result, "\n", indentation, "}"}, "")
	end

	KV = {}
	function KV:Parse(str)
		return parse_block(str)[1]
	end
	function KV:Dump(tbl)
		return serialize_block(tbl)
	end
end