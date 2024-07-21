SOURCE = $(wildcard *.erl)
OBJS = $(patsubst %.erl,%.beam,$(SOURCE))
	
EBIN_DIR = ./
ERLC = erlc -DRELEASE  -W -o ${EBIN_DIR} 
%.beam:%.erl
	${ERLC} $<

all:compile

debug: ERLC = erlc +debug_info -W -o ${EBIN_DIR} 
debug: compile
	
compile:$(OBJS)

clean:
	rm *.beam
