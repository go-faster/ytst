package main

import (
	"context"
	"log"
	"net/http"
	"time"
)

func tick() error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	req, err := http.NewRequestWithContext(ctx, "GET", "https://google.com", http.NoBody)
	if err != nil {
		return err
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	log.Println(req.Method, req.URL, res.Status)
	return res.Body.Close()
}

func main() {
	if err := tick(); err != nil {
		log.Printf("err: %v", err)
	}
	ticker := time.NewTicker(time.Second)
	defer ticker.Stop()
	for range ticker.C {
		if err := tick(); err != nil {
			log.Printf("err: %v", err)
		}
	}
}
