extends Resource
class_name Biome

@export var name :String
@export var biome_id:String
@export var weather : Weather

@export var hasDayNightCycle :bool = false

@export var warpArt : Texture2D

@export var topTextureVariants :Array[Texture2D]
@export var bottomTexturesVariants:Array[Texture2D]


@export var enemiesList : Array[SpawnEntry]
@export var itemDropsList : Array[SpawnEntry]
@export var objectsList : Array[SpawnEntry]

@export var locatablesList : Array[LocatableSpawnable]
@export var nearbyBiomesList :Array[BiomeSpawnEntry]
