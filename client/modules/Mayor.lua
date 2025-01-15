Mayor = {}

local mayor_config = require('config.mayor')

--- Check to see if the player is a Mayor
--- @return boolean | true if the player is a Mayor, false otherwise
function Mayor:IsAnMayor()
    -- Check if the player is an mayor
    local PlayerData = QBX.PlayerData

    -- Check if the player data exists
    if not PlayerData then return false end -- Check if exists

    Debug('job ', PlayerData.job.name == mayor_config.Mayor_Job.Job_Name)
    Debug('grade', PlayerData.job.grade.level == mayor_config.Mayor_Job.Grade)

    -- Check if the player is an mayor
    if PlayerData.job.name == mayor_config.Mayor_Job.Job_Name and PlayerData.job.grade.level == mayor_config.Mayor_Job.Grade then
        return true -- is an mayor  
    end

    return false -- not mayor
end

--- Opens the appointment counter of the mayor, to see the appointments
function Mayor:OpenAppointmentCounter()
    -- check if the player is an mayor
    if not self:IsAnMayor() then Debug('no mayor') return end

    -- Request the appointments from the server
    local appointments = lib.callback.await('rd_citycouncil:cb:server:requestAppointments', false)
    if not appointments then Debug('No Appointments') return end

    local options = {}

    for i = 1, #appointments do
        options[#options+1] = {
            title = appointments[i].title,
            description = appointments[i].description,
            onSelect = function()
                Debug('Selected Appointment; ', appointments[i])
            end
        }
    end

    -- Showes the appointments
    lib.registerContext({ id = 'mayor_appointments', title = 'Appointments', options = options })
    lib.showContext('mayor_appointments')
end

--- Creates an appointment counter where the player can create an appointment
function Mayor:CreateAppointmentCounter()
    print('Create Appointment Counter')
end