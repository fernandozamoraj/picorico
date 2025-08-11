debug_mode = false 

colors = {
   black = 0, --black
   dark_blue = 1, --white
   dark_purple = 2, --red
   dark_green = 3, --green
   brown = 4, --blue
   dark_gray = 5, --yellow
   light_gray = 6, --orange
   white = 7, --pink
   red = 8, --purple
   orange = 9, --brown
   yellow = 10,--gray
   green =  11,--light gray
   blue = 12,--dark gray
   indigo = 13,--light blue
   pink = 14,--light green
   peach = 15,--light red
}


function _init()
  player = {
    x = 60,
    y = 60,
    speed = 2,
  }

  game = {
    misses = 0,
    hits = 0,
    timer = 0,
    final_score = ""
  }

  game_states = {
    gameover = 0,
    playing = 1
  }

  timer_settings = {
    problem = 120,
    gameover = 45,
    play_round = 3600
  }

  timers = {
    gameover = 0
  }

  controller = {
     right = 1,
     left = 0,
     down = 3,
     up = 2,
     btn1 = 4,
     btn2 = 5
  }

  answer = {
        a=2,
        b=4,
        op="*", 
        answer=8
      }
        
  choices = {}
  explosions = {}
  
  game_state = game_states.gameover
  timers.start_level = 45

end


function optochar(opi) 
   if opi == 1 then
      return "+"
   elseif opi == 2 then
      return "-"
   elseif opi == 3 then
   	  return "*"
   else
   	  return "/"
   end
end

function doop(a, b, opi)
   if opi == 1 then
      return a + b
   elseif opi == 2 then
      return a - b
   elseif opi == 3 then
   	  return a*b
   else
   	  return a/b
   end
end

function spawn_choices()

  if #choices > 0 then
    return
  end

	 local n1 = flr(rnd(10))+2
	 local n2 = flr(rnd(10))+2
	 local op = flr(rnd(4))+1
	 
	 if op == 4 then
	 	
	 	answer = {
		 	 a = n1*n2,
		 	 b = n2,
		 	 op = optochar(op),
		 	 answer = doop(n1*n2,n2,op) 	 
		 }
	 else 
	 
		 answer = {
		 	 a = n1,
		 	 b = n2,
		 	 op = optochar(op),
		 	 answer = doop(n1,n2,op) 	 
		 }
	 end
	 
   local grid = {
   }
	 
	 for i=1, 7 do
	    local gridpos = flr(rnd(25))
	    local row = flr(gridpos/5)+1
	    local col = flr(gridpos%5)+1
      
      if grid[""..gridpos] == nil then
        add(choices,
        {
          x = (col*18)+10,
          y = (row*18)+15,
          r = 5,
          val = flr(rnd(36))*3+2,
          selected = false     
        })	
      end
      
      grid[""..gridpos] = true
	 end
	 
	 for i=1, 7 do
	    local gridpos = flr(rnd(25))
	    local row = flr(gridpos/5)+1
	    local col = flr(gridpos%5)+1

      if grid[""..gridpos] == nil then
        add(choices,
        {
          x = (col*18)+10,
          y = (row*18)+15,
          r = 5,
          val = flr(rnd(22))*5+5,
          selected = false     
        })	
      end 
      grid[""..gridpos] = true
	 end
	 
   local added = false

  while not(added) do 
    local gridpos = flr(rnd(25))
    local row = flr(gridpos/5)+1
    local col = flr(gridpos%5)+1
    if grid[""..gridpos] == nil then    
      add(choices,
          {
            x = (col*18)+10,
            y = (row*18)+15,
            r = 5,
            val = answer.answer,
            selected = false     
          })
      added = true
    end
    grid[""..gridpos] = true 
  end
end

function spawn_explosion(x, y)
	 add(explosions, 
	    {
	       x = x,
	       y = y,
	       r = 1,
         max_r = 1 + (flr(rnd(3))*2)
	    })
end

function update_explosions()
	 for e in all(explosions) do
	 	 e.r += 1.5
	 	 if(e.r >= e.max_r)then
	 	 	del(explosions, e)
      sfx(5)
      break
	 	 end	 	
	 end
end

function update_player_movement()
  if btn(controller.left) then
    player.x -= player.speed
  end
  
  if btn(controller.right) then
    player.x += player.speed
  end
  
  if btn(controller.up) then
    player.y -= player.speed
  end
  
  if btn(controller.down) then
    player.y += player.speed
  end

  if(player.y < 10) then
    player.y = 10
  end  	 
  
  if(player.y > 120) then
    player.y = 120
  end 
  
  if(player.x > 120) then
    player.x = 120
  end
  
  if(player.x < 0) then
    player.x = 0
  end 
end 

function update_player_target()
  for c in all(choices) do
    c.selected = false
    
    --check collicion and select the choice
    --very brute force
    if abs((player.x+c.r/2)-c.x) < 7 then
      if abs((player.y+c.r/2)-c.y) < 7 then
        c.selected = true
      end
    end
  end
