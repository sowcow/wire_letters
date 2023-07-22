END{
if __FILE__ == $0
  c = DrawContext.new
  c.draw 'Wire Letters', wire: false
  c.next_line
  c.draw 'Wire Letters', latin: false
  c.next_line
  c.draw ' '
  c.next_line
  c.draw 'new Alphabet', latin: false
  c.next_line
  c.draw 'new Alphabet', wire: false
  c.render 'intro.png'

  c = DrawContext.new
  c.draw [*?a..?z].join()
  c.render 'Alphabet.png'

  c = DrawContext.new
  c.draw "A e o u i"
  c.render 'vowels.png'

  c = DrawContext.new
  c.draw "lh dT nc rs"
  c.render 'common_consonants.png'

  c = DrawContext.new
  c.draw "ZXJQ"
  c.render 'rare_consonants.png'

  c = DrawContext.new
  c.draw "m w p b"
  c.next_line
  c.draw "  v f  "
  c.next_line
  c.draw "  y k g"
  c.render 'asymmetric_consonants.png'

  c = DrawContext.new
  c.draw "ndf mnpfks"
  c.next_line
  c.draw "ctv bcwvyrg"
  c.render 'confusions.png'

  # naming is hard
  #c = DrawContext.new
  #c.draw "new spinning wire script"
  #c.draw "new twisted wire alphabet"
  #c.draw "new twisted wire font"
  #c.draw "new twisted wire script"
  #c.render 'title.png'
end
}


# rename dx -> x (already)

