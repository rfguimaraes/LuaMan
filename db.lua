maze = require "maze"

local db = {}

function db.load()
	db.loadImages()
	db.loadMazes()
	db.loadFonts()
    db.loadSounds()
end

function db.loadImages()
	local imgPath = "assets/images/"
	db.img  = 
	{
		player = love.graphics.newImage(imgPath.."luaman.png"),
		maze = love.graphics.newImage(imgPath.."maze.png"),
		enemy = love.graphics.newImage(imgPath.."ghost.png"),
        intro1 = love.graphics.newImage(imgPath.."01_sleep.png"),
        intro2 = love.graphics.newImage(imgPath.."02_ghosts.png"),
        intro3 = love.graphics.newImage(imgPath.."03_enter.png"),
        intro4 = love.graphics.newImage(imgPath.."04_wake.png"),
        intro5 = love.graphics.newImage(imgPath.."05_follow.png")
	}
end

function db.loadMazes()
	local mazePath = "assets/mazes/"
	local data1 = love.filesystem.load(mazePath.."level2.lua")()
	db.lvl =
	{
		maze.Maze(16,16,db.img.maze, data1.tileString, data1.quadInfo)	
	}
end

function db.loadFonts()
	local fontPath = "assets/fonts/"
	db.fonts =
    {
		title = love.graphics.newFont(fontPath.."Cubellan Bold.ttf", 60),
		header = love.graphics.newFont(fontPath.."Cubellan.ttf", 50),
		default = love.graphics.newFont(fontPath.."Cubellan.ttf", 20),
		UI = love.graphics.newFont(fontPath.."Cubellan.ttf", 15)

	}
end

function db.loadSounds()
    local soundPath = "assets/sounds/"
    local bgmPath = soundPath.."/bgm/"
    local sfxPath = soundPath.."/sfx/"
    db.bgm = 
    {
        intro = love.audio.newSource(bgmPath.."The Organ NES.wav"),
        game = love.audio.newSource(bgmPath.."Mr. Blue Sky NES.wav")
    }
    db.bgm.intro:setLooping(true)
    db.bgm.game:setLooping(true)
    db.sfx =
    {
        point = love.audio.newSource(sfxPath.."Collect_Point_00.wav", "static"),
        power = love.audio.newSource(sfxPath.."Collect_Point_01.wav", "static"),
        die = love.audio.newSource(sfxPath.."Explosion_00.wav", "static"),
        kill = love.audio.newSource(sfxPath.."Explosion_02.wav", "static"),
        win = love.audio.newSource(sfxPath.."Jingle_Achievement_00.wav", "static")
    }
end

return db
