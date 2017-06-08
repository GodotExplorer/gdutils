tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("AutoLayoutControl", "Control", preload("scene/gui/AutoLayoutControl.gd"), null)

func _exit_tree():
	remove_custom_type("AutoLayoutControl")
