--IMPORTANT: This file is part of a game project and should not be modified without understanding the game logic.
--This file contains the game logic for a space shooter game called "Gaders".
--The game features player movement, enemy spawning, shooting mechanics, and collision detection.
--It also includes sound effects, particle effects, and a scoring system.
--The game is structured with different states such as playing, level complete, and game over.
--The player can move left, right, and shoot bullets at enemies.
--Enemies can spawn in different patterns and can be destroyed by player bullets.
--The game includes features like respawning, health management, and score tracking.
--The game is designed to be played in a Pico-8 environment.
--
--
-- TODOs and features to implement:
-- features
-- fix bug not waiting after game over before it can restart
-- make game over sound
-- pause screen after killed
-- add falling men to capture
--      and the score has to get reset
--add power up to blow entire screen ... maybe hold x button down
--add killer image for the game
--limit bullets after 100 bullets a 30 cooldown
--add repeating game music
--fix meteors to spawn more evened out
--after fourth round bring out big ass ship that shoots back
--done***add background
--done*** have aliens fall at different speeds
--done*** have aliens follow 4 different patterns
--done*** add rock meteors that can't be destrot
--done*** add bonus round after two rounds
--done*** add scoring for hit percentage bonus
--done**add freeman at 1000
--done** add power when hitting red ones
--done** give extra guns double barrel
--CANNOT BE DONE add leader boards
-- constants
--done** add kamikazes
--done**add a way to keep track of kills
--done**fix score calculations
--done** add power ups to get v guns
--done**add power ups to get side guns
--done***fix it to where a hit loses one gun set
--done***fix double calculation on the scoreboard...it should only add it once not multiple
--done***change the levels to operate in levels separate from the traditional round

function init_game_states()
  
  game_states = {
    game_over = 0,
    playing = 1,
    level_complete = 2,
    playing_bonus = 3  
  }

  normal_level_state = {
    init = normal_level_init,
    update = normal_level_update,
    draw = normal_level_draw,
    finish = normal_level_finish,
    game_state = game_states.playing
  }

  bonus_level_state = {
    init = bonus_level_init,
    update = bonus_level_update,
    draw = bonus_level_draw,
    finish = bonus_level_finish,
    game_state = game_states.playing_bonus  
  }

  game_over_state = {
    init = game_over_init,
    update = game_over_update,
    draw = game_over_draw,
    finish = game_over_finish,
    game_state = game_states.game_over
  }

  level_complete_state = {
    init = level_complete_init,
    update = level_complete_update,
    draw = level_complete_draw,
    finish = level_complete_finish,
    game_state = game_states.level_complete
  }

  current_game_state = game_over_state
  current_game_state.init()
end 

function switch_state(new_state)
  current_game_state.finish()
  current_game_state = new_state
  current_game_state.init()
end 

function _init()

  player_left = 2
  player_idle = 1
  player_right = 0
  score = 0
  level = 1
  enemies_count = 20
  shots_fired_count = 0
  accuracy = 0
  bonus = 0
  enemy_squadron_size = 5 ---fix this to a reasobable value
  max_health = 5
  max_enemies = 15

  --sounds
  sound_level_complete = 10
  sound_compute_kill_score = 11

  after_burner = {}
  meteor_trails = {}
  kill_points = {}

  stars_layer_1 = {}
  stars_layer_2 = {}

  -- player table
  player = {
    x = 64,
    y = 120,
    spd = 2,
    sprite = player_idle,
    alive = false,
    respawn_timer = 0,
    lives = 3,
    health_meter = max_health,
    twin_guns = false, -- if true, player has double guns
    v_guns = false -- if true, player has vertical guns
  }

  -- tables
  bullets = {}
  enemy_bullets = {}
  enemies = {}
  particles = {}

  enemy_timer = 0
  meteor_timer = 0
  level_complete_timer = 0
  game_over_state_timer = 0
  enemy_bullet_timer = 0
  enemies_dispatched = 0
  enemies_destroyed = 0

  power_up = {
    x = 0,
    y = 0,
    alive = false
  }

  init_game_states()
