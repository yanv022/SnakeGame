WIDTH = 600
HEIGHT = 720
BACKGROUND = colorant"antiquewhite"
header = 120
global game_started = false
global gameover_sound_played = false

snake_pos_x = WIDTH / 2
snake_pos_y = (HEIGHT - header) / 2 + header
snake_size = 20
snake_color = colorant"green"

snake_head = Rect(
    snake_pos_x, snake_pos_y, snake_size, snake_size
)

snake_body = []

# Diese Funktion vergrößert den Schlangenkörper, indem sie ein Segment hinzufügt.
function grow()
    push!(snake_body,
        Rect(
            snake_head.x, snake_head.y, snake_size, snake_size
        )
    )
end

grow()

apple_size = snake_size
apple_color = colorant"red"

# Diese Funktion generiert eine neue Position für einen Apfel, die nicht vom Schlangenkörper besetzt ist.
function spawn()
    xrange = collect(0:snake_size:(WIDTH - snake_size))
    yrange = collect(header:snake_size:(HEIGHT - snake_size))
    x = rand(xrange)
    y = rand(yrange)
    occupied = []
    for i in 1:length(snake_body)
        push!(occupied, (snake_body[i].x, snake_body[i].y))
    end
    if (x, y) in occupied
        spawn()
    else
        return x, y
    end
end

apple_pos_x, apple_pos_y = spawn()
apple = Rect(
    apple_pos_x, apple_pos_y, apple_size, apple_size
)

special_apple_color = colorant"skyblue"
global special_apple = nothing
# Timer, um die Dauer des speziellen Apfels zu verfolgen
# Dauer (in Sekunden), wie lange der spezielle Apfel auf dem Bildschirm bleibt
global special_apple_timer = 0
global special_apple_duration = 5


# Diese Funktion generiert einen speziellen Apfel an einer zufälligen Position.
function spawn_special_apple()
    global special_apple
    apple_pos_x, apple_pos_y = spawn()
    special_apple = Rect(apple_pos_x, apple_pos_y, apple_size, apple_size)
end

speed = snake_size
vx = speed
vy = 0

delay = 0.2
delay_limit = 0.05
score = 0
high_score = 0
gameover = false

# Bewegt die Schlange basierend auf ihrer Geschwindigkeit.
function move()
    snake_head.x += vx
    snake_head.y += vy
end

# Überprüft, ob die Schlange die Spielfeldgrenzen überschritten hat.
function border()
    global gameover
    if snake_head.x == WIDTH ||
        snake_head.x < 0 ||
        snake_head.y == HEIGHT ||
        snake_head.y < header
            gameover = true
    end
end

# Überprüft, ob der Schlangenkopf mit dem Körper kollidiert.
function collide_head_body()
    global gameover
    for i in 1:length(snake_body)
        if collide(snake_head, snake_body[i])
            gameover = true
        end
    end
end

# Überprüft, ob der Schlangenkopf mit einem Apfel kollidiert, und aktualisiert den Status.
function collide_head_apple()
    global delay, level, score
    if collide(snake_head, apple)
        apple.x, apple.y = spawn()
        play_sound("mange1")
        grow()
        if delay > delay_limit
            delay -= 0.01
        end
        score += 1
        if score == target_score_level_2 && level == 1
            level = 2
            generate_symmetric_obstacles(level)
        elseif score == target_score_level_3 && level == 2
            level = 3
            generate_symmetric_obstacles(level)
        elseif score == target_score_level_4 && level == 3
            level = 4
            generate_symmetric_obstacles(level)
        elseif score == target_score_level_5 && level == 4
            level = 5
            generate_symmetric_obstacles(level)
        end
    end
end
#Zeichnet den Startbildschirm mit Titel und Aufforderung.
function draw_start_screen()
    draw(Rect(0, 0, WIDTH, HEIGHT), colorant"black", fill = true)
    title = TextActor("SNAKE GAME", "comicbd"; font_size = 48, color = Int[255, 255, 255, 255])
    title.pos = (WIDTH / 2 - 150, HEIGHT / 2 - 50)
    draw(title)
    subtitle = TextActor("Zum Starten klicken", "comicbd"; font_size = 24, color = Int[200, 200, 200, 255])
    subtitle.pos = (WIDTH / 2 - 130, HEIGHT / 2 + 20)
    draw(subtitle)
