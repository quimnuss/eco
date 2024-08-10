extends Node
class_name Species
enum SpeciesEnum {
    NONE=-1,
    BEAR,
    RABBIT,
    CARROT,
    WOLF,
    BEE,
    BERRY,
    BIRD,
    FISH,
    FOX,
    GRASS,
    TREE,
    WORM,
    ALGAE
}

const name_enum : Dictionary = {
    'none': Species.SpeciesEnum.NONE,
    'bear' : Species.SpeciesEnum.BEAR,
    'rabbit' : Species.SpeciesEnum.RABBIT,
    'carrot' : Species.SpeciesEnum.CARROT,
    'wolf' : Species.SpeciesEnum.WOLF,
    'bee' : Species.SpeciesEnum.BEE,
    'berry' : Species.SpeciesEnum.BERRY,
    'bird' : Species.SpeciesEnum.BIRD,
    'fish' : Species.SpeciesEnum.FISH,
    'fox' : Species.SpeciesEnum.FOX,
    'grass' : Species.SpeciesEnum.GRASS,
    'tree' : Species.SpeciesEnum.TREE,
    'worm' : Species.SpeciesEnum.WORM,
    'algae' : Species.SpeciesEnum.ALGAE
}

static var species_frame : Dictionary = { # [Species : enum, frame : int]
    Species.SpeciesEnum.NONE:-1,
    Species.SpeciesEnum.BEAR:51,
    Species.SpeciesEnum.RABBIT:47,
    Species.SpeciesEnum.CARROT:150,
    Species.SpeciesEnum.WOLF:9,
    Species.SpeciesEnum.BEE:99,
    Species.SpeciesEnum.BERRY:141,
    Species.SpeciesEnum.BIRD:67,
    Species.SpeciesEnum.FISH:89,
    Species.SpeciesEnum.FOX:10,
    Species.SpeciesEnum.GRASS:119,
    Species.SpeciesEnum.TREE:121,
    Species.SpeciesEnum.WORM:107,
    Species.SpeciesEnum.ALGAE:143
}
