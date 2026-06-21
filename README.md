# myexpos

A toy operating system built from scratch as part of the **eXpOS** lab roadmap (NITC OS lab). This repo contains my implementation through **Stage 27**, covering everything from bootstrapping and paging to interrupts, multiprogramming, virtual memory, the shell, and a working filesystem.

> This is a personal/academic project. The simulator (XSM), the two language compilers (SPL, ExpL), and the disk interface tool (XFS-Interface) were provided as base scaffolding by the course. The OS kernel itself, written in SPL is my own work, built incrementally by following the [eXpOS Roadmap](https://exposnitc.github.io/Roadmap.html).

## What is eXpOS?

eXpOS is a teaching OS designed to run on a simulated machine rather than real hardware, so the focus stays more on core OS concepts. The stack looks like this:

- **XSM** (eXperimental String Machine) — a simulated CPU + memory + disk, with its own assembly language and a paging MMU. This is the "hardware" the OS runs on.
- **SPL** (Systems Programming Language) — a thin high-level layer over XSM assembly (if/while, aliases for registers, module calls). The kernel is written in SPL.
- **ExpL** — a proper high-level application language (functions, types, dynamic memory) used to write user-space test programs that run on top of the kernel.
- **XFS-Interface** — a CLI tool that loads compiled code and data files from the host Linux machine into the simulated disk (`disk.xfs`), in the eXpFS on-disk format the kernel understands.

More background: [eXpOS docs](https://exposnitc.github.io/documentation.html) · [Roadmap](https://exposnitc.github.io/Roadmap.html) · [org](https://github.com/orgs/eXpOSNitc/repositories)

## Repo layout

```
expl/             ExpL compiler (lex/yacc) — provided base tool
spl/              SPL compiler (lex/yacc) — provided base tool
xsm/              XSM machine simulator + debugger — provided base tool
xfs-interface/    Disk loader CLI + per-stage disk_setup scripts
progress/         My kernel source (.spl) and test programs (.expl), one folder per stage
scripts/          Helper script that rebuilds all programs referenced by a disk_setup file
Makefile          Top-level build/run orchestration
```

The kernel itself (boot module, scheduler, interrupt/exception handlers, resource manager, memory manager, device manager, shell, system call implementations) lives under `progress/`, organized by the stage in which each piece was introduced or revised.

## What's implemented (through Stage 27)

Built incrementally, each stage adding to the last:

- Bootstrap loading and the ABI/XEXE executable format
- Paging-based virtual memory and address translation
- Timer interrupts and a Round Robin scheduler
- Kernel/user stack separation, process table, page table management
- Modular kernel design (boot, scheduler, resource manager, device manager, memory manager, etc.)
- Disk I/O with interrupt-driven device handling
- Exception handling
- System calls (console I/O, file I/O, process management) via the eXpOS library/ABI
- A working filesystem (eXpFS) with create/delete/open/read/write
- A primitive shell running as a user process

See the [Roadmap](https://exposnitc.github.io/Roadmap.html) for what each stage covers in detail.

## Building and running

**Prerequisites:** GCC, Flex/Lex, Bison/Yacc, Make.

From the repo root:

```bash
make            # builds xsm, xfs-interface, spl, and expl
make run        # compiles all kernel/test programs, loads the disk, and starts the simulator
```

`make run` is the one command that does everything: it (re)compiles any `.spl`/`.expl` source that's out of date, loads the resulting binaries onto the simulated disk via `xfs-interface` according to the current stage's `disk_setup_*.txt` script, and boots the XSM simulator.

Useful variants:

```bash
make run FLAGS="--timer 50"   # run with timer interrupts enabled at a given interval
make run FLAGS="--debug"      # run with the XSM debugger attached
make reload                   # force a fresh disk load without recompiling
make recompile                # force recompilation of all programs, then reload and run
make clean                    # clean build artifacts in all subdirectories
```

The Makefile tracks progress with stamp files (`.programs_built`, `.disk_loaded_s27`) so repeated `make run` calls are fast — only changed sources get rebuilt.

## Notes

- `disk.xfs` (the simulated hard disk) is rebuilt from the `xfs-interface/disk_setup_s27.txt` script, which loads the latest version of every kernel module and user program in the right order.
- Earlier stages' kernel sources are kept in `progress/stage <N>/` for reference. They are not part of the final build, but they show the incremental design as each OS subsystem was added.
- This was built solo for a university OS lab; it's meant as a learning reference, not production code.
