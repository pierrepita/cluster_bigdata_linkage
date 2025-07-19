# Comandos: 
# 1: rebuild das imagens mesmo que nada tenha mudado
docker-compose build --no-cache
docker-compose up --force-recreate --remove-orphans
# 2: remove os contêineres, volumes e órfãos
docker-compose down --volumes --remove-orphans

# 3: subir depois do build (mas atualizando)
docker compose up -d --build

# 4: só subir depois do build
docker compose up -d 

# 5: resetar um node
docker restart barravento
