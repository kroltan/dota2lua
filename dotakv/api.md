#Usage

To use dotakv, you first have to `require` it. It uses the module pattern, 
so if it's installed on the folder "dotakv" inside your script directory:
```
scripts/
|-vscripts/
  |-myscript.lua
  |-dotakv/
    |-main.lua
```
Inside "myscript.lua", add the following at the top of your script:
```lua
local KV = require "dotakv.main"
```

#API

##:Parse(string)
Parses the given `string` into a standard Lua table.
```lua
local myTable = KV:Parse([[
"DOTAHeroes" {
	"npc_dota_hero_thunder_mario" {
		"override_hero"		"npc_dota_hero_zeus"
	}
}
]])
print(myTable.DOTAHeroes.npc_dota_thunder_mario)
```

##:Dump(name, table)
Makes a KV document out of the given `table`, under the root key `name`
```lua
local myString = KV:Dump("DOTAHeroes", {
	npc_dota_hero_thunder_mario = {
		override_hero = "npc_dota_hero_zeus"
	}
})
```

#The functions below seem to be non-functional in public games as of the last update

##:Load(file)
Convenience function to load a KV file from your addon's ./game/dota/ems
folder. Receives a filename to load. (no folders supported due to the
underlying Valve API limitations)
```lua
local myTable = KV:Load("preferences.txt")
print(myTable.Announcer.AllCaps)
```

##:Save(file, table)
Convenience function to save the given `table` to a file inside your addon's
./game/dota/ems folder. (no folders supported due to the underlying Valve 
API limitations)
```lua
KV:Save("preferences.txt", {
	Announcer = {
		AllCaps = true
	}
})
```