end

function add_star_layers()
  
  if #stars_layer_1 > 0 or #stars_layer_2 > 0 then
    return -- don't add stars if they already exist
  end
  
  for i=1, 20 do

    local is_planet = flr(rnd(20)) == 0
    
    if is_planet then 
      add(stars_layer_1, 
          {
            x = flr(rnd(128)), 
            y = flr(rnd(128)),
            r = flr(rnd(5))+3,
            speed = 0.3,
            twinkler = flr(rnd(5)) == 0
          })
    end 
    
    add(stars_layer_1, 
     {
      x = flr(rnd(128)), 
      y = flr(rnd(128)),
      r = flr(rnd(2)),
      speed = 0.3,
      twinkler = flr(rnd(5)) == 0
    })

    if i % 2 == 0 then
      -- alternate layer for more depth
      add(
        stars_layer_2, 
        {
          x = flr(rnd(128)), 
          y = flr(rnd(128)),
          speed = 0.1,
          r = flr(rnd(2)),
          twinkler = flr(rnd(5)) == 0
        })
    end
  end
end

function update_star_layers()
  for s in all(stars_layer_1) do
    s.y += s.speed
    if s.y > 128 then
      s.y = 0
      s.x = flr(rnd(128))
    end
  end

  for s in all(stars_layer_2) do
    s.y += s.speed
    if s.y > 128 then
      s.y = 0
      s.x = flr(rnd(128))
    end
  end
end

function draw_star_layers()
  for s in all(stars_layer_1) do
    local twinkle = flr(rnd(4)) == 0
    if not s.twinkler or not twinkle then        
      circfill(s.x, s.y, s.r, 6)  
      circfill(s.x, s.y, s.r-1, 7)
    end 
  end

  for s in all(stars_layer_2) do
    local twinkle = flr(rnd(4)) == 0
    if not s.twinkler or not twinkle then        
      circfill(s.x, s.y, s.r, 6)  
      circfill(s.x, s.y, s.r-1, 7)
    end
  end
end

function add_kill_points(x, y, points)
    add(kill_points,
      {
        x = x + flr(rnd(12))-2,
        y = y + 8,
        speed = .5,
        color = 11,
        life = 20,
        points = points
      })
end

function update_kill_points()
  for kp in all(kill_points) do
    kp.y -= kp.speed
    kp.life -= 1
    if kp.life <= 0 then
      del(kill_points, kp)
    end
  end
end

function draw_kill_points()
  for kp in all(kill_points) do
    print(""..kp.points, kp.x, kp.y, kp.color)
  end
end

function add_after_burner(x, y)
  if(player.alive)then
    add(after_burner,
      {
        x = x + flr(rnd(7)),
        y = y + flr(rnd(4)),
        r = 1 + rnd(2),
        speed = 1 + flr(rnd(3)),
        color = 5,
        life = 30+flr(rnd(30))
      })
  end
end

function add_meteor_trails()
  for m in all(enemies) do 
    if not m.breakable then 
        for i=1, 2 do 
          add(meteor_trails,
            {
              x = m.x + flr(rnd(8)),
              y = m.y - 1,
              r = flr(rnd(2)),
              speed = 0.2*flr(rnd(4)),
              color = 9,
              life = 5+flr(rnd(10))
            })
        end
    end 
  end 
end

function update_after_burner()
  for p in all(after_burner) do 
    p.y += p.speed 
    p.life -= 1
    p.r -= .03
    if p.life <= 0 then 
      del(after_burner, p)
    end 
  end
end

function update_meteor_trails()
  for m in all(meteor_trails) do 
    m.y -= m.speed 
    
    m.x -= .01 
    m.life -= 1
    m.r -= .08
    if m.life < 7 then
      m.color = 10
    end 
    if m.life <= 0 then 
      del(meteor_trails, m)
    end 
  end
