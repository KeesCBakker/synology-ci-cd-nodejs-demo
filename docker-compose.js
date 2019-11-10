program:
  image: hello:latest
  restart: always
  expose:
    - 3000
  ports:
    - 3000:3000
