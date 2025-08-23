-- asteroids demo
-- ship + bullets + asteroids

function _init()
  -- ship setup
  ship={
    x=64,y=64,vx=0,vy=0,
    a=0,turn=0.03,
    accel=0.06,drag=0.995,
    radius=6,cd=0
  }

  ship_model={
    { 7, 0},
    {-5, 5},
    {-2, 0},
    {-5,-5}
  }
  ship_lines={
    {1,2},{2,3},{3,4},{4,1},{1,3}
  }

  bullets={}
  max_bullets=6
  bullet_speed=2.5
  bullet_life=60
  fire_delay=8

  -- asteroids
  asteroids={}
  for i=1,4 do
    spawn_asteroid(rnd(128),rnd(128),2)
  end
end

function _update()
  -- rotate
  if btn(0) then ship.a-=ship.turn end
  if btn(1) then ship.a+=ship.turn end

  -- thrust
  if btn(2) then
    ship.vx+=cos(ship.a)*ship.accel
    ship.vy+=sin(ship.a)*ship.accel
    local spd=hypot(ship.vx,ship.vy)
    if spd>2.5 then
      local s=2.5/spd
      ship.vx*=s ship.vy*=s
    end
  end

  -- fire
  if ship.cd>0 then ship.cd-=1 end
  if btnp(5) and ship.cd<=0 and #bullets<max_bullets then
    local mx=ship.x+cos(ship.a)*8
    local my=ship.y+sin(ship.a)*8
    add(bullets,{
      x=mx,y=my,
      vx=ship.vx+cos(ship.a)*bullet_speed,
      vy=ship.vy+sin(ship.a)*bullet_speed,
      t=bullet_life
    })
    ship.cd=fire_delay
  end

  -- ship physics
  ship.x+=ship.vx
  ship.y+=ship.vy
  ship.vx*=ship.drag
  ship.vy*=ship.drag
  wrap_xy(ship,ship.radius)

  -- bullets
  for i=#bullets,1,-1 do
    local b=bullets[i]
    b.x+=b.vx b.y+=b.vy
    wrap_xy(b,2)
    b.t-=1
    if b.t<=0 then deli(bullets,i) end
  end

  -- asteroids
  for a in all(asteroids) do
    a.x+=a.vx
    a.y+=a.vy
    wrap_xy(a,a.r)
  end

  -- bullet vs asteroid
  for bi=#bullets,1,-1 do
    local b=bullets[bi]
    for ai=#asteroids,1,-1 do
      local a=asteroids[ai]
      if dist(b.x,b.y,a.x,a.y)<a.r then
        -- hit!
        deli(bullets,bi)
        split_asteroid(a)
        deli(asteroids,ai)
        break
      end
    end
  end
end

function _draw()
  cls(0)
  draw_ship(ship,7)
  if btn(2) then draw_thrust(ship) end

  for b in all(bullets) do
    pset(b.x,b.y,10)
  end

  for a in all(asteroids) do
    circ(a.x,a.y,a.r,6)
  end
end

-- helpers

function draw_ship(s,c)
  for seg in all(ship_lines) do
    local p1=ship_model[seg[1]]
    local p2=ship_model[seg[2]]
    local x1,y1=rot_trans(p1[1],p1[2],s.a,s.x,s.y)
    local x2,y2=rot_trans(p2[1],p2[2],s.a,s.x,s.y)
    line(x1,y1,x2,y2,c)
  end
end

function draw_thrust(s)
  local bx=s.x-cos(s.a)*6
  local by=s.y-sin(s.a)*6
  local fx=bx-cos(s.a)*(2+rnd(3))+(rnd(2)-1)
  local fy=by-sin(s.a)*(2+rnd(3))+(rnd(2)-1)
  line(bx,by,fx,fy,9+rnd(2))
end

function rot_trans(px,py,a,tx,ty)
  local rx= px*cos(a)-py*sin(a)
  local ry= px*sin(a)+py*cos(a)
  return rx+tx,ry+ty
end

function wrap_xy(o,margin)
  if o.x<-margin then o.x=128+margin end
  if o.x>128+margin then o.x=-margin end
  if o.y<-margin then o.y=128+margin end
  if o.y>128+margin then o.y=-margin end
end

function hypot(x,y)
  return sqrt(x*x+y*y)
end

function dist(x1,y1,x2,y2)
  local dx=x2-x1
  local dy=y2-y1
  return sqrt(dx*dx+dy*dy)
end

-- asteroid logic

function spawn_asteroid(x,y,size)
  local r=16
  if size==1 then r=8 end
  local a={
    x=x,y=y,
    vx=rnd(2)-1,
    vy=rnd(2)-1,
    r=r,
    size=size
  }
  add(asteroids,a)
end

function split_asteroid(a)
  if a.size>0 then
    for i=1,2 do
      spawn_asteroid(a.x,a.y,a.size-1)
    end
  end
