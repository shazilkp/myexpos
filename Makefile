DISK_SETUP := xfs-interface/disk_setup_s25.txt
PROGRAMS_STAMP := .programs_built
LOAD_STAMP := .disk_loaded_s25

.PHONY: all clean run programs

all: xsm-build xfs-build spl-build expl-build

# -------------------------------
# Build subdirectories only if needed
# -------------------------------
expl-build:
	$(MAKE) -C expl

spl-build:
	$(MAKE) -C spl

xfs-build:
	$(MAKE) -C xfs-interface

xsm-build:
	$(MAKE) -C xsm

# -------------------------------
# Programs (stamp file)
# -------------------------------
$(PROGRAMS_STAMP): $(DISK_SETUP)
	./scripts/build_programs.sh
	touch $(PROGRAMS_STAMP)

programs: $(PROGRAMS_STAMP)

# -------------------------------
# Load disk (stamp file)
# -------------------------------
$(LOAD_STAMP): $(DISK_SETUP) $(PROGRAMS_STAMP)
	cd xfs-interface && ./xfs-interface < disk_setup_s25.txt
	touch $(LOAD_STAMP)

# -------------------------------
# Run simulator (always)
# -------------------------------
run: $(LOAD_STAMP)
	cd xsm && ./xsm $(FLAGS)

# -------------------------------
# Clean everything
# -------------------------------
clean:
	$(MAKE) -C expl clean
	$(MAKE) -C spl clean
	$(MAKE) -C xfs-interface clean
	$(MAKE) -C xsm clean
	rm -f $(PROGRAMS_STAMP) $(LOAD_STAMP)

.PHONY: reload recompile
reload:
	rm -f $(LOAD_STAMP)
	$(MAKE) run

recompile:
	rm -f $(PROGRAMS_STAMP)
	$(MAKE) run