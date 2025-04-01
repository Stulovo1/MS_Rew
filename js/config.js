const DEFAULT_CONFIG = {
    search: {
        desktop: {
            limit: 35,
            interval: 5,
            multitab: false,
            engine: {
                name: "bing",
                settings: "Bing Desktop",
                url: "https://www.bing.com/search?q=",
                icon: "bi bi-search"
            }
        },
        mobile: {
            limit: 30,
            interval: 5,
            multitab: false,
            engine: {
                name: "bing",
                settings: "Bing Mobile",
                url: "https://www.bing.com/search?q=&mobile=1",
                icon: "bi bi-search"
            }
        }
    },
    terms: [
        // Популярные игры (100 запросов)
        ["Minecraft", "GTA V", "Fortnite", "League of Legends", "World of Warcraft", "Valorant", "Apex Legends", "Call of Duty", "FIFA 23", "Red Dead Redemption 2",
         "Cyberpunk 2077", "Elden Ring", "God of War", "The Last of Us", "Horizon Zero Dawn", "Death Stranding", "Ghost of Tsushima", "Assassin's Creed", "Far Cry 6", "Resident Evil",
         "Metro Exodus", "Doom Eternal", "Halo Infinite", "Forza Horizon 5", "Gran Turismo 7", "Escape from Tarkov", "Rust", "ARK", "DayZ", "Project Zomboid",
         "Dying Light 2", "Back 4 Blood", "It Takes Two", "Hades", "Disco Elysium", "Persona 5", "Final Fantasy VII", "Dragon Quest XI", "Monster Hunter Rise", "Nier Automata",
         "Devil May Cry 5", "Bayonetta 3", "Sekiro", "Bloodborne", "Dark Souls", "Demon's Souls", "Returnal", "Ratchet & Clank", "Spider-Man", "Batman Arkham",
         "Control", "Deathloop", "Psychonauts 2", "Guardians of the Galaxy", "Kena Bridge of Spirits", "Little Nightmares II", "Resident Evil Village", "Hitman 3", "Death's Door", "Chicory",
         "The Artful Escape", "Inscryption", "Loop Hero", "Wildermyth", "Tales of Arise", "Lost Judgment", "Life is Strange", "The Medium", "Scarlet Nexus", "Tales of Vesperia",
         "Ys IX", "Atelier Ryza", "Bravely Default II", "Octopath Traveler", "Triangle Strategy", "Monster Hunter Stories 2", "Shin Megami Tensei V", "The Great Ace Attorney", "Famicom Detective Club", "Story of Seasons",
         "Rune Factory 5", "Harvest Moon", "Stardew Valley", "My Time at Portia", "Garden Story", "Cozy Grove", "A Short Hike", "Unpacking", "TOEM", "The Gunk",
         "Sable", "Lake", "Before Your Eyes", "The Forgotten City", "Road 96", "12 Minutes", "The Artful Escape", "Genesis Noir", "Last Stop", "The Ascent",
         "Outriders", "Back 4 Blood", "Aliens Fireteam Elite", "Far Cry 6", "Riders Republic", "Forza Horizon 5", "Hot Wheels Unleashed", "WRC 10", "F1 2021", "MotoGP 21",
         "NBA 2K22", "Madden NFL 22", "NHL 22", "MLB The Show 21", "PGA Tour 2K21", "Tony Hawk's Pro Skater 1+2", "Skate 3", "Session", "Riders Republic", "Steep"]
    ]
}; 