end

--sfx is wrapped because i don't want to play
--sounds when game is not in play mode... even 
--though it is executing some game logic minus
--handling input
function play_sfx(soundindex)
  if not (current_game_state.game_state == game_states.game_over) then 
    sfx(soundindex)
  end
end

function game_over()
  play_sfx(4)  
  switch_state(game_over_state)
end 

function begin_level_complete()
  if enemies_count <= 0 then
    switch_state(level_complete_state)
  end
end

--------------------------------------------------------
--
-- level complete functions
--
--------------------------------------------------------
function level_complete_init()
  level_complete_timer = 0
  accuracy = 0
  bonus = 0
  enemy_squadron_size = level + 5
  if enemy_squadron_size > 15 then
    enemy_squadron_size = 20
  end
  bonus_round_enemy_spawn_count = 0  
end

function level_complete_finish()
  -- reset game state
end

function level_complete_update()
  if current_game_state.game_state == game_states.level_complete then
    if level_complete_timer == 0 then
      for e in all(enemies) do
        e.y += 1
        if e.y > 0 then 
          del(enemies, e)
        end
      end

      play_sfx(sound_level_complete)  
    end

    --set shot accuracy
    if level_complete_timer == 30 then
      play_sfx(sound_compute_kill_score)
      accuracy = flr((enemies_destroyed/enemies_dispatched)*100)
    end

    --set kill score
    if level_complete_timer == 60 then
      play_sfx(sound_compute_kill_score)
      bonus = accuracy * 10
      score += bonus
    end

    --pause after kill score before level begins
    if level_complete_timer > 120  then
      level += 1 
      if level > 2 and level % 2 != 0 then
        switch_state(bonus_level_state)
      else
        switch_state(normal_level_state)  
      end
    end
  end
  
  level_complete_timer += 1
end

function level_complete_draw()
  cls()
  
  print("bonus points", 46, 45, 7)
  
  if level_complete_timer >= 50 then
    print("accuracy: "..accuracy.."%", 46, 55, 7)
  end

  if level_complete_timer >= 100 then
    print("bonus: "..bonus.."!", 46, 65, 7)
  end
end

--ships have different possible paths
--straight down, diagonal left, diagonal right and sine wave path
function update_enemy_ship_path(e)

  e.dispatch_timer -= 1
  if e.dispatch_timer > 0 then
    return
  end
  
  if e.path == 1 then
     --do nothing
     e.x += 0
  elseif e.path == 2 then
    e.x += e.speedx
    if e.x > 125 then
      e.x = 4
    end
  elseif e.path == 3 then
  		e.x -= e.speedx
  		if e.x < 0 then
  		   e.x = 125
  		end
  elseif e.path == 4 then
    e.x += (e.speedx * cos(e.y/128))
    if e.x > 128 then
      e.x = 128 
    end 
  elseif e.path == 5 then
    e.x -= (e.speedx * cos(e.y/128))
    if e.x > 128 then
      e.x = 128 
    end 
  else
  	 local delta = player.x - e.x
  	 if delta > 0 then
  	   delta = 1 * e.speedx
  	 else
  	   delta = -1 * e.speedx
  	 end
  	 
  	 if e.x < 0 then
  	    e.x = 125
  	 elseif e.y > 128 then
  	    e.x = 0
  	 end
  end
end

function spawn_meteors()
  local time_span = 80 - (level*10)

  --these are the meteors and there can be only max enemies
  if meteor_timer > (time_span/2) and #enemies <= max_enemies then
    meteor_timer = 0

    add(enemies, {
      x = flr(rnd(12))*10,
      y = flr(rnd(4))*8,
      path = flr(rnd(6)),
      speedx = 0,
      speedy = 1+ flr(rnd(3))/5,
      sp = 10, -- sprite 10 is meteor
      breakable = false,     --this is the main difference between a meteor and a enemy ship
      dispatch_timer = 0,
      life = 6
    }) 
  end  
