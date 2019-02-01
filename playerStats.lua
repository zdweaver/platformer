	player = {}
	player.sprites = {}
	player.activeSprite = nil

	player.x = 500
	player.y = 720
	player.next_x = nil
	player.next_y = nil

	player.xSpeed = 0
	player.ySpeed = 0
	player.width = 24
	player.height = 22
	player.color = {190,190,190}

	player.facingDirection = "right"
	
	--stats--
	player.HP = 100
	player.MP = 100
	player.exp = 0
	player.strength = 5
	player.dexterity = 5
	player.intelligence = 5
	player.luck = 5
	
	--exp and levels
	player.level = 1
	player.expToLevel = 4
	player.expModifier = 1.2
	player.hasLeveled = false
	
	--dash stats--
	player.dashSpeed = 3
	player.dashTimeLength = 0.45
	player.dashTimer = 0
	player.canDashRight = true
	player.canDashLeft = true
	player.hasBegunToDashLeft = false
	player.hasBegunToDashRight = false
	player.isDashingLeft = false
	player.isDashingRight = false
	
	--run stats--
	player.runSpeed = 3
	player.isRunning = false

	--jump stats--
	player.jumpButton = "space"
	player.canJump = false
	player.hasJumped = false 	--one-cycle flag
	player.isJumping = false
	player.fullJumpImpulse = 10 --const
	player.shortHopImpulse = 6  --const
	player.jumpImpulse = nil 	--value applied
	player.jumpSquat = 5/60  --frames
	player.jumpSquatFrameTimer = 0
	player.hasEnteredJumpSquat = false
	player.jumpSquatBlobAmount = 1.3
	player.isTouchingFloor = false

	--fast fall stats
	player.fastFallSpeed = 8.5
	player.canFastFall = false
	player.fastFallActive = false
	
	--physics
	player.friction = 4.5
	player.weight = 5
	player.speed = 10
	player.maxSpeed = 3.5

	--attacks
	player.attack = {}
	player.attack.damage = 4 + player.strength*1.2
	player.attack.hitbox = {x=0, y=0, width=70, height=30, xOffset = 17, yOffset = 0}
	player.attack.hitboxDuration = 0.1
	player.attack.hitboxTimer = 0
	player.attack.cooldown = 0.125
	player.attack.cooldownTimer = 0
	player.hasAttacked = false 	--one cycle flag
	player.canAttack = true --cycled with button release
	player.attack.hitbox.isActive = false
	player.attack.cooldownIsActive = false
	
	--taking damage
	player.hasAlreadyTakenDamage = false --one cycle flag
	player.hasTakenDamage = false --updates timer
	player.damageEffectTimer = 0
	player.damageEffectTimerMax = 0.75
	player.hasDied = false --one cycle flag
	
	--button inputs
	player.leftButton = "a"
	player.upButton = "w"
	player.rightButton = "d"
	player.downButton = "s"
	player.jumpButton = "space"
	player.attackButton = "j"
	
	--items (or equips)
	player.items = {}