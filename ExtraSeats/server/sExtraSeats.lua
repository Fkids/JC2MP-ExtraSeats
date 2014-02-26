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

    Events:Subscribe("PostTick", self, self.onPostTick)
    Network:Subscribe("ES-Enter", self, self.onPlayerEnterExtraSeatAttempt)
    Network:Subscribe("ES-Leave", self, self.onPlayerLeaveExtraSeat)

end

function ExtraSeats:init()

    self.tempPosition = Vector3(-6748.748, 208.447, -3621.753) -- Location where players are teleported when entering extra seat
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

        if #self.takenSeats[vehicleId] >= (self.extraSeats[vehicleModelId] or 0) then return false end

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

    if not self.takenSeats[vehicleId][playerId] then return false end

    self.takenSeats[vehicleId][playerId] = false

    if vehicle then

        player:SetPosition(vehicle:GetPosition() + vehicle:GetAngle() * Vector3(5, 0, 0))

    end
    
end

function ExtraSeats:onPostTick(player)

    for playerId, _ in pairs(self.movePlayer) do

        if self.movePlayer[playerId]:GetSeconds() > 2 then

            local player = Player.GetById(playerId - 1)

            if player then

                player:SetPosition(self.tempPosition)
                player:SetStreamDistance(0)

            end

            self.movePlayer[playerId] = nil

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

ExtraSeats = ExtraSeats()
