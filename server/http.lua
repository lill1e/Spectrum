SetHttpHandler(function(req, res)
    if req.headers.v then
        if req.headers.v == Spectrum.vId then
            local body
            req.setDataHandler(function(data)
                local tbl = json.decode(data)
                if tbl then
                    body = tbl
                end
            end)
            if req.method == "GET" then
                if req.path == "/ping" then
                    res.writeHead(200, { ["Content-Type"] = "application/json" })
                    res.send("{}")
                elseif req.path == "/users" then
                    if req.headers.id and tonumber(req.headers.id) then
                        if Spectrum.players[req.headers.id] then
                            res.writeHead(200, { ["Content-Type"] = "application/json" })
                            res.send(json.encode(Spectrum.players[req.headers.id]))
                        else
                            res.writeHead(404)
                            res.send()
                        end
                    else
                        res.writeHead(200, { ["Content-Type"] = "application/json" })
                        res.send(json.encode(Spectrum.players))
                    end
                else
                    res.writeHead(404)
                    res.send()
                end
            else
                res.writeHead(404)
                res.send()
            end
        else
            res.writeHead(401)
            res.send()
        end
    else
        res.writeHead(401)
        res.send()
    end
end)
