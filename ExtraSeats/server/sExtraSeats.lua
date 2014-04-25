-- Scripted by Fkids ( http://fkids.net )

class 'ExtraSeats'

function ExtraSeats:__init()

    ExtraSeats:init()

    ExtraSeats:addSeats(39, 200) -- Aeroliner 474 Plane
    ExtraSeats:addSeats(85, 100) -- Bering I-86DP Plane
    ExtraSeats:addSeats(12, 20) -- Vanderbildt LeisureLiner Bus
    ExtraSeats:addSeats(66, 10) -- Dinggong 134D Bus
    ExtraSeats:addSeats(8, 4) -- Columbi Excelsior Limo
    ExtraSeats:addSeats(51, 4) -- Cassius 192 Plane
    ExtraSeats:addSeats(18, 4) -- SV-1003 Raider APC
    ExtraSeats:addSeats(65, 4) -- H-62 Quapaw Helicopter
    ExtraSeats:addSeats(56, 2) -- GV-104 Razorback APC
    ExtraSeats:addSeats(84, 2) -- Marten Storm III Car

    Events:Subscribe("PostTick", self, self.onPostTick)
    Events:Subscribe("PlayerQuit", self, self.onPlayerQuit)
    Network:Subscribe("ES-Enter", self, self.onPlayerEnterExtraSeatAttempt)
    Network:Subscribe("ES-Leave", self, self.onPlayerLeaveExtraSeat)

end

function ExtraSeats:init()

    self.streamDistance = 500 -- Default stream distance

    self.extraSeats = {}
    self.takenSeats = {}
    self.movePlayer = {}

end

function ExtraSeats:addSeats(modelId, extraSeats)

    self.extraSeats[modelId] = extraSeats

end

function ExtraSeats:onPlayerEnterExtraSeatAttempt(vehicleId, player)

    local vehicle = Vehicle.GetById(vehicleId)

    if not vehicle then return false end

    local vehicleModelId = vehicle:GetModelId()

    if (self.extraSeats[vehicleModelId] or 0) < 1 then return false end

    if self.takenSeats[vehicleId] then

        if #ExtraSeats:GetExtraOccupants(vehicle) >= (self.extraSeats[vehicleModelId] or 0) then return false end

    end

    local playerId = player:GetId() + 1

    if not self.takenSeats[vehicleId] then self.takenSeats[vehicleId] = {} end

    self.takenSeats[vehicleId][playerId] = true

    self.movePlayer[playerId] = Timer()

    Network:Send(player, "ES-Spectate", {vehicleId, vehicle:GetPosition()})

end

function ExtraSeats:onPlayerLeaveExtraSeat(vehicleId, player)

    player:SetStreamDistance(self.streamDistance)

    local vehicle = Vehicle.GetById(vehicleId)

    local playerId = player:GetId() + 1
    
    if not self.takenSeats[vehicleId] then return false end

    if not self.takenSeats[vehicleId][playerId] then return false end

    self.takenSeats[vehicleId][playerId] = nil

    if vehicle then

        player:SetPosition(vehicle:GetPosition() + vehicle:GetAngle() * Vector3(5, 1, 0))

    end

end

function ExtraSeats:onPostTick(player)

    for playerId, _ in pairs(self.movePlayer) do

        if self.movePlayer[playerId]:GetSeconds() > 2 then

            local player = Player.GetById(playerId - 1)

            if player then

                player:SetStreamDistance(0)

            end

            self.movePlayer[playerId] = nil

        end

    end

end

function ExtraSeats:onPlayerQuit(args)

    local playerId = args.player:GetId() + 1

    for vehicleId, _ in pairs(self.takenSeats) do

        if self.takenSeats[vehicleId][playerId] then

            self.takenSeats[vehicleId][playerId] = nil

        end

    end

end

function ExtraSeats:GetPlayerPosition(player)

    local playerId = player:GetId() + 1

    for vehicleId, _ in pairs(self.takenSeats) do

        if self.takenSeats[vehicleId][playerId] then

            local vehicle = Vehicle.GetById(vehicleId)

            if vehicle then

                return vehicle:GetPosition()

            end

        end

    end

    return player:GetPosition()

end

function ExtraSeats:InVehicle(player)

    local playerId = player:GetId() + 1

    for vehicleId, _ in pairs(self.takenSeats) do

        if self.takenSeats[vehicleId][playerId] then

            local vehicle = Vehicle.GetById(vehicleId)

            if vehicle then

                return true

            end

        end

    end

    return player:InVehicle()

end

function ExtraSeats:GetVehicle(player)

    local playerId = player:GetId() + 1

    for vehicleId, _ in pairs(self.takenSeats) do

        if self.takenSeats[vehicleId][playerId] then

            local vehicle = Vehicle.GetById(vehicleId)

            if vehicle then

                return vehicle

            end

        end

    end

    return player:GetVehicle()

end

function ExtraSeats:GetExtraOccupants(vehicle)

    local extraOccupantsTable = {}

    if vehicle then

        local vehicleId = vehicle:GetId()

        if self.takenSeats[vehicleId] then

            for playerId, _ in pairs(self.takenSeats[vehicleId]) do

                local player = Player.GetById(playerId - 1)

                if player then

                    table.insert(extraOccupantsTable, player)

                end

            end

        end

    end

    return extraOccupantsTable

end

function ExtraSeats:GetAllOccupants(vehicle)

    local allOccupantsTable = {}

    if vehicle then

        allOccupantsTable = vehicle:GetOccupants()

        for _, player in pairs(ExtraSeats:GetExtraOccupants(vehicle)) do

           table.insert(allOccupantsTable, player)

        end

    end

    return allOccupantsTable

end

ExtraSeats = ExtraSeats()
