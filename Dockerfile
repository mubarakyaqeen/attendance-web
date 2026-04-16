# -------- STAGE 1: BUILD FLUTTER WEB --------
FROM cirrusci/flutter:stable AS build

WORKDIR /app

# Copy all files
COPY . .

# Install dependencies
RUN flutter pub get

# Build Flutter web
RUN flutter build web

# -------- STAGE 2: SERVE WITH NGINX --------
FROM nginx:alpine

# Remove default nginx files
RUN rm -rf /usr/share/nginx/html/*

# Copy built files from stage 1
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy your nginx config (if you uploaded it)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]