FROM ghcr.io/r-devel/rcheckserver/ubuntu

COPY . /pkg
RUN R -e 'install.packages("pak");pak::pak("/pkg");library(recheck)'

