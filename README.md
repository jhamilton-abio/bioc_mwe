## Overview

I am creating a Docker container with a mix of Python and R packages. I am using conda to install the majority of the packages, and using R's `devtools::install_version` when specific package versions are unavailable through Conda. **This works to install R packages from CRAN, but not from Bioconductor.** Furthermore, when I launch the container, I'm able to install Bioconductor packages via devtools.

This repo contains a minimal (non)working example.

## Build the container:

Command:
````
docker build --no-cache . -t bioc_mwe
````

Output:
````
[+] Building 162.4s (12/12) FINISHED                                                                           docker:default 
 => [internal] load build definition from Dockerfile                                                                     0.0s 
 => => transferring dockerfile: 613B                                                                                     0.0s 
 => [internal] load metadata for docker.io/condaforge/miniforge3:24.3.0-0                                                0.7s 
 => [internal] load .dockerignore                                                                                        0.0s 
 => => transferring context: 2B                                                                                          0.0s 
 => CACHED [1/8] FROM docker.io/condaforge/miniforge3:24.3.0-0@sha256:33bbb7027511456bd98807365abfd6fd43a7ff2836e3f7f49  0.0s 
 => => resolve docker.io/condaforge/miniforge3:24.3.0-0@sha256:33bbb7027511456bd98807365abfd6fd43a7ff2836e3f7f4997baf32  0.0s 
 => [internal] load build context                                                                                        0.0s 
 => => transferring context: 760B                                                                                        0.0s 
 => [2/8] RUN apt-get update && apt-get install -y --no-install-recommends build-essential                              34.5s 
 => [3/8] RUN apt-get install     unzip                                                                                  2.1s 
 => [4/8] WORKDIR foo                                                                                                    0.0s 
 => [5/8] COPY conda_env.yml /foo/conda_env.yml                                                                          0.0s
 => [6/8] COPY install_packages.R /foo/install_packages.R                                                                0.0s
 => [7/8] RUN conda update -n base -c conda-forge conda &&     conda env update -f conda_env.yml &&     echo "conda a  118.1s
 => ERROR [8/8] RUN /opt/conda/envs/conda_env/bin/Rscript install_packages.R                                             6.9s
------
 > [8/8] RUN /opt/conda/envs/conda_env/bin/Rscript install_packages.R:
5.450 Downloading package from url: http://bioconductor.org/packages/3.9/bioc/src/contrib/BiocParallel_1.18.1.tar.gz
6.863 Error: Failed to install 'unknown package' from URL:
6.863   Could not find tools necessary to compile a package
6.863 Call `pkgbuild::check_build_tools(debug = TRUE)` to diagnose the problem.
6.863 Execution halted
------
Dockerfile:18
--------------------
  16 |
  17 |     # R DEPENDENCIES
  18 | >>> RUN /opt/conda/envs/conda_env/bin/Rscript install_packages.R
  19 |
--------------------
ERROR: failed to solve: process "/bin/sh -c /opt/conda/envs/conda_env/bin/Rscript install_packages.R" did not complete successfully: exit code: 1
````

## Launch the container, open R, and run `pkgbuild::check_build_tools(debug = TRUE)`:

Commands:
````
docker run -it bioc_mwe:latest

R

pkgbuild::check_build_tools(debug = TRUE)
````

Output:
````
Trying to compile a simple C file
Running /opt/conda/envs/conda_env/lib/R/bin/R CMD SHLIB foo.c
x86_64-conda-linux-gnu-cc -I"/opt/conda/envs/conda_env/lib/R/include" -DNDEBUG   -DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem /opt/conda/envs/conda_env/include -I/opt/conda/envs/conda_env/include -Wl,-rpath-link,/opt/conda/envs/conda_env/lib  -fpic  -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /opt/conda/envs/conda_env/include -fdebug-prefix-map=/home/conda/feedstock_root/build_artifacts/r-base_1621283253293/work=/usr/local/src/conda/r-base-3.6.3 -fdebug-prefix-map=/opt/conda/envs/conda_env=/usr/local/src/conda-prefix  -c foo.c -o foo.o
x86_64-conda-linux-gnu-cc -shared -L/opt/conda/envs/conda_env/lib/R/lib -Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -Wl,-rpath,/opt/conda/envs/conda_env/lib -Wl,-rpath-link,/opt/conda/envs/conda_env/lib -L/opt/conda/envs/conda_env/lib -Wl,-rpath-link,/opt/conda/envs/conda_env/lib -o foo.so foo.o -L/opt/conda/envs/conda_env/lib/R/lib -lR
 
Your system is ready to build packages!
````

## Launch the container and install packages:

Commands:
````
docker run -it bioc_mwe:latest

/opt/conda/envs/conda_env/bin/Rscript install_packages.R
````

