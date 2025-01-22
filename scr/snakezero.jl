# initialize screen

WIDTH = 600
HEIGHT = 720
BACKGROUND = colorant"antiquewhite"
header = 120
global game_started = false
global gameover_sound_played = false

# define snake actor
play_music("wallpaper")
snake_pos_x = WIDTH / 2
snake_pos_y = (HEIGHT - header) / 2 + header

snake_size = 20    # default = 20 | try 10, 30, 50

snake_color = colorant"green"

snake_head = Rect(
    snake_pos_x, snake_pos_y, snake_size, snake_size
)

# grow snake

snake_body = []

function grow()
    push!(snake_body,
        Rect(
            snake_head.x, snake_head.y, snake_size, snake_size
        )
    )
end

grow()

# define apple actor

function spawn()
    # all possible locations
    xrange = collect(0:snake_size:(WIDTH - snake_size))
    yrange = collect(header:snake_size:(HEIGHT - snake_size))
    x = rand(xrange)
    y = rand(yrange)
    # array of snake_body locations
    occupied = []
    for i in 1:length(snake_body)
        push!(occupied, (snake_body[i].x, snake_body[i].y))
    end
    # select spawning location
    if (x, y) in occupied
        spawn()
    else
        return x, y
    end
end

apple_pos_x, apple_pos_y = spawn()

apple_size = snake_size

apple_color = colorant"red"

apple = Rect(
    apple_pos_x, apple_pos_y, apple_size, apple_size
)

# define special apple actor
special_apple_color = colorant"skyblue"
global special_apple = nothing  # No special apple initially
global special_apple_timer = 0  # Timer to track how long the special apple stays
global special_apple_duration = 5  # Duration (in seconds) for the special apple to remain on the screen

function spawn_special_apple()
    global special_apple
    apple_pos_x, apple_pos_y = spawn()
    special_apple = Rect(apple_pos_x, apple_pos_y, apple_size, apple_size)
end

# define obstacles symmetrically

obstacle_color = colorant"black"
obstacles = []
# Fonction pour dessiner l'écran de démarrage
function draw_start_screen()
    # Fond de l'écran
    draw(Rect(0, 0, WIDTH, HEIGHT), colorant"black", fill = true)
    
    # Texte du titre
    title = TextActor("SNAKE GAME", "comicbd"; font_size = 48, color = Int[255, 255, 255, 255])
    title.pos = (WIDTH / 2 - 150, HEIGHT / 2 - 50)
    draw(title)
    
    # Texte pour indiquer de cliquer
    subtitle = TextActor("Zum Starten klicken", "comicbd"; font_size = 24, color = Int[200, 200, 200, 255])
    subtitle.pos = (WIDTH / 2 - 130, HEIGHT / 2 + 20)
    draw(subtitle)
end


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
        # Level 4(9 obstacles symétriques)
        push!(obstacles, Rect(WIDTH / 4, HEIGHT / 4, snake_size * 3, snake_size))
        push!(obstacles, Rect(WIDTH / 4, 3 * HEIGHT / 4, snake_size * 3, snake_size))
        push!(obstacles, Rect(3 * WIDTH / 4 - snake_size * 3, HEIGHT / 4, snake_size * 3, snake_size))
        push!(obstacles, Rect(3 * WIDTH / 4 - snake_size * 3, 3 * HEIGHT / 4, snake_size * 3, snake_size))
        push!(obstacles, Rect(WIDTH / 2 - snake_size * 1.5, HEIGHT / 3, snake_size * 3, snake_size))
        push!(obstacles, Rect(WIDTH / 2 - snake_size * 1.5, 2 * HEIGHT / 3, snake_size * 3, snake_size))
        push!(obstacles, Rect(WIDTH / 4 - snake_size, HEIGHT / 2 - snake_size / 2, snake_size * 3, snake_size))
        push!(obstacles, Rect(3 * WIDTH / 4 - snake_size * 3, HEIGHT / 2 - snake_size / 2, snake_size * 3, snake_size))
        push!(obstacles, Rect(WIDTH / 2 - snake_size / 2, HEIGHT / 2 - snake_size / 2, snake_size, snake_size))
    elseif level == 5
        # Obstacles pour le niveau 5 (S plus long et centré)
        s_width = snake_size * 18  # Largeur totale du S
        s_height = snake_size * 30  # Hauteur totale du S
        s_thickness = snake_size * 2  # Épaisseur des segments

        # Partie supérieure du S
        push!(obstacles, Rect((WIDTH - s_width) / 2, (HEIGHT - s_height) / 2, s_width, s_thickness))  # Ligne horizontale
        push!(obstacles, Rect((WIDTH - s_width) / 2, (HEIGHT - s_height) / 2, s_thickness, s_height / 2))  # Ligne verticale

        # Milieu du S
        push!(obstacles, Rect((WIDTH - s_width) / 2, HEIGHT / 2 - s_thickness / 2, s_width, s_thickness))  # Ligne horizontale

        # Partie inférieure du S
        push!(obstacles, Rect((WIDTH - s_width) / 2 + s_width - s_thickness, HEIGHT / 2, s_thickness, s_height / 2))  # Ligne verticale
        push!(obstacles, Rect((WIDTH - s_width) / 2, (HEIGHT + s_height) / 2 - s_thickness, s_width, s_thickness))  # Ligne horizontale
    end