end

# Überprüft, ob der Schlangenkopf mit einem speziellen Apfel kollidiert.
function collide_special_apple()
    global special_apple, delay, score
    if special_apple !== nothing && collide(snake_head, special_apple)
        play_sound("mange")
        score += 2
        delay += 0.05
        special_apple = nothing
    end
end

# Überprüft, ob der Schlangenkopf mit Hindernissen kollidiert.
function collide_head_obstacles()
    global gameover
    if level >= 2
        for obstacle in obstacles
            if collide(snake_head, obstacle)
                gameover = true
            end
        end
    end
end

# Zeichnet den Game-Over-Bildschirm mit der Endpunktzahl.
function draw_game_over_screen()
    draw(Rect(0, 0, WIDTH, HEIGHT), colorant"black", fill = true)
    game_over_title = TextActor("GAME OVER", "comicbd"; font_size = 48, color = Int[255, 0, 0, 255])
    game_over_title.pos = (WIDTH / 2 - 150, HEIGHT / 2 - 50)
    draw(game_over_title)
    restart_message = TextActor("Klicke zum Neustart.", "comicbd"; font_size = 24, color = Int[200, 200, 200, 255])
    restart_message.pos = (WIDTH / 2 - 130, HEIGHT / 2 + 20)
    draw(restart_message)
end

# Zeichnet das Spielfeld, die Schlange, Äpfel und Hindernisse.
function draw(g::Game)
    # Zeichne Startbildschirm
    if game_started == false
        draw_start_screen()
        return
    end

    # Zeichne Game-Over-Bildschirm
    if gameover
        draw_game_over_screen()
        return
    end

# Zeichne Äpfel und Hindernisse
    draw(apple, apple_color, fill = true)
    if special_apple !== nothing
        draw(special_apple, special_apple_color, fill = true)
        text_actor = TextActor("+2", "comicbd"; font_size = 12, color = Int[0, 0, 0, 255])
        text_actor.pos = (
            special_apple.x + apple_size / 2 - 8,
            special_apple.y + apple_size / 2 - 8
        )
        draw(text_actor)
    end 

# Benutzerinteraktionen und Level-Management

target_score_level_2 = 5
target_score_level_3 = 10
target_score_level_4 = 15
target_score_level_5 = 25

global obstacles = []
obstacle_color = colorant"black"

# Diese Funktion generiert Hindernisse symmetrisch je nach Level.

function generate_symmetric_obstacles(level::Int)
    global obstacles
    obstacles = []
    if level == 2
        push!(obstacles, Rect(WIDTH / 4, HEIGHT / 3, snake_size * 5, snake_size))
        push!(obstacles, Rect(WIDTH / 4, 2 * HEIGHT / 3, snake_size * 5, snake_size))
        push!(obstacles, Rect(WIDTH / 2 - snake_size / 2, HEIGHT / 4, snake_size, snake_size * 5))
    elseif level == 3
        push!(obstacles, Rect(WIDTH / 4, HEIGHT / 4, snake_size * 8, snake_size))
        push!(obstacles, Rect(3 * WIDTH / 4 - snake_size * 8, HEIGHT / 4, snake_size * 8, snake_size))
        push!(obstacles, Rect(WIDTH / 4, 3 * HEIGHT / 4, snake_size * 8, snake_size))
        push!(obstacles, Rect(3 * WIDTH / 4 - snake_size * 8, 3 * HEIGHT / 4, snake_size * 8, snake_size))
        push!(obstacles, Rect(WIDTH / 2 - snake_size / 2, HEIGHT / 2 - snake_size * 3, snake_size, snake_size * 6))
    elseif level == 4
        push!(obstacles, Rect(WIDTH / 4, HEIGHT / 4, snake_size * 3, snake_size))
        push!(obstacles, Rect(WIDTH / 4, 3 * HEIGHT / 4, snake_size * 3, snake_size))
        push!(obstacles, Rect(3 * WIDTH / 4 - snake_size * 3, HEIGHT / 4, snake_size * 3, snake_size))
        push!(obstacles, Rect(3 * WIDTH / 4 - snake_size * 3, 3 * HEIGHT / 4, snake_size * 3, snake_size))
    elseif level == 5
        s_width = snake_size * 18
        s_height = snake_size * 30
        s_thickness = snake_size * 2
        push!(obstacles, Rect((WIDTH - s_width) / 2, (HEIGHT - s_height) / 2, s_width, s_thickness))
        push!(obstacles, Rect((WIDTH - s_width) / 2, (HEIGHT - s_height) / 2, s_thickness, s_height / 2))
        push!(obstacles, Rect((WIDTH - s_width) / 2, HEIGHT / 2 - s_thickness / 2, s_width, s_thickness))
        push!(obstacles, Rect((WIDTH - s_width) / 2 + s_width - s_thickness, HEIGHT / 2, s_thickness, s_height / 2))
        push!(obstacles, Rect((WIDTH - s_width) / 2, (HEIGHT + s_height) / 2 - s_thickness, s_width, s_thickness))
    end