end 

function check_for_gameover()
  for c in all(choices) do
    del(choices, c)  	
    spawn_explosion(c.x, c.y) 		
  end
  --switch to gameover  	 		
  if game.timer > timer_settings.gameover then
    game_state = game_states.gameover  	 			
    timers.gameover = 45 
  end
end

function update_player_shot()

  --if player took the shot...
  if btnp(controller.btn1) then
    local hit = false
    
    --could be simplified using mget
    for c in all(choices) do
      if c.selected then
        --do not break because there may be more than
        --one overlay on top of the other
        if c.val == answer.answer then
          hit = true
        end
      end 	 	 	 
    end

    --destroy all choices
    --TODO: make it like fire works deleteing one at a time
    --randomly
    for c in all(choices) do  	 	 	  
      del(choices, c)
      spawn_explosion(c.x, c.y)
    end

    --update his or misses
    --we know the player took a shot
    --this determines if it was a hit or a miss
    if hit then 
      game.hits += 1
      sfx(3)
    else
      game.misses += 1
      sfx(4)
    end 
  end	   	 
end

function update_playing()
  if game_state == game_states.playing then
    game.timer += 1

    --explosions must happen even if timer exceeded
    --allows to finish out explosions
    update_explosions()	   	 
    
    if game.timer >= timer_settings.play_round then
        check_for_gameover()
    else
      spawn_choices()
      update_player_movement()
      update_player_target()
      update_player_shot()	
    end 
  end
end 

function update_gameover()
  if game_state == game_states.gameover then
  	timers.gameover -= 1
  	if timers.gameover < 0 then
  	  timers.gameover = 0
  	end
  	 
    --if allowed and player clicked the x button
  	if timers.gameover <= 0 and btn(controller.btn1) then
  	  game_state = game_states.playing  	
  	  game.timer = 0 
  	  game.hits = 0
  	  game.misses = 0
  	  game.final_score = ""
  	end 
  end
end 

function _update() 
  update_gameover()
  update_playing()
end

function _draw()
  cls(colors.brown)
  draw_gameover()
  draw_playing()
end

function draw_gameover()
  if not(game_state == game_states.gameover) then
    return 
  end 

  cls(colors.dark_blue)

  print("let's play mathwiz!", 20, 40, colors.dark_purple)
  print("let's play mathwiz!", 19, 39, colors.orange)

  print("Timer: "..timers.gameover, 20, 50, colors.dark_purple)
  print("Timer: "..timers.gameover, 19, 49, colors.orange)

  if timers.gameover <= 0 then
    print("press (❎) to start", 20, 60, colors.dark_purple)
    print("press (❎) to start", 19, 59, colors.orange)
  end
end

function draw_playing()

  if not(game_state == game_states.playing) then
    return
  end  

  cls(colors.dark_blue)

  print("Count Down: " ..((timer_settings.play_round-game.timer)/30), 10, 20, colors.dark_purple)
  print("Count Down: " ..((timer_settings.play_round-game.timer)/30),  9, 19, colors.orange)

  print("score: " ..game.hits.."/"..(game.hits+game.misses), 10, 10, colors.dark_purple)
  print("score: " ..game.hits.."/"..(game.hits+game.misses),  9, 9  , colors.orange)

  print(" "..answer.a..answer.op..answer.b.."?", 80, 10, colors.dark_purple)
  print(" "..answer.a..answer.op..answer.b.."?", 79,  9, colors.orange)
  
  if game.timer >= timer_settings.play_round then 
    print("final score! ", 50,40, colors.dark_purple)
    print("final score! ", 49,39, colors.orange)
  end
  
  circfill(player.x+3, player.y+3, 20, colors.blue)

  if #explosions <= 0 then
	  for c in all(choices) do
      if c.selected then
        circfill(c.x, c.y, c.r*1.5, colors.dark_blue)
        print(""..c.val, c.x-c.r/2, c.y-c.r/2, colors.blue)
      else
        print(""..c.val, c.x-c.r/2, c.y-c.r/2, colors.dark_blue)
      end
	  	
	  end 
  end
  
  for e in all(explosions) do
 	  circfill(e.x-2, e.y-2, e.r+3, colors.red)
 	  circfill(e.x-2, e.y-2, e.r+2, colors.orange)
    circfill(e.x-2, e.y-2, e.r+1, colors.yellow)
    circfill(e.x-2, e.y-2, e.r+0, colors.white)      
  end
  
  -- draw player
  local crosshairs_color = colors.red
  circ(player.x+3, player.y+3, 9, crosshairs_color)
 	line(player.x,player.y+3,player.x+6,player.y+3, crosshairs_color)
  line(player.x+3,player.y,player.x+3,player.y+6, crosshairs_color)
end

