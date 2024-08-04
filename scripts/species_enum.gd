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
