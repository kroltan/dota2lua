require "dotakv.main"
require "printtable"

teststr = [[{
	"hue" "br"
	"jaja\"" {
		"skill" "0"
		"noob" "1"
	}
	"as" "df"
}]]

PrintTable(KV:Parse(teststr))

print(
	KV:Dump(
		KV:Parse(
			teststr
		)
	)
)