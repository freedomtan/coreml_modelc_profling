CFLAGS=-Wall -O2 -g -mmacos-version-min=14.4
LDFLAGS=-mmacos-version-min=14.4

FRAMEWORKS=-framework CoreML -framework Foundation
TARGETS=coreml_profiling coreml_profiling_without_compute_plan

all: ${TARGETS}

coreml_profiling: coreml_profiling.o
	${CC} -o $@ $^ $(LDFLAGS) ${FRAMEWORKS} ${LIBS}

coreml_profiling_without_compute_plan: coreml_profiling_without_compute_plan.o
	${CC} -o $@ $^ $(LDFLAGS) ${FRAMEWORKS} ${LIBS}

clean: coreml_profiling.o coreml_profiling coreml_profiling_without_compute_plan coreml_profiling_without_compute_plan.o
	${RM} $^
