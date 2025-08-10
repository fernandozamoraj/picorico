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
    timer = 0
  }

  game_states = {
    gameover = 0,
    playing = 1
  }

  timer_settings = {
    problem = 120,
    gameover = 45
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
	 
	 
	 for i=1, 7 do
	    local gridpos = flr(rnd(25))
	    local row = flr(gridpos/5)+1
	    local col = flr(gridpos%5)+1
	    add(choices,
	    {
	       x = (col*18)+10,
	       y = (row*18)+30,
	       r = 5,
	       val = flr(rnd(36))*3+2,
	       selected = false     
	    })	 
	 end
	 
	 for i=1, 7 do
	    local gridpos = flr(rnd(25))
	    local row = flr(gridpos/5)+1
	    local col = flr(gridpos%5)+1
	    add(choices,
	    {
	       x = (col*18)+10,
	       y = (row*18)+30,
	       r = 5,
	       val = flr(rnd(22))*5+5,
	       selected = false     
	    })	 
	 end
	 
	 local gridpos = flr(rnd(25))
	 local row = flr(gridpos/5)+1
	 local col = flr(gridpos%5)+1
	    
	 add(choices,
	    {
	       x = (col*18)+10,
	       y = (row*18)+30,
	       r = 5,
	       val = answer.answer,
	       selected = false     
	    })
end

function spawn_explosion(x, y)
	 add(explosions, 
	    {
	       x = x,
	       y = y,
	       r = 1
	    })
end

function update_explosions()
	 
	 for e in all(explosions) do
	 	 e.r += 1
	 	 if(e.r >= 10)then
	 	 	del(explosions, e)
	 	 end	 	
	 end
end

function _update()
  if game_state == game_states.playing then
  	 game.timer += 1

	   update_explosions()	   	 
  	 
  	 if game.timer < 900 then
  	 	 spawn_choices()
  	 end
  	 
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
    
    for c in all(choices) do
    	c.selected = false
    	if abs((player.x+c.r/2)-c.x) < 5 then
    		if abs((player.y+c.r/2)-c.y) < 5 then
    			c.selected = true
    		end
    	end
    end
  	 
  	 if game.timer >= 3600 then
  	 		for c in all(choices) do
  	 			del(choices, c)  	 		
  	 		end

      --switch to gameover  	 		
  	 		if game.timer > 3780 then
	 			 	 game_state = game_states.gameover  	 			
	 			 	 timers.gameover = 45 
  	 		end
  	 elseif btnp(controller.btn1) then
  	 	 local hit = false
  	 	 for c in all(choices) do
		    	if c.selected 
  	 	 	then
  	 	 	 	if c.val == answer.answer then
  	 	 	 		 hit = true
  	 	 	 	end  	 	 	 
  	 	 	 end
  	 	 end

 	 	  for c in all(choices) do  	 	 	  
 	 	  	del(choices, c)
 	 	  	spawn_explosion(c.x, c.y)
 	 	  end
  	 	 
  	 	 if hit then 
  	 	    game.hits += 1
  	 	 	  sfx(3)
  	 	 else
  	 	    game.misses += 1
  	 	 	  sfx(4)
  	 	 end 	   	 	
  	 end
  else
  	 --do nothing 
  	 timers.gameover -= 1
  	 if timers.gameover < 0 then
  	 	timers.gameover = 0
  	 end
  	 
  	 if timers.gameover <= 0 and btn(controller.btn1) then
  	 	  game_state = game_states.playing  	
  	 	  game.timer = 0 
  	 	  game.hits = 0
  	 	  game.misses = 0
  	 end 
  end
  	
end


function _draw()
  cls(colors.blue)
  if game_state == game_states.gameover then 
    draw_gameover()
  elseif game_state == game_states.playing then 
    draw_playing()
  end
end

function draw_gameover()
  cls(colors.blue)
  print("welcome to the game!", 20, 20, colors.white)
  print("press (❎) to start", 20, 30, colors.white)
end

function draw_playing()
  cls(colors.blue)
  print("score: " ..game.hits.."/"..(game.hits+game.misses), 10, 10, colors.dark_blue)
  print(" "..answer.a..answer.op..answer.b.."?", 50, 10, colors.white)
  print("="..answer.answer, 90, 10, colors.white)
  
  if #explosions <= 0 then
	  for c in all(choices) do
	  	  circfill(c.x, c.y, c.r*1.5, colors.white)
	  	  if c.selected then
	  	    circfill(c.x, c.y, c.r*1.5, colors.dark_blue) 
	  	  end
	  	  print(""..c.val, c.x-c.r/2, c.y-c.r/2, colors.red)
	  end 
  end
  
  for e in all(explosions) do
  	  circfill(e.x-2, e.y-2, e.r, colors.yellow)
  end
  
  -- draw player
 	line(player.x,player.y+3,player.x+6,player.y+3, colors.green)
  line(player.x+3,player.y,player.x+3,player.y+6, colors.green)
   
end

