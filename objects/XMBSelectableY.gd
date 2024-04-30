@tool
class_name XMBSelectableY
extends Control

@export var iconImage:ImageTexture = ImageTexture.create_from_image(Image.load_from_file('res://images/icons/placeholder.png'))
@export var titleText:String = 'Template Title':
	set(v):
		titleText = v
		if title!= null:
			title.text = v
@export var titleDescription:String = 'Template Description':
	set(v):
		titleDescription = v
		if description!= null:
			description.text = v

@onready var icon = $icon
@onready var title = $title
@onready var description = $description
var selected = false
func _ready():
	icon.texture = iconImage
	title.text = titleText
	description.text = titleDescription
func _process(delta):
	modulate.a = 1 if selected else 0.5
func _unhandled_key_input(event):
	if Input.is_action_just_pressed('ui_accept') && selected:
		_enter_func()
func _enter_func():
	print('i did it!!')
	# for special things to plug into
	pass
