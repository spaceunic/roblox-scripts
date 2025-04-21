-- XPanel - Script para executor externo (Synapse X / Xeno)
-- Criado por Cascade
-- Versão 2.0 com sistema de abas e animações

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Variáveis para controlar os toggles
local NoClipEnabled = false
local InvisibleEnabled = false
local CtrlClickTPEnabled = false
local SpinEnabled = false
local FlingEnabled = false
local FlyEnabled = false
local SpeedEnabled = false
local KillAuraEnabled = false

-- Guardar a posição original para invisibilidade
local OriginalPosition = nil
local InvisiblePart = nil
local SpinSpeed = 10

-- Variáveis para as novas funções
local FlySpeed = 2
local SpeedMultiplier = 5
local KillAuraRange = 15

-- Variáveis para animações
local AnimationSpeed = 0.3
local CurrentTab = "Movimento" -- Aba padrão

-- Criação da GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XPanel"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Função para criar efeito de sombra
local function CreateShadow(parent, size, position, radius)
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = size
    shadow.Position = position or UDim2.new(0, 0, 0, 0)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.ZIndex = parent.ZIndex - 1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 5)
    corner.Parent = shadow
    
    shadow.Parent = parent
    return shadow
end

-- Função para criar efeito de transição
local function CreateTween(object, properties, time, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        time or AnimationSpeed,
        easingStyle or Enum.EasingStyle.Quint,
        easingDirection or Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(object, tweenInfo, properties)
    return tween
end

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 450)
MainFrame.Position = UDim2.new(0.8, 0, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Adicionar cantos arredondados
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Adicionar sombra
CreateShadow(MainFrame, UDim2.new(1, 10, 1, 10), UDim2.new(0, -5, 0, -5))

-- Título
local TitleFrame = Instance.new("Frame")
TitleFrame.Name = "TitleFrame"
TitleFrame.Size = UDim2.new(1, 0, 0, 40)
TitleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleFrame.BorderSizePixel = 0
TitleFrame.Parent = MainFrame

-- Cantos arredondados para o título
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleFrame

-- Cortar cantos inferiores do título
local TitleCornerCut = Instance.new("Frame")
TitleCornerCut.Name = "TitleCornerCut"
TitleCornerCut.Size = UDim2.new(1, 0, 0.5, 0)
TitleCornerCut.Position = UDim2.new(0, 0, 0.5, 0)
TitleCornerCut.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleCornerCut.BorderSizePixel = 0
TitleCornerCut.ZIndex = TitleFrame.ZIndex
TitleCornerCut.Parent = TitleFrame

-- Título
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "XPanel 2.0"
TitleLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 22
TitleLabel.Parent = TitleFrame

-- Container para as abas
local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Size = UDim2.new(1, 0, 0, 40)
TabsFrame.Position = UDim2.new(0, 0, 0, 40)
TabsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TabsFrame.BorderSizePixel = 0
TabsFrame.Parent = MainFrame

-- Linha separadora
local Separator = Instance.new("Frame")
Separator.Name = "Separator"
Separator.Size = UDim2.new(1, -20, 0, 2)
Separator.Position = UDim2.new(0, 10, 1, -1)
Separator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Separator.BorderSizePixel = 0
Separator.Parent = TabsFrame

-- Container para o conteúdo
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -90)
ContentFrame.Position = UDim2.new(0, 10, 0, 85)
ContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

-- Criar abas
local TabButtons = {}
local TabContents = {}

