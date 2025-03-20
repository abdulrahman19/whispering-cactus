---
title: Go — Decorator Pattern Technique Drawback With Type Assertion
date: 2025-03-16 18:07:38 
categories: [Tech, Golang]
tags: [golang, learning-go-book]
---

> This optional interface technique has one drawback. You saw earlier that it is common for implementations of interfaces to use the decorator pattern to wrap other implementations of the same interface to layer behavior. The problem is that if an optional interface is implemented by one of the wrapped implementations, you cannot detect it with a type assertion or type switch.
>
> <footer>Learning Go (2nd edition) — Chapter 7, "Use Type Assertions and Type Switches Sparingly"</footer>

This explanation refers to Go's `optional interface` technique, where interfaces optionally define additional methods, and `type assertions` (or `type switches`) are used to check if an object implements the optional interface.

However, this technique has a problem when using the decorator pattern to wrap another implementation. If the wrapped implementation supports an optional interface, the wrapper itself does not automatically inherit the interface, making it undetectable by type assertions.

```go main.go
package main

import (
	"fmt"
)

// Optional interface
type Greeter interface {
	Greet() string
}

// Concrete type implementing the optional interface
type Person struct {
	Name string
}

func (p Person) Greet() string {
	return "Hello, I'm " + p.Name
}

// Decorator wrapper that does NOT forward the interface directly
type LoudGreeter interface {
	GreetLoudly()
}

// Concrete type implementing the decorator interface
type LoudPerson struct {
	person Greeter
}

func (lp LoudPerson) GreetLoudly() {
	fmt.Println("LOUD:", lp.person.Greet())
}

func main() {
	p := Person{Name: "Alice"}
	lp := LoudPerson{person: p}

	fmt.Println(talk(lp))
}

func talk(s LoudGreeter) string {
	if _, ok := s.(Greeter); ok {
		return "LoudPerson supports Greeter"
	}

	return "LoudPerson does NOT support Greeter"
}

```
```bash output
LoudPerson does NOT support Greeter
```

To solve this issue, you need to **forward the interface** methods from the orginal implementation to the wrapper. This way, the wrapper can be detected as implementing the optional interface.

```diff main.go
package main

import (
	"fmt"
)

// Optional interface
type Greeter interface {
	Greet() string
}

// Concrete type implementing the optional interface
type Person struct {
	Name string
}

func (p Person) Greet() string {
	return "Hello, I'm " + p.Name
}

// Decorator wrapper that does NOT forward the interface directly
type LoudGreeter interface {
	GreetLoudly()
}

// Concrete type implementing the decorator interface
type LoudPerson struct {
	person Greeter
}

+ func (lp LoudPerson) Greet() string {
+ 	return lp.person.Greet() + "!!" // Adding extra behavior
+ }

func (lp LoudPerson) GreetLoudly() {
- 	fmt.Println("LOUD:", lp.person.Greet())
+ 	fmt.Println("LOUD:", lp.Greet())
}

func main() {
	p := Person{Name: "Alice"}
	lp := LoudPerson{person: p}

	fmt.Println(talk(lp))chat
}

func talk(s LoudGreeter) string {
	if _, ok := s.(Greeter); ok {
		return "LoudPerson supports Greeter"
	}

	return "LoudPerson does NOT support Greeter"
}

```
```bash output
LoudPerson supports Greeter
```
