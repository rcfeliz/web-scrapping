# HTML e XPath

# html --------------------------------------------------------------------

# HTML (Hypertext Markup Language) é uma linguagem de marcação
# Todo site tem pelo menos um arquivo .html

# O arquivo html gera um DOM (Documento Object Document).
# O DOM é composto de 4 coisas:
# - tag: São grandes títulos. Ele dá a ordem hierarquica das coisas
  # o <head> traz as coisas que a página carrega (bibliotecas, metadados)
  # o <body> traz o corpo do texto, divido em níveis de texto
    # dentro do body, tem o <h1> = header 1
    # <h2> = header 2
    # <p> = parágrafo
# - texto: Existem textos relacionados a cada tag
# - atributo: Pode ser a cor do texto
# - comentário

# O html é dividido em seções (tags)

# e cada tag tem atributos

# a estrutura das coisas é hierárquica, em formato pai/filho


# Passo a passo --------------------------------------------------------------------
# 1) O primeiro passo, é salvar o link
u_jfce <- "https://www.jfce.jus.br/institucional/composicao"

# 2) segundo passo é baixar o html desse link
# a gente faz isso com GET, que é uma função do httr
library(httr)
r_jfce <- httr::GET(u_jfce, httr::write_disk("data-raw/jfce.html", overwrite = TRUE))

# 3) o terceiro passo é puxar o arquivo html baixado, a gente vai usar o <xml2>
library(xml2)
html <- xml2::read_html("data-raw/jfce.html")

# 4) o quarto passo é acessar os elementos do html.
# Tem várias formas de acessar as coisas.
# Aqui começa a entrar a teoria do XPath

# vamos tentar acessar todos os <h4>
xml2::xml_find_all(html, "//h4")
# aqui a gente usou o "//"
# "//" significa: não importa o que vem antes; eu quero os <h4> independente da posição hierarquica que ele ocupa
# ou seja, "//" é "pesquise qualquer coisa que tenha h4"
# ao todo (find_all + //) a gente vai pegar todos os ancestrais de h4

# aqui a gente pode acessar só o primeiro h4
xml2::xml_find_first(html, "//body/div/div/div/div/div/h4")
# nesse caso, a gente não falou "todos os h4", mas só o primeiro
# todos os h4s estão na posição hierarquica depois de "body/div/div/div/div/div/"
# e o "." significa "comece procurando a partir da pasta em que eu estou
# no caso, a pasta em que eu estou é o início, isto é, a tag <html>


# e para acessar os textos, a gente usa
xml2::xml_text(html)
# se eu não especificar caminho, eu vou pegar todos os textos
# para especificar caminho, eu faço assim:
h4 <- xml2::xml_find_all(html, "//h4")
xml2::xml_text(h4)

# e para pegar atributos, a gente faz:
xml_attrs(h4)
# nesse caso, só o terceiro header 4 tem atributo
# se eu quiser pegar um um atributo específico, eu uso:
xml_attr(h4, "style")
xml_attr(h4, "class")

rvest::html_table(html)

# eu posso acessar com CSS path também
# eu preciso selecionar o item que eu quero pegar, copy XPath
# ele retorna isto:
//*[@id="component-content"]/div/div[3]/h4[22]/span
# isso é uma estratégica OK
# mas muitas vezes, isso é muito específico
# então isso acaba falhando
# normalmente, o Julio tenta fazer na mão, e não pelo elemento específico
# fazer na mão é mais generalizável
# se não funciona fazer na mão, ele pega o elemento e constrói na mão em cima disso

# Passo a passo em pipeline -----------------------------------------------
u_jfce <- "https://www.jfce.jus.br/institucional/composicao"
r_jfce <- httr::GET(u_jfce, httr::write_disk("data-raw/jfce.html", overwrite = TRUE))
html_jfce <- xml2::read_html("data-raw/jfce.html")

nomes <- html_jfce |>
  xml2::xml_find_all("//table") |>
  xml2::xml_text() |>
  as.data.frame() |>
  dplyr::mutate(id = 1:50)
  #rvest::html_table()
  # isso aqui tem a propriedade header = TRUE; a gnt não vai usar

cargos <- html_jfce |>
  xml2::xml_find_all("./body/div/div/div/div/div/h4/span") |>
  xml2::xml_text() |>
  as.data.frame() |>
  dplyr::mutate(id = 1:50)

juizes <- cargos |>
  dplyr::full_join(nomes) |>
  dplyr::transmute(
    vara = `xml2::xml_text(xml2::xml_find_all(html_jfce, "./body/div/div/div/div/div/h4/span"))`,
    nome = `xml2::xml_text(xml2::xml_find_all(html_jfce, "//table"))`
  ) |>
  tidyr::separate(nome, sep = "\r\n\r\n\r", into = c("juiz_titular", "juiz_substituto")) |>
  dplyr::mutate(juiz_titular = stringr::str_remove_all(juiz_titular, "Juiz|Ju.za|Federal|Titular|Substitut.|\\c"),
                juiz_titular = stringr::str_squish(juiz_titular),
                juiz_substituto = stringr::str_remove_all(juiz_substituto, "Juiz|Ju.za|Federal|Titular|Substitut.|\\c"),
                juiz_substituto = stringr::str_squish(juiz_substituto))
  # tentar fazer acima com dplyr::across()

juizes$juiz_titular[juizes$vara == "4ª Vara"] <- "José Vidal Silva Neto"