end


function spawn_enemy_space_ships()

  -- spawn enemies periodically
  enemy_timer += 1
  meteor_timer += 1
  local time_span = 80 - (level*10)
  if time_span < 10 then
    time_span = 10
  end 

  if enemies_count > 0 and enemy_timer > time_span then
    enemy_timer = 0
    enemies_dispatched += 1
    add(enemies, {
      x = flr(rnd(120)),
      y = -8,
      path = flr(rnd(6)),
      speedx = 1+ flr(rnd(3)),
      speedy = 1+ flr(rnd(3)),
      sp = 4 + flr(rnd(5)), -- sprite 4 to 7 
      breakable = true,
      dispatch_timer = 0,
      life = 1     
    })
  end
end 

dispatched_enemies = 0
function spawn_bonus_enemies()

  local ready_for_spawn = true
  for e in all(enemies) do
    if e.dispatch_timer > 0 then
      e.dispatch_timer -= 1
    else
      e.y += e.speedy
    end 

    if e.y > 0 and not e.dispatched then
      e.dispatched = true
      dispatched_enemies += 1
    end
    if not e.dispatched or e.y > 0 then
      ready_for_spawn = false
    end
  end

  --only six waves of attacks
  if ready_for_spawn and  bonus_round_enemy_spawn_count == 6 then
    switch_state(level_complete_state)
    return
  end

  local sequences = {2, 3, 4, 5, 2, 3, 4, 5, 2}
  local x_locations = {20, 100, 20, 100, 20, 100, 20, 100, 20}
  local enemy_sprites = {4,4,5,5,6,6,7,7,4,4,5,5,6,6,7,7}
  if ready_for_spawn then
    bonus_round_enemy_spawn_count += 1
    if bonus_round_enemy_spawn_count > #sequences then
      bonus_round_enemy_spawn_count = 1
    end

    enemy_timer = 0

    first_enemy = {
      x = x_locations[bonus_round_enemy_spawn_count],
      y = -8,
      path = sequences[bonus_round_enemy_spawn_count],
      speedx = 1.5,
      speedy = 1.5,
      sp = enemy_sprites[bonus_round_enemy_spawn_count], -- sprite 4 to 7 
      breakable = true, 
      dispatch_timer = 10,
      life = 1    
    }

    if first_enemy.sp > 7 then
      first_enemy.sp = 4 -- limit to sprite 7
    end

    for i=1, enemy_squadron_size do
      enemies_dispatched += 2
      if i == 1 then
        add(enemies, first_enemy)
        add(enemies, {
          x = first_enemy.x+10,
          y = first_enemy.y,
          path = first_enemy.path,
          speedx = first_enemy.speedx,
          speedy = first_enemy.speedy,
          sp = first_enemy.sp,
          breakable = first_enemy.breakable,
          dispatch_timer = first_enemy.dispatch_timer,
          life = 1
        })
      else
        -- spawn enemies in a line
        add(enemies, {
          x = first_enemy.x,
          y = first_enemy.y,
          path = first_enemy.path,
          speedx = first_enemy.speedx,
          speedy = first_enemy.speedy,
          sp = first_enemy.sp,
          breakable = first_enemy.breakable,
          dispatch_timer = 10*i+10,
          life = 1
        })
        add(enemies, {
          x = first_enemy.x+10,
          y = first_enemy.y,
          path = first_enemy.path,
          speedx = first_enemy.speedx,
          speedy = first_enemy.speedy,
          sp = first_enemy.sp,
          breakable = first_enemy.breakable,
          dispatch_timer = 10*i+10,
          life = 1
        })
      end
    end
  end
end 

function spawn_enemies()
  spawn_enemy_space_ships()
  spawn_meteors()
end

