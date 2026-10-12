# FracST
## Fractional Permission Session Types
This repository contains an implementation of the FracST typechecker and program reconstruction algorithm.

## Installation

### Prerequisites

#### Opam
The instructions for installing opam are available on the [opam installation page](https://opam.ocaml.org/doc/Install.html). Please install the latest version of opam.

##### Configuring Opam
To configure opam for the first time and install a specific version of OCaml, please run the following (skip if you have already configured opam)
```
$ opam init
```

### Installing Dependencies
Clone the repository.
```
$ git clone https://github.com/selenexwu/FracST.git
$ cd FracST
```

Now, we create a local opam switch to contain the necessary dependencies. This will also install the necessary dependencies and build FracST.
```
$ opam update
$ opam switch create . 5.4.1 -y
```

Afterwards, we can make sure `dune` is available at the command-line using
``` 
$ eval $(opam env)
```

### CLOC
To calculate line counts for our test cases, we used the [cloc](https://github.com/AlDanial/cloc) utility. The testing script will print the number of lines of each test case if it is present.

On MacOS, it can be installed via Homebrew with
```
$ brew install cloc
```

Cloc is also available in the package repositories of many common Linux distributions:
``` 
sudo apt install cloc    # Debian, Ubuntu
sudo yum install cloc    # Red Hat, Fedora
sudo dnf install cloc    # Fedora 22 or later
sudo pacman -S cloc      # Arch
```

### Building
To rebuild, simply run the make command at the top-level.
```
$ make
```

### Troubleshooting
1. Sometimes, your `$ make` command may fail with the error "dune: command not found". In this case, try restarting your terminal and running `$ make` again. Or you may need to run `$ eval $(opam env)` in your terminal again unless this command is already in your `.bashrc`.

2. If you get `Error: Library "core" not found` or similar, make sure you created the local switch with `opam switch create . 5.5.1 -y`, as this installs the necessary dependencies for FracST.

3. Sometimes, `$ opam upgrade` can fail with the following error particularly on Linux machines.
```
The packages you requested declare the following system dependencies. Please
make sure they are installed before retrying:
    m4
```
Please make sure you install `m4`. On Ubuntu machines, this simply amounts to running the command `$ sudo apt install m4`.

### Testing
To tests whether your installation works, run the following command to typecheck a basic example:
``` 
$ ./_build/default/bin/fracst.exe -v 2 -s implicit tests/implicit/nat.frac
```

If everything is working correctly, you should see the typechecking time printed to the console.

## Test Cases

The following tests from the `tests` directory represent the examples from Table 1 of the paper, with the implicit (with program reconstruction) versions in the `implicit` subdirectory and the explicit (without program reconstruction) versions in the `explicit` subdirectory.

- Stack: `stack.frac`
- Queue: `queue.frac`
- Binary Tree: `tree.frac`
- Copyable Nats: `nat.frac`
- Copyable Bins: `bin.frac`
- Leader Election: `ring_leader.frac`
- MapReduce: `mapreduce.frac`
- Auction: `auction.frac`
- AVL Tree: `avl_tree.frac`

### Running A Test Case
The make command creates an executable for FracST at `_build/default/bin/fracst.exe`.
To typecheck a file with FracST, run
```
$ ./_build/default/bin/fracst.exe <file-path>
```

By default the program reconstruction algorithm doesn't run. In order to tell FracST to use program reconstruction, pass the `-s implicit` flag. 

For example, the following commands typecheck the Stack example without and with program reconstruction respectively:
```
$ ./_build/default/bin/fracst.exe ./tests/explicit/stack.frac
$ ./_build/default/bin/fracst.exe -s implicit ./tests/implicit/stack.frac
```

The expected output looks like this (exact times may vary by hardware):
```
$ ./_build/default/bin/fracst.exe ./tests/explicit/stack.frac
Running fracst on explicit syntax: './tests/explicit/stack.frac'
typechecking time: 0.035000s
typechecking successful

$ ./_build/default/bin/fracst.exe -s implicit ./tests/implicit/stack.frac
Running fracst on implicit syntax: './tests/implicit/stack.frac'
typechecking + reconstruction time: 0.050000s
typechecking successful
```

### Running All Test Cases

We have provided a script to run all test cases at `time.sh`. To execute, simply run `./time.sh`. This will run each test case in both syntax modes 10 times and report the average time for typechecking and for reconstruction, as well as the line counts for both syntaxes. The times for individual runs are placed in the `times` directory. We calculate the typechecking time as the time for the explicit syntax and the program reconstruction time as the additional time taken for the implicit syntax.

The output should look like the following. Times may vary depending on hardware. This output is from a desktop computer with an AMD Ryzen 7 5800X CPU and 32 GB of RAM running Ubuntu 24.04.
```
$ ./time.sh
Running test 'stack'
Average typechecking time: 0.0317
Average reconstruction time: 0.0113
Implicit lines: 67
Explicit lines: 93

Running test 'queue'
Average typechecking time: 0.0315
Average reconstruction time: 0.0097
Implicit lines: 68
Explicit lines: 97

Running test 'tree'
Average typechecking time: 0.0367
Average reconstruction time: 0.0124
Implicit lines: 77
Explicit lines: 109

Running test 'nat'
Average typechecking time: 0.0291
Average reconstruction time: 0.0098
Implicit lines: 85
Explicit lines: 119

Running test 'bin'
Average typechecking time: 0.0296
Average reconstruction time: 0.0179
Implicit lines: 90
Explicit lines: 116

Running test 'ring_leader'
Average typechecking time: 0.0387
Average reconstruction time: 0.0153
Implicit lines: 120
Explicit lines: 161

Running test 'mapreduce'
Average typechecking time: 0.0619
Average reconstruction time: 0.0167
Implicit lines: 136
Explicit lines: 216

Running test 'auction'
Average typechecking time: 0.4682
Average reconstruction time: 0.0823
Implicit lines: 291
Explicit lines: 384

Running test 'avl_tree'
Average typechecking time: 0.2803
Average reconstruction time: 0.0378
Implicit lines: 364
Explicit lines: 500
```

## Writing FracST programs
If you wish to write new FracST programs, the following documentation gives an overview of the syntax:

#### Type Definitions
New type names can be defined using the following syntax `type v = A` where type name `v` has definition `A`. As an example, the `queue` type is defined as follows:
```
type queue = /\k. &{ins : \\// !a. <A,*,a> -o queue,
                    del : \\// +{none : 1,
                                 some : ?a. <A,*,a> * queue},
                    len : ?a. <nat,*,a> * \/ queue}
```
Here, `/\`, `\/`, and `\\//` are used to denote the up, down, and double down arrows, `!a` and `?a` are used to receive and send identifiers respectively, `-o` and `*` are used to receive and send channels, `+` and `&` denote internal and external choice, and `1` indicates termination.

Formally, the grammar for session types is as follows:
```
<A> ::= +{l1 : <A1>, ..., ln : <An>}       // internal choice
      | &{l1 : <A1>, ..., ln : <An>}       // external choice
      | <<A>,<p>,a> * <A>                  // tensor
      | <<A>,<p>,a> -o <A>                 // lolli
      | 1                                  // one
      | /\ <A>                             // up (start immutable session)
      | \/ <A>                             // down (end immutable session)
      | \\// <A>                           // double down (mutate)
      | !a. <A>                            // forall identifier
      | ?a. <A>                            // exists identifier
      | !!p. <A>                           // forall permission 
      | ??p. <A>                           // exists permission
      | <id>                               // type name (e.g. auction)
      | ( <A> )
    
<p> ::= *                // owned permission 
      | <int>/<int>      // fractional permission
      | <id>             // variable permission
      | <int>/<int>*<id> // fraction of variable permission
      | <p> + <p>        // sum of permissions
```

#### Process Definitions
New processes are defined using the syntax `proc f[ids]{ps} : (c1 : <A1,p1,a1>), ... (cm : <Am,pm,am>) |- (c : A) = P` where the process name is `f`, its declared identifier variables are `ids`, its declared permission variables are `ps`, its context is a sequence of channel arguments `ci` of type `<Ai,pi,ai>`, and the offered channel is `x` of type `A`. The definition is denoted by the expression `P`. An empty context is described using `.`.

Formally, the context is denoted with
```
<context> ::= .     // empty context
            | <ctx> // non-empty context

<ctx> ::= (x : <<A>,<p>,a>), <ctx>
```

### Process Syntax
Formally, the syntax for processes is below.
```
<ch-list> ::= <id> | <id> <ch-list> // channel list

<P> ::= {a}, <ch> <- f[ids]{ps} <- <ch-list> ; <P>   // spawn process f
      | {a}, <ch> <- f[ids]{ps} <- <ch-list>         // tail call f
      | <ch> <-> <ch>                                // forwarding
      | send <ch1> <ch2> ; <P>                       // send <ch2> on <ch1>
      | <ch2> <- recv <ch1> ; <P>                    // receive <ch2> on <ch1>
      | <ch>.k ; <P>                                 // send label k on <ch>
      | case <ch> ( <branches> )                     // case analyze on label received on <ch>
      | close <ch>                                   // close channel <ch>
      | wait <ch> ; <P>                              // wait for <ch> to close
      | immut <ch-list> { p => <P> }                 // immutable block using <ch-list>
      | continue <ch-list>                           // tail call immutable session with <ch-list>
      | mut { <P> }                                  // abort immutable session
      | start <ch>{<p>} ; <P>                        // start immutable session on <ch> with permission <p>
      | finish <ch> ; <P>                            // finish immutable session on <ch>
      | mutate <ch> ; <P>                            // abort immutabl session on <ch>
      | <ch1>, <ch2> <- split <ch> ; <P>             // split <ch> into <ch1> and <ch2>
      | <ch> <- merge <ch1>, <ch2> ; <P>             // merge <ch1> and <ch2> into <ch>
      | share <ch> ; <P>                             // share <ch>
      | own <ch> ; <P>                               // own <ch>
      | send {a} <ch> ; <P>                          // send identifier a on <ch>
      | {a} <- recv <ch> ; <P>                       // recieve identifier a on <ch>
      | send {{p}} <ch> ; <P>                        // send permission p on <ch>
      | {{p}} <- recv <ch> ; <P>                     // recieve permission p on <ch>
```
