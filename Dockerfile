FROM ubuntu
RUN apt-get -y update && apt-get install -y python-dev python-pip
RUN pip install -r requirements.txt
