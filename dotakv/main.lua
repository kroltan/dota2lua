if KV == nil then
	local function contains(table, element)
		for _, value in pairs(table) do
			if value == element then
				return true
			end
		end
		return false
	end

	local chars = {
		indent = "\t",
		escape = "\\",
		delim = '"',
		commentStart = "/",
		commentEnd = {"\n", "\r"},
		blockStart = "{",
		blockEnd = "}"
	}

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
			if i > jump then -- skips characters when under the jump
				local prev = str:sub(i-1,i-1) 
				local peek = str:sub(i+1,i+1)
				local char = str:sub(i,i)
				local remain = str:sub(i, #str) -- everything still unprocessed, including the current char
				local iterresult = iterator(char, prev, peek, remain, i) -- calls the iterating function
				if type(iterresult) == "number" then
					jump = i + iterresult -- if the function returns a number, skip that many characters
				elseif iterresult == false then
					return remain -- if the function returns false, stop iteration and return the remaining
				end
			end
		end
	end

	function parse_string(str)
		local stringmode = false
		local result = ""
		local remain = iterate_chars(str, function(char, prev, peek)
			if char == chars.escape then -- separate check so escape backslashes don't get processed
				if peek == chars.delim then
					result = result .. peek -- escape for \", allowing quotes inside strings
				end
			elseif char == chars.delim then
				if prev ~= chars.escape then
					-- if it's a quote that is not escaped...
					if stringmode then
						return false -- stops iteration when the closing quote is found
					else
						stringmode = true
					end
				end
			elseif stringmode then
				result = result .. char
			end
		end)
		-- result, remain, processed length
		return {result, remain, #result+2}
	end

	local function parse_block(str)
		-- parses a string, inserts the content into tbl and returns processed length
		local function parse_add_string(tbl, toparse)
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
			if char == chars.commentStart and peek == chars.commentStart then -- start comment
				commentmode = true
			elseif commentmode and contains(chars.commentEnd, char) then -- end comment
				commentmode = false
			elseif commentmode then
				-- just ignore...
			elseif not blockmode and char == chars.blockStart then -- block start detected
				blockmode = true
			elseif not char:match("%s") and char ~= chars.indent then -- non space char detected
				if blockmode then
					if char == chars.blockEnd then -- end of block detected
						blockmode = false
						return false
					elseif isKey then -- when on key mode, parse strings only
						isKey = false
						return parse_add_string(keyslist, remain)
					else
						isKey = true
						if char == chars.blockStart then -- values can also be blocks
							local data = parse_block(remain)
							table.insert(valuelist, data[1])
							return data[3]
						else -- in addition to strings
							return parse_add_string(valuelist, remain)
						end
					end
				end
			end
		end)

		-- joins the keys and values into one table
		for n, key in pairs(keyslist) do
			result[key] = valuelist[n]
		end
		-- result, remain, processed length 
		return {result, remain, #str-#remain}
	end

	local function serialize_block(tbl, indent)
		indent = indent or 0
		print(indent)
		local indentation = indent and indent ~= 0 and chars.indent:rep(indent) or "" -- for first level

		local result = chars.blockStart
		for k,v in pairs(tbl) do
			result = table.concat({result, '\n', indentation, chars.indent, chars.delim, k, chars.delim, " "}, "") -- Joins whitespace and key to the result
			if type(v) == "table" then -- Joins the value onto the result
				result = result .. serialize_block(v, indent + 1)
			else
				result = table.concat({result, chars.delim, tostring(v), chars.delim}, "")
			end
		end
		return table.concat({result, "\n", indentation, chars.blockEnd}, "") -- finally joins the closing character to the result
	end

	KV = {}
	function KV:Parse(str)
		return parse_block(str)[1] -- returns the parsed content
	end
	function KV:Dump(tbl)
		return serialize_block(tbl) -- returns the stringified table
	end
end