Spectrum = {
    PlayerData = {
        id = nil,
        health = 200,
        armor = 0,
        dead = false,
        money = {
            clean = 0,
            dirty = 0
        },
        staff = 0,
        ped = "mp_m_freemode_01",
        position = {
            x = -269.4,
            y = -955.3,
            z = 31.2,
            heading = 205.8
        },
        attributes = {},
        items = {},
        weapons = {},
        ammo = {
            AMMO_MG = 0,
            AMMO_SMG = 0,
            AMMO_RIFLE = 0,
            AMMO_PISTOL = 0,
            AMMO_SNIPER = 0,
            AMMO_SHOTGUN = 0
        },
        skin = {
            Sex = 1,
        },
        identifiers = {},
        jobs = {},
        licenses = {}
    },
    Loaded = false,
    Spawned = false,
    DeathTimer = nil,
    CanRespawn = false,
    CanRevive = false,
    InventoryLock = false,
    AmmoLock = true,
    Garage = {
        current = nil
    },
    StaffMenu = {
        target = nil,
        playerType = 1,
        spectating = false,
        spectateData = {
            entrance = nil,
            player = nil,
            ped = nil,
            id = nil
        }
    },
    items = {},
    jobs = {},
    stores = {},
    players = {},
    activePlayers = 0,
    reports = {},
    vehicles = {},
    vehicleCount = 0,
    properties = {},
    currentStore = {
        current = nil,
        currentLoc = nil
    },
    libs = {},
    misc = {},
    skin = {
        IsEditing = false,
        Outfit = false
    },
    Job = {
        current = nil,
        state = {},
        vehicle = nil,
        location = nil,
        vehicleBlip = nil,
        fund = nil
    },
    Storage = {},
    bills = {},
    outfits = {},
    Environment = {
        weather = "EXTRASUNNY",
        time = {
            base = 0,
            hour = 0,
            minute = 0
        },
        update = false,
        baseChangeTime = 0
    }
}
