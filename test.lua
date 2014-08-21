require "dotakv.main"
require "printtable"

teststr = [[{
	"hue" "br"
	"jaja" {
		"skill" "0"
		"noob" "1"
	}
}]]

print(
	KV:Dump(
		KV:Parse(
			teststr
		)
	)
)