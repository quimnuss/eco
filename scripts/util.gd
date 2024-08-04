extends Node

func imax(array : Array) -> Array:
    var max_value : float = -INF
    var index : int = -1
    for i in range(len(array)):
        if array[i] > max_value:
            max_value = array[i]
            index = i
    var imax : Array
    imax.push_back(index)
    imax.push_back(max_value)
    return imax

func sum(array : Array[float]) -> float:
    var total : float = 0
    for el in array:
        total += el
    return total

func cumsum(array : Array[float]) -> Array[float]:
    var cumsum_array : Array[float]
    var total : float = 0
    for el in array:
        total += el
        cumsum_array.push_back(total)
    return cumsum_array

func zip(keys : Array, values : Array) -> Dictionary:
    if len(keys) != len(values):
        push_error('zip: Arrays must be of same size')
    var zipped : Dictionary
    for i in range(len(keys)):
        zipped[keys[i]] = values[i]
    return zipped

func gradient_color(ratio : float) -> Color:
    var color_palette : Array = [
        "#bd0000", "#d7191c", "#e76818", "#f29e2e", "#f9d057", "#ffff8c",
        "#90eb9d", "#00ccbc", "#00a6ca", "#2c7bb6", "#2c35b6"
    ]
    var color_a : Color = color_palette[floor(ratio*10)]
    var color_b : Color = color_palette[ceil(ratio*10)]
    var sub_color_ratio : float = (ratio*10 - floor(ratio*10))
    return color_a * sub_color_ratio + (1-sub_color_ratio) * color_b
