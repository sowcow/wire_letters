# calculates how much letter instances simpler letters account for in text according to wiki
# => >80% 

text = DATA.read
xs = text.lines.select { |x| x =~ /^\w/ }
xs = xs.map { |x| x[/\d+(\.\d+)?/] }
p xs.map { |x| x.to_f }.reduce(:+)


__END__
E 	12.7% 	
 
	11% 	
 
T 	9.1% 	
 
	6.7% 	
 
A 	8.2% 	
 
	7.8% 	
 
O 	7.5% 	
 
	6.1% 	
 
I 	7% 	
 
	8.6% 	
 
N 	6.7% 	
 
	7.2% 	
 
S 	6.3% 	
 
	8.7% 	
 
H 	6.1% 	
 
	2.3% 	
 
R 	6% 	
 
	7.3% 	
 
D 	4.3% 	
 
	3.8% 	
 
L 	4% 	
 
	5.3% 	
 
C 	2.8% 	
 
	4% 	
 
U 	2.8% 	
 
