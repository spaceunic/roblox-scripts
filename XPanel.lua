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
local SpinSpeed = 10

-- Variáveis para configurações
local ConfigVisible = false

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
local ConfigTab = CreateTab("Config", 4)

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
local ConfigButton = CreateButton("Configurações", UtilityTab, 2)

-- Funções para cada feature
-- NoClip
local function ToggleNoClip()
    NoClipEnabled = not NoClipEnabled
    
    -- Animação de toggle
    local targetColor = NoClipEnabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 30, 30)
    local colorTween = CreateTween(NoClipButton, {BackgroundColor3 = targetColor})
    colorTween:Play()
    
    -- Atualizar ícone de status
    UpdateStatusIcons("NoClip", NoClipEnabled)
    
    if NoClipEnabled and not NoClipConnection then
        NoClipConnection = RunService.Stepped:Connect(function()
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        UpdateStatus("NoClip ativado")
    else
        -- Desconectar NoClip
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
            UpdateStatus("NoClip desativado")
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
    
    -- Atualizar ícone de status
    UpdateStatusIcons("Invisível", InvisibleEnabled)
    
    if InvisibleEnabled then
        -- Salvar posição original
        OriginalPosition = HumanoidRootPart.CFrame
        
        -- Criar parte invisível para ficar
        InvisiblePart = Instance.new("Part")
        InvisiblePart.Name = "InvisiblePart"
        InvisiblePart.Size = Vector3.new(5, 1, 5)
        InvisiblePart.Anchored = true
        InvisiblePart.CanCollide = false
        InvisiblePart.Transparency = 1
        InvisiblePart.Position = HumanoidRootPart.Position - Vector3.new(0, 3, 0)
        InvisiblePart.Parent = workspace
        
        -- Teleportar para longe
        HumanoidRootPart.CFrame = CFrame.new(9999, 9999, 9999)
        
        UpdateStatus("Modo invisível ativado")
    else
        -- Restaurar posição
        if OriginalPosition then
            HumanoidRootPart.CFrame = OriginalPosition
        end
        
        if InvisiblePart then
            InvisiblePart:Destroy()
            InvisiblePart = nil
        end
        
        UpdateStatus("Modo invisível desativado")
    end
end

-- CtrlClickTP
local function ToggleCtrlClickTP()
    CtrlClickTPEnabled = not CtrlClickTPEnabled
    
    -- Animação de toggle
    local targetColor = CtrlClickTPEnabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 30, 30)
    local colorTween = CreateTween(CtrlClickTPButton, {BackgroundColor3 = targetColor})
    colorTween:Play()
    
    -- Atualizar ícone de status
    UpdateStatusIcons("CtrlClickTP", CtrlClickTPEnabled)
    
    if CtrlClickTPEnabled and not CtrlClickConnection then
        CtrlClickConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                local mouse = LocalPlayer:GetMouse()
                if Character and HumanoidRootPart and mouse.Target then
                    HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                end
            end
        end)
        UpdateStatus("CtrlClickTP ativado - Segure CTRL e clique para teleportar")
    else
        if CtrlClickConnection then
            CtrlClickConnection:Disconnect()
            CtrlClickConnection = nil
            UpdateStatus("CtrlClickTP desativado")
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
        -- Inicializar ângulo de rotação
        local rotationAngle = 0
        
        SpinConnection = RunService.Heartbeat:Connect(function(dt)
            if Character and HumanoidRootPart then
                -- Incrementar o ângulo baseado na velocidade configurada
                rotationAngle = rotationAngle + (dt * SpinSpeed)
                
                -- Aplicar rotação
                HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position) * CFrame.Angles(0, rotationAngle, 0)
            end
        end)
        
        UpdateStatus("Spin ativado - Velocidade: " .. SpinSpeed)
    else
        if SpinConnection then
            SpinConnection:Disconnect()
            SpinConnection = nil
            UpdateStatus("Spin desativado")
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

