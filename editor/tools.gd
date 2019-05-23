tool
const MENUS = {
	"Open user://": 0,
}

func initialize(plugin):
	for key in MENUS:
		plugin.add_tool_menu_item(key, self, '_on_menu_pressed', MENUS[key])

func _on_menu_pressed(action):
	match action:
		0:
			OS.shell_open(str('file://', OS.get_user_data_dir()))
