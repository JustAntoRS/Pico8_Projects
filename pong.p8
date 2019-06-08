pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--[[by antonio ramirez solans
@justantors]]
--version 1.0.6

function _init()
	t=0 --time in frames
	s=0	--time in seconds (30t=1s)
	p_win=11 --points to win(2p)
	new_highscore=false --1p var
	col_over=8 --game over highscore color (1p)

	--open cart data
	cartdata("1p")

	--play area limits
	area={x1=5,y1=20,x2=123,y2=127}
	--timer position
	timer={x=62,y=8}
	--menu vars
	menu={sel="1p",col1=6,col2=6}
	--pads
	p1={
		col=12,
		x=40,
		y=94,
		speed=2,
		p=0,
		h=14,
		w=1,
		angles={0.1,0.0,0.9}
		}
	p2={
		col=8,
		x=83,
		y=94,
		speed=2,
		p=0,
		h=14,
		w=1,
		angles={0.4,0.5,0.6},
		playable=true
		}
	--ball
	ball={
	stop_d=false,
	s=0,
	sp=1,
	x=62,
	y=73,
	rad=2,
	angle=0,
	speed=2.3
	}
	--starting function
		start_menu()
end


function ball_move()
	--update ball speed
	ball.speed+=s*(0.0001)

	--calculate displacement
	local x_v=ball.speed*cos(ball.angle)
	local y_v=ball.speed*sin(ball.angle)

	--move ball
	if not ball.stop_d then
		ball.x+=x_v
		ball.y+=y_v
	end

	--wall collisions
		--left
	if ball.x-x_v-ball.rad<=area.x1 then
		if p2.playable then
			new_point(50)
		else
			game_over()
		end
		--add one to point counter
		p2.p+=1
		sfx(1)
	end
		--right
	if ball.x+x_v+ball.rad*2>=area.x2 then
		if p2.playable then
			new_point(70)
		else
			local new_angle=0.25+(-0.025+rnd(0.025))
			ball_bounce(new_angle)
		end
		--add one to point counter
		p1.p+=1
		sfx(1)
	end
		--top
	if ball.y+y_v<=area.y1 then
		ball_bounce(0.5)
	end
		--bottom
	if ball.y+y_v+ball.rad*2>=area.y2 then
		ball_bounce(0.5)
	end

	--pad collisions
		--pad1
	if ball.y+ball.rad*2>=p1.y and
				ball.y-ball.rad*2<=p1.y+p1.h and
				ball.x+x_v<=p1.x+p1.w and
				ball.x>p1.x then
		ball.angle=pad_coll(p1)
		sfx(0)
	end

		--pad2
	if p2.playable then
		if ball.y>=p2.y-ball.rad*2 and
					ball.y<=p2.y+p1.h+ball.rad*2 and
					ball.x+ball.rad*2+x_v>=p2.x and
					ball.x+ball.rad*2<p2.x+p2.w then
			ball.angle=pad_coll(p2)
			sfx(0)
		end
	end
end

function pad_coll(pad)
 if ball.y+ball.rad<7+pad.y then
		return pad.angles[1]+(-0.01+rnd(0.01))
	elseif ball.y+ball.rad<8+pad.y then
  return pad.angles[2]+(-0.01+rnd(0.01))
 else
 	return pad.angles[3]+(-0.01+rnd(0.01))
 end
end

--[[bounce the ball with a
given angle]]
function ball_bounce(angle)
	ball.angle=2*angle-ball.angle
	ball.angle=ball.angle%1
end

--[[restart all vars to play
a new point]]
function new_point(new_x)
	--stop ball
	ball.stop_d=true
	s=0
	ball.s=0

	--restart ball
	ball.x=new_x
	ball.y=73
	ball.speed=2

	--restart pads
	p1.y=69
	p2.y=69
	p1.speed=2
	p2.speed=2

	--restart timer pos
	timer.x=62

	--calculate starting angle
	if p2.playable then
		if new_x==70 then
			ball.angle=0.5
		elseif new_x==50 then
			ball.angle=0
		else
			local random=rnd(1)
			if random<0.5 then
				ball.angle=0
			else
				ball.angle=0.5
			end
		end
	else
		ball.angle=0.5
	end
