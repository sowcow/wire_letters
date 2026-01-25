require_relative 'wire_letters/draw'

scale = 10
side = 100*scale
pen = 5*scale

[*?a..?z].each { |letter|
  c = DrawContext.new dx: side, dy: side, pen: pen, gap: 0
  c.no_grid!
  c.next_line 0
  c.draw letter, latin: false
  file = "letters/#{letter}.svg"
  c.svg_render file

  if letter == ?o
    text = File.read file
    text.sub! /L [\d\.\,]+/, ''
    File.write file, text
  end
}
