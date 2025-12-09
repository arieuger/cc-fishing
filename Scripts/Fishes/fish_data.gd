extends Resource
class_name FishData

@export var id: String = ""                    
@export var display_name: String = ""          
@export_multiline var description: String = "" 

@export var level: int = 1

@export var min_difficulty: float = 0.5                 
@export var max_difficulty: float = 3        

var used := false        
