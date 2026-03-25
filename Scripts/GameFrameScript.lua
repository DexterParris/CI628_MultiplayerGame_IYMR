local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


-- remote events
local HideGameBoard = ReplicatedStorage.GameEvents.Send.HideGameBoard
local ShowGameBoard = ReplicatedStorage.GameEvents.Send.ShowGameBoard
local BoardUpdate = ReplicatedStorage.GameEvents.Send.BoardUpdate
local DropPiece = ReplicatedStorage.GameEvents.Receive.DropPiece

-- variables
local player = Players.LocalPlayer
local GameFrame = script.Parent
local GameBoard = GameFrame:WaitForChild("GameBoard")
local CurrentPlayerLabel = GameFrame:WaitForChild("CurrentPlayerLabel")
local WinLabel = GameFrame:WaitForChild("WinLabel")

local ROWS = 6
local COLUMNS = 11


local emptyColour = Color3.fromRGB(21, 27, 52)
local playerColours = {
	[1] = Color3.fromRGB(255,0,0),
	[2] = Color3.fromRGB(255,255,0),
	[3] = Color3.fromRGB(0,170,255),
	[4] = Color3.fromRGB(0,255,0),
}

local localPlayerSlot = nil



local function getCell(row, column)
	local rowFrame = GameBoard:FindFirstChild("Row" .. row)
	return rowFrame:WaitForChild("Cell"..column)
end

local function updateBoard(board)
	for row = 1, ROWS do
		for column = 1, COLUMNS do
			local cell = getCell(row,column)
			local value = board[row][column]
			
			if value == 0 then
				cell.BackgroundColor3 = emptyColour
			else
				cell.BackgroundColor3 = playerColours[value] or emptyColour
			end	
		end
	end
end

local function dropPiece(column)
	DropPiece:FireServer(column)
end

local function connectButtons()
	for column = 1, COLUMNS do
		local button = getCell(1,column)
		button.MouseButton1Click:Connect(function()
			dropPiece(column)
		end)
	end
end

local function updatePlayerLabel(state)
	if not state.gameActive then
		CurrentPlayerLabel.Text = "Game Over"
		return
	end

	local currentName = state.currentPlayerName

	if currentName == player.Name then
		CurrentPlayerLabel.Text = "Your Turn"
	else
		CurrentPlayerLabel.Text = currentName .. "'s Turn"
	end
end

local function updateWinLabel(state)
	if state.gameActive then
		WinLabel.Visible = false
		return
	end

	if state.winnerName == "Draw" then
		WinLabel.Text = "Draw!"
	else
		WinLabel.Text = state.winnerName .. " wins!"
	end

	WinLabel.Visible = true
end

-- hiding and showing the game board frame
ShowGameBoard.OnClientEvent:Connect(function()
	GameFrame.Visible = true
	GameFrame.Active = true
	GameFrame.Interactable = true
end)

HideGameBoard.OnClientEvent:Connect(function()
	GameFrame.Visible = false
	GameFrame.Active = false
	GameFrame.Interactable = false
end)

-- end of hiding and showing the game board frame

-- sending events
connectButtons()
-- end of sending events

-- receiving events
BoardUpdate.OnClientEvent:Connect(function(state)
	updateBoard(state.board)
	updatePlayerLabel(state)
	updateWinLabel(state)
end)
-- end of receiving events