FROM python:3.7.3-alpine

RUN pip install Flask==2.0.3

WORKDIR /app
COPY microservices/gateway-service/src/app.py /app/
ENV FLASK_APP=app.py
CMD flask run -h 0.0.0.0 -p 5000
