FROM ubuntu:20.04 as builder

USER root

# Locale
ENV LC_ALL C
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

ENV DEBIAN_FRONTEND=noninteractive

# Software version
ENV VER_PISCES='5.2.10.49'
ENV VER_UBUNTU='20.04'

RUN apt-get -yq update
RUN apt-get install -yq \ 
    curl 

ENV OPT /opt/wsi-t113
ENV PATH $OPT/bin:$PATH
ENV LD_LIBRARY_PATH $OPT/lib

RUN mkdir -p $OPT

ADD build/opt-build.sh build/
RUN bash build/opt-build.sh $OPT

FROM ubuntu:20.04

LABEL maintainer="vo1@sanger.ac.uk" \
      version="5.2.10.49" \
      description="PISCES container"

MAINTAINER  Victoria Offord <vo1@sanger.ac.uk>

RUN apt-get -yq update

ENV OPT /opt/wsi-t113
ENV PATH $OPT/bin:$OPT/python3/bin:$PATH
ENV LD_LIBRARY_PATH $OPT/lib
ENV PYTHONPATH $OPT/python3:$OPT/python3/lib/python3.6/site-packages
ENV LC_ALL C
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV DISPLAY=:0

RUN mkdir -p $OPT
COPY --from=builder $OPT $OPT

RUN apt-get update -yq && \
    apt-get install -y apt-transport-https \
        ca-certificates

RUN dpkg -i /opt/wsi-t113/packages-microsoft-prod.deb    

RUN apt-get update -yq && \
    apt-get install -yq dotnet-sdk-2.1

## USER CONFIGURATION
RUN adduser --disabled-password --gecos '' ubuntu && chsh -s /bin/bash && mkdir -p /home/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/bash"]
