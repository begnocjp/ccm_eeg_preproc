FROM ubuntu:20.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
     unzip xorg wget \
 && apt-get clean \
 && rm -rf \
     /tmp/hsperfdata* \
     /var/*/apt/*/partial \
     /var/lib/apt/lists/* \
     /var/log/apt/term

# Downloads and install MCR
RUN mkdir /opt/mcr_install 
RUN mkdir /opt/mcr 
RUN wget --progress=bar:force -P /opt/mcr_install https://ssd.mathworks.com/supportfiles/downloads/R2021a/Release/0/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2021a_glnxa64.zip 
RUN unzip -q /opt/mcr_install/MATLAB_Runtime_R2021a_glnxa64.zip -d /opt/mcr_install  
RUN /opt/mcr_install/install -destinationFolder /opt/mcr -agreeToLicense yes -mode silent 
RUN rm -rf /opt/mcr_install /tmp/*

ENV LD_LIBRARY_PATH /opt/mcr/v910/runtime/glnxa64:/opt/mcr/v910/bin/glnxa64:/opt/mcr/v910/sys/os/glnxa64:/opt/mcr/v910/sys/opengl/lib/glnxa64:/opt/mcr/v910/extern/bin/glnxa64

ENV MCR_INHIBIT_CTF_LOCK 1

# Install our src
COPY src /opt/src

# Create input/output directories for binding
RUN mkdir /opt/src/INPUTS
RUN mkdir /opt/src/INPUTS/RAW
RUN mkdir /opt/src/INPUTS/edat_txt

# Configure entry point
ENTRYPOINT ["/opt/src/run_fieldtrip.sh","/opt/mcr/v910","/opt/src/CCM_EEG_preproc.m"]
CMD ["--help"]
