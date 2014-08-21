dota2lua
========

Publicly available snippets for Dota 2 Workshop Tools! 
Feel free to contribute your own too. (Just Fork+PR, like always)

##printtable
Simple debugging function that can be either required or 
copy-pasted on files, prints the given table to the console
in a nice nested view.

##dotakv
Package to convert between tables and strings using 
Dota 2's key-value format (the same used on map editing)
Deserialize using `sometable = KV:Parse(somestr)` and
serialize using `somestr = KV:Dump(sometable`.
Useful for using together with `FileToString` and `StringToFile`.

```lua
mytable = {
	a = "b",
	somekey = {
		supports = "nesting",
		doesnt = "nil"
	}
}
mystring = [[
{
	"PackageInfo" "Cool Parser"
	"Supports" "Almost everything" //including comments
	//anywhere.
	"AndObviously" {
		"Nesting" "1"
	}
}
]]
print(KV:Dump(mytable))
PrintTable(KV:Parse(mystring))
```