extends TextureButton

@export var radius = 120
@export var speed = 0.25

var tween : Tween

var num
var active = false

func _ready():
    $Buttons.hide()
    num = $Buttons.get_child_count()
    for b in $Buttons.get_children():
        b.global_position = global_position

func _on_StartButton_pressed():
    disabled = true
    if active:
        hide_menu()
    else:
        show_menu()

func _on_Tween_tween_all_completed():
    disabled = false
    active = not active
    if not active:
        $Buttons.hide()

func show_menu():
    var spacing = TAU / num
    for b in $Buttons.get_children():
        # Subtract PI/2 to align the first button  to the top
        var a = spacing * b.get_position_in_parent() - PI / 2
        var dest = b.rect_position + Vector2(radius, 0).rotated(a)
        tween.interpolate_property(b, "position",
                b.position, dest, speed,
                Tween.TRANS_BACK, Tween.EASE_OUT)
        tween.interpolate_property(b, "scale",
                Vector2(0.5, 0.5), Vector2.ONE, speed,
                Tween.TRANS_LINEAR)
    $Buttons.show()
    tween.play()

func hide_menu():
    for b in $Buttons.get_children():
        tween.interpolate_property(b, "position", b.position, position, speed, Tween.TRANS_BACK, Tween.EASE_IN)
        tween.interpolate_property(b, "scale", null, Vector2(0.5, 0.5), speed, Tween.TRANS_LINEAR)
    tween.play()
