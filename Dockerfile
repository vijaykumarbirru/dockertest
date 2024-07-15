# Stage 1: Build the application
#FROM 798625366978.dkr.ecr.eu-west-1.amazonaws.com/avrioc/base:node-20.9.0 AS build-stage
FROM 798625366978.dkr.ecr.me-central-1.amazonaws.com/avrioc/base:node-20.9.0-npm-10.8.1.3 AS build-stage

# Install necessary build tools
RUN apk add --no-cache g++ make py3-pip

# Set the working directory inside the container
WORKDIR /app/admin-portal

# Copy the application files
COPY . .

# Clean npm cache and install dependencies
RUN rm -rf /usr/local/lib/node_modules/npm/node_modules/minipass-collect/node_modules/minipass
RUN npm cache clean --force && \
    npm config set registry http://nexus:8081/repository/npm && \
    npm install --omit=optional --verbose

# Set environment variable for API base URL


# Build the application
RUN npm run build

# Stage 2: Install nginx
FROM 798625366978.dkr.ecr.eu-west-1.amazonaws.com/avrioc/base:nginx-1.27

# Copy built files from the previous stage to Nginx html directory
COPY --from=build-stage /app/admin-portal/build /usr/share/nginx/html

# Modify the Nginx configuration
RUN sed -i 's/listen       80;/listen       8080;/g' /etc/nginx/conf.d/default.conf && \
    sed -i 's/listen  \[::\]:80;/listen  \[::\]:8080;/g' /etc/nginx/conf.d/default.conf

# Expose port 8080 to the outside world
EXPOSE 8080

# Start nginx with correct parameters
CMD ["nginx", "-g", "daemon off;"]