function detect_player_collision(player, enemy_object, damage)
  player_hit = false
  if current_game_state.game_state != game_states.game_over then
    if player.alive and  abs(enemy_object.x - player.x) < 6 and abs(enemy_object.y - player.y) < 6 then
      player_hit = true
      player.health_meter -= damage

      if player.v_guns then
        -- if player has vertical guns, remove them on hit
        player.v_guns = false
      elseif player.twin_guns then
        -- if player has twin guns, remove them on hit
        player.twin_guns = false
      end
      
      play_sfx(8)
      for i=1,8 do
          add(particles, {
            x = player.x + 4,
            y = player.y + 4,
            dx = (rnd(2) - 1)*3,
            dy = (rnd(2) - 1)*3,
            life = 15,
            color = 7
          })
      end			   	
    end
  end

  return player_hit
end 

function is_key_down(char)
  -- stat(28) returns bitfield of held keys
  local held = stat(28)
  local code = ord(char)
  return band(held, shl(1, code)) != 0
end

function game_over_game_play()
  update_player_bullets()
  update_enemy_bullets()
  spawn_enemies()
  add_meteor_trails()

  -- update enemies
  enemy_bullet_timer += 1
  for e in all(enemies) do   
    if e.dispatch_timer > 0 then
      e.dispatch_timer -= 1
    else
      e.y += e.speedy
    end 

    fire_bullets(e)
    update_enemy_ship_path(e)
    delete_enemy(e)
    detect_player_collision(player, e, 4)
  end

  -- bullet-enemy collision
  update_particles()
  update_meteor_trails()
end

function move_player_sideways()

  local moved_left = btn(0)     -- Left arrow
  local moved_right = btn(1)    -- Right arrow

  -- Read keyboard inputs using stat(31)
  local key = stat(28)

  -- Also check if 'A' or 'D' is pressed (using ASCII codes)
  if is_key_down("a") then moved_left = true end   -- 'a'
  if is_key_down("d") then moved_right = true end -- 'd'

  -- player movement
  if moved_left then -- left
    player.x -= player.spd
    player.sprite = player_left
  elseif moved_right then -- right
    player.x += player.spd
    player.sprite = player_right
  else
    player.sprite = player_idle
  end

  --up and down travel
  if btn(3) then -- up
    player.y += player.spd*3
  elseif btn(2) then -- down
    player.y -= player.spd*3
  end

  if player.y < 10 then 
    player.y = 10
  end
  
  if player.y > 100 then
    player.y = 100
  end
    
  -- clamp player to screen
  player.x = mid(0, player.x, 120)
end 

function spawn_player()
  player.respawn_timer -= 1
  if player.lives > 0 and player.respawn_timer <= 0 and not player.alive then
    player.alive = true
  end
end

function fire_bullets(e) 
  if bonus_round then
    return
  end

  if e.breakable and enemy_bullet_timer > 10 then --non breakables i.e. meteors can't shoot bullets
    if e.y == 10 or e.y == 18 or e.y == 26 or e.y == 34 then
      add(enemy_bullets, {
        x = e.x + 4,
        y = e.y + 4
      })
      play_sfx(6)
      enemy_bullet_timer = 0
    end
  end
end 

function delete_enemy(e) 
 if e.y > 128 then
    del(enemies, e)
  end
end 

function delete_bonus_enemy(e) 
  if e.dispatched and e.y < 0 then
    del(enemies, e)
  end
end 

function player_fire()
  if player.alive and  btnp(4) or btnp(5) then
    add(bullets, {
      x = player.x + 4,
      y = player.y - 2
    })
    if player.twin_guns then
      add(bullets, {
        x = player.x + 1,
        y = player.y - 2
      })
      add(bullets, {
        x = player.x + 7,
        y = player.y - 2
      })
    end

    if player.v_guns then
      add(bullets, {
        x = player.x + 2,
        y = player.y - 2,
        dx = -1,
        dy = -2
      })
      add(bullets, {
        x = player.x + 6,
        y = player.y - 2,
        dx = 1,
        dy = -2
      })
    end

    play_sfx(1)
    shots_fired_count += 1
  end
