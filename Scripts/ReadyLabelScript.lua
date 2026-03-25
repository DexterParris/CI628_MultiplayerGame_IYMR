local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateReadyStateChange = ReplicatedStorage.LobbyEvents.Send.UpdateReadyStateChange

labelText = script.Parent
labelText.Text = "Number of players ready: 0/1"

UpdateReadyStateChange.OnClientEvent:Connect(function(listOfPlayersReady, ServerNumberOfPlayers, ServerNumberOfReadyPlayers)
	labelText.Text = "Number of players ready: " .. ServerNumberOfReadyPlayers .. "/" .. ServerNumberOfPlayers
end)



