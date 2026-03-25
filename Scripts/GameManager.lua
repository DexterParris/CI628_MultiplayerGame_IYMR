local GameManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- remote events
local ShowGameBoard = ReplicatedStorage.GameEvents.Send.ShowGameBoard
local HideGameBoard = ReplicatedStorage.GameEvents.Send.HideGameBoard
local DropPiece = ReplicatedStorage.GameEvents.Receive.DropPiece
local BoardUpdate = ReplicatedStorage.GameEvents.Send.BoardUpdate

-- game variables
local gameActive = false
local currentTurn = 1
local activePlayers = {}
local winnerName = nil

-- board variables
local ROWS = 6
local COLUMNS = 11

local board = {}



-- managing players and stuff

local function assignActivePlayers(playerList)

	activePlayers = {}

	for _, player in ipairs(playerList) do
		table.insert(activePlayers, player)
	end

	table.sort(activePlayers, function(a,b)
		return a.UserId < b.UserId
	end)

	if #activePlayers > 0 then
		currentTurn = 1
	else
		currentTurn = 0
	end

end

local function getCurrentActivePlayer()
	if currentTurn < 1 or currentTurn > #activePlayers then
		return nil
	end

	return activePlayers[currentTurn]
end


local function removePlayer(player)
	local index = table.find(activePlayers, player)
	if not index then
		return
	end

	table.remove(activePlayers, index)

	if #activePlayers == 0 then
		currentTurn = 0
		return
	end


	-- this fixes and issue with the system when the first palyer in the list left
	if index < currentTurn then
		currentTurn -= 1
	end

	if currentTurn > #activePlayers then
		currentTurn = 1
	end

end

-- end of managing players and stuff


-- turns

local function nextTurn()
	if #activePlayers == 0 then
		currentTurn = 0
		return nil
	end

	currentTurn += 1

	if currentTurn > #activePlayers then
		currentTurn = 1
	end

	return getCurrentActivePlayer()
end

-- end of turns



--debug functions
local function printTurnState()
	print("Current turn index:", currentTurn)

	local currentPlayer = getCurrentActivePlayer()
	if currentPlayer then
		print("Current player:", currentPlayer.Name)
	else
		print("Current player: none")
	end
end

local function printBoard()
	print("----- BOARD -----")

	for row = 1, ROWS do
		local rowString = ""

		for col = 1, COLUMNS do
			rowString ..= tostring(board[row][col]) .. " "
		end

		print(rowString)
	end
end

-- end of debug functions



-- game functions

local function createEmptyBoard()
	board = {}
	
	-- basically i'm justmaking a 2d array to store everything in 
	for row = 1, ROWS do
		board[row] = {}
		for col = 1, COLUMNS do
			board[row][col] = 0
		end
	end
	
end

local function checkValidMove(column)
	if column < 1 or column > COLUMNS then
		return nil
	end
	
	for row = ROWS, 1, -1 do
		if board[row][column] == 0 then
			return row
		end
	end
	
	return nil
	
end

local function checkFullBoard()
	for row = 1, ROWS do
		for col = 1, COLUMNS do
			if board[row][col] == 0 then
				return false
			end
		end
	end
	
	return true
end

local function placePiece(column)
	local row = checkValidMove(column)
	if not row then
		return nil
	end

	if currentTurn < 1 or currentTurn > #activePlayers then
		return nil
	end

	local playerNumber = currentTurn
	board[row][column] = playerNumber

	return row, column, playerNumber
end

local function boardCopy()
	local copy = {}
	for row = 1, ROWS do
		copy[row] = {}
		for col = 1, COLUMNS do
			copy[row][col] = board[row][col]
		end
	end
	return copy
end

local function boardBoundsCheck(row, column)
	return row >= 1 and row <= ROWS and column >= 1 and column <= COLUMNS
end

local function sendBoardUpdate()
	
	local currentPlayer = getCurrentActivePlayer()
	
	BoardUpdate:FireAllClients({
		board = boardCopy(),
		currentTurn = currentTurn,
		currentPlayerName = currentPlayer and currentPlayer.Name or "",
		gameActive = gameActive,
		winnerName = winnerName
		
	})
end

local function checkDirections(startRow, startColumn, rowStep, columnStep, playerNumber)
	local count = 0
	local row = startRow + rowStep
	local column = startColumn + columnStep
	
	while boardBoundsCheck(row, column) and board[row][column] == playerNumber do
		count += 1
		row += rowStep
		column += columnStep
	end
	
	return count
end

local function checkWin(row, column, playerNumber)
	local directions = {
		{0, 1},  -- horizontal
		{1, 0},  -- vertical
		{1, 1},  -- diagonal down and right
		{1, -1}, -- diagonal down and left
	}
	
	for _, direction in ipairs(directions) do
		local rowStep = direction[1]
		local columnStep = direction[2]
		
		local total = 
			1 
			+ checkDirections(row, column, rowStep, columnStep, playerNumber) 
			+ checkDirections(row, column, -rowStep, -columnStep, playerNumber)
		
		if total >= 4 then
			return true
		end
	end
	
	return false
end

local function doTurn(player, column)
	
	if not gameActive then
		print("The game has ended, move ignored.")
		return false
	end
	
	local currentPlayer = getCurrentActivePlayer()
	if not currentPlayer then
		print("No current player")
		return false
	end
	
	if player ~= currentPlayer then
		print(player.name, "Tried to move but is not the current player")
		return false
	end
	
	
	local row, placedColumn, playerNumber = placePiece(column)
	if not row then
		print("Move invalid")		
		return false
	end
	
	print("Placed piece: ", row, placedColumn, playerNumber)
	printBoard()
	
	if checkWin(row, placedColumn, playerNumber) then
		gameActive = false
		winnerName = currentPlayer.Name
		sendBoardUpdate()
		
		print(player.name .. " wins!")
		return true
	end
	
	if checkFullBoard() then
		gameActive = false
		print("It's a draw!")
		winnerName = "Draw"
		
		sendBoardUpdate()
		return true
	end
	
	nextTurn()
	sendBoardUpdate()
	return true

end



DropPiece.OnServerEvent:Connect(function(player,column)
	doTurn(player,column)
end)




function GameManager:StartGame(playerList)
	ShowGameBoard:FireAllClients()

	assignActivePlayers(playerList)
	createEmptyBoard()
	gameActive = true
	winnerName = nil

	sendBoardUpdate()

end

-- end of game functions



return GameManager