end 

function update_player_bullets() 
  -- update bullets
  for b in all(bullets) do

    if not(b.dx == nil) then
      b.x += b.dx
      b.y += b.dy
    else
      b.y -= 4
    end

    if b.y < -8 then
      del(bullets, b)
    end

    if b.x < 0 or b.x > 128 then
      del(bullets, b)
    end
  end
end 

function update_enemy_bullets()
  for eb in all(enemy_bullets) do
    eb.y += 4
    if eb.y > 136 then
      del(enemy_bullets, eb)
    end
  end
end 

function update_particles()
  -- update particles
  for p in all(particles) do
    p.x += p.dx
    p.y += p.dy
    p.life -= 1
    if p.life <= 0 then
      del(particles, p)
    end
  end
end 

function detect_enemy_player_bullet_collisions()
  for b in all(bullets) do
    for e in all(enemies) do
      if abs(b.x - e.x) < 6 and abs(b.y - e.y) < 6 then

        local color = 10
        local life = 20
        local sound = 2
        del(bullets, b)
        if not e.breakable then
          color = 4
          life = 12
          e.life -= 1
          if e.life <= 0 then
            del(enemies, e)
            score += 10
            add_kill_points(e.x, e.y, 15)
          end
        else
          del(enemies, e)
          enemies_count -= 1
          score += 1
          enemies_destroyed += 1
          add_kill_points(e.x, e.y, 1)
        end

        -- spawn explosion particles
        for i=1,6 do
          add(particles, {
            x = e.x + 4,
            y = e.y + 4,
            dx = (rnd(2) - 1)*4,
            dy = (rnd(2) - 1)*4,
            life = life,
            color = color
          })
        end
        play_sfx(sound)

        break
      end
    end
  end
end 

previous_score = 0

---------------------------------------------------
--
-- normal level functions
--
---------------------------------------------------
function normal_level_init()
  player.alive = true
  player.sprite = player_idle
  player.respawn_timer = 120
  player.health_meter = max_health
  enemy_timer = 0
  meteor_timer = 0

  enemies_count = enemy_squadron_size
  player.x = mid(0, player.x, 120)
  player.y = 120
  shots_fired_count = 0
  enemies_dispatched = 0
  enemies_destroyed = 0
end

function normal_level_update()
  add_star_layers()
  update_star_layers()
  update_power_up()
  spawn_player()
  move_player_sideways()
  add_after_burner(player.x, player.y + 10)
  player_fire()
  update_player_bullets()
  update_enemy_bullets()
  spawn_enemies()
  add_meteor_trails()
  update_after_burner()

  -- update enemies
  enemy_bullet_timer += 1
  for e in all(enemies) do   
    if e.dispatch_timer > 0 then
      e.dispatch_timer -= 1
    else
      e.y += e.speedy
    end 

    fire_bullets(e)
    update_enemy_ship_path(e)
    delete_enemy(e)
    detect_player_collision(player, e, 4)
  end

  update_kill_points()

  --enemy bullet collision with our ship
  for eb in all(enemy_bullets) do
    detect_player_collision(player, eb, 1)     
  end

  local game_over_triggered = false
  if player.alive then
    -- check if player is alive and update health meter
    if player.health_meter <= 0 then
      player.alive = false
      player.respawn_timer = 90
      player.lives -= 1
      player.health_meter = max_health
      if player.lives == 0 then
        game_over()
        game_over_triggered = true
      end 
    end
  end


  if player.health_meter <= 0 then
    player.alive = false
    player.respawn_timer = 90
    player.lives -= 1
    player.health_meter = max_health
    if player.lives == 0 then
      game_over_triggered = true
    end 
  end

  if game_over_triggered then
      game_over()
  else 
        -- bullet-enemy collision
    detect_enemy_player_bullet_collisions()
    update_particles()
    update_meteor_trails()
    begin_level_complete()
  end
