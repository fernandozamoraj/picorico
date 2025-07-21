pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
  -- add payout screens
  -- fix bug with elements on edges of reels
  -- give bonus round spins
  -- free games and increase the odds by changing the reels on any four wild cherries
  -- 2x is wild and pays out double 
  -- 2x 2x pays out four times
  -- make bet 2 4 6 12 18
  -- pay tables
  --      2x 2x 2x jackpot
  --      7  7  7  black
  --      7  7  7  red
  --    
  -- problem with seeing symbole 100 and also showing the right payline
  -- scrolling markee that says good luck but when a win happens it displays the win
  -- display big win on anything 20x the bet amount
  -- display big win on anything 20x the bet amount
--- can bet upt to 5 and only the lines played can win...
-- e.g.  bet 1,2,3 or 5... thats the max bet
  dev_setting_debug_on = false
  dev_setting_ignore_shuffle = false
  dev_setting_use_winner_tables = false


  --list of game colors
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

  primary_color = colors.blue
  primary_text_color = colors.white
  secondary_color = colors.indigo
  background_color = colors.dark_blue

  game_states = {
    spinning     = 0,
    idle         = 1,
    stopping     = 2,
    unveil       = 3,
    free_spins   = 4,
    start_screen = 5,
    win_awards   = 6
  }

  buttons = {
    coll    = 0,
    na      = 1,
    spin    = 2,
    max     = 3,
    upbet   = 4
  }

  wins = {}
  win_timer = 0
  max_bet_amount = 5
  win_multiplier = 2

  current_btn = buttons.spin  
  btn_highlight_color = 7
  btn_bg_color = 3
  stats_display_box_color = 8

  reel1_payline = 0
  reel2_payline = 0
  reel3_payline = 0

  game_state = game_states.idle
  reel1_speed = 4
  reel2_speed = 4
  reel3_speed = 4

  btn_click_delay = 0

  credits = 100
  bet_amount = 1
  paid_amount = 0

  player = {
    credits = 0,
    bet_amount = 1,
    denom = 1
  }

  bottom_reel1_position = {
    x = 45,
    y = 100  
  }

  bottom_reel2_position = {
    x = 55,
    y = 100  
  }

  bottom_reel3_position = {
    x = 65,
    y = 100  
  }

  spin_triggered = false
  bottom_reel1_position.y = (flr(rnd(100)))*10
  bottom_reel2_position.y = (flr(rnd(100)))*10
  bottom_reel3_position.y = (flr(rnd(100)))*10
  virtual_stop_reel1 = 0
  virtual_stop_reel2 = 0
  virtual_stop_reel3 = 0
  actual_stop_reel1 = -1
  actual_stop_reel2 = -1
  actual_stop_reel3 = -1

  reel_sfx_playing = false

  reel1 = {
    9,
    8,8,8,
    7,7,7,7,7,
    6,6,6,6,6,6,6,6,6,6,
    5,5,5,5,5,5,5,5,5,5,
    4,4,4,4,4,4,4,4,4,4,
    3,3,3,3,3,3,3,3,3,3,
    2,2,2,2,2,2,2,2,2,2,2,
    1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1
  }

  reel2 = {
    9,
    8,8,8,
    7,7,7,7,7,
    6,6,6,6,6,6,6,6,6,6,
    5,5,5,5,5,5,5,5,5,5,
    4,4,4,4,4,4,4,4,4,4,
    3,3,3,3,3,3,3,3,3,3,
    2,2,2,2,2,2,2,2,2,2,2,
    1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1
  }
  reel3 = {
    9,
    8,8,8,
    7,7,7,7,7,
    6,6,6,6,6,6,6,6,6,6,
    5,5,5,5,5,5,5,5,5,5,
    4,4,4,4,4,4,4,4,4,4,
    3,3,3,3,3,3,3,3,3,3,
    2,2,2,2,2,2,2,2,2,2,2,
    1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1
  }

  is_shuffled = false
  coins_fountain = {}
  --sounds
  sound_jackpot = 5   
  sound_big_win = 6  
  sound_win     = 7

  scrolling_text = "good luck! spin the reels and try your luck at rico rich casino! press x to spin, o to increase bet, and [] for max bet. enjoy the game!"
  

  function _init()
    if dev_setting_use_winner_tables then
      reel1 = {
        9,9,9,9,9,9,9,9,9,9,
        8,8,8,8,8,8,8,8,8,8,
        7,7,7,7,7,7,7,7,7,7,
        6,6,6,6,6,6,6,6,6,6,
        5,5,5,5,5,5,5,5,5,5,
        4,4,4,4,4,4,4,4,4,4,
        3,3,3,3,3,3,3,3,3,3,
        2,2,2,2,2,2,2,2,2,2,
        2,2,2,2,2,2,2,2,2,2,
        5,5,5,5,5,5,5,5,5,5,
      }

      reel2 = {
        9,9,9,9,9,9,9,9,9,9,
        8,8,8,8,8,8,8,8,8,8,
        7,7,7,7,7,7,7,7,7,7,
        6,6,6,6,6,6,6,6,6,6,
        5,5,5,5,5,5,5,5,5,5,
        4,4,4,4,4,4,4,4,4,4,
        3,3,3,3,3,3,3,3,3,3,
        2,2,2,2,2,2,2,2,2,2,
        2,2,2,2,2,2,2,2,2,2,
        5,5,5,5,5,5,5,5,5,5,
      }
      reel3 = {
        9,9,9,9,9,9,9,9,9,9,
        8,8,8,8,8,8,8,8,8,8,
        7,7,7,7,7,7,7,7,7,7,
        6,6,6,6,6,6,6,6,6,6,
        5,5,5,5,5,5,5,5,5,5,
        4,4,4,4,4,4,4,4,4,4,
        3,3,3,3,3,3,3,3,3,3,
        2,2,2,2,2,2,2,2,2,2,
        2,2,2,2,2,2,2,2,2,2,
        5,5,5,5,5,5,5,5,5,5,
      }
    end
  end 


  function shuffle_reel(t)
    for i=#t,2,-1 do
      local j = flr(rnd(i))+1
      t[i], t[j] = t[j], t[i]
    end
  end

  function suffle_reels()

    if not dev_setting_ignore_shuffle then
      if not is_shuffled then
        rnd(time(0))
        virtual_stop_reel1 = flr(rnd(100)+1)
        virtual_stop_reel2 = flr(rnd(100)+1)
        virtual_stop_reel3 = flr(rnd(100)+1)
        shuffle_reel(reel1)
        shuffle_reel(reel2)
        shuffle_reel(reel3)
        is_shuffled = true
      end 
    else
      if not is_shuffled then
        virtual_stop_reel1 = flr(rnd(100)+1)
        virtual_stop_reel2 = flr(rnd(100)+1)
        virtual_stop_reel3 = flr(rnd(100)+1)
        is_shuffled = true
      end
    end
  end

  function spin_clicked()
    return (btnp(4) and current_btn == buttons.spin)
  end

  function upbet_clicked()
    return (btnp(4) and current_btn == buttons.upbet)
  end

  function maxbet_clicked()
    return (btnp(4) and current_btn == buttons.max)
  end

  function is_spinning()
    return spin_triggered
  end

  function get_reel_stop()

    local value = 0

    --todo: this is a hack because i have a bug that prevents stopping on these 4 values
    --the todo is the bug because it when shuffled one of these values is the jackpot
    --it will never hit the jack pot
    --do not ship out with this bug!!!!!!!s!!!!!!!!!!!
    --while value == 0 or value == 1 or value == 2 or value > 97 do 
      value = flr(rnd(100)+1)
   -- end

    return value
  end

  function check_jackpot(row1, row2, row3) 

    if (row1[2] == row2[2] and row2[2] == row3[2] and row3[2] == 1) then 
      add(wins, {
        line = 4,
        symbol = row1[2],
        win_amount = 1000 * win_multiplier
      })
    end 
  end 

  function check_win(row1, row2, row3) 
    local result = false

    local rows = {row1, row2, row3}
    local i = 1
    for row in all(rows) do

      if row[1] == row[2] and row[2] == row[3] and row[3] > 1 then
        add(wins, 
          {
              line = i,
              symbol = row[1],
              win_amount =  row[1] * 10 * bet_amount
          }
        )
      end
      i += 1
    end 

    --diagonal
    if (row1[1] == row2[2] and row2[2] == row3[3]) then 
      add(wins, 
        {
            line = 4,
            symbol = row1[1],
            win_amount =  row1[1] * 10 * bet_amount
        }
      )
    end  
    
    if (row1[3] == row2[2] and row2[2] == row3[1]) then 
      add(wins, 
        {
            line = 5,
            symbol = row1[3],
            win_amount =  row1[3] * 10 * bet_amount
        }
      )
    end  
  end

  function determine_wins()
    if paid_amount == 0 and
       actual_stop_reel1 == virtual_stop_reel1 and 
       actual_stop_reel2 == virtual_stop_reel2 and
       actual_stop_reel3 == virtual_stop_reel3 then 

      win_timer = 0

      local row1 = {0,0,0}
      local row2 = {0,0,0}
      local row3 = {0,0,0}

      row1[1] = reel1[actual_stop_reel1]
      row1[2] = reel2[actual_stop_reel2]
      row1[3] = reel3[actual_stop_reel3]

      local normalize_index = function(index)
        if index < 1 then
          return index + 100
        elseif index > 100 then
          return index - 100
        else
          return index
        end
      end
      
      row2[1] = reel1[normalize_index(actual_stop_reel1-1)]
      row2[2] = reel2[normalize_index(actual_stop_reel2-1)]
      row2[3] = reel3[normalize_index(actual_stop_reel3-1)]
      
      row3[1] = reel1[normalize_index(actual_stop_reel1-2)]
      row3[2] = reel2[normalize_index(actual_stop_reel2-2)]
      row3[3] = reel3[normalize_index(actual_stop_reel3-2)]

      determine_wins_custom(row1, row2, row3)
    end
  end 

  function move_closer_to_target()
    local function target_y(stop, r)
      -- y offset to align target in visible window (centered at ~40)
      local symbol_height = 10
      local visible_center = 100*r
      local newstop = (stop * symbol_height) - visible_center
      if newstop < 0 then
        newstop += 1000
      end
      return newstop
    end

    bottom_reel1_position.y = target_y(virtual_stop_reel1, 1)
    bottom_reel2_position.y = target_y(virtual_stop_reel2, 2)
    bottom_reel3_position.y = target_y(virtual_stop_reel3, 3)
  end

  function spin_reels()

    if dev_setting_use_winner_tables then 
      virtual_stop_reel1 = get_reel_stop()
      virtual_stop_reel2 = virtual_stop_reel1
      virtual_stop_reel3 = virtual_stop_reel2
    else 
      virtual_stop_reel1 = get_reel_stop()  
      virtual_stop_reel2 = get_reel_stop()
      virtual_stop_reel3 = get_reel_stop()
    end

    actual_stop_reel1 = -1
    actual_stop_reel2 = -1
    actual_stop_reel3 = -1
    spin_triggered = true
    paid_amount = 0
    wins = {}
    move_closer_to_target()
    reset_scrolling_markee()
  end 

  function hinge_reel(r) 

    if not( r.y % 10 == 0) then
      r.y += 10 --what a hack... idk what i am doing just experimenting
      local diff = r.y % 10 
      
      if( diff < 2) then
        r.y -= diff 
      end
    end
  end

  function hinge_reels()

    if virtual_stop_reel1 == actual_stop_reel1 then
      hinge_reel(bottom_reel1_position)
    end 

    if virtual_stop_reel2 == actual_stop_reel2 then
      hinge_reel(bottom_reel2_position)
    end 

    if virtual_stop_reel3 == actual_stop_reel3 then
      hinge_reel(bottom_reel3_position)
    end 
  end

  function move_reels_to_target()
    local function target_y(stop)
      -- y offset to align target in visible window (centered at ~40)
      local symbol_height = 10
      local visible_center = 40
      return (stop * symbol_height) - visible_center
    end

    if virtual_stop_reel1 != actual_stop_reel1 then
      bottom_reel1_position.y = target_y(virtual_stop_reel1)
    end
    if virtual_stop_reel2 != actual_stop_reel2 then
      bottom_reel2_position.y = target_y(virtual_stop_reel2)
    end
    if virtual_stop_reel3 != actual_stop_reel3 then
      bottom_reel3_position.y = target_y(virtual_stop_reel3)
    end
  end

  function override_and_spin()
    if btn(3) then
      spin_reels()
    end 
  end

  function calculate_win_amount()
    
    local win_amount = 0
    for w in all(wins) do 
      win_amount += w.win_amount
    end 

    return win_amount
  end 

  function do_coin_foiuntain()
    local coins_qty = flr(paid_amount / 10)
    if #coins_fountain < coins_qty then
      local x = 30 + flr(rnd(40))
      local y = 20 + flr(rnd(20))
      local speedx = flr(rnd(8)) - 4
      local speedy = (2 + flr(rnd(3)))*-1
      local gravity = 0.1
      add(coins_fountain, {x = x, y = y, speedy = speedy, speedx = speedx, gravity = gravity})
    end
  end

  function update_coins_fountain()
    for i = #coins_fountain, 1, -1 do
      local coin = coins_fountain[i]
      coin.gravity += (coin.gravity*.3) 
      coin.speedy += coin.gravity
      coin.x += coin.speedx
      coin.y += coin.speedy 
      coin.y -= coin.gravity
      if coin.y < 0 then
        del(coins_fountain, coin)
      end
    end
  end

  function draw_coins_fountain()
    for coin in all(coins_fountain) do
      spr(35, coin.x-5, coin.y+12) -- assuming sprite 1 is a coin
    end
    for coin in all(coins_fountain) do
      spr(32+flr(rnd(2)), coin.x, coin.y) -- assuming sprite 1 is a coin
    end
  end

  function update_reels()

    if spin_triggered then
      --increase y position for the reels
       --only if they have not reached their stop
      if not (actual_stop_reel1 == virtual_stop_reel1) then
        bottom_reel1_position.y += reel1_speed;
      end
      
      if not (actual_stop_reel2 == virtual_stop_reel2) then
        bottom_reel2_position.y += reel2_speed;
      end 

      if not (actual_stop_reel3 == virtual_stop_reel3) then
        bottom_reel3_position.y += reel3_speed;
      end 

      --reconcile reels if over 1000
      if bottom_reel1_position.y > 1000 then
        bottom_reel1_position.y -= 1000
      end

      if bottom_reel2_position.y > 1000 then
        bottom_reel2_position.y -= 1000
      end

      if bottom_reel3_position.y > 1000 then
        bottom_reel3_position.y -= 1000
      end

       --divide by 10 because the symbols are in 10 pixel slots
       --add 1 because luas arrays or list are 1 based no 0 based
      local reel1_symbol_index = flr((bottom_reel1_position.y) / 10)+1;
      local reel2_symbol_index = flr((bottom_reel2_position.y) / 10)+1;
      local reel3_symbol_index = flr((bottom_reel3_position.y) / 10)+1;

      if not (virtual_stop_reel1 == actual_stop_reel1) then 
        if virtual_stop_reel1 == reel1_symbol_index then 
          actual_stop_reel1 = reel1_symbol_index
        end
      end

      if not (virtual_stop_reel2 == actual_stop_reel2) then 
        if virtual_stop_reel2 == reel2_symbol_index then 
          actual_stop_reel2 = reel2_symbol_index
        end
      end
      
      if not (virtual_stop_reel3 == actual_stop_reel3) then 
        if virtual_stop_reel3 == reel3_symbol_index then 
          actual_stop_reel3 = reel3_symbol_index
        end
      end

      --hinge th reels
      if actual_stop_reel1 == virtual_stop_reel1  then 
        bottom_reel1_position.y = bottom_reel1_position.y - bottom_reel1_position.y%10
      end

      if actual_stop_reel2 == virtual_stop_reel2 then 
        bottom_reel2_position.y = bottom_reel2_position.y - bottom_reel2_position.y%10
      end
 
      if actual_stop_reel3 == virtual_stop_reel3 then 
        bottom_reel3_position.y = bottom_reel3_position.y - bottom_reel3_position.y%10     
      end

      if actual_stop_reel1 == virtual_stop_reel1 and 
        actual_stop_reel2 == virtual_stop_reel2 and 
        actual_stop_reel3 == virtual_stop_reel3 then 
        spin_triggered = false
      end
    end
  end 

  function reset_scrolling_markee()
    scrolling_text = "good luck! spin the reels and try your luck at rico rich casino! press x to spin, o to increase bet, and [] for max bet. enjoy the game!"
  end

  function set_wins_to_scrolling_markee()
    scrolling_text = ""
    if #wins > 0 then
      for win in all(wins) do 
        scrolling_text = "...line "..win.line.." pays "..win.win_amount..". "
      end
    else
      scrolling_text = "no wins this time. better luck next time!"
    end
  end

  function _update()

    update_coins_fountain()
    if(win_timer > 0) then
       do_coin_foiuntain()
      if paid_amount > 1000  % win_timer == 149 then
        sfx(sound_jackpot, 1, 1, 10)
      elseif win_timer == 149 then
        sfx(sound_big_win, 1, 1, 10)
      end 

      win_timer -= 1
    else

      sfx(-1, 1, 0)
      update_game()
      
      --paid amount gets cleared only on spin triggered
      if paid_amount == 0 then
        determine_wins()
        set_wins_to_scrolling_markee()
        if #wins > 0 then
          win_timer = 150
          paid_amount = calculate_win_amount()
          credits += paid_amount
          sfx(8)
        end
      end 
    end
  end

  function update_game()

    suffle_reels()
    hinge_reels()
    override_and_spin()
    update_reels()

    btn_click_delay += 1

    -- track whether sfx is already playing
    if is_spinning() and not reel_sfx_playing then
      sfx(7, 1) -- play sfx 2 on channel 1 (loop mode should be set in editor)
      reel_sfx_playing = true
    elseif not is_spinning() and reel_sfx_playing then
      sfx(-1, 1) -- stop sound on channel 1
      reel_sfx_playing = false
    end
    -- player movement
    if btn_click_delay > 10 and btn(0) then -- left
      current_btn = (current_btn - 1)
      btn_click_delay = 0
    elseif btn_click_delay > 10 and btn(1) then -- right
      current_btn = (current_btn + 1)
      btn_click_delay = 0
    end

    if current_btn < 0 then
      current_btn += 4
    elseif current_btn > 4 then
      current_btn -= 4
    end

    if not is_spinning() and spin_clicked() then
      if credits > bet_amount then
        credits -= bet_amount
        spin_reels()
        sfx(0)
      end
    elseif is_spinning() and spin_clicked() then
      move_reels_to_target()
      sfx(0)
    end 

    if not is_spinning() and upbet_clicked() then
      if credits > 0 then
        bet_amount += 1
        if bet_amount > 5 then
          bet_amount = 1
        end
        sfx(1)
      end
    end

    if not is_spinning() and maxbet_clicked() then
      if credits >= 5 then
        bet_amount = 5
        credits -= 5
        spin_reels()
        sfx(0)
      end
    end
  end

  function draw_stats()

    for i = 0, 1 do 
      rect(i*50+1, 91, i*50+46, 103, primary_color)
    end
  
    rect(2*50+1, 91, 2*50+25, 103, primary_color)

    print("crdts",     5, 95, primary_color)
    print(""..credits,  30, 95, primary_text_color)
    print("paid",       55, 95, primary_color)
    print(""..paid_amount, 75, 95, primary_text_color)
    print(""..bet_amount, 105, 95, primary_text_color)
    
  end 

  function draw_buttons()
    for i = 0, 4 do 
      rect(i*25+1, 106, i*25+24, 118, secondary_color)
    end

    rect(current_btn*25+1, 106, current_btn*25+24, 118, btn_highlight_color)
  
    print("coll",  5, 110, primary_color)
    print("    ",  30, 110, primary_color)
    print("spin",  55, 110, primary_color)
    print("max",  80, 110, primary_color)
    print("++", 105, 110, primary_color)
  end 

  function draw_reel(bottom_reel_position, reel, xoffset)    
    local second_symbol = flr((bottom_reel_position.y) / 10)+1;
    local third_symbol  = second_symbol - 1
    local fourth_symbol = second_symbol - 2
    local fifth_symbol  = second_symbol - 3
    local first_symbol  = second_symbol + 1

    --reconciles symbols to make sure they're
    --between 1 and 100 inclusive
    if second_symbol > 100 then 
      second_symbol -= 100
    end

    if third_symbol < 1 then 
      third_symbol += 100
    end
    
    if fourth_symbol < 1 then 
      fourth_symbol += 100
    end
    
    if fifth_symbol < 1 then 
      fifth_symbol += 100
    end
    
    if first_symbol > 100 then 
      first_symbol -= 100
    end

    local y = 20

    --draw symbols on same reel from top to bottom
    --first and last symbols do not count for prizes
    --only the 2nd through fourth symbols are active (lines 1,2, and 3)
    spr(reel[first_symbol],  30+xoffset, y)
    spr(reel[second_symbol], 30+xoffset, y+10)
    spr(reel[third_symbol],  30+xoffset, y+20)
    spr(reel[fourth_symbol], 30+xoffset, y+30)
    spr(reel[fifth_symbol],  30+xoffset, y+40)   
  end

  function draw_pay_lines()

    for pl in all(wins) do 
      if pl.line == 1 then 
        line(40, 33, 75, 33, 9)
      elseif pl.line == 2  then
        line(40, 43, 75, 43, 9)
      elseif pl.line == 3  then
        line(40, 53, 75, 53, 9)
      elseif pl.line == 4  then
        line(43, 30, 75, 60, 9)
      elseif pl.line == 5  then
        line(41, 60, 75, 30, 9)
      end
    end
  end

  function draw_win_symbols()
    if dev_setting_debug_on then
        local ypos = 30
        local xpos = 85
        for win in all(wins) do 
        spr(win.symbol, xpos, ypos)
        print(" on "..win.line.." "..win.win_amount, xpos+10, ypos, primary_color)
        ypos += 15
        end
    end
  end 

  function draw_scrolling_text(text, y, scroll_speed)
    local x = 0
    local text_length = #text * 4
 
    if text_length > 120 then
      x = (time() * scroll_speed) % (text_length + 120)
      if x > 120 then
        x = x - 120
      end
    end

    rectfill(0, y, 128, y + 10, primary_color)
    print(text, -x, y + 2, primary_text_color)
    rectfill(0, y, 3, y + 10, background_color)
    rectfill(125, y, 128, y + 10, background_color)
    
  end

  function draw_help_screen()
    rectfill(0, 0, 120, 20, primary_color)
    print("welcome to the slot machine!", 2, 2, primary_text_color)
    print("press [left] and [right] to change buttons", 2, 10, primary_text_color)
    print("press [up] to spin", 2, 18, primary_text_color)
    print("press [down] to upbet", 2, 26, primary_text_color)
    print("press [x] to max bet", 2, 34, primary_text_color)
  end

  function draw_game_title()
    rectfill(0, 0, 128, 15, primary_color)
    print("rico rich casino", 30, 6, primary_text_color)
  end

  function _draw()
    cls(background_color)
    draw_game_title()
    --place line numbers
    for i=1,3 do 
      print(""..i, bottom_reel1_position.x-10, i*10+21, primary_color)
    end
    for i=1,3 do 
      print(""..i, bottom_reel1_position.x+34, i*10+21, primary_color)
    end

    if dev_setting_debug_on then
      --draw debugging code... todo remove on actual game
      print("a1-"..actual_stop_reel1,  0, 100, 8)
      print("a2-"..actual_stop_reel2, 40, 100, 8)
      print("a3-"..actual_stop_reel3, 80, 100, 8)
      print("v1-"..virtual_stop_reel1,  0, 110, 8)
      print("v2-"..virtual_stop_reel2, 40, 110, 8)
      print("v3-"..virtual_stop_reel3, 80, 110, 8)
      spr(reel1[virtual_stop_reel1+1],  0, 117)
      spr(reel2[virtual_stop_reel2+1], 40, 117)
      spr(reel3[virtual_stop_reel3+1], 80, 117)
    end
    
    draw_buttons()
    draw_stats()
    rect(bottom_reel1_position.x-5,20, bottom_reel1_position.x+32,68, 7)
    draw_pay_lines()
    draw_win_symbols()

    --todo move back to top
    draw_reel(bottom_reel1_position, reel1, 13)
    --rectfill(0,  0, 120, 25, 0)
    --rectfill(0, 70, 120, 120, 0)

    draw_reel(bottom_reel2_position, reel2, 25)
    --rectfill(0,  0, 120, 25, 0)
    --rectfill(0, 70, 120, 120, 0)

    draw_reel(bottom_reel3_position, reel3, 37)
   -- rectfill(0,  0, 120, 25, 0)
   -- rectfill(0, 70, 120, 120, 0)

   draw_scrolling_text(scrolling_text, 78, 35)

    if dev_setting_debug_on then
      draw_help_screen()
    end

    if dev_setting_show_help then
      draw_help_screen()
    end

    draw_coins_fountain()
  end


