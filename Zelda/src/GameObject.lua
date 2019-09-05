--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    self.frames = def.frames or {}
    self.potFrame = def.defaulPotFrame   -- used by pot object only
    self.inMotion = false
    self.room = def.room    -- reference to room for pots in motion
    self.projectileTimer = 0
    self.bumped = false

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    self.collidable = def.collidable
    self.consumable = def.consumable
    self.solid = def.solid
    self.onConsume = def.onConsume

    -- default empty collision callback
    self.onCollide = function()
    end
end

function GameObject:collides(target)
    return not (target.x > self.x + self.width or self.x > target.x + target.width or
            target.y > self.y + self.height or self.y > target.y + target.height)
end

function GameObject:update(dt)
    if self.inMotion then
        self.projectileTimer = self.projectileTimer + dt
        if self.projectileTimer >= 1 then
            -- Update frame to shatteredPotFrame after a pot travel 4 tiles
            local shatteredPotFrame = self.potFrame + 3
            self.potFrame = shatteredPotFrame
            gSounds['block-crash']:play()
            self.inMotion = false
            self.projectileTimer = 0
            -- Allowing 0.25 secs to show shattered pot be4 removing from gameplay
            Timer.after(0.25, function()
                    -- find projectile object and remove it from room after projectile time elapsed
                    for k, object in pairs(self.room.objects) do
                        if object == self then
                            table.remove(self.room.objects, k)
                            return
                        end
                    end
                end)
        end
        -- Wall Collision Check
        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE

        if self.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then 
            self.x = MAP_RENDER_OFFSET_X + TILE_SIZE
            self.bumped = true
        
        elseif  self.x + self.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
            self.x = VIRTUAL_WIDTH - TILE_SIZE * 2 - self.width
            self.bumped = true
            
        elseif self.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2 then 
            self.y = MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2
            self.bumped = true

        elseif self.y + self.height >= bottomEdge then
            self.y = bottomEdge - self.height
            self.bumped = true
        end

        for k, object in pairs(self.room.objects) do
            if object == self and self.bumped then
                self.inMotion = false
                self.projectileTimer = 0
                gSounds['block-crash']:play()
                table.remove(self.room.objects, k)
                return
            end
        end

        -- Entity Collision Check
        for k, entity in pairs(self.room.entities) do
            if self:collides(entity) then
                entity:damage(1)
                gSounds['hit-enemy']:play()
                
                -- find projectile object and remove it from room
                for k, object in pairs(self.room.objects) do
                    if object == self then
                        self.inMotion = false
                        self.projectileTimer = 0
                        table.remove(self.room.objects, k)
                        return
                    end
                end
            end
        end
    end
end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    if self.type == 'switch' then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
            self.x + adjacentOffsetX, self.y + adjacentOffsetY)
    elseif self.type == 'heart' then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
    elseif self.type == 'pot' then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frames[self.potFrame]],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
    end
end