end

function normal_level_draw()
  cls()
  draw_star_layers()
  draw_hud()
  draw_after_burner()

  -- draw player
  draw_player()
  draw_bullets()
  draw_power_up()
  draw_enemy_ships()
  draw_meteor_trails()
  draw_particles()
  draw_kill_points()
end

function normal_level_finish()
  clear_game_objects()

  -- reset game state
  player.alive = true
  player.x = 64
  player.y = 120
  player.sprite = player_idle
  player.respawn_timer = 300
  enemies_count = enemy_squadron_size
  enemy_timer = 0
end

--------------------------------------------------
--
--
-- bonus level functions
--
--------------------------------------------------

function bonus_level_init()
  player.alive = true
  player.x = 64
  player.y = 120
  player.sprite = player_idle
  player.respawn_timer = 300
  player.health_meter = max_health
  enemies_count = 20
  enemy_timer = 0
  enemmies_dispatched = 0
  enemies_destroyed = 0
  enemmy_squadron_size = 10
end

function bonus_level_update()
  add_star_layers()
  update_star_layers()
  spawn_player()
  move_player_sideways()
  add_after_burner(player.x, player.y + 10)
  player_fire()
  update_player_bullets()
  spawn_bonus_enemies()
  
  for e in all(enemies) do   
    if e.dispatch_timer > 0 then
      e.dispatch_timer -= 1
    else
      e.y += e.speedy
      e.dipatched = true
    end 

    update_enemy_ship_path(e)
    if e.y > 89 then
      e.speedy *= -1
      e.speedx *= -1
    end
    delete_bonus_enemy(e)
    detect_player_collision(player, e, 4)
  end

  -- bullet-enemy collision
  detect_enemy_player_bullet_collisions()  
  update_particles()
  update_after_burner()
end


function bonus_level_draw()
  cls()
  draw_hud()

  draw_star_layers()
  -- draw player
  draw_player()
  draw_bullets()
  draw_enemy_ships()
  draw_particles()
  draw_after_burner()
end

function bonus_level_finish()
  -- reset game state
  player.x = 64
  player.y = 120
  player.sprite = player_idle
  player.respawn_timer = 300
  enemies_count = enemy_squadron_size
  enemy_timer = 0

  clear_game_objects()
  -- reset particles and bullets
  
end

function clear_game_objects()
  for e in all(enemies) do
    del(enemies, e)
  end

  for b in all(bullets) do
    del(bullets, b)
  end
  for p in all(particles) do
    del(particles, p)
  end
  for ab in all(after_burner) do
    del(after_burner, ab)
  end
  for mt in all(meteor_trails) do
    del(meteor_trails, mt)
  end

  bullets = {}
  enemy_bullets = {}
  enemies = {}
  particles = {}
end
--------------------------------------------------------------
-- game over functions
--------------------------------------------------------------
function game_over_init()
  clear_game_objects()
  player.alive = false
  player.x = 64
  player.y = 120
  player.sprite = player_idle
  player.respawn_timer = 300
  player.health_meter = max_health
  enemies_count = 5
  enemy_timer = 0
  shots_fired_count = 0
  game_over_timer = 45
end 

function game_over_update()
  game_over_timer -= 1
  if game_over_timer <= 0 and btnp(4) then     
       score = 0
       level = 1
       player.lives = 3
       clear_game_objects()
      switch_state(normal_level_state)
  else
    game_over_game_play()
  end
end

function game_over_draw()
  cls()

  spawn_enemies()
  draw_hud()
  draw_bullets()
  draw_enemy_ships()
  draw_meteor_trails()
  draw_particles()

  --rectfill(10, 50, 50, 20, 0)
  print("game over", 46, 55, 7)
  print("press x to start", 32, 65, 7)
end

function game_over_finish()
  -- reset game state
   level = 1
   player.lives = 3
end 

function _update()
  current_game_state.update()
end

