require 'base64'

font = Dir['*.otf'].first
font_name = File.basename font, '.otf'

font_data = File.binread font
base64_font = Base64.strict_encode64(font_data)

css = DATA.read % { base64_font: base64_font, font_name: font_name }

File.write 'css.css', css


__END__
@font-face {
  font-family: '%{font_name}';
  src: url(data:font/opentype;base64,%{base64_font}) format('opentype');
  font-weight: normal;
  font-style: normal;
}

html, body, * {
  margin: 0;
  padding: 0;
}

body * {
  /* font baseline accounting for */
  line-height: 10em;
  margin: 1px;
  white-space: pre-wrap;

  font-family: '%{font_name}', sans-serif;
  font-size: 16px;
}

*:not(.skip-font) {
  font-family: '%{font_name}', sans-serif;
  font-size: 16px;
}
.skip-font {
  font-family: monospace;
}

