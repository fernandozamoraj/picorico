pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
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
    speedx = 0
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
    ball_kicked = 0
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
  spr(player.sprite, player.x, player.y)
  rectfill(player.x+2, ground_y+8, player.x+6, ground_y+9, colors.dark_blue)
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
    player.gravity = -2.5
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
 
__gfx__
00000000000000000111000000000000000111000010000000100000000111000001110000000000000000000000000000000000000000000000000000000000
00fff0000111100000ff100000011100001ff0000011100000111000001ff100001ff00000000000000000000000000000000000000000000000000000000000
00fff00000ff110000fff100001ff00001fff0000f111f000f111f0001ffff0001ffff0000000000000000000000000000000000000000000000000000000000
000f000000fff000000f000001fff000000f0000000f0000000f0000000f0000000f000000000000000000000000000000000000000000000000000000000000
00f8f00000f8f0000008000000080000000800000088800000888000008880000088800000000000000000000000000000000000000000000000000000000000
0008000000080000000f000000f8f000000f000000f800000008f00000f800000008f00000000000000000000000000000000000000000000000000000000000
00808b000008000000080000000800000008000000b800000008b00000b800000008b00000000000000000000000000000000000000000000000000000000000
0bb0b00000b0b000000b000000b0b000000b00000000b00000b000000000b00000b0000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000050000005000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000050000005000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000050000005000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000050000005000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000077777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000616000000000005555555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666000000000051111111111111111115000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666611000000000510000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66111111000000000510000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
ccccccccc111ccccc111ccccc111ccccc111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccff1cccccff1cccccff1cccccff1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccfff1ccccfff1ccccfff1ccccfff1cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccfcccccccfcccccccfcccccccfcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccc8ccccccc8ccccccc8ccccccc8cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccfcccccccfcccccccfcccccccfcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccc8ccccccc8ccccccc8ccccccc8cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccbcccccccbcccccccbcccccccbcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc7ccc777c7c7c777c7ccccccccccc777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc7ccc7ccc7c7c7ccc7cccc7cccccc7c7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc7ccc77cc7c7c77cc7ccccccccccc7c7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc7ccc7ccc777c7ccc7cccc7cccccc7c7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc777c777cc7cc777c777ccccccccc777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccc77cc77cc77c777c777ccccccccc777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc7ccc7ccc7c7c7c7c7cccc7cccccc7c7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc777c7ccc7c7c77cc77cccccccccc7c7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc7c7ccc7c7c7c7c7cccc7cccccc7c7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc77ccc77c77cc7c7c777ccccccccc777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77777777777777ccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc555555555555555555ccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc51111111111111111115cccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc51cccccccccccccccccc15ccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc51cccccccccccccccccc15ccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc888888888888888888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc888888888888888888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc888888888888888888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc888888888888888888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc888888888888888888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc888888888888888888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc888888888888888888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc888888888888888888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc888888888888888888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc888888888888888888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc888888888888888888888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc8ccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc888cccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc8ccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111ccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1ffcccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1fffcccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccfccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc8ccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7cfccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7ccc8ccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc777ccbccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7cc11111cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11111cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000040000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000400000400000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0004000027350293502a3502f35033350363503a3500030000300113000d300073000230017300123000e300093000530002300263001b3001030004300003000030000300003000030000300003000030000300
000300001f050120500f0501005010050100500f0501b05000000000000000000000000000000000000000000a0000c0000000010000150001800000000000000000000000000000000000000000000000000000
000300001a05006050160500d0001a00028000280001a70015700117000e7000b7000970007700057000370001700007000070000700007000070000700097000970009700097000070000700007000070000700
001000001405014050140501405013050130500000012050110501105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000120501305012050120500f0500a0500905008050070500405001050000500005000050000500005000050000500005000050000500005000000000000000000000000000000000000000000000000000
0001000037050320502e050260502005019050140500f0500a050040502f0502001013000140001d0502b0501f0501505018050260502a050310503e050000000000000000000000000000000000000000000000
000500003a050340502f0502d0502d050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e000431120301103212032110001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000e1000f1000f1000f1001010010100101001110011100
0010000023050270502a0502f0503305036050380503a0503d0503f0502f050310503305036050380503a0503b0503e0503f0503205035050370503b0503d0503f0503f050360503a0503e0503f050350503a050
000900001405016050190501d05020050250502a0502e050380503d05039050320502c05027050220501e05019050180501605013050120500f05000000000000000000000000000000000000000000000000000
0003000002750047500575006750097500b7500e75011750157501b7501f750247502775000700067000270000700007000070000700007000070000700007000070000700007000070000700007000070000700
000c000800f001c35032350163502a3501e350373502035016300105000f5000d5000950006500055000350001500015000050000500005000050000500005000050000500005000050000500005000050000500
0011010f000002f3502b350293502f3502b35029350313502b350273502b35025350273502b3502c3503730000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b00000732006320063200633008330093300c3300d35012350163501b350223502a3503d350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01424344

