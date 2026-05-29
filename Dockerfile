FROM tarantool/tarantool

WORKDIR /opt/tarantool

# Тулчейн для установки роков ВНУТРИ образа (стоковый образ их не содержит)
# luaossl (C, только для WebApp/initData) намеренно пропущен
RUN apt-get update && apt-get install -y --no-install-recommends \
      git unzip luarocks lua5.1 gcc \
 && rm -rf /var/lib/apt/lists/*

# Rocks ставятся в этом же окружении (Ubuntu 22.04)
# .rocks запекается в слой образа
COPY tnt-tg-bot.pre-build.sh ./
COPY bin/ ./bin/
RUN bash tnt-tg-bot.pre-build.sh
