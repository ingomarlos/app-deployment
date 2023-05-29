# To execute the go app you first need to build the image
docker build -t go-app .
Then push to your registry of choice.

The available endpoints are:
/health - used for health checks
/movies - used to get a list of movies
/stress - used to stress the app
