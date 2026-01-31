local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local AutoJumpEnabled = false 

-- --- INTERFACE (GUI) ---
local ScreenGui = Instance.new("ScreenGui")
local MainButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- Proteção para não duplicar a GUI se executar 2 vezes
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "AutoJumpUltra" then v:Destroy() end
end

if pcall(function() ScreenGui.Parent = CoreGui end) then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

ScreenGui.Name = "AutoJumpUltra"
ScreenGui.ResetOnSpawn = false 

-- Configuração do Botão
MainButton.Name = "ToggleJump"
MainButton.Parent = ScreenGui
MainButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Vermelho (OFF)
MainButton.Position = UDim2.new(0.85, -20, 0.5, 0) -- Canto direito
MainButton.Size = UDim2.new(0, 50, 0, 50) 
MainButton.Text = "JUMP"
MainButton.TextSize = 12
MainButton.Font = Enum.Font.GothamBold
MainButton.TextColor3 = Color3.new(1,1,1)
MainButton.AutoButtonColor = true

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = MainButton

-- --- ARRASTAR (MÓVEL) ---
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

-- --- LÓGICA HÍBRIDA (O SEGREDO ESTÁ AQUI) ---
task.spawn(function()
    while true do
        if AutoJumpEnabled then
            -- 1. Força o pulo FÍSICO (Garantia caso o botão falhe)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Jump = true
            end
            
            -- 2. Simula o CLIQUE no botão (Aperta)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            
            -- Segura por um tempo minúsculo
            task.wait(0.03) 
            
            -- 3. Simula SOLTAR o botão (Libera)
            -- Isso é vital: soltar e apertar de novo renova o comando se você tocou na tela
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            
            -- Espera só um pouquinho para o próximo ciclo
            task.wait() 
        else
            -- Se estiver desligado, o script dorme para não lagar
            task.wait(0.2)
        end
    end
end)

-- Botão Liga/Desliga
MainButton.MouseButton1Click:Connect(function()
    AutoJumpEnabled = not AutoJumpEnabled
    
    if AutoJumpEnabled then
        MainButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Verde
        MainButton.Text = "ON"
    else
        MainButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Vermelho
        MainButton.Text = "OFF"
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) -- Garante que soltou
    end
end)
