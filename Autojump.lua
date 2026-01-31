local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local AutoJumpEnabled = false 

-- --- CRIAÇÃO DA INTERFACE (GUI) ---
local ScreenGui = Instance.new("ScreenGui")
local MainButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

if pcall(function() ScreenGui.Parent = CoreGui end) then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

ScreenGui.Name = "AutoJumpHold"
ScreenGui.ResetOnSpawn = false 

-- Configuração do Botão
MainButton.Name = "HoldJump"
MainButton.Parent = ScreenGui
MainButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Vermelho (OFF)
MainButton.Position = UDim2.new(0.8, -10, 0.6, 0) -- Posição ajustada
MainButton.Size = UDim2.new(0, 45, 0, 45) -- Tamanho confortável
MainButton.Text = "HOLD"
MainButton.TextSize = 10
MainButton.TextColor3 = Color3.new(1,1,1)
MainButton.AutoButtonColor = true

UICorner.CornerRadius = UDim.new(1, 0) -- Redondo
UICorner.Parent = MainButton

-- --- SISTEMA MÓVEL (Arrastar) ---
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
MainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainButton.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
MainButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

-- --- LÓGICA DE SEGURAR O BOTÃO ---

-- Loop que mantém o botão pressionado
RunService.RenderStepped:Connect(function()
    if AutoJumpEnabled then
        -- Envia sinal de que o Espaço está PRESSIONADO (true) a cada frame
        -- Isso simula o dedo colado na tela/tecla
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    end
end)

-- Evento de Clique no Botão da Tela
MainButton.MouseButton1Click:Connect(function()
    AutoJumpEnabled = not AutoJumpEnabled
    
    if AutoJumpEnabled then
        -- LIGOU
        MainButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Verde
        MainButton.Text = "ON"
    else
        -- DESLIGOU
        MainButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Vermelho
        MainButton.Text = "OFF"
        
        -- Importante: Envia o sinal de SOLTAR (false) imediatamente para parar de pular
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end
end)
