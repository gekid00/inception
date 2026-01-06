# Load USER variable from .env file
include srcs/.env
export

all:
	@if ! grep -q "127.0.0.1 $(USER).42.fr" /etc/hosts; then \
		echo "127.0.0.1 $(USER).42.fr" | sudo tee -a /etc/hosts > /dev/null; \
		echo "Added $(USER).42.fr to /etc/hosts"; \
	fi
	@mkdir -p /home/$(USER)/data/mariadb
	@mkdir -p /home/$(USER)/data/wordpress
	@cd srcs && docker-compose up -d --build

down:
	@cd srcs && docker-compose down

re: fclean all

clean:
	@cd srcs && docker-compose down -v

fclean:
	@cd srcs && docker-compose down -v
	@docker system prune -af
	@sudo rm -rf /home/$(USER)/data

.PHONY: all down re clean fclean
