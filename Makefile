CFLAGS=-Wall -O2 -g -mmacos-version-min=14.4
LDFLAGS=-mmacos-version-min=14.4

FRAMEWORKS=-framework CoreML -framework Foundation
TARGETS=coreml_profiling

all: ${TARGETS}

coreml_profiling: coreml_profiling.o
	${CC} -o $@ $^ $(LDFLAGS) ${FRAMEWORKS} ${LIBS}

clean: coreml_profiling.o coreml_profiling
	${RM} $^
