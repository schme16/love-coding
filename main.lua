
-- Variables

local map -- stores tiledata
local mapWidth, mapHeight -- width and height in tiles

local mapX, mapY -- view x,y in tiles. can be a fractional value like 3.25.

local tilesDisplayWidth, tilesDisplayHeight -- number of tiles to show
local zoomX, zoomY

local tilesetImage
local tileSize -- size of tiles in pixels
local tileQuads = {} -- parts of the tileset used for different tiles
local tilesetSprite

-- Start and quit

function love.load()
    bgm = love.audio.newSource("music/cosine.mp3")
    bgm:setVolume(0.1) -- 10% of ordinary volume
    bgm:setLooping(true)
    love.audio.play(bgm)

    setupMap()
    setupMapView()
    setupTileset("img/tileset.png")
end

function love.quit()

end

-- Update

function love.update(dt)
    if love.keyboard.isDown("up")  then
    moveMap(0, -0.2 * tileSize * dt)
  end
  if love.keyboard.isDown("down")  then
    moveMap(0, 0.2 * tileSize * dt)
  end
  if love.keyboard.isDown("left")  then
    moveMap(-0.2 * tileSize * dt, 0)
  end
  if love.keyboard.isDown("right")  then
    moveMap(0.2 * tileSize * dt, 0)
  end
end

-- Draw

function love.draw()
    love.graphics.draw(tilesetBatch,
        math.floor(-zoomX*(mapX%1)*tileSize), math.floor(-zoomY*(mapY%1)*tileSize),
        0, zoomX, zoomY)
  love.graphics.print("FPS: "..love.timer.getFPS(), 10, 20)
end


-- Input

function love.mousereleased(x, y, button)

end

function love.mousepressed(x, y, button)

end

function love.keypressed(key, unicode)

end

function love.keyreleased(key, unicode)

end

-- Other

function love.focus(f)

end

--------------------------------------------------------------------------

function setupMap()
  mapWidth = 60
  mapHeight = 40

  map = {}
  for x=1,mapWidth do
    map[x] = {}
    for y=1,mapHeight do
      map[x][y] = math.random(0,3)
    end
  end
end

function setupMapView()
  mapX = 1
  mapY = 1
  tilesDisplayWidth = 26
  tilesDisplayHeight = 20

  zoomX = 1
  zoomY = 1
end

function setupTileset(tileset, size)
  tilesetImage = love.graphics.newImage(tileset)
  tilesetImage:setFilter("nearest", "linear") -- this "linear filter" removes some artifacts if we were to scale the tiles
  tileSize = size or 32

  -- grass
  tileQuads[0] = loadTile(0, 19, tileSize, tilesetImage)
  -- kitchen floor tile
  tileQuads[1] = loadTile(2, 0, tileSize, tilesetImage)
  -- parquet flooring
  tileQuads[2] = loadTile(4, 0, tileSize, tilesetImage)
  -- middle of red carpet
  tileQuads[3] = loadTile(3, 9, tileSize, tilesetImage)

  tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, tilesDisplayWidth * tilesDisplayHeight)

  updateTilesetBatch()
end

function loadTile(x, y, size, image)
    return love.graphics.newQuad(x * size, y * size, size, size,
        image:getWidth(), image:getHeight())
end

function updateTilesetBatch()
  tilesetBatch:clear()
  for x=0, tilesDisplayWidth-1 do
    for y=0, tilesDisplayHeight-1 do
      tilesetBatch:addq(tileQuads[map[x+math.floor(mapX)][y+math.floor(mapY)]],
        x*tileSize, y*tileSize)
    end
  end
end

-- central function for moving the map
function moveMap(dx, dy)
  oldX = mapX
  oldY = mapY
  mapX = math.max(math.min(mapX + dx, mapWidth - tilesDisplayWidth), 1)
  mapY = math.max(math.min(mapY + dy, mapHeight - tilesDisplayHeight), 1)
  -- only update if we actually moved
  if math.floor(mapX) ~= math.floor(oldX) or math.floor(mapY) ~= math.floor(oldY) then
    updateTilesetBatch()
  end
end
