md = ''

md << '<style>'
md << File.read('css.css')
md << '</style>'
md << ?\n
md << ?\n

md << File.read('Iliad.md')

require 'kramdown'

doc = Kramdown::Document.new md
puts html = doc.to_html
File.write 'Iliad.html', html