local function CreateTab(name, index)
    -- Botão da aba
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(0, 90, 1, -5)
    TabButton.Position = UDim2.new(0, 10 + (index - 1) * 95, 0, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabButton.BackgroundTransparency = 0.5
    TabButton.BorderSizePixel = 0
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 14
    TabButton.Parent = TabsFrame
    
    -- Cantos arredondados para o botão
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton
    
    -- Indicador de seleção
    local SelectionIndicator = Instance.new("Frame")
    SelectionIndicator.Name = "SelectionIndicator"
    SelectionIndicator.Size = UDim2.new(1, 0, 0, 3)
    SelectionIndicator.Position = UDim2.new(0, 0, 1, -3)
    SelectionIndicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    SelectionIndicator.BorderSizePixel = 0
    SelectionIndicator.Visible = (name == CurrentTab)
    SelectionIndicator.Parent = TabButton
    
    -- Container para o conteúdo da aba
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = name .. "Content"
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    TabContent.Visible = (name == CurrentTab)
    TabContent.Parent = ContentFrame
    
    -- Layout para os botões dentro da aba
    local ButtonLayout = Instance.new("UIGridLayout")
    ButtonLayout.CellSize = UDim2.new(0, 130, 0, 45)
    ButtonLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ButtonLayout.Parent = TabContent
    
    -- Padding para os botões
    local ButtonPadding = Instance.new("UIPadding")
    ButtonPadding.PaddingTop = UDim.new(0, 5)
    ButtonPadding.PaddingLeft = UDim.new(0, 5)
    ButtonPadding.Parent = TabContent
    
    -- Adicionar à tabela de abas
    TabButtons[name] = TabButton
    TabContents[name] = TabContent
    
    -- Evento de clique
    TabButton.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
    
    return TabContent
end

-- Função para trocar de aba
function SwitchTab(tabName)
    if CurrentTab == tabName then return end
    
    -- Desativar aba atual
    if TabButtons[CurrentTab] then
        local oldIndicator = TabButtons[CurrentTab]:FindFirstChild("SelectionIndicator")
        if oldIndicator then
            oldIndicator.Visible = false
        end
        
        local oldTween = CreateTween(TabButtons[CurrentTab], {
            BackgroundTransparency = 0.5,
            TextColor3 = Color3.fromRGB(200, 200, 200)
        })
        oldTween:Play()
        
        TabContents[CurrentTab].Visible = false
    end
    
    -- Ativar nova aba
    CurrentTab = tabName
    
    local newIndicator = TabButtons[CurrentTab]:FindFirstChild("SelectionIndicator")
    if newIndicator then
        newIndicator.Visible = true
    end
    
    local newTween = CreateTween(TabButtons[CurrentTab], {
        BackgroundTransparency = 0,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    })
    newTween:Play()
    
    TabContents[CurrentTab].Visible = true
end

-- Criar as abas
local MovementTab = CreateTab("Movimento", 1)
local CombatTab = CreateTab("Ataque", 2)
local UtilityTab = CreateTab("Utilitários", 3)

-- Função para criar botões modernos
local function CreateButton(name, parent, layoutOrder)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(0, 130, 0, 45)
    Button.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = name
    Button.TextSize = 16
    Button.Font = Enum.Font.GothamSemibold
    Button.LayoutOrder = layoutOrder
    Button.BorderSizePixel = 0
    Button.Parent = parent
    
    -- Adicionar cantos arredondados
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button
    
    -- Adicionar efeito de sombra
    local ButtonShadow = CreateShadow(Button, UDim2.new(1, 6, 1, 6), UDim2.new(0, -3, 0, -3))
    ButtonShadow.ZIndex = Button.ZIndex - 1
    
    -- Efeitos de hover
    Button.MouseEnter:Connect(function()
        local hoverTween = CreateTween(Button, {
            BackgroundColor3 = Color3.fromRGB(200, 40, 40),
            Size = UDim2.new(0, 135, 0, 48)
        }, 0.2)
        hoverTween:Play()
    end)
    
    Button.MouseLeave:Connect(function()
        local leaveTween = CreateTween(Button, {
            BackgroundColor3 = Color3.fromRGB(180, 30, 30),
            Size = UDim2.new(0, 130, 0, 45)
        }, 0.2)
        leaveTween:Play()
    end)
    
    -- Efeito de clique
    Button.MouseButton1Down:Connect(function()
        local clickTween = CreateTween(Button, {
            BackgroundColor3 = Color3.fromRGB(150, 25, 25),
            Size = UDim2.new(0, 125, 0, 42)
        }, 0.1)
        clickTween:Play()
    end)
    
    Button.MouseButton1Up:Connect(function()
        local releaseTween = CreateTween(Button, {
            BackgroundColor3 = Color3.fromRGB(200, 40, 40),
            Size = UDim2.new(0, 135, 0, 48)
        }, 0.1)
        releaseTween:Play()
    end)
    
    return Button
end

-- Criação dos botões organizados por abas
-- Aba de Movimento
local NoClipButton = CreateButton("NoClip", MovementTab, 1)
local FlyButton = CreateButton("Fly", MovementTab, 2)
local SpeedButton = CreateButton("Speed", MovementTab, 3)
local CtrlClickTPButton = CreateButton("CtrlClickTP", MovementTab, 4)

-- Aba de Ataque
local KillAuraButton = CreateButton("KillAura", CombatTab, 1)
local FlingButton = CreateButton("Fling", CombatTab, 2)
local SpinButton = CreateButton("Spin", CombatTab, 3)

-- Aba de Utilitários
local InvisibleButton = CreateButton("Invisível", UtilityTab, 1)

-- Funções para cada feature
-- NoClip
local function ToggleNoClip()
    NoClipEnabled = not NoClipEnabled
    
    -- Animação de toggle
    local targetColor = NoClipEnabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 30, 30)
    local colorTween = CreateTween(NoClipButton, {BackgroundColor3 = targetColor})
    colorTween:Play()
    
    if NoClipEnabled then
        -- Conexão NoClip
        NoClipConnection = RunService.Stepped:Connect(function()
            if Character and Character:FindFirstChild("Humanoid") then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        -- Desconectar NoClip
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
    end
end

-- Invisível
local function ToggleInvisible()
    InvisibleEnabled = not InvisibleEnabled
    
    -- Animação de toggle
    local targetColor = InvisibleEnabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 30, 30)
    local colorTween = CreateTween(InvisibleButton, {BackgroundColor3 = targetColor})
    colorTween:Play()
    
    if InvisibleEnabled then
        -- Guardar posição e criar parte invisível
        OriginalPosition = HumanoidRootPart.CFrame
        InvisiblePart = Instance.new("Part")
        InvisiblePart.Size = Vector3.new(5, 1, 5)
        InvisiblePart.Anchored = true
        InvisiblePart.CanCollide = true
        InvisiblePart.Transparency = 1
        InvisiblePart.Position = Vector3.new(9999, 9999, 9999)
        InvisiblePart.Parent = workspace
        
        HumanoidRootPart.CFrame = CFrame.new(9999, 9999, 9999)
    else
        -- Restaurar posição e remover parte
        if OriginalPosition and HumanoidRootPart then
            HumanoidRootPart.CFrame = OriginalPosition
        end
        
        if InvisiblePart then
            InvisiblePart:Destroy()
            InvisiblePart = nil
        end
    end
