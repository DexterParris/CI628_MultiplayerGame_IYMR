local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GameManager = require(ServerScriptService:WaitForChild("GameManager"))


-- remote events
local ReadyStateChange = ReplicatedStorage.LobbyEvents.Receive.ReadyStateChange
local UpdateReadyStateChange = ReplicatedStorage.LobbyEvents.Send.UpdateReadyStateChange
local ShowCountdown = ReplicatedStorage.LobbyEvents.Send.ShowCountdown
local HideCountdown = ReplicatedStorage.LobbyEvents.Send.HideCountdown
local HideLobbyMenu = ReplicatedStorage.LobbyEvents.Send.HideLobbyMenu
local ShowLobbyMenu = ReplicatedStorage.LobbyEvents.Send.ShowLobbyMenu

-- variables
local readyPlayers = {}
local numberOfPlayers = 0
local numberOfReadyPlayers = 0

-- countdown variables
local countdownTimerStart = 5
local countdownTimer = countdownTimerStart
local countdownRunning = false

gameStarted = false



--JOIN/LEAVE

-- when a player joins update the number of players
Players.PlayerAdded:Connect(function(player)
	print("player '" .. player.Name .. "' has joined")
	handlePlayerConnectionStateChange()
end)

-- when a player leaves update the number of players
Players.PlayerRemoving:Connect(function(player)
	print("player '" .. player.Name .. "' has left")
	
	--remove player from the ready list
	if(table.find(readyPlayers, player)) then
		table.remove(readyPlayers, table.find(readyPlayers, player))
		numberOfReadyPlayers -= 1
	end
	handlePlayerConnectionStateChange()
end)

function handlePlayerConnectionStateChange()
	numberOfPlayers = #Players:GetPlayers()
	UpdateReadyStateChange:FireAllClients(readyPlayers, numberOfPlayers, numberOfReadyPlayers)
end

-- END OF JOIN/LEAVE



--Ready up

-- build the list of active players taht will be sent into the game
local function buildPlayerList()
	local playerList = {}

	for _, player, isReady in pairs(readyPlayers) do
		table.insert(playerList, player)
	end

	table.sort(playerList, function (a,b)
		return a.UserId < b.UserId
	end)

	return playerList
end

-- start countdown

local function countdown()
	if countdownRunning then
		return
	end

	countdownRunning = true
	countdownTimer = countdownTimerStart

	task.spawn(function()
		while countdownRunning do
			if numberOfReadyPlayers < numberOfPlayers then
				countdownRunning = false
				countdownTimer = countdownTimerStart
				HideCountdown:FireAllClients()
				return
			end

			ShowCountdown:FireAllClients(countdownTimer)

			if countdownTimer <= 0 then
				countdownRunning = false
				countdownTimer = countdownTimerStart
				HideCountdown:FireAllClients()

				gameStarted = true
				print("Starting game...")
				
				local playerList = buildPlayerList()
				HideLobbyMenu:FireAllClients()
				GameManager:StartGame(playerList)
				
				return
			end

			task.wait(1)
			countdownTimer -= 1
		end
	end)
end


-- update ready states
ReadyStateChange.OnServerEvent:Connect(function(player, isReady)
	if(isReady) then
		if(not table.find(readyPlayers, player)) then
			table.insert(readyPlayers, player)
			numberOfReadyPlayers += 1
		end
	else
		if(table.find(readyPlayers, player)) then
			table.remove(readyPlayers, table.find(readyPlayers, player))
			numberOfReadyPlayers -= 1
		end
	end
	UpdateReadyStateChange:FireAllClients(readyPlayers, numberOfPlayers, numberOfReadyPlayers)
	
	if(numberOfReadyPlayers == numberOfPlayers) then
		countdown()
	end
end)




-- End of Ready Up