end

# Diese Funktion aktualisiert die Richtung der Schlange basierend auf Benutzereingaben.
function direction(x, y)
    global vx, vy
    vx = x
    vy = y
end

right() = direction(speed, 0)
left() = direction(-speed, 0)
down() = direction(0, speed)
up() = direction(0, -speed)

# Verarbeitet Tastatureingaben, um die Schlange zu bewegen.
function on_key_down(g::Game, k)
    if g.keyboard.RIGHT
        if vx !== -speed
            right()
        end
    elseif g.keyboard.LEFT
        if vx !== speed
            left()
        end
    elseif g.keyboard.DOWN
        if vy !== -speed
            down()
        end
    elseif g.keyboard.UP
        if vy !== speed
            up()
        end
    end
end

# Setzt den Spielstatus zurück und initialisiert alle Variablen neu.
function reset()
    global snake_head, snake_body, obstacles, score, high_score, level, delay, gameover, special_apple, gameover_sound_played
    if score > high_score
        high_score = score
    end
    snake_head = Rect(snake_pos_x, snake_pos_y, snake_size, snake_size)
    snake_body = []
    grow()
    apple_pos_x, apple_pos_y = spawn()
    apple.x, apple.y = apple_pos_x, apple_pos_y
    special_apple = nothing
    obstacles = []
    score = 0
    level = 1
    delay = 0.2
    gameover = false
    gameover_sound_played = false
end

# Behandelt Mausklicks, um das Spiel zu starten oder neu zu starten.
function on_mouse_down(g::Game)
    global game_started
    if !game_started
        game_started = true
    elseif gameover == true
        reset()
    end
end

# Aktualisiert den Spielstatus bei jedem Frame.
function update(g::Game)
    if !game_started
        return
    end
    if gameover == false
        global snake_body, special_apple, special_apple_timer
        move()
        border()
        collide_head_body()
        collide_head_apple()
        collide_special_apple()
        collide_head_obstacles()
        grow()
        popat!(snake_body, 1)
        sleep(delay)
        if special_apple !== nothing
            special_apple_timer -= 1
            if special_apple_timer <= 0
                special_apple = nothing
            end
        elseif rand() < 0.01
            spawn_special_apple()
            special_apple_timer = special_apple_duration * 10
        end
    else
        global gameover_sound_played
        if !gameover_sound_played
           play_sound("gameOver")
            gameover_sound_played = true
        end
    end
end

 # Zeichne Hindernisse
    if level >= 2
        for obstacle in obstacles
            draw(obstacle, obstacle_color, fill = true)
        end
    end
    draw(headerbox, colorant"navyblue", fill = true)
    if gameover == false
        score_display = "Score = $score"
        high_score_display = "High Score = $high_score"
        level_display = "Level = $level"
    else
        score_display = "GAME OVER! Final Score = $score"
        high_score_display = "High Score = $high_score"
        level_display = "Click to Play Again"
    end
    y_offset = 10

 # Zeichne Score, High Score und Level
    txt1 = TextActor(score_display, "comicbd"; font_size = 24, color = Int[255, 255, 0, 255])
    txt1.pos = (30, y_offset)
    draw(txt1)
    txt2 = TextActor(high_score_display, "comicbd"; font_size = 24, color = Int[255, 255, 0, 255])
    txt2.pos = (30, y_offset + 30)
    draw(txt2)
  
    txt3 = TextActor(level_display, "comicbd"; font_size = 24, color = Int[255, 255, 0, 255])
    txt3.pos = (30, y_offset + 60)
    draw(txt3)
end




















    
    