-- Conectar funções aos botões com tratamento de erros
NoClipButton.MouseButton1Click:Connect(SafeCallback(ToggleNoClip, "Erro ao ativar NoClip"))
InvisibleButton.MouseButton1Click:Connect(SafeCallback(ToggleInvisible, "Erro ao ativar Invisível"))
CtrlClickTPButton.MouseButton1Click:Connect(SafeCallback(ToggleCtrlClickTP, "Erro ao ativar CtrlClickTP"))
SpinButton.MouseButton1Click:Connect(SafeCallback(ToggleSpin, "Erro ao ativar Spin"))
FlingButton.MouseButton1Click:Connect(SafeCallback(ToggleFling, "Erro ao ativar Fling"))
FlyButton.MouseButton1Click:Connect(SafeCallback(ToggleFly, "Erro ao ativar Fly"))
SpeedButton.MouseButton1Click:Connect(SafeCallback(ToggleSpeed, "Erro ao ativar Speed"))
KillAuraButton.MouseButton1Click:Connect(SafeCallback(ToggleKillAura, "Erro ao ativar KillAura"))

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
    
    -- Atualizar ícone de status
    UpdateStatusIcons("Fly", FlyEnabled)
    
    if FlyEnabled and not FlyConnection then
        -- Desativar gravidade
        if Humanoid then
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
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
        
        UpdateStatus("Fly ativado - Velocidade: " .. FlySpeed .. " (WASD + Espaço/Shift)")
    else
        -- Restaurar estados
        if Humanoid then
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        end
        
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
            UpdateStatus("Fly desativado")
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
    
    -- Atualizar ícone de status
    UpdateStatusIcons("Speed", SpeedEnabled)
    
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
        
        UpdateStatus("Speed ativado - Multiplicador: " .. SpeedMultiplier)
    else
        -- Restaurar velocidade
        if Humanoid then
            Humanoid.WalkSpeed = 16 -- Velocidade padrão
        end
        
        if SpeedConnection then
            SpeedConnection:Disconnect()
            SpeedConnection = nil
            UpdateStatus("Speed desativado")
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
    
    -- Atualizar ícone de status
    UpdateStatusIcons("KillAura", KillAuraEnabled)
    
    if KillAuraEnabled and not KillAuraConnection then
        -- Variável para contar hits
        local hitCount = 0
        
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
                                local damageRemote = Character:FindFirstChild("DamageRemote") or game:GetService("ReplicatedStorage"):FindFirstChild("DamageRemote")
                                if damageRemote and damageRemote:IsA("RemoteEvent") then
                                    damageRemote:FireServer()
                                    hitCount = hitCount + 1
                                end
                                
                                -- Método 2: Usando ferramentas (depende do jogo)
                                for _, tool in pairs(Character:GetChildren()) do
                                    if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                                        local handle = tool.Handle
                                        firetouchinterest(handle, playerHRP, 0)
                                        firetouchinterest(handle, playerHRP, 1)
                                        hitCount = hitCount + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
        
        UpdateStatus("KillAura ativado - Alcance: " .. KillAuraRange)
        
        -- Atualizar contador de hits a cada 5 segundos
        spawn(function()
            while KillAuraEnabled and KillAuraConnection do
                wait(5)
                if hitCount > 0 then
                    UpdateStatus("KillAura - " .. hitCount .. " hits detectados")
                    hitCount = 0
                end
            end
        end)
    else
        if KillAuraConnection then
            KillAuraConnection:Disconnect()
            KillAuraConnection = nil
            UpdateStatus("KillAura desativado")
        end
    end
end
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

-- Adicionar ícone de status para funções ativas
local ActiveFeaturesFrame = Instance.new("Frame")
ActiveFeaturesFrame.Name = "ActiveFeatures"
ActiveFeaturesFrame.Size = UDim2.new(1, -20, 0, 30)
ActiveFeaturesFrame.Position = UDim2.new(0, 10, 1, -80)
ActiveFeaturesFrame.BackgroundTransparency = 1
ActiveFeaturesFrame.Parent = MainFrame

-- Layout para ícones de status
local IconLayout = Instance.new("UIListLayout")
IconLayout.FillDirection = Enum.FillDirection.Horizontal
IconLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
IconLayout.SortOrder = Enum.SortOrder.LayoutOrder
IconLayout.Padding = UDim.new(0, 5)
IconLayout.Parent = ActiveFeaturesFrame

