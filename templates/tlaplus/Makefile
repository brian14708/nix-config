SPEC ?= Main
CONFIG ?=
STEPS ?= 20

TLC = tlc
PCAL = pcal

.PHONY: check sim pcal clean

check:
	$(TLC) -deadlock -workers 4 $(if $(CONFIG),-config $(CONFIG),) $(SPEC)

sim:
	$(TLC) -simulate num=$(STEPS) $(if $(CONFIG),-config $(CONFIG),) $(SPEC)

pcal:
	$(PCAL) $(SPEC).tla

clean:
	rm -rf states *.out *.tlc* MC.out *_TTrace_*
