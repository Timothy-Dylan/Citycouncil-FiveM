return {
    DeleteAppointmets = false, -- If true it will delete the COMPLETED appointments from the database on resource stop
    Targets = {
        [1] = {
            Location = vec3(-539.49, -204.44, 37.65), -- Location of the target
            Name = 'Appointment_Counter', -- Name of the target, not be confused with the label
            Groups = { 'mayor' }, -- Groups, that are allowed to interact with the target or just leave nil
            OnSelect = function()
                Mayor:OpenAppointmentCounter() -- Function to be called when the target is interacted with
            end
        },
    },

    Mayor_Job = {
        Job_Name = 'mayor',
        Grade = 2,
    },
}