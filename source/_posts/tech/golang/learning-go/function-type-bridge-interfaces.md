---
title: Function Types Are a Bridge to Interfaces
date: 2025-03-20 22:41:28 
categories: [Tech, Golang]
tags: [golang, learning-go-book]
---

> The question becomes: when should your function or method specify an input parameter of a function type, and when should you use an interface? 
> If your single function is likely to depend on many other functions or other state that’s not specified in its input parameters, use an interface parameter and define a function type to bridge a function to the interface.
>  However, if it’s a simple function (like the one used in `sort.Slice`), then a parameter of a function type is a good choice.
>
> <footer>Learning Go (2nd edition) — Chapter 7, "Function Types Are a Bridge to Interfaces"</footer>

The acutall question here is, Why use this function-wrapper trick instead of just passing structs that implement the interface? 🤔

## Using a Struct-Based Handler
Go allows passing structs that implemente an interface. For example, `http.Handler` interface:
```go main.go
type HelloHandler struct{
    db *sql.DB
}

func (h HelloHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    // do DB stuff
    fmt.Fprintln(w, "Hello, Struct!")
}

func main() {
    http.Handle("/", HelloHandler{&sql.DB{}}) // Works fine
    http.ListenAndServe(":8080", nil)
}
```
This is useful if you need state/dependency (e.g., database connections, logging). Also, structs are explicit and readable.
However, this is not always the best choice if you just need to wrap a function.

## Using Function Type As a Bridge
Go provides `function type` so that you can pass a function directly, without needing a struct to satisfy the interface.
```go go/http.go
type Handler interface {
    ServeHTTP(http.ResponseWriter, *http.Request)
}

type HandlerFunc func(http.ResponseWriter, *http.Request)

func (f HandlerFunc) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    f(w, r)
}
```
```go main.go
func helloHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintln(w, "Hello, Function!")
}

func main() {
    http.Handle("/", http.HandlerFunc(helloHandler)) // Works fine
    http.ListenAndServe(":8080", nil)
}
```
Here no need to create a `struct` just to wrap a function. More readable, you can define simple handlers in fewer lines. And easier for `middleware`.

> [!NOTE]
> If you will use `http.Handle` you need use `http.HandlerFunc` to convert the function to a `http.Handler` type. Otherwise, you can use `http.HandleFunc` directly.

## Where Function Type REALLY Shines
It shines when you want to use `higher-order functions` to create `middleware` for example.
```go main.go
package main

import (
    "fmt"
    "net/http"
)

func loggingMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // Log request details before processing
        log.Printf("Request: %s %s", r.Method, r.URL.Path)
        
        // Call the next handler
        next.ServeHTTP(w, r)
        
        // Log after processing (optional)
        log.Printf("Completed: %s %s", r.Method, r.URL.Path)
    })
}

func authMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // Check for auth token (simplified example)
        token := r.Header.Get("Authorization")
        if token == "" {
            http.Error(w, "Unauthorized", http.StatusUnauthorized)
            return
        }
        
        // If authenticated, call the next handler
        next.ServeHTTP(w, r)
    })
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintln(w, "Hello, Middleware!")
}

func main() {
    handler := loggingMiddleware(authMiddleware(http.HandlerFunc(helloHandler)))
    http.Handle("/", handler) // Much cleaner!
    http.ListenAndServe(":8080", nil)
}
```
If you try to do this with a struct-based handler, you would need to create a new struct for each middleware/handler, which is not very clean.

> [!TIP]
> Alternative you can use a middleware chaining helper function. you can find many examples on the internet.

## You Need State? Use Closures!
A common argument against function handlers is that they can't store state like a struct.
But closures solve this elegantly:
```go main.go
func newCounterHandler() http.HandlerFunc {
    counter := 0
    return func(w http.ResponseWriter, r *http.Request) {
        counter++
        fmt.Fprintf(w, "Counter: %d\n", counter)
    }
}

func main() {
    http.Handle("/count", newCounterHandler()) // Each handler has its own counter
    http.ListenAndServe(":8080", nil)
}
```
> [!CAUTION]
> Using closures can be misused (memory leaks). Be careful when using them.
