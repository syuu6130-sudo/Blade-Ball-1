-- =============================================
-- Bladeball Auto & Spam Parry Script (Final Version)
-- PC & Mobile対応
-- =============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ゲーム内のボール
local BallPart = Workspace:WaitForChild("BallPart")

-- 設定
local AutoParryRange = 10       -- 自動パリー発動距離
local SpamParryDistance = 5     -- スパムパリー発動距離
local ParryCooldown = 1         -- 通常パリーのクールタイム
local SpamParryCooldown = 0.1   -- スパムパリーのクールタイム

local lastParryTime = 0
local AutoParryEnabled = true
local SpamParryEnabled = true

-- PCパリーキー
local ParryKey = Enum.KeyCode.Q

-- パリー関数
local function Parry()
    local now = tick()
    local cooldown = ParryCooldown
    -- スパムパリーならクールタイムを短くする
    if SpamParryEnabled then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local enemyDistance = (otherPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                if enemyDistance <= SpamParryDistance then
                    cooldown = SpamParryCooldown
                    break
                end
            end
        end
    end

    if now - lastParryTime >= cooldown then
        -- 実際にボールを弾く処理はゲーム側で動作
        print("Parry triggered")  -- デバッグ用ログ
        lastParryTime = now
    end
end

-- モバイルタップ対応
local function MobileParryAction(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin then
        Parry()
    end
end

if UserInputService.TouchEnabled then
    ContextActionService:BindAction("MobileParry", MobileParryAction, false, Enum.UserInputType.Touch)
end

-- メインループ（自動オートパリー・スパムパリー）
RunService.RenderStepped:Connect(function()
    local now = tick()
    local ballDistance = (BallPart.Position - humanoidRootPart.Position).Magnitude

    -- スパムパリー判定
    local spamParry = false
    if SpamParryEnabled then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local enemyDistance = (otherPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                if enemyDistance <= SpamParryDistance then
                    spamParry = true
                    break
                end
            end
        end
    end

    -- クールタイム調整＆パリー実行
    if spamParry then
        if now - lastParryTime >= SpamParryCooldown then
            Parry()
        end
    elseif AutoParryEnabled and ballDistance <= AutoParryRange then
        if now - lastParryTime >= ParryCooldown then
            Parry()
        end
    end
end)

-- PCキーボード入力
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == ParryKey then
        Parry()
    end
end)