end

-- CtrlClickTP
local function ToggleCtrlClickTP()
    CtrlClickTPEnabled = not CtrlClickTPEnabled
    
    -- Animação de toggle
    local targetColor = CtrlClickTPEnabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 30, 30)
    local colorTween = CreateTween(CtrlClickTPButton, {BackgroundColor3 = targetColor})
    colorTween:Play()
    
    if CtrlClickTPEnabled and not CtrlClickConnection then
        CtrlClickConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                local mouse = LocalPlayer:GetMouse()
                if Character and HumanoidRootPart and mouse.Target then
                    HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                end
            end
        end)
    else
        if CtrlClickConnection then
            CtrlClickConnection:Disconnect()
            CtrlClickConnection = nil
        end
    end
end

-- Spin
local function ToggleSpin()
    SpinEnabled = not SpinEnabled
    
    -- Animação de toggle
    local targetColor = SpinEnabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 30, 30)
    local colorTween = CreateTween(SpinButton, {BackgroundColor3 = targetColor})
    colorTween:Play()
    
    if SpinEnabled and not SpinConnection then
        local RotationAngle = 0
        SpinConnection = RunService.Heartbeat:Connect(function(dt)
            if Character and HumanoidRootPart then
                RotationAngle = RotationAngle + dt * SpinSpeed
                HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position) * CFrame.Angles(0, RotationAngle, 0)
            end
        end)
    else
        if SpinConnection then
            SpinConnection:Disconnect()
            SpinConnection = nil
        end
    end
end

