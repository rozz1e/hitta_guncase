local onHand, inAnimation = false, false, false

RegisterNetEvent('hitta_guncase:openMenu')
AddEventHandler('hitta_guncase:openMenu', function()
    openMenu()
end)

openMenu = function()
    if not onHand then
        lib.registerContext({
            id = 'guncase',
            title = 'Choose',
            options = {
                {
                    title = 'Hold on hand',
                    description = 'Hold the guncase on your hand',
                    icon = 'hand',
                    onSelect = function()
                        if Config.PullFromBack then
                            animDict('reaction@intimidation@1h')
                            TaskPlayAnimAdvanced(PlayerPedId(), 'reaction@intimidation@1h', 'intro', GetEntityCoords(PlayerPedId(), true), 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
                            Wait(2000)
                        end

                        deleteObject(closeCase)
                        animDict('move_weapon@jerrycan@generic')
                        playAnim(PlayerPedId(), 'move_weapon@jerrycan@generic', 'idle')
                        local playerPed = PlayerPedId()
                        local x, y, z = table.unpack(GetEntityCoords(playerPed))
                        prop = CreateObject(GetHashKey('prop_gun_case_01'), x, y, z + 0.2,  true,  true, true)
                        AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 57005), 0.10, 0.02, -0.02, 40.0, 145.0, 115.0, true, true, false, true, 1, true)
                        onHand = true
                        inAnimation = true
                    end
                }
            }
        })
    elseif onHand then
        lib.registerContext({
            id = 'guncase',
            title = 'Choose',
            options = {
                {
                    title = 'Place on ground',
                    description = 'Places guncase where your looking',
                    icon = 'location-dot',
                    onSelect = function()
                        animDict('pickup_object')
                        TaskPlayAnim(PlayerPedId(), 'pickup_object', 'pickup_low', 1.0, -1.0, -1, 2, 1, true, true, true)
                        Wait(1500)
                        ClearPedTasks(PlayerPedId())

                        spawnObject('prop_gun_case_01')
                        ClearPedTasks(PlayerPedId())
                        ClearPedSecondaryTask(PlayerPedId())
                        DeleteEntity(prop)
                        onHand = false
                        inAnimation = false
                        TriggerServerEvent('hitta_gunCase:removeCase')
                    end
                },
                {
                    title = 'Remove from Hand',
                    description = 'Puts the guncase back on your inventory',
                    icon = 'hand',
                    onSelect = function()
                        if Config.PullFromBack then
                            animDict('reaction@intimidation@1h')
                            TaskPlayAnimAdvanced(PlayerPedId(), 'reaction@intimidation@1h', 'outro', GetEntityCoords(PlayerPedId(), true), 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
                            Wait(1600)
                        end

                        ClearPedTasks(GetPlayerPed(-1))
                        ClearPedSecondaryTask(PlayerPedId())
                        DeleteEntity(prop)
                        onHand = false
                        inAnimation = false
                    end
                }
            }
        })
    end
    Wait(sleep)

    lib.showContext('guncase')
end

spawnObject = function(object)
    local playerPed = GetPlayerPed(-1)
    local coords    = GetEntityCoords(playerPed)
    local forward   = GetEntityForwardVector(playerPed)
    local x, y, z   = table.unpack(coords + forward * 1.0)
    
    local model = GetHashKey(object)
    RequestModel(model)
    while (not HasModelLoaded(model)) do
        Wait(1)
    end
    case = CreateObject(model, x, y, z, true, false, true)
    PlaceObjectOnGroundProperly(case)
    SetModelAsNoLongerNeeded(model)
    SetEntityAsMissionEntity(case)
end

deleteObject = function(object)
    DeleteObject(object)
end

animDict = function(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(1)
    end
end

playAnim = function(player, dict, clip)
    TaskPlayAnim(player, dict, clip, 8.0, 8.0, -1, 50, 0, false, false, false)
end


CreateThread(function()

    local textUI 
    while true do
        local sleep = 1200

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local groundCaseClosed = GetClosestObjectOfType(playerCoords, 1.0, GetHashKey('prop_gun_case_01'), false, false, false)
        local dist = #(playerCoords - groundCaseClosed)
        
        if DoesEntityExist(groundCaseClosed) and not inAnimation then
            sleep = 5

            if not textUI then
                lib.showTextUI('[E] - To Pickup  \n [H] - To Open')
                textUI = true
            end
            if IsControlJustPressed(0, 38) then
                animDict('pickup_object')
                TaskPlayAnim(playerPed, 'pickup_object', 'pickup_low', 1.0, -1.0, -1, 2, 1, true, true, true)
                Wait(1500)
                ClearPedTasks(playerPed)

                deleteObject(case)
                animDict('move_weapon@jerrycan@generic')
                playAnim(playerPed, 'move_weapon@jerrycan@generic', 'idle')

                local x, y, z = table.unpack(GetEntityCoords(playerPed))
                prop = CreateObject(GetHashKey('prop_gun_case_01'), x, y, z + 0.2,  true,  true, true)
                AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 57005), 0.10, 0.02, -0.02, 40.0, 145.0, 115.0, true, true, false, true, 1, true)
                onHand = true
                textUI = nil
                lib.hideTextUI()
                TriggerServerEvent('hitta_gunCase:giveCase')
                inAnimation = true
            elseif IsControlJustPressed(0, 74) then
                deleteObject(case)
                spawnObject('prop_gun_case_02')
            end
        elseif dist >= 2.2 and textUI then
            sleep = 0
            lib.hideTextUI()
            textUI = nil
        end


        local textUI2
        local groundCaseOpened = GetClosestObjectOfType(playerCoords, 1.0, GetHashKey('prop_gun_case_02'), false, false, false)
        local dist2 = #(playerCoords - groundCaseOpened)

        if DoesEntityExist(groundCaseOpened) and not inAnimation then
            sleep = 5

            if not textUI2 then
                lib.showTextUI('[E] - Look Inside  \n [G] - Close')
                textUI2 = true
            end
            if IsControlJustPressed(0, 38) then
                exports.ox_inventory:openInventory('stash', {id='guncase'})

            elseif IsControlJustPressed(0, 113) then
                deleteObject(case)
                spawnObject('prop_gun_case_01')
            end
            

        elseif dist2 >= 2.2 and textUI2 then
            sleep = 0
            lib.hideTextUI()
            textUI2 = nil
        end

        Wait(sleep)
    end

end)