FROM alpine:3.12

# Install nginx and ffmpeg
RUN apk add --update nginx ffmpeg && rm -rf /var/cache/apk/* && mkdir /app
COPY nginx/nginx.conf /etc/nginx/nginx.conf

COPY ./startup.sh /
COPY ./create_ffmpeg_cmd.sh /
RUN ["chmod", "+x", "/startup.sh"]
RUN ["chmod", "+x", "/create_ffmpeg_cmd.sh"]

CMD ["/startup.sh"]
