SOURCE = $(wildcard *.erl)
OBJS = $(patsubst %.erl,%.beam,$(SOURCE))
	
EBIN_DIR = ../ebin
INCLUDE_DIR = ../include
ERLC = erlc  -DRELEASE  -W -o ${EBIN_DIR} -I ${INCLUDE_DIR}
%.beam:%.erl
	${ERLC} $<


ERL = erl -boot start_clean

all:compile

debug: ERLC = erlc +debug_info -W -o ${EBIN_DIR} -I ${INCLUDE_DIR}
debug: compile

compile:$(OBJS)
	make -C Mysql
clean:
	rm -rf ${EBIN_DIR}/*.beam


