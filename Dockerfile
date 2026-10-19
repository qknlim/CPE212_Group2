FROM nginx:alpine

LABEL maintainer="CPE212 Group 2" \
      description="Static portfolio web application (HOA, Exams, Reflections)"

# Remove the default Nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy the static web app into the Nginx web root
COPY webapp/ /usr/share/nginx/html/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
