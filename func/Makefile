build-pack:
	pack build ce-function:pack --path . --builder heroku/builder:24

build-alt:
	pack build ce-function:alt --path . --builder heroku/builder:24 --platform linux/arm64

build-kn:
	kn func build  --builder=pack --image leradicator/ce-function:kn --path . --builder-image=heroku/builder:24 --verbose #--platform linux/arm64

run:
	docker run --rm -p 8080:8080 ce-function

nur:
	PORT=8080 LISTEN_ADDRESS=127.0.0.1:8080 ./.venv/bin/python ./service/main.py

test:
	echo "$$(pwd)"
