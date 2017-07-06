# DManga

DManga é um script/programa ruby multiplataforma Window/Linux/Mac 
para baixar mangas de mangahost.net. Com ele voce pode baixar 
qualquer manga hospedado em mangahost.net (site br de hospedagem de
manga) de forma automatizada e sem restrição de quantidade. Basta 
dizer o nome do manga e selecionar os capitulos que deseja baixar 
e pronto o script fará os downloads do capitulos selecionados.

#### Atualização 

> - Corrigido erro com download de shokugeki no souma 
> - Corrigido erro com download de elfen lied 
> - Corrigido erro com download de tokyo ghoul:re no windows  

> **Se acontecer qualquer erro atualize o script/programa (esse erro provalvemente já foi corrigido)**.  

> Para atualizar:  

> `gem update dmanga`

## Instalação

### Windows
Primeiro você precisa ter ruby instalado, você pode baixar ruby 
deste [site](https://github.com/oneclick/rubyinstaller2/releases), 
basta baixar um dos instaladores que estão abaixo do titulo 'Downloads', 
algo com o nome similar a rubyinstaller-2.4.1-1rc3-x86.exe (pode ser uma 
versão superior) para arquitetura 32 bits e rubyinstaller-2.4.1-1rc3-x64.exe para 64.

Com o ruby instalado. Abra o prompt de comando.

No prompt digite:

`gem install dmanga`

Digite Enter para executar o comando.

Com isso o script/programa será instalado.

Você pode atualizar o script/programa com:

`gem update dmanga`

Atualize sempre para obter melhoras (desempenho ou novas funcionalidades) e correções de bugs.

### Linux (debian/ubuntu)
Abra o terminal.

Se voce não tem o ruby instalado:

`$ sudo apt-get install ruby`

Em seguida:

`$ gem install dmanga`

Pode ser necessário usar o sudo.

Você pode atualizar o script/programa com:

`gem update dmanga`

Atualize sempre para obter melhoras (desempenho ou novas funcionalidades) e correções de bugs.

Obs: Eu não cheguei a testar em versões do ruby abaixo do 2.4.1,
em caso de problema procure na internet como instalar a versão do
ruby 2.4.1 ou superior.

## Uso

`dmanga [opções] <nome do manga>`

obs: o script/programa é executado no prompt.

Ex1:

`dmanga "one piece"`

Ex2:

`dmanga tomo-chan`

Ex3:
<!--![exemplo de uso](https://github.com/david-endrew/somethings/blob/master/uso_exemplo.gif)-->
![exemplo de uso](https://github.com/david-endrew/somethings/blob/master/uso_exemplo.gif)

obs: A pasta padrão de destino dos downloads é a pasta Downloads mas 
você pode dizer ao script a pasta de destino do downloads com a 
opçao -d, veja [Opções](#opções) para mais detalhes.

obs: o nome do manga não precisa ser o nome exato, pode ser parte do
nome ou alguma palavra contida no nome, em todo caso o script/programa
fará uma busca no site com o nome passado.

obs: você pode cancelar a execução do script/program a qualquer hora
clicando ctrl-c no prompt.

**obs: se o nome do manga contiver mais de uma palavra coloque-o 
entre aspas**.

O scrip/program mostará os mangas encontrados na busca no site 
um de cada vez, selecione o que corresponde a sua busca.

Após será mostrada a lista de capitulos encontrados para aquele manga.

Quando ele perguntar "Quais capitulos você que baixar?", digite
uma das sequintes opções:

1. Para baixar todos so capitulos:

    `todos`

    Baixa todos os capitulos disponiveis.

2. Para selecionar um intervalo digite:

    `inicio-fim`

    Ex1:

    `10-222`

    Baixa do capitulo 10 ao 222.

    Ex2:

    `1-1l`

    Baixa do capitulo 1 ao 11.

    Se voce quiser baixar de um certo capitulo ao ultimo, basta digitar
    no limite superior do intervalo um numero maior que o numero do
    ultimo capitulo (ex: 999999).

3. Para selecionar capitulos especificos:

    `numeroDoCapitulo,numeroDoCapitulo,numeroDoCapitulo`

    Ex:

    `2,5,130`

    Baixa os capitulos 2, 5 e 130.

    Obs: os numeros dos capitulos devem ser digitados separados por
    virgula e **sem espaços**.

### Opções

`--version`

Mostra o numero da versao do programa e sai.

`-d <pasta de download>, --directory <pasta de download>`

Define a pasta de destino do downlaod.

`-h , --help`

Mostra a messagem de ajuda e sai.

`-v , --verbose`

Mostra detalhes da execução do programa.

### Exemplos

`dmanga -d "C:\Users\usuario\images\manga e animes" "One piece"`

No windows, baixe 'One piece' para 'C:\Users\usuario\images\manga e animes'

`dmanga "One punch man"`

Baixe 'One punch man' para 'Downloads'. 

`dmanga -d /home/usuario/Images/mangas tomo-chan`

No linux baixe 'tomo-chan' para '/home/usuario/Images/mangas'. 

### Exemplos de seleção de capitulos

`todos`

Baixa todos os capitulos.

`34-96`

Baixa do capitulo 34 ao 96.

`1,3,55`

Baixa os capitulos 1, 3 e 55.

`34,124`

Baixa os capitulos 34 e 124.

`200`

Baixa o capitulo 200.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
