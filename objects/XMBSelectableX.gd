class_name XMBSelectableX
extends Control
@export var iconImage:ImageTexture = ImageTexture.create_from_image(Image.load_from_file('res://images/icons/placeholder.png'))
@onready var icon = $icon
@onready var title = $title
@export var titleText:String = 'Template Title':
	set(v):
		titleText = v
		if title!= null:
			title.text = v
@onready var list:VBoxContainer:
	get:
		if get_children().filter(func(c): return c != icon && c != title).size() != 0:
			return get_children().filter(func(c): return c != icon && c != title)[0]
		return null
@onready var hasList = list!=null
var selected = false
func _ready():
	icon.texture = iconImage
	title.text = titleText
func _process(delta):
	modulate.a = 1 if selected else 0.5
	list.visible = selected
	title.visible = selected