end
-- asteroids demo
-- ship + bullets + asteroids

function _init()
  -- ship setup
  ship={
    x=64,y=64,vx=0,vy=0,
    a=0,turn=0.03,
    accel=0.06,drag=0.995,
    radius=6,cd=0
  }

  ship_model={
    { 7, 0},
    {-5, 5},
    {-2, 0},
    {-5,-5}
  }
  ship_lines={
    {1,2},{2,3},{3,4},{4,1},{1,3}
  }

  bullets={}
  max_bullets=6
  bullet_speed=2.5
  bullet_life=60
  fire_delay=8

  -- asteroids
  asteroids={}
  for i=1,4 do
    spawn_asteroid(rnd(128),rnd(128),2)
  end
end

function _update()
  -- rotate
  if btn(0) then ship.a-=ship.turn end
  if btn(1) then ship.a+=ship.turn end

  -- thrust
  if btn(2) then
    ship.vx+=cos(ship.a)*ship.accel
    ship.vy+=sin(ship.a)*ship.accel
    local spd=hypot(ship.vx,ship.vy)
    if spd>2.5 then
      local s=2.5/spd
      ship.vx*=s ship.vy*=s
    end
  end

  -- fire
  if ship.cd>0 then ship.cd-=1 end
  if btnp(5) and ship.cd<=0 and #bullets<max_bullets then
    local mx=ship.x+cos(ship.a)*8
    local my=ship.y+sin(ship.a)*8
    add(bullets,{
      x=mx,y=my,
      vx=ship.vx+cos(ship.a)*bullet_speed,
      vy=ship.vy+sin(ship.a)*bullet_speed,
      t=bullet_life
    })
    ship.cd=fire_delay
  end

  -- ship physics
  ship.x+=ship.vx
  ship.y+=ship.vy
  ship.vx*=ship.drag
  ship.vy*=ship.drag
  wrap_xy(ship,ship.radius)

  -- bullets
  for i=#bullets,1,-1 do
    local b=bullets[i]
    b.x+=b.vx b.y+=b.vy
    wrap_xy(b,2)
    b.t-=1
    if b.t<=0 then deli(bullets,i) end
  end

  -- asteroids
  for a in all(asteroids) do
    a.x+=a.vx
    a.y+=a.vy
    wrap_xy(a,a.r)
  end

  -- bullet vs asteroid
  for bi=#bullets,1,-1 do
    local b=bullets[bi]
    for ai=#asteroids,1,-1 do
      local a=asteroids[ai]
      if dist(b.x,b.y,a.x,a.y)<a.r then
        -- hit!
        deli(bullets,bi)
        split_asteroid(a)
        deli(asteroids,ai)
        break
      end
    end
  end
end

function _draw()
  cls(0)
  draw_ship(ship,7)
  if btn(2) then draw_thrust(ship) end

  for b in all(bullets) do
    pset(b.x,b.y,10)
  end

  for a in all(asteroids) do
    circ(a.x,a.y,a.r,6)
  end
end

-- helpers

function draw_ship(s,c)
  for seg in all(ship_lines) do
    local p1=ship_model[seg[1]]
    local p2=ship_model[seg[2]]
    local x1,y1=rot_trans(p1[1],p1[2],s.a,s.x,s.y)
    local x2,y2=rot_trans(p2[1],p2[2],s.a,s.x,s.y)
    line(x1,y1,x2,y2,c)
  end
end

function draw_thrust(s)
  local bx=s.x-cos(s.a)*6
  local by=s.y-sin(s.a)*6
  local fx=bx-cos(s.a)*(2+rnd(3))+(rnd(2)-1)
  local fy=by-sin(s.a)*(2+rnd(3))+(rnd(2)-1)
  line(bx,by,fx,fy,9+rnd(2))
end

function rot_trans(px,py,a,tx,ty)
  local rx= px*cos(a)-py*sin(a)
  local ry= px*sin(a)+py*cos(a)
  return rx+tx,ry+ty
end

function wrap_xy(o,margin)
  if o.x<-margin then o.x=128+margin end
  if o.x>128+margin then o.x=-margin end
  if o.y<-margin then o.y=128+margin end
  if o.y>128+margin then o.y=-margin end
end

function hypot(x,y)
  return sqrt(x*x+y*y)
end

function dist(x1,y1,x2,y2)
  local dx=x2-x1
  local dy=y2-y1
  return sqrt(dx*dx+dy*dy)
end

-- asteroid logic

function spawn_asteroid(x,y,size)
  local r=16
  if size==1 then r=8 end
  local a={
    x=x,y=y,
    vx=rnd(2)-1,
    vy=rnd(2)-1,
    r=r,
    size=size
  }
  add(asteroids,a)
end

function split_asteroid(a)
  if a.size>0 then
    for i=1,2 do
      spawn_asteroid(a.x,a.y,a.size-1)
    end
  end
end
