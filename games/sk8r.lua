        --
        --
        --  TODO List
        --  Add tall benches
        --  Add water ditches to jump over
        --  Add chasing dog that runs mid speed
        --  Add fire hydrant
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
                layer_1 = {74,74,74,74,74,72,74,74,74,74,74,74,74,96,98,100,74,74,74,74,74,74,74,74,74,74,102,74,74,74,74,74},  
                layer_2 = {64,64,64,64,64,64,64,64,64,64,64,64,64,64,64, 64,64,64,64,64,64,64,64,64,64,64, 64,64,64,64,64,64}         
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
                --TODO write funciton to hande this
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
            end

            update_clouds()

            set_skating_sprite()
        end

        previous_points_x = 0
        function add_points(v)

            --way to draw points on different area horizontally
            previous_points_x += 10
            
            if previous_points_x > 50 then 
                previous_points_x = 0
            end 

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
            for p in all(points) do     
               print(" "..p.val, p.x, p.y, colors.white)
            end        
        end 

        function update_kick_flip() 
            kick_flip_timer -= 1
            if kick_flip_timer < 0 then 
                kick_flip_timer = 0
            end
            if kick_flip_timer == 0 and 
            btn(controller.down) and 
            player.jumped then 
                kick_flip_timer = 10
                add_points(10*flr(((128-player.y)/10)))
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
                add_points(10*flr(((128-player.y)/10)))
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
                add_points(20*flr(((128-player.y)/10)))
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
                add_points(10*flr(((128-player.y)/10)))
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

        --Determines place where skater can land
        --TODO if we have higher objects we may need to
        --orgranize in collection and check from highest 
        --location to lowest
        -- See platforms below where x? is the player
        -- and ---- is the platforms
        -- only players that are above the platform
        -- can land on that platform
        -- x1 can only land on the ground
        -- x2 can land on platform below it but so can x7
        -- since it seems it collided
        -- x3 and x8 can lan on platform but x5 has to land on
        -- the ground.
        -- This is the idea but currently the game only handles
        -- one level of platforms plus the ground
        --                   x3
        --  x1   x2          -----x8--
        --       ---x7--       x5 
        --       x6
        function determine_ground_floor()
            ground_floor = 96;
            if 
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
