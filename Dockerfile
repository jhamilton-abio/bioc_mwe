FROM condaforge/miniforge3:24.3.0-0
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends build-essential
RUN apt-get install \
    unzip

# SET WORKDIR AND COPY FILES
WORKDIR foo
COPY conda_env.yml /foo/conda_env.yml
COPY install_packages.R /foo/install_packages.R

# CONDA DEPENDENCIES
RUN conda update -n base -c conda-forge conda && \
    conda env update -f conda_env.yml && \
    echo "conda activate conda_env" >> ~/.bashrc

# R DEPENDENCIES
#RUN /opt/conda/envs/conda_env/bin/Rscript install_packages.R