function determine_wins_custom(row1, row2, row3)
  local function is_wild(val) return val == 3 or val == 4 end
  local function is_seven_eight(val) return val == 7 or val == 8 end

  local function pay_line(line, vals)
    if bet_amount < line then return end

    local a, b, c = vals[1], vals[2], vals[3]
    -- symbol 1 never wins
    if a == 1 or b == 1 or c == 1 then return end

    -- all alike
    if a == b and b == c then
      add(wins, {line = line, symbol = a, win_amount = a * win_multiplier})
      return
    end

    -- any combination of wilds (3 or 4) with any other symbol > 1
    local wild_count = (is_wild(a) and 1 or 0) + (is_wild(b) and 1 or 0) + (is_wild(c) and 1 or 0)
    local non_wilds = {}
    if not is_wild(a) then add(non_wilds, a) end
    if not is_wild(b) then add(non_wilds, b) end
    if not is_wild(c) then add(non_wilds, c) end

    -- if all are wilds, treat as a win
    if wild_count == 3 then
      add(wins, {line = line, symbol = 3, win_amount = 3 * win_multiplier})
      return
    end

    -- if there is at least one wild and the other symbols are the same and > 1
    if wild_count >= 1 and #non_wilds > 0 and non_wilds[1] == non_wilds[#non_wilds] and non_wilds[1] > 1 then
      local win_amount = non_wilds[1] * 10
      if wild_count == 2 then win_amount = win_amount * 2 end
      if wild_count == 3 then win_amount = win_amount * 3 end

      add(wins, {line = line, symbol = non_wilds[1], win_amount = win_amount})
       
      return
    end

    -- mixed 7/8
    if is_seven_eight(a) and is_seven_eight(b) and is_seven_eight(c) then
      local win_amount = 7 * 10
      if a == 8 or b == 8 or c == 8 then win_amount = 8 * win_multiplier end
      add(wins, {line = line, symbol = 7, win_amount = win_amount})
      return
    end
  end

  -- rows
  pay_line(1, row1)
  pay_line(2, row2)
  pay_line(3, row3)
  pay_line(4, {row1[1], row2[2], row3[3]})
  pay_line(5, {row1[3], row2[2], row3[1]}) 
