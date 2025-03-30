Scaleform = {}
Scaleform.__index = Scaleform

function Scaleform.Load(movie)
    local movieInstance = RequestScaleformMovie(movie)
    while not HasScaleformMovieLoaded(movieInstance) do Wait(0) end
    return movieInstance
end

function Scaleform.Create(movie, method, ...)
    local scaleform = Scaleform.Load(movie)
    local scaleformParameters = { ... }
    BeginScaleformMovieMethod(scaleform, method)
    for _, parameter in ipairs(scaleformParameters) do
        if type(parameter) == "number" then
            PushScaleformMovieMethodParameterInt(parameter)
        elseif type(parameter) == "string" then
            PushScaleformMovieMethodParameterString(parameter)
        elseif type(parameter) == "boolean" then
            PushScaleformMovieMethodParameterBool(parameter)
        end
    end
    EndScaleformMovieMethod()
    return setmetatable({ handle = scaleform }, Scaleform)
end

function Scaleform:Draw()
    DrawScaleformMovieFullscreen(self.handle, 255, 255, 255, 255, -1)
end

Spectrum.libs.Scaleform = Scaleform
