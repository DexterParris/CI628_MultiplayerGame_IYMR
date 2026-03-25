local readyButton = script.Parent
local isReady = false

-- remote events
local ReplicatedStorage = game.ReplicatedStorage
local ReadyStateChange = ReplicatedStorage.LobbyEvents.Receive.ReadyStateChange
local UpdateReadyStateChange = ReplicatedStorage.LobbyEvents.Send.UpdateReadyStateChange


readyButton.MouseButton1Click:Connect(function()
	if(not isReady) then
		ReadyStateChange:FireServer(true)
	else
		ReadyStateChange:FireServer(false)
	end
end)


-- ensure that the player is ready using server side verification
UpdateReadyStateChange.OnClientEvent:Connect(function(listOfPlayersReady)
	if(table.find(listOfPlayersReady, game.Players.LocalPlayer)) then
		isReady = true
		readyButton.Text = "Unready"
	else
		isReady = false
		readyButton.Text = "Ready Up"
	end
end)


