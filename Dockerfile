FROM tensorflow/tensorflow:latest-gpu-jupyter

RUN /usr/bin/python3 -m pip install --upgrade pip
RUN apt-get update && apt-get install -y r-base r-base-dev
RUN pip install tensorflow zeep elasticsearch cx-Oracle geopy matplotlib pydot graphviz ipyparallel nltk pandas sklearn ipyleaflet dash dash-leaflet jupyterlab
ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/Berlin" JUPYTER_ENABLE_LAB=yes
USER 0

RUN cd /tmp/ && \
    curl -LO https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-basic-linux.x64-19.8.0.0.0dbru.zip && \
    unzip instantclient-basic-linux.x64-19.8.0.0.0dbru.zip && \
    mkdir /opt/oracle && \
    mv instantclient_19_8/ /opt/oracle && \
    rm -rf /tmp/instantclient-basic-linux.x64-19.8.0.0.0dbru.zip && \
    apt-get update && \
    apt-get install -y libaio1 graphviz && \
    sh -c "echo /opt/oracle/instantclient_19_6 > /etc/ld.so.conf.d/oracle-instantclient.conf" && \
    ldconfig && \
    apt-get install -y python3-mpltoolkits.basemap && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_19_8/${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
USER 0
#WORKDIR /tf
#ENV HOME=/tf

### R verfuegbar machen ###
RUN apt-get update && apt-get install -y libxml2-dev libxml2 libssl-dev libcurl4-openssl-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev
RUN R -e 'install.packages(c("devtools"), lib="/usr/local/lib/R/site-library",dependencies=TRUE)' && \
    R -e 'devtools::install_github("IRkernel/IRkernel",force=TRUE)'
RUN R -e 'IRkernel::installspec(user = FALSE)'

###javascript in jupyterlab ermöglichen###
RUN pip install git+https://chromium.googlesource.com/external/gyp
RUN apt-get install -y nodejs npm
RUN npm install -g --unsafe-perm ijavascript
RUN ijsinstall --install=global
###end javascript in jupyterlab###
CMD jupyter-lab --allow-root --ip=0 --collaborative
