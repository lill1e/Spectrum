Config.Drugs = {
    Dealer = {
        Items = {
            weed_bag = {
                max = 3,
                range = { 50, 75 }
            },
            meth_bag = {
                max = 3,
                range = { 125, 175 }
            },
            cocaine_bag = {
                max = 3,
                range = { 250, 315 }
            },
        }
    },
    Types = {
        Coke = {
            origin = "process",
            stages = {
                debug = {
                    text = "~o~Grab Shipment",
                    endText = "You pick up the package outside and find important ~o~production materials",
                    position = vector3(1088.692, -3187.55, -38.99346),
                    input = {
                        items = {}
                    },
                    output = {
                        items = { "cocaine_raw" },
                        count = 5
                    },
                    threshold = 1,
                    cooldown = 5000
                },
                pour = {
                    text = "~o~Pour Liquid Cocaine",
                    endText = "You pour the ~b~Cocaine ~s~into a mold",
                    position = vector3(1087.192, -3196.87, -38.9935),
                    input = {
                        items = { "cocaine_raw" },
                        count = 1
                    },
                    output = {
                        items = { "cocaine_mold" },
                        count = 1
                    },
                    threshold = 1,
                    cooldown = 5000
                },
                process = {
                    text = "~y~Process Liquid Cocaine",
                    endText = "You grab ~b~Cocaine ~s~from the oven, in what seems to feel like powder but still solid",
                    position = vector3(1096.958, -3193.004, -38.9935),
                    input = {
                        items = { "cocaine_mold" },
                        count = 1
                    },
                    output = {
                        items = { "cocaine_solid" },
                        displayItem = "cocaine_solid",
                        count = 1
                    },
                    background = true,
                    threshold = 8,
                    cooldown = 10000
                    -- cooldown = 60000 * 2.5
                },
                mash = {
                    text = "~o~Break Solid Cocaine",
                    endText = "You mash ~b~Cocaine ~s~resulting in a rough powdery substance",
                    position = vector3(1088.75, -3195.906, -38.99348),
                    input = {
                        items = { "cocaine_solid" },
                        count = 1
                    },
                    output = {
                        items = { "cocaine_bowl" },
                        count = 1
                    },
                    threshold = 1,
                    cooldown = 5000,
                    scene = {
                        coords = vector3(0.0, 0.0, 0.0),
                        rot = vector3(0.0, 0.0, 0.0),
                        offset = vector3(0.0, 0.0, 0.0),
                        objects = {
                            obj = "animhere"
                        },
                        start = 0.0,
                        stop = 0.0,
                        dict = "",
                        selfAnim = ""
                    }
                },
                sift = {
                    text = "~b~Break Up Cocaine",
                    endText = "You sift through the ~b~Cocaine ~s~resulting in smoother product",
                    position = vector3(1090.63, -3196.596, -38.9935),
                    input = {
                        items = { "cocaine_bowl" },
                        count = 1
                    },
                    output = {
                        items = { "cocaine_bowl_ready" },
                        count = 1
                    },
                    threshold = 1,
                    cooldown = 10000
                    -- cooldown = 60000
                },
                bag = {
                    text = "~b~Bag Cocaine",
                    endText = "You weigh the ~b~Cocaine ~s~and place it in bags",
                    position = vector3(1099.608, -3194.29, -38.99348),
                    input = {
                        items = { "cocaine_bowl_ready" },
                        count = 1
                    },
                    output = {
                        items = { "cocaine_bag" },
                        count = 40
                    },
                    threshold = 1,
                    cooldown = 10000
                    -- cooldown = 60000
                }
            }
        }
    },
    Interiors = {
        [247553] = "Coke",
        [247041] = "Meth",
        [247297] = "Weed"
    }
}
