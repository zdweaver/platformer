	player = {}
	player.sprites = {}
	player.activeSprite = nil

	player.x = 30
	player.y = 720 - 100
	player.next_x = nil
	player.next_y = nil

	player.xSpeed = 0
	player.ySpeed = 0
	player.width = 15
	player.height = 15
	player.color = {190,190,190}

	player.facingDirection = "right"
	
	--stats--
	player.HP = 100
	player.MP = 100
	player.exp = 0
	player.level = 1
	player.expToLevel = 2
	player.expModifier = 1.2
	player.hasLeveled = false
	player.strength = 5
	player.dexterity = 5
	player.intelligence = 5
	player.luck = 5
	
	player.weight = 5
	player.speed = 7
	player.maxSpeed = 10
	
	--jump stats--
	player.jumpButton = "z"
	player.canJump = false
	player.hasJumped = false 	--one-cycle flag
	player.isJumping = false
	player.fullJumpImpulse = 10 --const
	player.shortHopImpulse = 6  --const
	player.jumpImpulse = nil 	--value applied
	player.jumpSquat = 0.08333  --5 frames
	player.jumpSquatFrameTimer = 0
	player.hasEnteredJumpSquat = false
	player.jumpSquatBlobAmount = 1.3
	player.isTouchingFloor = false

	--fast fall stats
	player.fastFallSpeed = 8.5
	player.canFastFall = false
	player.fastFallActive = false
	
	--physics
	player.friction = 3

	--attacks
	player.attack = {}
	player.attack.button = "x"
	player.attack.damage = 4 + player.strength*1.2
	player.attack.hitbox = {x=0, y=0, width=40, height=10, xOffset = 17, yOffset = 0}
	player.attack.hitboxDuration = 0.05
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
	