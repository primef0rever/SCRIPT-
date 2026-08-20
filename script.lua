local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function AntiKick(...)
    warn("!!! ЗАБЛОКИРОВАНА ПОПЫТКА КИКА !!!")
    return nil -- Ничего не делаем
end

local OldKick
if hookfunction then
    OldKick = hookfunction(LocalPlayer.Kick, AntiKick)
end

LocalPlayer.Kick = AntiKick

setreadonly(LocalPlayer, true) 

print("Anti-Kick Shield активирован. Защита от скриптов включена.")
