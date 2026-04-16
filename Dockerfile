# -------- STAGE 1: BUILD FLUTTER WEB --------
FROM ghcr.io/cirruslabs/flutter:3.22.3 AS build

WORKDIR /app

COPY . .

RUN flutter pub get
RUN flutter build web

# -------- STAGE 2: SERVE WITH NGINX --------
FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY --from=build /app/build/web /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]