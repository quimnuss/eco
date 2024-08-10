extends Node

func _input(event):
    if event.is_action_pressed("take_screenshot"):
        var filename = take_screenshot()
        filename = filename.replace('user:/', OS.get_user_data_dir())
        print(filename)

func take_screenshot():

    var capture = get_viewport().get_texture().get_image()

    var _time = Time.get_datetime_string_from_system()

    var filename = "user://eco-screenshot-{0}.png".format({"0":_time})

    capture.save_png(filename)
    return filename
