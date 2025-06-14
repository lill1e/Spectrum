Scaleform = {}
Scaleform.__index = Scaleform

function Scaleform.Load(movie)
    local movieInstance = RequestScaleformMovie(movie)
    while not HasScaleformMovieLoaded(movieInstance) do Wait(0) end
    return setmetatable({ handle = movieInstance }, Scaleform)
end

function Scaleform:Call(method, ...)
    local parameters = { ... }
    BeginScaleformMovieMethod(self.handle, method)
    for _, parameter in ipairs(parameters) do
        if type(parameter) == "number" then
            PushScaleformMovieMethodParameterInt(parameter)
        elseif type(parameter) == "string" then
            PushScaleformMovieMethodParameterString(parameter)
        elseif type(parameter) == "boolean" then
            PushScaleformMovieMethodParameterBool(parameter)
        end
    end
    EndScaleformMovieMethod()
end

function Scaleform:DrawFullscreen()
    DrawScaleformMovieFullscreen(self.handle, 255, 255, 255, 255, -1)
end

function Scaleform:Draw(x, y, width, height)
    DrawScaleformMovie(self.handle, x or 0, y or 0, width or 0, height or 0, 255, 255, 255, 255, 0)
end

Spectrum.libs.Scaleform = Scaleform