-- Função para criar ícones de status
local statusIcons = {}
local function CreateStatusIcon(name, color)
    local icon = Instance.new("Frame")
    icon.Name = name .. "Icon"
    icon.Size = UDim2.new(0, 15, 0, 15)
    icon.BackgroundColor3 = color or Color3.fromRGB(60, 180, 60)
    icon.BorderSizePixel = 0
    icon.Visible = false
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 7.5)
    iconCorner.Parent = icon
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 0, 1, 0)
    iconLabel.Position = UDim2.new(1, 5, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = name
    iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLabel.TextSize = 12
    iconLabel.Font = Enum.Font.Gotham
    iconLabel.TextXAlignment = Enum.TextXAlignment.Left
    iconLabel.Parent = icon
    
    icon.Parent = ActiveFeaturesFrame
    statusIcons[name] = icon
    return icon
end

-- Criar ícones para cada função
CreateStatusIcon("NoClip", Color3.fromRGB(255, 100, 100))
CreateStatusIcon("Invisível", Color3.fromRGB(100, 100, 255))
CreateStatusIcon("CtrlClickTP", Color3.fromRGB(255, 200, 100))
CreateStatusIcon("Spin", Color3.fromRGB(200, 100, 255))
CreateStatusIcon("Fling", Color3.fromRGB(255, 100, 200))
CreateStatusIcon("Fly", Color3.fromRGB(100, 200, 255))
CreateStatusIcon("Speed", Color3.fromRGB(100, 255, 200))
CreateStatusIcon("KillAura", Color3.fromRGB(255, 50, 50))

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

-- Função para atualizar ícones de status
local function UpdateStatusIcons(name, enabled)
    if statusIcons[name] then
        statusIcons[name].Visible = enabled
    end
end

-- Função para tratamento de erros
local function SafeCallback(callback, errorMsg)
    return function(...)
        local success, result = pcall(callback, ...)
        if not success then
            warn("XPanel Error: " .. tostring(result))
            UpdateStatus(errorMsg or "Erro ao executar função", Color3.fromRGB(255, 100, 100))
        end
        return success, result
    end
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

-- Função para criar sliders
local function CreateSlider(name, parent, layoutOrder, min, max, defaultValue, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = name .. "SliderFrame"
    SliderFrame.Size = UDim2.new(0, 260, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.LayoutOrder = layoutOrder
    SliderFrame.Parent = parent
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Name = "Label"
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = name
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextSize = 14
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderValueLabel = Instance.new("TextLabel")
    SliderValueLabel.Name = "Value"
    SliderValueLabel.Size = UDim2.new(0, 40, 0, 20)
    SliderValueLabel.Position = UDim2.new(1, -40, 0, 0)
    SliderValueLabel.BackgroundTransparency = 1
    SliderValueLabel.Text = tostring(defaultValue)
    SliderValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderValueLabel.Font = Enum.Font.Gotham
    SliderValueLabel.TextSize = 14
    SliderValueLabel.Parent = SliderFrame
    
    local SliderBack = Instance.new("Frame")
    SliderBack.Name = "Back"
    SliderBack.Size = UDim2.new(1, 0, 0, 10)
    SliderBack.Position = UDim2.new(0, 0, 0, 30)
    SliderBack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SliderBack.BorderSizePixel = 0
    SliderBack.Parent = SliderFrame
    
    local SliderBackCorner = Instance.new("UICorner")
    SliderBackCorner.CornerRadius = UDim.new(0, 5)
    SliderBackCorner.Parent = SliderBack
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "Fill"
    SliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBack
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 5)
    SliderFillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Name = "Button"
    SliderButton.Size = UDim2.new(1, 0, 1, 0)
    SliderButton.BackgroundTransparency = 1
    SliderButton.Text = ""
    SliderButton.Parent = SliderBack
    
    local value = defaultValue
    
    local function updateSlider(input)
        local sizeX = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
        
        value = min + ((max - min) * sizeX)
        value = math.floor(value * 10) / 10 -- Arredondar para 1 casa decimal
        SliderValueLabel.Text = tostring(value)
        
        if callback then
            callback(value)
        end
    end
    
    SliderButton.MouseButton1Down:Connect(function(input)
        local connection
        connection = RunService.Heartbeat:Connect(function()
            updateSlider({Position = UserInputService:GetMouseLocation()})
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end
        end)
    end)
    
    return SliderFrame, function() return value end
 end

-- Criar painel de configurações
local FlySpeedSlider, GetFlySpeed = CreateSlider("Velocidade de Voo", ConfigTab, 1, 1, 10, FlySpeed, function(value)
    FlySpeed = value
    UpdateStatus("Velocidade de voo ajustada para: " .. value)
end)

local SpeedSlider, GetSpeedMultiplier = CreateSlider("Multiplicador de Velocidade", ConfigTab, 2, 1, 10, SpeedMultiplier, function(value)
    SpeedMultiplier = value
    UpdateStatus("Multiplicador de velocidade ajustado para: " .. value)
    
    -- Atualizar velocidade em tempo real se estiver ativo
    if SpeedEnabled and Humanoid then
        Humanoid.WalkSpeed = 16 * value
    end
end)

local KillAuraRangeSlider, GetKillAuraRange = CreateSlider("Alcance do KillAura", ConfigTab, 3, 5, 30, KillAuraRange, function(value)
    KillAuraRange = value
    UpdateStatus("Alcance do KillAura ajustado para: " .. value)
end)

local SpinSpeedSlider, GetSpinSpeed = CreateSlider("Velocidade de Giro", ConfigTab, 4, 1, 30, SpinSpeed, function(value)
    SpinSpeed = value
    UpdateStatus("Velocidade de giro ajustada para: " .. value)
end)

-- Função para abrir configurações
local function ToggleConfig()
    SwitchTab("Config")
    UpdateStatus("Painel de configurações aberto")
end

-- Conectar botão de configurações
ConfigButton.MouseButton1Click:Connect(ToggleConfig)

-- Mensagem de confirmação
print("XPanel 2.0 carregado com sucesso!")
UpdateStatus("XPanel 2.0 carregado com sucesso!")