end

# define header box actor

headerbox = Rect(0, 0, WIDTH, header)

# initialize game variables

score = 0
high_score = 0  # New variable to track the high score
gameover = false
level = 1  # Start at level 1
target_score_level_2 = 5  # Score to advance to level 2
target_score_level_3 = 10 # Score to advance to level 3
target_score_level_4 = 15 # Score to advance to level 4
target_score_level_5 = 25 # Score to advance to level 5

# draw actors

function draw(g::Game)
    # Draw the start screen if the game has not started
    if game_started == false
        draw_start_screen()
        return
    end

    # Si le jeu est terminé, afficher l'écran de Game Over
    if gameover
        draw_game_over_screen()
        return
    end
    # Snake
    draw(snake_head, snake_color, fill = true)
    for i in 1:length(snake_body)
        draw(snake_body[i], snake_color, fill = true)
    end
    # Apple
    draw(apple, apple_color, fill = true)
    # Special Apple
    if special_apple !== nothing
        # Draw the special apple as a solid skyblue rectangle
        draw(special_apple, special_apple_color, fill = true)
        # Add "+2" text inside the special apple
        text_actor = TextActor("+2", "comicbd"; font_size = 12, color = Int[0, 0, 0, 255])  # Smaller and black
        # Center the text inside the special apple
        text_actor.pos = (
            special_apple.x + apple_size / 2 - 8,  # Adjust to center horizontally
            special_apple.y + apple_size / 2 - 8   # Adjust to center vertically
        )
        draw(text_actor)
    end
    # Obstacles (only for level 2 and above)
    if level >= 2
        for obstacle in obstacles
            draw(obstacle, obstacle_color, fill = true)
        end
    end
    # Headerbox
    draw(headerbox, colorant"navyblue", fill = true)
    # Display score, high score, and level in the header
    if gameover == false
        # Information displayed during the game
        score_display = "Score = $score"
        high_score_display = "High Score = $high_score"
        level_display = "Level = $level"
    else
        # Information displayed on Game Over
        score_display = "GAME OVER! Final Score = $score"
        high_score_display = "High Score = $high_score"
        level_display = "Click to Play Again"
    end

    # Adjust text positions to stay in the header
    y_offset = 10  # Position near the top of the header
    txt1 = TextActor(score_display, "comicbd"; font_size = 24, color = Int[255, 255, 0, 255])
    txt1.pos = (30, y_offset)
    draw(txt1)

    txt2 = TextActor(high_score_display, "comicbd"; font_size = 24, color = Int[255, 255, 0, 255])
    txt2.pos = (30, y_offset + 30)  # Adjust the offset for the second line
    draw(txt2)

    txt3 = TextActor(level_display, "comicbd"; font_size = 24, color = Int[255, 255, 0, 255])
    txt3.pos = (30, y_offset + 60)  # Adjust the offset for the third line
    draw(txt3)
end

# move snake

speed = snake_size

vx = speed
vy = 0

function move()
    snake_head.x += vx
    snake_head.y += vy
end

# set variables to regulate snake speed

delay = 0.2    # delay in seconds

delay_limit = 0.05

# define border function

function border()
    global gameover
    if snake_head.x == WIDTH ||
        snake_head.x < 0 ||
        snake_head.y == HEIGHT ||
        snake_head.y < header
            gameover = true
    end
end

# define collision functions

