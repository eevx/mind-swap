extends Action
class_name SwapAction

var character_data1 : CharacterObjectData
var command_type1 : int
var index1 : int

var character_data2 : CharacterObjectData
var command_type2 : int
var index2 : int

var duplicate_command_array1 = []
var duplicate_command_array2 = []

func _init(data1: CharacterObjectData, type1: int, id1: int, data2: CharacterObjectData, type2: int, id2: int):
	self.character_data1 = data1
	self.command_type1 = type1
	self.index1 = id1
	self.character_data2 = data2
	self.command_type2 = type2
	self.index2 = id2
	duplicate_command_array1 = character_data1.command_array.duplicate()
	duplicate_command_array2 = character_data2.command_array.duplicate()

func execute() -> bool:
	if index1 >= character_data1.command_array.size() or index2 >= character_data2.command_array.size():
		return false
	character_data1.command_array[index1] = command_type1
	character_data2.command_array[index2] = command_type2
	TurnManager.swaps_performed += 1
	SfxManager.play_sfx("swap")
	character_data1.command_array_changed.emit()
	character_data2.command_array_changed.emit()
	return true

func debug_action():
	return ["swapped", character_data1.command_type.find_key(command_type1), index1, character_data1.command_type.find_key(command_type2), index2]

func undo():
	character_data1.command_array = duplicate_command_array1
	character_data2.command_array = duplicate_command_array2
	character_data1.command_array_changed.emit()
	character_data2.command_array_changed.emit()
	TurnManager.swaps_performed -= 1
	SfxManager.play_sfx("swap")

#func swap_command(type : command_type, index: int):
	#if index >= command_array.size():
		#return
	#command_array[index] = type
	#command_array_changed.emit()
	#print("command swapped for ", ref_to_node, " at index ", index)
