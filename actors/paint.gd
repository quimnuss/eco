extends Sprite2D

var img_width = 100
var img_height = 100
var img = Image.create(img_width, img_height, false, Image.FORMAT_RGBA8)
const ALPHA : float = 0.5

#@export var color_palette : Array[Color] = [
    #Color("#bd0000", ALPHA), Color("#d7191c", ALPHA), Color("#e76818", ALPHA), Color("#f29e2e", ALPHA), Color("#f9d057", ALPHA), Color("#ffff8c", ALPHA),
    #Color("#90eb9d", ALPHA), Color("#00ccbc", ALPHA), Color("#00a6ca", ALPHA), Color("#2c7bb6", ALPHA), Color("#2c35b6", ALPHA),
#]

func _ready():
    self.texture = ImageTexture.create_from_image(img)

func distributed_random(cumsum : Array[float], total : float) -> int:
    var pin : float = randf()*total
    for idx : int in range(len(cumsum)):
        var piece : float = cumsum[idx]
        if pin <= piece:
            return idx
    return -1

var skipped_frames : int = 0
const MAX_SKIPPED_FRAMES : int = 10

func update_density(new_densities : Array[float]):
    skipped_frames += 1
    if skipped_frames < MAX_SKIPPED_FRAMES:
        return
    else:
        skipped_frames = 0

    if new_densities.is_empty():
        return
    var total : float = Util.sum(new_densities)
    var cumulative : Array[float] = Util.cumsum(new_densities)
    for x in img_width:
        for y in img_height:
            var species_index : int = distributed_random(cumulative, total)
            var color : Color = Util.gradient_color(float(species_index)/len(new_densities))
            color.a = 0.5
            img.set_pixel(x, y, color)

    self.texture.update(img)

func _on_glv_densities_update(new_densities):
    if process_mode != PROCESS_MODE_DISABLED:
        update_density(new_densities)
