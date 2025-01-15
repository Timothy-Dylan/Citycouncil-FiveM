local mayor_config = require('config.mayor')

local function IsAnMayor()
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return end

    if Player.PlayerData.job.name == mayor_config.Mayor_Job.Job_Name and Player.PlayerData.job.grade.level == mayor_config.Mayor_Job.Grade then
        return true
    end

    return false
end

lib.callback.register('rd_citycouncil:cb:server:requestAppointments', function(source)
    if not IsAnMayor() then return end

    -- Gets the DB_query and data in the DB
    local db_query = MySQL.query.await('SELECT * FROM citycouncil_appointments')
    local appointments = {}

    for i = 1, #db_query do
        appointments[#appointments+1] = {
            title = db_query[i].charname,
            description = db_query[i].details,
            phoneNumber = db_query[i].phone_number,
            citizenid = db_query[i].citizenid,
            done = db_query[i].isDone
        }
    end

    -- Check if there are no appointments
    if next(appointments) == nil then return nil end

    return appointments
end)   

