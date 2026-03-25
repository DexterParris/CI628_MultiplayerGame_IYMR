local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- remote events
local HideLobbyMenu = ReplicatedStorage.LobbyEvents.Send.HideLobbyMenu
local ShowLobbyMenu = ReplicatedStorage.LobbyEvents.Send.ShowLobbyMenu

-- variables
local lobbyFrame = script.Parent

ShowLobbyMenu.OnClientEvent:Connect(function()
	lobbyFrame.Visible = true
	lobbyFrame.Active = true
	lobbyFrame.Interactable = true
end)

HideLobbyMenu.OnClientEvent:Connect(function()
	lobbyFrame.Visible = false
	lobbyFrame.Active = false
	lobbyFrame.Interactable = false
end)
