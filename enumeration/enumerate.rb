step = 100
gap = 25
$pen = 10
$width = 200 + gap*2
$height = 200 + gap*2

used = %w[
0-0
1-1
2-12
2-15
2-25
2-37
2-38
2-40
2-3
2-35
].map { |x| "#{x}.png" }

duplicates = %w[
2-1
2-28
2-0
2-2
2-9
2-14
2-20
2-22
2-36
2-39
].map { |x| "#{x}.png" }

points = 3.times.map { |y|
  3.times.map { |x|
    Point[x * step + gap, (y * step + gap)]
  }
}.flatten

$start = points[0]
$finish = points[2]
$ceiling = points.select { |p| p.y == points[6].y }

grid_paths = points.combination(2).to_a
$draw_grids = grid_paths.map { |x| to_draw x }

# - if points present then at least one is at the ceiling (=> same height of letters)
# - auto-start at start
# - auto-finish at finish

system 'rm *.png'
(0..2).each { |len|
  points.permutation(len)
    .select { |xs| xs.length == 0 || xs.find { |x| $ceiling.include?(x) }}
    .each_with_index { |xs, i|
    path = make_path xs
    file = "#{len}-#{i}.png"
    next if duplicates.include? file
    draw path, file, used.include?(file)
  }
}
files = Dir['*.png'].sort_by { |x| x.scan(/\d+/).map &:to_i } * ' '
system %'montage #{files} ../enumeration.png'

BEGIN {
  def make_path points
    [$start, *points, $finish]
  end

  def draw path, file, highlight = false
    draw_path = to_draw path

    color = highlight ? '"navy"' : '"rgba(0,128,255, 0.5)"'

    command = <<-END.strip.lines.map(&:strip).join(' ')
      convert
      -size #{$width}:#{$height} xc:white
      -alpha set
      -fill none

      -stroke gray
      -strokewidth 1
      #{$draw_grids * ' '}

      -stroke #{color}
      -strokewidth #{$pen}
      #{draw_path}

      #{file.inspect}
    END

    system command
  end

  def path_to_rendering path
    path.map.with_index { |x, i|
      if i == 0
        "M #{x}"
      else
        "L #{x} M#{x}"
      end
    }
  end

  def to_draw path
  <<-END.strip.lines.map(&:strip).join(' ')
    -draw "path '
      #{ path_to_rendering(path) * ' ' }
    '"
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
}
