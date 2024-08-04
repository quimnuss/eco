extends Sprite2D

var img_width = 100
var img_height = 100
var img = Image.create(img_width, img_height, false, Image.FORMAT_RGBA8)
const ALPHA : float = 0.5

#@export var color_palette : Array[Color] = [
    #Color("#bd0000", ALPHA), Color("#d7191c", ALPHA), Color("#e76818", ALPHA), Color("#f29e2e", ALPHA), Color("#f9d057", ALPHA), Color("#ffff8c", ALPHA),
    #Color("#90eb9d", ALPHA), Color("#00ccbc", ALPHA), Color("#00a6ca", ALPHA), Color("#2c7bb6", ALPHA), Color("#2c35b6", ALPHA),
#]

const BACKGROUND_COLOR : Color = Color(0.745098, 0.745098, 0.745098, 0.5)

func _ready():
    img.fill(BACKGROUND_COLOR)
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
    var total : float = max(Util.sum(new_densities), 50)


    var species_index : int = 0
    var row : float = 0
    for d in new_densities:
        var color : Color = Util.gradient_color(float(species_index)/len(new_densities))
        var num_pixel_rows : int = int(img_height * d/total)
        img.fill_rect(Rect2i(Vector2i(0,row), Vector2i(img_width, num_pixel_rows)), color)
        species_index += 1
        row += num_pixel_rows
    img.fill_rect(Rect2i(Vector2i(0, row), Vector2i(img_width, img_height-row)), BACKGROUND_COLOR)
    self.texture.update(img)

func _on_glv_densities_update(new_densities):
    if process_mode != PROCESS_MODE_DISABLED:
        update_density(new_densities)