end

function draw_pad(pad)
	rectfill(pad.x,pad.y,
										pad.x+pad.w,pad.y+pad.h+1,
										pad.col)
end

function draw_bg()
	local col=0
	local x=64
	local y=64
	for i=1,35 do
		col=1+flr(rnd(14))
		x=64-flr(rnd(10))
		y=64-flr(rnd(10))
		circ(x,y,55+i,col)
	end
	circfill(64,64,60,0)
end

function start_menu()
	--play music
	music(0)

	--update basic functions
	_update = update_menu
	_draw = draw_menu

	--restart pad position
	p1.x=40
	p1.y=94
	p2.x=83
	p2.y=94

	--restart pad score
	p1.p=0
	p2.p=0

	--restart global variables
	s=0
	t=0
	new_highscore=false
	p2.playable=true
end

function start_selection()
	_update=update_selection
	_draw=draw_selection
end

function start_game()
	--stop music
	music(-1)

	--update function
	_update=update_game
	_draw =draw_game

	--update pads
	p1.x=16
	p2.x=109

	--restart
	new_point(62)
end

function game_over()
	--play music
	music(0)

	--update functions
	_update=update_over
	_draw=draw_over

	--high-score
	if not p2.playable then
		if dget(0)<p1.p then
			new_highscore=true
			dset(0,p1.p)
			dset(1,s)
		end
	end

end

function update_menu()
--mode selection
	if (menu.sel=="1p") then
		menu.col1=8
		menu.col2=6
	else
		menu.col1=6
		menu.col2=8
	end

	if btn(1) and menu.sel=="1p" then
		menu.sel="2p"
	end

	if btn(0) and menu.sel=="2p" then
		menu.sel="1p"
	end

	--start
	if btnp(5) then
	 sfx(1)
	 if menu.sel=="2p" then
	 	start_selection()
		else
			p2.playable=false
			start_game()
		end
	end

	--controls
	if btn(2,1) and p1.y>85 then
		p1.y-=2
	end

	if btn(3,1) and p1.y<100 then
		p1.y+=2
	end

	if btn(2,0) and p2.y>85 then
		p2.y-=2
	end

	if btn(3,0) and p2.y<100 then
		p2.y+=2
	end
end

function draw_menu()
	cls()

	--draw background
	draw_bg()

	--player selection
	print("choose a mode:",37,20,6)
	print("press ❎ to start",30,60,11)
	rect(35,35,50,50,menu.col1)
	rect(75,35,90,50,menu.col2)
	print("1p",40,40,menu.col1)
	print("2p",80,40,menu.col2)

	--controls
	print("controls",48,75,6)
	draw_pad(p1)
	draw_pad(p2)
	color(6) -- default color to 6
	print("p1",25,85)
	print("e",25,93)
	print("d",25,101)
	print("p2",93,85)
	print("⬆️",95,93)
	print("⬇️",95,101)
end

function update_selection()
		--update p_win
		if btnp(2) and p_win<31 then
			p_win+=2
		end
		if btnp(3) and p_win>1 then
			p_win-=2
		end

		--start game
		if btnp(5) then start_game() end

end

function draw_selection()
	cls()

	--draw background
	draw_bg()

	--points selection
	print("how many points to win?:",15,50,6)
	print(p_win,111,50,8)
	print("+2",55,70,8)
	print("-2",55,80,12)
	print("⬆️",63,70,8)
	print("⬇️",63,80,12)
	rect(50,65,75,90,13)
	print("press ❎ to start",30,30,11)
end

