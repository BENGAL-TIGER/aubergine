
FROM rocker/geospatial:3.6.0

ENV NB_USER rstudio
ENV NB_UID 1000
ENV VENV_DIR /srv/venv
env SHELL=/bin/bash
env PYTHONPATH="${PYTHONPATH}:${VENV_DIR}"

# Set ENV for all programs...
ENV PATH ${VENV_DIR}/bin:$PATH
# And set ENV for R! It doesn't read from the environment...
RUN echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron

# The `rsession` binary that is called by nbrsessionproxy to start R doesn't seem to start
# without this being explicitly set
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib

ENV HOME /home/${NB_USER}
WORKDIR ${HOME}

RUN apt-get update && \
    apt-get -y install python3-venv python3-dev && \
    apt-get purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

env OFFICE_DIR=${HOME}/work

run mkdir -p ${OFFICE_DIR}\
 && chown -R ${NB_USER} ${OFFICE_DIR}


# Create a venv dir owned by unprivileged user & set up notebook in it
# This allows non-root to install python libraries if required
RUN mkdir -p ${VENV_DIR} && chown -R ${NB_USER} ${VENV_DIR}

USER ${NB_USER}


RUN python3 -m venv ${VENV_DIR} && \
    # Explicitly install a new enough version of pip
    pip3 install pip==9.0.1 && \
    pip3 install --no-cache-dir \
         nbrsessionproxy==0.6.1 && \
    pip3 install jupyter_contrib_nbextensions && \
    jupyter contrib nbextension install && \
    jupyter nbextension enable printview/main \
 && jupyter nbextension enable livemdpreview/livemdpreview \
 && jupyter nbextension enable latex_envs/latex_envs \
 && jupyter serverextension enable --sys-prefix --py nbrsessionproxy && \
    jupyter nbextension install    --sys-prefix --py nbrsessionproxy && \
    jupyter nbextension enable     --sys-prefix --py nbrsessionproxy


RUN R --quiet -e "devtools::install_github('IRkernel/IRkernel')" && \
    R --quiet -e "IRkernel::installspec(prefix='${VENV_DIR}')"

run R -e "setwd(\"${OFFICE_DIR}\")"

user root

add . ${HOME}

# _____ julia ______________________________________________________________
ENV JULIA_VERSION=1.1.0

RUN mkdir /opt/julia-${JULIA_VERSION} \
 && cd /tmp \
 && wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz \
 && echo "80cfd013e526b5145ec3254920afd89bb459f1db7a2a3f21849125af20c05471 *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - \
 && tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 \
 && rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz \
 && ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia \
 && cd ${HOME}

# run pwd; wait 10 \
#  && cat splash \

USER ${NB_USER}

run julia -e 'print("Julia v",VERSION," installed...\n\n\n")'

# run julia -e 'import Pkg; Pkg.add("IJulia"); Pkg.build("IJulia")'

run julia -e 'using Pkg; \
              pkg"add Unitful \
                      IJulia \
                      InstantiateFromURL"; \
              pkg"precompile" ' \

run echo "PWD: " ${PWD}

WORKDIR ${OFFICE_DIR}

CMD jupyter notebook --ip 0.0.0.0


## If extending this image, remember to switch back to USER root to apt-get










# CMD jupyter notebook --ip 0.0.0.0
