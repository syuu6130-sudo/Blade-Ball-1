-- 変数の設定
local BallPart = game.Workspace:WaitForChild("BallPart")
local CenterPart = game.Workspace:WaitForChild("CenterPart")
local ParryRange = 10 -- ボールがこの距離内に入るとパリィ可能
local ParryKey = Enum.KeyCode.Q -- プレイヤーがパリィに使うキー (クライアント側で処理が必要)

-- サーバーイベントの設定 (クライアントからのパリィ操作を受け取る)
local ParryEvent = Instance.new("RemoteEvent")
ParryEvent.Name = "ParryAttempt"
ParryEvent.Parent = game.ReplicatedStorage

-- ボールを特定のターゲットに向かって動かす関数 (デモ用)
local function MoveBallTowardsPlayer(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local targetPosition = character:WaitForChild("HumanoidRootPart").Position
    
    -- ボールの初期位置をリセット
    BallPart.Position = CenterPart.Position + Vector3.new(30, 0, 30) 
    
    -- ボールをターゲットに向かって加速させる
    local direction = (targetPosition - BallPart.Position).Unit
    local speed = 50 
    BallPart.AssemblyLinearVelocity = direction * speed
end

-- パリィの判定ロジック
ParryEvent.OnServerEvent:Connect(function(player, isParrying)
    if isParrying then
        local character = player.Character
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        -- ボールとプレイヤーの距離を計算
        local distance = (BallPart.Position - rootPart.Position).Magnitude
        
        print(player.Name .. " がパリィを試みました。距離: " .. math.floor(distance) .. " studs")

        if distance < ParryRange then
            -- **パリィ成功！**
            print("--- " .. player.Name .. " はパリィに成功しました！ ---")
            
            -- ここにパリィ成功時の処理（ボールを跳ね返す、エフェクトを出すなど）を記述
            BallPart.AssemblyLinearVelocity = -BallPart.AssemblyLinearVelocity * 1.5 -- 速度を上げて跳ね返す
            
        else
            -- パリィ失敗
            print(player.Name .. " のパリィは早すぎるか遅すぎました。")
        end
    end
end)

-- ゲームが始まったらボールを動かす (デモ用)
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Wait()
    task.wait(5) -- 5秒待ってからボールを飛ばす
    MoveBallTowardsPlayer(player)
end)