Output:
````
Downloading package from url: http://bioconductor.org/packages/3.9/bioc/src/contrib/BiocParallel_1.18.1.tar.gz
* installing *source* package ‘BiocParallel’ ...
** using staged installation
checking for x86_64-conda-linux-gnu-gcc... /opt/conda/envs/conda_env/bin/x86_64-conda-linux-gnu-cc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables... 
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
checking whether /opt/conda/envs/conda_env/bin/x86_64-conda-linux-gnu-cc accepts -g... yes       
checking for /opt/conda/envs/conda_env/bin/x86_64-conda-linux-gnu-cc option to accept ISO C89... none needed
checking for shm_open in -lrt... yes
configure: creating ./config.status
config.status: creating src/Makevars
** libs
x86_64-conda-linux-gnu-c++ -std=gnu++11 -I"/opt/conda/envs/conda_env/lib/R/include" -DNDEBUG  -I"/opt/conda/envs/conda_env/lib/R/library/BH/include" -DNDEBUG -D_FORTIFY_SOURCE=2 -O2 -isystem /opt/conda/envs/conda_env/include -I/opt/conda/envs/conda_env/include -Wl,-rpath-link,/opt/conda/envs/conda_env/lib  -fpic  -fvisibility-inlines-hidden  -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /opt/conda/envs/conda_env/include -fdebug-prefix-map=/home/conda/feedstock_root/build_artifacts/r-base_1621283253293/work=/usr/local/src/conda/r-base-3.6.3 -fdebug-prefix-map=/opt/conda/envs/conda_env=/usr/local/src/conda-prefix  -c ipcmutex.cpp -o ipcmutex.o
In file included from /opt/conda/envs/conda_env/lib/R/library/BH/include/boost/config/header_deprecated.hpp:18,
                 from /opt/conda/envs/conda_env/lib/R/library/BH/include/boost/pending/integer_log2.hpp:5,
                 from /opt/conda/envs/conda_env/lib/R/library/BH/include/boost/random/detail/integer_log2.hpp:19,
                 from /opt/conda/envs/conda_env/lib/R/library/BH/include/boost/random/detail/large_arithmetic.hpp:19,
                 from /opt/conda/envs/conda_env/lib/R/library/BH/include/boost/random/detail/const_mod.hpp:23,
                 from /opt/conda/envs/conda_env/lib/R/library/BH/include/boost/random/detail/seed_impl.hpp:26,
                 from /opt/conda/envs/conda_env/lib/R/library/BH/include/boost/random/mersenne_twister.hpp:30,
                 from /opt/conda/envs/conda_env/lib/R/library/BH/include/boost/uuid/random_generator.hpp:17,
                 from /opt/conda/envs/conda_env/lib/R/library/BH/include/boost/uuid/uuid_generators.hpp:17,
                 from ipcmutex.cpp:3:
/opt/conda/envs/conda_env/lib/R/library/BH/include/boost/config/pragma_message.hpp:24:34: note: #pragma message: This header is deprecated. Use <boost/integer/integer_log2.hpp> instead.
   24 | # define BOOST_PRAGMA_MESSAGE(x) _Pragma(BOOST_STRINGIZE(message(x)))
      |                                  ^~~~~~~
/opt/conda/envs/conda_env/lib/R/library/BH/include/boost/config/header_deprecated.hpp:23:37: note: in expansion of macro 'BOOST_PRAGMA_MESSAGE'
   23 | # define BOOST_HEADER_DEPRECATED(a) BOOST_PRAGMA_MESSAGE("This header is deprecated. Use " a " instead.")
      |                                     ^~~~~~~~~~~~~~~~~~~~
/opt/conda/envs/conda_env/lib/R/library/BH/include/boost/pending/integer_log2.hpp:7:1: note: in expansion of macro 'BOOST_HEADER_DEPRECATED'
    7 | BOOST_HEADER_DEPRECATED("<boost/integer/integer_log2.hpp>");
      | ^~~~~~~~~~~~~~~~~~~~~~~
x86_64-conda-linux-gnu-c++ -std=gnu++11 -shared -L/opt/conda/envs/conda_env/lib/R/lib -Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -Wl,-rpath,/opt/conda/envs/conda_env/lib -Wl,-rpath-link,/opt/conda/envs/conda_env/lib -L/opt/conda/envs/conda_env/lib -Wl,-rpath-link,/opt/conda/envs/conda_env/lib -o BiocParallel.so ipcmutex.o -lrt -L/opt/conda/envs/conda_env/lib/R/lib -lR
installing to /opt/conda/envs/conda_env/lib/R/library/00LOCK-BiocParallel/00new/BiocParallel/libs
** R
** inst
** byte-compile and prepare package for lazy loading
** help
*** installing help indices
** building package indices
** installing vignettes
** testing if installed package can be loaded from temporary location
** checking absolute paths in shared objects and dynamic libraries
** testing if installed package can be loaded from final location
** testing if installed package keeps a record of temporary installation path
* DONE (BiocParallel)
````