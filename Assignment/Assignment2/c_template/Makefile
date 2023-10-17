simulator: checkpoints.o main.o simulator.o
	g++ -std=c++11 checkpoints.o main.o simulator.o -o simulator

checkpoints.o: checkpoints.cpp simulator.h
	g++ -std=c++11 -c checkpoints.cpp -o checkpoints.o
main.o: main.cpp simulator.h
	g++ -std=c++11 -c main.cpp -o main.o
simulator.o:simulator.cpp simulator.h
	g++ -std=c++11 -c simulator.cpp -o simulator.o

.PHONY: clean
clean: 
	del *.o simulator
