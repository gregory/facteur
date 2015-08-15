build:
	docker build -t facteur .
dev:
	docker run -it --rm -v `pwd`:/code -w /code facteur bundle exec guard -p
