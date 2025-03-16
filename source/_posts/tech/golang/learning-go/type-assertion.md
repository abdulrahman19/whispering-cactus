---
title: Go — Type Assertion
date: 2025-03-16 01:36:34
categories: [Tech, Golang]
tags: [golang, learning-go-book]
---

> A type assertion names the concrete type that implemented the interface, or names another interface that is also implemented by the concrete type whose value is stored in the interface. 
>
> <footer>Learning Go (2nd edition) — Chapter 7, "Type Assertions and Type Switches"</footer>

**What the previous statement means:**
* `Type assertion` retrieves the actual (concrete) type inside an interface
    * If an `interface{}` holds a `string`, you can extract that `string` using a type assertion.
* `Type assertion` can also assert another interface type
    * If a concrete type implements multiple interfaces, you can assert from one interface to another.

## Extracting a Concrete Type from an Interface
```go main.go
package main

import "fmt"

func main() {
	var i interface{} = "Hello, Go!"

	// Type assertion to extract the string
	s, ok := i.(string)
	if ok {
		fmt.Println("Extracted:", s)
	} else {
		fmt.Println("Type assertion failed")
	}
}
```
```bash output
Extracted: Hello, Go!
```

> [!CAUTION]
> If the `type assertion` fails, the second value (`ok`) will be `false`. Always check the `ok` value before using the extracted value. Otherwise, it will **panic**.

## Asserting from One Interface to Another
A concrete type can implement multiple interfaces. A type assertion can check if it implements another interface.
```go main.go
package main

import "fmt"

// Define two interfaces
type Speaker interface {
	Speak() string
}

type Greeter interface {
	Greet() string
}

// Define a struct that implements both interfaces
type Person struct {
	Name string
}

func (p Person) Speak() string {
	return "Hello!"
}

func (p Person) Greet() string {
	return "Welcome!"
}

func main() {
	var s Speaker = Person{"Alice"} // Speaker interface

	// Assert that s (Speaker) also implements Greeter
	g, ok := s.(Greeter)
	if ok {
		fmt.Println(g.Greet())
	}
}
```
```bash output
Welcome!
```
