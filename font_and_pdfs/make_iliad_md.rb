require 'json'
require 'any_ascii'

text = File.read 'Iliad.json'
xs = JSON.load text

text = xs.map { |x|
  text = AnyAscii.transliterate x['part']
  unless text =~ /#/
    text.downcase!
  end
  text
}.join

File.write 'Iliad.md', text
