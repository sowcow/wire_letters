require_relative 'draw'

desc 'stdin text -> print.png'
task :print do
  lines = STDIN.read.lines.map(&:chomp)
  p lines

  c = DrawContext.new
  lines.each { |x|
    c.draw x, latin: false
    c.next_line
    c.draw x, wire: false
    c.next_line
  }
  c.render 'print.png'
end
