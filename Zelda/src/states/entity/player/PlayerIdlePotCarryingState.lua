

PlayerIdlePotCarryingState = Class{__includes = EntityIdleState}

function PlayerIdlePotCarryingState:init(entity, dungeon)
    self.entity = entity
    self.dungeon = dungeon

    self.entity:changeAnimation('idlepotcarrying-' .. self.entity.direction)
end

function PlayerIdlePotCarryingState:enter(params)
    self.potLifted = params.pot
end

function PlayerIdlePotCarryingState:update(dt)
    EntityIdleState.update(self, dt)
    self.potLifted.x = self.entity.x
    self.potLifted.y = self.entity.y - 10
end

function PlayerIdlePotCarryingState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('potWalk', {pot = self.potLifted})
    end
    
    if love.keyboard.wasPressed('return') then
        self.entity:changeState('liftOrThrow', {state = 'throw',
                                                projectile = self.potLifted})
    end
end
