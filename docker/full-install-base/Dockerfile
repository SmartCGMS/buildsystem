FROM debian:bookworm

RUN apt-get update ; \
	apt-get install -y wget iputils-ping git gcc g++ make cmake git vim 
	
RUN apt-get install -y qt6-base-dev qt6-base-dev-tools libqt6sql6 qt6-svg-dev libqt6svg6 libqt6svgwidgets6

RUN mkdir -p /opt/scgms && cd /opt/scgms && wget https://github.com/SmartCGMS/buildsystem/raw/devel/full-install/CMakeLists.txt

RUN cd /opt/scgms && git clone https://github.com/SmartCGMS/common.git
RUN cd /opt/scgms && git clone https://github.com/SmartCGMS/core.git
RUN cd /opt/scgms && git clone https://github.com/SmartCGMS/console.git
RUN cd /opt/scgms && git clone https://github.com/SmartCGMS/desktop.git

RUN cd /opt/scgms && mkdir build && cd build && cmake -S ../ -DBUILDOPT_FETCH_ALL_DEPS=TRUE -DBUILDOPT_NO_RDRAND=TRUE -DCOMPONENT_EXCEL_LOADERS=FALSE && make -j4

ENV SHELL /bin/bash

CMD /bin/bash
