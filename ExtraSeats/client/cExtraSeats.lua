-- Scripted by Fkids ( http://fkids.net )

class 'ExtraSeats'

function ExtraSeats:__init()

    self.enterVehicleKey = "G" -- Key to enter/leave extra seat
    self.timerDelay = 1 -- Delay in seconds between trying to enter/leave an extra seat
    self.enterMaxDistance = 10 -- How far can you be to enter an extra seat

    self.delayTimer = Timer()
    self.inVehicle = false

    Events:Subscribe("KeyUp", self, self.onKeyUp)
    Events:Subscribe("CalcView", self, self.onCalcView)
    Events:Subscribe("LocalPlayerInput", self, self.onLocalPlayerInput)
    Network:Subscribe("ES-Spectate", self, self.onStartSpectatingVehicle)

end

function ExtraSeats:addSeats(modelId, extraSeats)

    self.extraSeats[modelId] = extraSeats

end

function ExtraSeats:onKeyUp(args)

    if self.delayTimer:GetSeconds() < self.timerDelay then return end
    if args.key ~= string.byte(self.enterVehicleKey) then return end

    if self.inVehicle then

        Network:Send("ES-Leave", self.inVehicle)
        self.inVehicle = false

    end

    if LocalPlayer:InVehicle() then return end

    local playerPos = LocalPlayer:GetPosition()

    for vehicle in Client:GetVehicles() do

        if IsValid(vehicle) then

            if Vector3.Distance(vehicle:GetPosition(), playerPos) < self.enterMaxDistance then

                Network:Send("ES-Enter", vehicle:GetId())

                break

            end

        end

    end

    self.delayTimer:Restart()

end

function ExtraSeats:onCalcView()

    if not self.inVehicle then return end

    local vehicle = Vehicle.GetById(self.inVehicle)

    if IsValid(vehicle) then

        Camera:SetPosition(vehicle:GetPosition() + Camera:GetAngle() * Vector3(0, 4, 15))

    else

        if (ExtraSeats.tick or 0) < 1000 then

            Camera:SetPosition(self.vehiclePos)

        else

            Network:Send("ES-Leave", self.inVehicle)
            self.inVehicle = false

        end

    end

    ExtraSeats.tick = (ExtraSeats.tick or 0) + 1

end

function ExtraSeats:onLocalPlayerInput(args)

    if not self.inVehicle then return end

    if args.input ~= Action.LookUp and
       args.input ~= Action.LookDown and
       args.input ~= Action.LookLeft and
       args.input ~= Action.LookRight then

        return false

    end

end

function ExtraSeats:onStartSpectatingVehicle(args)

    self.inVehicle = args[1]
    self.vehiclePos = args[2]

end

ExtraSeats = ExtraSeats()
