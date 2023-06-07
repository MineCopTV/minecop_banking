-- Insert this code in place when you need to check card pay
ESX.TriggerServerCallback('minecop_banking:payCard', function(status)
    if status == 1 then
        -- Success
    else 
        -- Error
    end
end, price)