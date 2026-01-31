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
local StatusIndicator = Instance.new("Frame") -- Bolinha para indicar status

-- Tenta colocar no CoreGui (Executores) ou PlayerGui (Studio)
if pcall(function() ScreenGui.Parent = CoreGui end) then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

ScreenGui.Name = "AutoJumpPro"
ScreenGui.ResetOnSpawn = false 

-- Configuração do Botão (20x20)
MainButton.Name = "ToggleJump"
MainButton.Parent = ScreenGui
MainButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Cinza escuro
MainButton.Position = UDim2.new(0.8, 0, 0.7, 0) -- Perto dos botões de mobile
MainButton.Size = UDim2.new(0, 40, 0, 40) -- Aumentei um pouco para facilitar o toque no celular (era 20, pus 40)
MainButton.Text = "JUMP"
MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainButton.TextSize = 10
MainButton.AutoButtonColor = true

-- Deixa o botão redondo
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = MainButton

-- Função de Arrastar (Móvel para qualquer parte)
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
        MainButton.Text = "ON"
    else
        MainButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Vermelho (Desligado)
        MainButton.Text = "OFF"
    end
end)

-- Lógica FORÇADA de Pulo (Nova versão)
RunService.Heartbeat:Connect(function()
    if AutoJumpEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        -- Verifica se o humanoide existe e se NÃO está no ar (para não bugar voando)
        if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
            -- Método 1: Forçar Estado (Mais forte que apenas .Jump = true)
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            
            -- Método 2: Backup (pressionar propriedade também)
            humanoid.Jump = true
        end
    end
end)
