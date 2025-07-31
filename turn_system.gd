extends Node
class_name turn_system

var turn_inventory := ["Walk","Left","Right","Shoot"]
@export var turns := {"Walk":true , "Left": true, "Right": false, "Shoot": false}
var pointer : int = 0

func mob_current_turn() -> String:
	var current_selected_turns = mob_current_turn()
	#turn script files here
	#temp. testing starts here
	next_turn()
	

func mob_turn_inventory() -> Array:
	if get_parent() is CharacterBody2D:
		var current_selected_turns : Array
		for key in turns:
			if turns[key] == true:
				current_selected_turns.append(key)
		return current_selected_turns
	else:
		return []
		
func next_turn():
	pointer+= 1
