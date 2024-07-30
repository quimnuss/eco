extends CanvasLayer

var history : Array[String]

var history_index : int = 0

@onready var cli_edit = $CenterContainer/CliEdit

signal change_species(island : int, species_name : String, growth : float, mutuality : Array[Array])

# Called when the node enters the scene tree for the first time.
func _ready():
    cli_edit.text_submitted.connect(process_command)

func _input(event):
    if history.is_empty():
        return
        
    if event.is_action_pressed('ui_up'):
        history_index += 1
    elif event.is_action_pressed('ui_down'):
        history_index -= 1
    elif event.is_action_pressed('ui_cancel'):
        history_index = -1
        cli_edit.clear()
        return

    if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
        if history_index <= -1:
            history_index = -1
            cli_edit.clear()
        else:
            history_index = clamp(history_index,0,len(history)-1)
            cli_edit.set_text(history[history_index])
        

func process_command(new_text : String):
    history_index = -1
    history.append(new_text)
    print(new_text)
    cli_edit.clear()
    
    var tokens : PackedStringArray = new_text.split(' ', false)
    if not tokens:
        return
    match tokens[0]:
        'mod':
            if len(tokens) > 4: # mod <island> <name> <growth> <mutuality : Array>
                var island : int = int(tokens[1])
                var species_name : String = tokens[2]
                var growth : float = float(tokens[3])
                var mutuality : Array = Array(tokens.slice(4)).map(to_float)
                change_species.emit(island, species_name, growth, mutuality)

func to_float(text : String):
    return float(text)
    
