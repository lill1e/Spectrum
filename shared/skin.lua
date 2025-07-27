Config.Skin = {
    Models = { "mp_m_freemode_01", "mp_f_freemode_01" },
    Parents = {
        OrderDad = {
            "Benjamin",
            "Daniel",
            "Joshua",
            "Noah",
            "Andrew",
            "Joan",
            "Alex",
            "Isaac",
            "Evan",
            "Ethan",
            "Vincent",
            "Angel",
            "Diego",
            "Adrian",
            "Gabriel",
            "Michael",
            "Santiago",
            "Kevin",
            "Louis",
            "Samuel",
            "Anthony",
            "John",
            "Niko",
            "Claude"
        },
        OrderMom = {
            "Hannah",
            "Audrey",
            "Jasmine",
            "Giselle",
            "Amelia",
            "Isabella",
            "Zoe",
            "Ava",
            "Camilla",
            "Violet",
            "Sophia",
            "Eveline",
            "Nicole",
            "Ashley",
            "Grace",
            "Brianna",
            "Natalie",
            "Olivia",
            "Elizabeth",
            "Charlotte",
            "Emma",
            "Misty"
        },
        Dad = {
            Benjamin = 0,
            Daniel = 1,
            Joshua = 2,
            Noah = 3,
            Andrew = 4,
            Joan = 5,
            Alex = 6,
            Isaac = 7,
            Evan = 8,
            Ethan = 9,
            Vincent = 10,
            Angel = 11,
            Diego = 12,
            Adrian = 13,
            Gabriel = 14,
            Michael = 15,
            Santiago = 16,
            Kevin = 17,
            Louis = 18,
            Samuel = 19,
            Anthony = 20,
            John = 42,
            Niko = 43,
            Claude = 44
        },
        Mom = {
            Hannah = 21,
            Audrey = 22,
            Jasmine = 23,
            Giselle = 24,
            Amelia = 25,
            Isabella = 26,
            Zoe = 27,
            Ava = 28,
            Camilla = 29,
            Violet = 30,
            Sophia = 31,
            Eveline = 32,
            Nicole = 33,
            Ashley = 34,
            Grace = 35,
            Brianna = 36,
            Natalie = 37,
            Olivia = 38,
            Elizabeth = 39,
            Charlotte = 40,
            Emma = 41,
            Misty = 45
        }
    },
    Features = {
        -- A Feature is:
        -- feature: Number
        -- gridType: H (0) | H+V (1) | nil
        -- gridLabels: String[left, right, top?, bottom?]
        Nose = {
            gridType = 1,
            features = { 0, 1 },
            gridLabels = { "Narrow", "Wide", "Up", "Down" },
            inverseX = false,
            inverseY = false
        },
        NoseProfile = {
            gridType = 1,
            features = { 2, 3 },
            gridLabels = { "Short", "Long", "Crooked", "Curved" },
            inverseX = true,
            inverseY = false
        },
        NoseTip = {
            gridType = 1,
            features = { 5, 4 },
            gridLabels = { "Broken Left", "Broken Right", "Tip Up", "Tip Down" },
            inverseX = false,
            inverseY = true
        },
        Brow = {
            gridType = 1,
            features = { 7, 6 },
            gridLabels = { "In", "Out", "Up", "Down" },
            inverseX = false,
            inverseY = false
        },
        Cheekbones = {
            gridType = 1,
            features = { 9, 8 },
            gridLabels = { "In", "Out", "Up", "Down" },
            inverseX = false,
            inverseY = false
        },
        Cheeks = {
            gridType = 0,
            features = { 10 },
            gridLabels = { "Gaunt", "Puffed" },
            inverseX = true
        },
        Eyes = {
            gridType = 0,
            features = { 11 },
            gridLabels = { "Squint", "Wide" },
            inverseX = true
        },
        Lips = {
            gridType = 0,
            features = { 12 },
            gridLabels = { "Thin", "Fat" },
            inverseX = true
        },
        Jaw = {
            gridType = 1,
            features = { 13, 14 },
            gridLabels = { "Narrow", "Wide", "Round", "Square" },
            inverseX = false,
            inverseY = false
        },
        ChinProfile = {
            gridType = 1,
            features = { 16, 15 },
            gridLabels = { "In", "Out", "Up", "Down" },
            inverseX = false,
            inverseY = false
        },
        ChinShape = {
            gridType = 1,
            features = { 17, 18 },
            gridLabels = { "Square", "Pointed", "Rounded", "Bum" },
            inverseX = true,
            inverseY = false
        }
    },
    Overlays = {
        -- An Overlay is:
        -- overlay: Number
        -- colour: Boolean
        -- opacity: Boolean
        Blemishes = {
            overlay = 0,
            colour = false,
            opacity = true
        },
        FacialHair = {
            overlay = 1,
            colour = true,
            opacity = true
        },
        Eyebrows = {
            overlay = 2,
            colour = true,
            opacity = true
        },
        Ageing = {
            overlay = 3,
            colour = false,
            opacity = true
        },
        Makeup = {
            overlay = 4,
            colour = true,
            opacity = true
        },
        Blush = {
            overlay = 5,
            colour = false,
            opacity = true
        },
        Complexion = {
            overlay = 6,
            colour = false,
            opacity = true
        },
        SunDamage = {
            overlay = 7,
            colour = false,
            opacity = true
        },
        Lipstick = {
            overlay = 8,
            colour = true,
            opacity = true
        },
        MolesFreckles = {
            overlay = 9,
            colour = false,
            opacity = true
        },
        ChestHair = {
            overlay = 10,
            colour = false,
            opacity = false
        },
        BodyBlemishes = {
            overlay = 11,
            colour = false,
            opacity = false
        },
        AddBodyBlemishes = {
            overlay = 12,
            colour = false,
            opacity = false
        }
    },
    Components = {
        -- A Component is a Number
        -- component: Number
        Head = 0,
        Mask = 1,
        Arms = 3,
        Pants = 4,
        Bags = 5,
        Shoes = 6,
        Chains = 7,
        Undershirt = 8,
        Vest = 9,
        Decals = 10,
        Overshirt = 11
    },
    Props = {
        Hats = 0,
        Glasses = 1,
        Ears = 2,
        Watches = 6,
        Bracelets = 7
    },
    Hair = {
        {
            "Close Shave", "Buzzcut", "Faux Hawk",
            "Hipster Shaved", "Side Parting Spiked", "Shorter Cut",
            "Biker", "Ponytail", "Cornrows",
            "Slicked", "Short Brushed", "Spikey",
            "Caesar", "Chopped", "Dreads",
            "Long Hair", "Shaggy Curls", "Surfer Dude",
            "Short Side Part", "High Slicked Sides", "Long Slicked",
            "Hipster Youth", "Mullet", "N/A",
            "Classic Cornrows", "Palm Cornrows", "Lightning Cornrows",
            "Whipped Cornrows", "Zig Zag Cornrows", "Snail Cornrows",
            "Hightop", "Loose Swept Back", "Undercut Swept Back",
            "Undercut Swept Side", "Spiked Mohawk", "Mod",
            "Layered Mod", "Buzzcut", "Faux Hawk",
            "Hipster", "Side Parting", "Shorter Cut",
            "Biker", "Ponytail", "Cornrows",
            "Slicked", "Short Brushed", "Spikey",
            "Caesar", "Chopped", "Dreads",
            "Long Hair", "Shaggy Curls", "Surfer Dude",
            "Short Side Part", "High Slicked Sides", "Long Slicked",
            "Hipster Youth", "Mullet", "Classic Cornrows",
            "Palm Cornrows", "Lightning Cornrows", "Whipped Cornrows",
            "Zig Zag Cornrows", "Snail Cornrows", "Hightop",
            "Loose Swept Back", "Undercut Swept Back", "Undercut Swept Side",
            "Spiked Mohawk", "Mod", "Layered Mod",
            "Flattop", "Military Buzzcut", "Impotent Rage",
            "Afro Faded", "Top Knot", "Two Block",
            "Shaggy Mullet", "Short Curls Fade", "Curtains",
            "Knotless Braids"
        },
        {
            "Close Shave", "Short", "Layered Bob",
            "Pigtails", "Ponytail", "Braided Mohawk",
            "Braids", "Bob", "Faux Hawk",
            "French Twist", "Long Bob", "Loose Tied",
            "Pixie", "Shaved Bangs", "Top Knot",
            "Wavy Bob", "Pin Up Girl", "Messy Bun",
            "Flapper Bob", "Tight Bun Black", "Twisted Bob",
            "Big Bangs", "Braided Top Knot", "Mullet",
            "N/A", "Pinched Cornrows", "Leaf Cornrows",
            "Zig Zag Cornrows", "Pigtail Bangs", "Wave Braids",
            "Coil Braids", "Rolled Quiff", "Loose Swept Back",
            "Undercut Swept Back", "Undercut Swept Side", "Spiked Mohawk",
            "Bandana and Braid", "Skinbyrd", "Layered Mod",
            "Short", "Layered Bob", "Pigtails",
            "Ponytail", "Braided Mohawk", "Braids",
            "Bob", "Faux Hawk", "French Twist",
            "Long Bob", "Loose Tied", "Pixie",
            "Shaved Bangs", "Top Knot", "Wavy Bob",
            "Messy Bun", "Pin Up Girl", "Tight Bun Black",
            "Twisted Bob", "Flapper Bob", "Big Bangs",
            "Braided Top Knot", "Mullet", "Pinched Cornrows",
            "Leaf Cornrows", "Zig Zag Cornrows", "Pigtail Bangs",
            "Wave Braids", "Coil Braids", "Rolled Quiff",
            "Loose Swept Back", "Undercut Swept Back", "Undercut Swept Side",
            "Spiked Mohawk", "Bandana and Braid", "Layered Mod",
            "Skinbyrd", "Neat Bun", "Short Bob",
            "Impotent Rage", "Afro", "Pixie Wavy",
            "Short Tucked Bob", "Shaggy Mullet", "Buzzcut",
            "Baby Braids", "Knotless Braids", "Shaggy Octopus"
        }
    },
    EyeColours = {
        "Black",
        "Light Blue/Green",
        "Dark Blue",
        "Brown",
        "Darker Brown",
        "Light Brown",
        "Blue",
        "Light Blue",
        "Pink",
        "Yellow",
        "Purple",
        "Black",
        "Dark Green",
        "Light Brown",
        "Yellow/Black",
        "Light Colored Spiral",
        "Shiny Red",
        "Shiny Blue/Red",
        "Black/Light Blue",
        "White/Red",
        "Green Snake",
        "Red Snake",
        "Dark Blue Snake",
        "Dark Yellow",
        "Bright Yellow",
        "All Black",
        "Red Small Pupil",
        "Devil Blue/Black",
        "White Small/Pupil",
        "Glossed Over"
    },
    Disabled = {
        Components = {},
        Props = {
            [0] = {
                [189] = true,
                [190] = true,
                [200] = true,
                [201] = true,
                [206] = true,
                [207] = true
            }
        }
    },
    Menu = {
        Features = {
            { displayName = "Brow",         type = "Features", name = "Brow" },
            { displayName = "Eyes",         type = "Features", name = "Eyes" },
            { displayName = "Nose",         type = "Features", name = "Nose" },
            { displayName = "Nose Profile", type = "Features", name = "NoseProfile" },
            { displayName = "Nose Tip",     type = "Features", name = "NoseTip" },
            { displayName = "Cheekbones",   type = "Features", name = "Cheekbones" },
            { displayName = "Cheeks",       type = "Features", name = "Cheeks" },
            { displayName = "Lips",         type = "Features", name = "Lips" },
            { displayName = "Jaw",          type = "Features", name = "Jaw" },
            { displayName = "Chin Profile", type = "Features", name = "ChinProfile" },
            { displayName = "Chin Shape",   type = "Features", name = "ChinShape" }
        },
        Appearance = {
            { displayName = "Hair",             type = "Component", name = 2 },
            { displayName = "Eyebrows",         type = "Overlays",  name = "Eyebrows" },
            { displayName = "Facial Hair",      type = "Overlays",  name = "FacialHair" },
            { displayName = "Skin Blemishes",   type = "Overlays",  name = "Blemishes" },
            { displayName = "Skin Aging",       type = "Overlays",  name = "Ageing" },
            { displayName = "Skin Complexion",  type = "Overlays",  name = "Complexion" },
            { displayName = "Moles & Freckles", type = "Overlays",  name = "MolesFreckles" },
            { displayName = "Skin Damage",      type = "Overlays",  name = "SunDamage" },
            { displayName = "Eye Color",        type = "EyeColour", name = "" },
            { displayName = "Eye Makeup",       type = "Overlays",  name = "Makeup" },
            { displayName = "Blusher",          type = "Overlays",  name = "Blush" },
            { displayName = "Lipstick",         type = "Overlays",  name = "Lipstick" },
        },
        Apparel = {
            { displayName = "Mask",       type = "Component", name = 1 },
            { displayName = "Arms",       type = "Component", name = 3 },
            { displayName = "Pants",      type = "Component", name = 4 },
            { displayName = "Bags",       type = "Component", name = 5 },
            { displayName = "Shoes",      type = "Component", name = 6 },
            { displayName = "Chain",      type = "Component", name = 7 },
            { displayName = "Undershirt", type = "Component", name = 8 },
            { displayName = "Vest",       type = "Component", name = 9 },
            { displayName = "Overshirt",  type = "Component", name = 11 },
            { displayName = "Hat",        type = "Prop",      name = 0 },
            { displayName = "Glasses",    type = "Prop",      name = 1 },
            { displayName = "Ears",       type = "Prop",      name = 2 },
            { displayName = "Left Arm",   type = "Prop",      name = 6 },
            { displayName = "Right Arm",  type = "Prop",      name = 7 }
        }
    }
}
