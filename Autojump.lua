-- Configurações Iniciais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local AutoJumpEnabled = false -- Começa desligado

-- Criação da Interface (GUI)
local ScreenGui = Instance.new("ScreenGui")
local MainButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- Tenta colocar no CoreGui (para executores) ou PlayerGui (para Studio)
if pcall(function() ScreenGui.Parent = CoreGui end) then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

ScreenGui.Name = "AutoJumpUI"
ScreenGui.ResetOnSpawn = false -- Mantém a GUI se você morrer

-- Configuração do Botão
MainButton.Name = "ToggleJump"
MainButton.Parent = ScreenGui
MainButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Vermelho (Desligado)
MainButton.Position = UDim2.new(0.5, -10, 0.5, -10) -- Centro da tela
MainButton.Size = UDim2.new(0, 20, 0, 20) -- Tamanho 20x20 como solicitado
MainButton.Text = "" -- Sem texto para ficar limpo (pode colocar "J" se quiser)
MainButton.AutoButtonColor = true

-- Arredondar os cantos (Opcional, fica mais bonito)
UICorner.CornerRadius = UDim.new(1, 0) -- Deixa redondo (círculo)
UICorner.Parent = MainButton

-- Função de Arrastar (Móvel para qualquer parte)
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Lógica do Botão (Ligar/Desligar)
MainButton.MouseButton1Click:Connect(function()
    AutoJumpEnabled = not AutoJumpEnabled
    
    if AutoJumpEnabled then
        MainButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Verde (Ligado)
        -- Feedback visual rápido (opcional)
        print("Auto Jump: LIGADO")
    else
        MainButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Vermelho (Desligado)
        print("Auto Jump: DESLIGADO")
    end
end)

-- Lógica do Auto Jump (Loop rápido)
RunService.RenderStepped:Connect(function()
    if AutoJumpEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Jump = true
        end
    end
end)
