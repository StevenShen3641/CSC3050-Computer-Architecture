simulator: Checkpoints.o main.o Simulator.o
	g++ Checkpoints.o main.o Simulator.o -o simulator

Checkpoints.o: Checkpoints.cpp Checkpoints.h
	g++ -c Checkpoints.cpp -o Checkpoints.o
main.o: main.cpp Simulator.h
	g++ -c main.cpp -o main.o
Simulator.o: Simulator.cpp Simulator.h
	g++ -c Simulator.cpp -o Simulator.o

.PHONY: clean
clean:
	del *.o simulator.exe *.bin
