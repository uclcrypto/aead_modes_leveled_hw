CC = iverilog
FLAGS =-Wall -Winfloop
LIB_DPA = ../src/DPA
LIB_V = ../src/lib_v
LIB = ../src/mode
PATH_CIPHER = ../src/mode/cipher.v
PATH_TB = ../src/mode/tb.v
all:
	$(CC) $(FLAGS) -y $(LIB_DPA) -y $(LIB_V) -y $(LIB) -o romulus-n $(PATH_CIPHER) $(PATH_TB)
	vvp romulus-n
	gtkwave waveform.vcd config.gtkw
clean:
	rm -rf *.vcd
	rm romulus-n
sim: 
	$(CC) $(FLAGS) -y $(LIB_DPA) -y $(LIB_V) -y $(LIB) -o romulus-n $(PATH_CIPHER) $(PATH_TB)
	vvp romulus-n
testing:
	$(CC) $(FLAGS) -y $(LIB_DPA) -y $(LIB_V) -y $(LIB) -o romulus-n $(PATH_CIPHER) $(PATH_TB)
	vvp romulus-n
	gtkwave waveform.vcd config.gtkw
