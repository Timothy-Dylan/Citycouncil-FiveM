return {
    Targets = {
        [1] = {
            Location = vec3(-539.49, -204.44, 37.65), -- Location of the target
            Name = 'Appointment_Counter', -- Name of the target, not be confused with the label
            Groups = { 'mayor' }, -- Groups, that are allowed to interact with the target or just leave nil
            OnSelect = function()
                Mayor:OpenAppointmentCounter() -- Function to be called when the target is interacted with
            end
        },

        [2] = {
            Location = vec3(-546.96, -206.56, 38.22),
            Name = 'Appointment_Making',
            OnSelect = function()
                Mayor:CreateAppointmentCounter()
            end
        }
    },

    Mayor_Job = {
        Job_Name = 'mayor',
        Grade = 2,
    },
}