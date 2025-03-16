---
title: Go — Pointer Receivers vs Value Receivers
date: 2025-03-16 00:22:34
categories: [Tech, Golang]
tags: [golang, learning-go-book]
---

>Go uses parameters of pointer type to indicate that a parameter might be modified by the function. The same rules apply for method receivers too. They can be pointer receivers (the type is a pointer) or value receivers (the type is a value type). The following rules help you determine when to use each kind of receiver:
>- If your method modifies the receiver, you must use a pointer receiver.
>- If your method needs to handle nil instances, then it must use a pointer receiver.
>- If your method doesn’t modify the receiver, you can use a value receiver.
>
> <footer>Learning Go (2nd edition) – Chapter 7, "Pointer Receivers and Value Receivers"</footer>

It is a common debate in Go community to use `value receiver` vs. `pointer receiver` for methods. Does it impact performance? Let's explore the rules and performance implications of using value vs. pointer receivers.

## General Rules
Use a `value receiver` when:
* The struct is **small** (e.g., primitive types or a few fields).
* The method does not modify the struct.
* You want the method to work on a copy of the struct.
* The struct stays on the stack (avoiding heap allocations).

Use a `pointer receiver` when:
* The struct is **large**, and copying it would be costly.
* You need to modify the struct inside the method.
* You want to avoid unnecessary copying for efficiency.
* You want to ensure all methods have a consistent receiver type.

## How Receiver Types Affect Performance?
Let’s start with a small struct and compare the performance of `value` and `pointer` receivers.

```go product_test.go
package main

import (
	"fmt"
	"testing"
)

type Product struct {
	ID   int
	Name string
}

// Value receiver
func (p Product) StringValue() string {
	return fmt.Sprintf("Product: %d %s", p.ID, p.Name)
}

// Pointer receiver
func (p *Product) StringPointer() string {
	return fmt.Sprintf("Product: %d %s", p.ID, p.Name)
}

// Benchmark for value receiver
func BenchmarkValueReceiver(b *testing.B) {
	p := Product{1, "Laptop"}
	for i := 0; i < b.N; i++ {
		_ = p.StringValue()
	}
}

// Benchmark for pointer receiver
func BenchmarkPointerReceiver(b *testing.B) {
	p := &Product{1, "Laptop"}
	for i := 0; i < b.N; i++ {
		_ = p.StringPointer()
	}
}
```
```bash
go test -bench=. -run=^$
```
```bash output
BenchmarkValueReceiver-14        4666302      228.2 ns/op
BenchmarkPointerReceiver-14      5040805      230.6 ns/op
```
Now, let's make the struct a bit larger and see how the performance changes.

```go product_test.go
package main

import (
	"fmt"
	"testing"
)

type Product struct {
	ID         int
	Name       string
	Tags       []string
	Categories []string
	Attributes map[string]string
	Owner      Owner
}

type Owner struct {
	ID   int
	Name string
}

// Value receiver
func (p Product) StringValue() string {
	return fmt.Sprintf("Product: %d %s", p.ID, p.Name)
}

// Pointer receiver
func (p *Product) StringPointer() string {
	return fmt.Sprintf("Product: %d %s", p.ID, p.Name)
}

// Benchmark for value receiver
func BenchmarkValueReceiver(b *testing.B) {
	p := Product{
		1,
		"Laptop",
		[]string{"tag_1"},
		[]string{"cat_1"},
		map[string]string{
			"Att_1": "val",
		},
		Owner{1, "Adam"},
	}
	for i := 0; i < b.N; i++ {
		_ = p.StringValue()
	}
}

// Benchmark for pointer receiver
func BenchmarkPointerReceiver(b *testing.B) {
	p := &Product{
		1,
		"Laptop",
		[]string{"tag_1"},
		[]string{"cat_1"},
		map[string]string{
			"Att_1": "val",
		},
		Owner{1, "Adam"},
	}
	for i := 0; i < b.N; i++ {
		_ = p.StringPointer()
	}
}
```
```bash
go test -bench=. -run=^$
```
```bash output
BenchmarkValueReceiver-14        4908726      234.9 ns/op
BenchmarkPointerReceiver-14      5040136      230.6 ns/op
```

The conclusion from the benchmarks is that the performance difference between `value` and `pointer` receivers is negligible for small structs. However, for larger structs, the pointer receiver is slightly faster due to avoiding copying the struct.
