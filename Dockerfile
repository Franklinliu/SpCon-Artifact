FROM ubuntu:20.04

RUN apt-get update && apt-get install -y software-properties-common gcc && \
    add-apt-repository -y ppa:deadsnakes/ppa

RUN apt-get update && apt-get install -y python3.8 python3-distutils python3-pip python3-apt

RUN mkdir /home/spcon 
WORKDIR /home/spcon

COPY Pyevolve Pyevolve
RUN cd Pyevolve && python3 setup.py install && cd .. 

RUN pip3 install numpy pandas scipy 
COPY spcon spcon 
COPY README.md README.md 
COPY setup.py setup.py 
RUN python3 setup.py install 

RUN pip3 install solc-select
RUN apt-get install z3 

CMD ["/usr/bin/spcon"]



