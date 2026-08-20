local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

-- Функция для отправки уведомлений
local function notify(title, text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 4
		})
	end)
end

-- Основная функция поиска сервера
local function findAndTeleport()
	notify("Поиск сервера", "Ищем маленькие сервера...")
	
	local apiUrl = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
	local success, response = pcall(function()
		return game:HttpGet(apiUrl)
	end)
	
	if not success then
		notify("Ошибка", "Не удалось получить список серверов")
		return
	end
	
	local data = HttpService:JSONDecode(response)
	if not data or not data.data then
		notify("Ошибка", "Данные серверов недоступны")
		return
	end
	
	local candidateServers = {}
	for _, server in ipairs(data.data) do
		if server.id ~= JobId and server.playing < server.maxPlayers then
			table.insert(candidateServers, server)
			if #candidateServers >= 5 then
				break
			end
		end
	end
	
	if #candidateServers == 0 then
		notify("Ошибка", "Подходящих серверов не найдено")
		return
	end
	
	table.sort(candidateServers, function(a, b)
		return a.playing < b.playing
	end)
	
	local bestServer = candidateServers[1]
	notify("Сервер найден!", "Игроков: " .. bestServer.playing .. ". Телепорт...")
	
	task.wait(1)
	TeleportService:TeleportToPlaceInstance(PlaceId, bestServer.id, LocalPlayer)
end

-- ================= ИНТЕРФЕЙС =================

local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Создание ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ServerSearchGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Главная рамка-контейнер (невидимая)
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, 95, 0, 60)
container.Position = UDim2.new(0.5, -47, 0.2, 0)
container.BackgroundTransparency = 1
container.Parent = screenGui

-- Квадратная кнопка с лупой
local mainButton = Instance.new("TextButton")
mainButton.Name = "SearchButton"
mainButton.Size = UDim2.new(0, 60, 0, 60)
mainButton.Position = UDim2.new(0, 0, 0, 0)
mainButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainButton.BorderSizePixel = 0
mainButton.Text = "🔍"
mainButton.TextSize = 28
mainButton.Parent = container

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 12)
buttonCorner.Parent = mainButton

-- Кружочек для перемещения (сбоку)
local dragCircle = Instance.new("Frame")
dragCircle.Name = "DragHandle"
dragCircle.Size = UDim2.new(0, 26, 0, 26)
dragCircle.Position = UDim2.new(0, 68, 0, 17)
dragCircle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
dragCircle.BorderSizePixel = 0
dragCircle.Active = true
dragCircle.Parent = container

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = dragCircle

-- Логика перетаскивания через кружок
local dragging = false
local dragStart, startPos

dragCircle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = container.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		container.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- Запуск скрипта при нажатии на квадрат
mainButton.MouseButton1Click:Connect(function()
	findAndTeleport()
end)
