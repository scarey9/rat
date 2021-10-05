# pull official base image
FROM python:3.9-alpine

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PYTHONPATH=/usr/lib/python3.8/site-packages

RUN apk add --no-cache gcc build-base
# copy requirements file
COPY requirements.txt /usr/src/app/requirements.txt

# install dependencies
RUN pip install -r /usr/src/app/requirements.txt \
    && rm -rf /root/.cache/pip

# copy project
COPY ./src/app /usr/src/app

CMD ["sh", "-c", "piccolo migrations forwards session_auth && piccolo migrations forwards user &&  piccolo migrations new home --auto && piccolo migrations forwards home && python main.py"]