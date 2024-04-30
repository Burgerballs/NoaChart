class_name PingasFormat
extends Resource
## for eventual compat problems
@export var version:int = 1

@export var notes:Array = [] ## [position, sustime, key, type]
@export var name:String = 'Pingas Song'
@export var data_name:String = 'pingas_song'
@export var artist:String = 'Doctor Ivo Robotnik'
@export var quote:String = 'SnooPING AS usual I see?'
@export var source:String = 'The Adventures Of Sonic The Hedgehog'

@export var events:Array = [] ## [name, position, [param1,param2,param3,etc]]
@export var bpm_times:Array = [] ## [position, bpm]
@export var start_bpm:float = 100.0 ## im bored

@export var skill:int = 1 ## they don't know this means nothing i just like meaningless numbers
