FROM ubuntu:18.04

RUN apt-get update && apt-get install -y wget git && wget https://github.com/gohugoio/hugo/releases/download/v0.55.5/hugo_0.55.5_Linux-64bit.deb && apt-get install ./hugo_0.55.5_Linux-64bit.deb

RUN git clone https://github.com/mark-church/site.git

CMD ["/bin/sh", "-c", "hugo server --bind 0.0.0.0 -p 80 --source /site"]