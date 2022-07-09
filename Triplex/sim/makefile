CC = iverilog
FLAGS =-Wall -Winfloop
LIB_DPA = ../src/lib/Skinny_DPA
LIB_SPA =  ../src/lib/Skinny_SPA
LIB_V =  ../src/lib/lib_v
PATH_CIPHER = ../src/cipher.v
PATH_TB = ../src/tb.v
all:
	$(CC) $(FLAGS) -y $(LIB_DPA) -y $(LIB_V) -y $(LIB_SPA) -o triplex $(PATH_CIPHER) $(PATH_TB)
	vvp triplex
	gtkwave waveform.vcd config.gtkw
clean:
	rm -rf *.vcd
	rm triplex
sim: 
	$(CC) $(FLAGS) -y $(LIB_DPA) -y $(LIB_V) -y $(LIB_SPA) -o triplex $(PATH_CIPHER) $(PATH_TB)
	vvp triplex
testing:
	$(CC) $(FLAGS) -y $(LIB_DPA) -y $(LIB_V) -y $(LIB_SPA) -o triplex $(PATH_CIPHER) $(PATH_TB)
	vvp triplex
	gtkwave waveform.vcd config.gtkw
question:
	$(CC) $(FLAGS) -y $(LIB_DPA) -y $(LIB_V) -y $(LIB_SPA) -o triplex $(PATH_CIPHER) $(PATH_TB)
	vvp triplex
	gtkwave waveform.vcd question1.gtkw