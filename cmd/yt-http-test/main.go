package main

import (
	"context"
	"flag"
	"log"
	"net/http"
	"time"
)

func main() {
	var arg struct {
		URL      string
		Rate     time.Duration
		Timeout  time.Duration
		Duration time.Duration
		Fail     bool
	}
	flag.StringVar(&arg.URL, "url", "https://google.com", "url to request")
	flag.DurationVar(&arg.Rate, "rate", time.Second, "request rate")
	flag.DurationVar(&arg.Timeout, "timeout", 5*time.Second, "request timeout")
	flag.BoolVar(&arg.Fail, "fail", false, "fail on first error")
	flag.DurationVar(&arg.Duration, "duration", time.Minute*2, "duration to run")
	flag.Parse()
	handle := func(err error) {
		if err == nil {
			return
		}
		if arg.Fail {
			log.Fatalf("err: %v", err)
		}
		log.Printf("err: %v", err)
	}
	tick := func() error {
		ctx, cancel := context.WithTimeout(context.Background(), arg.Timeout)
		defer cancel()
		req, err := http.NewRequestWithContext(ctx, http.MethodGet, arg.URL, http.NoBody)
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
	until := time.After(arg.Duration)
	handle(tick())
	ticker := time.NewTicker(arg.Rate)
	defer ticker.Stop()
	for {
		select {
		case <-until:
			log.Println("done")
			return
		case <-ticker.C:
			handle(tick())
		}
	}
}
