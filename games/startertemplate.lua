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

  settings = {
    bg_color = colors.blue,
    bg_text_color = colors.white
  }

  player = {
    sprite = 1,
    x = 60,
    y = 60,
    last_y = 60,
    speed = .5,
    gravity = 0,
    lives = 4,
    health = 10,
    jumped = false,
    speedx = 0,
    is_big = false
  }

  jump_puffs = {}

  game = {
    level = 0,
    score = 0
  }

  game_states = {
    start_up = 0,
    playing = 1,
    level_start = 2,
    help_screen = 3
  }

  timer_settings = {
    lost_life = 60,
    start_level = 45,
    game_over = 45
  }

  timers = {
    lost_life = 0,
    start_level = 0,
    game_over = 0,
    ball_kicked = 0,
    toggle_big_player = 0
  }

  controller = {
     right = 1,
     left = 0,
     down = 3,
     up = 2,
     btn1 = 4,
     btn2 = 5
  }

  --innanimate objects
  innani_objects = {}
  
  add(innani_objects, 
    {
      --flat
      sprite = 66,
      x = 80,
      y = 40,
      rows = 1,
      cols = 3
    }
  );

  init_ball()
  game_state = game_states.start_up
  timers.start_level = 0

end

function add_jump_puffs()

  for i=1,4 do 
    add(jump_puffs, {

      life = 45,
      x = player.x + flr(rnd(12))-2,
      y = player.y + 8,
      r = 1 + rnd(rnd(3)),
      speedx = (flr(rnd(4)) - 2)/10,
      speedy = (flr(rnd(4)) * -1)/10
    })
  end

end

function update_jump_puffs()

  for p in all(jump_puffs) do

    if p.life < 0 then 
       del(jump_puffs, p) 
    end 

    p.life -= 1
    p.r -= 0.1
    p.x += p.speedx
    p.y += p.speedy
  end
end 

function draw_jump_puffs()
  for p in all(jump_puffs) do 
    circfill(p.x, p.y, p.r, 7)
  end 
end 

function _update()
 if game_state == game_states.start_up then 
  update_startup()
 elseif game_state == game_states.playing then 
  update_playing()
 end 
end

function draw_startup()
  print("welcome to the game!", 20, 20, settings.bg_text_color)
  print("press button 1 to start", 20, 30, settings.bg_text_color)
end

function draw_playing()
  cls(settings.bg_color)
  draw_innani_objects()
  print("level: " .. game.level, 10, 10, settings.bg_text_color)
  print("score: " .. game.score, 10, 20, settings.bg_text_color)
  
  -- draw player
  if player.is_big then 
    draw_big_player()
  else 
     spr(player.sprite, player.x, player.y)
     rectfill(player.x+2, ground_y+8, player.x+6, ground_y+9, colors.dark_blue)
  end 
  draw_jump_puffs()
  draw_ball()
  
  -- draw lives
  for i = 1, player.lives do
    spr(2, i * 8, 0) -- assuming sprite 2 is a heart or life icon
  end
  
  -- draw health bar
  rectfill(10, 50, player.health * 2 + 10, 60, colors.red)
  
end

function _draw()
  cls(settings.bg_color)
  print("time: "..time(), 50, 100)
  if game_state == game_states.start_up then 
    draw_startup()
  elseif game_state == game_states.playing then 
    draw_playing()
  end
end



function draw_innani_objects()
  for i in all(innani_objects) do
    local offsetx = 0
    local offsety = 0
    local s_index = i.sprite
    for r = 0, i.rows do
      offsetx = 0 
      
      for c = 0, i.cols do 
        s_index = i.sprite + (flr(offsetx/8)) + (flr(offsety/8)*16)
        spr(s_index, i.x +offsetx, i.y+offsety)
        offsetx += 8
      end
      offsety += 8
    end
  end
end 
ground_y = 120 -- ground level for player
previous_player_x = 0
--generaed code

function draw_big_player()

  if player.sprite == 1 then 
    spr(192, player.x, player.y)
    spr(193, player.x+8, player.y)
    spr(208, player.x, player.y+8)
    spr(209, player.x+8, player.y+8)
  elseif player.sprite == 2 then
    spr(194, player.x, player.y)
    spr(195, player.x+8, player.y)
    spr(210, player.x, player.y+8)
    spr(211, player.x+8, player.y+8)
  elseif player.sprite == 3 then 
    spr(193, player.x, player.y, 1, 1, true, false)
    spr(192, player.x+8, player.y, 1, 1, true, false)
    spr(209, player.x, player.y+8, 1, 1, true, false)
    spr(208, player.x+8, player.y+8, 1, 1, true, false)
  elseif player.sprite == 4 then 
    spr(195, player.x, player.y, 1, 1, true, false)
    spr(194, player.x+8, player.y, 1, 1, true, false)
    spr(211, player.x, player.y+8, 1, 1, true, false)
    spr(210, player.x+8, player.y+8, 1, 1, true, false)
  elseif player.sprite % 2 == 0 then 
    spr(192, player.x, player.y)
    spr(193, player.x+8, player.y)
    spr(208, player.x, player.y+8)
    spr(209, player.x+8, player.y+8)
  else --TODO use vertical sprites later
    spr(194, player.x, player.y)
    spr(195, player.x+8, player.y)
    spr(210, player.x, player.y+8)
    spr(211, player.x+8, player.y+8)
  end 
end 

