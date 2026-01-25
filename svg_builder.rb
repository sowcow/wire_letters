require 'json'

class SVGBuilder
  attr_accessor :pen

  def initialize commands, viewBox, data
    @data = data
    @commands = commands
    @viewBox = viewBox
    @paths = []
    @circles = []
    process_commands
  end
  
  def process_commands
    path_data = []
    
    @commands.each do |command|
      case command[0]
      when "M", "L", "C", "Z"
        if command[0] == "M"
          path_data << "M #{format_point(command[1][0])}"
        elsif command[0] == "L"
          path_data << "L #{format_point(command[1][0])}"
        elsif command[0] == "C"
          points = command[1].map { |pt| format_point(pt) }
          path_data << "C #{points.join(' ')}"
        elsif command[0] == "Z"
          path_data << "Z"
        end
      when "O"
        # Save circle separately if we want to use circle elements
        center = command[1][0]
        radius = command[1][1]
        @circles << { center: center, radius: radius }
        # Also add to path as a circle arc
        path_data << circle_to_path_data(center, radius)
      end
    end
    
    @paths << path_data.join(' ') unless path_data.empty?
  end
  
  def to_svg
    elements = []
    
    # Add path elements
    @paths.each do |path_data|
      elements << %(<path d="#{path_data}" fill="none" stroke="black" stroke-width="#@pen"/>)
    end
    
    # Add circle elements (using actual circle elements for better SVG)
    @circles.each do |circle|
      elements << %(<circle cx="#{circle[:center][0]}" cy="#{circle[:center][1]}" r="#{circle[:radius]}" 
                     fill="none" stroke="black" stroke-width="#@pen"/>)
    end
    
    <<~SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="#{@viewBox}" stroke-linejoin="round" stroke-linecap="round">
  <desc>
#{JSON.pretty_generate(@data)}
  </desc>
  #{elements.join("\n  ")}
</svg>
    SVG
  end
  
  private
  
  def format_point(point)
    "#{point[0]},#{point[1]}"
  end
  
  def circle_to_path_data(center, radius)
    cx, cy = center
    start_x = cx - radius
    "M #{start_x},#{cy} a #{radius},#{radius} 0 1,0 #{radius * 2},0 a #{radius},#{radius} 0 1,0 #{-radius * 2},0"
  end
end
