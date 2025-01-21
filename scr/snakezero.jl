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
