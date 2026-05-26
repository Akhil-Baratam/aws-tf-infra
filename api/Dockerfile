FROM golang:1.25.7 AS build

WORKDIR /app

ARG APP_PATH

COPY ${APP_PATH}.go /app

RUN CGO_ENABLED=0 go build -o main ${APP_PATH}.go

FROM scratch

WORKDIR /app

COPY --from=build /app/main .

ARG PORT
EXPOSE ${PORT}


ENTRYPOINT [ "/app/main" ]