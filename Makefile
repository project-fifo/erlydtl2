REBAR=./rebar3 $(REBAR_ARGS)
REBAR2=./rebar $(REBAR_ARGS)

all: compile

compile: check-slex
	@$(REBAR) compile

check-slex: src/erlydtl_scanner.erl
src/erlydtl_scanner.erl: src/erlydtl_scanner.slex
	@echo Notice: $@ is outdated by $<, consider running "'make slex'".

.PHONY: tests
tests: src/erlydtl_parser.erl
	@$(REBAR) eunit

check: tests dialyze

## dialyzer
.PHONY: dialyze
dialyze: compile
	@$(REBAR) dialyzer

## In case you are missing a plt file for dialyzer,
## you can run/adapt this command
clean:
	@$(REBAR2) -C rebar-slex.config clean
	rm -fv erl_crash.dump

really-clean: clean
	rm -f $(PLT_FILE)

# rebuild any .slex files as well..  not included by default to avoid
# the slex dependency, which is only needed in case the .slex file has
# been modified locally.
slex: REBAR_DEPS ?= get-deps update-deps
slex: slex-compile

slex-skip-deps: REBAR_DEPS:=
slex-skip-deps: slex-compile

slex-compile:
	@$(REBAR2) -C rebar-slex.config $(REBAR_DEPS) compile

shell:
	@$(REBAR) shell


# this file must exist for rebar eunit to work
# but is only built when running rebar compile
src/erlydtl_parser.erl: compile
