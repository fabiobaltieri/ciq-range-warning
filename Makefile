SDK_PATH = $(HOME)/ciq
KEY = developer_key.der

NAME = range-warning
APP_ID = 5a6ad56b-4489-4f8f-a833-e54b7223c3d1

JUNGLE = monkey.jungle
ifeq ($(DEVICE),)
DEVICE = fr955
endif

MONKEYC = $(SDK_PATH)/bin/monkeyc
MONKEYDO = $(SDK_PATH)/bin/monkeydo

.PHONY: all clean sim graph

all: $(NAME).prg

clean:
	rm -f $(NAME)-fit_contributions.json
	rm -f $(NAME)-settings.json
	rm -f $(NAME).iq
	rm -f $(NAME).prg
	rm -f $(NAME).prg.debug.xml

$(NAME).prg: manifest.xml resources/*.xml source/*.mc
	$(MONKEYC) -d $(DEVICE) -f $(JUNGLE) -o $(NAME).prg -y $(KEY)

$(NAME).iq: manifest.xml resources/*.xml source/*.mc
	$(MONKEYC) -e -f $(JUNGLE) -o $(NAME).iq -y $(KEY)

sim: $(NAME).prg
	$(MONKEYDO) $(NAME).prg $(DEVICE)

graph:
	java -jar $(SDK_PATH)/bin/fit-graph.jar

era:
	$(SDK_PATH)/bin/era -k $(KEY) -a $(APP_ID)
