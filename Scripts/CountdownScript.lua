local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShowCountdown = ReplicatedStorage.LobbyEvents.Send.ShowCountdown
local HideCountdown = ReplicatedStorage.LobbyEvents.Send.HideCountdown

local countdownLabel = script.Parent

ShowCountdown.OnClientEvent:Connect(function(countdownTimer)
	countdownLabel.Visible = true
	countdownLabel.Text = "Game starting in " .. countdownTimer
end)

HideCountdown.OnClientEvent:Connect(function()
	countdownLabel.Visible = false
end)