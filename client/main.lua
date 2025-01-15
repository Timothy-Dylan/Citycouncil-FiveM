local main_config = require('config.main')
local mayor_config = require('config.mayor')

local spawnedPed = nil

--- Creates a Cityhall ped for the player to interact with
local function createCityHallPed()
    local pedConfig = main_config.City_Hall
    if not pedConfig or not next(pedConfig) then 
        error('City Hall Config is missing or empty')
        return
    end

    local point = lib.points.new({ coords = pedConfig.Location, distance = 50 })

    function point:onEnter()
        if spawnedPed then return end

        Debug('Entered City Hall Zone')

        -- * Get's the hash and loads model
        local hash = joaat(pedConfig.Ped)
        lib.requestModel(hash)

        -- * Create the Ped
        spawnedPed = CreatePed(4, hash, pedConfig.Location.x, pedConfig.Location.y, pedConfig.Location.z - 1.0, pedConfig.Location.w, false, false)
        SetBlockingOfNonTemporaryEvents(spawnedPed, true)
        SetEntityInvincible(spawnedPed, true)
        FreezeEntityPosition(spawnedPed, true)
        SetPedCanRagdollFromPlayerImpact(spawnedPed, false)
        SetPedCanPlayAmbientAnims(spawnedPed, true)
        SetPedDiesWhenInjured(spawnedPed, false)

        exports.ox_target:addLocalEntity(spawnedPed, {
            {
                label = 'Interact...',
                icon = 'fas fa-user',
                name = 'cityhall_main_ped',
                distance = 2.5,

                onSelect = function()
                    exports.mt_lib:showDialogue({
                        ped = spawnedPed,
                        label = 'Cityhall',
                        speech = 'What can I do for you?',
                        options = {
                            {
                                id = 'buy',
                                label = 'Buy Identity/Driver License',
                                icon = 'id-card',
                                close = true,
                                action = function()
                                    Shop:OpenMenu()
                                end
                            },

                            {
                                id = 'jobs',
                                label = 'City Jobs',
                                icon = 'briefcase',
                                close = true,
                                action = function()
                                    Jobs:OpenMenu()
                                end
                            },

                            {
                                id = 'close',
                                label = 'Close',
                                icon = 'times',
                                close = true,
                            }
                        }
                    })
                end
            }
        })

        SetModelAsNoLongerNeeded(hash)
    end

    function point:onExit()
        if not spawnedPed then return end
        DeleteEntity(spawnedPed)
        spawnedPed = nil
    end
end

local function createMayorTargets()
    if not mayor_config or not next(mayor_config) then 
        error('Mayor Config is missing or empty')
        return
    end

    for i = 1, #mayor_config.Targets do
        exports.ox_target:addSphereZone({
            coords = mayor_config.Targets[i].Location.xyz,
            name = ('%s'):format(i),
            radius = 1.0,
            debug = true,
            drawSprite = true,
            options = {
                {
                    label = 'Interact...',
                    icon = 'fas fa-user',
                    groups = mayor_config.Targets[i].Groups,
                    onSelect = mayor_config.Targets[i].OnSelect
                }
            }
        })
    end
end 

CreateThread(function()
    local _, error = pcall(function() createCityHallPed() end)
    if error then
        error('Error creating City Hall Ped: ' .. error)
    end

    local _, error = pcall(function() createMayorTargets() end)
    
    if error then
        error('Error creating Mayor Targets: ' .. error)
    end
end)