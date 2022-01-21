# How to web scrapping

# parte I -----------------------------------------------------------------
# 1) Política do web scrapping
# Quando usar: Quando precisamos coletar um grande volume de dados da internet
# Quando não usar:
# - Quando tiver outras formas de acessar
# - Quando os termos de uso não permitirem (robots.txt + outras coisas)
# - Quando as informações do site não são públicas

# se é para fazer pesquisa, mande um email para o site!

# 2) Tipos de problemas (em ordem de dificuldade)
# a) APIs disponíveis: O site fornece uma forma estruturada e
  # documentada para acessar as páginas
# b) APIs escondidas: O site não fornece essa forma estrutura e
  # documentada para acessar as páginas, mas internamente,
  # o site é alimentado por uma API e nós podemos descobrir qual é
  # e utiliza-la portanto!
# c) HTML estático: Quando não tem API e nós temos que ir entrar na selva
# d) HTML dinâmico: Quando a selva é um lugar horrível e tenebroso.
  # Uma página dinâmica é uma página criada por javascript
  # então se eu baixo uma página da forma comum, eu não consigo ver nada
  # nesse caso, eu preciso simular o navegar

# I.I) APIs diretas ------------------------------------------------------------
# 1) Definição de API
# Uma API é assim. Imagina que tem uma pessoa numa sala. Essa sala ta cheia de arquivos.
# e a sala é a prova de som. Você quer acessar os arquivos da sala
# mas não consegue falar pra pessoa que arquivos você quer
# a única forma q vc consegue se comunicar com a pessoa ali dentro é
# passando um papelzinho por debaixo da porta
#

# 2) Como funciona uma API?
# a) ACESSAR
# A gente precisa estudar a documentação da API pra fazer isso
# O que nós queremos fazer para acessar a API é dar instruções para a API
# (pois lembra, a API é o papelzinho que a gente vai enviar por debaixo da porta)
# (e esse papelzinho contém informações)

# pode ser que o acesso esteja subordinado a uma autenticação, um toen

# b) COLETAR
# Geralmente a gente coleta isso por requisições do tipo GET
# a requisição do tipo GET pode ou não possuir parâmetros para acessar as informações
# o resultado retornado é um arquivo .json

# c) INSERIR
# Geralmente são requisições do tipo POST
# Necssariamente utiliza parâmetros para enviar informações ao servidor

# D) HTTR
# O pacote que usamos para isso é o httr, feito pelo Hadley Wickham
# Vamos ao codigo!


# base do API -------------------------------------------------------------
url_base <- "https://pokeapi.co/api/v2" # não muda na mesma API !
endpoint <- "/pokemon/ditto"
u_pokemon <- paste0(url_base, endpoint)
r_pokemon <- httr::GET(u_pokemon)

# Esse GET vai retornar:
# Status:
# - 200 OK
# - 302 Uma página redireciona para outra
# - 400 Requisição mal formatada
# - 401 Não autorizado
# - 404 Não encontrado
# - 503 Erro no servidor
# Tem muitas outras

# Content type: é o tipo de dado que retornou

# Size: é o tamanho do dado

# resultado da API --------------------------------------------------------
# para observar o resultado da API, eu uso a função content()
httr::content(r_pokemon)

# o content, pode ter 3 formas de saída
httr::content(r_pokemon, "text") # sai um texto único
httr::content(r_pokemon, "raw") # é pouco utilizado
httr::content(r_pokemon, "parsed") # é a forma padrão

# Eu posso juntar isso a uma função do jsonlite::fromJSON()

httr::content(r_pokemon, "text") %>%
  jsonlite::fromJSON(simplifyDataFrame = T)

# O fromJSON() tem um parâmetro: simplifyDataFrame()
# o que ele faz mesmo?


# parametros do GET -------------------------------------------------------
# 1) query
# a gente também pode pegar informações filtrando com o código
q_pokemon <- list(
  limit = 8,
  offset = 1
)

r_pokemon_filtrado <- httr::GET(
  paste0(url_base, "/pokemon"),
  query = q_pokemon # <---
)

# essa query é equivalente a colar isso na url
# offset=8&limit=1
r_pokemon_filtrado2 <- GET(
  "https://pokeapi.co/api/v2/pokemon?limit=8&offset=1"
)

# 2) httr::write_disk()

dir.create("output", showWarning = FALSE, recursive = TRUE)

GET(
  paste0(url_base, "/pokemon"),
  query = q_pokemon,
  write_disk("output/01-pokemon.json", overwrite = TRUE)
)
# guardar em disco é uma forma de fazer um backup do web scrapping
# basicamente, o problema é:
# quando a gente faz web scrapping muito grande, pode dar problema no meio do caminho
# se a gente não guardar em disco, então tudo vai se perder, se der algum problema
# se guardar em disco, ele vai salvar tudo que deu certo ATÉ o problema

# além disso, é importante separar as etapas de baixar os dados da etapa de processar os dados
# baixar os dados = acessar
# processar = faxina


# I.II) APIs escondidas

# inspecionar elemento ----------------------------------------------------
# Para isso, a gente vai no site e clica f12 OU crtl+shift+I
# ou clica no botão direito e busca por "inspecionar"

# normalmente, a gente usa ali dentro elements e network.
  # - elements: Mostra o código fonte da minha página agora,
    # os elementos de código que compõem o que eu estou vendo na página
  # - network: É a aba secreta e salvadora. Quando eu mudo alguma coisa no site
    # o network acumula as minhas requisições
