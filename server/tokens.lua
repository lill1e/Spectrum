Spectrum.libs.Tokens = {}

Spectrum.libs.Tokens.randomToken = function(i)
    if i == 0 then
        return ""
    else
        return string.char(96 + math.random(26)) .. Spectrum.libs.Tokens.randomToken(i - 1)
    end
end

Spectrum.libs.Tokens.CreateToken = function(source)
    local token = Spectrum.libs.Tokens.randomToken(16)
    Spectrum.libs.tokens[token] = source
    return token
end