function update_player()

  -- movement
  if not player.jumped and btn(controller.left) then
    player.x -= player.speed
    if abs(previous_player_x - player.x) > 2 then
      player.sprite += 1
      previous_player_x = player.x
    end
    player.speedx = -player.speed
    if player.sprite > 2 then player.sprite = 1 end
  elseif not player.jumped and btn(controller.right) then
    player.x += player.speed
    if abs(previous_player_x - player.x) > 2 then
      player.sprite += 1
      previous_player_x = player.x
    end
    if player.sprite < 3 or player.sprite > 4 then player.sprite = 3 end
    player.speedx = player.speed
  elseif btn(controller.up) then -- up
    player.speedx = 0
    player.y -= player.speed 
    player.sprite += 1
    if player.sprite < 4 or player.sprite > 6 then
        player.sprite = 5
    end
    player.last_y = player.y
    ground_y = player.y
  elseif btn(controller.down) then -- down
    player.speedx = 0
    player.y += player.speed 
    player.sprite += 1
    if player.sprite < 7 or player.sprite > 8 then
        player.sprite = 7 
    end
    player.last_y = player.y
    ground_y = player.y
  elseif not player.jumped then
    player.speedx = 0
  end

  -- jump
  if btnp(controller.btn1) and not player.jumped then

    if player.is_big then 
      player.gravity = -3.5  
    else 
      player.gravity = -2.5
    end 
    player.jumped = true

    --only change the sprit when they are running horizontally
    --but not vertially
    if player.sprite < 5 then 
      if player.speedx > 0 then
          player.sprite = 4  --todo face right way
      else
        player.sprite = 2
      end
      ground_y = player.y
    end
    add_jump_puffs()
    sfx(2)
  end

  -- apply gravity (vertical velocity)
  player.gravity += 0.2
  player.y += player.gravity
  
  if player.y < ground_y then
      player.x += player.speedx
  end

  -- check for ground
  if player.y >= ground_y then
    player.y = ground_y
    player.gravity = 0
    player.jumped = false
  end

  update_ball()
end

function update_enemies()

end

function detect_collisions()

  for i in all(innani_objects) do 
    if abs(i.x+4 - player.x+4) <= 4 
       and 
       abs((i.y + 4) - (player.y+4)) <=  4
    then 

      if timers.toggle_big_player <= 0 then 
        if player.is_big then
          player.is_big = false
          player.speedx /= 3
          player.speed /= 3
          timers.toggle_big_player = 60
        else 
          player.is_big = true
          player.speedx *= 3
          player.speed *= 3
          timers.toggle_big_player = 60
        end
      end
    end
  end 

  timers.toggle_big_player -= 1
  if timers.toggle_big_player < 0 then 
    timer_settings.toggle_big_player = 0
  end
end


function update_playing()
  if timers.start_level > 0 then 
    timers.start_level -= 1
    print("timer"..timers.start_level, 10,100,colors.white)
  else 
    
    update_player()
    update_kick()
    update_jump_puffs()
    update_enemies()
    detect_collisions()
    print("playing"..timers.start_level, 10,100,colors.white)
  end 
end 

function update_startup()
  if timers.start_level <= 0 and btnp(controller.btn1) then 
    timers.start_level = timer_settings.start_level
    game_state = game_states.playing
  end
  timers.start_level -= 1
end 

-- ball structure
ball = {}

function init_ball()
    ball = {
        x = 64,
        y = 110,      -- ground level (approx screen height - ball size)
        w = 2,
        h = 2,
        vx = 0,
        vy = 0,
        gravity = 0.2,
        bounce = -0.6,
        kicked = false
    }
end

function kick_left(override)
    if not ball.kicked or override then
        ball.vx = -2
        ball.vy = -3.5
        ball.kicked = true
        timers.ball_kicked = 160
        add_jump_puffs()
        sfx(1)
    end
end

function kick_right(override)
    if not ball.kicked or override then
        ball.vx = 2
        ball.vy = -3.5
        ball.kicked = true
        timers.ball_kicked = 160
        add_jump_puffs()
        sfx(1)
    end
end

function update_ball()

    if timers.ball_kicked <= 0 then 
      ball.kicked = false
    end 

    timers.ball_kicked -= 1
    if ball.kicked then
        -- apply velocity
        ball.x += ball.vx
        ball.y += ball.vy

        -- apply gravity
        ball.vy += ball.gravity

        -- ground collision
        if ball.y + ball.h > 116 then
            ball.y = 116 - ball.h
            ball.vy *= ball.bounce

            -- dampen horizontal speed slightly
            ball.vx *= 0.9

            -- stop if very slow
            if abs(ball.vy) < 0.3 then
                ball.vy = 0
            end
            if abs(ball.vx) < 0.1 then
                ball.vx = 0
            end

            if ball.vx == 0 and ball.vy == 0 then 
              init_ball()   
            end 
        end

        -- wall bounce
        if ball.x < 0 then
            ball.x = 0
            ball.vx *= -1
        elseif ball.x + ball.w > 128 then
            ball.x = 128 - ball.w
            ball.vx *= -1
        end
    end
end


function update_kick()
    update_ball()

    -- input: kick left/right
    if (ball.x - player.x) < 4 and (ball.x - player.x) > 0 
       and abs(ball.y - (player.y+8)) < 3
    then 
      kick_right(true) 
    end

    if (player.x - ball.x) < 4 and (player.x - ball.x) > 0 
       and abs(ball.y - (player.y+8)) < 3 
    then 
      kick_left(true) 
    end
end

function draw_ball()
    -- draw ground
    line(0, 116, 127, 116, 3)

    -- draw ball (2x2 square)
    circfill(ball.x, ball.y, 1, 8)
			
		if debug_mode then 
      if ball.kicked then 
				print("ball kicked: true ", 50, 90, colors.white) 
			else
			  print("ball kicked: false ", 50, 90, colors.white) 
			end
    end
end
