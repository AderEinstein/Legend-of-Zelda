--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {
                frame = 2
            },
            ['pressed'] = {
                frame = 1
            }
        }
    },

    ['heart'] = {
        type = 'heart',
        texture = 'hearts',
        frame = 5,
        width = 16,
        height = 16,
        solid = false,
        consumable = true,

        onConsume = function(player, object)
            gSounds['pickup']:play()
            player.health = math.min(6, player.health + 2) --Clamp player hearth to a maximum of 6
        end
    },

    ['pot'] = {
        type = 'pot',
        texture = 'tiles',
        defaultPotFrame = 1,
        frames = {
            [1] = 14,
            [2] = 15,
            [3] = 16,
            [4] = 52,
            [5] = 53,
            [6] = 54
        },
        width = 16,
        height = 16,
        solid = true,
        collidable = true,
    }
}