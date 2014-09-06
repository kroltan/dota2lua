KV = require "dotakv.main"
require "printtable"

teststr = [["dotakvTest" {
	"key" "value"
	"otherKey" { //C-style "comments" "to break?"
		"moreKey" "moreValue"
		{"let's see" "if\n // breaks" } //should it?}
	} //no block comments!
	"let's see" "if // breaks"
}]]

tbl = KV:Parse(teststr)
print(tbl.dotakvTest.otherKey["let's see"])
print(KV:Dump("Yay", tbl))