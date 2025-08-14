pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
        --
        --
        --  todo list
        --  add tall benches
        --  add water ditches to jump over
        --  add chasing dog that runs mid speed
        --  add fire hydrant
        --  make map way longer
        --  add bonus poin coins
        --  add nose grind
        --  add chris air
        --  add board slide... 
        --  add arrow to add gravity
        --  add killer obstacles that have to be jumped over
        --  add spine -- this on hard to do lis
        --  add background buidlings
        --  **done****add animatior to skating sakter
        --  make skater fall into ditch
        --  add run timer
        --  award points
        --      10 points for jumping cones
        --      10 points for jumping on bench
        --      20 additional points for landing manual
        --      20 additional points for landing nose grind
        --      40 poins for jumping ramp
        --      20 points for jumping dog
        --      


        function _init()

            debug_mode = false

            controller = {
                right = 1,
                left = 0,
                down = 3,
                up = 2,
                btn1 = 4,
                btn2 = 5
            }

            colors = {
                black = 0, 
                dark_blue = 1, 
                dark_purple = 2, 
                dark_green = 3, 
                brown = 4,
                dark_gray = 5, 
                light_gray = 6, 
                white = 7, 
                red = 8, 
                orange = 9, 
                yellow = 10,
                green =  11,
                blue = 12,
                indigo = 13,
                pink = 14,
                peach = 15,
            }

            game_states = {
                playing = 1,
                tutorial = 2,
                game_over = 3
            }

            game_state_playing = {
                draw = draw_playing,
                update = update_playing,
                init = init_playing,
                finish = finish_playing,
                next_state = game_state_game_over,
                game_state = game_states.playing
            }

            game_state_tutorial = {
                draw = draw_tutorial,
                update = update_tutorial,
                init = init_tutorial,
                finish = finish_tutorial,
                next_state = game_state_playing,
                game_state = game_states.tutorial
            }

            game_state_game_over = {
                draw = draw_game_over,
                update = update_game_over,
                init = init_game_over,
                finish = finish_game_over,
                next_state = game_state_tutorial,
                game_state = game_states.game_over
            }

            current_game_state = game_state_game_over
            current_game_state.init()
        end 

        -------------------------------------
        --
        --  game state: playing functions
        --
        -------------------------------------

        function init_playing()

            score = 0
            trick_streak = {}
            varial_timer = 0
            kick_flip_timer = 0
            nose_grab_timer = 0
            air_walk_timer = 0
            ground_floor = 96;
            skater_map_tile = 1
            skater_map_tile_pre = 1            
            jump_puffs = {}
            clouds = {}
            points = {}
            prev_btn_x = false
            map_length = 0
            playing_timer = 0
            
            player_sprites = {
                skating_a = 4,
                skating_b = 6,
                crouched = 8,
                nose_grind = 10,
                wheelie = 38,
                stale = 34,
                air_walk = 40,
                nose_grab = 42,
                kick_flip_1 = 44,
                kick_flip_2 = 46,
                varial_1 = 12,
                varial_2 = 14
            }

            player = {
                spr = player_sprites.skating_a,
                x = 20,
                y = 20,
                gravity = 0.2,
                speed_x = .75,
                jumped = false,
                friction = 0.03,
                jumped_timer = 0     
            }

            skate_map = {
                layer_0 = {136,136,136,128,132,136,136,136,132,136,128,136,136,136,136,132,136,136,136,136,136,136,128,136,128,136,136,128,136,128,132,132,132},
                layer_1 = { 74, 74, 74, 74, 74, 72, 74, 74, 74, 74, 74, 74, 74, 96, 98,100, 74, 74, 74, 74, 74, 74, 74, 74, 74, 74,102, 74, 74, 74, 74, 74},  
                layer_2 =  {64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64}         
            }

            map_length = #(skate_map.layer_1)*16;
            
            set_map_bearing = function()
                map_tile = flr(player.x / 16)
                map_tile_offset = player.x % 16
                map_tile_length = #(skate_map.layer_1)
            end 

            set_map_bearing()
            add_clouds()
        end

        function update_playing()
            function get_normalized_tile(mt)
                --todo write funciton to hande this
                if mt < 1 then 
                    return mt + map_tile_length
                end 

                if mt > map_tile_length then 
                    return mt - map_tile_length
                end

                return mt
            end 

            playing_timer += 1
            skater_map_tile = get_normalized_tile(map_tile + 3)
            skater_map_tile_pre = get_normalized_tile( map_tile + 4)

            player.x += player.speed_x
            if player.x > map_length then 
                player.x = 0
            end 
            set_map_bearing()
            determine_ground_floor()

            print("gouond floor after"..ground_floor, 20, 80)

            if not player.jumped and btn(controller.right) then 
                player.speed_x += .5
                if player.speed_x > 5 then  
                player.speed_x = 5     
                end
            end 

            update_air_walk() 
            update_nose_grab()
            update_kick_flip()
            update_varial()
            update_points()

            --player jump
            if not player.jumped and prev_btn_x and not btn(controller.down) then 
                player.gravity = -3
                prev_btn_x = false
                player.jumped = true
                add_jump_puffs()
                sfx(3)
                player.jumped_timer = 85
                if skate_map.layer_1[skater_map_tile] == 102 then 
                    player.gravity -= 2
                end 
                player.manual_timer = 0
            elseif btn(controller.down) then 
                prev_btn_x = true 
                
                --do not crouch while in manual
                --ollie from manual is ok
                if player.manual_timer <= 0 then
                    player.spr = player_sprites.crouched
                end 
            elseif not player.jumped and skate_map.layer_1[skater_map_tile] == 102 then
                --player has cross paths with the ramp e.g. tile 102
                --so they automatically get to jump
                player.gravity = -3
                prev_btn_x = false
                player.jumped = true
                add_jump_puffs()
                sfx(3)
                player.jumped_timer = 85
            else 
                prev_btn_x = false
            end 

            if not(player.jumped) and btn(controller.up) then 
                player.manual_timer = 45
            end 

            if player.manual_timer == nil or player.manual_timer < 0 then 
                player.manual_timer = 0
            end 

            if player.manual_timer > 0 then 
                player.manual_timer -= 1 
            end 

            update_jump_puffs()

            player.gravity += .3
            
            --apply fricition when rolling
            if not player.jumped then
                player.speed_x -= player.friction
            end 

            if player.speed_x < 1 then 
                player.speed_x = 1
            end 

            player.jumped_timer -= 1

            if player.jumped_timer < 0 then 
                player.jumped_timer = 0
            end

            if air_walk_timer > 0 then 
                player.spr = player_sprites.air_walk 
            elseif nose_grab_timer > 0 then 
                player.spr = player_sprites.nose_grab   
            elseif kick_flip_timer > 0 then 
                local which_sprite = flr(kick_flip_timer/3)%2
                player.spr = player_sprites.kick_flip_1 + (2*which_sprite)  
            elseif varial_timer > 0 then 
                local which_sprite = flr(varial_timer/3)%2
                player.spr = player_sprites.varial_1 + (2*which_sprite)  
            elseif player.jumped and player.jumped_timer > 77 then
                player.spr = player_sprites.wheelie
            elseif player.jumped and player.jumped_timer > 60 then 
                player.spr = player_sprites.stale
            elseif player.jumped and player.jumped_timer > 50 then 
                player.spr = player_sprites.skating_a
            elseif player.manual_timer > 0 then 
                player.spr = player_sprites.wheelie
            elseif not player.jumped and prev_btn_x then 
                player.spr = player_sprites.crouched
            else 
                player.spr = player_sprites.skating_a
            end 

            player.y += player.gravity
            if player.y > ground_floor then 
                player.y = ground_floor
                player.jumped = false
                player.jumped_timer = 0
                if trick_streak_count() > 1 then
                    add(points, {
                        val = trick_streak_count() * 250,
                        x = 40,
                        y = player.y - 10,
                        speed_x = -2,
                        speed_y = -2,
                        life = 45 
                    })
                    sfx(4)
                end
                trick_streak = {
                    air_walk = false,
                    nose_grab = false,
                    kick_flip = false,
                    varial = false   
                }
            end

            update_clouds()

            set_skating_sprite()
        end

        function trick_streak_count()
            local c = 0
             
            if trick_streak.air_walk then c += 1 end
            if trick_streak.nose_grab then c += 1 end
            if trick_streak.kick_flip then c += 1 end
            if trick_streak.varial then c += 1 end

            return c
        end 

        previous_points_x = 0
        function add_points(v)

            --way to draw points on different area horizontally
            previous_points_x += 10
            
            if previous_points_x > 50 then 
                previous_points_x = 0
            end 

            score += v
            add(points,
                {
                    val = v,
                    x = 30+previous_points_x,
                    y = player.y-5,
                    speed_y = -1,
                    speed_x = 0,--flr(rnd(5))-2.5,
                    life = 30
                }
            )
        end 

        function update_points()
            for p in all(points) do 
               p.life -= 1 
               p.y += p.speed_y 
               p.x += p.speed_x
               
               if p.life < 1 then 
                 del(points, p)
               end 
            end
        end 

        function draw_points() 
            print("score ", 2, 2, colors.red)
            print(""..score, 2, 12, colors.white)

            for p in all(points) do     
               print(" "..p.val, p.x, p.y, colors.white)
            end        
        end 

        function update_kick_flip() 

            kick_flip_timer -= 1
            if kick_flip_timer < 0 then 
                kick_flip_timer = 0
            end

            --ignore kickflip if other btns are pressed
            if btn(controller.btn1) or btn(controller.btn2) then
                return
            end 

            if kick_flip_timer == 0 and 
            btn(controller.down) and 
            player.jumped then 
                kick_flip_timer = 10
                
                --tricks only count when on air higher than 80
                if player.y < 80 then
                    trick_streak.kick_flip = true
                    sfx(3)
                    add_points(100)
                else 
                    add_points(10)
                    sfx(5)
                end 
                 
            end
        end

        function update_varial() 
            varial_timer -= 1
            if varial_timer < 0 then 
                varial_timer = 0
            end
            if varial_timer == 0 and 
            btn(controller.right) and 
            player.jumped then 
                varial_timer = 10
                    
                if player.y < 80 then
                    trick_streak.varial = true
                    sfx(3)
                    add_points(100)
                else 
                    add_points(10)
                    sfx(5)
                end 
            end
        end

        function update_air_walk() 
            air_walk_timer -= 1
            if air_walk_timer < 0 then 
                air_walk_timer = 0
            end
            if air_walk_timer == 0 and 
            btn(controller.down) and 
            btn(controller.btn1) and 
            player.jumped then 
                air_walk_timer = 10
                if player.y < 80 then    
                    trick_streak.air_walk = true
                    add_points(100)
                    sfx(3)
                else 
                    add_points(20)
                    sfx(5)
                end
            end
        end 

        function update_nose_grab() 
            nose_grab_timer -= 1
            if nose_grab_timer < 0 then 
                nose_grab_timer = 0
            end
            if nose_grab_timer == 0 and 
            btn(controller.down) and 
            btn(controller.btn2) and 
            player.jumped then 
                nose_grab_timer = 10
                
                if player.y < 80 then
                    trick_streak.nose_grab = true
                    add_points(20)
                    sfx(3)
                else 
                    add_points(20)
                    sfx(5)
                end 
            end
        end 

        function set_skating_sprite()
            if player.spr == 4 or player.spr == 6 then
                local sprite_to_use = flr(playing_timer/5)%2
        
                if sprite_to_use == 0 then 
                    player.spr = 4
                else 
                    player.spr = 6
                end 
            end 
        end 

        function draw_playing()
            cls(colors.blue)
            draw_clouds()
            if debug_mode then print(map_length) end
            
            if debug_mode then print("tile_count"..map_tile_length) end

            if map_tile <= 0 then
                map_tile += map_tile_length
            end 

            local current_tile = map_tile
            local current_x = -map_tile_offset
            local current_y = 96
            local end_tile = map_tile + 9

            if debug_mode then
                print("map_tile"..map_tile)
                print("end_tile"..end_tile)
            end

            for i = map_tile, end_tile do 
                spr(skate_map.layer_0[current_tile], current_x, current_y-16, 4, 4)
                spr(skate_map.layer_1[current_tile], current_x, current_y, 2, 2)
                spr(skate_map.layer_2[current_tile], current_x, current_y+16, 2, 2)
                
                current_x += 16
                current_tile += 1
                if current_tile > map_tile_length then 
                    current_tile -= map_tile_length
                end 

                if current_x > 128 then
                    break;
                    --don't draw tiles outside of the map
                end  
            end 

            if debug_mode then
                print("player.x "..player.x)
                print("map tile "..map_tile)
                print("map tile offset "..map_tile_offset)
                print("map length "..map_length)
                print("ground floor "..ground_floor, 20, 60)
                print("map tile len: "..map_tile_length, 20, 70)
                print("map tile     "..map_tile, 20, 80)
                print("skater map tile "..skater_map_tile, 20, 90)    
            end 

            spr(player.spr, 50, player.y, 2, 2)
            draw_jump_puffs()
            draw_points()
        end

        function finish_playing()
        end 

        function add_clouds()
            add(clouds, {
                x = 40,
                y = 40,
                speed = -0.15,
                spr =  106
            })
            
            add(clouds, {
                x = 160,
                y = 20,
                speed = -0.15,
                spr = 106
            })
        end

        function update_clouds()
            for c in all(clouds) do
                c.x += c.speed
                if c.x < -64 then 
                    c.x = 192
                end 
            end
        end 

        function draw_clouds()
            for c in all(clouds) do 
                spr(c.spr, c.x, c.y, 4, 2)
            end 
        end 

        --determines place where skater can land
        --todo if we have higher objects we may need to
        --orgranize in collection and check from highest 
        --location to lowest
        -- see platforms below where x? is the player
        -- and ---- is the platforms
        -- only players that are above the platform
        -- can land on that platform
        -- x1 can only land on the ground
        -- x2 can land on platform below it but so can x7
        -- since it seems it collided
        -- x3 and x8 can lan on platform but x5 has to land on
        -- the ground.
        -- this is the idea but currently the game only handles
        -- one level of platforms plus the ground
        --                   x3
        --  x1   x2          -----x8--
        --       ---x7--       x5 
        --       x6
        function determine_ground_floor()
            ground_floor = 96;
            if 
                player.y < 81
                and 
                (( 
                    skate_map.layer_0[skater_map_tile] >= 132
                    and 
                    skate_map.layer_0[skater_map_tile] <= 134 
                )
                or
                ( 
                    skate_map.layer_0[skater_map_tile_pre] >= 132
                    and 
                    skate_map.layer_0[skater_map_tile_pre] <= 134 
                ))
            then
                ground_floor = 70
            elseif 
                player.y < 91
                and 
                (( 
                    skate_map.layer_1[skater_map_tile] >= 96
                    and 
                    skate_map.layer_1[skater_map_tile] <= 100 
                )
                or
                ( 
                    skate_map.layer_1[skater_map_tile_pre] >= 96
                    and 
                    skate_map.layer_1[skater_map_tile_pre] <= 100 
                ))
            then 
                ground_floor = 86
            end
        end

        function add_jump_puffs()
            for i=1,4 do 
                add(jump_puffs, {

                life = 45,
                x = 50 + flr(rnd(12))-2,
                y = 112,
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

        ---------------------------------------
        --
        --  game state: tutorial functions
        --
        ---------------------------------------
        function update_tutorial()
            display_min_timer -= 1
            if display_min_timer < 0 then 
                display_min_timer = 0
            end 
            if display_min_timer == 0 
            and
            ( btn(controller.btn1) 
                or 
                btn(controller.btn2)
            )
            then 
                current_game_state.finish()
                current_game_state = current_game_state.next_state
                current_game_state.init()
            end 
        end 

        function draw_tutorial()
            cls()
            spr(118, 40, 110, 2, 2)
            spr(34, 60, 20, 2, 2)
            print("release down arrow to olie.", 20, 40, colors.white)
            print("down arrow to nose manual.", 20, 50, colors.white)
            print("back arrow to manual.", 20, 60, colors.white)
            print("combine arrows and buttons", 20, 70, colors.white)
            print(" mid-air for secret moves.", 20, 80, colors.white)
            
            print("press x button to start", 20, 90, colors.red)
        end 

        function init_tutorial()
        display_min_timer = 30
        end 

        function finish_tutorial()
        display_min_timer = 0
        end 

        -------------------------------
        --
        --  game over state funcitons
        --
        -------------------------------
        function init_game_over()
        end 
        function update_game_over()
            if btn(controller.btn1) or btn(controller.btn2)  then 
                current_game_state.finish()
                current_game_state = current_game_state.next_state
                current_game_state.init()
            end 
        end 
        function draw_game_over()
            cls()
            spr(118, 30, 70, 2, 2)
            spr(34, 60, 30, 2, 2)
            print("game over", 40, 50, colors.white)
            print("press x to start", 40, 60, colors.red)
        end 


        function finish_game_over()
        end 


        function _update()
            current_game_state.update()
        end 

        function _draw()
            current_game_state.draw()
        end 

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000000050000000
00000000000000000000055000000000000000000005000000000000050000000000000000000000000000000005000000000055500000000000005550000000
00000000000000000000055500000000000000000555000000000000055000000000000000050000000000000555000000555555500000000055555550000000
00000000000000000005555555555000000005555555000000000555555000000000000005550000000005555555000055555555000000005555555500000000
0000000000000000000555ff5555500000055555555000000055555555500000000005555555000000055555555000005555ffff000000005555ffff00000000
0000000000000000000055fffff550000005555ffff000000005555ffff0000000055555555000000005555ffff00000555fff4fff000000555fff4fff000000
000000000000000000005ff4f4ff5000000555fff4ff0000000555fff4ff00000005555ffff00000000555fff4ff000005ffffff0000000005ffffff00000000
0000000000000000000005fffff5000000005ffffff0000000005ffffff00000000555fff4ff000000005fffff000000fff3333000000000fff3333000000000
0000000000000000000000033300000000000033300000000000003330000000000f5ffffff00000000fff33ff00000000033330000000700003333000000000
000000000000000000000fff3fff00000000ff33fff000000000ff33fff000000000ff333f000000000000330000000000088888090007700008888809000700
00000000000000000000000888000000000000888000000000000088800000000000088880000000007988880000000000088889900077000008888990007700
00000000000000000000555588000000000000808000000000000080800000000000088080000000000799880000000000088009000770700008800900077000
00000000000000000000555509990000000709909900700000070990990070000700990999070000007077999000000000999000007700000099900000770000
00000000000000000000000000000000000077777777000000007777777700000077777777700000000007777000000000000000077000000000000000700000
00000000000000000000000000000000000007000070000000000600006000000007000007000000000000070000000000000000770700000000000000000000
00000000000000000000000000050000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000005550000000000000000000000000000500000000000000050000000000000005000000000000000500000000000000050000000
00000000000000000000055555550000000000000000000000000055500000000000005550000000000000555000000000000055500000000000005550000000
00000000000000000005555555500000000050000000000000555555500000000055555550000000005555555000000000555555500000000055555550000000
00000000000000000005555ffff0ff0000005500000000005555555500f000005555555500000000555555550000000055555555000000005555555500000000
00000000000000000f0555fff4fff00000005550000000005555ffff0f0000005555ffff007070005555ffff0f0000005555ffff000000005555ffff00000000
00000000000000000fffffff8fff00700055555555550000555fff4ff0000000555fff4ffff70000555fff4ff7700000555fff4fff000000555fff4fff000000
000000000000000000fff8ff8ff0777000555ff55555000005ffffff0000000005ffffff0007000005ffffff0700000005ffffff0000000005ffffff00000000
0000000000000000000038f9f999700000055fffff550000fff3333000000000fff3333000007070fff3333007000000fff3333000000000fff3333000000000
000000000000000000003399777707000005ff4f4ff5000000033330007000000003333000000700000333300700000000033330000000700003333000707700
0000000000000000000000777000000000005fffff50000000088888097000000008888809000070000888800700000000088888090007700008888809077000
00000000000000000000000007000000000000333000000000008889970000000008888990000070000888807700000000088889900077000008888990077000
000000000000000000000000000000000000fff3fff0000000000999707000000008800900000000000088897060000000088009000770700008800970770000
00000000000000000000000000000000000000888000000000009977000000000099900000000000000008870000000000999000007700000099900007700000
00000000000000000000000000000000000099885555000000077700000000000000000000000000000000900000000000000000077000000000000777000000
00000000000000000000000000000000000999905555000000000170000000000000000000000000000000000000000000000000770700000000000700000000
6666666666666666666666666600000000000000000000000066666666666666000000000000000000000000000000000000000000000000cccccccccccccccc
6666666666666666666666666660000000000000000000000066666666666666000000000000000000000000000000000000000000000000cccccccccccccccc
4646446644646646464644664466600000000000000000000666446644666666000000000000000000000000000000000000000000000000cccccccccccccccc
4444454445444444444445444566660000000000000000000666454445444444000000000000000000000000000000000000000000000000cccccccccccccccc
5444444444444444544444444446660000000000000000000664444444444444000000000000000000000000000000000000000000000000cccccccccccccccc
4444444444444444444444444444660000000000000000000666444444444444000000001000000000000000000000000000000000000000cccccccccccccccc
4444444444444454444444444446660000000000000000000666444444444444000000018100000000000000000000000000000000000000cccccccccccccccc
4454444454444444445444445446666666666666666666666664444454444444000000188810000000000000000000000000000000000000cccccccccccccccc
4444444444444444444444444444664666666666666666666666444444444444000000166610000000000000000000000000000000000000cccccccccccccccc
4444544444444444444454444444444446646646644664666666544444444444000000188810000000000000000000000000000000000000cccccccccccccccc
4444444444444444444444444444444444444444444444446664444444444444000001888881000000000000000000000000000000000000cccccccccccccccc
4444444454444444444444445444444444444444544444444444444454444444000001666661000000000000000000000000000000000000cccccccccccccccc
4444444444444445444444444444444544444444444444454444444444444445000018888888100000000000000000000000000000000000cccccccccccccccc
4454444444444444445444444444444444544444444444444454444444444444000018888888100000000000000000000000000000000000cccccccccccccccc
4444444444444444444444444444444444444444444444444444444444444444000166666666610000000000000000000000000000000000cccccccccccccccc
4444444444444444444444444444444444444444444444444444444444444444001888888888881000000000000000000000000000000000cccccccccccccccc
00000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111711100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000111777777711000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000001777777777777111000111110000000000000000000
01111111111111111111111111111111111111111111111100000000000000000000000000000000000017777777777777777111777771000000000000000000
06666666666666666666666666666666666666666666666600000000000000000000000000000000000177777777777777777777777110000000000000000000
07777777777777777777777777777777777777777777777700000000000000000000000000000000001777777777777777777777771100000000000000000000
06666666666666666666666666666666666666666666666600000000000000000000000000000000001777777777777777777777771000000000000000000000
05555555555555555555555555555555555555555555555500000000000000110000000000000000017777ccccc7777ccc777777710000000000000000000000
0111551111111111111111111111111111111111111561110000000000001141000000000000000000177777cccccccc77777777100000000000000000000000
000156100000000000000000000000000000000000156100000000000111444100000000000000000011177777ccc77777777771000000000000000000000000
00016610000000000000000000000000000000000016610000001111144444410000000000000000000011777777777777777100000000000000000000000000
00016610000000000000000000000000000000000016610000014444444444410000000000000000000001117777777771111000000000000000000000000000
00016610000000000000000000000000000000000016610011111111111111110000000000000000000000011111111110000000000000000000000000000000
00000000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000011bbbbbb1110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000011bbbbbbbbb11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011bbbbbbbbbbb1100000000000000000000000000000000000000000000000000000000000000000000000000000000000110000000000000000000
0000000011bbbbbbbbbbbbb110000000111111111111111111111111111111110000000000000000000000000000000000000000011710000000000000000000
000000011bbbbbbbbbbbbbbb11000000666666666666666666666666666666660000000000000000000000000000000000000001177711000000000000000000
00000001bbbbbbbbbbbbbbbbb1000000666666666666666666666666666666660000000000000000000000000000000000000017777771110000000000000000
00000011bbbbbbbbbbbbbbbbb1100000777777777777777777777777777777770000000000000000000000000000000000000177777777710000000000000000
00000015bbbbbbbbbbbbbbbbbb10000055555555555555555555555555555555000000000000000000000000000000000000177cc77771100000000000000000
00000015bbbbbbbbbbbbbbbbbb1000001111115555111111111111155551111100000000000000000000000000000000001177cc777711000000000000000000
00000115bbbbbbbbbbbbbbbbbb110000000001557610000000000015576100000000000000000000000000000000000001777777771100000000000000000000
00000155bbb4bbbbbbbbbbbbbbb10000000001567610000000000015676100000000000000000000000000000000000011111177111000000000000000000000
00000155bbbbbbbbbbbbbbbbbbb10000000001567610000000000015676100000000000000000000000000000000000000000111100000000000000000000000
0000015bbbbbbbbbbbbbbbbbbbb10000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
0000015bbb4b4bbbbbbbbbbbbbb10000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
00000155bbbbbbbbbbbbbbbbbbb10000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
0000015bbbbbbbbbbbbbbbbbbbb10000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
0000015b5bbbbbbbbbbbbbbbbbb10000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
000001155bbbb4bbbbbbbbbbbb110000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
00000015bbbbbbbbbbbbbbbbbb100000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
00000015b5bbbbbbbbbbbbbbb1100000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
000000115b5b4bbbbbbbbbbbb1000000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
000000015bb5b4bbbbbbbbbb11000000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
0000000115bbbbbbbbbbbbbb10000000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
000000001155bbbbbbbbbbb110000000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
0000000001155b4bbbfbbb1000000000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
000000000011114444ff111000000000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
000000000000014fffff100000000000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
0000000000000144ff4f100000000000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
000000000000014fffff100000000000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
0000000000000144ff4f100000000000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
000000000000014fffff100000000000000001567610000000000015676100000000000000000000000000000000000000000000000000000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccc88cc88cc88c888c888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc8ccc8ccc8c8c8c8c8ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc888c8ccc8c8c88cc88cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccc8c8ccc8c8c8c8c8ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc88ccc88c88cc8c8c888ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc777c77cc777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc7c7cc7cc7c7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc777cc7cc7c7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc7c7cc7cc7c7ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc777c777c777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
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
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1117111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccc111777777711cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccc1777777777777111ccc11111ccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccc17777777777777777111777771cccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccc17777777777777777777777711ccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc17777777777777777777777711cccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc1777777777777777777777771ccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc17777ccccc7777ccc77777771cccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc177777cccccccc777777771ccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc11177777ccc77777777771cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccc117777777777777771cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccc1117777777771111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccc1111111111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
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
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccc11111111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccc11bbbbbb111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc11bbbbbbbbb11cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccc11bbbbbbbbbbb11ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc11bbbbbbbbbbbbb11cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc11bbbbbbb66666666666666666666666666666666cccccccccccccccccccccccccccccccc66666666666666666666666
cccccccccccccccccccccccccccccccc1bbbbbbbb66666666666666666666666666666666cccccccccccccccccccccccccccccccc66666666666666666666666
ccccccccccccccccccccccccccccccc11bbbbbbbb77777777777777777777777777777777cccccccccccccccccccccccccccccccc77777777777777777777777
ccccccccccccccccccccccccccccccc15bbbbbbbb55555555555555555555555555555555cccccccccccccccccccccccccccccccc55555555555555555555555
ccccccccccccccccccccccccccccccc15bbbbbbbbbbbbbb55551cccccccccccc5555ccccccccccccccccccccccccccccccccccccccccccc5555ccccccccccccc
cccccccccccccccccccccccccccccc115bbbbbbbbbbbbbb557611ccccccccccc5576ccccccccccccccccccccccccccccccccccccccccccc5576ccccccccccccc
cccccccccccccccccccccccccccccc155bbb4bbbbbbbbbb5676b1ccccccccccc5676ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
cccccccccccccccccccccccccccccc155bbbbbbbbbbbbbb5676b1ccccccccccc5676ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
cccccccccccccccccccccccccccccc15bbbbbbbbbbbbbbb5676b1ccccccccccc5676ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
cccccccccccccccccccccccccccccc15bbb4b4bbbbbbbbb5676b1ccccccccccc5676ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
cccccccccccccccccccccccccccccc155bbbbbbbbbbbbbb5676b1ccccccccccc5676ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
cccccccccccccccccccccccccccccc15bbbbbbbbbbbbbbb5676b1ccccccccccc5676ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
cccccccccccccccccccccccccccccc15b5bbbbbbbbbbbbb5676b1ccccccccccc5676ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
cccccccccccccccccccccccccccccc1155bbbb4bbbbbbbb567611cccccccc5cc5676ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
ccccccccccccccccccccccccccccccc15bbbbbbbbbbbbbb56761ccccccc555cc5676ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
ccccccccccccccccccccccccccccccc15b5bbbbbbbbbbbb56761ccc5555555cc5676ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
ccccccccccccccccccccccccccccccc115b5b4bbbbbbbbb5676cc55555555ccc5676ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
cccccccccccccccccccccccccccccccc15bb5b4bbbbbbbb5676cc5555ffffccc5876ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
cccccccccccccccccccccccccccccccc115bbbbbbbbbbbb5676cc555fff4ffcc8886ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
ccccccccccccccccccccccccccccccccc1155bbbbbbbbbb5676ccc5ffffffccc7776ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
cccccccccccccccccccccccccccccccccc1155b4bbbfbbb5676ccccc333ccccc8886ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
ccccccccccccccccccccccccccccccccccc11114444ff115676cccff33fffcc88888ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
cccccccccccccccccccccccccccccccccccccc14fffff1c5676ccccc888cccc77777ccccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
cccccccccccccccccccccccccccccccccccccc144ff4f1c5676ccccc8c8ccc8888888cccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
cccccccccccccccccccccccccccccccccccccc14fffff1c5676cc7c99c99cc7888888cccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
cccccccccccccccccccccccccccccccccccccc144ff4f1c5676ccc7777777777777777ccccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
cccccccccccccccccccccccccccccccccccccc14fffff1c5676cccc7cccc78888888888cccccccccccccccccccccccccccccccccccccccc5676ccccccccccccc
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
64464664646464466446466464646446644646646464644664464664646464466446466464646446644646646464644664464664646464466446466464646446
44544444444444544454444444444454445444444444445444544444444444544454444444444454445444444444445444544444444444544454444444444454
44444444454444444444444445444444444444444544444444444444454444444444444445444444444444444544444444444444454444444444444445444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444445444444444444444544444444444444454444444444444445444444444444444544444444444444454444444444444445444444444444444544444444
45444444444544444544444444454444454444444445444445444444444544444544444444454444454444444445444445444444444544444544444444454444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444445444444444444444544444444444444454444444444444445444444444444444544444444444444454444444444444445444444444444444544
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
45444444444444444544444444444444454444444444444445444444444444444544444444444444454444444444444445444444444444444544444444444444
44444444544444444444444454444444444444445444444444444444544444444444444454444444444444445444444444444444544444444444444454444444
44444444444544444444444444454444444444444445444444444444444544444444444444454444444444444445444444444444444544444444444444454444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444

__sfx__
0004000027350293502a3502f35033350363503a3500030000300113000d300073000230017300123000e300093000530002300263001b3001030004300003000030000300003000030000300003000030000300
000b000000000200502205025050290503105009000090000a0000a0000d0000e0003f000390003b00035000390003a0000000010000150001800000000000000000000000000000000000000000000000000000
00090000367503575033750317502e7502a750217501a75015750117500e7500b7500975007750057500375001750007500075000700007000070000700097000970009700097000070000700007000070000700
00060000170501c0502305001000260000000024000000002500000000000001e0001e0001d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000900001205016050190501c05021050260502a0502e050360503f05001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000160500005019050010501d05019000140000f0000a000040002f0002000013000140001d0002b0001f0001500018000260002a000310003e000000000000000000000000000000000000000000000000
000500003a050340502f0502d0502d050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e000431120301103212032110001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000e1000f1000f1000f1001010010100101001110011100
001000001f05021050230502505027050290502d05030050310503b0503f050310503305036050380503a0503b0503e0503f0503205035050370503b0503d0503f0503f050360503a0503e0503f050350503a050
000900001405016050190501d05020050250502a0502e050380503d05039050320502c05027050220501e05019050180501605013050120500f05000000000000000000000000000000000000000000000000000
0003000002750047500575006750097500b7500e75011750157501b7501f750247502775000700067000270000700007000070000700007000070000700007000070000700007000070000700007000070000700
000c000800f001c35032350163502a3501e350373502035016300105000f5000d5000950006500055000350001500015000050000500005000050000500005000050000500005000050000500005000050000500
0011010f000002f3502b350293502f3502b35029350313502b350273502b35025350273502b3502c3503730000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b00000732006320063200633008330093300c3300d35012350163501b350223502a3503d350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01424344

