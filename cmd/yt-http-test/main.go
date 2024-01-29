package main

import (
	"context"
	"flag"
	"log"
	"net"
	"net/http"
	"time"

	"github.com/ncruces/go-dns"
)

func newClient() *http.Client {
	resolver, err := dns.NewDoHResolver("https://dns.google/dns-query{?dns}",
		dns.DoHAddresses("8.8.8.8", "8.8.4.4", "2001:4860:4860::8888", "2001:4860:4860::8844"),
		dns.DoHCache(),
	)
	if err != nil {
		log.Fatalln(err)
	}
	dialer := &net.Dialer{
		Resolver:  resolver,
		Timeout:   5 * time.Second,
		KeepAlive: 1 * time.Minute,
	}
	transport := &http.Transport{
		Proxy:                 http.ProxyFromEnvironment,
		DialContext:           dialer.DialContext,
		ForceAttemptHTTP2:     true,
		MaxIdleConns:          100,
		IdleConnTimeout:       90 * time.Second,
		TLSHandshakeTimeout:   10 * time.Second,
		ExpectContinueTimeout: 1 * time.Second,
	}
	client := &http.Client{
		Transport: transport,
	}
	return client
}

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
	var ok bool
	handle := func(err error) {
		if ok = err == nil; ok {
			return
		}
		if arg.Fail {
			log.Fatalf("err: %v", err)
		}
		log.Printf("err: %v", err)
	}
	client := newClient()
	tick := func() error {
		ctx, cancel := context.WithTimeout(context.Background(), arg.Timeout)
		defer cancel()
		req, err := http.NewRequestWithContext(ctx, http.MethodGet, arg.URL, http.NoBody)
		if err != nil {
			return err
		}
		res, err := client.Do(req)
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
			if !ok {
				log.Fatalln("failed")
			}
			log.Println("done")
			return
		case <-ticker.C:
			handle(tick())
		}
	}
}
