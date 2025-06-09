package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"github.com/joho/godotenv"
)

type Phone struct {
	Brand   string  `json:"brand"`
	Model   string  `json:"model"`
	Storage string  `json:"storage"`
	Color   string  `json:"color"`
	Price   float64 `json:"price"`
}

type Response struct {
	Success bool    `json:"success"`
	Message string  `json:"message,omitempty"`
	Data    []Phone `json:"data,omitempty"`
}

type Config struct {
	Enviroment    string
	APIKey        string
	InventoryFile string
	Port          string
}

var inventory []Phone
var config Config

func loadConfig() Config {
	enviroment := os.Getenv("ENVIROMENT")
	if enviroment == "" {
		enviroment = "dev"
	}

	apiKey := os.Getenv("API_KEY")
	if apiKey == "" {
		apiKey = "this-is-not-secure"
	}

	inventoryFile := os.Getenv("INVENTORY_FILE")
	if inventoryFile == "" {
		inventoryFile = "inventory.json"
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	return Config{
		Enviroment:	   enviroment,
		APIKey:        apiKey,
		InventoryFile: inventoryFile,
		Port:          port,
	}
}

func loadInventoryFromFile(filename string) error {
	absPath, err := filepath.Abs(filename)

	if err != nil {
		return fmt.Errorf("error getting absolute path: %v", err)
	}

	if _, err := os.Stat(absPath); os.IsNotExist(err) {
		return fmt.Errorf("file does not exist: %s", absPath)
	}

	data, err := ioutil.ReadFile(absPath)

	if err != nil {
		return fmt.Errorf("error reading file: %v", err)
	}

	err = json.Unmarshal(data, &inventory)
	if err != nil {
		return fmt.Errorf("error parsing JSON: %v", err)
	}

	fmt.Printf("Loaded %d phones\n", len(inventory))
	return nil
}

func enableCORS(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next(w, r)
	}
}

func isValidAPIKey(key string) bool {
	return key == config.APIKey
}

func inventoryHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("Got a request!\n")

	w.Header().Set("Content-Type", "application/json")

	// 404 on non-POST requests
	if r.Method != "POST" {
		w.WriteHeader(http.StatusNotFound)
		w.Write([]byte("404 page not found"))
		return
	}

	apiKey := r.URL.Query().Get("key")

	// Check if key is valid
	if apiKey == "" || !isValidAPIKey(apiKey) {
		response := Response{
			Success: false,
			Message: "Invalid API key",
		}
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(response)
		return
	}

	response := Response{
		Success: true,
		Data:    inventory,
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

func main() {
	fmt.Println("Starting EJ's Cellphone Emporium API...")

	envFile := ".env"
	if err := godotenv.Load(envFile); err != nil {
		fmt.Printf("Could not load %s: %v\n", envFile, err)
	}

	config = loadConfig()
	fmt.Printf("Configuration loaded\n")

	err := loadInventoryFromFile(config.InventoryFile)
	if err != nil {
		fmt.Printf("Could not load %s: %v\n", config.InventoryFile, err)
		inventory = []Phone{}
	}

	http.HandleFunc("/api", enableCORS(inventoryHandler))

	fmt.Printf("Server starting on port %s\n", config.Port)
	if config.Enviroment == "dev" {
		fmt.Printf("Try:\n\tcurl -X POST \"http://localhost:%s/api?key=%s\"\n", config.Port, config.APIKey)
	}

	log.Fatal(http.ListenAndServe(":"+config.Port, nil))
}
