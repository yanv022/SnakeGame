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

