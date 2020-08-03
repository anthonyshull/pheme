![logo](logo.svg)

<hr>

> Between the earth and skies she flies by night,
> screeching across the darkness, and she never
> closes her eyes in gentle sleep.
>
> &mdash; The Aeneid

Pheme, pronounced *FEE-mee*, is written in [Racket](https://racket-lang.org/).

Installing Racket (Ubuntu):
```
%> sudo add-apt-repository ppa:plt/racket
%> sudo apt update
%> sudo apt install racket
```

## DEVELOP

The best way (for beginners) to write and run Racket is with DrRacket:
```
%> drracket main.rkt
```
You can also use the REPL:
```
%> racket
Welcome to Racket v7.7.
> (enter! "main.rkt")
```

## TEST

You will need to have access to a Kubernetes Cluster.
We use [microk8s](https://microk8s.io/).

Create a proxy so that you can access the API externally:
```
%> microk8s.kubectl proxy --port=5555
```

Create the namespace and run the deployment manifest:
```
%> microk8s.kubectl apply -f deploy/deployment.yml
```

Scale the deployment down to 1: 
```
%> microk8s.kubectl scale deployment/pheme -n pheme --replicas=1
```

## BUILD

```
%> raco exe -o build/main main.rkt
```