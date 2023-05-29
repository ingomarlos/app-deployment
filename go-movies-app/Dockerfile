# Start from the latest golang base image
FROM golang:latest

# Add Maintainer Info
LABEL maintainer="ingomarlos@gmail.com"

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY movies.go ./

# Compile the app
RUN CGO_ENABLED=0 go build movies.go

# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the executable
CMD ["./movies"]