-- Fling
local function ToggleFling()
    FlingEnabled = not FlingEnabled
    
    -- Animação de toggle
    local targetColor = FlingEnabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 30, 30)
    local colorTween = CreateTween(FlingButton, {BackgroundColor3 = targetColor})
    colorTween:Play()
    
    if FlingEnabled and not FlingConnection then
        -- Aumentar velocidade para fling
        if HumanoidRootPart then
            HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(9e9, 9e9, 9e9, 9e9, 9e9)
            
            FlingConnection = RunService.Heartbeat:Connect(function()
                if Character and HumanoidRootPart then
                    HumanoidRootPart.Velocity = Vector3.new(500, 500, 500)
                    HumanoidRootPart.RotVelocity = Vector3.new(9e9, 9e9, 9e9)
                end
            end)
        end
    else
        if FlingConnection then
            FlingConnection:Disconnect()
            FlingConnection = nil
        end
        
        if HumanoidRootPart then
            HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
            HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
        end
    end
end

-- Conectar funções aos botões
NoClipButton.MouseButton1Click:Connect(ToggleNoClip)
InvisibleButton.MouseButton1Click:Connect(ToggleInvisible)
CtrlClickTPButton.MouseButton1Click:Connect(ToggleCtrlClickTP)
SpinButton.MouseButton1Click:Connect(ToggleSpin)
FlingButton.MouseButton1Click:Connect(ToggleFling)
FlyButton.MouseButton1Click:Connect(ToggleFly)
SpeedButton.MouseButton1Click:Connect(ToggleSpeed)
KillAuraButton.MouseButton1Click:Connect(ToggleKillAura)

-- Função para atualizar character se mudar
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Resetar toggles
    if NoClipEnabled then ToggleNoClip() end
    if InvisibleEnabled then ToggleInvisible() end
    if SpinEnabled then ToggleSpin() end
    if FlingEnabled then ToggleFling() end
    if FlyEnabled then ToggleFly() end
    if SpeedEnabled then ToggleSpeed() end
    if KillAuraEnabled then ToggleKillAura() end
end)

-- Fly
local function ToggleFly()
    FlyEnabled = not FlyEnabled
    
    -- Animação de toggle
    local targetColor = FlyEnabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 30, 30)
    local colorTween = CreateTween(FlyButton, {BackgroundColor3 = targetColor})
    colorTween:Play()
    
    if FlyEnabled and not FlyConnection then
        -- Desativar gravidade
        if Humanoid then
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
            Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        end
        
        FlyConnection = RunService.Heartbeat:Connect(function()
            if Character and HumanoidRootPart then
                local humanoid = Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    -- Controles de voo
                    local newVelocity = Vector3.new(0, 0, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        newVelocity = newVelocity + (workspace.CurrentCamera.CFrame.LookVector * FlySpeed)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        newVelocity = newVelocity - (workspace.CurrentCamera.CFrame.LookVector * FlySpeed)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        newVelocity = newVelocity - (workspace.CurrentCamera.CFrame.RightVector * FlySpeed)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        newVelocity = newVelocity + (workspace.CurrentCamera.CFrame.RightVector * FlySpeed)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        newVelocity = newVelocity + Vector3.new(0, FlySpeed, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        newVelocity = newVelocity - Vector3.new(0, FlySpeed, 0)
                    end
                    
                    -- Aplicar velocidade
                    HumanoidRootPart.Velocity = newVelocity
                end
            end
        end)
    else
        -- Restaurar estados
        if Humanoid then
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        end
        
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
    end
end

-- Speed
local function ToggleSpeed()
    SpeedEnabled = not SpeedEnabled
    
    -- Animação de toggle
    local targetColor = SpeedEnabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 30, 30)
    local colorTween = CreateTween(SpeedButton, {BackgroundColor3 = targetColor})
    colorTween:Play()
    
    if SpeedEnabled and not SpeedConnection then
        -- Guardar velocidade original
        local originalWalkSpeed = Humanoid.WalkSpeed
        
        -- Aumentar velocidade
        Humanoid.WalkSpeed = originalWalkSpeed * SpeedMultiplier
        
        SpeedConnection = RunService.Heartbeat:Connect(function()
            if Character and Character:FindFirstChildOfClass("Humanoid") then
                Character:FindFirstChildOfClass("Humanoid").WalkSpeed = originalWalkSpeed * SpeedMultiplier
            end
        end)
    else
        -- Restaurar velocidade
        if Humanoid then
            Humanoid.WalkSpeed = 16 -- Velocidade padrão
        end
        
        if SpeedConnection then
            SpeedConnection:Disconnect()
            SpeedConnection = nil
        end
    end
end

-- KillAura
local function ToggleKillAura()
    KillAuraEnabled = not KillAuraEnabled
    
    -- Animação de toggle
    local targetColor = KillAuraEnabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 30, 30)
    local colorTween = CreateTween(KillAuraButton, {BackgroundColor3 = targetColor})
    colorTween:Play()
    
    if KillAuraEnabled and not KillAuraConnection then
        KillAuraConnection = RunService.Heartbeat:Connect(function()
            if Character and HumanoidRootPart then
                -- Procurar por jogadores próximos
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local playerCharacter = player.Character
                        if playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") and playerCharacter:FindFirstChildOfClass("Humanoid") then
                            local playerHRP = playerCharacter.HumanoidRootPart
                            local playerHumanoid = playerCharacter:FindFirstChildOfClass("Humanoid")
                            
                            -- Verificar distância
                            local distance = (HumanoidRootPart.Position - playerHRP.Position).Magnitude
                            if distance <= KillAuraRange and playerHumanoid.Health > 0 then
                                -- Tentar danificar o jogador
                                -- Método 1: Usando RemoteEvents (depende do jogo)
                                local damageRemote = playerCharacter:FindFirstChild("DamageRemote")
                                if damageRemote and damageRemote:IsA("RemoteEvent") then
                                    damageRemote:FireServer()
                                end
                                
                                -- Método 2: Usando ferramentas (depende do jogo)
                                for _, tool in pairs(Character:GetChildren()) do
                                    if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                                        local handle = tool.Handle
                                        firetouchinterest(handle, playerHRP, 0)
                                        firetouchinterest(handle, playerHRP, 1)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        if KillAuraConnection then
            KillAuraConnection:Disconnect()
            KillAuraConnection = nil
        end
    end
end

-- Adicionar um indicador de status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 1, -40)
StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
StatusLabel.BackgroundTransparency = 0.7
StatusLabel.BorderSizePixel = 0
StatusLabel.Text = "XPanel 2.0 carregado com sucesso!"
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- Cantos arredondados para o status
local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 5)
StatusCorner.Parent = StatusLabel

