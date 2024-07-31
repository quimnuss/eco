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
            
        
