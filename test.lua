require "dotakv.main"
require "printtable"

teststr = [[{
	"hue" "br" //comments r fun
	"jaja\"" {
		"skill" "0"
		"noob" "1"
	}
	"as" "df"
}]]

print(
	KV:Dump(
		KV:Parse(
			teststr
		)
	)
)