-- Animação de entrada
MainFrame.Position = UDim2.new(1.1, 0, 0.5, -225) -- Iniciar fora da tela
local entryTween = CreateTween(MainFrame, {
    Position = UDim2.new(0.8, 0, 0.5, -225)
}, 0.6, Enum.EasingStyle.Back)
entryTween:Play()

-- Função para atualizar o status
local function UpdateStatus(text, color)
    local statusTween = CreateTween(StatusLabel, {
        TextColor3 = color or Color3.fromRGB(100, 255, 100),
        TextTransparency = 0
    }, 0.3)
    statusTween:Play()
    
    StatusLabel.Text = text
    
    -- Fade out após 3 segundos
    spawn(function()
        wait(3)
        local fadeTween = CreateTween(StatusLabel, {
            TextTransparency = 0.7
        }, 0.5)
        fadeTween:Play()
    end)
end

-- Botão para fechar o painel
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 8)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TitleFrame

-- Cantos arredondados para o botão de fechar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseButton

-- Evento de clique para fechar
CloseButton.MouseButton1Click:Connect(function()
    -- Animação de saída
    local exitTween = CreateTween(MainFrame, {
        Position = UDim2.new(1.1, 0, 0.5, -225),
        Size = UDim2.new(0, 280, 0, 430)
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    
    exitTween:Play()
    
    exitTween.Completed:Connect(function()
        ScreenGui:Destroy()
        
        -- Desativar todas as funções ativas
        if NoClipEnabled then ToggleNoClip() end
        if InvisibleEnabled then ToggleInvisible() end
        if CtrlClickTPEnabled then ToggleCtrlClickTP() end
        if SpinEnabled then ToggleSpin() end
        if FlingEnabled then ToggleFling() end
        if FlyEnabled then ToggleFly() end
        if SpeedEnabled then ToggleSpeed() end
        if KillAuraEnabled then ToggleKillAura() end
    end)
end)

-- Mensagem de confirmação
print("XPanel 2.0 carregado com sucesso!")
UpdateStatus("XPanel 2.0 carregado com sucesso!")
