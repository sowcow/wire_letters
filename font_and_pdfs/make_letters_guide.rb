md = ''

md << '<style>'
md << File.read('css.css')
md << '</style>'
md << ?\n

Dir['by_letters/*'].each { |x|
  letter = File.basename(x).chars.first
  words = File.read(x).lines.map(&:strip).select { |x| x != '' }.uniq

  md << "# #{letter.upcase}: #{letter}"
  md << ?\n
  md << ?\n
  words.each_with_index { |w, i|
    md << "| <span class='skip-font'>#{w}</span> | #{w} |"
    md << ?\n
  }

  guess_counter ||= 0

  words.each_slice(4) { |xs|
    mixed = xs.shuffle

    md << ?\n
    md << '---'
    md << ?\n
    md << ?\n

    if guess_counter == 0
      md << "<span class='skip-font'>link correct pairs:</span>"
      md << ?\n
      md << ?\n
    end

    guess_counter += 1

    xs.shuffle.each_with_index { |w, i|
      other = mixed[i]
      md << "| #{other} | <span class='skip-font'>~#{w}</span> |"
      md << ?\n
    }
  }

  md << ?\n
}

puts md

require 'kramdown'

doc = Kramdown::Document.new md
puts html = doc.to_html
File.write 'guide.html', html
