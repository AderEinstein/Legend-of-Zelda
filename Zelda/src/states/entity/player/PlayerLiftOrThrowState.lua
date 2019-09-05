PlayerLiftOrThrowState = Class{__includes = BaseState}

function PlayerLiftOrThrowState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon

    self.player.offsetY = 5
    self.player.offsetX = 0

    local direction = self.player.direction

    self.player:changeAnimation('lift_throw-' .. self.player.direction)
end

function PlayerLiftOrThrowState:enter(params)
    self.state = params.state -- Lift or Throw
    if self.state == 'throw' then
        self.projectile = params.projectile
    end

    self.player.currentAnimation:refresh()
    self.carry = false
end

function PlayerLiftOrThrowState:update(dt)
    
    if self.state == 'lift' then
        local potLifted = nil
        -- Determine if Player is lifting besides a pot
        for k, object in pairs(self.dungeon.currentRoom.objects) do
            if object.collidable and object:collides(self.player) then
                self.carry = true
                potLifted = object
                break
            elseif object.collidable and self.player.direction == 'down' then
                Event.on('objectDownCollision', function()
                    self.carry = true
                    potLifted = object
                end)
            end
        end
        if self.carry and self.state == 'lift' and self.player.currentAnimation.timesPlayed > 0 then
            self.player.currentAnimation.timesPlayed = 0
            self.player:changeState('idlePotCarrying', {pot = potLifted})
        elseif self.player.currentAnimation.timesPlayed > 0 then
            self.player.currentAnimation.timesPlayed = 0
            self.player:changeState('idle')
        end

        if love.keyboard.wasPressed('return') then
            self.player:changeState('liftOrThrow', {state = 'lift'})
        end
    else -- self.state == 'throw'
        local projected = false   --Flag for start of projection 
        if not projected then
            local projectileMotion = self.player.direction
            self.projectile.inMotion = true
            self.projectile.room = self.dungeon.currentRoom
            
            -- Project pot by tweening it 4 tiles away for 0.5 s
            -- Unless the pot would come in contact with a wall or entity,
            -- It will travel 4 tiles away and then shatter before dissapearing 
            if projectileMotion == 'left' then
                Timer.tween(0.5, {[self.projectile] = {x = self.projectile.x - TILE_SIZE * 3}})
            elseif projectileMotion == 'right' then
                Timer.tween(0.5, {[self.projectile] = {x = self.projectile.x + TILE_SIZE * 3}})
            elseif projectileMotion == 'up' then
                Timer.tween(0.5, {[self.projectile] = {y = self.projectile.y - TILE_SIZE * 3}})
            elseif projectileMotion == 'down' then
                Timer.tween(0.5, {[self.projectile] = {y = self.projectile.y + TILE_SIZE * 3}})
            end
            projected = true
        end
        if self.player.currentAnimation.timesPlayed > 0 then
            self.player:changeState('idle')
        end
    end
end

function PlayerLiftOrThrowState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))
end
