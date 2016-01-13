
-- Configurando a conexao WIFI no NodeMCU
wifi.setmode(wifi.STATION)
wifi.sta.config("SSID","PASSWORD")

--Caso queira IP Fixo

--print(wifi.sta.getip())
--cfg =
 -- {
  --  ip="192.168.25.150",
  --  netmask="255.255.255.0",
  --  gateway="192.168.25.1"
 -- }
 -- wifi.sta.setip(cfg)
--conectando...
wifi.sta.connect()

-- Definindo as variaveis dos reles
rele0 = 0
rele1 = 1
rele2 = 2
rele3 = 3
rele4 = 4
rele5 = 5
rele6 = 6
rele7 = 7
-- rele8 = 8 nao usei o pino 8 mas poderia usar...
gpio.mode(rele0, gpio.OUTPUT)
gpio.mode(rele1, gpio.OUTPUT)
gpio.mode(rele2, gpio.OUTPUT)
gpio.mode(rele3, gpio.OUTPUT)
gpio.mode(rele4, gpio.OUTPUT)
gpio.mode(rele5, gpio.OUTPUT)
gpio.mode(rele6, gpio.OUTPUT)
gpio.mode(rele7, gpio.OUTPUT)
-- gpio.mode(rele8, gpio.OUTPUT)  = 8 nao usei o pino 8 mas poderia usar...

gpio.write(rele0, gpio.HIGH)
gpio.write(rele1, gpio.HIGH)
gpio.write(rele2, gpio.HIGH)
gpio.write(rele3, gpio.HIGH)
gpio.write(rele4, gpio.HIGH)
gpio.write(rele5, gpio.HIGH)
gpio.write(rele6, gpio.HIGH)
gpio.write(rele7, gpio.HIGH)
-- gpio.write(rele8, gpio.HIGH)  = 8 nao usei o pino 8 mas poderia usar...


--Definindo a variável mqtt que será usada por toda a aplicação
mqtt = mqtt.Client("clientid", 120)
--aqui são definido os "listeners"... na verdade, defino o que deve ser feito quando o mqtt conectar com o servidor
--nesse exemplo está apenas imprimindo no console a mensagem MQTT Conectado
mqtt:on("connect", function(con) print ("MQTT Conectado") end)




-- Definido o que deve ser feito quando uma mensagem for recebida...
-- Quando algum valor for alterado via celular ou qualquer outro dispositivo
-- o servidor mosquitto automaticamente enviar essa informação para os "assinantes" desser tópico
-- mais abaixo irei definir como "assinar" esse topico
mqtt:on("message", function(conn, topic, data) 
  -- configuração verificando se a alteração foi em r0 ou relê 0...
  if(topic == "napoles/sala/r0") then
        -- caso tenha sido no rele 0, verificando se o novo valor é ON ou OFF
        if(data == "ON")then
            -- alterando (ativando o Relê)
            gpio.write(rele0, gpio.HIGH);
        elseif(data == "OFF")then
          -- alterando (DESativando o Relê)
            gpio.write(rele0, gpio.LOW);
        end

  end
  -- repete para todos os reles...
  if(topic == "napoles/sala/r1") then
        if(data == "ON")then
            gpio.write(rele1, gpio.HIGH);
        elseif(data == "OFF")then
            gpio.write(rele1, gpio.LOW);
        end

  end
  if(topic == "napoles/sala/r2") then
        if(data == "ON")then
            gpio.write(rele2, gpio.HIGH);
        elseif(data == "OFF")then
            gpio.write(rele2, gpio.LOW);
        end

  end

  if(topic == "napoles/sala/r3") then
        if(data == "ON")then
            gpio.write(rele3, gpio.HIGH);
        elseif(data == "OFF")then
            gpio.write(rele3, gpio.LOW);
        end

  end


  if(topic == "napoles/sala/r4") then
        if(data == "ON")then
            gpio.write(rele4, gpio.HIGH);
        elseif(data == "OFF")then
            gpio.write(rele4, gpio.LOW);
        end

  end

    if(topic == "napoles/sala/r5") then
        if(data == "ON")then
            gpio.write(rele5, gpio.HIGH);
        elseif(data == "OFF")then
            gpio.write(rele5, gpio.LOW);
        end

  end


  if(topic == "napoles/sala/r6") then
        if(data == "ON")then
            gpio.write(rele6, gpio.HIGH);
        elseif(data == "OFF")then
            gpio.write(rele6, gpio.LOW);
        end

  end


  if(topic == "napoles/sala/r7") then
        if(data == "ON")then
            gpio.write(rele7, gpio.HIGH);
        elseif(data == "OFF")then
            gpio.write(rele7, gpio.LOW);
        end

  end

end)



-- Funcao que define qual o tópico esse mqtt local no ESP8266 deve ser assinante
function mqtt_sub() 
    mqtt:subscribe("napoles/sala/#",0, function(conn) 
        -- Definito assinante do topico napoles/sala/#
        -- todas as alterações que ocorrerem em napoles/sala/**** esse mqtt será avisado automaticamente pelo
        -- servidor pois ele é um assinante desse tópico...
        print("Subscribe realizado com sucesso")
    end)
end 
 


-- Conectando com o servidor

function connect() 
  -- essa funcão fica dentro de um tmr.alarm pois defe ficar repetindo a cada 1000 (1s) verificando de o status = 5 (conectado)
  -- quando for, tmr.stop(0)  é chamado e o mqtt:connect tenta se conectar novamente
  tmr.alarm(0, 1000, 1, function() 
      print ("Connecting to Wifi... ")
        if wifi.sta.status() == 5 and wifi.sta.getip() ~= nil then 
          print ("Wifi connected")
          print("IP:"..wifi.sta.getip())
          tmr.stop(0) 
          -- onde xxx.xxx.xxx.xxx é o IP do servidor que está rodando o serviço mosquitto.
          -- 1883 é a porta (padrão). pode ser outra porta caso seja configurado ssl/tls, etc..
          mqtt:connect("xxx.xxx.xxx.xxx", 1883, 0, function(conn)  
            print("MQTT Conectado")
            -- assim que a conexao for feita, a funcao acima mqtt_sub é chamada.... que faz a assinatura no topico
            mqtt_sub()
          end)
        end
  end)

end


-- caso a internet caia ou algo parecido, e o mqtt ficar off-line, a função acima de conectar é chamada automaticamente pra tentar reconectar...
mqtt:on("offline", function(con) 
  connect() 
end)



-- final do programa, chama a funcçao pra conectar no servidor mqtt
connect()



-- o código abaixo é bastante conhecido e disponível em vários sites
-- serve apenas para fazer com que seja possível realizar a conexao no nodemcu através
-- de um telnet na porta 2323. Ao relizar o telnet, é possível acompanhar todo o comportamento
-- da aplicação (todos os "prints" configurados acima são exibidos no telnet, apos a conexão. alem disso)
-- uma vez conectado, vc pode executar qualquer um dos comandos acima...

s=net.createServer(net.TCP,180) 
s:listen(2323,function(c) 
    function s_output(str) 
      if(c~=nil) 
        then c:send(str) 
      end 
    end 
    node.output(s_output, 0)   
    c:on("receive",function(c,l) 
      node.input(l)           
    end) 
    c:on("disconnection",function(c) 
      node.output(nil)        
    end) 
    print("Bem vindo ao NodeMCU.")
end)
