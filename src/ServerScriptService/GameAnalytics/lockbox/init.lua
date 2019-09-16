local lockbox = {ALLOW_INSECURE = false}

for i,v in pairs(script:GetChildren()) do
	lockbox[v.Name] = v
end

return lockbox