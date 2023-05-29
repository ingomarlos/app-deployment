package main

import (
	"encoding/json"
	"net/http"
	"os"
	"sync"
	"time"
)

type Movie struct {
	Name string `json:"name"`
	Year int    `json:"year"`
}

type EnvVars struct {
	Environment string `json:"environment"`
	Token       string `json:"token"`
}

var movies = []Movie{
	{Name: "The Shawshank Redemption", Year: 1994},
	{Name: "The Godfather", Year: 1972},
	{Name: "The Dark Knight", Year: 2008},
	{Name: "Pulp Fiction", Year: 1994},
	{Name: "Fight Club", Year: 1999},
	{Name: "Inception", Year: 2010},
	{Name: "Forrest Gump", Year: 1994},
	{Name: "The Matrix", Year: 1999},
	{Name: "Interstellar", Year: 2014},
	{Name: "Schindler's List", Year: 1993},
}

var envVars = EnvVars{
	Environment: os.Getenv("ENVIRONMENT"),
	Token:       os.Getenv("TOKEN"),
}

var stopStress bool
var mutex sync.Mutex

func fib(n int) int {
	if n <= 1 {
		return n
	}
	return fib(n-1) + fib(n-2)
}

func stressHandler(w http.ResponseWriter, r *http.Request) {
	mutex.Lock()
	stopStress = false
	mutex.Unlock()

	go func() {
		for {
			mutex.Lock()
			if stopStress {
				mutex.Unlock()
				break
			}
			mutex.Unlock()

			// perform a heavy operation
			_ = fib(30)
		}
	}()

	// Set timer to stop the stress after 5 minutes
	time.AfterFunc(5*time.Minute, func() {
		mutex.Lock()
		stopStress = true
		mutex.Unlock()
	})

	w.WriteHeader(http.StatusOK)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
}

func moviesHandler(w http.ResponseWriter, r *http.Request) {
	response := struct {
		Movies  []Movie `json:"movies"`
		EnvVars EnvVars `json:"env_vars"`
	}{
		Movies:  movies,
		EnvVars: envVars,
	}

	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/movies", moviesHandler)
	http.HandleFunc("/stress", stressHandler)
	http.ListenAndServe(":8080", nil)
}
