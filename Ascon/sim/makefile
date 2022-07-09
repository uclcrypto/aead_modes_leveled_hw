CC = iverilog
FLAGS =-Wall -Winfloop
LIB_DPA = ../src/lib/ascon_dpa
LIB_SPA = ../src/lib/ascon_spa
LIB_V = ../src/lib/lib_v
PATH_CIPHER = ../src/cipher.v
PATH_TB = ../src/tb.v
all:
	$(CC) $(FLAGS) -y $(LIB_DPA) -y $(LIB_V) -y $(LIB_SPA) -o ascon $(PATH_CIPHER) $(PATH_TB)
	vvp ascon
	gtkwave waveform.vcd config.gtkw
clean:
	rm -rf *.vcd
	rm ascon
sim: 
	$(CC) $(FLAGS) -y $(LIB_DPA) -y $(LIB_V) -y $(LIB_SPA) -o ascon $(PATH_CIPHER) $(PATH_TB)
	vvp ascon
testing:
	$(CC) $(FLAGS) -y $(LIB_DPA) -y $(LIB_V) -y $(LIB_SPA) -o ascon $(PATH_CIPHER) $(PATH_TB)
	vvp ascon
	gtkwave waveform.vcd config.gtkw