altura_tela = 480
largura_tela = 320
MaxMeteoros = 15
meteoros_Destruidos = 0
objetivo = 50

aviao_14bis = {
    src = "imagens/14bis.png",
    largura = 55,
    altura = 63,
    x = largura_tela/2 -64/2,
    y = altura_tela - 64/2,
    tiros = {}
}

function daTiro()
    disparo:play()
    local tiro = {
        x = aviao_14bis.x + aviao_14bis.largura/2,
        y = aviao_14bis.y,
        largura = 18,
        altura = 18
    }

    table.insert(aviao_14bis.tiros, tiro)
end

function moveTiros()
    for i = #aviao_14bis.tiros,1,-1 do
        if aviao_14bis.tiros[i].y > 0 then
            aviao_14bis.tiros[i].y = aviao_14bis.tiros[i].y -1
        else 
            table.remove(aviao_14bis.tiros, i)
        end
    end

end

function temColisao( X1, Y1, L1, A1, X2, Y2, L2, A2)
    return X2 < X1 + L1 and
           X1 < X2 + L2 and
           Y1 < Y2 + A2 and
           Y2 < Y1 + A1
end



function destroiAviao()
    destruicao:play()
    aviao_14bis.src = "imagens/explosao_nave.png"
    aviao_14bis.imagem = love.graphics.newImage(aviao_14bis.src)
    aviao_14bis.largura = 67
    aviao_14bis.altura = 77
end

meteoros = {}

function removeMeteoros()
    for i = #meteoros, 1, -1 do
        if meteoros[i].y > altura_tela then
            table.remove(meteoros, i)
        end
    end
end

function criaMetoro()
    meteoro = {
        x = math.random(largura_tela),
        y = -80,
        largura = 50,
        altura = 44,
        peso = math.random(4),
        deslocamento_horizontal = math.random(-2,2)
    }
    table.insert(meteoros, meteoro)
end

function moveMeteoros()
    for k,meteoro in pairs(meteoros) do
        meteoro.y = meteoro.y + meteoro.peso
        meteoro.x = meteoro.x + meteoro.deslocamento_horizontal
    end
end



function move14bis()
    if love.keyboard.isDown('up') then
        aviao_14bis.y = aviao_14bis.y -2
    end

    if love.keyboard.isDown('down') then
        aviao_14bis.y = aviao_14bis.y +2
    end

    if love.keyboard.isDown('left') then
        aviao_14bis.x = aviao_14bis.x -2
    end

    if love.keyboard.isDown('right') then
        aviao_14bis.x = aviao_14bis.x +2
    end
end

function trocaMusicaFundo()
    musicaAmbiente:stop()
    game_over:play()
end

function colisaoAviao()
    for k, meteoro in pairs(meteoros) do
        if temColisao(meteoro.x, meteoro.y, meteoro.largura, meteoro.altura, 
        aviao_14bis.x, aviao_14bis.y, aviao_14bis.largura, aviao_14bis.altura) then

            trocaMusicaFundo()
                    destroiAviao()
                    FIM_JOGO = true
        end
    end
end

function colisaoTiros()
   for i = #aviao_14bis.tiros, 1, -1 do
        for j= #meteoros, 1,-1 do
            if temColisao(aviao_14bis.tiros[i].x, aviao_14bis.tiros[i].y, aviao_14bis.tiros[i].largura, aviao_14bis.tiros[i].altura,
            meteoros[j].x, meteoros[j].y, meteoros[j].largura, meteoros[j].altura ) then
                meteoros_Destruidos = meteoros_Destruidos +1
                table.remove(meteoros, j)
                table.remove(aviao_14bis.tiros, i)
                break
            end
        end
   end
end

function checaColisao()
    colisaoAviao()
    colisaoTiros()
end

function objetivoConcluido()
    if meteoros_Destruidos >= objetivo then
        vencedor = true

        musicaAmbiente:stop()
        vitoria:play()
    end
end

-- Load some default values for our rectangle.
function love.load()

    math.randomseed(os.time())
    love.window.setMode(largura_tela, altura_tela, {resizable = false})
    love.window.setTitle("14-bis X Asteroids")

    background = love.graphics.newImage("imagens/background.png")
    game_over_img = love.graphics.newImage("imagens/gameover.png")
    vencedor_img = love.graphics.newImage("imagens/vencedor.png")
    aviao_14bis.imagem = love.graphics.newImage(aviao_14bis.src)
    meteoro_img = love.graphics.newImage("imagens/meteoro.png")
    tiro_img = love.graphics.newImage("imagens/tiro.png")

    musicaAmbiente = love.audio.newSource("audios/ambiente.wav", "static")
    musicaAmbiente:setLooping(true)
    musicaAmbiente:play()
   
    destruicao = love.audio.newSource("audios/destruicao.wav", "static")
    game_over = love.audio.newSource("audios/game_over.wav", "static")
    disparo = love.audio.newSource("audios/disparo.wav", "stream")
    vitoria = love.audio.newSource("audios/winner.wav", "stream")
end

-- Increase the size of the rectangle every frame.
function love.update(dt)
    if not FIM_JOGO and not vencedor then
        if love.keyboard.isDown('up','down','left','right') then
            move14bis()
        end

        removeMeteoros()

        if #meteoros < MaxMeteoros then
            criaMetoro()
        end
        moveMeteoros()
        moveTiros()
        checaColisao()
        objetivoConcluido()
    end
end

function love.keypressed(tecla)
    if tecla == "escape" then
        love.event.quit()
    elseif tecla == "space" then
        daTiro()
    end
end

-- Draw a coloured rectangle.
function love.draw()
    
    love.graphics.draw(background, 0,0)
    
    love.graphics.draw(aviao_14bis.imagem, aviao_14bis.x,aviao_14bis.y)

    for k,meteoro in pairs(meteoros) do
        love.graphics.draw(meteoro_img,meteoro.x, meteoro.y)
    end

    for k,tiro in pairs(aviao_14bis.tiros) do
        love.graphics.draw(tiro_img,tiro.x, tiro.y)
    end

    love.graphics.print("METEOROS RESTANTES: "..objetivo-meteoros_Destruidos, 0,0)

    if FIM_JOGO then
        love.graphics.draw(game_over_img,largura_tela/2 - game_over_img:getWidth()/2, altura_tela/2 - game_over_img:getHeight()/2)
    end

    if vencedor then
        love.graphics.draw(vencedor_img,largura_tela/2 - vencedor_img:getWidth()/2, altura_tela/2 - vencedor_img:getHeight()/2)
    end
end