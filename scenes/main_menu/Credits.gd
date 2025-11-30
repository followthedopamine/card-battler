extends RichTextLabel

func _on_meta_clicked(meta: Variant) -> void:
	print(meta)
	OS.shell_open(str(meta))