end

__gfx__
0000000007777770077997700000060000006000000000000000000000000000000000000777777c000000000000000000000600000000000000000000000000
509999055777777557999775500060055006000557777775587887855888888550000005588777755b7bb7b55099990550006005588888855222222500000000
0909909007777770077997700088780000c6cc000777777007788770087778800077700007787770077bb7700909909000887800087778800227722000000000
598089955777777557799775587788855c77ccc55eeeeee5588888855777887557770075578707055bbbbbb55990099558778885577788755272272500000000
098009900777777007799770087888800c7cccc00e7ee7e0088888800778877007700770087770700bbbbbb00990099008788880077887700272272000000000
590980955777777557799775588888855cccccc55eeeeee557788775578877755700777558880705577bb7755909909558888885578877755227722500000000
0099990007777770079999700088880000cccc0007777770087887800888877000000770077777700b7bb7b00099990000888800088887700222222000000000
50000005577777755777777550000005500000055000000550000005500000055000000558888885500000055000000550000005500000055000000500000000
00000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
58bbbb855c7cc7c50008000000000000000000000000000000000000000000000000000050000005000000000000000000000000000000000000000000000000
0bb88bb0077cc7700808888000080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5b8888b55cccccc50088008000000000000000000000000000000000000000000000000050000005000000000000000000000000000000000000000000000000
0bb88bb00cccccc00800008008000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
58bbbb85577cc7750880088000800080000000000000000000000000000000000000000050000005000000000000000000000000000000000000000000000000
000000000c7cc7c00008880000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000005500000050000880000000000000000000000000000000000000000000000000050000005000000000000000000000000000000000000000000000000
0099990000aaaa000000000000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
094444900a9999a00000000001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
944999a9a99aaa7a0000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
949949a9a9aa9a7a0000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
949449a9a9a99a7a0000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
94999aa9a9aaa77a0000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09aaaa940a7777a40000000001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0099994000aaaa400000000000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117777777777777777777777777777777777777711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117115777777511115777777511115777777511711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117111777777111111777777111111777777111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117115777777511115eeeeee511115777777511711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117111777777111111e7ee7e111111777777111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117115777777511115eeeeee511115777777511711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117111777777111111777777111111777777111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117115777777511115111111511115777777511711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117111111111111111111111111111111111111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117111111111111111111111111111111111111711111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111711111111111111111116111111111111119171111111111111111111111cc1cc111111ccc11111c111ccc11
11111111111111111111111111111111111cc111711511111151111511161151111587887851171cc111158788785111111c1c1c1c11111c1111111c111c1c11
111111111111111111111111111111111111c1117111177711111111188781111111778877111711c111117788771111111c1c1c1c11111ccc11111ccc1c1c11
111111111111111111111111111111111111c1117115777117511115877888511115888888511711c111158888885111111c1c1c1c1111111c11111c1c1c1c11
111111111111111111111111111111111111c1117111771177111111878888111111888888111711c111118888881111111cc11c1c11111ccc11111ccc1ccc11
11111111111111111111111111111111111ccc11711571177751111588888851111577887751171ccc1115778877511111111111111111111111111111111111
11111111111111111111111111111111111111117111111177111111188881111111878878111711111111878878111111111111111111111111111111111111
11111111111111111111111111111111111111117115111111511115111111511115111111511711111115111111511111111111111111111111111111111111
11111111111111111111111111111111111111117111111111111111111111111191111111111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117111111111111111111111111911111111111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117111777777111111111611119111777777111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111ccc11711577777751111511611159111577777751171ccc1111111111111111111111111111111111111111111111
1111111111111111111111111111111111111c1171117777771111111c6cc91111117777771117111c1111111111111111111111111111111111111111111111
11111111111111111111111111111111111ccc117115777777511115c77ccc51111577777751171ccc1111111111111111111111111111111111111111111111
11111111111111111111111111111111111c11117111777777111111c7cccc11111177777711171c111111111111111111111111111111111111111111111111
11111111111111111111111111111111111ccc117115777777511115cccccc51111577777751171ccc1111111111111111111111111111111111111111111111
111111111111111111111111111111111111111171117777771111111cccc1111111777777111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117115777777511115911111511115777777511711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117111111111111119111111111111111111111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117111111111111991111111111111111111111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117111111111119111779977111111777777111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111ccc11711587887859111579997751111577777751171ccc1111111111111111111111111111111111111111111111
1111111111111111111111111111111111111c1171117788779111117799771111117777771117111c1111111111111111111111111111111111111111111111
111111111111111111111111111111111111cc117115888888511115779977511115777777511711cc1111111111111111111111111111111111111111111111
1111111111111111111111111111111111111c1171118888881111117799771111117777771117111c1111111111111111111111111111111111111111111111
11111111111111111111111111111111111ccc11711577887751111577997751111577777751171ccc1111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117111878878111111799997111111777777111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117115911111511115777777511115777777511711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117119111111111111111111111111111111111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117191111111111111111111111111111111111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117911111111111111111111111111777777111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117115777777511115111111511115777777511711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117111777777111111177711111111777777111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117115eeeeee511115777117511115777777511711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117111e7ee7e111111771177111111777777111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117115eeeeee511115711777511115777777511711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117111777777111111111177111111777777111711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117115111111511115111111511115777777511711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111117777777777777777777777777777777777777711111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1cccccccccccccccccccccccccccccccccccccccccccccc1111cccccccccccccccccccccccccccccccccccccccccccccc1111ccccccccccccccccccccccccc11
1c11111111111111111111111111111111111111111111c1111c11111111111111111111111111111111111111111111c1111c11111111111111111111111c11
1c11111111111111111111111111111111111111111111c1111c11111111111111111111111111111111111111111111c1111c11111111111111111111111c11
1c11111111111111111111111111111111111111111111c1111c11111111111111111111111111111111111111111111c1111c11111111111111111111111c11
1c1111cc1ccc1cc11ccc11cc111111ddd1dd11ddd11111c1111c111ccc1ccc1ccc1cc111111d111ddd11111111111111c1111c111ddd11111111111111111c11
1c111c111c1c1c1c11c11c11111111d1d11d11d1111111c1111c111c1c1c1c11c11c1c11111d111d1d11111111111111c1111c11111d11111111111111111c11
1c111c111cc11c1c11c11ccc111111ddd11d11ddd11111c1111c111ccc1ccc11c11c1c11111ddd1d1d11111111111111c1111c1111dd11111111111111111c11
1c111c111c1c1c1c11c1111c111111d1d11d1111d11111c1111c111c111c1c11c11c1c11111d1d1d1d11111111111111c1111c11111d11111111111111111c11
1c1111cc1c1c1ccc11c11cc1111111ddd1ddd1ddd11111c1111c111c111c1c1ccc1ccc11111ddd1ddd11111111111111c1111c111ddd11111111111111111c11
1c11111111111111111111111111111111111111111111c1111c11111111111111111111111111111111111111111111c1111c11111111111111111111111c11
1c11111111111111111111111111111111111111111111c1111c11111111111111111111111111111111111111111111c1111c11111111111111111111111c11
1c11111111111111111111111111111111111111111111c1111c11111111111111111111111111111111111111111111c1111c11111111111111111111111c11
1cccccccccccccccccccccccccccccccccccccccccccccc1111cccccccccccccccccccccccccccccccccccccccccccccc1111ccccccccccccccccccccccccc11
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1dddddddddddddddddddddddd1dddddddddddddddddddddddd1dddddddddddddddddddddddd17777777777777777777777771dddddddddddddddddddddddd111
1d1111111111111111111111d1d1111111111111111111111d1d1111111111111111111111d17111111111111111111111171d1111111111111111111111d111
1d1111111111111111111111d1d1111111111111111111111d1d1111111111111111111111d17111111111111111111111171d1111111111111111111111d111
1d1111111111111111111111d1d1111111111111111111111d1d1111111111111111111111d17111111111111111111111171d1111111111111111111111d111
1d1111cc11cc1c111c111111d1d1111111111111111111111d1d1111cc1ccc1ccc1cc11111d17111ccc1ccc1c1c1111111171d1111111111111111111111d111
1d111c111c1c1c111c111111d1d1111111111111111111111d1d111c111c1c11c11c1c1111d17111ccc1c1c1c1c1111111171d1111c111c1111111111111d111
1d111c111c1c1c111c111111d1d1111111111111111111111d1d111ccc1ccc11c11c1c1111d17111c1c1ccc11c11111111171d111ccc1ccc111111111111d111
1d111c111c1c1c111c111111d1d1111111111111111111111d1d11111c1c1111c11c1c1111d17111c1c1c1c1c1c1111111171d1111c111c1111111111111d111
1d1111cc1cc11ccc1ccc1111d1d1111111111111111111111d1d111cc11c111ccc1c1c1111d17111c1c1c1c1c1c1111111171d1111111111111111111111d111
1d1111111111111111111111d1d1111111111111111111111d1d1111111111111111111111d17111111111111111111111171d1111111111111111111111d111
1d1111111111111111111111d1d1111111111111111111111d1d1111111111111111111111d17111111111111111111111171d1111111111111111111111d111
1d1111111111111111111111d1d1111111111111111111111d1d1111111111111111111111d17111111111111111111111171d1111111111111111111111d111
1dddddddddddddddddddddddd1dddddddddddddddddddddddd1dddddddddddddddddddddddd17777777777777777777777771dddddddddddddddddddddddd111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

__sfx__
0004000027350293502a3502f35033350363503a3500030000300113000d300073000230017300123000e300093000530002300263001b3001030004300003000030000300003000030000300003000030000300
0003000000000200501d0501a050170501505013050120500f0500e0500c0500b0500a0500a0500a0500a0500a0500c0000000010000150001800000000000000000000000000000000000000000000000000000
00090000367503575033750317502e7502a750217501a75015750117500e7500b7500975007750057500375001750007500075000700007000070000700097000970009700097000070000700007000070000700
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

