-- LOVR 0.13 boiler plate
-- Written by Ben Ferguson, 2020
-- CC0

fRenderDelta = 0.0
sOperatingSystem = ''
fFPSAvg = 0.0
totalFrames = 0
hx, hy, hz = 0.0, 0.0, 0.0

m = lovr.filesystem.load('src/lib.lua'); m()

function lovr.load()
    -- set up logfile
    debug.init()

    -- print os info
    sOperatingSystem = lovr.getOS()
    debug.print('OS detected: ' .. sOperatingSystem)
    
    -- set up shaders
    defaultVertex = lovr.filesystem.read('src/default.vs')
    defaultFragment = lovr.filesystem.read('src/default.fs')
    
    shader = lovr.graphics.newShader(defaultVertex, defaultFragment, {})
    
    -- Set default shader values
    shader:send('liteColor', {1.0, 1.0, 1.0, 1.0})
    shader:send('ambience', {0.05, 0.05, 0.05, 1.0})
    shader:send('specularStrength', 0.5)
    shader:send('metallic', 32.0)
    
end

function lovr.update(dT)
    -- Per-frame ticks
    fRenderDelta = os.clock()
    totalFrames = totalFrames + 1
    local fr 
    if debug.showFPS or debug.logFPS then fr = 1/dt end 
    if debug.showFPS then 
        print('update delta', dt, '/ FPS: ', fr)
    end 
    if debug.logFPS then 
        fFPSAvg = fFPSAvg + fr
    end

    -- Light position updates
    shader:send('lightPos', { 2.0, 5.0, 0.0 })

    -- Adjust head position (for specular)
    if lovr.headset then 
        hx, hy, hz = lovr.headset.getPosition()
        shader:send('viewPos', { hx, hy, hz } )
    end
end

function lovr.draw()
    lovr.graphics.setShader(shader)
    --ground
    lovr.graphics.setColor(0.2, 0.6, 0.2, 1.0)
    shader:send('metallic', 1)
    shader:send('specularStrength', 0.1)
    lovr.graphics.box('fill', 0.0, -2.0, 0.0, 15.0, 0.1, 15.0, 0.0)
    
    lovr.graphics.setShader() -- Reset to default/unlit
    -- skybox
    lovr.graphics.setColor(0.2, 0.3, 0.7, 1.0)
    lovr.graphics.cube('fill', hx, hy, hz, 100.0, 0.0)
    
    
    -- reset color/shader variables
    lovr.graphics.setColor(1, 1, 1, 1)
    shader:send('metallic', 32)
    shader:send('specularStrength', 0.25)
    
    lovr.graphics.print('hello world', 0, 2, -3, .5)
    -- light
    lovr.graphics.sphere(2, 5, 0, 0.1)

    lovr.graphics.setShader()

    if debug.showFrameDelta then 
        fRenderDelta = os.clock() - fRenderDelta 
        print('frame render time', fRenderDelta)
    end
end

function lovr.quit()
    if debug.logFPS then 
        debug.print(round(fFPSAvg/totalFrames, 2))
    end
    debug.print('OK.')
end