function update_game()
	--time
	t+=1
	if(t%30==0) then s+=1 end

	--game_over
	if p2.playable then
		if p1.p==p_win or p2.p==p_win then
			game_over()
		end
	end

	--controls
		--pad1
	if btn(2,1) and p1.y-p1.speed>area.y1+2 then
		p1.y-=p1.speed
	end
	if btn(3,1) and p1.y+p1.speed+p1.h<area.y2-2 then
		p1.y+=p1.speed
	end
		--pad2
	if p2.playable then
		if btn(2,0) and p2.y-p2.speed>area.y1+2 then
			p2.y-=p2.speed
		end
		if btn(3,0) and p2.y+p1.speed+p1.h<area.y2-2 then
			p2.y+=p2.speed
		end
	end

	--ball movement
	ball_move()

	if ball.stop_d then
		if ball.s+1.5<s then
			ball.stop_d=false
			sfx(3)
		end
	end

	--update pad speed
	p1.speed+=(s*0.0001)
	if p2.playable then
		p2.speed+=(s*0.0001)
	end

			--update timer position
	if timer.x==62 and s>9 then
		timer.x=60
	end

	if timer.x==60 and s>99 then
		timer.x=58
	end

end

function draw_game()
	cls()

	--game area limits
	rect(area.x1,area.y1,
						area.x2,area.y2,6)

	--middle net
	for i=0,16 do
		line(64,24+(6*i),64,27+(6*i),6)
	end

	--pads
	draw_pad(p1)
	if p2.playable then
		draw_pad(p2)
	end

		--ball
	spr(ball.sp,ball.x,ball.y)

	--score panel
	rect(10,6,35,16,12)--rect p1
	rect(50,6,77,14,6)--timer rect
	print(p1.p,22,9,6)--p1 score
	if p2.playable then
		print(p2.p,104,9,6)--p2 score
		rect(92,6,117,16,8)--rect p2
	else
		print(dget(0),116,9,8)--highscore
		print("hi-score:",80,9,6)
	end
	print(s,timer.x,timer.y,6)--time
end

function update_over()
	--time
	t+=1

	--change color of highscore
	if new_highscore and t%30==0 then
		col_over+=1
		if col_over>12 then
			col_over=8
		end
	end

	--restart
	if btnp(5) then
		start_menu()
	end

end

function draw_over()
	cls()
	--background
	draw_bg()
	--print text

	if p2.playable then --2 players
		if p1.p==p_win then
			print("p1 wins!",47,25,12)
			spr(26,38,35,6,7) --blue trophie
		else
			print("p2 wins!",47,25,8)
			spr(19,38,35,6,7) --red trophie
		end
	else --1 player
		print("your score was:",30,30,6)
		print(p1.p,90,30,8)
		print("your time was:",32,50,6)
		print(s,88,50,8)
		if new_highscore then
			print("new highscore!",34,75,col_over)
			print(p1.p,40,83,col_over)
			print("in",50,83,col_over)
			print(s,60,83,col_over)
			print("sec",70,83,col_over)
		end
	end

	print("press ❎ to start again",20,95,11)

