NAME = inception
COMPOSE = ./srcs/docker-compose.yml
DATA_PATH = /home/fdurban/data

all: build

dirs:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
build: dirs
	@docker compose -f $(COMPOSE) up -d --build

down:
	@docker compose -f $(COMPOSE) down
clean:
	@docker compose -f $(COMPOSE) down -v --rmi all --remove-orphans

fclean:clean
	@sudo rm -rf $(DATA_PATH)
	@docker system prune -af --volumes

re: fclean all

.PHONY: all dirs build down clean fclean re
