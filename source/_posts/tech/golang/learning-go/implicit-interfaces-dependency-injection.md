---
title: Go — Implicit Interfaces Make Dependency Injection Easier
date: 2025-03-22 23:20:02 
categories: [Tech, Golang]
tags: [golang, learning-go-book]
---

> You have a struct with two fields: one a Logger, the other a DataStore. Nothing in SimpleLogic mentions the concrete types, so there’s no dependency on them. There’s no problem if you later swap in new implementations from an entirely different provider, because the provider has nothing to do with your interface. This is very different from explicit interfaces in languages like Java. Even though Java uses an interface to decouple the implementation from the interface, the explicit interfaces bind the client and the provider together. This makes replacing a dependency in Java (and other languages with explicit interfaces) far more difficult than it is in Go.
>
> <footer>Learning Go (2nd edition) — Chapter 7, "Implicit Interfaces Make Dependency Injection Easier"</footer>

Let's take an example trying to confirm the author's point. I'll do this example in another OOP language, `PHP`, and then in `Go`.

## PHP Example
Let's say I started my program with a `Logger` class that logs messages. And I have a `InfoClient` class that uses this logger to log info messages. I also have an `ErrClient` class that uses the same logger to log error messages.
```php Logger.php
Interface LoggerInterface {
    public function info($message);
    public function error($message);
}

Class Logger implements LoggerInterface {
    public function info($message) {
        echo "Logging: $message\n";
    }

    public function error($message) {
        echo "Error: $message\n";
    }
}
```
```php InfoClient.php
Class InfoClient {
    private $logger;

    public function __construct(LoggerInterface $logger) {
        $this->logger = $logger;
    }

    public function doSomething() {
        $this->logger->info("Doing something");
    }
}
```
```php ErrClient.php
Class ErrClient {
    private $logger;

    public function __construct(LoggerInterface $logger) {
        $this->logger = $logger;
    }

    public function doAnotherThing() {
        $this->logger->error("Doing another thing");
    }
}
```
```php index.php
$logger = new Logger();
$infoClient = new InfoClient($logger);
$errClient = new ErrClient($logger);

$infoClient->doSomething();
$errClient->doAnotherThing();
```
But In the middle of the project, becuase of some new requirements, the error method needs to be seperated from the logger class. So I created a new `ErrorLogger` class that logs only errors.
```php ErrorLogger.php
Interface ErrLoggerInterface {
    public function error($message);
}

Class ErrorLogger implements ErrLoggerInterface {
    public function error($message) {
        echo "Error: $message\n";
    }
}
```
With this change I need to do 3 things:
1. Refactor the `Logger` class to remove the error method.
2. Update the `ErrClient` class to use the new `ErrorLogger` class. <small>_(the most dangerous part)_</small>
3. Update the `index.php` file that create the new `ErrorLogger` class and pass it to the `ErrClient` class. <small>_(In real life senario, this should be done in the `ErrClient` factory)_</small>

```php Logger.php
Interface LoggerInterface {
    public function info($message);
}

Class Logger implements LoggerInterface {
    public function info($message) {
        echo "Logging: $message\n";
    }
}
```
```php ErrClient.php
Class ErrClient {
    private $logger;

    public function __construct(ErrLoggerInterface $logger) {
        $this->logger = $logger;
    }

    public function doAnotherThing() {
        $this->logger->error("Doing another thing");
    }
}
```
```php index.php
$logger = new Logger();
$errorLogger = new ErrorLogger();
$infoClient = new InfoClient($logger);
$errClient = new ErrClient($errorLogger);

$infoClient->doSomething();
$errClient->doAnotherThing();
```

You may think that this is not a big deal, but in a large project, this can be a nightmare. You need to find all the places where the `Logger` class is used and update them. And if you miss one, you will have a bug in your code. I'm not only talking about the creation of the `ErrClient` class, but also the places where the `Logger` class is used as a dependency; this also cann't be done **auotmatically by the IDE**!

## Go Example
Let's do the same example in Go. I'll start with the `logger` carrying the `info` and `error` methods.

```go Logger.go
type Logger struct{}

func (l Logger) Info(message string) {
    fmt.Printf("Logging: %s\n", message)
}

func (l Logger) Error(message string) {
    fmt.Printf("Error: %s\n", message)
}
```
You many wonder where's the interface? In Go, the interface is not the producser issue, it's the consumer issue! So, I don't need to create an interface for the `Logger` struct. I can directly use the `Logger` struct in any plece need a `Info` or `Error` methods where defined in their interfaces.

Now, I'll create the `InfoClient` and `ErrClient` structs.

```go InfoClient.go
type InfoLogger interface {
    Info(message string)
}

type InfoClient struct {
    logger InfoLogger
}

func (i InfoClient) DoSomething() {
    i.logger.Info("Doing something")
}
```
```go ErrClient.go
type ErrLogger interface {
    Error(message string)
}

type ErrClient struct {
    logger ErrLogger
}

func (e ErrClient) DoAnotherThing() {
    e.logger.Error("Doing another thing")
}
```
As you can see, each struct defines the interface it needs, with only needed methods. And any struct that implements these methods can be used as a dependency. This is the power of implicit interfaces in Go.

Finally, I'll create the `main.go` file to run the program.
```go main.go
func main() {
    logger := Logger{}
    infoClient := InfoClient{logger}
    errClient := ErrClient{logger}

    infoClient.DoSomething()
    errClient.DoAnotherThing()
}
```
And also because of the requirement changes, I need to separate the `Error` method from the `Logger` struct. I'll create a new `ErrorLogger` struct that carries the `Error` method.
```go ErrorLogger.go
type ErrorLogger struct{}

func (e ErrorLogger) Error(message string) {
    fmt.Printf("Error: %s\n", message)
}
```
Now, if I need to separate the `Error` method from the `Logger` struct, I only need 2 easy steps:
1. Refactor the `Logger` struct to remove the `Error` method.
2. Update the `ErrClient` struct creation/factory to use the new `ErrorLogger` struct.

```go ErrorLogger.go
type Logger struct{}

func (l Logger) Info(message string) {
    fmt.Printf("Logging: %s\n", message)
}
```
```go main.go
func main() {
    logger := Logger{}
    errorLogger := ErrorLogger{}
    infoClient := InfoClient{logger}
    errClient := ErrClient{errorLogger}

    infoClient.DoSomething()
    errClient.DoAnotherThing()
}
```
That's it! I don't need to touch the `ErrClient` struct or any other place where the `Logger` struct is used as a dependency. This is the power of implicit interfaces in Go. 😍