end
__gfx__
00000000099900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700999a90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700099aa90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000099900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000005555555555555555555555555555555555555555555555000000000055555555555555555555555555555555555555555555550
00000000000000000000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa500000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa50
00000000000000000000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa500000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa50
00000000000000000000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa500000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa50
000000000000000000000000055aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa55000000000055aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa550
000000000000000000000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa50000000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa500
0000000000000000000000000055aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa5500000000000055aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa5500
0000000000000000000000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa5000000000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa5000
00000000000000000000000000055aaaaaaaaaaaaaaaaaa00aaaaaaaaaaaaaaaaaa550000000000000055aaaaaaaaaaaaaaaaaa00aaaaaaaaaaaaaaaaaa55000
00000000000000000000000000005aaaaaaaaaaaaaaaaa0880aaaaaaaaaaaaaaaaa500000000000000005aaaaaaaaaaaaaaaaa0cc0aaaaaaaaaaaaaaaaa50000
00000000000000000000000000005aaaaaaaaaaaaaaaaa0880aaaaaaaaaaaaaaaaa500000000000000005aaaaaaaaaaaaaaaaa0cc0aaaaaaaaaaaaaaaaa50000
000000000000000000000000000055aaaaaaaaaaaaaaa0e88e0aaaaaaaaaaaaaaa55000000000000000055aaaaaaaaaaaaaaa06cc60aaaaaaaaaaaaaaa550000
000000000000000000000000000005aaaaaaaaaaaaaaa08ee80aaaaaaaaaaaaaaa50000000000000000005aaaaaaaaaaaaaaa0c66c0aaaaaaaaaaaaaaa500000
000000000000000000000000000005aaaaaaaaaaaaaa088ee880aaaaaaaaaaaaaa50000000000000000005aaaaaaaaaaaaaa0cc66cc0aaaaaaaaaaaaaa500000
0000000000000000000000000000055aaaaaaaaaaaaa088ee880aaaaaaaaaaaaa5500000000000000000055aaaaaaaaaaaaa0cc66cc0aaaaaaaaaaaaa5500000
0000000000000000000000000000005aaaaaaaaaaaaa088ee880aaaaaaaaaaaaa5000000000000000000005aaaaaaaaaaaaa0cc66cc0aaaaaaaaaaaaa5000000
0000000000000000000000000000005aaaaaaaaaaaaaa08ee80aaaaaaaaaaaaaa5000000000000000000005aaaaaaaaaaaaaa0c66c0aaaaaaaaaaaaaa5000000
00000000000000000000000000000055aaaaaaaaaaaaa0e88e0aaaaaaaaaaaaa550000000000000000000055aaaaaaaaaaaaa06cc60aaaaaaaaaaaaa55000000
00000000000000000000000000000005aaaaaaaaaaaaaa0880aaaaaaaaaaaaaa500000000000000000000005aaaaaaaaaaaaaa0cc0aaaaaaaaaaaaaa50000000
00000000000000000000000000000005aaaaaaaaaaaaaa0880aaaaaaaaaaaaaa500000000000000000000005aaaaaaaaaaaaaa0cc0aaaaaaaaaaaaaa50000000
000000000000000000000000000000055aaaaaaaaaaaaaa00aaaaaaaaaaaaaa55000000000000000000000055aaaaaaaaaaaaaa00aaaaaaaaaaaaaa550000000
000000000000000000000000000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa50000000000000000000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa500000000
000000000000000000000000000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa50000000000000000000000005aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa500000000
0000000000000000000000000000000055aaaaaaaaaaaaaaaaaaaaaaaaaaaa5500000000000000000000000055aaaaaaaaaaaaaaaaaaaaaaaaaaaa5500000000
00000000000000000000000000000000005aaaaaaaaaaaaaaaaaaaaaaaaaa500000000000000000000000000005aaaaaaaaaaaaaaaaaaaaaaaaaa50000000000
000000000000000000000000000000000055aaaaaaaaaaaaaaaaaaaaaaaa55000000000000000000000000000055aaaaaaaaaaaaaaaaaaaaaaaa550000000000
0000000000000000000000000000000000055aaaaaaaaaaaaaaaaaaaaaa5500000000000000000000000000000055aaaaaaaaaaaaaaaaaaaaaa5500000000000
00000000000000000000000000000000000055aaaaaaaaaaaaaaaaaaaa550000000000000000000000000000000055aaaaaaaaaaaaaaaaaaaa55000000000000
000000000000000000000000000000000000055aaaaaaaaaaaaaaaaaa55000000000000000000000000000000000055aaaaaaaaaaaaaaaaaa550000000000000
0000000000000000000000000000000000000055aaaaaaaaaaaaaaaa5500000000000000000000000000000000000055aaaaaaaaaaaaaaaa5500000000000000
00000000000000000000000000000000000000055aaaaaaaaaaaaaa550000000000000000000000000000000000000055aaaaaaaaaaaaaa55000000000000000
000000000000000000000000000000000000000055aaaaaaaaaaaa55000000000000000000000000000000000000000055aaaaaaaaaaaa550000000000000000
0000000000000000000000000000000000000000055aaaaaaaaaa5500000000000000000000000000000000000000000055aaaaaaaaaa5500000000000000000
000000000000000000000000000000000000000000555aaaaaa55500000000000000000000000000000000000000000000555aaaaaa555000000000000000000
000000000000000000000000000000000000000000555aaaaaa55500000000000000000000000000000000000000000000555aaaaaa555000000000000000000
0000000000000000000000000000000000000000055aaaaaaaaaa5500000000000000000000000000000000000000000055aaaaaaaaaa5500000000000000000
000000000000000000000000000000000000000005aaaaaaaaaaaa50000000000000000000000000000000000000000005aaaaaaaaaaaa500000000000000000
0000000000000000000000000000000000000000055aaaaaaaaaa5500000000000000000000000000000000000000000055aaaaaaaaaa5500000000000000000
000000000000000000000000000000000000000000555aaaaaa55500000000000000000000000000000000000000000000555aaaaaa555000000000000000000
0000000000000000000000000000000000000000000055aaaa5500000000000000000000000000000000000000000000000055aaaa5500000000000000000000
000000000000000000000000000000000000000000005aaaaaa50000000000000000000000000000000000000000000000005aaaaaa500000000000000000000
000000000000000000000000000000000000000000005aaaaaa50000000000000000000000000000000000000000000000005aaaaaa500000000000000000000
000000000000000000000000000000000000000000055aaaaaa55000000000000000000000000000000000000000000000055aaaaaa550000000000000000000
00000000000000000000000000000000000000000005aaaaaaaa500000000000000000000000000000000000000000000005aaaaaaaa50000000000000000000
00000000000000000000000000000000000000000055aaaaaaaa550000000000000000000000000000000000000000000055aaaaaaaa55000000000000000000
0000000000000000000000000000000000000000005aaaaaaaaaa5000000000000000000000000000000000000000000005aaaaaaaaaa5000000000000000000
0000000000000000000000000000000000000000055aaaaaaaaaa5500000000000000000000000000000000000000000055aaaaaaaaaa5500000000000000000
000000000000000000000000000000000000000005aaaaaaaaaaaa50000000000000000000000000000000000000000005aaaaaaaaaaaa500000000000000000
000000000000000000000000000000000000000055aaaaaaaaaaaa55000000000000000000000000000000000000000055aaaaaaaaaaaa550000000000000000
00000000000000000000000000000000000000005aaaaaaaaaaaaaa500000000000000000000000000000000000000005aaaaaaaaaaaaaa50000000000000000
00000000000000000000000000000000000000005aaaaaaaaaaaaaa500000000000000000000000000000000000000005aaaaaaaaaaaaaa50000000000000000
000000000000000000000000000000000000000055aaaaaaaaaaaa55000000000000000000000000000000000000000055aaaaaaaaaaaa550000000000000000
0000000000000000000000000000000000000000055aaaaaaaaaa5500000000000000000000000000000000000000000055aaaaaaaaaa5500000000000000000
000000000000000000000000000000000000000000555aaaaaa55500000000000000000000000000000000000000000000555aaaaaa555000000000000000000
00000000000000000000000000000000000000000000555555550000000000000000000000000000000000000000000000005555555500000000000000000000
__map__
00000000000000000000002b3c2b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000002b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010f00000c57300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000185542455124551185552b505245052850528505245052850524505295052b505245052850528505245052850524505295052b5052450528505285050000000000000000000000000000000000000000
01100020183551c3551835521355233551f3551c3551a3551d35521355233551f3551835521355233551d3551a355233551f35521355183551c3551f3551d3551a3551d35521355233551f35524355233551f355
011000003005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 02424344

