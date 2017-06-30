canJump = null
hero = null
onWall = null
layer = null
canDoubleJump = null

options = 
	gameWidth: 1000
	gameHeight: 800
	bgColor: 0x444444
	playerGravity: 900
	playerGrip: 100
	playerSpeed: 200
	playerJump: 400
	playerDoubleJump: 300

preload = ->
	game.stage.backgroundColor = options.bgColor
	game.scale.scaleMode = Phaser.ScaleManager.SHOW_ALL
	game.scale.pageAlighHorizontally = true
	game.scale.pageAlignVertically = true
	game.stage.disableVisibilityChange = true

	game.load.tilemap 'level', 'taito/level.json', null, Phaser.Tilemap.TILED_JSON
	game.load.image 'tile', 'taito/tile.png'
	game.load.image 'hero', 'taito/hero.png'

create = ->
	game.physics.startSystem Phaser.Physics.ARCADE
	map = game.add.tilemap 'level'
	map.addTilesetImage 'tileset01', 'tile'
	map.setCollision 1
	layer = map.createLayer 'layer01'
	hero = game.add.sprite 300, 376, 'hero'
	hero.anchor.set 0.5
	game.physics.enable hero, Phaser.Physics.ARCADE
	hero.body.gravity.y = options.playerGravity
	hero.body.velocity.x = options.playerSpeed
	canJump = true
	canDoubleJump = false
	onWall = false
	game.input.onDown.add handleJump, this
	game.world.setBounds 0, 0, 1920, 1440
	game.camera.follow hero, Phaser.Camera.FOLLOW_PLATFORMER, 0.1, 0.1

update = ->
	setDefaultValues()
	game.physics.arcade.collide hero, layer, heroToLayer, null, this

handleJump = ->
	if (canJump and hero.body.blocked.down) or onWall
		hero.body.velocity.y = -options.playerJump
		if onWall
			setPlayerXVelocity true
		canJump = false
		onWall = false
		canDoubleJump = true
	else
		if canDoubleJump
			canDoubleJump = false
			hero.body.velocity.y = -options.playerDoubleJump

setPlayerXVelocity = (defaultDirection) ->
	direction = if defaultDirection then 1 else -1
	hero.body.velocity.x = options.playerSpeed * hero.scale.x * direction

setDefaultValues = ->
	hero.body.gravity.y = options.playerGravity
	onWall = false
	setPlayerXVelocity true

heroToLayer = (hero, layer) ->
	blockedDown = hero.body.blocked.down
	blockedLeft = hero.body.blocked.left
	blockedRight = hero.body.blocked.right
	canDoubleJump = false
	if blockedDown
		canJump = true
	if blockedRight
		hero.scale.x = -1
	if blockedLeft
		hero.scale.x = 1
	if (blockedRight or blockedLeft) and not blockedDown
		onWall = true
		hero.body.gravity.y = 0
		hero.body.velocity.y = options.playerGrip
	setPlayerXVelocity not onWall or blockedDown

@game = new Phaser.Game options.gameWidth, options.gameHeight, Phaser.AUTO, 'container',
	preload: preload, create: create, update: update
