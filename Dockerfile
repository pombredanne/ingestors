FROM ubuntu:xenial
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq -y update \
    && apt-get -qq -y upgrade \
    && apt-get -qq -y install wget git less \
        python-pip build-essential python-dev libxml2-dev libxslt1-dev \
        libpq-dev apt-utils ca-certificates postgresql-client unrar locales \
        libtiff5-dev libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev \
        poppler-utils poppler-data unrtf pstotext libwebp-dev \
        imagemagick-common imagemagick mdbtools p7zip-full libboost-python-dev libgsf-1-dev \
        libjpeg-dev libicu-dev libldap2-dev libsasl2-dev libreoffice djvulibre-bin \
        libtesseract-dev libleptonica-dev tesseract-ocr \
        tesseract-ocr-all \    
    && apt-get -qq -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# New version of the PST file extractor
RUN mkdir - /tmp/libpst \
    && wget -qO- http://www.five-ten-sg.com/libpst/packages/libpst-0.6.71.tar.gz | tar xz -C /tmp/libpst --strip-components=1 \
    && ls /tmp \
    && cd /tmp/libpst \
    && ln -s /usr/bin/python /usr/bin/python2.7.10 \
    && ./configure \
    && make \
    && make install \
    && rm -rf /tmp/libpst

# Set up the locale and make sure the system uses unicode for the file system.
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# en_GB.ISO-8859-15 ISO-8859-15/en_GB.ISO-8859-15 ISO-8859-15/' /etc/locale.gen && \
    locale-gen
ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8'

# Install Python dependencies
RUN pip install -q --upgrade pip && pip install -q --upgrade setuptools six nose coveralls
COPY requirements_dev.txt /tmp/
RUN pip install -r /tmp/requirements_dev.txt

# Install ingestors
COPY . /srv
WORKDIR /srv
RUN pip install -e .

WORKDIR /srv

CMD ["/bin/bash"]