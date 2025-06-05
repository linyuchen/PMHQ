FROM node:22.16-alpine
RUN apk add --no-cache unzip

WORKDIR /app/llonebot

COPY docker/llonebot/startup.sh /startup.sh

RUN chmod +x /startup.sh

COPY /dist/llonebot.zip /app/llonebot.zip

RUN unzip /app/llonebot.zip -d /app/llonebot \
    && rm /app/llonebot.zip

ENTRYPOINT ["/startup.sh"]