function collide_head_body()
    global gameover
    for i in 1:length(snake_body)
        if collide(snake_head, snake_body[i])
            gameover = true
        end
    end
end

function collide_head_apple()
    global delay, level, score
    if collide(snake_head, apple)
        # spawn new apple
        apple.x, apple.y = spawn()

        # play sound
        play_sound("mange1")


        # grow snake body
        grow()
        # reduce delay
        if delay > delay_limit
            delay -= 0.01
        end
        # Update score and check for level advancement
        score += 1
        if score == target_score_level_2 && level == 1
            level = 2
            generate_symmetric_obstacles(level)  # Add symmetric obstacles in level 2
        elseif score == target_score_level_3 && level == 2
            level = 3
            generate_symmetric_obstacles(level)  # Add larger symmetric obstacles in level 3
        elseif score == target_score_level_4 && level == 3
            level = 4
            generate_symmetric_obstacles(level)  # Add even larger symmetric obstacles in level 4
        elseif score == target_score_level_5 && level == 4
            level = 5
            generate_symmetric_obstacles(level)  # Add even larger symmetric obstacles in level 5
        end
    end
end

function collide_special_apple()
    global special_apple, delay, score
    if special_apple !== nothing && collide(snake_head, special_apple)
        play_sound("mange")
        score += 2  # Double the normal score
        delay += 0.05  # Temporarily slow down the snake
        special_apple = nothing  # Remove the special apple after collision
    end
end

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

# define update function

function update(g::Game)
    # Start the game on the first click
    if !game_started
        return
    end
    if gameover == false
        global snake_body, special_apple, special_apple_timer
        move()
        border()
        collide_head_body()
        collide_head_apple()
        collide_special_apple()  # Check collision with the special apple
        collide_head_obstacles()
        grow()
        popat!(snake_body, 1)
        sleep(delay)
        
        # Special apple logic
        if special_apple !== nothing
            special_apple_timer -= 1
            if special_apple_timer <= 0
                special_apple = nothing  # Remove special apple after timer expires
            end
        elseif rand() < 0.01  # 1% chance per update to spawn a special apple
            spawn_special_apple()
            special_apple_timer = special_apple_duration * 10  # Convert seconds to update ticks
        end
    else
        # Jouer le son de Game Over une seule fois
        global gameover_sound_played
        if !gameover_sound_played
           play_sound("gameOver")  # Joue le fichier `gameover.ogg`
            gameover_sound_played = true
        end
    end
end

# define keyboard interaction

function direction(x, y)
    global vx, vy
    vx = x
    vy = y
end

right() = direction(speed, 0)
left() = direction(-speed, 0)
down() = direction(0, speed)
up() = direction(0, -speed)

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

# define reset function

function reset()
    # reset all global variables

    global snake_head, snake_body, obstacles, score, high_score, level, delay, gameover, special_apple, gameover_sound_played
    # Update high score
    if score > high_score
        high_score = score
    end

    snake_head = Rect(
        snake_pos_x, snake_pos_y, snake_size, snake_size
    )
    snake_body = []
    grow()

    apple_pos_x, apple_pos_y = spawn()
    apple.x, apple.y = apple_pos_x, apple_pos_y

    special_apple = nothing  # Reset special apple

    obstacles = []
    score = 0
    level = 1
    delay = 0.2
    gameover = false
    gameover_sound_played = false
     gameover_sound_played = false

end

# define mouse interaction

function on_mouse_down(g::Game)
    global game_started
    if !game_started
        # Si le jeu n'a pas commencé, démarrer le jeu
        game_started = true
    elseif gameover == true
        reset()
    end
end

# Fonction pour dessiner l'écran de Game Over
function draw_game_over_screen()
    # Fond de l'écran
    draw(Rect(0, 0, WIDTH, HEIGHT), colorant"black", fill = true)
    
    # Texte du Game Over
    game_over_title = TextActor("GAME OVER", "comicbd"; font_size = 48, color = Int[255, 0, 0, 255])
    game_over_title.pos = (WIDTH / 2 - 150, HEIGHT / 2 - 50)
    draw(game_over_title)
    
    # Texte pour indiquer de cliquer pour recommencer
    restart_message = TextActor("Klicke zum Neustart.", "comicbd"; font_size = 24, color = Int[200, 200, 200, 255])
    restart_message.pos = (WIDTH / 2 - 130, HEIGHT / 2 + 20)
    draw(restart_message)
end