function repstring(val, n)
  local out = ""
  for i = 1, n do
    out = out..val
  end

  return out
end




function update_power_up()
  if flr(time()%15) == 0 then
    if power_up.alive == false then
      power_up.alive = true
      power_up.x = flr(rnd(80)) + 20
      power_up.y = 0
    end
  end
  if power_up.alive then
    power_up.y += 1
    if power_up.y > 128 then
      power_up.alive = false
    end

    -- check collision with player
    if abs(power_up.x - player.x) < 6 and abs(power_up.y - player.y) < 6 then
      player.health_meter = min(player.health_meter + 1, max_health)
      power_up.alive = false
      play_sfx(3) -- play power-up sound
      if player.twin_guns then
        player.v_guns = true -- if player already has twin guns, give vertical guns
      end
      player.twin_guns = true
    end
  end
end

function draw_power_up()
  if power_up.alive then

    if power_up.y < 0 then
      return -- don't draw if not on screen
    end

    local s = 16 + flr(power_up.y/2)%6 
    spr(s, power_up.x, power_up.y) -- draw power-up sprite
  end
end

function draw_hud()
  local lifestring = repstring("|", player.health_meter)
  local health_color = 2
  
  if player.health_meter < 3 then
    health_color = 8
  else
    health_color = 11 
  end 

  print("score ", 2, 2, 9) 
  print(""..score, 4, 9, 7)
  spr(1, 54, 0)
  print(""..player.lives, 64, 2, 8)
  spr(4, 84, 0)   --alien lives
  print(""..enemies_count, 94, 2, 8)
  print(lifestring, 54, 9, health_color)
  print(lifestring, 55, 9, health_color)
  print(lifestring, 56, 9, health_color)
  print(lifestring, 57, 9, health_color)
  
  print("level: ", 110, 2, 9)
  print(""..level, 113, 9, 7 )
end

function draw_after_burner()
  if current_game_state.game_state == game_states.playing or
     current_game_state.game_state == game_states.playing_bonus then 
    for p in all(after_burner) do 
      circfill(p.x,p.y, p.r, p.color)
      circfill(p.x,p.y, p.r-1, 7)
      
    end 
  end 
end

function draw_meteor_trails()
  for m in all(meteor_trails) do 
    circfill(m.x,m.y, m.r, m.color)
  end 
end

function draw_player()
  if current_game_state.game_state != game_states.game_over then
    if player.alive then
      spr(player.sprite, player.x, player.y)
    elseif player.respawn_timer % 3 == 0 then
      spr(player.sprite, player.x, player.y)
    end
  end
end 

function draw_bullets() 
  -- draw bullets
  for b in all(bullets) do

    if not(b.dx == nil) then
      --if b.dx < 0 then
        -- draw bullet with left direction
     --   line(b.x, b.y, b.x + b.dx, b.y + b.dy, 7)
     -- else
        -- draw bullet with right direction
     --   line(b.x+7, b.y, b.x + 1 + b.dx, b.y + b.dy, 7)
     -- end
      if b.dx < 0 then
        line(b.x, b.y, b.x+b.dx, b.y+b.dy, 7)
      else
        line(b.x+7, b.y, b.x+7+b.dx, b.y+b.dy, 7)
      end
    else
        rectfill(b.x, b.y, b.x-1, b.y-2, 7)
    end
  end

  for b in all(enemy_bullets) do
    rectfill(b.x, b.y, b.x+1, b.y+3, 10)
  end
end 

function draw_enemy_ships()
  -- draw enemies
  for e in all(enemies) do
    if e.speedy < 0 then
      spr(e.sp, e.x, e.y, 1, 1, false, true) -- flip vertically
    else 
      spr(e.sp, e.x, e.y)
    end
  end
end 

function draw_particles() 
  -- draw particles
  for p in all(particles) do
    rectfill(p.x, p.y, p.x+1, p.y+1, p.color) -- orange
  end
end 


function _draw()
  current_game_state.draw()
end
