maze = require "maze"

local db = {}

function db.load()
	db.loadImages()
	db.loadMazes()
	db.loadFonts()
end

function db.loadImages()
	local imgPath = "assets/images/"
	db.img  = 
	{
		player = love.graphics.newImage(imgPath.."luaman.png"),
		maze = love.graphics.newImage(imgPath.."maze.png"),
		enemy = love.graphics.newImage(imgPath.."ghost.png")
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
	db.fonts = {
		title = love.graphics.newFont(fontPath.."Cubellan Bold.ttf", 60),
		header = love.graphics.newFont(fontPath.."Cubellan.ttf", 50),
		default = love.graphics.newFont(fontPath.."Cubellan.ttf", 20)
	}
end
	

return db