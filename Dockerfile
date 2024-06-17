FROM elixir:1.16.1-alpine

WORKDIR /app

COPY . .

RUN pip install gdown

RUN cd MapaRuas-materialBase
RUN gdown https://drive.google.com/uc?id=1ZWrg_ARBkzlpKmMxs7oirQTnSMXzdzFw

RUN cd ..

CMD [ "sh", "-c", "mix setup; mix phx.server" ]
