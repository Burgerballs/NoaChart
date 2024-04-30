extends Node2D

var selected:Vector2i = Vector2i(0,0) # hell yeah!!
@onready var xList = $HBoxContainer
var yList:
	get: return curSelectedX.list
var arrayX: 
	get: return $HBoxContainer.get_children()
var arrayY: 
	get: return yList.get_children()
var curSelectedX:
	get:
		return arrayX[selected.x]
var curSelectedY:
	get:
		return arrayY[selected.y]
var intendedX = 0;
var intendedY = 48;
func _ready():
	change_x(0)
func _unhandled_key_input(event):
	if Input.get_axis('ui_left', 'ui_right'):
		change_x(Input.get_axis('ui_left', 'ui_right'))
	if Input.get_axis('ui_down', 'ui_up'):
		change_y(Input.get_axis('ui_down', 'ui_up'))
func change_x(x:int):
	selected.x = wrapi(selected.x+x, 0, arrayX.size())
	curSelectedX.selected = true
	for i in arrayX:
		if i != curSelectedX:
			i.selected = false
	intendedX = (-selected.x) * 48 + (xList.get_theme_constant("separation") * -selected.x) + 60
	selected.y = 0
	intendedY = (-selected.y) * 48 + (yList.get_theme_constant("separation") * -selected.y) + 50
	yList.position.y = intendedY
	change_y(0)
func change_y(y:int):
	selected.y = wrapi(selected.y+y, 0, arrayY.size())
	curSelectedY.selected = true
	for i in arrayY:
		if i != curSelectedY:
			i.selected = false
	intendedY = (-selected.y) * 48 + (yList.get_theme_constant("separation") * -selected.y) + 50
func _physics_process(delta):
	xList.position.x = lerpf(xList.position.x, intendedX, 0.2-delta)
	yList.position.y = lerpf(yList.position.y, intendedY, 0.2-delta)
