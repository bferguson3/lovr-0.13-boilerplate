-- LOVR 0.13 boiler plate
-- Written by Ben Ferguson, 2020
-- CC0

fRenderDelta = 0.0
sOperatingSystem = ''
fFPSAvg = 0.0
totalFrames = 0

m = lovr.filesystem.load('src/lib.lua'); m()

function lovr.load()
    -- set up logfile
    debug.init()

    -- print os info
    sOperatingSystem = lovr.getOS()
    debug.print('OS detected: ' .. sOperatingSystem)
    
    -- set up shader
    defaultVertex = [[
        out vec3 FragmentPos;
        out vec3 Normal;

        vec4 position(mat4 projection, mat4 transform, vec4 vertex) { 
            Normal = lovrNormal;
            FragmentPos = (lovrModel * vertex).xyz;
        
            return projection * transform * vertex;
        }
    ]]
    defaultFragment = [[
        uniform vec4 liteColor;

        uniform vec4 ambience;
    
        in vec3 Normal;
        in vec3 FragmentPos;
        uniform vec3 lightPos;

        uniform vec3 viewPos;
        uniform float specularStrength;
        uniform float metallic;
        
        vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
        {    
            //diffuse
            vec3 norm = normalize(Normal);
            vec3 lightDir = normalize(lightPos - FragmentPos);
            float diff = max(dot(norm, lightDir), 0.0);
            vec4 diffuse = diff * liteColor;
            
            //specular
            vec3 viewDir = normalize(viewPos - FragmentPos);
            vec3 reflectDir = reflect(-lightDir, norm);
            float spec = pow(max(dot(viewDir, reflectDir), 0.0), metallic);
            vec4 specular = specularStrength * spec * liteColor;
            
            vec4 baseColor = graphicsColor * texture(image, uv);            
            //vec4 objectColor = baseColor * vertexColor;

            return baseColor * (ambience + diffuse + specular);
        }
    ]]
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
    shader:send('lightPos', { 0.0, -1.0, -3.0 })

    -- Adjust head position (for specular)
    if lovr.headset then 
        hx, hy, hz = lovr.headset.getPosition()
        shader:send('viewPos', { hx, hy, hz } )
    end
end

function lovr.draw()
    lovr.graphics.setShader(shader)

    lovr.graphics.setShader() -- Reset to default/unlit
    lovr.graphics.setColor(1, 1, 1, 1)
    lovr.graphics.print('hello world', 0, 2, -3, .5)
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