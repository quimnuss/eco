extends TextureButton
class_name SpeciesTextureButton
@export var species_enum : Species.SpeciesEnum

const texture_width := 1152

const texture_num_h_frames := 16

func _ready():
    self.texture_normal = AtlasTexture.new()
    self.texture_normal.atlas = load("res://assets/animals_nature.png")

    var frame : int = Species.species_frame[species_enum]
    var atlas_coords = Vector2i(frame % texture_num_h_frames, int(frame/texture_num_h_frames))
    self.texture_normal.region = Rect2(atlas_coords.x*72, atlas_coords.y*72, 72, 72)
    #prints(Species.name_enum.keys()[species_enum+1], species_enum,  frame, atlas_coords, self.texture_normal.region)

