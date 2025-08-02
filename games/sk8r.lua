function _init()

    controller = {
        right = 1,
        left = 0,
        down = 3,
        up = 2,
        btn1 = 4,
        btn2 = 5
    }

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

function update_playing()
    player.x += player.speed_x
    if player.x > map_length then 
        player.x = 0
    end 
    set_map_bearing()
end

function draw_playing()
    cls()
    print(map_length)
    local map_tile_length = flr(map_length/16)
    print("tile_count"..map_tile_length)
    local current_tile = map_tile
    local current_x = -map_tile_offset
    local current_y = 96
    local end_tile = map_tile + 9
    print("map_tile"..map_tile)
    print("end_tile"..end_tile)

    for i = map_tile, end_tile do 
        spr(skate_map.layer_1[current_tile], current_x, current_y, 2, 2)
        spr(skate_map.layer_2[current_tile], current_x, current_y+16, 2, 2)
        
        current_x += 16
        current_tile += 1
        if current_tile > map_tile_length then 
            current_tile = 1
        end 

        if current_x > 128 then
            current_x -= 128
        end  
    end 
    print("player.x "..player.x)
    print("map tile "..map_tile)
    print("map tile offset "..map_tile_offset)
    print("map length "..map_length)

    spr(player.spr, 50, 96, 2, 2)
end

function init_playing()
    map_length = 0
    player_sprites = {
        skating_a = 4,
        skating_b = 6,
        crouched = 8,
        nose_grind = 10,
        wheelie = 32,
        stale = 34 
    }

    player = {
        spr = player_sprites.skating_a,
        x = 20,
        y = 20,
        gravity = .2,
        speed_x = .75       
    }
    skate_map = {
        layer_1 = {74,74,74,74,74,72,74,74,74,74,74,74,74,96,98,100,74,74,74,74,74,74,74,74,74,74,102,74,74,74,74,74},
        layer_2 = {64,64,64,64,64,64,64,64,64,64,64,64,64,64,64, 64,64,64,64,64,64,64,64,64,64,64, 64,64,64,64,64,64}         
    }
    map_length = #(skate_map.layer_1)*16;
    
    set_map_bearing = function()
        map_tile = flr(player.x / 16)
        map_tile_offset = player.x % 16
    end 

    set_map_bearing()

end 
function finish_playing()
end 

function update_tutorial()
    if btn(controller.btn1) or btn(controller.btn2)  then 
        current_game_state.finish()
        current_game_state = current_game_state.next_state
        current_game_state.init()
    end 
end 

function draw_tutorial()
    cls()
    print("hold down down arrow and let go to olie.", 20, 30, colors.white)
    print("after ollie ress down for nose manual or nose grind", 20, 40, colors.white)
    print("press x button to start")
end 

function init_tutorial()

end 

function finish_tutorial()

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
    print("game over", 40, 40, colors.white)
    print("press x to start", 40, 50, colors.white)
end 

function init_game_over()
end 
function finish_game_over()
end 


function _update()
    current_game_state.update()
end 

function _draw()
    current_game_state.draw()
end 
