Mayor = {}

local mayor_config = require('config.mayor')
local icons = {
    ['false'] = { icon = 'fa-solid fa-square-xmark', color = 'red'}, 
    ['true'] = { icon = 'fa-solid fa-square-check', color = 'green' }
}

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


function Mayor:OpenAppointmentMenu(appointmentData)
    if not self:IsAnMayor() then Debug('no mayor') return end

    if not appointmentData or not next(appointmentData) then return end

    lib.registerContext({
        title = ('%s'):format(appointmentData.title),
        id = 'appointment_menu',
        menu = 'mayor_appointments',
        options = {
            {
                title = 'Data;',
                description = ('Phone Number: %s \n Citizenid: %s \n Reason: %s'):format(appointmentData.phoneNumber, appointmentData.citizenid, appointmentData.description),
                readOnly = true
            },
            {
                title = 'Check off/not off',
                description = 'Check off the appointment',
                icon = 'fa-solid fa-check-to-slot',
                onSelect = function()
                    local status = appointmentData.done == 'false' and 'true' or 'false'
                    TriggerServerEvent('rd_citycouncil:event:server:changeAppointmentStatus', status, appointmentData.id)
                end
            }
        }
    })

    lib.showContext('appointment_menu')
end

--- Opens the appointment counter of the mayor, to see the appointments
function Mayor:OpenAppointmentCounter()
    -- check if the player is an mayor
    if not self:IsAnMayor() then Debug('no mayor') return end

    -- Request the appointments from the server
    local appointments = lib.callback.await('rd_citycouncil:cb:server:requestAppointments', false)
    if not appointments then 
        lib.notify({ title = 'No appointments', description = 'There are no appointments made with the mayor', type = 'info' })
        return 
    end

    local options = {}
    for i = 1, #appointments do
        Debug(appointments[i].done)
        options[#options+1] = {
            title = appointments[i].title,
            description = appointments[i].description,
            icon = icons[appointments[i].done].icon,
            iconColor = icons[appointments[i].done].color,
            onSelect = function()
                self:OpenAppointmentMenu(appointments[i])
            end
        }
    end

    -- Showes the appointments
    lib.registerContext({ id = 'mayor_appointments', title = 'Appointments', options = options })
    lib.showContext('mayor_appointments')
end

--- Creates an appointment counter where the player can create an appointment
function Mayor:CreateAppointmentCounter()
    if self:IsAnMayor() then
        lib.notify({ title = 'You are the Mayor', description = 'You can not create an appointment with yourself', type = 'error' })
        return
    end

    local hasAppointed = lib.callback.await('rd_citycouncil:cb:server:hasPlayerAnAppointment', false)
    -- check if the player has an appointment
    if hasAppointed then
        lib.notify({ title = 'You already have an appointment', description = 'You can only have one appointment at a time', type = 'error' })
        return
    end

    local input = lib.inputDialog('Create Appointment', {
        { type = 'textarea', label = 'Appointment description', description = 'About what do you want the appointment to be?', required = true, max = 50, icon = 'pencil', autosize = true  },
    })

    -- if there is no input then return
    if not input then return end

    -- Trigger the server event to create the appointment
    TriggerServerEvent('rd_citycouncil:event:server:createMayorAppointment', input[1])
end