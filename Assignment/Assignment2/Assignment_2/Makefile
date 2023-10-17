objects = main.o LabelTable.o phase1.o phase2.o simulator.o util.o

cc = g++

simulator : $(objects)
		$(cc) -o simulator $(objects)

debug : $(objects)
		$(cc) -o simulator $(objects) -g

main.o : main.cpp simulator.h
		$(cc) -c main.cpp

simulator.o : simulator.cpp simulator.h
		$(cc) -c simulator.cpp

LabelTable.o : LabelTable.cpp LabelTable.h
		$(cc) -c LabelTable.cpp

phase1.o : phase1.cpp LabelTable.h util.h
		$(cc) -c phase1.cpp

phase2.o : phase2.cpp LabelTable.h util.h
		$(cc) -c phase2.cpp

util.o : util.cpp util.h
		$(cc) -c util.cpp

clean :
		rm simulator $(objects)