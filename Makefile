build-pack:
	pack build ce-function --path . --builder heroku/builder:24

build-alt:
	pack build ce-function --path . --builder heroku/builder:24 --platform linux/amd64

build-kn:
	func build --path $$(pwd)  --builder=pack --builder-image=heroku/builder:24 --verbose --image leradicator/ce-function:0.1.0

run:
	docker run --rm -p 8080:8080 ce-function

nur:
	PORT=8080 LISTEN_ADDRESS=127.0.0.1:8080 ./.venv/bin/python ./service/main.py

test:
	echo "$$(pwd)"