class DrawContext

  def draw_missing
    draw_space
  end

  def draw_space
    move dx: 1
  end

  # = alphabet

  # == vowels

  def draw_a
    ratiox = 1
    ratioy = 1
    curve [
      { x: vx/2 * ratiox },
      { y: -vy*ratioy, x: vx/2 },
      { y: -vy, x: vx/2 },
    ]
    curve [
      { y: -vy*ratioy, x: vx/2 },
      { x: vx - vx/2 * ratiox },
      { x: vx },
    ]
    move_cursor
  end

  def draw_i
    ratiox = 1
    ratioy = 1
    curve [
      { x: vx/2 * ratiox },
      { y: +vy*ratioy, x: vx/2 },
      { y: +vy, x: vx/2 },
    ]
    curve [
      { y: +vy*ratioy, x: vx/2 },
      { x: vx - vx/2 * ratiox },
      { x: vx },
    ]
    move_cursor
  end

  def draw_o
    r = vx / 2

    line dx: 2*r
    move_cursor

    # after cursor have moved 2*r distance by x:
    right = Point[0 * @dx_scale, 0]
    left = Point[-r*2 * @dx_scale, 0]

    @rendering << "A 1,1, 0 0,0 #{@point + left} A 1,1 0 1,0 #{@point + right}" if @show_wire
    #
    # cursor is already in the place! (right point, relative 0,0)
  end

  def draw_e
    # all points are relative to the initial point I'd have it => absolute numbers in actual exucution
    ratiox = 1.5
    ratioy = 0.5
    curve [
      { y: -vy * ratioy },
      { y: -vy, x: vx * ratiox },
      { y: -vy },
    ]
    curve [
      { x: -vx * ratiox, y: -vy },
      { y: -vy * ratioy },
      { },
    ]
    move_cursor
  end

  def draw_u
    ratiox = 1.5
    ratioy = 0.5
    curve [
      { y: +vy * ratioy },
      { y: +vy, x: vx * ratiox },
      { y: +vy },
    ]
    curve [
      { x: -vx * ratiox, y: +vy },
      { y: +vy * ratioy },
      { },
    ]
    move_cursor
  end

  # == rare consonants
  
  def draw_x
    line dx: cx, dy: cy
    line dx: 0, dy: cy
    line dx: cx, dy: 0
    move_cursor
  end
  def draw_z
    line dx: cx, dy: -cy
    line dx: 0, dy: -cy
    line dx: cx, dy: 0
    move_cursor
  end
  def draw_q
    line dx: 0, dy: cy
    line dx: cx, dy: cy
    line dx: cx, dy: 0
    move_cursor
  end
  def draw_j
    line dx: 0, dy: -cy
    line dx: cx, dy: -cy
    line dx: cx, dy: 0
    move_cursor
  end

  # == simple symmetrical consonants
  
  def draw_h
    draw_l
  end
  def draw_l
    line dx: cx
    move_cursor
  end

  def draw_d
    line dx: cx*0.5, dy: -cy
    line dx: cx
    move_cursor
  end
  def draw_t
    line dx: cx*0.5, dy: cy
    line dx: cx
    move_cursor
  end

  def draw_n ratiox: 0.1, yy: 1
    curve [
      { y: -cy * yy },
      { y: -cy * yy, x: 0.5*(1-ratiox)*cx },
      { x: 0.5*cx, y: -cy * yy },
    ]
    curve [
      { y: -cy * yy, x: 0.5*cx*(1 + ratiox) },
      { y: -cy * yy, x: cx },
      { x: cx },
    ]
    move_cursor
  end

  def draw_c
    draw_n yy: -1
  end

  def draw_s ratiox: 0.5, ratio2x: 1.5, yy: 1
    curve [
      { x: cx * ratiox },
      { y: -cy * yy, x: cx * ratio2x },
      { x: 0.5*cx, y: -cy * yy },
    ]
    curve [
      { y: -cy * yy, x: cx * (1 - ratio2x) },
      { x: cx * (1 - ratiox) },
      { x: cx },
    ]
    move_cursor
  end

  def draw_r
    draw_s yy: -1
  end

  # == assymetrical composition (with line) letters
  
  # === teeth letters
  #
  def draw_v ratiox: 1, ratioy: 0.7
    curve [
      { x: 0.5*cx * ratiox, y: 0.5*cy * ratioy },
      { x: 0.5*cx * ratiox, y: cy - 0.5*cy * ratioy },
      { y: cy },
    ]
    line dx: cx
    move_cursor
  end

  def draw_f ratiox: 1, ratioy: 0.7
    line dx: cx, dy: -cy
    move_cursor
    curve [
      { x: -0.5*cx * ratiox, y: 0.5*cy * ratioy },
      { x: -0.5*cx * ratiox, y: cy - 0.5*cy * ratioy },
      { y: cy },
    ]
    move_cursor
  end

  # === lips letters (expected to be more round and not having two corners for sure - this may slow down as I assume)
  #
  def draw_p yy: 1, ratio: 0.1
    curve [
      { y: -cy * ratio * yy },
      { y: -cy * yy },
      { x: cx, y: -cy * yy },
    ]
    curve [
      { x: cx, y: -cy * yy },
      { x: cx, y: -cy * ratio * yy },
      { x: 0.25*cx },
    ]
    line dx: cx
    move_cursor
  end

  def draw_b
    draw_p yy: -1
  end

  def draw_m yy: 1, ratio: 0.1
    line dx: 0.75*cx
    curve [
      { x: 0.75*cx, y: -cy * ratio * yy },
      { x: 0, y: -cy * ratio * yy },
      { x: 0, y: -cy * yy },
    ]
    curve [
      { x: cx, y: -cy * yy },
      { x: cx, y: -cy * ratio * yy },
      { x: cx },
    ]
    move_cursor
  end

  def draw_w
    draw_m yy: -1
  end

  def draw_k yy: 1
    line dx: cx, dy: -cy * yy
    curve [
      { y: -cy * yy },
      { x: 0 },
      { x: cx },
    ]
    move_cursor
  end

  def draw_g
    draw_k yy: -1
  end

  def draw_y
    curve [
      { x: cx },
      { y: cy, x: cx },
      { y: cy },
    ]
    line dx: cx
    move_cursor
  end

  # ===
  
  # vowel dx
  def vx
    0.2
  end

  # vowel dy
  def vy
    2.0
  end

  def cx
    1
  end
  def cy
    1
  end

  def vowel_step ratio=1
    line dx: vx * ratio
  end

  # wire - show this alhpabet, latin - show latin writing
  def draw string, wire: true, latin: true
    string.chars.each { |x|
      name = "draw_#{to_name x}"
      @used_starts << @point.dup
      prev_point = @point
      @show_wire = wire
      if respond_to? name
        send name
      else
        draw_missing
      end
      drawn_letter x, prev_point, @point if latin
      @used_ends << @point.dup
    }
  end

  def drawn_letter letter, a, b
    mid = Point[(a.x + b.x) / 2, (a.y + b.y) / 2]
    mid.x -= @pointsize * 0.25
    @naming << %| -draw "text #{mid} '#{letter}'" |
  end

  def initialize dx: 100, dy: 100, pointsize: 50
    @dx_scale = dx
    @dy_scale = dy
    @pointsize = pointsize
    @line = 0

    # gap is like margin but is from baseline and not letters boundaries so it's size is bigger than the biggest letter dimension
    @gap = [dx, dy].max * 2 + 10

    @used_starts = []
    @used_ends = []
    @rendering = []
    @naming = []
    next_line 0
  end

  def next_line line=@line+1
    @line = line
    @point = Point[@gap, @gap + @line*@gap]
    move dx: 0, dy: 0
  end

  def move dx: 0, dy: 0
    dx *= @dx_scale
    dy *= @dy_scale

    p = @point + [dx, dy]
    @rendering << "M #{p}"

    @point = p
  end

  def line dx: 0, dy: 0, absx: nil, absy: nil
    dx *= @dx_scale
    dy *= @dy_scale

    dx = absx unless absx.nil?
    dy = absy unless absy.nil?

    p = @point + [dx, dy]
    @rendering << "L #{p}" if @show_wire

    @latest_point = p
  end

  def move_cursor
    @point = @latest_point
  end

  def curve xs
    (a, b, c) = xs
    scale = -> point { Point[point.x * @dx_scale, point.y * @dy_scale] }

    a = @point + scale[Point.from a]
    b = @point + scale[Point.from b]
    c = @point + scale[Point.from c]

    @latest_point = c
    @rendering << "C #{a} #{b} #{c}" if @show_wire
  end

  def arc dx: 0, dy: 0
    line dx: dx, dy: dy
  end

  def to_name letter
    return 'space' if letter == ' '
    return letter.downcase
  end

  def render file, names: true, latin: 'orange'
    width = @used_ends.map { |x| x.x }.max + @gap
    height = @used_ends.map { |x| x.y }.max + @gap

    grid = []
    grid.push *@used_starts.uniq.map { |point|
      a = point.with x: 0
      b = point.with x: width
      %|-draw "polyline #{a} #{b}"|
    }

    # imagemagick does not like multiple M's at the start
    while @rendering.count > 1 && @rendering[0] =~ /^M/ && @rendering[1] =~ /^M/
      @rendering.shift
    end

    draw = <<-END.strip.lines.map(&:strip).join(' ')
      -draw "path '
        #{ @rendering * ' ' }
      '"
    END
    draw = '' if @rendering.empty?

    color = latin
    naming = %'-font Courier -pointsize #@pointsize -strokewidth 0 -stroke #{color} -fill #{color} #{@naming * ' '}'

    system <<-END.strip.lines.map(&:strip).join(' ')
      convert
      -size #{width}:#{height} xc:white
      -fill none
      -stroke gray
      -strokewidth 1
      #{grid * ' '}
      -stroke navy
      -strokewidth 5
      #{draw}
      #{names && naming}
      #{file.inspect}
    END
  end

  Point = Struct.new :x, :y do
    def self.from given
      return Point[given[:x] || 0, given[:y] || 0] if given.is_a? Hash
      Point[*given]
    end

    def to_s
      [x,y] * ?,
    end

    def + other
      other = Point[*other] if other.kind_of? Array
      Point[x + other.x, y + other.y]
    end

    def - other
      other = Point[*other] if other.kind_of? Array
      Point[x - other.x, y - other.y]
    end

    def / number
      Point[x / number, y / number]
    end

    def with x: nil, y: nil
      if x && y
        raise ArgumentError
      elsif x
        Point[x, self.y]
      elsif y
        Point[self.x, y]
      else
        raise ArgumentError
      end
    end
  end

end
