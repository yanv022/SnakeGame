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
