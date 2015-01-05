package main

import (
    "github.com/gocraft/web"
    "github.com/t3rm1n4l/go-mega"
    "fmt"
    "net/http"
)

var megaSession *mega.Mega;

type Context struct {
    inc int
}



func (c *Context) Handle(rw web.ResponseWriter, req *web.Request) {
    initSession()
    c.inc++
    fmt.Println("%#v", megaSession)
    fmt.Fprint(rw, "Hello ", c.inc)
}


func initSession() {
    if (megaSession != nil) {
        return
    }

    m := mega.New()
    err := m.Login("UN", "PW")
    if err == nil {
        megaSession = m
    } else {
        panic("Cannot initialize megaSession")
    }
    return
}

func main() {
    // c := Context{Session: s}

    router := web.New(Context{}).                   // Create your router
        Middleware(web.LoggerMiddleware).           // Use some included middleware
        Middleware(web.ShowErrorsMiddleware).       // ...
        Get("/", (*Context).Handle)               // Add a route
    http.ListenAndServe("localhost:8100", router)   // Start the server!
}