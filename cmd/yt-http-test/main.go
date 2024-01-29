package main

import (
	"context"
	"flag"
	"log"
	"net"
	"net/http"
	"net/netip"
	"strconv"
	"time"
)

type staticDialer struct {
	ip netip.Addr
}

func (d staticDialer) Dial(_ context.Context, network, address string) (net.Conn, error) {
	_, strPort, err := net.SplitHostPort(address)
	if err != nil {
		return nil, err
	}
	port, err := strconv.ParseUint(strPort, 10, 16)
	if err != nil {
		return nil, err
	}
	return net.Dial(network, netip.AddrPortFrom(d.ip, uint16(port)).String())
}

func newClient() *http.Client {
	dialer := staticDialer{
		// dig example.com
		// 	example.com.            6585    IN      A       93.184.216.34
		ip: netip.MustParseAddr("93.184.216.34"),
	}
	transport := &http.Transport{
		Proxy:                 http.ProxyFromEnvironment,
		DialContext:           dialer.Dial,
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
		Rate     time.Duration
		Timeout  time.Duration
		Duration time.Duration
		Fail     bool
	}
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
		req, err := http.NewRequestWithContext(ctx, http.MethodGet, "http://example.com", http.NoBody)
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
