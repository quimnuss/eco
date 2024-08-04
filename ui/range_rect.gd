extends TextureRect
class_name RangeRect

var index_i : int
var index_j : int

var max_value : float
var value : float

@export var increments : float = 0.001
@onready var label = $Label

var is_growth : bool = false

signal change_mutuality(index_i: int, index_j : int, new_value : float)
signal change_growth(index_i : int, new_value : float)

func _ready():
    self.label.set_text("%d" % (self.value*1000))
    self.set_tooltip_text("%0.4f" % (self.value*1000))

func change_max_value(new_max_value : float):
    self.max_value = new_max_value
    self.set_color(self.value)

func set_color(new_value : float):
    if abs(new_value) < 0.0001:
        self.modulate = Color.GRAY
        self.value = 0
        self.label.set_text("0")
        return
    var ratio = (clamp(new_value/max_value,-1.0,1.0)+1.0)/2.0
    var g_color : Color = Util.gradient_color(ratio)
    self.set_modulate(g_color)
    self.value = new_value
    self.label.set_text("%d" % (self.value*1000))
    self.set_tooltip_text("%0.4f" % (self.value*1000))
    #if is_instance_valid(ctooltip):
        #ctooltip.set_text("%0.4f" % (self.value*1000))
        #ctooltip.set_tooltip_text("%0.4f" % (self.value*1000))

func get_value():
    return self.value
#var ctooltip : Label
#
#func _make_custom_tooltip(for_text):
    #ctooltip = Label.new()
    ##ctooltip.set_text("%0.3f" % (self.value*1000))
    ##ctooltip.text = for_text
    #return ctooltip

func _gui_input(event):
    if event is InputEventMouseButton and event.is_pressed():
        if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            if event.button_index == MOUSE_BUTTON_WHEEL_UP:
                self.value += increments
            elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                self.value -= increments
            self.set_color(self.value)
            if is_growth:
                change_growth.emit(index_i, self.value)
            else:
                change_mutuality.emit(index_i, index_j, self.value)

