local mayor_config = require('config.mayor')

local function IsAnMayor()
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return end

    if Player.PlayerData.job.name == mayor_config.Mayor_Job.Job_Name and Player.PlayerData.job.grade.level == mayor_config.Mayor_Job.Grade then
        return true
    end

    return false
end

local function hasPlayerAnAppointment(source)
    if IsAnMayor() then return end

    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return end

    local db_query = MySQL.query.await('SELECT * FROM citycouncil_appointments WHERE citizenid = @citizenid', { 
        ['@citizenid'] = Player.PlayerData.citizenid
     })

    if next(db_query) == nil then return false end

    return {
        title = ('%s - %s'):format(db_query[1].id, db_query[1].charname),
        description = db_query[1].details,
        phoneNumber = db_query[1].phonenumber,
        citizenid = db_query[1].citizenid,
        done = db_query[1].isDone,
        id = db_query[1].id
    }
end


local function getMayorAppointments()
    if not IsAnMayor() then return end

    -- Gets the DB_query and data in the DB
    local db_query = MySQL.query.await('SELECT * FROM citycouncil_appointments')
    local appointments = {}

    for i = 1, #db_query do
        appointments[#appointments+1] = {
            title = ('%s - %s'):format(db_query[i].id, db_query[i].charname),
            description = db_query[i].details,
            phoneNumber = db_query[i].phonenumber,
            citizenid = db_query[i].citizenid,
            done = db_query[i].isDone,
            id = db_query[i].id
        }
    end

    -- Check if there are no appointments
    if next(appointments) == nil then return nil end

    return appointments
end

lib.callback.register('rd_citycouncil:cb:server:requestAppointments', function(_)
    return getMayorAppointments()
end)

lib.callback.register('rd_citycouncil:cb:server:hasPlayerAnAppointment', function(source)
    return hasPlayerAnAppointment(source)
end)



RegisterNetEvent('rd_citycouncil:event:server:createMayorAppointment', function(inputText)
    local src = source

    -- Check if the player has an Appointment
    if hasPlayerAnAppointment(src) then
        TriggerClientEvent('ox_lib:notify', src, { title = 'You already have an appointment', description = 'You can not create another appointment', type = 'error' })
        return
    end

    local Player = exports.qbx_core:GetPlayer(src)

    local db_input = MySQL.insert.await('INSERT INTO citycouncil_appointments (charname, citizenid, phonenumber, details, isDone) VALUES (@charname, @citizenid, @phonenumber, @details, @isDone)', {
        ['@charname'] = ('%s %s'):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname),
        ['@citizenid'] = Player.PlayerData.citizenid,
        ['@phonenumber'] = Player.PlayerData.charinfo.phone,
        ['@details'] = inputText,
        ['@isDone'] = 0
    })


    -- Check if the query is successful
    if db_input then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Appointment Created', description = 'You have created an appointment', type = 'success' })
    end
end)

RegisterNetEvent('rd_citycouncil:event:server:changeAppointmentStatus', function(status, id)
    local src = source
    -- check if the player is an mayor
    if not IsAnMayor() then return end

    -- Update the status of the appointment
    local db_query = MySQL.update.await('UPDATE citycouncil_appointments SET isDone = @isDone WHERE id = @id', {
        ['@isDone'] = ('%s'):format(status),
        ['@id'] = id
    })

    -- Check if the query is successful
    if db_query then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Appointment Status Changed', description = 'You have changed the appointment status', type = 'success' })
    end
end)

if mayor_config.DeleteAppointmets then
    AddEventHandler('onResourceStop', function(resourceName)
        if (cache.resource ~= resourceName) then
            return
        end

        local appointments = getMayorAppointments()
        if not appointments then return end

        for i = 1, #appointments do
            if appointments[i].done == 'true' then
                local data_query = MySQL.query.await('DELETE FROM citycouncil_appointments WHERE id = @id', {
                    ['@id'] = appointments[i].id
                })
            end
        end
    end)
end